#!/bin/bash

# Close wofi if it's already running
if pgrep -x wofi > /dev/null 2>&1; then
    killall wofi
    exit 0
fi

#Remove cache so orders works
rm ~/.cache/wofi-dmenu

WALL_DIR="$HOME/.config/themes/wallpapers"
COLOR_DIR="$HOME/.config/themes/colors"
APPLY_SCRIPT="$HOME/.config/scripts/apply_theme.sh"

list=""
# Build list of theme entries
for theme in "$COLOR_DIR"/*.sh; do
    filename=$(basename "$theme")
    name="${filename%.sh}"

    wall=$(find "$WALL_DIR" -type f \( -iname "$name.jpg" -o -iname "$name.png" \) | head -n 1)
    [ ! -f "$wall" ] && continue

    list+=$'img:'"$wall"$'\n'
done

# Wofi select list
#selected=$(echo -e "$list" | wofi --dmenu --conf="$HOME/.config/wofi/theme_config")

# run wofi and wirete temp file
~/.config/scripts/wofi.sh theme_selection "$list"

# read them file
selected=$(<~/.config/wofi/temp.txt)
rm ~/.config/wofi/temp.txt

if [[ -n "$selected" ]]; then
    # get the name
    theme_file=$(basename "$selected" | sed 's/\.[^.]*$//')

    # Run apply script with filename
    [ -n "$theme_file" ] && exec "$APPLY_SCRIPT" "$theme_file.sh"
    
fi





