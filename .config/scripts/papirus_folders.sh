icons=$1
LOCKFILE=$2

/usr/bin/papirus-folders -C "$icons" --theme Papirus-Dark

# Mark Papirus finish
sed -i "s|^Papirus .*|Papirus True|" "$HOME/.config/scripts/theme_switch.lock"

