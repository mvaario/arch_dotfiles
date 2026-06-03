echo " "
echo "🟢 Configurating NVIDIA GPU"
GPU_INFO=$(lspci | grep -E "VGA|3D" | grep NVIDIA)

if [ -z "$GPU_INFO" ]; then
    echo "ERROR:🛑 No NVIDIA GPU detected!"
    exit 1
fi
echo " "
echo "🔧 Detected GPU: $GPU_INFO"

if echo "$GPU_INFO" | grep -Eiq "RTX 20|RTX 30|RTX 40|RTX 50"; then
    echo "🎮 Downloading modern NVIDIA Open drivers..."
    echo ""
    PACKAGES=(
      nvidia-open
      nvidia-utils
      lib32-nvidia-utils
      vulkan-icd-loader
      lib32-vulkan-icd-loader
      libva-nvidia-driver
      nvidia-settings
      egl-wayland
    )

elif echo "$GPU_INFO" | grep -Eiq "GTX 10"; then
    echo "🎮 Downloading Pascal legacy drivers..."
    echo ""
    PACKAGES=(
		nvidia-settings
		egl-wayland
		vulkan-icd-loader
		lib32-vulkan-icd-loader
		libva-nvidia-driver
    )

    AUR_PACKAGES=(
        nvidia-580xx-dkms
        nvidia-580xx-utils
        lib32-nvidia-580xx-utils
    )

else
    echo "🛑 Unsupported or unknown NVIDIA GPU generation."
    echo "$GPU_INFO"
    exit 1
fi

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
echo ""

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
echo ""

#------------------------------------------------------------------------
# Create or update modprobe config
echo "💾 Writing /etc/modprobe.d/nvidia.conf..."
if ! grep -q '^options nvidia_drm modeset=1$' /etc/modprobe.d/nvidia.conf 2>/dev/null; then
    echo "options nvidia_drm modeset=1" | sudo tee /etc/modprobe.d/nvidia.conf > /dev/null
else
    echo "☑️ nvidia_drm modeset already enabled"
fi
echo ""

#------------------------------------------------------------------------
# Modify mkinitcpio.conf
echo "🧩 Updating /etc/mkinitcpio.conf..."
if ! grep -q 'MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)' /etc/mkinitcpio.conf; then
    if grep -q '^MODULES=' /etc/mkinitcpio.conf; then
        sudo sed -i 's/^MODULES=.*/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
    else
        echo "MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)" | sudo tee -a /etc/mkinitcpio.conf
    fi
else
    echo "☑️ Nvidia Modules already done"
fi
echo ""

#------------------------------------------------------------------------
# Update /etc/environment
echo "🌱 Adding NVIDIA environment variables to /etc/environment..."
if ! grep -q 'LIBVA_DRIVER_NAME=nvidia' /etc/environment; then
  sudo tee -a /etc/environment > /dev/null <<EOF
# NVIDIA Wayland / VA-API support
LIBVA_DRIVER_NAME=nvidia
__GLX_VENDOR_LIBRARY_NAME=nvidia
EOF
else
    echo "☑️ Enviroment variables already done"
fi
echo ""

#------------------------------------------------------------------------
echo "✅ NVIDIA configurations done."
echo ""