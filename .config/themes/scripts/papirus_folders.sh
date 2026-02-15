ICONS=$1
CURRENT_PROFIEL=$2
LOCKFILE=$3

if [ "$CURRENT_PROFILE" = "$ICONS" ]; then
    echo "Current papirus folders already loaded"
    sed -i "s|^Papirus .*|Papirus True $ICONS|" "$LOCKFILE"
else
    /usr/bin/papirus-folders -C "$ICONS" --theme Papirus-Dark
    #Check errors
    if [ $? -eq 0 ]; then
        # Mark Papirus finish
        sed -i "s|^Papirus .*|Papirus True $ICONS|" "$LOCKFILE"
    else
        echo "Papirus folder command failed"
    fi
fi





