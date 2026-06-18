#
# ~/.bashrc
#
if [[ -n "$RUN_ANIMATION" ]]; then
    ~/.config/fastfetch/scripts/frame_animation.sh
    export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
    eval "$(starship init bash)"
fi

[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
HISTCONTROL=ignoredups:erasedups
