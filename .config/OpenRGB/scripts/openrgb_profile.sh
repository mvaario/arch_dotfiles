PROFILE="$HOME/.config/OpenRGB/themes/$1.orp"
LOCKFILE=$2
if [ ! -f "$PROFILE" ]; then
    echo "Profile not found: $PROFILE"
    exit 1
fi

#write temp file with the profile to run on startup
echo "$1" > "$HOME/.config/OpenRGB/cache_profile"

# Start OpenRGB in background, capturing output
stdbuf -oL -eL /usr/bin/openrgb --profile "$PROFILE" 2>&1 | {
    SECONDS=0
    while IFS= read -r line; do
        #debug:
        echo "$line"

        if [[ "$line" == *"Profile loaded successfully"* ]]; then
            # Mark openrgb finish
            sed -i "s|^OpenRGB .*|OpenRGB True|" "$LOCKFILE"
            break
        fi

        if (( SECONDS >= 8 )); then
            echo "Timeout on OpenRGB profile loading" >> "$LOCKFILE"
            break
        fi
    done
}

pkill openrgb