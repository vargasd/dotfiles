export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share
export XDG_STATE_HOME=$HOME/.local/state

# Use emacs keymap as the default.
bindkey -e

# shift-tab backwards through menu
bindkey -M emacs '^[[Z' reverse-menu-complete
# completion menu highlighting
zstyle ':completion:*' menu select
# case-insensitive completion
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

brew_completion=$(brew --prefix 2>/dev/null)/share/zsh/site-functions
my_completions=$XDG_DATA_HOME/zsh/completion
if [ $? -eq 0 ] && [ -d "$brew_completion" ];then
  fpath=($brew_completion $my_completions $fpath)
fi

autoload -U compinit && compinit

# KEY BINDINGS
# better word navigation
autoload -U select-word-style
select-word-style bash

# bind [delete] for forward deletion
bindkey -M emacs "^[[3~" delete-char
bindkey -M emacs "^[3;5~" delete-char

autoload -U colors && colors

# HISTORY
HISTSIZE=50000
SAVEHIST=50000

HISTFILE="$XDG_STATE_HOME/zsh/.zsh_history"
mkdir -p "$(dirname "$HISTFILE")"

setopt HIST_FCNTL_LOCK
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt APPEND_HISTORY

# PROMPT
git_head() {
  git symbolic-ref --short HEAD 2> /dev/null || git rev-parse --short HEAD 2> /dev/null
}

setopt PROMPT_SUBST
export PROMPT='
%B%(?.%F{green}.%F{red})%~ %F{cyan}$(git_head)
%F{yellow}→ %f%b'

ZSH_TITLE=""
function xtitle () {
  if [[ $# > 0 ]]; then
    ZSH_TITLE=$@
  fi

  builtin print -n -- "\e]0;${ZSH_TITLE:-${(D)PWD}}\a"
}
xtitle

function precmd () { xtitle }

# Aliases
alias la='eza -a'
alias ll='eza -l'
alias lla='eza -la'
alias ls='eza'
alias lt='eza --tree'
alias vim='nvim'
alias jqi='f() { echo "" | fzf -q "." \
  --bind "shift-up:preview-half-page-up,shift-down:preview-half-page-down,load:unbind(enter)" \
  --preview-window "bottom:99%" \
  --print-query \
  --preview "cat $1 | jq ${@:2} {q} | bat --color=always --plain -l json" \
}; f'

[ -f $HOMEBREW_PREFIX/opt/asdf/libexec/asdf.sh ] && . $HOMEBREW_PREFIX/opt/asdf/libexec/asdf.sh

export EDITOR="nvim"
export HOMEBREW_BUNDLE_FILE="$HOME/dotfiles/exclude/Brewfile"
export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

export FZF_DEFAULT_OPTS='--color=16'
source <(fzf --zsh)
source ~/dotfiles/submodules/fzf-git.sh/fzf-git.sh

source <(zoxide init zsh)

# pnpm
export PNPM_HOME="/Users/sam/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
