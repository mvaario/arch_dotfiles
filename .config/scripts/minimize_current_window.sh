#!/bin/bash
# jq needs to be installed

# Get the current active workspace
CURRENT_WS=$(hyprctl activeworkspace -j | jq -r '.name')

# Get all minimized windows (on special:desktop)
MINIMIZED_WINDOWS=$(hyprctl clients -j | jq -r '.[] | select(.workspace.name=="special:desktop") | .address')


if [[ -n "$MINIMIZED_WINDOWS" ]]; then
  # Restore all minimized windows to current workspace
  for addr in $MINIMIZED_WINDOWS; do
    hyprctl dispatch movetoworkspacesilent name:$CURRENT_WS,address:$addr
  done
  echo "Restored minimized windows to workspace $CURRENT_WS"
  exit 0
fi

# No minimized windows found, minimize the currently focused window
FOCUSED_JSON=$(hyprctl activewindow -j)
FOCUSED_ADDR=$(echo "$FOCUSED_JSON" | jq -r '.address')
FOCUSED_WS=$(echo "$FOCUSED_JSON" | jq -r '.workspace.name')

if [[ -n "$FOCUSED_ADDR" && "$FOCUSED_WS" != "special:desktop" ]]; then
  hyprctl dispatch movetoworkspacesilent special:desktop,address:$FOCUSED_ADDR
  echo "Minimized window $FOCUSED_ADDR from workspace $FOCUSED_WS"
else
  echo "No window to minimize or window already minimized."
fi
