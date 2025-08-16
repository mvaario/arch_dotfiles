# Delete old fastch animations
rm ~/.config/fastfetch/frames/fastfetch_anim.lock


# Enable last OpenRGB profile 
# Edit lockfile
LOCKFILE="$HOME/.config/scripts/theme_switch.lock"
sed -i "s|^OpenRGB .*|OpenRGB False|" "$LOCKFILE"

PROFILE=$(<"$HOME/.config/OpenRGB/cache_profile")
$HOME/.config/scripts/openrgb_profile.sh "$PROFILE" "$LOCKFILE"

