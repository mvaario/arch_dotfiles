echo " "
echo "🖥️ Configurating desktop"
echo " "
echo "🚀 Downloading packages desktop enviroment"

BASE_DIR="$1"
PACKAGES=(
    # desktop
    sddm							# Display manager
    qt5-graphicaleffects            # Blur effect on sddm
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
# configure sddm theme file
sudo mkdir -p /usr/share/sddm/themes/Arch_sddm/backgrounds
sudo chown -R $USER:$USER /usr/share/sddm/themes/Arch_sddm
cp -r "$BASE_DIR/Arch_sddm" "/usr/share/sddm/themes/"
if [ ! -f /etc/sddm.conf.d/theme.conf ]; then
    sudo mkdir -p /etc/sddm.conf.d
    echo "[Theme] 
Current=Arch_sddm" | sudo tee /etc/sddm.conf.d/theme.conf > /dev/null
else
    sudo sed -i -e 's|^Current=.*|Current=Arch_sddm|' "/etc/sddm.conf.d/theme.conf"
fi

sudo systemctl enable sddm.service

#------------------------------------------------------------------------
# ufw settings
sudo ufw default deny incoming
sudo ufw default allow outgoing

#------------------------------------------------------------------------
echo "✅ Desktop configurations done."
echo ""