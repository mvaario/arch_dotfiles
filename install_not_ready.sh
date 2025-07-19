#!/bin/bash
set -e

if ! sudo -v; then
  echo "❌ This script requires sudo privileges."
  exit 1
fi

# Keep sudo alive until script ends
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo "🔧 Copying custom pacman.conf with multilib enabled..."
sudo cp pacman.conf /etc/pacman.conf


echo "Updating system"
sudo pacman -Syu

if ! command -v yay &> /dev/null; then
    echo "📥 Installing yay AUR helper..."
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd -
fi

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
    xed
    gnome-disk-utility
    celluloid
    steam
    discord
    lutris
    gamemode
    openrgb

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

echo "📦 Installing AUR packages with yay..."

AUR_PACKAGES=(
    papirus-folders
    openrazer-meta-git
    ttf-jetbrains-mono-nerd
    nautilus-open-any-terminal
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


echo "✅ All packages processed."

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

# Rebuild initramfs
echo "🛠 Rebuilding initramfs..."
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

# random stuff for papirus folder icons
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'

#set terminal for nautilus
gsettings set com.github.stunkymonkey.nautilus-open-any-terminal kitty

#random stuff for razer...
sudo gpasswd -a $USER plugdev

cp -r "$(pwd)/.config" "$HOME/"
cp -r "$(pwd)/.bashrc" "$HOME/"
echo "config files copied"

# Performance mode
echo 'governor="performance"' | sudo tee /etc/default/cpupower

echo "✅ Configuration complete."

# Guide:
echo "After reboot run these commands, for papirus"
echo "sudo chown -R $USER:$USER /var/lib/papirus-folders/"
echo "sudo chown -R $USER:$USER /usr/share/icons/Papirus*"

# Ask to reboot
read -p "🔁 Reboot now to apply changes? (y/N): " reboot_ans
case "$reboot_ans" in
    [Yy]*) echo "♻️ Rebooting..."; sudo reboot;;
    *) echo "❗ Reboot skipped. Please reboot manually later.";;
esac

