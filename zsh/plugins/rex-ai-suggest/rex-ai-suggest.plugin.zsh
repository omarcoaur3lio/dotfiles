# rex-ai-suggest: Sugestoes proativas e sob demanda no Zsh usando rex capture + Gemini

zmodload zsh/system 2>/dev/null
autoload -Uz add-zsh-hook add-zle-hook-widget

# Caminho portavel do plugin e do helper Python
typeset -g _REX_AI_PLUGIN_DIR="${${(%):-%x}:A:h}"
typeset -g _REX_AI_BIN="${_REX_AI_PLUGIN_DIR}/bin/rex-ai-suggest"

# Configuracoes sobreescreviveis via ~/.zshrc.local
: "${REX_AI_ENABLED:=1}"
: "${REX_AI_PROACTIVE_MODE:=smart}"
: "${REX_AI_MODEL:=gemini-3.5-flash-lite}"
: "${REX_AI_KEYBIND:=^G}"
: "${REX_AI_HIGHLIGHT_STYLE:=fg=8}"

# Estado interno do worker assincrono e ultimo comando
typeset -g _REX_AI_ASYNC_FD=""
typeset -g _REX_AI_CHILD_PID=""
typeset -gi _REX_AI_REQ_ID=0
typeset -g _REX_AI_REQ_MODE=""
typeset -g _REX_AI_REQ_BUFFER=""
typeset -g _REX_AI_PENDING_SUGGESTION=""
typeset -g _REX_AI_LAST_CMD=""
typeset -gi _REX_AI_LAST_EXIT=0
typeset -gi _REX_AI_CMD_RAN=0
typeset -g _REX_AI_LAST_HIGHLIGHT=""

# Evita que o zsh-autosuggestions re-encapsule nosso widget como 'modify'
if (( ! ${+ZSH_AUTOSUGGEST_IGNORE_WIDGETS} )); then
  typeset -ga ZSH_AUTOSUGGEST_IGNORE_WIDGETS
fi
if (( ! ${ZSH_AUTOSUGGEST_IGNORE_WIDGETS[(Ie)rex-ai-suggest]} )); then
  ZSH_AUTOSUGGEST_IGNORE_WIDGETS+=(rex-ai-suggest)
fi

_rex_ai_has_credentials() {
  [[ -n "${REX_AI_API_KEY:-}" || -n "${GEMINI_API_KEY:-}" || "${REX_AI_USE_KEYCHAIN:-0}" == "1" ]]
}

_rex_ai_highlight_reset() {
  if (( $+functions[_zsh_autosuggest_highlight_reset] )); then
    _zsh_autosuggest_highlight_reset
  elif [[ -n "$_REX_AI_LAST_HIGHLIGHT" ]]; then
    region_highlight=("${(@)region_highlight:#$_REX_AI_LAST_HIGHLIGHT}")
    _REX_AI_LAST_HIGHLIGHT=""
  fi
}

