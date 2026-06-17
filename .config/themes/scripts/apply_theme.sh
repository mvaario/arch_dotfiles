#!/bin/bash
# Apply selected theme to different moduls
# Script called by theme_picker.sh
start_time=$(date +%s%N) # log the time

THEME_FILE="$HOME/.config/themes/colors/$1.sh"
LOCKFILE="$HOME/.config/themes/theme_switch.lock"

# Lock hyprland
sed -i "s|^Hyprland .*|Hyprland False|" "$LOCKFILE"

echo "Applying theme $1 from:" $THEME_FILE
echo ""
if [ ! -f "$THEME_FILE" ]; then
    echo "Theme not found: $1"
    # Release the lockfile
    sed -i "s|^Hyprland .*|Hyprland True|" "$LOCKFILE"
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

# create hex background with opacity
hexopacity="$HOME/.config/scripts/hex_opacity.sh"
alpha_hex=$("$hexopacity" "$opacity")

# changes color to rgb
background_rgb_str=$($HOME/.config/scripts/hex_to_rgb.sh "$background")
rgb_main=$($HOME/.config/scripts/hex_to_rgb.sh "$main")
# darken background since kitty is stupid and does not match
darkenbackground=$($HOME/.config/themes/scripts/darken_background.sh "$background")

# Get zen user.js file location
MAIN_PROFILE=$(whoami)
MAIN=$(grep -A5 "Name=$MAIN_PROFILE" ~/.config/zen/profiles.ini | \
grep "^Path=" | head -n1 | sed 's/Path=//')

# list of template files and their destination
declare -A files=(
    ["$HOME/.config/themes/templates/hyprland.template.conf"]="$HOME/.config/hypr/colors_temp.conf"
    ["$HOME/.config/themes/templates/hyprpaper.template.conf"]="$HOME/.config/hypr/hyprpaper.conf"
    ["$HOME/.config/themes/templates/waybar.template.css"]="$HOME/.config/waybar/style.css"
    ["$HOME/.config/themes/templates/kitty.template.conf"]="$HOME/.config/kitty/colors.conf"
    ["$HOME/.config/themes/templates/wofi.template.conf"]="$HOME/.config/wofi/style.css"
    ["$HOME/.config/themes/templates/swaync_style.template.css"]="$HOME/.config/swaync/style.css"
    ["$HOME/.config/themes/templates/fastfetch.template.conf"]="$HOME/.config/fastfetch/colors.conf"
    ["$HOME/.config/themes/templates/fastfetch_config.template.jsonc"]="$HOME/.config/fastfetch/config.jsonc"
    ["$HOME/.config/themes/templates/btop_style.template.theme"]="$HOME/.config/btop/themes/btop_style.theme"
    ["$HOME/.config/themes/templates/windows.template.conf"]="$HOME/.config/hypr/conf/window_theme.conf"
    ["$HOME/.config/themes/templates/gtk-4.template.css"]="$HOME/.config/gtk-4.0/gtk.css"
    ["$HOME/.config/themes/templates/zen_browser.template.js"]="$HOME/.config/zen/$MAIN/user.js"
    ["$HOME/.config/themes/templates/Main.template.qml"]="/usr/share/sddm/themes/Arch_sddm/Main.qml"
)

# Loop through the files and apply the theme
for template in "${!files[@]}"; do
    dest="${files[$template]}"
    # Use sed to find and replace placeholders
    sed -e "s|%background_rgb_str%|$background_rgb_str|g" \
        -e "s|%rgb_main%|$rgb_main|g" \
        -e "s,%opacity%,$opacity,g" \
        -e "s,%darkenbackground%,$darkenbackground,g" \
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
        -e "s,%folders%,$folders,g" \
        -e "s,%fastfetch%,$fastfetch,g" \
        -e "s,%alpha_hex%,$alpha_hex,g" \
        "$template" > "$dest"
done

