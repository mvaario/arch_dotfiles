#!/bin/bash

# current state
STATE_FILE=$HOME/.config/hypr/float_state_temp

if [ ! -f "$STATE_FILE" ]; then
    echo "off" > "$STATE_FILE"
fi

CURRENT_STATE=$(cat "$STATE_FILE")
SWITCH_STATE=$1

if [ -z "$SWITCH_STATE" ]; then
    echo "Switching state variable missing"
    notify-send "Toggleing float error"
    exit 1
fi

# Check state and passes variable to changes
# Used in swaync and apply theme
MAX_W=1200
MAX_H=700
if [[ "$CURRENT_STATE" = "off" && "$SWITCH_STATE" = "true" ]]; then
    echo "setting floating ON"
    hyprctl clients -j | jq -c '.[] | {addr: .address, w: .size[0], h: .size[1], x: .at[0], y: .at[1]}' |
    while read -r win; do
        addr=$(jq -r '.addr' <<< "$win")
        width=$(jq -r '.w' <<< "$win")
        height=$(jq -r '.h' <<< "$win")
        x=$(jq -r '.x' <<< "$win")
        y=$(jq -r '.y' <<< "$win")

        hyprctl dispatch setfloating address:$addr
        if (( width > MAX_W || height > MAX_H )); then
            width=$MAX_W
            height=$MAX_H
        fi
        hyprctl dispatch resizewindowpixel exact "$width" "$height",address:$addr
        hyprctl dispatch movewindowpixel exact "$x" "$y",address:$addr
    done

    # Make glabal float rule
    hyprctl keyword windowrule match:class .*, float 1

    # save state
    echo "on" > "$STATE_FILE"

    # Notification
    notify-send "Floating on"
elif [[ "$CURRENT_STATE" = "on" && "$SWITCH_STATE" = "true" ]]; then
    echo "setting floating OFF"

    # Array of all active workspaces
    mapfile -t current_workspaces < <(hyprctl monitors -j | jq -r '.[] | .activeWorkspace.id')

    hyprctl clients -j | jq -r '.[] | "\(.address) \(.workspace.id)"' | while read -r addr ws; do
        # Not sure if this need to be done in window_float.sh
        hyprctl dispatch settiled address:$addr
        hyprctl dispatch movetoworkspacesilent $ws,address:$addr
    done

    # Remove global float rule
    hyprctl keyword windowrule match:class .*, float 0

    # save state
    echo "off" > "$STATE_FILE"

    # need to reload to make normal float rules to work
    hyprctl reload

    # Notification
    notify-send "Floating off"
else
    if [ "$CURRENT_STATE" = "off" ]; then
        echo "keeping floating OFF"

        # Make global float rule
        hyprctl keyword windowrule match:class .*, float 0
        echo "off" > "$STATE_FILE"

    else
        echo "keeping floating ON"
        
        # Make global float rule
        hyprctl keyword windowrule match:class .*, float 1
        echo "on" > "$STATE_FILE"
    fi
fi

