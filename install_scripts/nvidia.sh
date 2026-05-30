echo " "
echo "🚀 Downloading nvidia packages..."
GPU_INFO=$(lspci | grep -E "VGA|3D" | grep NVIDIA)

if [ -z "$GPU_INFO" ]; then
    echo "ERROR: No NVIDIA GPU detected!"
    exit 1
fi
echo " "
echo "Detected GPU: $GPU_INFO"

if echo "$GPU_INFO" | grep -Eiq "RTX 20|RTX 30|RTX 40|RTX 50"; then
    echo "Installing modern NVIDIA Open drivers..."
    PACKAGES=(
      nvidia-open \
      nvidia-utils \
      lib32-nvidia-utils \
      vulkan-icd-loader \
      lib32-vulkan-icd-loader \
      libva-nvidia-driver \
      nvidia-settings \
      egl-wayland
    )

elif echo "$GPU_INFO" | grep -Eiq "GTX 10"; then
    echo "Installing Pascal legacy drivers..."
    PACKAGES=(
      vulkan-icd-loader \
      lib32-vulkan-icd-loader \
      libva-nvidia-driver \
      nvidia-settings \
      egl-wayland
    )

    AUR_PACKAGES=(
        nvidia-570xx-dkms
        nvidia-570xx-utils
        lib32-nvidia-570xx-utils
    )

else
    echo "Unsupported or unknown NVIDIA GPU generation."
fi

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


# Update /etc/environment
echo "🌱 Adding environment variables to /etc/environment..."
if ! grep -q 'LIBVA_DRIVER_NAME=nvidia' /etc/environment; then
  sudo tee -a /etc/environment > /dev/null <<EOF

# NVIDIA Wayland / VA-API support
LIBVA_DRIVER_NAME=nvidia
__GLX_VENDOR_LIBRARY_NAME=nvidia
EOF
fi