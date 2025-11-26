#!/bin/bash

# PikaOS Package Installation Script
# Converted from Fedora package installation script
# Maps Fedora packages to their Debian/Ubuntu/PikaOS equivalents

# Don't exit on error immediately - we'll handle errors manually
set +e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting PikaOS package installation...${NC}\n"

# Check if running as root, if not re-execute with sudo
if [ "$EUID" -ne 0 ]; then 
    echo -e "${YELLOW}This script requires sudo privileges. Requesting sudo access...${NC}"
    exec sudo "$0" "$@"
fi

# Function to check if a file is locked by a process
is_locked() {
    local file="$1"
    if [ ! -f "$file" ]; then
        return 1  # Not locked if file doesn't exist
    fi
    
    # Try fuser first (more reliable)
    if command -v fuser >/dev/null 2>&1; then
        if fuser "$file" >/dev/null 2>&1; then
            return 0  # Locked
        fi
    fi
    
    # Try lsof as fallback
    if command -v lsof >/dev/null 2>&1; then
        if lsof "$file" >/dev/null 2>&1; then
            return 0  # Locked
        fi
    fi
    
    return 1  # Not locked
}

# Function to check and wait for apt lock to be released
wait_for_apt() {
    local lock_file="/var/lib/dpkg/lock-frontend"
    local lock_file2="/var/lib/apt/lists/lock"
    local lock_file3="/var/cache/apt/archives/lock"
    local max_wait=300  # 5 minutes max wait
    local waited=0
    
    # First, check if there are any running apt/dpkg processes (excluding this script)
    local apt_processes=$(pgrep -fl "apt|apt-get|dpkg" | grep -v "$$" | grep -v "$0" || true)
    
    # Check if locks are actually held by processes
    local lock1_held=false
    local lock2_held=false
    local lock3_held=false
    
    if is_locked "$lock_file"; then
        lock1_held=true
    fi
    if is_locked "$lock_file2"; then
        lock2_held=true
    fi
    if is_locked "$lock_file3"; then
        lock3_held=true
    fi
    
    local locks_held=false
    if [ "$lock1_held" = true ] || [ "$lock2_held" = true ] || [ "$lock3_held" = true ]; then
        locks_held=true
    fi
    
    # If no processes and locks exist but aren't held, they're likely stale
    if [ -z "$apt_processes" ] && [ "$locks_held" = false ]; then
        if [ -f "$lock_file" ] || [ -f "$lock_file2" ] || [ -f "$lock_file3" ]; then
            echo -e "${YELLOW}Detected stale apt locks. Removing them...${NC}"
            rm -f "$lock_file" "$lock_file2" "$lock_file3" 2>/dev/null || true
            dpkg --configure -a 2>/dev/null || true
            return 0
        fi
    fi
    
    # If processes are running or locks are held, wait
    while [ $waited -lt $max_wait ]; do
        apt_processes=$(pgrep -fl "apt|apt-get|dpkg" | grep -v "$$" | grep -v "$0" || true)
        
        lock1_held=false
        lock2_held=false
        lock3_held=false
        if is_locked "$lock_file"; then
            lock1_held=true
        fi
        if is_locked "$lock_file2"; then
            lock2_held=true
        fi
        if is_locked "$lock_file3"; then
            lock3_held=true
        fi
        
        locks_held=false
        if [ "$lock1_held" = true ] || [ "$lock2_held" = true ] || [ "$lock3_held" = true ]; then
            locks_held=true
        fi
        
        if [ -n "$apt_processes" ] || [ "$locks_held" = true ]; then
            echo -e "${YELLOW}Waiting for apt lock to be released... (waited ${waited}s)${NC}"
            sleep 5
            waited=$((waited + 5))
        else
            # Double check - remove any remaining stale locks
            if [ -f "$lock_file" ] || [ -f "$lock_file2" ] || [ -f "$lock_file3" ]; then
                echo -e "${YELLOW}Removing stale locks...${NC}"
                rm -f "$lock_file" "$lock_file2" "$lock_file3" 2>/dev/null || true
            fi
            return 0
        fi
    done
    
    echo -e "${RED}Timeout waiting for apt lock. Attempting to remove stale locks...${NC}"
    # Remove stale locks (be careful with this)
    rm -f "$lock_file" "$lock_file2" "$lock_file3" 2>/dev/null || true
    dpkg --configure -a 2>/dev/null || true
    return 0
}

# Wait for apt to be available
wait_for_apt

# Function to run apt command with retry
run_apt() {
    local max_retries=3
    local retry=0
    
    while [ $retry -lt $max_retries ]; do
        # Always check for locks before running
        wait_for_apt
        
        # Try to run the command
        if "$@"; then
            return 0
        else
            local exit_code=$?
            # Check if it failed due to lock
            if [ $exit_code -ne 0 ]; then
                retry=$((retry + 1))
                if [ $retry -lt $max_retries ]; then
                    echo -e "${YELLOW}Command failed (exit code: $exit_code), retrying in 5 seconds... (attempt $retry/$max_retries)${NC}"
                    wait_for_apt
                    sleep 5
                else
                    echo -e "${RED}Command failed after $max_retries attempts: $*${NC}"
                    return 1
                fi
            else
                return 0
            fi
        fi
    done
}

# Update system first
echo -e "${YELLOW}Updating system...${NC}"
run_apt apt update -y
run_apt apt upgrade -y

# Prevent gdm from being installed as a recommended dependency
echo -e "${YELLOW}Configuring apt to avoid installing gdm...${NC}"
run_apt apt-mark hold gdm gdm3 2>/dev/null || true

