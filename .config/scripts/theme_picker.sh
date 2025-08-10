#!/bin/bash
#script run by swaync so close to window
# make sure script is not running on the background
LOCKFILE="$HOME/.config/scripts/theme_switch.lock"
WAIT_TIME=1

while [ -f "$LOCKFILE" ]; do
  echo "Other instance running"
  echo "Waiting..."
  sleep 1
  WAIT_TIME=$((WAIT_TIME - 1))
  if [ "$WAIT_TIME" -le 0 ]; then
    echo "Timeout reached, exiting."
    exit 1
  fi
done

# Create the lock file (optionally store PID)
echo $$ > "$LOCKFILE"

# Ensure lock file is deleted on script exit or interruption
#trap 'rm -f "$LOCKFILE"; exit' INT TERM EXIT

#-------------------------------------------------
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

# run wofi and write temp file
~/.config/scripts/wofi.sh theme_selection "$list"

# read them file
selected=$(<~/.config/wofi/temp.txt)

if [[ -n "$selected" ]]; then
    rm ~/.config/wofi/temp.txt

    # get the name
    theme_file=$(basename "$selected" | sed 's/\.[^.]*$//')

    # Run run apply script with selected theme file
    if [ -n "$theme_file" ]; then
        nohup bash "$APPLY_SCRIPT" "$theme_file.sh" >/dev/null 2>&1 &
    fi
fi

# Remove lock file
#rm -f "$LOCKFILE"
#trap - INT TERM EXIT
