# Roteki Lualine Zsh Theme for Oh My Zsh
# Replica visual da statusline (lualine.nvim + roteki-theme.nvim)

# Paleta Roteki Dark (extraída de roteki/palette/dark.lua)
ROTEKI_BLACK="#111213"
ROTEKI_BG="#151718"
ROTEKI_LINE="#232628"
ROTEKI_COMMENT="#3c4349"
ROTEKI_DIM="#7E8B96"
ROTEKI_FG="#d0d3d6"
ROTEKI_TYPE="#eff1f5"
ROTEKI_SELECTION="#265457"
ROTEKI_EMPHASIS="#BCD1FF"
ROTEKI_CONST="#deb4f8"
ROTEKI_INFO="#90DFFF"
ROTEKI_SUCCESS="#3ab877"
ROTEKI_WARNING="#e3c76a"
ROTEKI_DANGER="#c2606d"
ROTEKI_ORANGE="#e08d1f"

# Separadores identicos ao lualine.lua:
# lualine_a right = '', lualine_b right = '', section right = ''
ROTEKI_SEP_A_RIGHT=""
ROTEKI_SEP_ROUND_RIGHT=""

# Formata branch do Git igual ao fmt do lualine_b (max_len = 35 + '...')
_roteki_git_branch() {
  command git rev-parse --is-inside-work-tree &>/dev/null || return 1
  local ref
  ref=$(command git symbolic-ref --quiet --short HEAD 2>/dev/null || command git rev-parse --short HEAD 2>/dev/null) || return 1
  local max_len=35
  if (( ${#ref} > max_len )); then
    ref="${ref[1,$max_len]}..."
  fi
  echo -n "$ref"
}

# Coleta diff/status do Git com os simbolos do lualine_x ( ,  ,  )
_roteki_git_diff() {
  command git rev-parse --is-inside-work-tree &>/dev/null || return
  local porcelain
  porcelain=$(command git status --porcelain --ignore-submodules=dirty 2>/dev/null) || return
  [[ -z "$porcelain" ]] && return

  local added=0 modified=0 removed=0
  local line status_xy
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    status_xy="${line[1,2]}"
    case "$status_xy" in
      \?\?|A*|*A) (( added++ )) ;;
      D*|*D)      (( removed++ )) ;;
      *)          (( modified++ )) ;;
    esac
  done <<< "$porcelain"

  local out=""
  (( added > 0 ))    && out+="%F{${ROTEKI_SUCCESS}} ${added} "
  (( modified > 0 )) && out+="%F{${ROTEKI_WARNING}} ${modified} "
  (( removed > 0 ))  && out+="%F{${ROTEKI_DANGER}} ${removed} "
  [[ -n "$out" ]] && echo -n " ${out% }"
}

# Construcao do PROMPT esquerdo (lualine_a -> lualine_b -> lualine_c)
_roteki_build_prompt() {
  local branch
  branch=$(_roteki_git_branch)
  local git_diff
  git_diff=$(_roteki_git_diff)

  # lualine_a: bg = emphasis (#BCD1FF), fg = bg (#151718), bold
  local seg_a="%K{${ROTEKI_EMPHASIS}}%F{${ROTEKI_BG}}%B ZSH %b"

  if [[ -n "$branch" ]]; then
    # Transicao lualine_a -> lualine_b com ''
    local sep_ab="%K{${ROTEKI_BLACK}}%F{${ROTEKI_EMPHASIS}}${ROTEKI_SEP_A_RIGHT}"
    # lualine_b: icon = '', bg = black (#111213), fg = fg (#d0d3d6)
    local seg_b="%K{${ROTEKI_BLACK}}%F{${ROTEKI_FG}}  ${branch} "
    # Transicao lualine_b -> lualine_c com ''
    local sep_bc="%K{${ROTEKI_LINE}}%F{${ROTEKI_BLACK}}${ROTEKI_SEP_ROUND_RIGHT}"
    # lualine_c: icone de diretorio + caminho + git diff
    local seg_c="%K{${ROTEKI_LINE}}%F{${ROTEKI_EMPHASIS}}  %F{${ROTEKI_FG}}%3~${git_diff} "
    # Fechamento lualine_c com ''
    local sep_end="%k%F{${ROTEKI_LINE}}${ROTEKI_SEP_ROUND_RIGHT}%f "
    echo -n "${seg_a}${sep_ab}${seg_b}${sep_bc}${seg_c}${sep_end}"
  else
    # Sem git: transicao direta lualine_a -> lualine_c com ''
    local sep_ac="%K{${ROTEKI_LINE}}%F{${ROTEKI_EMPHASIS}}${ROTEKI_SEP_A_RIGHT}"
    local seg_c="%K{${ROTEKI_LINE}}%F{${ROTEKI_EMPHASIS}}  %F{${ROTEKI_FG}}%3~ "
    local sep_end="%k%F{${ROTEKI_LINE}}${ROTEKI_SEP_ROUND_RIGHT}%f "
    echo -n "${seg_a}${sep_ac}${seg_c}${sep_end}"
  fi
}

_roteki_precmd() {
  PROMPT="$(_roteki_build_prompt)"
  RPROMPT=""
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _roteki_precmd
