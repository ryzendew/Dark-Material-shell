#!/bin/bash

# Arch Linux Package Installation Script
# Checks for dependencies and installs missing packages
# Also installs yay, AUR packages, fonts, and Python dependencies

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting Arch Linux package installation...${NC}\n"

# Check if running as root for pacman operations
if [ "$EUID" -eq 0 ]; then 
    echo -e "${RED}Please run as regular user (not root). Sudo will be used when needed.${NC}"
    exit 1
fi

# Function to check if a package is installed
check_package() {
    pacman -Qi "$1" &>/dev/null
}

# Function to check if a command exists
check_command() {
    command -v "$1" &>/dev/null
}

# Update system first
echo -e "${YELLOW}Updating system...${NC}"
sudo pacman -Syu --noconfirm

# Official repository packages
echo -e "\n${YELLOW}Checking official repository packages...${NC}"
OFFICIAL_PACKAGES=(
    brightnessctl
    cliphist
    easyeffects
    firefox
    fuzzel
    gedit
    gnome-disks
    grim
    hyprland
    mission-center
    nautilus
    nwg-look
    pavucontrol
    polkit
    polkit-gnome
    mate-polkit
    ptyxis
    qt6ct
    slurp
    swappy
    tesseract
    wl-clipboard
    wlogout
    xdg-desktop-portal-hyprland
    yad
)

MISSING_PACKAGES=()
for package in "${OFFICIAL_PACKAGES[@]}"; do
    if ! check_package "$package"; then
        MISSING_PACKAGES+=("$package")
        echo -e "${BLUE}  Missing: $package${NC}"
    else
        echo -e "${GREEN}  Installed: $package${NC}"
    fi
done

if [ ${#MISSING_PACKAGES[@]} -gt 0 ]; then
    echo -e "\n${YELLOW}Installing missing packages...${NC}"
    sudo pacman -S --needed --noconfirm "${MISSING_PACKAGES[@]}"
else
    echo -e "\n${GREEN}All official packages are already installed!${NC}"
fi

# Check for yay
echo -e "\n${YELLOW}Checking for yay...${NC}"
if ! check_command yay; then
    echo -e "${BLUE}yay not found. Installing yay...${NC}"
    sudo pacman -S --needed --noconfirm git base-devel
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay && makepkg -si --noconfirm
    cd .. && rm -rf yay
    cd ~
    echo -e "${GREEN}yay installed successfully!${NC}"
else
    echo -e "${GREEN}yay is already installed!${NC}"
fi

# AUR packages
echo -e "\n${YELLOW}Checking AUR packages...${NC}"
AUR_PACKAGES=(
    anyrun
    dgop
    hyprpicker-git
    matugen-git
    python-pynvml
    quickshell-git
)

MISSING_AUR=()
for package in "${AUR_PACKAGES[@]}"; do
    if ! check_package "$package"; then
        MISSING_AUR+=("$package")
        echo -e "${BLUE}  Missing: $package${NC}"
    else
        echo -e "${GREEN}  Installed: $package${NC}"
    fi
done

if [ ${#MISSING_AUR[@]} -gt 0 ]; then
    echo -e "\n${YELLOW}Installing missing AUR packages...${NC}"
    yay -S --needed --noconfirm "${MISSING_AUR[@]}"
else
    echo -e "\n${GREEN}All AUR packages are already installed!${NC}"
fi

# dgop (build from source if not installed via AUR)
echo -e "\n${YELLOW}Checking for dgop...${NC}"
if ! check_command dgop; then
    if ! check_package dgop; then
        echo -e "${BLUE}dgop not found. Building from source...${NC}"
        # Check for Go
        if ! check_command go; then
            echo -e "${YELLOW}Installing Go...${NC}"
            sudo pacman -S --needed --noconfirm go
        fi
        
        cd /tmp
        git clone https://github.com/AvengeMedia/dgop.git
        cd dgop
        make
        sudo make install
        cd .. && rm -rf dgop
        cd ~
        echo -e "${GREEN}dgop installed successfully!${NC}"
    else
        echo -e "${GREEN}dgop is already installed via AUR!${NC}"
    fi
else
    echo -e "${GREEN}dgop is already installed!${NC}"
fi

# Font installation
echo -e "\n${YELLOW}Installing fonts...${NC}"

# Create fonts directory
mkdir -p ~/.local/share/fonts

# Inter Variable Font
echo -e "${BLUE}Installing Inter Variable Font...${NC}"
if [ ! -f ~/.local/share/fonts/InterVariable.ttf ]; then
    curl -L "https://github.com/rsms/inter/releases/download/v4.0/Inter-4.0.zip" -o /tmp/Inter.zip
    unzip -j /tmp/Inter.zip "InterVariable.ttf" "InterVariable-Italic.ttf" -d ~/.local/share/fonts/ 2>/dev/null || true
    rm -f /tmp/Inter.zip
    echo -e "${GREEN}Inter Variable Font installed!${NC}"
else
    echo -e "${GREEN}Inter Variable Font already installed!${NC}"
fi

# Fira Code
echo -e "${BLUE}Installing Fira Code...${NC}"
if [ ! -f ~/.local/share/fonts/FiraCode-Regular.ttf ] && [ ! -f ~/.local/share/fonts/FiraCode-VariableFont_wght.ttf ]; then
    curl -L "https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip" -o /tmp/FiraCode.zip
    unzip -j /tmp/FiraCode.zip "ttf/*.ttf" -d ~/.local/share/fonts/ 2>/dev/null || true
    rm -f /tmp/FiraCode.zip
    echo -e "${GREEN}Fira Code installed!${NC}"
else
    echo -e "${GREEN}Fira Code already installed!${NC}"
fi

# Material Symbols
echo -e "${BLUE}Installing Material Symbols...${NC}"
if ! check_package ttf-material-symbols-variable-git; then
    yay -S --needed --noconfirm ttf-material-symbols-variable-git
    echo -e "${GREEN}Material Symbols installed!${NC}"
else
    echo -e "${GREEN}Material Symbols already installed!${NC}"
fi

# Noto Fonts
echo -e "${BLUE}Installing Noto Fonts...${NC}"
NOTO_PACKAGES=(noto-fonts noto-fonts-emoji)
MISSING_NOTO=()
for package in "${NOTO_PACKAGES[@]}"; do
    if ! check_package "$package"; then
        MISSING_NOTO+=("$package")
    fi
done

if [ ${#MISSING_NOTO[@]} -gt 0 ]; then
    sudo pacman -S --needed --noconfirm "${MISSING_NOTO[@]}"
    echo -e "${GREEN}Noto Fonts installed!${NC}"
else
    echo -e "${GREEN}Noto Fonts already installed!${NC}"
fi

# Update font cache
echo -e "${YELLOW}Updating font cache...${NC}"
fc-cache -f

echo -e "\n${GREEN}Installation complete!${NC}"
echo -e "${YELLOW}Note: SF Pro Display and SF Pro Rounded are included in quickshell/eqsh/media/fonts/ and don't need installation.${NC}"

