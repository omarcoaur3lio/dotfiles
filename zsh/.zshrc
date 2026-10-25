# Caminho para a instalacao do Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"

# Tema customizado que replica o lualine + roteki-theme do Neovim
ZSH_THEME="roteki"

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
# Configuracoes de Autocomplete e Sugestoes (Paleta Roteki)
# ============================================================================

# Estilo da sugestao fantasma (usa palette.dim = #7E8B96 do Roteki)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#7E8B96"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC=1

# Menu interativo de autocomplete com navegacao por setas / Tab e case-insensitive
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' special-dirs true

# Cores do zsh-syntax-highlighting alinhadas ao Roteki Dark
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=#BCD1FF,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#BCD1FF,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#3ab877,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=#BCD1FF'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#3ab877,bold'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#3ab877,underline'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#AFD8ED'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#AFD8ED'
ZSH_HIGHLIGHT_STYLES[path]='fg=#d0d3d6,underline'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#c2606d,bold'
ZSH_HIGHLIGHT_STYLES[arg0]='fg=#BCD1FF'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#3c4349'

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
