#!/bin/bash
MAIN_PROFILE="Default (release)"
MAIN=$(grep -A5 "Name=$MAIN_PROFILE" ~/.zen/profiles.ini | \
grep "^Path=" | head -n1 | sed 's/Path=//')

EMPTY_PROFILE="Empty_Profile"
EMPTY=$(grep -A5 "Name=$EMPTY_PROFILE" ~/.zen/profiles.ini | \
grep "^Path=" | head -n1 | sed 's/Path=//')

# Copy theme file to second profile
cp "$HOME/.zen/$MAIN/user.js" "$HOME/.zen/$EMPTY/user.js"

zen_browser="$HOME/.local/opt/zen/zen"
if pgrep -x "zen" >/dev/null; then
    $zen_browser -P "$EMPTY_PROFILE" &
    echo "Starting zen $EMPTY_PROFILE"
else
    $zen_browser -P "$MAIN_PROFILE" &
    echo "Starting zen normal profile"
fi