HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

setopt extendedglob
setopt noautomenu
setopt nomenucomplete

bindkey -e

zstyle :compinstall filename '/home/patryk/.zshrc'
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

autoload -Uz compinit
compinit

PS1="%F{cyan}%B%n@%m%f%b "

export EDITOR="nvim"
alias vi=nvim
alias ls='ls -v --color="auto" --time-style=posix-long-iso --group-directories-first'
alias open=xdg-open

export PATH="$HOME/.local/bin:$PATH"

export PATH="$HOME/apps/zen:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
