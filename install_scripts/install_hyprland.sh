#!/bin/bash
set -e

# Edit these if nvidia or razer is used
nvidia=true
razer=true
optional_softwares=true
laptop=true


#------------------------------------------------------------------------ 
BASE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
# Ask for sudo password upfront
if ! sudo -v; then
  echo "❌ This script requires sudo privileges."
  exit 1
fi 

# Keep sudo alive in the background (does not work)
(
  while true; do
    sleep 30
    sudo -n true
    kill -0 "$$" || exit
  done
) 2>/dev/null &


#------------------------------------------------------------------------
echo " "
echo "🔧 Enabling [multilib] repo in /etc/pacman.conf..."
sudo awk '
BEGIN { in_multilib = 0 }
/^#\s*\[multilib\]/ { print substr($0, 2); in_multilib = 1; next }
/^\s*\[multilib\]/ { print; in_multilib = 1; next }
in_multilib && /^\s*#/ && /Include\s*=\s*\/etc\/pacman.d\/mirrorlist/ {
    # uncomment line by removing leading #
    sub(/^#/, "")
    print
    next
}
in_multilib && /^\s*\[/ { in_multilib = 0 }
{ print }
' /etc/pacman.conf | sudo tee /etc/pacman.conf.tmp > /dev/null
sudo mv /etc/pacman.conf.tmp /etc/pacman.conf


#------------------------------------------------------------------------
echo " "
echo "🔄 Updating system"
sudo pacman -Syu

#------------------------------------------------------------------------
echo " "
echo "🚀 Downloading packages..."
PACKAGES=(
	# essentials
	git
	neovim
	hyprpolkitagent
	ufw
	pacman-contrib

	# fonts
	noto-fonts
	noto-fonts-emoji
	ttf-jetbrains-mono-nerd
	ttf-dejavu
	ttf-liberation
	ttf-roboto
	noto-fonts-cjk
	papirus-icon-theme

	# audio
	pipewire
	pipewire-alsa
	pipewire-audio
	pipewire-pulse
	lib32-libpipewire
	lib32-pipewire
	pavucontrol
	linux-headers
	jq

	# packages
	hyprland
	kitty
	waybar
	hyprpaper
	hyprsunset
	wofi
	nautilus
	swaync
	starship
	fastfetch
	btop
	sddm
	xdg-desktop-portal-hyprland 	# allow screen sharing
	libinput-tools 					# For wofi scripts to get devices (does it even work?)
	
	# softwares
	code
	ristretto 						# Image viewer
	grim 							# screenshot
	slurp 							# screenshot
	gnome-disk-utility
	mousepad						# easy notepad
	meld							# mousepad compare
	
	# miscs
	cpupower
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
if ! command -v yay &> /dev/null; then
    echo "📥 Installing yay AUR helper..."
	sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd -
fi


#------------------------------------------------------------------------
echo " "
echo "📦 Downloading AUR packages..."

AUR_PACKAGES=(
	papirus-folders
	nautilus-open-any-terminal
	catppuccin-cursors-mocha

)

# AUR package install
for aur_pkg in "${AUR_PACKAGES[@]}"; do
    echo "📥 Installing $aur_pkg from AUR..."
    if ! yay -S --noconfirm --needed "$aur_pkg"; then
        echo "❌ Failed to install: $aur_pkg"
        read -p "⚠️  Continue anyway? (y/N): " yn
        case "$yn" in
            [Yy]*) echo "⏩ Continuing...";;
            *) echo "🛑 Exiting script."; exit 1;;
        esac
	fi
done


#------------------------------------------------------------------------
mkdir -p ~/.local/share/applications

# Setup nvidia
if $nvidia; then
	"$BASE_DIR/install_scripts/nvidia.sh"
fi

# Setup razer
if $razer; then
	"$BASE_DIR/install_scripts/razer.sh"
	sed -i \
		-e 's|^[[:space:]]*//[[:space:]]*"custom\/razer"|    "custom\/razer"|' \
			"$BASE_DIR/.config/waybar/config.jsonc"
fi

# Setup optional softwares
if $optional_softwares; then
	"$BASE_DIR/install_scripts/optional_softwares.sh"
fi

