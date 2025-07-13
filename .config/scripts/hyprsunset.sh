#!/bin/bash

# Get current temperature from hyprctl
temp=$(hyprctl hyprsunset temperature)

# Default clamp values (you can adjust)
MIN_TEMP=1000
MAX_TEMP=6000
STEP=200

# Direction: up/down
direction=$1


if [[ "$direction" == "up" ]]; then
    if (( temp >= MAX_TEMP )); then
        hyprctl hyprsunset temperature $MAX_TEMP
    else
        new_temp=$(( temp + STEP ))
        hyprctl hyprsunset temperature $new_temp
    fi
elif [[ "$direction" == "down" ]]; then
    new_temp=$(( temp - STEP ))
    if (( new_temp < MIN_TEMP )); then
        new_temp=$MIN_TEMP
    fi
    hyprctl hyprsunset temperature $new_temp
fi