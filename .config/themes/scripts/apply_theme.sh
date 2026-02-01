#!/bin/bash
# Apply selected theme to different moduls
# Script called by theme_picker.sh
THEME_FILE="$HOME/.config/themes/colors/$1"
LOCKFILE="$HOME/.config/themes/scripts/theme_switch.lock"
echo "apply theme" $THEME_FILE

if [ ! -f "$THEME_FILE" ]; then
    echo "Theme not found: $1"
    # Release the lockfile
    echo "Hyprland True" > "$LOCKFILE"
    exit 1
fi

# Load common colors
COMMON_FILE="$HOME/.config/themes/common.sh"

#-------------------------------------------------
# No idea why this broke now...
# source ~/.profile
# source ~/.bashrc
# export HYPRLAND_INSTANCE_SIGNATURE="${HYPRLAND_INSTANCE_SIGNATURE:-$(cat ~/.hyprland_signature 2>/dev/null)}"
# echo "HYPRLAND_INSTANCE_SIGNATURE is: $HYPRLAND_INSTANCE_SIGNATURE"

# Source the theme file to load the color variables
source "$COMMON_FILE"
source "$THEME_FILE"

#create hex background with opacity
hexopacity="$HOME/.config/scripts/hex_opacity.sh"
alpha_hex=$("$hexopacity" "$opacity")

# changes color to rgb
background_rgb_str=$($HOME/.config/scripts/hex_to_rgb.sh "$background")
rgb_bwhite=$($HOME/.config/scripts/hex_to_rgb.sh "$bwhite")
rgb_main=$($HOME/.config/scripts/hex_to_rgb.sh "$main")

# List of template files and their destination
declare -A files=(
    ["$HOME/.config/themes/templates/hyprland.template.conf"]="$HOME/.config/hypr/colors_temp.conf"
    ["$HOME/.config/themes/templates/hyprpaper.template.conf"]="$HOME/.config/hypr/hyprpaper.conf"
    ["$HOME/.config/themes/templates/hyprlock.template.conf"]="$HOME/.config/hypr/hyprlock.conf"
    ["$HOME/.config/themes/templates/waybar.template.css"]="$HOME/.config/waybar/style.css"
    ["$HOME/.config/themes/templates/kitty.template.conf"]="$HOME/.config/kitty/colors.conf"
    ["$HOME/.config/themes/templates/wofi.template.conf"]="$HOME/.config/wofi/style.css"
    ["$HOME/.config/themes/templates/swaync_style.template.css"]="$HOME/.config/swaync/style.css"
    ["$HOME/.config/themes/templates/fastfetch.template.conf"]="$HOME/.config/fastfetch/colors.conf"
    ["$HOME/.config/themes/templates/fastfetch_config.template.jsonc"]="$HOME/.config/fastfetch/config.jsonc"
    ["$HOME/.config/themes/templates/btop_style.template.theme"]="$HOME/.config/btop/themes/btop_style.theme"
    ["$HOME/.config/themes/templates/windows.template.conf"]="$HOME/.config/hypr/conf/window_theme.conf"
    ["$HOME/.config/themes/templates/gtk-4.template.css"]="$HOME/.config/gtk-4.0/gtk.css"
    ["$HOME/.config/themes/templates/zen_browser.template.js"]="$HOME/.zen/qcjojoq2.Default (release)/user.js"
)

# Loop through the files and apply the theme
for template in "${!files[@]}"; do
    dest="${files[$template]}"
    # Use sed to find and replace placeholders
    sed -e "s|%background_rgb_str%|$background_rgb_str|g" \
        -e "s|%rgb_main%|$rgb_main|g" \
        -e "s|%rgb_bwhite%|$rgb_bwhite|g" \
        -e "s,%opacity%,$opacity,g" \
        -e "s,%background%,$background,g" \
        -e "s,%backerground%,$backerground,g" \
        -e "s,%foreground%,$foreground,g" \
        -e "s,%main%,$main,g" \
        -e "s,%highlight%,$highlight,g" \
        -e "s,%black%,$black,g" \
        -e "s,%red%,$red,g" \
        -e "s,%green%,$green,g" \
        -e "s,%yellow%,$yellow,g" \
        -e "s,%blue%,$blue,g" \
        -e "s,%magenta%,$magenta,g" \
        -e "s,%cyan%,$cyan,g" \
        -e "s,%white%,$white,g" \
        -e "s,%bblack%,$bblack,g" \
        -e "s,%bred%,$bred,g" \
        -e "s,%bgreen%,$bgreen,g" \
        -e "s,%byellow%,$byellow,g" \
        -e "s,%bblue%,$bblue,g" \
        -e "s,%bmagenta%,$bmagenta,g" \
        -e "s,%bcyan%,$bcyan,g" \
        -e "s,%bwhite%,$bwhite,g" \
        -e "s,%wallpaper%,$wallpaper,g" \
        -e "s,%cursor%,$cursor,g" \
        -e "s,%size%,$size,g" \
        -e "s,%nautilus%,$nautilus,g" \
        -e "s,%icons%,$icons,g" \
        -e "s,%name%,$name,g" \
        -e "s,%alpha_hex%,$alpha_hex,g" \
        "$template" > "$dest"
done


#-------------------------------------------------
# Load openRGB profile (takes a while....)
echo "☑️ Changing OpenRGB profile"
echo "OpenRGB False" >> "$LOCKFILE"
nohup $HOME/.config/OpenRGB/scripts/openrgb_profile.sh "$openrgb" "$LOCKFILE" >/dev/null 2>&1 &

#-------------------------------------------------
# Changes folder theme (takes a while....)
pkill nautilus
echo "☑️ Changing folder icons"
echo "Papirus False" >> "$LOCKFILE"
$HOME/.config/scripts/papirus_folders.sh "$icons" "$LOCKFILE" &

#-------------------------------------------------
# Make blurred background for wlogout
echo "wlogout False" >> "$LOCKFILE"
python3 $HOME/.config/themes/scripts/blur_wallpaper.py "$wallpaper" "$background_rgb_str" "$opacity" "$LOCKFILE"

#-------------------------------------------------
# Hyprland temp file to not show errors when loading themes
mv "$HOME/.config/hypr/colors_temp.conf" "$HOME/.config/hypr/colors.conf"
echo "✅ Hyprland done"

hyprctl setcursor "$cursor" "$size"
gsettings set org.gnome.desktop.interface cursor-theme "$cursor"
gsettings set org.gnome.desktop.interface cursor-size "$size"
echo "✅ Cursor changes"

gsettings set org.gnome.desktop.interface gtk-theme "$nautilus"
echo "✅ Nautilus changes"

#-------------------------------------------------
pkill swaync
pkill hyprpaper
pkill waybar
hyprctl reload
sleep 0.5

swaync & disown
waybar & disown
hyprpaper & disown

#-------------------------------------------------
# make sure float state is the same
$HOME/.config/scripts/toggle_float.sh "false"

# Mark Hyprland ready
sed -i "s|^Hyprland .*|Hyprland True|" "$LOCKFILE"
echo "$1" >> "$LOCKFILE"
echo "✅ all done"


# Notification timeout
timeout=10
for ((i=0; i<timeout; i++)); do
    if ! grep -q ' False$' "$LOCKFILE"; then
        notify-send "$1" "Theme activated."
        exit 0
    fi
    sleep 1
done

notify-send "$1" "Theme activation timed out."
