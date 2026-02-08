#!/usr/bin/env bash

# Your main keyboard device
DEVICE="rdmctmzt-evo80-2.4g"

# If called with "switch", cycle layout
if [ "$1" = "switch" ]; then
    hyprctl switchxkblayout "$DEVICE" next
fi

# Get current layout
CURRENT=$(hyprctl devices -j | jq -r '.[] | .[] | select(.name=="rdmctmzt-evo80-2.4g") | .active_keymap')

#echo $CURRENT

# Map to short code (US/FI)
case "$CURRENT" in
    US|'English (US)')
        #echo "US"
        echo True
        ;;
    FI|'Finnish')
        #echo "FI"
        echo False
        ;;
    *)
        #echo "$CURRENT"
        ;;
esac