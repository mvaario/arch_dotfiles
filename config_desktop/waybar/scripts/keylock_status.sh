STATE_FILE="$HOME/.config/waybar/hypr_keylock_state"

if [ -f "$STATE_FILE" ]; then
  # Locked: red color
  echo '{"text":"⌨","class":"locked"}'
else
  # Unlocked: blue color
  echo '{"text":"⌨","class":"unlocked"}'
fi