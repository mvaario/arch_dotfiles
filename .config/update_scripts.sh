#!/bin/bash

set -euo pipefail

echo "🧼 Arch System Update & Cleanup"
echo "-------------------------------"

# Ask for sudo upfront
sudo -v

echo "🔄 Updating official packages..."
sudo pacman -Syu

if command -v yay &>/dev/null; then
    echo "🔁 Updating AUR packages..."
    yay -Sua --noconfirm
fi

echo "🧹 Removing orphan packages..."
sudo pacman -Rns $(pacman -Qdtq) || echo "No orphans to remove."

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
