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
    new_temp=$(( temp + STEP ))
    if (( new_temp < MAX_TEMP )); then
        hyprctl hyprsunset temperature $new_temp
    elif (( temp < MAX_TEMP )); then
        hyprctl hyprsunset temperature $MAX_TEMP
    fi

elif [[ "$direction" == "down" ]]; then
    new_temp=$(( temp - STEP ))
    if (( new_temp > MIN_TEMP )); then
        hyprctl hyprsunset temperature $new_temp
    elif (( temp < MIN_TEMP )); then
        hyprctl hyprsunset temperature $MIN_TEMP
    fi
fi
