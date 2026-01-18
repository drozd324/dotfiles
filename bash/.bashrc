HISTCONTROL=ignoreboth

shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s checkwinsize

shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

PS1="\[\033[01;32m\]\u@\h\[\033[00m\] $ "

# enable color support of ls and also add handy aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'

export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

PATH="$HOME/.local/bin:$PATH"

. "$HOME/.cargo/env"
PATH=$PATH:/opt/rocm-7.0.1/bin

#PATH=$PATH:/home/patryk/builds/lua-language-server/bin
LLVM_ROOT=/home/patryk/builds/llvm-project
PATH=$PATH:/usr/local/
PATH=/usr/lib/llvm-21/bin:$PATH


#Perforce Service name [master]: testp4service
#Service testp4service not found. Creating...
#Perforce Server root (P4ROOT) [/opt/perforce/servers/testp4service]:
#Create directory? (y/n) [y]: y
#Perforce Server unicode-mode (y/n) [n]:
#Perforce Server case-sensitive (y/n) [y]:
#Perforce Server address (P4PORT) [ssl:1666]:
#Perforce super-user login [super]:
#Perforce super-user password:
export P4PORT=ssl:1666
export P4USER=super
export P4EDITOR=nvim
export P4DIFF="nvim -d"



# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

case ":$PATH:" in
    *:/home/patryk/.juliaup/bin:*)
        ;;

    *)
        export PATH=/home/patryk/.juliaup/bin${PATH:+:${PATH}}
        ;;
esac

# <<< juliaup initialize <<<

export GEMINI_API_KEY=AIzaSyAi4QYzTQAkauIBlDE7ZXM7oPL7GMgYsT4

export TAVILY_API_KEY=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
#export GOOGLE_SEARCH_API_KEY=AIzaSyDhR0DsBK0dVBz8FmsI0LH5uACSfNwc2FM 
#export GOOGLE_SEARCH_ENGINE_KEY=11c036f50f4cc4c34 

#<script async src="https://cse.google.com/cse.js?cx=11c036f50f4cc4c34">
#</script>
#<div class="gcse-search"></div>

PATH=/home/patryk/builds/neovim/build/bin/:$PATH

# vamp-sdk
export PKG_CONFIG_PATH=/tmp/vamp-plugin-sdk/build/:$PKG_CONFIG_PATH

eval "$(zoxide init bash)"
EDITOR=nvim
