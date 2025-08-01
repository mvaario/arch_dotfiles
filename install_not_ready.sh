#!/bin/bash
set -e

# Edit these if nvidia or razer is used
nvidia=false
razer=false

#------------------------------------------------------------------------
# Ask for sudo password upfront
if ! sudo -v; then
  echo "❌ This script requires sudo privileges."
  exit 1
fi

# Keep sudo alive in the background
(
  while true; do
    sleep 30
    sudo -n true
    kill -0 "$$" || exit
  done
) 2>/dev/null &

#------------------------------------------------------------------------
echo " "
echo "🔧 Enabling [multilib] repo in /etc/pacman.conf..."
sudo awk '
BEGIN { in_multilib = 0 }
/^#\s*\[multilib\]/ { print substr($0, 2); in_multilib = 1; next }
/^\s*\[multilib\]/ { print; in_multilib = 1; next }
in_multilib && /^\s*#/ && /Include\s*=\s*\/etc\/pacman.d\/mirrorlist/ {
    # uncomment line by removing leading #
    sub(/^#/, "")
    print
    next
}
in_multilib && /^\s*\[/ { in_multilib = 0 }
{ print }
' /etc/pacman.conf | sudo tee /etc/pacman.conf.tmp > /dev/null
sudo mv /etc/pacman.conf.tmp /etc/pacman.conf

#------------------------------------------------------------------------
echo " "
echo "🔄 Updating system"
sudo pacman -Syu

if ! command -v yay &> /dev/null; then
    echo "📥 Installing yay AUR helper..."
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd -
fi

#------------------------------------------------------------------------
echo " "
echo "🚀 Downloading packages..."
PACKAGES=(
    git
    neovim
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
    gnome-disk-utility
    celluloid
    steam
    discord
    lutris
    gamemode
    openrgb

	mousepad
	meld

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

#------------------------------------------------------------------------
echo " "
echo "📦 Downloading AUR packages..."

AUR_PACKAGES=(
	wlogout
    papirus-folders
    ttf-jetbrains-mono-nerd
    nautilus-open-any-terminal
    catppuccin-cursors-mocha
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

#------------------------------------------------------------------------
# Setup nvidia
if $nvidia; then
	scripts/nvidia.sh
fi

# Setup razer
if $razer; then
	scripts/razer.sh
fi

#------------------------------------------------------------------------
# Get user
USER=$(logname)

if [ ! -f ~/.local/opt/zen/zen ]; then
	echo " "
	echo "📥 Installing latest Zen Browser..."
	mkdir -p ~/.local/opt/zen
	mkdir -p ~/.local/share/applications

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
if [ ! -f ~/.local/opt/gitkraken/gitkraken ]; then
	echo " "
	echo "📥 Installing latest GitKranker..."
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
if [ ! -d "$HOME/.themes/Orchis-Dark-Nord" ]; then
	echo " "
	echo "📥 Installing Orchis theme..."
    git clone https://github.com/vinceliuice/Orchis-theme.git /tmp/Orchis-theme
	cd /tmp/Orchis-theme
	./install.sh -d ~/.themes -t all -c dark -s standard --tweaks nord
	cd -
	rm -rf /tmp/Orchis-theme
fi

echo "✅ All packages installed."
echo " "

#------------------------------------------------------------------------
# Update HOOKS line
if grep -q '^HOOKS=' /etc/mkinitcpio.conf; then
  sudo sed -i 's/^HOOKS=.*/HOOKS=(base autodetect udev microcode block filesystems keyboard)/' /etc/mkinitcpio.conf
else
  echo 'HOOKS=(base autodetect udev microcode block filesystems keyboard)' | sudo tee -a /etc/mkinitcpio.conf
fi

# Set COMPRESSION="cat"
if grep -q '^COMPRESSION=' /etc/mkinitcpio.conf; then
  sudo sed -i 's/^COMPRESSION=.*/COMPRESSION="cat"/' /etc/mkinitcpio.conf
else
  echo 'COMPRESSION="cat"' | sudo tee -a /etc/mkinitcpio.conf
fi

# Rebuild initramfs
echo " "
echo "🛠️ Rebuilding initramfs..."
sudo mkinitcpio -P

#------------------------------------------------------------------------
echo " "
echo "🧰 Applying configuration settings"

# copy config files
cp -r "$(pwd)/.config" "$HOME/"
cp -r "$(pwd)/.bashrc" "$HOME/"

# Enable ufw
sudo systemctl enable ufw

# random stuff for papirus folder icons
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'

# Set terminal for nautilus
gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal kitty

# Performance mode
echo 'governor="performance"' | sudo tee /etc/default/cpupower

# enable theme
~/.config/scripts/apply_theme.sh earthsong.sh

# Add permissions
sudo chown -R $USER:$USER /var/lib/papirus-folders/
sudo chown -R $USER:$USER /usr/share/icons/Papirus*

# Autolog in file
if [ ! -d "/etc/systemd/system/getty@tty1.service.d" ]; then
    echo "Creating directory for systemd override: /etc/systemd/system/getty@tty1.service.d"
    sudo mkdir -p "/etc/systemd/system/getty@tty1.service.d"
fi

echo "[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin $USER --noclear %I xterm-kitty" | sudo tee "/etc/systemd/system/getty@tty1.service.d/override.conf" > /dev/null

# Link nautilus compare using meld
mkdir -p "$HOME/.local/share/nautilus/scripts"
[ -e "$HOME/.local/share/nautilus/scripts/Compare with Meld" ] || \
ln -s "$HOME/.config/scripts/nautilus_compare.sh" "$HOME/.local/share/nautilus/scripts/Compare with Meld"

# set mousepad theme
export DISPLAY=:0
export XDG_RUNTIME_DIR="/run/user/$(id -u)"

sudo -u "$USER" DISPLAY=:0 XDG_RUNTIME_DIR="/run/user/$(id -u $USER)" gsettings set org.xfce.mousepad.preferences.view color-scheme 'oblivion'
sudo -u "$USER" DISPLAY=:0 XDG_RUNTIME_DIR="/run/user/$(id -u $USER)" gsettings set org.xfce.mousepad.preferences.view tab-width 4
sudo -u "$USER" DISPLAY=:0 XDG_RUNTIME_DIR="/run/user/$(id -u $USER)" gsettings set org.xfce.mousepad.preferences.view font-name 'JetBrainsMonoNL Nerd Font Mono 10'
sudo -u "$USER" DISPLAY=:0 XDG_RUNTIME_DIR="/run/user/$(id -u $USER)" gsettings set org.xfce.mousepad.preferences.view show-line-numbers true
sudo -u "$USER" DISPLAY=:0 XDG_RUNTIME_DIR="/run/user/$(id -u $USER)" gsettings set org.xfce.mousepad.preferences.window always-show-tabs true

echo "✅ Configuration complete."
echo ""

#------------------------------------------------------------------------
# Ask to reboot
read -p "🔁 Reboot now to apply changes? (y/N): " reboot_ans
case "$reboot_ans" in
    [Yy]*) echo "♻️ Rebooting..."; sudo reboot;;
    *) echo "❗ Reboot skipped. Please reboot manually later.";;
esac













