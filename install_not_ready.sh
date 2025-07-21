#!/bin/bash
set -e

# Ask for sudo privileges once at the beginning
if ! sudo -v; then
  echo "❌ This script requires sudo privileges."
  exit 1
fi

# Define user for auto-login
read -p "Enter your username: " USER

# Start a background sudo keep-alive loop
( while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done 2>/dev/null &
) &

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

echo "🚀 Starting Arch setup script..."
PACKAGES=(
    git
    neovim
    firefox
    code
    hyprpolkitagent
    ufw
    pacman-contrib

    noto-fonts
    noto-fonts-emoji
    ttf-dejavu
    ttf-liberation
    ttf-roboto
    noto-fonts-cjk
    papirus-icon-theme

    pipewire
    pipewire-alsa
    pipewire-audio
    pipewire-pulse
    lib32-libpipewire
    lib32-pipewire
    pavucontrol

    nvidia
    libva-nvidia-driver
    nvidia-utils
    vulkan-icd-loader
    lib32-nvidia-utils
    lib32-vulkan-icd-loader
    nvidia-settings

    linux-headers

    kitty
    waybar
    hyprland
    hyprpaper
    hyprlock
    hyprsunset
    wofi
    nautilus
    starship
    fastfetch
    
    lact
    gnome-disk-utility
    celluloid
    steam
    discord
    lutris
    gamemode
    openrgb

	mousepad
	meld

    cpupower
    
)

# Package installation loop
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

echo "📦 Installing AUR packages with yay..."

AUR_PACKAGES=(
    papirus-folders
    openrazer-meta-git
    gitkraken
    ttf-jetbrains-mono-nerd
    nautilus-open-any-terminal
    catppuccin-cursors-mocha
)

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

echo "📥 Installing Orchis theme..."
[ -d Orchis-theme ] || git clone https://github.com/vinceliuice/Orchis-theme.git
cd Orchis-theme
./install.sh -d ~/.themes -t all -c dark -s standard --tweaks nord
cd -

echo "✅ All packages processed."
echo " "
#------------------------------------------------------------------------

# Create or update modprobe config
echo "💾 Writing /etc/modprobe.d/nvidia.conf..."
echo "options nvidia_drm modeset=1" | sudo tee /etc/modprobe.d/nvidia.conf > /dev/null


# Modify mkinitcpio.conf
echo "🧩 Updating /etc/mkinitcpio.conf..."
if grep -q '^MODULES=' /etc/mkinitcpio.conf; then
  sudo sed -i 's/^MODULES=.*/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
else
  echo "MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)" | sudo tee -a /etc/mkinitcpio.conf
fi

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
echo "🛠️ Rebuilding initramfs..."
sudo mkinitcpio -P


# Update /etc/environment
echo "🌱 Adding environment variables to /etc/environment..."
if ! grep -q 'LIBVA_DRIVER_NAME=nvidia' /etc/environment; then
  sudo tee -a /etc/environment > /dev/null <<EOF

# NVIDIA Wayland / VA-API support
LIBVA_DRIVER_NAME=nvidia
__GLX_VENDOR_LIBRARY_NAME=nvidia
EOF
fi

#------------------------------------------------------------------------
echo "🧰 Applying configuration settings"

# copy config files
cp -r "$(pwd)/.config" "$HOME/"
cp -r "$(pwd)/.bashrc" "$HOME/"

# random stuff for papirus folder icons
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'

# Set terminal for nautilus
gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal kitty

# Random stuff for razer...
sudo gpasswd -a $USER plugdev

# Enable ufw
sudo systemctl enable ufw

# Performance mode
echo 'governor="performance"' | sudo tee /etc/default/cpupower

# Enable theme
papirus-folders -C orange --theme Papirus-Dark
sudo chown -R $USER:$USER /var/lib/papirus-folders/
sudo chown -R $USER:$USER /usr/share/icons/Papirus*

# Autolog in file
if [ ! -d "/etc/systemd/system/getty@tty1.service.d" ]; then
    echo "Creating directory for systemd override: /etc/systemd/system/getty@tty1.service.d"
    sudo mkdir -p "/etc/systemd/system/getty@tty1.service.d"
fi

echo "[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin $USER --noclear %I $TERM" | sudo tee "/etc/systemd/system/getty@tty1.service.d/override.conf" > /dev/null


# Link nautilus compare using meld (did not work :( )
[ -e "$HOME/.local/share/nautilus/scripts/Compare with Meld" ] || \
ln -s "$HOME/.config/scripts/nautilus_compare.sh" "$HOME/.local/share/nautilus/scripts/Compare with Meld"


echo "✅ Configuration complete."
echo ""
#------------------------------------------------------------------------

# Ask to reboot
read -p "🔁 Reboot now to apply changes? (y/N): " reboot_ans
case "$reboot_ans" in
    [Yy]*) echo "♻️ Rebooting..."; sudo reboot;;
    *) echo "❗ Reboot skipped. Please reboot manually later.";;
esac