# Note: PikaOS uses its own PPA (ppa.pika-os.com) which should already be configured
# If you need additional repositories, add them here
# For example, if hyprpicker or other packages need additional repos:
# echo -e "\n${YELLOW}Adding additional repositories if needed...${NC}"
# add-apt-repository -y ppa:some/repo  # Uncomment and modify as needed

# Note: gdm (GNOME Display Manager) is intentionally not installed
# Hyprland works with other display managers or can be started directly

# Update package cache after adding repositories
echo -e "\n${YELLOW}Updating package cache...${NC}"
run_apt apt update

# NVIDIA drivers (optional - uncomment if needed)
# echo -e "\n${YELLOW}Installing NVIDIA drivers...${NC}"
# apt install -y nvidia-driver-535  # Adjust version as needed
# apt install -y nvidia-cuda-toolkit  # Optional for cuda/nvdec/nvenc support

# Development tools and dependencies
echo -e "\n${YELLOW}Installing development tools and dependencies...${NC}"
wait_for_apt
run_apt apt install -y --no-install-recommends \
    rustc cargo \
    gcc g++ pkg-config \
    libssl-dev \
    libx11-dev libxcursor-dev libxrandr-dev libxi-dev \
    libgl1-mesa-dev \
    libfontconfig-dev libfreetype-dev libexpat1-dev \
    curl unzip fontconfig \
    libcairo2-dev \
    libgtk-4-dev \
    libgtk-layer-shell-dev \
    qtbase5-dev \
    qt6-base-dev \
    python3-pyqt6 \
    python3 python3-dev \
    libcurl4-openssl-dev \
    fuse libfuse2t64 \
    mate-polkit-bin \
    zenity

# Desktop environment and window manager
echo -e "\n${YELLOW}Installing desktop environment components...${NC}"
wait_for_apt
run_apt apt install -y --no-install-recommends \
    hyprland \
    swww \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-wlr \
    xdg-desktop-portal-gnome \
    gnome-keyring

# Note: hyprpicker and hyprpolkitagent may need to be built from source
# or installed from additional repositories
echo -e "\n${YELLOW}Checking for hyprpicker and hyprpolkitagent...${NC}"
if apt-cache show hyprpicker >/dev/null 2>&1; then
    wait_for_apt
    run_apt apt install -y --no-install-recommends hyprpicker
else
    echo -e "${YELLOW}hyprpicker not found in repos - may need to build from source${NC}"
    echo -e "${YELLOW}See: https://github.com/hyprwm/hyprpicker${NC}"
fi

if apt-cache show hyprpolkitagent >/dev/null 2>&1; then
    wait_for_apt
    run_apt apt install -y --no-install-recommends hyprpolkitagent
else
    echo -e "${YELLOW}hyprpolkitagent not found in repos - may need to build from source${NC}"
    echo -e "${YELLOW}See: https://github.com/hyprwm/hypridle${NC}"
fi

# System utilities
echo -e "\n${YELLOW}Installing system utilities...${NC}"
wait_for_apt
run_apt apt install -y --no-install-recommends \
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
    tesseract-ocr \
    wl-clipboard \
    wlogout \
    yad \
    btop \
    lm-sensors \
    gedit

# Applications
echo -e "\n${YELLOW}Installing applications...${NC}"
wait_for_apt
run_apt apt install -y --no-install-recommends \
    firefox \
    obs-studio \
    steam \
    lutris \
    mangohud \
    gamescope

# GUI tools
echo -e "\n${YELLOW}Installing GUI tools...${NC}"
wait_for_apt
run_apt apt install -y --no-install-recommends \
    qt6ct \
    nwg-look

# Quickshell
echo -e "\n${YELLOW}Installing Quickshell...${NC}"
if apt-cache show quickshell-git >/dev/null 2>&1; then
    wait_for_apt
    run_apt apt install -y --no-install-recommends quickshell-git
elif apt-cache show quickshell >/dev/null 2>&1; then
    wait_for_apt
    run_apt apt install -y --no-install-recommends quickshell
else
    echo -e "${YELLOW}quickshell not found in repos - may need to build from source${NC}"
    echo -e "${YELLOW}See: https://github.com/Quickshell/quickshell${NC}"
fi

# Additional packages that may be needed
echo -e "\n${YELLOW}Installing additional dependencies...${NC}"
# Note: apr and libxcrypt-compat may not be needed or may have different names
# These are optional dependencies that were in the Fedora script

# Qt5 graphical effects (may be in different package)
if apt-cache show qt5-graphicaleffects >/dev/null 2>&1; then
    wait_for_apt
    run_apt apt install -y --no-install-recommends qt5-graphicaleffects
elif apt-cache show qml-module-qtquick-controls >/dev/null 2>&1; then
    wait_for_apt
    run_apt apt install -y --no-install-recommends qml-module-qtquick-controls
else
    echo -e "${YELLOW}Qt5 graphical effects package not found - may not be needed${NC}"
fi

# Qt6 Qt5Compat (may be in different package)
if apt-cache show qt6-qt5compat >/dev/null 2>&1; then
    wait_for_apt
    run_apt apt install -y --no-install-recommends qt6-qt5compat
elif apt-cache show qml6-module-qt5compat >/dev/null 2>&1; then
    wait_for_apt
    run_apt apt install -y --no-install-recommends qml6-module-qt5compat
else
    echo -e "${YELLOW}Qt6 Qt5Compat package not found - may not be needed${NC}"
fi

echo -e "\n${GREEN}Installation complete!${NC}"
echo -e "${YELLOW}Note: You may need to reboot if you installed NVIDIA drivers or kernel packages.${NC}"
echo -e "${YELLOW}Some packages (hyprpicker, hyprpolkitagent) may need to be built from source if not available in repos.${NC}"

