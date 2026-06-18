#!/bin/bash
# Script for switching workspaces on 2 monitors

echo "$1"
# with keyboard shortcuts
if [ -n "$1" ]; then
    target_workspace="$1"
else
    exit;
fi

# switch workspaces
second_monitor="$(($target_workspace + 4))"
hyprctl dispatch workspace $second_monitor
hyprctl dispatch workspace $target_workspace