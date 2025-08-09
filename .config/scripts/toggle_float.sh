#!/bin/bash

STATE_FILE=$HOME/.config/hypr/float_state_temp

if [ ! -f "$STATE_FILE" ]; then
    echo "off" > "$STATE_FILE"
fi

STATE=$(cat "$STATE_FILE")

if [ "$STATE" = "off" ]; then
    echo "setting floating ON"
    hyprctl clients -j | jq -r '.[].address' | while read -r addr; do
        hyprctl dispatch setfloating address:$addr
    done

    # Make all new windows float
    hyprctl keyword windowrulev2 "float,class:.*"

    # save state
    echo "on" > "$STATE_FILE"
else
    echo "setting floating OFF"

    hyprctl clients -j | jq -r '.[].address' | while read -r addr; do
        hyprctl dispatch settiled address:$addr
    done

    # Remove global float rule
    hyprctl keyword windowrulev2 "tile,class:.*"

    # save state
    echo "off" > "$STATE_FILE"
fi

