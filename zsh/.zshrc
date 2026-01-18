zmodload zsh/complist

autoload -Uz compinit; compinit

zstyle ':completion:*' completer _expand _complete _correct _approximate    
zstyle ':completion:*' group-name ''    
zstyle ':completion:*' menu select=2    
eval "$(dircolors -b)"    
#zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'    
zstyle ':completion:*' menu select=long    
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s    
zstyle ':completion:*' use-compctl false    
zstyle ':completion:*' verbose true    
    
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'    
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'    

# better mv
autoload -Uz zmv;

# better cd
eval "$(zoxide init zsh)"; alias cd=z

autoload -Uz tetriscurses # tetris
bindkey -e # default bash (emacs) bahaviour

# main opts
# better history
setopt append_history inc_append_history histignorealldups sharehistory
HISTSIZE=10000    
SAVEHIST=10000   
HISTFILE=~/.zsh_history    

setopt menu_complete # autocmp first menu match
setopt autocd # type a dir to cd
#setopt auto_param_slash # when a dir is completed, add a / instead of a trailing space

# zsh globing
# ls ^(*.o) # to negate results
# ls *.o~file.txt # to exclude file
# ls ^(*.o)~file.txt # to exclude file

#setopt no_case_glob no_case_match # make cmp case insensitive

setopt extended_glob # match ~ # ^
#unsetopt prompt_sp # don't autoclean blanklines

## set up prompt
autoload -Uz colors && colors
PROMPT="%F{#1dcc75}%B${NEWLINE}${USER}@${$(hostname)}%b %f%k%b❯ " 
#PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\] $ '

# requires zsh-autosuggestions
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# requires zsh-syntax-highlighting package # i think this is a bit too much
#source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

#export DISPLAY=:0 # useful for some scripts
export EDITOR="nvim"
alias vi=nvim
alias ls='ls -v --color="auto" --time-style=posix-long-iso --group-directories-first'
#alias ls='ls --color="auto"'

PATH=/home/patryk/builds/rust/build/host/stage0/bin:$PATH
