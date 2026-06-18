#!/bin/bash
# script to start zen browser, if second or more zen windows are opened it's always empty
MAIN_PROFILE=$(whoami)
EMPTY_PROFILE="Empty_Profile"

MAIN=$(grep -A5 "Name=$MAIN_PROFILE" ~/.config/zen/profiles.ini | \
grep "^Path=" | head -n1 | sed 's/Path=//')

EMPTY=$(grep -A5 "Name=$EMPTY_PROFILE" ~/.config/zen/profiles.ini | \
grep "^Path=" | head -n1 | sed 's/Path=//')

ZEN_BROWESR="$HOME/.local/opt/zen/zen"
if [[ -z "$MAIN" || -z "$EMPTY" ]]; then
    echo "Create 2 Zen profiles named: $MAIN_PROFILE and $EMPTY_PROFILE"
    echo "Also recommend to install Transparent Zen, Better Unloaded Tabs and Better Find Bar from Zen mods"
    notify-send "Create 2 Zen profiles named: $MAIN_PROFILE and $EMPTY_PROFILE"
    $ZEN_BROWESR -P
    exit 1
fi

# Copy theme file to second profile
cp "$HOME/.config/zen/$MAIN/user.js" "$HOME/.config/zen/$EMPTY/user.js"

if pgrep -x "zen" >/dev/null; then
    $ZEN_BROWESR -P "$EMPTY_PROFILE" &
    echo "Starting zen $EMPTY_PROFILE profile"
else
    $ZEN_BROWESR -P "$MAIN_PROFILE" &
    echo "Starting zen $MAIN_PROFILE profile"
fi