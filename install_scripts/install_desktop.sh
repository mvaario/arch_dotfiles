echo " "
echo "🖥️ Configurating desktop"
echo " "
echo "🚀 Downloading packages desktop enviroment"

BASE_DIR="$1"
PACKAGES=(
    # hyprland
    hyprpolkitagent
	hyprland                        # Window manager
	hyprpaper                       # Wallpaper
    hyprsunset                      # Night light
    kitty                           # Terminal
    waybar                          # bar                           
	nautilus                        # file manager
    swaync                          # notification center
    wofi                            # app launcher
    papirus-icon-theme

    # sddm
    sddm							# Display manager
    qt5-graphicaleffects            # Blur effect on sddm

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
    code
	mousepad						# easy notepad
    pavucontrol						# sound control
    ristretto 						# image viewer
    grim 							# screenshot
    slurp 							# screenshot
    gnome-disk-utility

    # misc
    libinput-tools 					# For wofi scripts to get devices
    xdg-desktop-portal-hyprland 	# allow screen sharing
    meld							# mousepad compare
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
echo " "
echo "📦 Downloading essential AUR packages"
echo "Skipping for couple days"
AUR_PACKAGES=(
	#papirus-folders
	#nautilus-open-any-terminal
	#catppuccin-cursors-mocha
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
# copy config files
echo "Copying desktop config files"
cp -r "$BASE_DIR/config_desktop/." "$HOME/.config/"

#------------------------------------------------------------------------
if [ ! -d "$HOME/.themes/Orchis-Dark-Nord" ]; then
	echo " "
	echo "📥 Installing Orchis theme..."
    git clone https://github.com/vinceliuice/Orchis-theme.git /tmp/Orchis-theme
	cd /tmp/Orchis-theme
	./install.sh -d ~/.themes -t all -c dark -s standard --tweaks nord
	cd -
	rm -rf /tmp/Orchis-theme
fi

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
# Copy icons to .icons folder. Used to make custom icons work without permission issues
echo ""
echo "✨ Copying icons"
mkdir -p $HOME/.icons/Papirus-Dark
cp -a /usr/share/icons/Papirus-Dark $HOME/.icons/Papirus-Dark
find "$HOME/.icons/Papirus-Dark" -type l -exec rm -v {} + > /dev/null
cp -an /usr/share/icons/Papirus/* $HOME/.icons/Papirus-Dark
cp -r "$BASE_DIR/Icons" "$HOME/.icons/Icons"
echo ""

# Enable Papirus-Dark
echo "🎨 Enabling icon theme"
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
echo ""

# Set terminal for nautilus
echo "📟 Enabling open-any-terminal"
gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal kitty
echo ""

#------------------------------------------------------------------------
# Link nautilus compare using meld
echo "🗂️ Creating nautilus compare with Meld"
if [ -d "$HOME/.local/share/nautilus/scripts" ]; then
	rm -rf $HOME/.local/share/nautilus/scripts
fi
mkdir -p "$HOME/.local/share/nautilus/scripts"
[ -e "$HOME/.local/share/nautilus/scripts/Compare with Meld" ] || \
ln -s "$HOME/.config/nautilus/scripts/nautilus_compare.sh" "$HOME/.local/share/nautilus/scripts/Compare with Meld"
echo ""

#------------------------------------------------------------------------
echo ""
echo "🖥️ Configurating monitors"
# detect connected monitors
mapfile -t monitors < <(
    for m in /sys/class/drm/*/status; do
        [[ $(<"$m") == "connected" ]] &&
        basename "$(dirname "$m")" | sed 's/^card[0-9]-//'
    done
)

primary="${monitors[0]}"
secondary="${monitors[1]}"
# replace first placeholder (required)
sed -i "s/\bDP-1\b/$primary/g" "$HOME/.config/hypr/hyprland.conf"
sed -i "s/\bDP-1\b/$primary/g" "$HOME/.config/themes/templates/hyprpaper.template.conf"
sed -i "s/\bDP-1\b/$primary/g" "$HOME/.config/hypr/conf/autostart.conf"
sed -i "s/\bDP-1\b/$primary/g" "$HOME/.config/hypr/conf/keyboard.conf"
sed -i "s/\bDP-1\b/$primary/g" "$HOME/.config/waybar/config.jsonc"

if [[ -n "$secondary" ]]; then
    # replace second placeholder
    sed -i "s/\bDP-3\b/$secondary/g" "$HOME/.config/hypr/hyprland.conf"
	sed -i "s/\bDP-3\b/$secondary/g" "$HOME/.config/themes/templates/hyprpaper.template.conf"
	sed -i "s/\bDP-3\b/$secondary/g" "$HOME/.config/waybar/config.jsonc"
else
    # remove all lines containing DP-3
    sed -i '/DP-3/d' "$HOME/.config/hypr/hyprland.conf"
	sed -i '/DP-3/d' "$HOME/.config/waybar/config.jsonc"
fi

#------------------------------------------------------------------------
# set mousepad theme
echo "📋 Setting mousepad theme"
export DISPLAY=:0
export XDG_RUNTIME_DIR="/run/user/$(id -u)"

sudo -u "$USER" DISPLAY=:0 XDG_RUNTIME_DIR="/run/user/$(id -u $USER)" gsettings set org.xfce.mousepad.preferences.view color-scheme 'oblivion'
sudo -u "$USER" DISPLAY=:0 XDG_RUNTIME_DIR="/run/user/$(id -u $USER)" gsettings set org.xfce.mousepad.preferences.view tab-width 4
sudo -u "$USER" DISPLAY=:0 XDG_RUNTIME_DIR="/run/user/$(id -u $USER)" gsettings set org.xfce.mousepad.preferences.view font-name 'JetBrainsMonoNL Nerd Font Mono 10'
sudo -u "$USER" DISPLAY=:0 XDG_RUNTIME_DIR="/run/user/$(id -u $USER)" gsettings set org.xfce.mousepad.preferences.view show-line-numbers true
sudo -u "$USER" DISPLAY=:0 XDG_RUNTIME_DIR="/run/user/$(id -u $USER)" gsettings set org.xfce.mousepad.preferences.window always-show-tabs true



#------------------------------------------------------------------------
echo "✅ Desktop configurations done."
echo ""