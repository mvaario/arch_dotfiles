#!/bin/bash
addr=$(hyprctl activewindow -j | jq -r '.address')
is_floating=$(hyprctl activewindow -j | jq -r '.floating')

if [[ "$is_floating" == "true" ]]; then
    hyprctl dispatch togglefloating address:$addr
else
    hyprctl dispatch togglefloating address:$addr
    

    win_info=$(hyprctl activewindow -j)
    width=$(echo "$win_info" | jq -r '.size[0]')
    height=$(echo "$win_info" | jq -r '.size[1]')


    max_width=1280
    max_height=720

    if (( width > max_width )); then
        width=$max_width
    fi

    if (( height > max_height )); then
        height=$max_height
    fi

    hyprctl dispatch resizeactive exact $width $height

fi


