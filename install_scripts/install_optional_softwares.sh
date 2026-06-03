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
if [[ ! -d ~/.local/opt/gitkraken ]]; then
    # Get user
    USER=$(logname)

	echo " "
	echo "🔀 Installing latest GitKranker..."
    mkdir ~/.local/opt
	mkdir ~/.local/opt/gitkraken

	# Download the latest version
	curl -L https://release.gitkraken.com/linux/gitkraken-amd64.tar.gz -o /tmp/gitkraken.tar.gz

	# Extract
	tar -xzf /tmp/gitkraken.tar.gz -C ~/.local/opt/gitkraken --strip-components=1
	
	# Create desktop entry for wofi
	cat > ~/.local/share/applications/gitkraken.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=GitKraken
Exec=/home/$USER/.local/opt/gitkraken/gitkraken
Icon=/home/$USER/.local/opt/gitkraken/gitkraken.png
Terminal=false
Categories=Development;Git;
EOF

	chmod +x ~/.local/share/applications/gitkraken.desktop
	update-desktop-database ~/.local/share/applications/

	# Delete temp file
	rm /tmp/gitkraken.tar.gz

fi

#------------------------------------------------------------------------
# VLC darktheme and disable codec
sed -i -e 's|^[[:space:]]*#qt-dark-palette=0|qt-dark-palette=1|' "$HOME/.config/vlc/vlcrc"
sed -i -e 's|^[[:space:]]*#avcodec-hw=any|avcodec-hw=none|' "$HOME/.config/vlc/vlcrc"

#------------------------------------------------------------------------
echo "✅ Optional softwares installed."
echo ""