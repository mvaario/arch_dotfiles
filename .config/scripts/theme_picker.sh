#!/bin/bash

# Close wofi if it's already running
if pgrep -x wofi > /dev/null 2>&1; then
    killall wofi
    exit 0
fi

WALL_DIR="$HOME/.config/themes/wallpapers"
COLOR_DIR="$HOME/.config/themes/colors"
APPLY_SCRIPT="$HOME/.config/scripts/apply_theme.sh"

list=""

# Build list of theme entries
for theme in "$COLOR_DIR"/*.sh; do
    filename=$(basename "$theme")
    name="${filename%.sh}"
    wall="$WALL_DIR/$name.jpg"
    [ ! -f "$wall" ] && wall="$WALL_DIR/$name.png"
    [ ! -f "$wall" ] && continue

    list+=$'img:'"$wall"$':text:'"$filename"$'\n'
done

# Show list with wofi
selected=$(echo -e "$list" | wofi --dmenu --conf="$HOME/.config/wofi/theme_config")

# Extract script filename (after :text:)
theme_file=$(echo "$selected" | sed 's|.*:text:||')

# Run apply script with filename (e.g., earthsong.sh)
[ -n "$theme_file" ] && exec "$APPLY_SCRIPT" "$theme_file"
