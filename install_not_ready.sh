#!/bin/bash
set -e

if ! sudo -v; then
  echo "❌ This script requires sudo privileges."
  exit 1
fi

echo "🚀 Starting Arch setup script..."

sudo pacman -Syu

PACKAGES=(
    git
    neovim
    firefox
    code
    hyprpolkitagent
    ufw
    
    pipewire
    pavucontrol
    
    nvidia
    libva-nvidia-driver
    nvidia-utils
    vulkan-icd-loader
    lib32-nvidia-utils
    lib32-vulkan-icd-loader
    nvidia-settings  

    kitty
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
    gnome-disk-utils
    celluloid
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

echo "✅ Configuration complete."

# Ask to reboot
read -p "🔁 Reboot now to apply changes? (y/N): " reboot_ans
case "$reboot_ans" in
    [Yy]*) echo "♻️ Rebooting..."; sudo reboot;;
    *) echo "❗ Reboot skipped. Please reboot manually later.";;
esac

