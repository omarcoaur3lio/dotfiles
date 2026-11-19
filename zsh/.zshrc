# Caminho para a instalacao do Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"

# Tema desativado (usando o Starship como prompt)
ZSH_THEME=""

# Carrega definicoes extras do zsh-completions no fpath antes do compinit do Oh My Zsh
fpath+="${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src"

# Plugins ativos (git, autocomplete, autosuggestions e syntax highlighting)
plugins=(
  git
  zsh-completions
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

# ============================================================================
# Configuracoes de Autocomplete e Sugestoes
# ============================================================================

ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC=1

# Menu interativo de autocomplete com navegacao por setas / Tab e case-insensitive
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' special-dirs true

# Remove o sublinhado padrao em caminhos de pastas/arquivos do zsh-syntax-highlighting
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]='none'
ZSH_HIGHLIGHT_STYLES[path_prefix]='none'

# ============================================================================
# Ferramentas, Runtimes e Variaveis de Ambiente
# ============================================================================

command -v gh &>/dev/null && eval "$(gh completion -s zsh)"
command -v fnm &>/dev/null && eval "$(fnm env --use-on-cd --shell zsh)"

# Added by Antigravity CLI installer
export PATH="/Users/marco/.local/bin:$PATH"

# Java (OpenJDK 21 — exigido pelo firebase-tools 15+; o Gradle fica no 17 via ~/.gradle/gradle.properties)
export JAVA_HOME="/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"

# Android SDK
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin"

# Configuracoes locais e segredos (nunca versionados no git)
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# Sugestoes proativas com IA no Rex (rex capture + Gemini Flash-Lite)
_ZSH_DOTFILES_DIR="${${(%):-%x}:A:h}"
[[ -r "$_ZSH_DOTFILES_DIR/plugins/rex-ai-suggest/rex-ai-suggest.plugin.zsh" ]] && \
  source "$_ZSH_DOTFILES_DIR/plugins/rex-ai-suggest/rex-ai-suggest.plugin.zsh"
unset _ZSH_DOTFILES_DIR

# Inicializa o prompt Starship
command -v starship &>/dev/null && eval "$(starship init zsh)"

