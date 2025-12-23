#!/bin/bash

# Temporary file to track keylock state
STATE_FILE="$HOME/.config/waybar/hypr_keylock_state"

# Check if we're already in 'clean' mode
if [ -f "$STATE_FILE" ]; then
    # Currently locked – reset
    hyprctl dispatch submap reset
    rm -f "$STATE_FILE"

    # Notification
    notify-send "Keylock off"
else
    # Currently unlocked – lock
    hyprctl dispatch submap clean
    touch "$STATE_FILE"

    # Notification
    notify-send "Keylock on"
fi