if $laptop; then
	echo "💻 Setting up laptop configs"
    sed -i \
        -e 's|^[[:space:]]*//[[:space:]]*"battery"|    "battery"|' \
        -e 's|^[[:space:]]*//[[:space:]]*"network"|    "network"|' \
        	"$BASE_DIR/.config/waybar/config.jsonc"

	sed -i \
        -e 's|^[[:space:]]*#[[:space:]]*bind = ,XF86MonBrightnessUp, exec, brightnessctl s 5%+|bind = ,XF86MonBrightnessUp, exec, brightnessctl s 5%+|' \
		-e 's|^[[:space:]]*#[[:space:]]*bind = ,XF86MonBrightnessDown, exec, brightnessctl s 5%-|bind = ,XF86MonBrightnessDown, exec, brightnessctl s 5%-|' \
		-e 's|^[[:space:]]*#[[:space:]]*bind = ,XF86AudioLowerVolume, exec, pactl -- set-sink-volume 0 -1%|bind = ,XF86AudioLowerVolume, exec, pactl -- set-sink-volume 0 -1%|' \
		-e 's|^[[:space:]]*#[[:space:]]*bind = ,XF86AudioRaiseVolume, exec, pactl -- set-sink-volume 0 +1%|bind = ,XF86AudioRaiseVolume, exec, pactl -- set-sink-volume 0 +1%|' \
		-e 's|^[[:space:]]*#[[:space:]]*bind = ,XF86AudioMute, exec, pactl -- set-sink-mute 0 toggle|bind = ,XF86AudioMute, exec, pactl -- set-sink-mute 0 toggle|' \
        	"$BASE_DIR/.config/hypr/conf/keybinds.conf"
	echo ""
fi

#------------------------------------------------------------------------
# Get user
USER=$(logname)

if [ ! -f ~/.local/opt/zen/zen ]; then
	echo " "
	echo "📥 Installing latest Zen Browser..."
	mkdir -p ~/.local/opt/zen
	
	# Download the latest version
	curl -L https://github.com/zen-browser/desktop/releases/latest/download/zen.linux-x86_64.tar.xz -o /tmp/zen-latest.tar.xz

	# Extract
	tar xf /tmp/zen-latest.tar.xz -C ~/.local/opt/zen --strip-components=1

	# Create desktop entry for wofi
	cat > ~/.local/share/applications/zen.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Zen Browser
Exec=/home/$USER/.local/opt/zen/zen %U
Icon=/home/$USER/.local/opt/zen/browser/chrome/icons/default/default128.png
Terminal=false
Categories=Network;WebBrowser;
EOF

	chmod +x ~/.local/share/applications/zen.desktop
	update-desktop-database ~/.local/share/applications/
	
	# Delete temp file
	rm /tmp/zen-latest.tar.xz
fi


#------------------------------------------------------------------------
if [ ! -d "$HOME/.themes/Orchis-Dark-Nord" ]; then
	echo " "
	echo "📥 Installing Orchis theme..."
    git clone https://github.com/vinceliuice/Orchis-theme.git /tmp/Orchis-theme
	cd /tmp/Orchis-theme
	./install.sh -d ~/.themes -t all -c dark -s standard --tweaks nord
	cd -
	rm -rf /tmp/Orchis-theme
fi

echo "✅ All packages installed."
echo " "


#------------------------------------------------------------------------
# Update HOOKS line
if grep -q '^HOOKS=' /etc/mkinitcpio.conf; then
  sudo sed -i 's/^HOOKS=.*/HOOKS=(base autodetect udev microcode block filesystems keyboard)/' /etc/mkinitcpio.conf
else
  echo 'HOOKS=(base autodetect udev microcode block filesystems keyboard)' | sudo tee -a /etc/mkinitcpio.conf
fi

# Set COMPRESSION="cat"
if grep -q '^COMPRESSION=' /etc/mkinitcpio.conf; then
  sudo sed -i 's/^COMPRESSION=.*/COMPRESSION="cat"/' /etc/mkinitcpio.conf
else
  echo 'COMPRESSION="cat"' | sudo tee -a /etc/mkinitcpio.conf
fi

# Rebuild initramfs
echo " "
echo "🛠️ Rebuilding initramfs..."
sudo mkinitcpio -P

#------------------------------------------------------------------------
echo " "
echo "🧰 Applying configuration settings"

# copy config files
echo "Copying dot files"
cp -r "$BASE_DIR/.config" "$HOME/"
cp -r "$BASE_DIR/.bashrc" "$HOME/"


