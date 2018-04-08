  
#:::::::::::::::::::::::::::
#     ━━┓┏━┓╻  ╻┏━┓┏━╸    ::
#     ┏━┛┗━┓┃━━┃┣┳┛┃      :: 
#     ┗━━┗━┛╹  ╹╹┗╸┗━╸    ::
# by: asarch              ::
#:::::::::::::::::::::::::::

# Path to your oh-my-zsh installation.
ZSH=/home/marco/.oh-my-zsh/

# ZSH theme. Necessary package oh-my-zsh
ZSH_THEME="agnoster"
#ZSH_THEME="cypher"
#ZSH_THEME="adben"
#ZSH_THEME="josh"
#ZSH_THEME="zsh-theme-powerlevel9k/powerlevel9k"


# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

ZSH_CACHE_DIR=$HOME/.oh-my-zsh-cache
if [[ ! -d $ZSH_CACHE_DIR ]]; then
  mkdir $ZSH_CACHE_DIR
fi

source ~/.zsh_aliases

source $ZSH/oh-my-zsh.sh

#Syntax-highlighting  similar to shell Fish. Its necessary install the package zsh-syntax-highlighting
#source /home/marco/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

#Fish-like autosuggestions for zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /home/marco/.oh-my-zsh/plugins/bgnotify/bgnotify.plugin.zsh

# Historic
 export HISTFILE=${HOME}/.zsh_history
 export HISTSIZE=5000
 export SAVEHIST=$HISTSIZE

# Historic options:
 setopt EXTENDED_HISTORY
 setopt HIST_VERIFY
 setopt HIST_REDUCE_BLANKS
 setopt HIST_IGNORE_ALL_DUPS
 
setopt autopushd pushdsilent pushdtohome

setopt prompt_subst

## Remove duplicate entries
setopt pushdignoredups

# Ativando auto-correção:
setopt CORRECT
setopt CORRECT_ALL
export SPROMPT="$(print '%{\e[37m%}zsh: Corrigir para %S%r%s ? (n|y|e): %{\e[0m%}')"

# Auto-complete with <TAB>
setopt auto_list
setopt auto_menu
setopt case_glob
setopt list_types
setopt glob_complete
setopt menu_complete
setopt complete_in_word
setopt complete_aliases
autoload -Uz compinit promptinit vcs_info
compinit
promptinit
autoload -U colors 
colors

# Misc
setopt ZLE                                  
declare -U path                             
 
 # Enabling verbose mode:
zstyle ':completion:*' verbose 'yes'
zstyle ':completion:*' show-completer
 
# Persistent repetition:
zstyle ':completion:*' rehash true
 
 # Colored stripe complementation:
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors 'reply=( "=(#b)(*$VAR)(?)*=00=$color[green]=$color[bg-green]" )' 
zstyle ':completion:*:*:*:*:hosts' list-colors '=*=30;41'
zstyle ':completion:*:*:*:*:users' list-colors '=*=$color[green]=$color[red]'
zstyle ':completion:*' menu select
 
 # Visual selection menu:
zstyle ':completion:*' menu select=3 _complete _i-patterns ignored_approximate
zstyle ':completion:*' select-prompt '%S zsh: Seleção atual = %p %s'
 
# Auto description of possible additions:
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
 
# Format of self-completion messages:
zstyle ':completion:*:corrections' format '%Bzsh: %d (erros: %e)%b'
zstyle ':completion:*:descriptions' format '%U%B%d%b%u'
zstyle ':completion:*:warnings' format '%Bzsh: Inválido como: %d%b'
 
# Listing self-complementation groups:
zstyle ':completion:*:matches' groups 'yes'
zstyle ':completion:*' list-grouped
zstyle ':completion:*' group-name ''
zstyle ':completion:*:*:-command-:*' group-order commands builtins
 
# Expand as much as possible:
zstyle ':completion:incremental:*' completer _complete _correct
zstyle ':completion:*' completer _complete _correct _match _approximate
zstyle ':completion:*:expand:*' tag-order all-expansions
 
# Number of errors to accept for autocompletion:
zstyle ':completion:*:approximate:*' max-errors 2 numeric
 
# Use '/d/s <TAB>' to expand to '/dir/subdir':
zstyle ':completion:*' expand 'yes'
zstyle ':completion:*' squeeze-slashes 'yes'

# Preserve prefix/suffix for autocompletion:
zstyle ':completion:*' expand prefix suffix
zstyle ':completion:*' completer _complete _prefix _match _approximate
zstyle ':completion:*' preserve-prefix '//[^ /]##/'
zstyle ':completion:*:match:*' original only
zstyle ':completion:*approximate :*' max-errors 1 numeric
 
# Option auto-cd should ignore the current directory:
zstyle ':completion:*:cd:*' ignore-parents parent pwd
 
# Avoid duplicate entries for the commands below:
zstyle ':completion:*:rm:*' ignore-line 'yes'
zstyle ':completion:*:cp:*' ignore-line 'yes'
zstyle ':completion:*:mv:*' ignore-line 'yes'
 
# Case-sensitive self-complementation:
zstyle ':completion:*:complete:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'
 
# Self-complementary from Wildcards:
zstyle ':completion:*:complete-extended:*' matcher 'r:|[.,_-]=* r:|=*'
 
# Ignore auto-completion of internal functions of zsh:
zstyle ':completion:*:functions' ignored-patterns '_*'
 
# Autocomplete for the command 'kill':
zstyle ':completion:*:processes' command 'ps x -o pid,command'
zstyle ':completion:*:kill:*' menu yes select
zstyle ':completion:*:kill:*' force-list always
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
 
