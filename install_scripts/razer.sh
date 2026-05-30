echo " "
echo "📦 Downloading razer packages..."

#AUR_PACKAGES=(
#    openrazer-meta-git
#)

#for aur_pkg in "${AUR_PACKAGES[@]}"; do
#    echo "📥 Installing $aur_pkg from AUR..."
#    if ! yay -S --noconfirm --needed "$aur_pkg"; then
#        echo "❌ Failed to install: $aur_pkg"
#        read -p "⚠️  Continue anyway? (y/N): " yn
#        case "$yn" in
#            [Yy]*) echo "⏩ Continuing...";;
#            *) echo "🛑 Exiting script."; exit 1;;
#        esac
#	fi
#done

PACKAGES=(
    openrazer-daemon 
    python-openrazer 
    openrazer-driver-dkms
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


# Get user
USER=$(logname)

# Random stuff for razer...
sudo gpasswd -a $USER openrazer
#sudo gpasswd -a $USER plugdev