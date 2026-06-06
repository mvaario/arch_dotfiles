echo " "
echo "🎮 Downloading optional softwares..."
PACKAGES=(
    lact                        # GPU overclocking
    steam
    discord
    lutris
    gamemode   
    openrgb                     # RGB control
    
    moonlight-qt                # Remote connection to server
    wakeonlan                   # Allow to start server remotetly

    pycharm-community-edition

    vlc
    vlc-plugin-x264
    vlc-plugin-mpeg2
    vlc-plugin-mad
    vlc-plugin-ffmpeg
    
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


AUR_PACKAGES=(
	xone-dkms-git 			# xbox controller
	xone-dongle-firmware    # xbox controller
    gitkraken               # Git client
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
# Check latest Proton-GE version
latest=$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | jq -r '.tag_name')

# Check installed Proton-GE version
installed=$(find ~/.steam/root/compatibilitytools.d \
    -maxdepth 1 \
    -type d \
    -name "GE-Proton*" \
    -printf '%f\n' 2>/dev/null \
    | sort -V \
    | tail -n1)

if [[ "$latest" != "$installed" ]]; then
    echo " "
    echo "🔀 Installing latest Proton-GE"
    mkdir -p "$HOME/.steam/steam/compatibilitytools.d"

    # Download latest version
    latest_url=$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest \
    | grep browser_download_url \
    | grep '\.tar\.gz"' \
    | cut -d '"' -f 4)

    curl -L "$latest_url" -o /tmp/proton-ge.tar.gz

    # Extract
    tar -xzf /tmp/proton-ge.tar.gz -C "$HOME/.steam/steam/compatibilitytools.d"

    # Delete temp file
	rm /tmp/proton-ge.tar.gz
fi

#------------------------------------------------------------------------
echo "✅ Optional softwares installed."
echo ""