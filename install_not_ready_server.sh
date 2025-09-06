#!/bin/bash
set -e

# Edit these if nvidia or razer is used
nvidia=true

#------------------------------------------------------------------------
# Ask for sudo password upfront
if ! sudo -v; then
  echo "❌ This script requires sudo privileges."
  exit 1
fi

# Keep sudo alive in the background
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

if ! command -v yay &> /dev/null; then
    echo "📥 Installing yay AUR helper..."
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd -
fi


#------------------------------------------------------------------------
echo " "
echo "🚀 Downloading packages..."
PACKAGES=(
	git
	neovim
	code
	hyprpolkitagent
	ufw
	pacman-contrib

	papirus-icon-theme
	linux-headers

	kitty
	hyprland
	hyprpaper
	nautilus
	starship
	fastfetch
	btop
    
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
echo " "
echo "📦 Downloading AUR packages..."

AUR_PACKAGES=(
    nautilus-open-any-terminal
    sunshine
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
# Setup nvidia
if $nvidia; then
	install_scripts/nvidia.sh
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
cp -r "$(pwd)/.config" "$HOME/"
cp -r "$(pwd)/.bashrc" "$HOME/"

# copy server spesific configs
cp -r "$(pwd)/.config_server/." "$HOME/.config/"

# Enable ufw
sudo systemctl enable ufw

# random stuff for papirus folder icons
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'

# Set terminal for nautilus
gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal kitty

# Performance mode
echo 'governor="performance"' | sudo tee /etc/default/cpupower

# enable theme
~/.config/scripts/apply_theme.sh earthsong.sh

# Add permissions
sudo chown -R $USER:$USER /var/lib/papirus-folders/
sudo chown -R $USER:$USER /usr/share/icons/Papirus*

# Autolog in file
if [ ! -d "/etc/systemd/system/getty@tty1.service.d" ]; then
    echo "Creating directory for systemd override: /etc/systemd/system/getty@tty1.service.d"
    sudo mkdir -p "/etc/systemd/system/getty@tty1.service.d"
fi

echo "[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin $USER --noclear %I xterm-kitty" | sudo tee "/etc/systemd/system/getty@tty1.service.d/override.conf" > /dev/null

echo "✅ Configuration complete."
echo ""

#------------------------------------------------------------------------
# Ask to reboot
read -p "🔁 Reboot now to apply changes? (y/N): " reboot_ans
case "$reboot_ans" in
    [Yy]*) echo "♻️ Rebooting..."; sudo reboot;;
    *) echo "❗ Reboot skipped. Please reboot manually later.";;
esac













