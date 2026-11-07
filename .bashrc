[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

export PATH="$HOME/.local/bin:$PATH"

export HISTCONTROL=ignoreboth:erasedups
shopt -s histappend
shopt -s cmdhist

PS1='[\u@\h] [\D{%H:%M:%S}] [\w]\n\$ '
