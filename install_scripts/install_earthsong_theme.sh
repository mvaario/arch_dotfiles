#!/bin/bash
LOCKFILE="$HOME/.config/themes/theme_switch.lock"
THEME_FILE="$HOME/.config/themes/colors/earthsong.sh"

# Load common colors
COMMON_FILE="$HOME/.config/themes/common.sh"

# Source the theme file to load the color variables
source "$COMMON_FILE"
source "$THEME_FILE"

#create hex background with opacity
hexopacity="$HOME/.config/scripts/hex_opacity.sh"
alpha_hex=$("$hexopacity" "$opacity")

# changes color to rgb
background_rgb_str=$($HOME/.config/scripts/hex_to_rgb.sh "$background")
rgb_main=$($HOME/.config/scripts/hex_to_rgb.sh "$main")
#darken background since kitty is stupid and does not match
darkenbackground=$($HOME/.config/themes/scripts/darken_background.sh "$background")

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
        -e "s,%icons%,$icons,g" \
        -e "s,%fastfetch%,$fastfetch,g" \
        -e "s,%alpha_hex%,$alpha_hex,g" \
        "$template" > "$dest"
done

#-------------------------------------------------
# Load openRGB profile (takes a while....)
echo "☑️ Changing OpenRGB profile"
CURRENT_PROFILE=$(grep '^OpenRGB ' "$LOCKFILE" | cut -d' ' -f3-)
$HOME/.config/OpenRGB/scripts/openrgb_profile.sh "$openrgb" "$CURRENT_PROFILE" "$LOCKFILE"

#-------------------------------------------------
# Changes folder theme
echo "☑️ Changing folder icons"
CURRENT_ICONS=""
$HOME/.config/themes/scripts/papirus_folders.sh "$icons" "$CURRENT_ICONS" "$LOCKFILE"

#-------------------------------------------------
# Make blurred background for wlogout
CURRENT_WALLPAPER=$(grep '^Wlogout ' "$LOCKFILE" | cut -d' ' -f3-)
python3 $HOME/.config/themes/scripts/blur_wallpaper.py "$wallpaper" "$background_rgb_str" "$opacity" "$CURRENT_WALLPAPER" "$LOCKFILE"

#-------------------------------------------------
# Hyprland temp file to not show errors when loading themes
mv "$HOME/.config/hypr/colors_temp.conf" "$HOME/.config/hypr/colors.conf"
echo "✅ Hyprland done"

gsettings set org.gnome.desktop.interface cursor-theme "$cursor"
gsettings set org.gnome.desktop.interface cursor-size "$size"
echo "✅ Cursor changes"

gsettings set org.gnome.desktop.interface gtk-theme "$nautilus"
echo "✅ Nautilus changes"

# Make custom icons for waybar tray
CURRENT_COLOR=$(grep '^Recolor ' "$LOCKFILE" | cut -d' ' -f3-)
$HOME/.config/themes/scripts/icon_recolor.sh "$foreground" "$CURRENT_COLOR" "$LOCKFILE"