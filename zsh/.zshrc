# load modules
zmodload zsh/complist
autoload -U compinit && compinit # 
#autoload -U tetris # main attraction of zsh, obviously
autoload -Uz tetriscurses

bindkey -e # default bash bahaviour

# convenient directory navigation? 
setopt AUTO_PUSHD           # Push the current directory visited on the stack.
setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack.
setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd.
alias d='dirs -v'
for index ({1..9}) alias "$index"="cd +${index}"; unset index

# main opts
setopt append_history inc_append_history share_history # better history
# on exit, history appends rather than overwrites; history is appended as soon as cmds executed; history shared across sessions
setopt auto_menu menu_complete # autocmp first menu match
setopt autocd # type a dir to cd
setopt auto_param_slash # when a dir is completed, add a / instead of a trailing space
#setopt no_case_glob no_case_match # make cmp case insensitive
#setopt globdots # include dotfiles
#setopt extended_glob # match ~ # ^
unsetopt prompt_sp # don't autoclean blanklines

## set up prompt
autoload -U colors && colors
#PROMPT="%F{#70c6ff}%B${NEWLINE}${USER}@${$(hostname)}%b %F{#E5E9F0}❯ "
PROMPT="%F{#1dcc75}%B${NEWLINE}${USER}@${$(hostname)}%b %F{#E5E9F0}❯ "

## autosuggestions
## requires zsh-autosuggestions
# source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
#
## syntax highlighting
## requires zsh-syntax-highlighting package
#source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
#

# default programs
#export DISPLAY=:0 # useful for some scripts
export EDITOR="nvim"
alias vi=nvim
alias ls='ls -v --color="auto" --time-style=posix-long-iso --group-directories-first'

#eval "$(zoxide init bash)"
