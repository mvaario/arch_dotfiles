#!/bin/bash
# Add symbolic waybar icons to .icons
# script will recolor these icons and copy to DST folder
# NOTE: most applications do not use these so kind of pointless...

# recolor waybar tray icons to theme color
COLOR=#$1
LOCKFILE=$2

SRC="$HOME/.icons/Icons"
DST="$HOME/.icons/Papirus-Dark/16x16/apps"

for icon in "$SRC"/*.svg; do
  sed -E \
    -e "s/fill:currentColor/fill:$COLOR/g" \
    -e "s/stroke:currentColor/stroke:$COLOR/g" \
    "$icon" > "$DST/$(basename "$icon")"
done

# Mark recolor finish
sed -i "s|^recolor .*|recolor True|" "$LOCKFILE"


