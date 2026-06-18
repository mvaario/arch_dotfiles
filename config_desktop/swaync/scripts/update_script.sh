#!/bin/bash
set -euo pipefail

echo "🧼 Arch System Update & Cleanup"
echo "-------------------------------"

# Ask for sudo upfront
sudo -v

echo ""
echo "🔄 Updating official packages..."
sudo pacman -Syu --noconfirm

echo ""
echo "🔄 Updating AUR packages..."
#yay -Sua --noconfirm --answerdiff None --answerclean None

if command -v flatpak &>/dev/null; then
    echo "🔃 Updating Flatpaks..."
    flatpak update -y
fi

#------------------------------------------------------------------------
# Check latest Proton-GE version
latest=$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | jq -r '.tag_name')

# Check installed Proton-GE version
installed=$(find $HOME/.steam/steam/compatibilitytools.d \
    -maxdepth 1 \
    -type d \
    -name "GE-Proton*" \
    -printf '%f\n' 2>/dev/null \
    | sort -V \
    | tail -n1)

if [[ "$latest" != "$installed" && -n "$installed" ]]; then
    echo ""
    echo "🔄 Downloading latest $latest"

    # Download latest version
    latest_url=$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest \
    | grep browser_download_url \
    | grep '\.tar\.gz"' \
    | cut -d '"' -f 4)

    curl -L "$latest_url" -o /tmp/proton-ge.tar.gz

    # Extract
    tar -xzf /tmp/proton-ge.tar.gz -C "$HOME/.steam/steam/compatibilitytools.d"

    # Delete temp file
	rm /tmp/proton-ge.tar.gz
fi
#------------------------------------------------------------------------

echo ""
echo "🧹 Removing orphan packages..."
sudo pacman -Rns --noconfirm $(pacman -Qdtq) 2>/dev/null || echo "No orphans to remove."

echo ""
echo "🗑️ Clearing pacman cache (keep 3 versions)..."
sudo paccache -r -k3

echo ""
echo "🧽 Cleaning up yay cache..."
yay -Yc --noconfirm

echo ""
echo "🧾 Trimming journal logs (keep 100MB)..."
sudo journalctl --vacuum-size=100M

echo ""
echo "✅ All done!"

echo
read -p "Press Enter to close..."

exit