#!/bin/bash

STATE_FILE=$HOME/.config/hypr/float_state_temp

if [ ! -f "$STATE_FILE" ]; then
    echo "off" > "$STATE_FILE"
fi

STATE=$(cat "$STATE_FILE")

if [ "$STATE" = "off" ]; then
    echo "setting floating ON"
    hyprctl clients -j | jq -r '.[].address' | while read -r addr; do
        # Not sure if this need to be done in window_float.sh
        hyprctl dispatch setfloating address:$addr
        hyprctl dispatch resizeactive exact 720 720
    done

    # Make all new windows float
    hyprctl keyword windowrulev2 "float,class:.*"

    # save state
    echo "on" > "$STATE_FILE"

    # Notification
    notify-send "Floating on"
else
    echo "setting floating OFF"

    # Array of all active workspaces
    mapfile -t current_workspaces < <(hyprctl monitors -j | jq -r '.[] | .activeWorkspace.id')

    hyprctl clients -j | jq -r '.[] | "\(.address) \(.workspace.id)"' | while read -r addr ws; do
        # Not sure if this need to be done in window_float.sh
        hyprctl dispatch settiled address:$addr
        hyprctl dispatch movetoworkspacesilent $ws,address:$addr
    done

    # Remove global float rule
    hyprctl keyword windowrulev2 "tile,class:.*"

    # save state
    echo "off" > "$STATE_FILE"

    # need to reload to make normal float rules to work
    hyprctl reload

    # Notification
    notify-send "Floating off"
fi

