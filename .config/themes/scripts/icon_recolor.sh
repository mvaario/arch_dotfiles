#!/bin/bash
# Add symbolic waybar icons to .icons
# script will recolor these icons and copy to DST folder

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
        filename=$(basename "$icon")
        if [[ ! -f "$DST/$filename" ]]; then
            cp -an "$icon" "$DST"
            echo "Copied missing file to DST: $filename"
        fi
        sed -E \
            -e "s/fill:currentColor/fill:$COLOR/g" \
            -e "s/fill:#000000/fill:$COLOR/g" \
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

