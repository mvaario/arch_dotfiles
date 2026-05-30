FOLDERS=$1
CURRENT_PROFIEL=$2
LOCKFILE=$3

if [ "$CURRENT_PROFILE" = "$FOLDERS" ]; then
    echo "Current papirus folders already loaded"
    sed -i "s|^Papirus .*|Papirus True $FOLDERS|" "$LOCKFILE"
else
    /usr/bin/papirus-folders -C "$FOLDERS" --theme Papirus-Dark
    #Check errors
    if [ $? -eq 0 ]; then
        # Mark Papirus finish
        sed -i "s|^Papirus .*|Papirus True $FOLDERS|" "$LOCKFILE"
    else
        echo "Papirus folder command failed"
    fi
fi