#-------------------------------------------------
# Load openRGB profile (takes a while....)
echo "☑️ Changing OpenRGB profile"
CURRENT_PROFILE=$(grep '^OpenRGB ' "$LOCKFILE" | cut -d' ' -f3-)
sed -i "s|^OpenRGB .*|OpenRGB False|" "$LOCKFILE"
$HOME/.config/OpenRGB/scripts/openrgb_profile.sh "$openrgb" "$CURRENT_PROFILE" "$LOCKFILE" &

#-------------------------------------------------
# Changes folder theme
echo "☑️ Changing folder icons"
CURRENT_ICONS=$(grep '^Papirus ' "$LOCKFILE" | cut -d' ' -f3-)
sed -i "s|^Papirus .*|Papirus False|" "$LOCKFILE"
$HOME/.config/themes/scripts/papirus_folders.sh "$folders" "$CURRENT_ICONS" "$LOCKFILE" &

#-------------------------------------------------
# Make blurred background for wlogout
#CURRENT_WALLPAPER=$(grep '^Wlogout ' "$LOCKFILE" | cut -d' ' -f3-)
#sed -i "s|^Wlogout .*|Wlogout False|" "$LOCKFILE"
#python3 $HOME/.config/themes/scripts/blur_wallpaper.py "$wallpaper" "$background_rgb_str" "$opacity" "$CURRENT_WALLPAPER" "$LOCKFILE" &
#echo ""

#-------------------------------------------------
# Hyprland temp file to not show errors when loading themes
echo "☑️ Settings hyprland colors"
mv "$HOME/.config/hypr/colors_temp.conf" "$HOME/.config/hypr/colors.conf"


#-------------------------------------------------
# Copy sddm background
echo "☑️ Copying SDDM background"
cp -r $wallpaper /usr/share/sddm/themes/Arch_sddm/backgrounds/background.jpg

#-------------------------------------------------
if [[ "$2" != "0" ]]; then
    echo "☑️ Setting cursor theme"
    hyprctl setcursor "$cursor" "$size" &>/dev/null
fi
gsettings set org.gnome.desktop.interface cursor-theme "$cursor"
gsettings set org.gnome.desktop.interface cursor-size "$size"
sed -i "s|^Cursor .*|Cursor $cursor|" "$LOCKFILE"
sed -i "s|^Cursor_Size .*|Cursor_Size $size|" "$LOCKFILE"

echo "☑️ Setting gtk-theme"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme"


#-------------------------------------------------
# Make custom icons for waybar tray
echo "☑️ Recoloring icons"
CURRENT_COLOR=$(grep '^Recolor ' "$LOCKFILE" | cut -d' ' -f3-)
sed -i "s|^Recolor .*|Recolor False|" "$LOCKFILE"
$HOME/.config/themes/scripts/icon_recolor.sh "$foreground" "$CURRENT_COLOR" "$LOCKFILE" $
echo ""

#-------------------------------------------------
if [[ "$2" != "0" ]]; then
    output=$(hyprctl reload)
    echo "✅ hyprland: $output"

    pkill -USR2 waybar
    for monitor in $(hyprctl monitors -j | jq -r '.[].name'); do
        hyprctl hyprpaper wallpaper "$monitor, $wallpaper, cover" 
    done

    output=$(swaync-client --reload-css)
    echo "✅ swaync: $output"

    #-------------------------------------------------
    # make sure float state is the same
    $HOME/.config/swaync/scripts/toggle_float.sh "false" "$LOCKFILE" &

    # Notification timeout
    timeout=5000
    while grep -vE '^OpenRGB' "$LOCKFILE" | grep -qE '\bFalse\b'; do
        $HOME/.config/themes/scripts/timeout.sh "$start_time" "$timeout" "$LOCKFILE" 
    done
fi
echo "✅ all done"
echo ""

#-------------------------------------------------
# Mark to time and notify
end_time=$(date +%s%N)
elapsed=$(( ($end_time - $start_time) / 1000000 ))
sed -i "s|^Theme .*|Theme $1 took ${elapsed} ms|" "$LOCKFILE"
if [[ "$2" != "0" ]]; then
    notify-send "$1" "Theme activated."
fi
exit 0