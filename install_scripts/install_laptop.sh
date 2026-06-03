echo " "
echo "💻 Setting up laptop configs"
echo " "
echo "🚀 Downloading packages for laptop"
PACKAGES=(
    networkmanager      # wifi
)

# Package install
for pkg in "${PACKAGES[@]}"; do
    echo "📦 Installing $pkg..."
    if ! sudo pacman -S --noconfirm --needed "$pkg"; then
        echo "❌ Failed to install: $pkg"
        read -p "⚠️  Continue anyway? (y/N): " yn
        case "$yn" in
            [Yy]*) echo "⏩ Continuing...";;
            *) echo "🛑 Exiting script."; exit 1;;
        esac
    fi
done

#------------------------------------------------------------------------
echo "💻 Setting up laptop configs"
    sed -i \
        -e 's|^[[:space:]]*//[[:space:]]*"battery"|    "battery"|' \
        -e 's|^[[:space:]]*//[[:space:]]*"network"|    "network"|' \
        	"$HOME/.config/waybar/config.jsonc"

	sed -i \
        -e 's|^[[:space:]]*#[[:space:]]*bind = ,XF86MonBrightnessUp, exec, brightnessctl s 5%+|bind = ,XF86MonBrightnessUp, exec, brightnessctl s 5%+|' \
		-e 's|^[[:space:]]*#[[:space:]]*bind = ,XF86MonBrightnessDown, exec, brightnessctl s 5%-|bind = ,XF86MonBrightnessDown, exec, brightnessctl s 5%-|' \
		-e 's|^[[:space:]]*#[[:space:]]*bind = ,XF86AudioLowerVolume, exec, pactl -- set-sink-volume 0 -1%|bind = ,XF86AudioLowerVolume, exec, pactl -- set-sink-volume 0 -1%|' \
		-e 's|^[[:space:]]*#[[:space:]]*bind = ,XF86AudioRaiseVolume, exec, pactl -- set-sink-volume 0 +1%|bind = ,XF86AudioRaiseVolume, exec, pactl -- set-sink-volume 0 +1%|' \
		-e 's|^[[:space:]]*#[[:space:]]*bind = ,XF86AudioMute, exec, pactl -- set-sink-mute 0 toggle|bind = ,XF86AudioMute, exec, pactl -- set-sink-mute 0 toggle|' \
        	"$HOME/.config/hypr/conf/keybinds.conf"

#------------------------------------------------------------------------
echo "✅ Laptop configurations done."
echo ""