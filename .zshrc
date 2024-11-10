# Use emacs keymap as the default.
bindkey -e

# shift-tab backwards through menu
bindkey -M emacs '^[[Z' reverse-menu-complete
# completion menu highlighting
zstyle ':completion:*' menu select
# case-insensitive completion
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

brew_completion=$(brew --prefix 2>/dev/null)/share/zsh/site-functions
if [ $? -eq 0 ] && [ -d "$brew_completion" ];then
  fpath=($brew_completion $fpath)
fi

autoload -U compinit && compinit

# KEY BINDINGS
# better word navigation
export WORDCHARS="${WORDCHARS/\//}"
# bind [delete] for forward deletion
bindkey -M emacs "^[[3~" delete-char
bindkey -M emacs "^[3;5~" delete-char

autoload -U colors && colors

# HISTORY
HISTSIZE="10000"
SAVEHIST="10000"

HISTFILE="$HOME/.zsh_history"
mkdir -p "$(dirname "$HISTFILE")"

setopt HIST_FCNTL_LOCK
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt APPEND_HISTORY

# PROMPT
git_branch() {
  git symbolic-ref --short HEAD 2> /dev/null | sed -e 's/\(.*\)/ \1/'
}
git_hash() {
  git rev-parse --short HEAD 2> /dev/null | sed -e 's/\(.*\)/ \1/'
}

setopt PROMPT_SUBST
export PROMPT='
%B%(?.%F{green}.%F{red})%~%F{cyan}$(git_branch)%F{blue}$(git_hash)
%F{yellow}-> %f%b'


function xtitle () {
    builtin print -n -- "\e]0;$@\a"
}

# updates the window title whenever a command is run
function precmd () {
  xtitle "zsh ($(print -P %2~))"
}

function preexec () {
  xtitle "$1 ($(print -P %2~))"
}

# Aliases
alias dotfiles='git --git-dir=$HOME/.git-dotfiles/ --work-tree=$HOME'
alias la='exa -a'
alias ll='exa -l'
alias lla='exa -la'
alias ls='exa'
alias lt='exa --tree'
alias vim='nvim'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f $HOMEBREW_PREFIX/opt/asdf/libexec/asdf.sh ] && . $HOMEBREW_PREFIX/opt/asdf/libexec/asdf.sh

export EDITOR="nvim"
export LESS="-R --no-init"
export LESSHISTFILE="-"
export BAT_THEME="ansi"
export HOMEBREW_BUNDLE_FILE="$HOME/.dotfiles/Brewfile"
export PATH="$HOME/.cargo/bin:$HOME/.local/bin:/usr/local/bin:$PATH"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
