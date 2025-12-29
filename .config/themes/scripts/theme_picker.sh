#!/bin/bash
# Close wofi if it's already running
if pgrep -x wofi > /dev/null 2>&1; then
    killall wofi
    exit 0
fi

#Remove cache so orders works
rm ~/.cache/wofi-dmenu

WALL_DIR="$HOME/.config/themes/images"
COLOR_DIR="$HOME/.config/themes/colors"

list=""
# Build list of theme entries
for theme in "$COLOR_DIR"/*.sh; do
    filename=$(basename "$theme")
    name="${filename%.sh}"

    wall=$(find "$WALL_DIR" -type f \( -iname "$name.jpg" -o -iname "$name.png" -o -iname "$name.jpeg" \) | head -n 1)
    [ ! -f "$wall" ] && continue

    list+=$'img:'"$wall"$'\n'
done

# run wofi and write temp file
~/.config/wofi/scripts/wofi.sh theme_selection "$list"

# read them file
selected=$(<~/.config/wofi/temp)
rm ~/.config/wofi/temp

echo $selected

if [[ -n "$selected" ]]; then
    # get the name
    theme_file=$(basename "$selected" | sed 's/\.[^.]*$//')

    # Run run apply script with selected theme file
    if [ -n "$theme_file" ]; then
        nohup "$HOME/.config/themes/scripts/apply_theme.sh" "$theme_file.sh" >/dev/null 2>&1 &
    fi
fi