_rex_ai_highlight_apply() {
  if (( $+functions[_zsh_autosuggest_highlight_apply] )); then
    _zsh_autosuggest_highlight_apply
  elif (( $#POSTDISPLAY )); then
    _REX_AI_LAST_HIGHLIGHT="$#BUFFER $(($#BUFFER + $#POSTDISPLAY)) $REX_AI_HIGHLIGHT_STYLE"
    region_highlight+=("$_REX_AI_LAST_HIGHLIGHT")
  else
    _REX_AI_LAST_HIGHLIGHT=""
  fi
}

_rex_ai_cancel_async() {
  if [[ -n "$_REX_AI_ASYNC_FD" ]]; then
    zle -F "$_REX_AI_ASYNC_FD" 2>/dev/null
    if { true <&$_REX_AI_ASYNC_FD } 2>/dev/null; then
      builtin exec {_REX_AI_ASYNC_FD}<&- 2>/dev/null
    fi
    _REX_AI_ASYNC_FD=""
  fi

  if [[ -n "$_REX_AI_CHILD_PID" ]]; then
    if [[ -o MONITOR ]]; then
      kill -TERM -"$_REX_AI_CHILD_PID" 2>/dev/null
    else
      kill -TERM "$_REX_AI_CHILD_PID" 2>/dev/null
    fi
    _REX_AI_CHILD_PID=""
  fi
}

_rex_ai_apply_widget() {
  emulate -L zsh

  local suggestion="$1"
  local mode="$2"
  local orig_buffer="$3"

  _rex_ai_highlight_reset

  if [[ "$POSTDISPLAY" == " …" ]]; then
    POSTDISPLAY=""
  fi

  if [[ -z "$suggestion" ]]; then
    _rex_ai_highlight_apply
    zle -R
    return 0
  fi

  if [[ "$mode" == "proactive" ]]; then
    if [[ -z "$BUFFER" ]]; then
      POSTDISPLAY="$suggestion"
    fi
  else
    if [[ "$BUFFER" == "$orig_buffer" ]]; then
      if [[ -z "$BUFFER" ]]; then
        POSTDISPLAY="$suggestion"
      elif [[ "$suggestion" == "$BUFFER"* ]]; then
        POSTDISPLAY="${suggestion#$BUFFER}"
        CURSOR=$#BUFFER
      else
        BUFFER="$suggestion"
        CURSOR=$#BUFFER
        POSTDISPLAY=""
        (( $+functions[_zsh_highlight] )) && _zsh_highlight
      fi
    fi
  fi

  _rex_ai_highlight_apply
  zle -R
}
zle -N _rex_ai_apply_widget

_rex_ai_async_callback() {
  emulate -L zsh

  local fd="$1"
  local err="${2:-}"
  local suggestion=""

  if [[ -z "$err" || "$err" == "hup" ]]; then
    IFS='' read -rd '' -u "$fd" suggestion
  fi

  zle -F "$fd" 2>/dev/null
  builtin exec {fd}<&- 2>/dev/null

  if [[ "$fd" != "$_REX_AI_ASYNC_FD" ]]; then
    return 0
  fi

  _REX_AI_ASYNC_FD=""
  _REX_AI_CHILD_PID=""

  if ! zle _rex_ai_apply_widget -- "$suggestion" "$_REX_AI_REQ_MODE" "$_REX_AI_REQ_BUFFER" 2>/dev/null; then
    if [[ "$_REX_AI_REQ_MODE" == "proactive" ]]; then
      _REX_AI_PENDING_SUGGESTION="$suggestion"
    fi
  fi
}

_rex_ai_start_async() {
  local mode="$1"
  local last_cmd="$2"
  local exit_code="$3"
  local buffer="$4"

  [[ -x "$_REX_AI_BIN" ]] || return 0

  _rex_ai_cancel_async

  _REX_AI_REQ_ID=$(( _REX_AI_REQ_ID + 1 ))
  _REX_AI_REQ_MODE="$mode"
  _REX_AI_REQ_BUFFER="$buffer"

  local recent_history
  recent_history="$(fc -ln -5 2>/dev/null)"

  builtin exec {_REX_AI_ASYNC_FD}< <(
    echo "$sysparams[pid]"
    "$_REX_AI_BIN" \
      --mode="$mode" \
      --cwd="$PWD" \
      --last-cmd="$last_cmd" \
      --exit-code="$exit_code" \
      --buffer="$buffer" \
      --history="$recent_history" \
      --block="${REX_BLOCK:-}" 2>/dev/null
  )

  read -r _REX_AI_CHILD_PID <&$_REX_AI_ASYNC_FD
  zle -F "$_REX_AI_ASYNC_FD" _rex_ai_async_callback
}

_rex_ai_preexec() {
  _REX_AI_LAST_CMD="$1"
  _REX_AI_CMD_RAN=1
  _REX_AI_PENDING_SUGGESTION=""
  _rex_ai_cancel_async
}

_rex_ai_precmd() {
  local last_exit=$?
  _REX_AI_LAST_EXIT=$last_exit

  _rex_ai_cancel_async
  _REX_AI_PENDING_SUGGESTION=""

  if (( _REX_AI_CMD_RAN != 1 )); then
    return 0
  fi
  _REX_AI_CMD_RAN=0

  [[ "$REX_AI_ENABLED" == "1" ]] || return 0
  [[ "$REX_AI_PROACTIVE_MODE" != "off" ]] || return 0
  [[ -n "${REX_BLOCK:-}" ]] || return 0
  _rex_ai_has_credentials || return 0
  [[ -x "$_REX_AI_BIN" ]] || return 0

  _rex_ai_start_async "proactive" "$_REX_AI_LAST_CMD" "$last_exit" ""
}

_rex_ai_zle_line_init() {
  if [[ -n "$_REX_AI_PENDING_SUGGESTION" && -z "$BUFFER" ]]; then
    local pending="$_REX_AI_PENDING_SUGGESTION"
    _REX_AI_PENDING_SUGGESTION=""
    _rex_ai_apply_widget "$pending" "proactive" ""
  fi
}

rex-ai-suggest() {
  emulate -L zsh

  [[ "$REX_AI_ENABLED" == "1" ]] || {
    zle -M "rex-ai-suggest esta desativado (use rex-ai-toggle para ativar)"
    return 0
  }

  _rex_ai_has_credentials || {
    zle -M "rex-ai: configure GEMINI_API_KEY em ~/.zshrc.local"
    return 0
  }

  [[ -x "$_REX_AI_BIN" ]] || return 0

  _rex_ai_highlight_reset
  POSTDISPLAY=" …"
  _rex_ai_highlight_apply
  zle -R

  _rex_ai_start_async "manual" "$_REX_AI_LAST_CMD" "$_REX_AI_LAST_EXIT" "$BUFFER"
}

zle -N rex-ai-suggest
bindkey -M emacs "$REX_AI_KEYBIND" rex-ai-suggest
bindkey -M viins "$REX_AI_KEYBIND" rex-ai-suggest

add-zsh-hook preexec _rex_ai_preexec
add-zsh-hook precmd _rex_ai_precmd
add-zle-hook-widget line-init _rex_ai_zle_line_init

rex-ai-toggle() {
  if [[ "$REX_AI_ENABLED" == "1" ]]; then
    export REX_AI_ENABLED=0
    _rex_ai_cancel_async
    _REX_AI_PENDING_SUGGESTION=""
    echo "rex-ai-suggest: desativado"
  else
    export REX_AI_ENABLED=1
    echo "rex-ai-suggest: ativado (modelo: $REX_AI_MODEL, modo: $REX_AI_PROACTIVE_MODE)"
  fi
}

rex-ai-status() {
  if [[ -x "$_REX_AI_BIN" ]]; then
    "$_REX_AI_BIN" --status --cwd="$PWD" --block="${REX_BLOCK:-}"
  else
    echo "rex-ai-suggest: helper nao encontrado em $_REX_AI_BIN" >&2
    return 1
  fi
  echo "  keybind:        $REX_AI_KEYBIND"
}

rex-ai-test() {
  local live=0
  if [[ "${1:-}" == "--live" ]]; then
    live=1
    shift
  fi

  local test_cmd="${1:-git status}"
  local test_exit="${2:-0}"
  local recent_history
  recent_history="$(fc -ln -5 2>/dev/null)"

  if (( live )); then
    "$_REX_AI_BIN" \
      --mode=proactive \
      --cwd="$PWD" \
      --last-cmd="$test_cmd" \
      --exit-code="$test_exit" \
      --history="$recent_history" \
      --block="${REX_BLOCK:-}"
    echo
  else
    "$_REX_AI_BIN" \
      --dry-run \
      --mode=proactive \
      --cwd="$PWD" \
      --last-cmd="$test_cmd" \
      --exit-code="$test_exit" \
      --history="$recent_history" \
      --block="${REX_BLOCK:-}"
  fi
}
