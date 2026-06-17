#!/bin/bash
set -e
BASE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

echo " "
echo " "
echo " "
desktop=$("$BASE_DIR/install_scripts/get_user_settings.sh" "desktop")
server=$("$BASE_DIR/install_scripts/get_user_settings.sh" "server")
laptop=$("$BASE_DIR/install_scripts/get_user_settings.sh" "laptop")
nvidia=$("$BASE_DIR/install_scripts/get_user_settings.sh" "NVIDIA")
razer=$("$BASE_DIR/install_scripts/get_user_settings.sh" "razer")
optional_softwares=$("$BASE_DIR/install_scripts/get_user_settings.sh" "optional software")

# Verification
echo " "
echo " "
read -rp "🚀 Continue with installation? [Y/n]: " CONTINUE
CONTINUE=${CONTINUE,,}

if [[ "$CONTINUE" == "n" || "$CONTINUE" == "no" ]]; then
    echo "❌ Installation canceled"
    exit 1
fi

#------------------------------------------------------------------------ 
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
sudo pacman -Syu --noconfirm

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
echo "🚀 Downloading essential packages"
PACKAGES=(
	# essentials
	git
	neovim
	pacman-contrib
	linux-headers
	jq								# json processor
	
	starship
	fastfetch

	# fonts
	noto-fonts
	noto-fonts-emoji
	ttf-jetbrains-mono-nerd
	
	# softwares
	btop

	# misc
	ufw
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
mkdir -p ~/.local/share/applications

# copy config files
echo "Copying dot files"
cp -r "$BASE_DIR/.config" "$HOME/"
cp -r "$BASE_DIR/.bashrc" "$HOME/"

# install desktop
if $desktop; then
	"$BASE_DIR/install_scripts/install_desktop.sh" "$BASE_DIR"
fi

# Setup server
if $server; then
	"$BASE_DIR/install_scripts/install_server.sh" "$BASE_DIR"
fi

# Setup laptop softwares
if $laptop; then
	"$BASE_DIR/install_scripts/install_optional_softwares.sh"
fi

# Setup nvidia
if $nvidia; then
	"$BASE_DIR/install_scripts/install_nvidia.sh"
fi

# Setup razer
if $razer; then
	"$BASE_DIR/install_scripts/install_razer.sh"
fi

# Setup optional softwares
if $optional_softwares; then
	"$BASE_DIR/install_scripts/install_optional_softwares.sh"
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

#------------------------------------------------------------------------
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


# Enable ufw
echo "🛡️ Enabling ufw"
sudo systemctl enable ufw > /dev/null
sudo ufw --force enable > /dev/null
echo ""

# Performance mode
echo "⚙️ Enabling performance mode"
echo 'governor="performance"' | sudo tee /etc/default/cpupower > /dev/null
echo ""

#------------------------------------------------------------------------
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

# Systemd-boot timeout
if [ -f "/boot/loader/loader.conf" ]; then
	echo "⏱️ Setting Systemd-boot timeout"
	SYSTEMD_FILE="/boot/loader/loader.conf"
	sudo sed -i \
	-e 's/^timeout.*/timeout 0/' \
	"$SYSTEMD_FILE"
	echo ""
fi

#------------------------------------------------------------------------
# enable desktop theme
if $desktop; then
	mkdir -p "$HOME/.config/btop/themes"
	mkdir -p "$HOME/.config/gtk-3.0"
	mkdir -p "$HOME/.config/gtk-4.0"
	~/.config/themes/scripts/apply_theme.sh "earthsong" 0
	echo ""
fi

#------------------------------------------------------------------------
# Ask to reboot
sleep 1
read -p "🔁 Reboot now to apply changes? (y/N): " reboot_ans
case "$reboot_ans" in
    [Yy]*) echo "♻️ Rebooting..."; sudo reboot;;
    *) echo "❗ Reboot skipped. Please reboot manually later.";;
esac