# Command help in the Zsh
autoload -U run-help
autoload run-help-git
autoload run-help-svn
autoload run-help-svk

# More info: http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Zle-Widgets
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# Prefix to use when saving original versions of bound widgets
ZSH_AUTOSUGGEST_ORIGINAL_WIDGET_PREFIX=autosuggest-orig-

ZSH_AUTOSUGGEST_STRATEGY=default

# Widgets that clear the suggestion
ZSH_AUTOSUGGEST_CLEAR_WIDGETS=(
  history-search-forward
  history-search-backward
  history-beginning-search-forward
  history-beginning-search-backward
  history-substring-search-up
  history-substring-search-down
  up-line-or-history
  down-line-or-history
  accept-line
)

# Widgets that accept the entire suggestion
ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=(
  forward-char
  end-of-line
  vi-forward-char
  vi-end-of-line
  vi-add-eol
)

# Widgets that accept the entire suggestion and execute it
ZSH_AUTOSUGGEST_EXECUTE_WIDGETS=(
)

# Widgets that accept the suggestion as far as the cursor moves
ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS=(
  forward-word
  vi-forward-word
  vi-forward-word-end
  vi-forward-blank-word
  vi-forward-blank-word-end
)

# Widgets that should be ignored (globbing supported but must be escaped)
ZSH_AUTOSUGGEST_IGNORE_WIDGETS=(
  orig-\*
  beep
  run-help
  set-local-history
  which-command
  yank
)

# Max size of buffer to trigger autosuggestion. Leave undefined for no upper bound.
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=

# Pty name for calculating autosuggestions asynchronously
ZSH_AUTOSUGGEST_ASYNC_PTY_NAME=zsh_autosuggest_pty

#  Is a global variable that defines how the query should be highlighted inside a matching command
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=default,fg=default,bold'

# Is a global variable that defines how the query should be highlighted when no commands in the history match it.
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=default,fg=white,bold'

# Is a global variable that defines how the command history will be searched for your query. Its default value causes this script to perform a case-insensitive search
HISTORY_SUBSTRING_SEARCH_GLOBBING_FLAGS='i'

# Welcome messages
#echo '                                                        (`.         ,-,    '  
#echo '                                                         ` `.    ,;` /     '
#echo '    wake up, Neo...                                       `.  ,`/ .`       '
#echo '                                                           `. X /.`        '    
#echo '      the matrix has you                         .-;--``--.._` ` (         '
#echo '                                               .´            /   `         '
#echo '          follow the white rabbit.            ,           ` `   Q `        '
#echo '                                              ,         ,   `._    \       '
#echo '      knock, knock, Neo.                   ,.|         ´     `-.;_´        '  
#echo '                                           :  . `  ;    `  ` --,.._;       '  
#echo '                                            ´ `    ,   )   .´              '
#echo '                                               `._ ,  ´   /__              '
#echo '                                                  ; ,´´-,;´ ``-            '
#echo '                                                   ``-..__``--`            '

# Set pfavorite apps.
 export BROWSER="firefox"
 export EDITOR="subl3"

 # Run anny modules:
 zmodload -i zsh/complete
 zmodload -i zsh/mapfile
 zmodload -i zsh/mathfunc
 zmodload -i zsh/complist

# Solve error of exibition the Man Pages
export MANPAGER=less

# Man pages coloridas:
 if [ -e $(`which most > /dev/null`) ]; then
    export PAGER='most -s'
    export LESSHISTFILE='-'
 else
    export PAGER=less
 fi


# key bindings
 bindkey "\e[1~" beginning-of-line
 bindkey "\e[4~" end-of-line
 bindkey "\e[5~" beginning-of-history
 bindkey "\e[6~" end-of-history
 bindkey "\e[3~" delete-char
 bindkey "\e[2~" quoted-insert
 bindkey "\e[5C" forward-word
 bindkey "\eOc" emacs-forward-word
 bindkey "\e[5D" backward-word
 bindkey "\eOd" emacs-backward-word
 bindkey "\e\e[C" forward-word
 bindkey "\e\e[D" backward-word
 bindkey "^H" backward-delete-word

# Descompact files:
    # Use: descom <file>
    descom() {
    if [ -a $1 ]
    then
       case $1 {
          *.[tT][aA][rR].[gG][zZ])    tar -xvzf $1 ;;
          *.[gG][zZ])          gunzip    $1 ;;
          *.[tT][aA][rR].[bB][zZ]2)   tar -jxvf $1 ;;
          *.[bB][zZ]2)          bunzip2   $1 ;;
          *.[tT][aA][rR])          tar -xvf  $1 ;;
          *.[tT][gG][zZ])          gunzip    $1 ;;
          *.[zZ][iI][pP])          unzip     $1 ;;
          *) print "[$1] Arquivo não suportado." ;;
       }
    else
       print "Especifique um arquivo."
    fi
    }    

# added by Anaconda3 installer
export PATH="/home/marco/anaconda3/bin:$PATH"

# corrige erro anaconda + urxvt
TERM="xterm-256color"

# ls colored:
export ZLS_COLORS=$LS_COLORS

PATH="/home/marco/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/home/marco/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/home/marco/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/home/marco/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/home/marco/perl5"; export PERL_MM_OPT;

# Settings of Locale 
 export LANG="pt_BR.utf8"
 export LC_COLLATE="C"
 umask 022

export WORKON_HOME=$HOME/.virtualenvs
source ~/.oh-my-zsh/plugins/virtualenvwrapper/virtualenvwrapper.plugin.zsh
