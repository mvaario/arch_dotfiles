# Delete old fastch animations
rm ~/.config/fastfetch/frames/fastfetch_anim.lock

# Enable last OpenRGB profile 
# Edit lockfile
LOCKFILE="$HOME/.config/themes/theme_switch.lock"
sed -i "s|^OpenRGB .*|OpenRGB False|" "$LOCKFILE"

PROFILE=$(<"$HOME/.config/OpenRGB/cache_profile")
$HOME/.config/OpenRGB/scripts/openrgb_profile.sh "$PROFILE" "none" "$LOCKFILE" &

# Create wofi theme images
$HOME/.config/themes/scripts/resize_wallpaper.sh &

# Enable last cursor
cursor=$(grep '^Cursor ' "$LOCKFILE" | cut -d' ' -f2-)
size=$(grep '^Cursor_Size ' "$LOCKFILE" | cut -d' ' -f2-)

hyprctl setcursor "$cursor" "$size"
gsettings set org.gnome.desktop.interface cursor-theme "$cursor"
gsettings set org.gnome.desktop.interface cursor-size "$size"
