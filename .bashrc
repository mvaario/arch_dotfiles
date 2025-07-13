#
# ~/.bashrc
#

if [[ $- == *i* ]]; then
    ~/.config/scripts/frame_animation.sh
    eval "$(starship init bash)"
fi

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
