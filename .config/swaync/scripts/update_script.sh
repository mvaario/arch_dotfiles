#!/bin/bash

set -euo pipefail

echo "🧼 Arch System Update & Cleanup"
echo "-------------------------------"

# Ask for sudo upfront
sudo -v

# Allow internet
#sudo ufw default allow outgoing

echo ""
echo "🔄 Updating official packages..."
sudo pacman -Syu --noconfirm

echo ""
echo "🔄 Updating AUR packages..."
yay -Sua --noconfirm --answerdiff None --answerclean None

echo ""
echo "🧹 Removing orphan packages..."
sudo pacman -Rns --noconfirm $(pacman -Qdtq) 2>/dev/null || echo "No orphans to remove."

echo ""
echo "🗑️ Clearing pacman cache (keep 3 versions)..."
sudo paccache -r -k3

echo ""
echo "🧽 Cleaning up yay cache..."
yay -Sc --noconfirm || true

if command -v flatpak &>/dev/null; then
    echo "🔃 Updating Flatpaks..."
    flatpak update -y
fi

echo ""
echo "🧾 Trimming journal logs (keep 100MB)..."
sudo journalctl --vacuum-size=100M

# Block internet only for server
#sudo ufw default deny outgoing

echo ""
echo "✅ All done!"

echo
read -p "Press Enter to close..."

exit