#!/bin/bash
# Add symbolic waybar icons to .icons
# script will recolor these icons and copy to DST folder
# NOTE: most applications do not use these so kind of pointless...

# recolor waybar tray icons to theme color
COLOR=#$1
CURRENT_COLOR=$2
LOCKFILE=$3

SRC="$HOME/.icons/Icons"
DST="$HOME/.icons/Papirus-Dark/16x16/apps"

if [ "$CURRENT_COLOR" = "$COLOR" ]; then
    echo "Current colors already loaded"
    sed -i "s|^Recolor .*|Recolor True $COLOR|" "$LOCKFILE"
else
    for icon in "$SRC"/*.svg; do
      sed -E \
        -e "s/fill:currentColor/fill:$COLOR/g" \
        -e "s/stroke:currentColor/stroke:$COLOR/g" \
        "$icon" > "$DST/$(basename "$icon")"
    done
    #Check errors
    if [ $? -eq 0 ]; then
        # Mark Recoloring finish
        echo "Recoloring done"
        sed -i "s|^Recolor .*|Recolor True $COLOR|" "$LOCKFILE"
    else
        echo "Error while recoloring"
    fi
fi
