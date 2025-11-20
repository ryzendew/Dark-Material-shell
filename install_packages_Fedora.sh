#!/bin/bash

# Fedora Package Installation Script
# Generated from terminal history
# Excludes Cider-related packages

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting Fedora package installation...${NC}\n"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run as root or with sudo${NC}"
    exit 1
fi

# Update system first
echo -e "${YELLOW}Updating system...${NC}"
dnf update -y

# Enable RPM Fusion repositories
echo -e "\n${YELLOW}Enabling RPM Fusion repositories...${NC}"
dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Enable COPR repositories
echo -e "\n${YELLOW}Enabling COPR repositories...${NC}"
dnf copr enable -y solopasha/hyprland
dnf copr enable -y errornointernet/quickshell
dnf copr enable -y bieszczaders/kernel-cachyos
dnf copr enable -y bieszczaders/kernel-cachyos-addons

# Update package cache after adding repositories
echo -e "\n${YELLOW}Updating package cache...${NC}"
dnf makecache

# NVIDIA drivers (optional - uncomment if needed)
# echo -e "\n${YELLOW}Installing NVIDIA drivers...${NC}"
# dnf install -y akmod-nvidia
# dnf install -y xorg-x11-drv-nvidia-cuda  # Optional for cuda/nvdec/nvenc support

# Development tools and dependencies
echo -e "\n${YELLOW}Installing development tools and dependencies...${NC}"
dnf install -y \
    rust cargo \
    gcc gcc-c++ pkg-config \
    openssl-devel \
    libX11-devel libXcursor-devel libXrandr-devel libXi-devel \
    mesa-libGL-devel \
    fontconfig-devel freetype-devel expat-devel \
    dnf rpm polkit zenity curl unzip fontconfig \
    cairo-gobject cairo-gobject-devel \
    rust-gdk4-sys+default-devel \
    gtk4-layer-shell-devel \
    qt5-qtgraphicaleffects \
    qt6-qt5compat \
    python3-pyqt6 \
    python3.11 python3.11-libs \
    libxcrypt-compat libcurl libcurl-devel apr fuse-libs

# Desktop environment and window manager
echo -e "\n${YELLOW}Installing desktop environment components...${NC}"
dnf install -y \
    hyprland \
    hyprpicker \
    swww \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-wlr \
    xdg-desktop-portal-gnome \
    hyprpolkitagent \
    gnome-keyring

# CachyOS kernel (optional)
# echo -e "\n${YELLOW}Installing CachyOS kernel...${NC}"
# dnf install -y kernel-cachyos kernel-cachyos-devel-matched
# dnf install -y cachyos-settings --allowerasing

# System utilities
echo -e "\n${YELLOW}Installing system utilities...${NC}"
dnf install -y \
    brightnessctl \
    cliphist \
    easyeffects \
    fuzzel \
    gnome-system-monitor \
    gnome-text-editor \
    grim \
    nautilus \
    pavucontrol \
    ptyxis \
    slurp \
    swappy \
    tesseract \
    wl-clipboard \
    wlogout \
    yad \
    btop \
    lm_sensors \
    fuse2 \
    fuse fuse-libs \
    gedit

# Applications
echo -e "\n${YELLOW}Installing applications...${NC}"
dnf install -y \
    firefox \
    obs-studio \
    steam lutris mangohud gamescope

# GUI tools
echo -e "\n${YELLOW}Installing GUI tools...${NC}"
dnf install -y \
    qt6ct \
    nwg-look

# Quickshell
echo -e "\n${YELLOW}Installing Quickshell...${NC}"
dnf install -y quickshell-git

echo -e "\n${GREEN}Installation complete!${NC}"
echo -e "${YELLOW}Note: You may need to reboot if you installed NVIDIA drivers or kernel packages.${NC}"

