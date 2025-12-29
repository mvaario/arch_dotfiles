#!/bin/bash
# Script for switching workspaces, but keeping mouse position to same

echo "$1"
# with keyboard shortcuts
if [ -n "$1" ]; then
    target_workspace="$1"
else
    exit;
fi

# get cursor position
read cx cy < <(hyprctl cursorpos | tr -d ',')
# read current_workspace < <(hyprctl -j activeworkspace | jq -r '.id')

# switch workspaces
second_monitor="$(($target_workspace + 4))"
hyprctl dispatch workspace $second_monitor
hyprctl dispatch workspace $target_workspace

# move cursor
hyprctl dispatch movecursor $cx $cy


# echo $cx $cy
# echo $current_workspace
# echo $target_workspace $second_monitor






