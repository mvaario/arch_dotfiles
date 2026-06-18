echo " "
echo "🖧 Configurating server"
BASE_DIR="$1"

echo " "
echo "🚀 Downloading server packages"
PACKAGES=(
    kitty-terminfo  # terminal command

    openssh         # ssh access
    ethtool         # wake-on-lan
    iperf3          # speed test

    jellyfin-server # media server
    jellyfin-web    # web UI
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
echo "🧰 Applying server configuration"
echo " "

# copy server spesific configs
cp -r "$BASE_DIR/config_server/." "$HOME/.config/"

# enable ssh
sudo systemctl enable sshd

# enable jellyfin
sudo systemctl enable jellyfin

#------------------------------------------------------------------------
echo "🛡️ Allowing ssh and jellyfish 🌐"
sudo ufw default deny outgoing > /dev/null
sudo ufw default deny incoming > /dev/null
sudo ufw allow from 192.168.1.0/24 to any port 22 proto tcp     # allow SSH LAN
sudo ufw allow from 192.168.1.0/24 to any port 8096 proto tcp   # allow jellyfis LAN

sudo ufw allow from 10.8.0.0/24 to any port 22 proto tcp        # allow SSH outside LAN
sudo ufw allow from 10.8.0.0/24 to any port 8096 proto tcp      # allow jellyfish outside LAN

echo ""
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
echo "✅ Server configurations done."
echo ""
