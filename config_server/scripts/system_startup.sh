# Delete old fastch animations
rm ~/.config/fastfetch/frames/fastfetch_anim.lock

# Enable last cursor
cursor=$(grep '^Cursor ' "$LOCKFILE" | cut -d' ' -f2-)
size=$(grep '^Cursor_Size ' "$LOCKFILE" | cut -d' ' -f2-)

hyprctl setcursor "$cursor" "$size"
gsettings set org.gnome.desktop.interface cursor-theme "$cursor"
gsettings set org.gnome.desktop.interface cursor-size "$size"