#!/bin/bash

set -euo pipefail

echo "🧼 Arch System Update & Cleanup"
echo "-------------------------------"

# Ask for sudo upfront
sudo -v

echo "🔄 Updating official packages..."
yay -Syu --noconfirm --answerdiff None --answerclean None

echo "🧹 Removing orphan packages..."
sudo pacman -Rns --noconfirm $(pacman -Qdtq) 2>/dev/null || echo "No orphans to remove."

echo "🗑️ Clearing pacman cache (keep 3 versions)..."
sudo paccache -r -k3

echo "🧽 Cleaning up yay cache..."
yay -Sc --noconfirm || true

if command -v flatpak &>/dev/null; then
    echo "🔃 Updating Flatpaks..."
    flatpak update -y
fi

echo "🧾 Trimming journal logs (keep 100MB)..."
sudo journalctl --vacuum-size=100M

echo "✅ All done!"

echo
read -p "Press Enter to close..."

pkill kitty