echo " "
echo "🖥️ Configurating desktop"
echo " "
echo "🚀 Downloading packages desktop enviroment"
PACKAGES=(
    # desktop
    sddm							# Display manager
    waybar
    hyprsunset
    swaync
    wofi

    # fonts
    ttf-dejavu
    ttf-liberation
    ttf-roboto
    noto-fonts-cjk

    # audio
    pipewire
    pipewire-alsa
    pipewire-audio
    pipewire-pulse
    lib32-libpipewire
    lib32-pipewire

    # softwares
    pavucontrol						# sound control
    ristretto 						# image viewer
    grim 							# screenshot
    slurp 							# screenshot
    gnome-disk-utility

    # misc
    libinput-tools 					# For wofi scripts to get devices
    xdg-desktop-portal-hyprland 	# allow screen sharing
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
# Get user
USER=$(logname)

if [ ! -f ~/.local/opt/zen/zen ]; then
	echo " "
	echo "📥 Installing latest Zen Browser..."
	mkdir -p ~/.local/opt/zen
	
	# Download the latest version
	curl -L https://github.com/zen-browser/desktop/releases/latest/download/zen.linux-x86_64.tar.xz -o /tmp/zen-latest.tar.xz

	# Extract
	tar xf /tmp/zen-latest.tar.xz -C ~/.local/opt/zen --strip-components=1

	# Create desktop entry for wofi
	cat > ~/.local/share/applications/zen.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Zen Browser
Exec=/home/$USER/.local/opt/zen/zen %U
Icon=/home/$USER/.local/opt/zen/browser/chrome/icons/default/default128.png
Terminal=false
Categories=Network;WebBrowser;
EOF

	chmod +x ~/.local/share/applications/zen.desktop
	update-desktop-database ~/.local/share/applications/
	
	# Delete temp file
	rm /tmp/zen-latest.tar.xz
fi

#------------------------------------------------------------------------
# add user to input group, needed to detect mouse inputs
sudo usermod -aG input $USER

#------------------------------------------------------------------------
# ufw settings
sudo ufw default deny incoming
sudo ufw default allow outgoing

#------------------------------------------------------------------------
echo "✅ Desktop configurations done."
echo ""