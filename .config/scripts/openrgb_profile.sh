PROFILE="$HOME/.config/OpenRGB/themes/$1.orp"
LOCKFILE=$2
if [ ! -f "$PROFILE" ]; then
    echo "Profile not found: $PROFILE"
    exit 1
fi

#write temp file with the profile to run on startup
echo "$1" > "$HOME/.config/OpenRGB/cache_profile"

# Start OpenRGB in background, capturing output
openrgb --profile "$PROFILE" --startminimized 2>&1 | {
    SECONDS=0
    while IFS= read -r line; do
        #debug:
        #echo "$line"

        if [[ "$line" == *"Profile loaded successfully"* ]]; then
            echo "$line"
            # Mark openrgb finish
            sed -i "s|^OpenRGB .*|OpenRGB True|" "$LOCKFILE"
            pkill openrgb
            break
        fi

        if (( SECONDS >= 8 )); then
            echo "Timeout on openrgb profile loading"
            pkill openrgb
            break
        fi
    done
}