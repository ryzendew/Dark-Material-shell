# Dark Material Shell

This is my personal dotfiles repository. These configurations are built specifically for me and my system.

You're welcome to use any part of this configuration, but **no support will be provided**. Use at your own risk.

# QuickShell Dotfiles Installation Guide

This guide provides step-by-step instructions to install the necessary dependencies for the QuickShell dotfiles on Arch Linux.

## Prerequisites

Ensure your system is up-to-date:

```bash
sudo pacman -Syu
```

## Installing Required Packages

### Official Arch Repository Packages

Install the following packages from the official Arch repositories:

```bash
sudo pacman -S ptyxis nautilus gedit pavucontrol gnome-system-monitor grim slurp swappy cliphist wl-clipboard brightnessctl tesseract yad fuzzel wlogout systemd dbus xdg-user-dirs python
```

**Packages included:**
- **ptyxis** - Terminal emulator
- **nautilus** - File manager
- **gedit** - Text editor
- **pavucontrol** - Audio mixer
- **gnome-system-monitor** - System monitoring tool
- **grim** - Screenshot utility
- **slurp** - Area selection tool
- **swappy** - Screenshot editor
- **cliphist** - Clipboard history manager
- **wl-clipboard** - Wayland clipboard utilities
- **brightnessctl** - Brightness control
- **tesseract** - OCR engine
- **yad** - Dialog boxes
- **fuzzel** - Application launcher
- **wlogout** - Logout menu
- **systemd** - System and service manager
- **dbus** - Message bus system
- **xdg-user-dirs** - User directory management
- **python** - Python interpreter

### AUR Packages

For packages available in the Arch User Repository (AUR), you can use an AUR helper like `yay`. If you don't have `yay` installed, follow these steps:

1. Install the necessary build tools:

   ```bash
   sudo pacman -S --needed git base-devel
   ```

2. Clone and install `yay`:

   ```bash
   git clone https://aur.archlinux.org/yay.git
   cd yay
   makepkg -si
   cd ..
   rm -rf yay
   ```

Once `yay` is installed, proceed to install the AUR packages:

```bash
yay -S quickshell-git hyprpicker-git anyrun matugen
```

**AUR packages included:**
- **quickshell-git** - QuickShell framework (development version)
- **hyprpicker-git** - Color picker for Hyprland
- **anyrun** - Application launcher
- **matugen** - Material You color generation tool

### Building and Installing Hyprswitch

`Hyprswitch` is not available in the official repositories or AUR, so it needs to be built from source:

1. Install build dependencies:

   ```bash
   sudo pacman -S rust cargo gtk4 pkg-config
   ```

2. Clone the Hyprswitch repository:

   ```bash
   git clone https://github.com/ryzendew/hyprswitch.git
   cd hyprswitch
   ```

3. Build and install Hyprswitch:

   ```bash
   cargo build --release
   sudo cp target/release/hyprswitch /usr/local/bin/
   cd ..
   rm -rf hyprswitch
   ```

### Installing Python Dependencies

Install the required Python package using `pip`:

```bash
pip install pynvml
```

## Complete Installation Script

Here's a complete script that installs all dependencies:

```bash
#!/bin/bash

# Update system
sudo pacman -Syu

# Install AUR helper if not present
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay && makepkg -si
cd .. && rm -rf yay

# Install from official repos
sudo pacman -S ptyxis nautilus gedit pavucontrol gnome-system-monitor grim slurp swappy cliphist wl-clipboard brightnessctl tesseract yad fuzzel wlogout systemd dbus xdg-user-dirs python

# Install from AUR
yay -S quickshell-git hyprpicker-git anyrun matugen

# Install hyprswitch build dependencies
sudo pacman -S rust cargo gtk4 pkg-config

# Build and install hyprswitch
git clone https://github.com/ryzendew/hyprswitch.git
cd hyprswitch
cargo build --release
sudo cp target/release/hyprswitch /usr/local/bin/
cd .. && rm -rf hyprswitch

# Install Python dependency
pip install pynvml

# Update user directories
xdg-user-dirs-update

echo "All dependencies installed successfully!"
```

## Final Steps

After installing all the necessary packages, ensure that your user directories are set up correctly:

```bash
xdg-user-dirs-update
```

This completes the installation of all dependencies required for the QuickShell dotfiles on Arch Linux.