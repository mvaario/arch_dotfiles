echo " "
echo "🖧 Configurating server"
BASE_DIR="$1"

echo " "
echo "🚀 Downloading server packages"
PACKAGES=(
    openssh
    ethtool
    iperf3
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
echo "📦 Downloading server AUR packages"

AUR_PACKAGES=(
    sunshine
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
echo " "
echo "🧰 Applying server configuration"
echo " "

# copy server spesific configs
cp -r "$BASE_DIR/config_server/." "$HOME/.config/"

#------------------------------------------------------------------------
echo "Enabling Wake-on_LAN 🌐"
INTERFACE=$(ip route | awk '/default/ {print $5; exit}')

if [ -z "$INTERFACE" ]; then
    echo "ERROR:🛑 No active network interface detected. Skipping"
    echo ""
else
  echo "Detected network interface: $INTERFACE"

cat <<EOF | sudo tee /etc/systemd/system/wol.service > /dev/null
[Unit]
Description=Enable Wake-on-LAN

[Service]
Type=oneshot
ExecStart=/usr/bin/ethtool -s $INTERFACE wol g

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable wol.service

echo "🌐 Wake-on-LAN enabled"
echo ""
fi

#------------------------------------------------------------------------
# Enable speed test
echo "Enabling speedtest 📡"
if [ -f /etc/systemd/system/iperf3.service ]; then
cat <<EOF | sudo tee /etc/systemd/system/iperf3.service > /dev/null
[Unit]
Description=iPerf3 bandwidth measurement daemon
After=network.target

[Service]
ExecStart=/usr/bin/iperf3 -s
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable iperf3.service

echo "📡 Speed test enabled"
else
  echo "🛑 Enabling speedtest failed"
fi
echo ""

#------------------------------------------------------------------------
# Autolog in file
echo "🛡️ Enabling autolog in"
if [ ! -d "/etc/systemd/system/getty@tty1.service.d" ]; then
    echo "Creating directory for systemd override: /etc/systemd/system/getty@tty1.service.d"
    sudo mkdir -p "/etc/systemd/system/getty@tty1.service.d"
fi

echo "[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin $USER --noclear %I xterm-kitty" | sudo tee "/etc/systemd/system/getty@tty1.service.d/override.conf" > /dev/null
echo ""

#------------------------------------------------------------------------
# Auto start hyprland
echo "🖥️ Enabling Hyprland auto-start"
if ! grep -q "exec start-hyprland" ~/.bash_profile 2>/dev/null; then
cat << 'EOF' >> ~/.bash_profile
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec start-hyprland
fi
EOF
fi
echo ""
#------------------------------------------------------------------------
echo "✅ Server configurations done."
echo ""
