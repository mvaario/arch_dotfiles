#!/bin/bash
# Apply selected theme to different moduls
# Script called be theme_picker
THEME_FILE="$HOME/.config/themes/colors/$1"

echo $THEME_FILE

if [ ! -f "$THEME_FILE" ]; then
    echo "Theme not found: $1"
    exit 1
fi

# Source the theme file to load the color variables
source "$THEME_FILE"

# List of template files and their destination
declare -A files=(
    #["$HOME/Documents/projects/rice_configs/chrome/userChrome.css.template"]="$HOME/.mozilla/firefox/3j5wjipw.new-default/chrome/userChrome.css"
    ["$HOME/.config/themes/templates/wofi.template.conf"]="$HOME/.config/wofi/style.css"
    ["$HOME/.config/themes/templates/hyprlock.template.conf"]="$HOME/.config/hypr/hyprlock.conf"
    ["$HOME/.config/themes/templates/hyprpaper.template.conf"]="$HOME/.config/hypr/hyprpaper.conf"
    ["$HOME/.config/themes/templates/kitty.template.conf"]="$HOME/.config/kitty/colors.conf"
    ["$HOME/.config/themes/templates/waybar.template.css"]="$HOME/.config/waybar/style.css"
    ["$HOME/.config/themes/templates/hyprland.template.conf"]="$HOME/.config/hypr/colors_temp.conf"
    ["$HOME/.config/themes/templates/fastfetch.template.conf"]="$HOME/.config/fastfetch/colors.conf"
    ["$HOME/.config/themes/templates/windows.template.conf"]="$HOME/.config/hypr/conf/window_theme.conf"
    #["$HOME/.config/themes/templates/startup_theme.template.conf"]="$HOME/.config/hypr/conf/startup_theme.conf"
)

# Loop through the files and apply the theme
for template in "${!files[@]}"; do
    dest="${files[$template]}"
    # Use sed to find and replace placeholders
    sed -e "s,%background%,$background,g" \
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
        -e "s,%bfastfetch%,$bfastfetch,g" \
        -e "s,%fastfetch%,$fastfetch,g" \
        -e "s,%cursor%,$cursor,g" \
        -e "s,%size%,$size,g" \
        -e "s,%nautilus%,$nautilus,g" \
        -e "s,%icons%,$icons,g" \
        "$template" > "$dest"
done


#hyprland temp file to not show errors when loading themes
mv "$HOME/.config/hypr/colors_temp.conf" "$HOME/.config/hypr/colors.conf"

hyprctl setcursor $cursor $size
gsettings set org.gnome.desktop.interface gtk-theme $nautilus

pkill waybar
pkill hyprpaper
sleep 0.5
hyprctl reload

hyprpaper &
waybar &

/usr/bin/papirus-folders -C $icons --theme Papirus-Dark >> /tmp/papirus.log 2>&1

