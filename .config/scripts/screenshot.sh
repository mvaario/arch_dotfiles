#!/bin/bash
mkdir -p ~/Pictures

FILE=~/Pictures/screenshot-$(date +'%Y-%m-%d_%H-%M-%S').png


grim -g "$(slurp)" "$FILE"


notify-send "Screenshot saved" "$FILE"
ristretto "$FILE" &