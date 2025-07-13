#!/bin/bash

echo "Stopping display manager..."
sudo systemctl stop display-manager

echo "Uninstalling NVIDIA drivers and related packages..."
sudo pacman -Rcns --noconfirm nvidia nvidia-utils nvidia-settings lib32-nvidia-utils vulkan-icd-loader lib32-vulkan-icd-loader vulkan-tools

echo "Removing leftover config files and kernel modules..."
sudo rm -f /etc/modprobe.d/nvidia.conf
sudo rm -f /etc/X11/xorg.conf.d/90-nvidia.conf
sudo rm -f /usr/share/X11/xorg.conf.d/10-nvidia.conf
sudo rm -rf /lib/modules/$(uname -r)/kernel/drivers/video/nvidia*

#---------------------------#

echo "Stopping any running Wine processes..."
wineserver -k

echo "Uninstalling Wine packages..."
sudo pacman -Rcns --noconfirm wine wine-staging wine-ge wine-mono wine-multimedia wine-ge-custom wine-ge-staging wine-tkg

echo "Removing 32-bit Wine libraries (if installed)..."
sudo pacman -Rcns --noconfirm lib32-wine lib32-wine-mono

echo "Removing Wine prefixes and config folders..."
rm -rf ~/.wine
rm -rf ~/.local/share/applications/wine
rm -rf ~/.local/share/wine
rm -rf ~/.cache/wine
rm -rf ~/.config/wine

echo "Removing system-wide Wine config (if exists)..."
sudo rm -rf /etc/wine
sudo rm -rf /usr/share/wine

echo "Done. Wine and all associated files removed."

#---------------------------#

echo "Updating system and reinstalling NVIDIA drivers..."
sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm nvidia nvidia-utils nvidia-settings lib32-nvidia-utils vulkan-icd-loader lib32-vulkan-icd-loader vulkan-tools

echo "Rebuilding initramfs..."
sudo mkinitcpio -P

echo "Starting display manager..."
sudo systemctl start display-manager

echo "Done! Reboot recommended."