#------------------------------------------------------------------------
echo "🖥️ Configurating monitors"
# detect connected monitors
mapfile -t monitors < <(
    for m in /sys/class/drm/*/status; do
        [[ $(<"$m") == "connected" ]] &&
        basename "$(dirname "$m")" | sed 's/^card[0-9]-//'
    done
)

primary="${monitors[0]}"
secondary="${monitors[1]}"
# replace first placeholder (required)
sed -i "s/\bDP-1\b/$primary/g" "$HOME/.config/hypr/hyprland.conf"
sed -i "s/\bDP-1\b/$primary/g" "$HOME/.config/themes/templates/hyprpaper.template.conf"
sed -i "s/\bDP-1\b/$primary/g" "$HOME/.config/hypr/conf/autostart.conf"
sed -i "s/\bDP-1\b/$primary/g" "$HOME/.config/hypr/conf/keyboard.conf"
sed -i "s/\bDP-1\b/$primary/g" "$HOME/.config/waybar/config.jsonc"

if [[ -n "$secondary" ]]; then
    # replace second placeholder
    sed -i "s/\bHDMI-A-1\b/$secondary/g" "$HOME/.config/hypr/hyprland.conf"
	sed -i "s/\bHDMI-A-1\b/$secondary/g" "$HOME/.config/themes/templates/hyprpaper.template.conf"
	sed -i "s/\bHDMI-A-1\b/$secondary/g" "$HOME/.config/waybar/config.jsonc"
else
    # remove all lines containing HDMI-A-1
    sed -i '/HDMI-A-1/d' "$HOME/.config/hypr/hyprland.conf"
	sed -i '/HDMI-A-1/d' "$HOME/.config/waybar/config.jsonc"
fi

#------------------------------------------------------------------------
# Copy icons to .icons folder. Used to make custom icons work without permission issues
echo "✨ Copying icons"
mkdir -p $HOME/.icons/Papirus-Dark
cp -a /usr/share/icons/Papirus-Dark $HOME/.icons/Papirus-Dark
find "$HOME/.icons/Papirus-Dark" -type l -exec rm -v {} + > /dev/null
cp -an /usr/share/icons/Papirus/* $HOME/.icons/Papirus-Dark
echo ""

# Enable ufw
echo "🛡️ Enabling ufw"
sudo systemctl enable ufw
echo ""

# Enable Papirus-Dark
echo "🎨 Enabling icon theme"
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
echo ""

# Set terminal for nautilus
echo "📟 Enabling open-any-terminal"
gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal kitty
echo ""

# Performance mode
echo "⚙️ Enabling performance mode"
echo 'governor="performance"' | sudo tee /etc/default/cpupower
echo ""

# add user to input group, needed to detect mouse inputs
sudo usermod -aG input $USER

# Grub timeout and style
if [ -f "/etc/default/grub" ]; then
	echo "⏱️ Setting Grub timeout"
	GRUB_FILE="/etc/default/grub"
	sudo sed -i \
	-e 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' \
	-e 's/^GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=hidden/' \
	"$GRUB_FILE"

	sudo grub-mkconfig -o /boot/grub/grub.cfg
fi

# Link nautilus compare using meld
echo "✅ Creating nautilus compare with Meld link"
if [ -d "$HOME/.local/share/nautilus/scripts" ]; then
	rm -rf $HOME/.local/share/nautilus/scripts
fi

echo "✅ Creating mousepad compare"
mkdir -p "$HOME/.local/share/nautilus/scripts"
[ -e "$HOME/.local/share/nautilus/scripts/Compare with Meld" ] || \
ln -s "$HOME/.config/nautilus/scripts/nautilus_compare.sh" "$HOME/.local/share/nautilus/scripts/Compare with Meld"

# set mousepad theme
echo "✅ Setting mousepad theme"
export DISPLAY=:0
export XDG_RUNTIME_DIR="/run/user/$(id -u)"

sudo -u "$USER" DISPLAY=:0 XDG_RUNTIME_DIR="/run/user/$(id -u $USER)" gsettings set org.xfce.mousepad.preferences.view color-scheme 'oblivion'
sudo -u "$USER" DISPLAY=:0 XDG_RUNTIME_DIR="/run/user/$(id -u $USER)" gsettings set org.xfce.mousepad.preferences.view tab-width 4
sudo -u "$USER" DISPLAY=:0 XDG_RUNTIME_DIR="/run/user/$(id -u $USER)" gsettings set org.xfce.mousepad.preferences.view font-name 'JetBrainsMonoNL Nerd Font Mono 10'
sudo -u "$USER" DISPLAY=:0 XDG_RUNTIME_DIR="/run/user/$(id -u $USER)" gsettings set org.xfce.mousepad.preferences.view show-line-numbers true
sudo -u "$USER" DISPLAY=:0 XDG_RUNTIME_DIR="/run/user/$(id -u $USER)" gsettings set org.xfce.mousepad.preferences.window always-show-tabs true


# enable theme
~/.config/themes/scripts/apply_theme.sh "earthsong" 0

echo "✅ Configuration complete."
echo ""

#------------------------------------------------------------------------
# Ask to reboot
read -p "🔁 Reboot now to apply changes? (y/N): " reboot_ans
case "$reboot_ans" in
    [Yy]*) echo "♻️ Rebooting..."; sudo reboot;;
    *) echo "❗ Reboot skipped. Please reboot manually later.";;
esac













