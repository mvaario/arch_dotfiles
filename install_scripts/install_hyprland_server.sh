#!/bin/bash
set -e

# Edit these if nvidia or razer is used
nvidia=true

#------------------------------------------------------------------------
BASE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
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
	hyprpolkitagent
	ufw
	pacman-contrib

	papirus-icon-theme
	linux-headers
  openssh
  jq

	
	hyprland
  kitty
	hyprpaper
	nautilus
	starship
	fastfetch
	btop
  ethtool
  iperf3

  # softwares
  code

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
    papirus-folders
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
  "$BASE_DIR/install_scripts/nvidia.sh"
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
echo "Enabling Wake-on_LAN 🌐"
INTERFACE=$(ip route | awk '/default/ {print $5; exit}')

if [ -z "$INTERFACE" ]; then
    echo "ERROR:🛑 No active network interface detected. Skipping"
    echo ""
else
  echo "Detected network interface: $INTERFACE"

cat <<EOF | sudo tee /etc/systemd/system/wol.service > /dev/null
[Unit]
Description=Enable Wake-on-LAN

[Service]
Type=oneshot
ExecStart=/usr/bin/ethtool -s $INTERFACE wol g

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable wol.service

echo "🌐 Wake-on-LAN enabled"
echo ""
fi


#------------------------------------------------------------------------
# Enable speed test
echo "Trying to enable speedtest 📡"
if [ -f /etc/systemd/system/iperf3.service ]; then
cat <<EOF | sudo tee /etc/systemd/system/iperf3.service > /dev/null
[Unit]
Description=iPerf3 bandwidth measurement daemon
After=network.target

[Service]
ExecStart=/usr/bin/iperf3 -s
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable iperf3.service

echo "📡 Speed test enabled"
else
  echo "🛑 Enabling speedtest failed"
fi


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

# copy server spesific configs
cp -r "$BASE_DIR/config_server/." "$HOME/.config/"

#------------------------------------------------------------------------
# Copy icons to .icons folder. Used to make custom icons work without permission issues
echo "✨ Copying icons"
mkdir -p $HOME/.icons/Papirus-Dark
cp -a /usr/share/icons/Papirus-Dark $HOME/.icons/Papirus-Dark
find "$HOME/.icons/Papirus-Dark" -type l -exec rm -v {} + > /dev/null
cp -an /usr/share/icons/Papirus/* $HOME/.icons/Papirus-Dark
echo ""

#------------------------------------------------------------------------
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
echo 'governor="performance"' | sudo tee /etc/default/cpupower > /dev/null
echo ""

# Grub timeout and style
if [ -f "/etc/default/grub" ]; then
	echo "⏱️ Setting Grub timeout"
	GRUB_FILE="/etc/default/grub"
	sudo sed -i \
	-e 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' \
	-e 's/^GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=hidden/' \
	"$GRUB_FILE"

	sudo grub-mkconfig -o /boot/grub/grub.cfg
  echo ""
fi

# Autolog in file!!!!
echo "🛡️ Enabling autolog in"
if [ ! -d "/etc/systemd/system/getty@tty1.service.d" ]; then
    echo "Creating directory for systemd override: /etc/systemd/system/getty@tty1.service.d"
    sudo mkdir -p "/etc/systemd/system/getty@tty1.service.d"
fi

echo "[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin $USER --noclear %I xterm-kitty" | sudo tee "/etc/systemd/system/getty@tty1.service.d/override.conf" > /dev/null
echo ""

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












