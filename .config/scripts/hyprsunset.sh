#!/usr/bin/env bash
# Script to changes hyprsunset temperature inside limits

MIN_TEMP=1000
MAX_TEMP=6000
STEP=200

current=$(hyprctl hyprsunset temperature)

arg="$1"

if [[ "$arg" == "up" ]]; then
    new=$((current + STEP))
elif [[ "$arg" == "down" ]]; then
    new=$((current - STEP))
elif [[ "$arg" =~ ^[0-9]+$ ]]; then
    new=$arg
else
    new=$current
fi

# Clamp
if (( new < MIN_TEMP )); then 
    new=$MIN_TEMP; 
    hyprctl hyprsunset temperature "$new"
fi

if (( new > MAX_TEMP )); then 
    new=$MAX_TEMP; 
    hyprctl hyprsunset temperature "$new"
fi



# Print current temperature for slider update
echo "$new"