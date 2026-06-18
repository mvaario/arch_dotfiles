#!/bin/bash
mainMod=$1

# Temporary file to track keylock state
STATE_FILE="$HOME/.config/waybar/hypr_keylock_state"

# Check if we're already in 'clean' mode
if [ -f "$STATE_FILE" ]; then
    # Currently locked – reset
    hyprctl dispatch submap reset
    rm -f "$STATE_FILE"

    # nice hyprland update bindm does not work anymore had to manually
    hyprctl keyword bindm "$mainMod, mouse:272, movewindow"
    hyprctl keyword bindm "$mainMod, mouse:273, resizewindow"


    # Notification
    notify-send "Keylock off"
else
    # Currently unlocked – lock
    hyprctl dispatch submap clean
    touch "$STATE_FILE"

    # nice hyprland update bindm does not work anymore had to manually
    hyprctl keyword unbind "$mainMod, mouse:272"
    hyprctl keyword unbind "$mainMod, mouse:273"

    # Notification
    notify-send "Keylock on"
fi