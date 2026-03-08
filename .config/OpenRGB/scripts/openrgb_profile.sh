PROFILE="$HOME/.config/OpenRGB/themes/$1.orp"
CURRENT_PROFILE=$2
LOCKFILE=$3
if [ ! -f "$PROFILE" ]; then
    echo "Profile not found: $PROFILE"
    exit 1
fi

if [ "$CURRENT_PROFILE" = "$1" ]; then
    echo "Current profile already loaded"
    sed -i "s|^OpenRGB .*|OpenRGB True $2|" "$LOCKFILE"
    exit 0
fi

#write temp file with the profile to run on startup
echo "$1" > "$HOME/.config/OpenRGB/cache_profile"

# Start OpenRGB in background, capturing output
start_time=$(date +%s%N)
stdbuf -oL -eL /usr/bin/openrgb --profile "$PROFILE" 2>&1 | {
    while IFS= read -r line; do
        time=$(date +%s%N)
        elapsed=$(( ($time - $start_time) / 1000000 ))
        #debug
        echo "$line"

        if [[ "$line" == *"Profile loaded successfully"* ]]; then
            # Mark openrgb finish
            sed -i "s|^OpenRGB .*|OpenRGB True $1|" "$LOCKFILE"
            break
        fi

        if [ $elapsed -gt 5000 ]; then
            # Timeout
            sed -i "s|^OpenRGB .*|OpenRGB timeout when loading profile $1|" "$LOCKFILE"
            pkill openrgb
            break
        fi
    done
}

pkill openrgb
