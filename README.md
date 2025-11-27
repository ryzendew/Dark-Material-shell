# Dark Material Shell

This is my personal dotfiles repository. These configurations are built specifically for me and my system.

You're welcome to use any part of this configuration, but **no support will be provided**. Use at your own risk.

<img width="2562" height="1441" alt="image" src="https://github.com/user-attachments/assets/354c34ca-f393-49de-ac9f-e46c0367fc4a" />
<img width="2560" height="1441" alt="image" src="https://github.com/user-attachments/assets/705f616d-524b-465e-8451-7fe0ecd1fb30" />
<img width="2561" height="1441" alt="image" src="https://github.com/user-attachments/assets/314f8656-2cce-4a23-b089-f99cfc8a22b7" />
<img width="2560" height="1441" alt="image" src="https://github.com/user-attachments/assets/ec69120b-96e4-49cd-9da6-68ed17cf0c00" />
<img width="2561" height="1441" alt="image" src="https://github.com/user-attachments/assets/b600c5d2-dad0-445d-8d23-83efe3aa0830" />






## Installation

<details>
<summary>System Utilities & Tools</summary>

- **anyrun** — Application launcher (fallback)
- **brightnessctl** — Brightness control
- **cliphist** — Clipboard history manager
- **fuzzel** — Application launcher/dmenu
- **grim** — Screenshot tool
- **hyprpicker** — Color picker
- **ptyxis** — Terminal emulator
- **quickshell** — Shell/launcher/widget system
- **slurp** — Region selector for screenshots
- **swappy** — Screenshot editor
- **tesseract** — OCR engine
- **wl-copy** — Wayland clipboard utility
- **wlogout** — Logout menu
- **wpctl** — WirePlumber audio control
- **yad** — Dialog tool (file picker)

</details>

<details>
<summary>Applications</summary>

- **better-control** — Settings application
- **code** — Visual Studio Code
- **easyeffects** — Audio effects/equalizer
- **firefox** — Firefox browser
- **mission-center** — System monitor
- **gedit** — Text editor
- **google-chrome-stable** — Google Chrome browser
- **nautilus** — GNOME file manager
- **pavucontrol** — PulseAudio volume control GUI
- **wps** — WPS Office suite
- **Zed** — Code editor

</details>

<details>
<summary>Package Installation (Arch)</summary>

Update your system first:

```bash
sudo pacman -Syu
```

### Official Repositories

```bash
sudo pacman -S brightnessctl cliphist easyeffects firefox fuzzel gedit gnome-disks grim hyprland mission-center nautilus nwg-look pavucontrol polkit polkit-gnome mate-polkit ptyxis qt6ct slurp swappy tesseract wl-clipboard wlogout xdg-desktop-portal-hyprland yad
```

### AUR Packages

Install `yay` if you don't have it:

```bash
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay && makepkg -si && cd .. && rm -rf yay
```

Install AUR packages:

```bash
yay -S anyrun dgop hyprpicker-git matugen-git python-pynvml quickshell-git
```

### dgop (Manual Installation)

**Option 1: Install from AUR (Recommended)**

```bash
yay -S dgop
```

**Option 2: Build from Source**

```bash
# Install Go if not already installed
sudo pacman -S --needed go

# Clone and build
cd /tmp
git clone https://github.com/AvengeMedia/dgop.git
cd dgop
make
sudo make install
cd .. && rm -rf dgop
```

### matugen (Manual Installation)

**Option 1: Install from AUR (Recommended)**

```bash
yay -S matugen-git
```

**Option 2: Install via Cargo**

```bash
# Install Rust and Cargo if not already installed
sudo pacman -S --needed rust cargo

# Install matugen
cargo install matugen
```

</details>

<details>
<summary>Package Installation (Fedora)</summary>

Update your system first:

```bash
sudo dnf update -y
```

### Step 1: Enable Required Repositories

Enable RPM Fusion (free and nonfree):

```bash
sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

Enable COPR repositories:

```bash
sudo dnf copr enable -y lionheartp/Hyprland
sudo dnf copr enable -y errornointernet/quickshell
```

Update package cache:

```bash
sudo dnf makecache
```

### Step 2: Install Packages from COPR Repositories

The following packages should be installed from the COPR repositories:

**From `lionheartp/Hyprland` repository:**

```bash
sudo dnf install -y hyprland hyprpicker swww xdg-desktop-portal-hyprland
```

**From `errornointernet/quickshell` repository:**

```bash
sudo dnf install -y quickshell-git
```

### Step 3: Install All Packages

Install all required packages in a single command:

```bash
sudo dnf install -y \
    hyprland hyprpicker swww xdg-desktop-portal-hyprland xdg-desktop-portal-wlr xdg-desktop-portal-gnome gnome-keyring \
    brightnessctl cliphist easyeffects firefox fuzzel gedit gnome-disks gnome-system-monitor gnome-text-editor grim nautilus nwg-look pavucontrol polkit mate-polkit ptyxis qt6ct slurp swappy tesseract wl-clipboard wlogout yad \
    quickshell-git \
    rust cargo gcc gcc-c++ pkg-config openssl-devel libX11-devel libXcursor-devel libXrandr-devel libXi-devel mesa-libGL-devel fontconfig-devel freetype-devel expat-devel \
    cairo-gobject cairo-gobject-devel rust-gdk4-sys+default-devel gtk4-layer-shell-devel \
    qt5-qtgraphicaleffects qt6-qt5compat python3-pyqt6 \
    python3.11 python3.11-libs libxcrypt-compat libcurl libcurl-devel apr fuse-libs fuse2 fuse \
    btop lm_sensors gedit nwg-look
```

### Step 4: Python Dependencies

```bash
pip install pynvml
```

### Step 5: dgop (Manual Installation)

**Build from Source:**

```bash
# Install Go and build tools if not already installed
sudo dnf install -y golang git make

# Clone and build
cd /tmp
git clone https://github.com/AvengeMedia/dgop.git
cd dgop
make
sudo make install
cd .. && rm -rf dgop
```

### Step 6: matugen (Manual Installation)

**Install via Cargo:**

```bash
# Install Rust and Cargo if not already installed
sudo dnf install -y rust cargo

# Install matugen
cargo install matugen
```

</details>

<details>
<summary>Package Installation (PikaOS)</summary>

Update your system first:

```bash
sudo apt update && sudo apt upgrade -y
```

### Step 1: Install All Packages

Install all required packages in a single command:

```bash
sudo apt install -y --no-install-recommends \
    hyprland swww xdg-desktop-portal-hyprland xdg-desktop-portal-wlr xdg-desktop-portal-gnome gnome-keyring \
    brightnessctl cliphist easyeffects firefox fuzzel gedit gnome-system-monitor gnome-text-editor grim nautilus nwg-look pavucontrol polkit mate-polkit-bin ptyxis qt6ct slurp swappy tesseract-ocr wl-clipboard wlogout yad \
    rustc cargo gcc g++ pkg-config libssl-dev libx11-dev libxcursor-dev libxrandr-dev libxi-dev libgl1-mesa-dev \
    libfontconfig-dev libfreetype-dev libexpat1-dev curl unzip fontconfig libcairo2-dev libgtk-4-dev libgtk-layer-shell-dev \
    qtbase5-dev qt6-base-dev python3-pyqt6 python3 python3-dev libcurl4-openssl-dev fuse libfuse2t64 \
    btop lm-sensors golang-go git make
```

**Note:** Some packages like `hyprpicker` and `quickshell-git` may need to be built from source or installed from additional repositories if not available in PikaOS repositories.

### Step 2: Python Dependencies

```bash
pip install pynvml
```

### Step 3: dgop (Manual Installation)

**Build from Source:**

```bash
# Install Go and build tools if not already installed
sudo apt install -y golang-go git make

# Clone and build
cd /tmp
git clone https://github.com/AvengeMedia/dgop.git
cd dgop
make
sudo make install
cd .. && rm -rf dgop
```

### Step 4: matugen (Manual Installation)

**Install via Cargo:**

```bash
# Install Rust and Cargo if not already installed
sudo apt install -y rustc cargo

# Install matugen
cargo install matugen
```

</details>

<details>
<summary>Font Installation (Fedora)</summary>

### Inter Variable Font

```bash
curl -L "https://github.com/rsms/inter/releases/download/v4.0/Inter-4.0.zip" -o /tmp/Inter.zip
unzip -j /tmp/Inter.zip "InterVariable.ttf" "InterVariable-Italic.ttf" -d ~/.local/share/fonts/
rm /tmp/Inter.zip && fc-cache -f
```

### Fira Code

```bash
curl -L "https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip" -o /tmp/FiraCode.zip
unzip -j /tmp/FiraCode.zip "ttf/*.ttf" -d ~/.local/share/fonts/
rm /tmp/FiraCode.zip && fc-cache -f
```

### Material Symbols

**Manual:**

```bash
mkdir -p ~/.local/share/fonts
curl -L "https://github.com/google/material-design-icons/raw/master/variablefont/MaterialSymbolsRounded%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf" -o ~/.local/share/fonts/MaterialSymbolsRounded.ttf
fc-cache -f
```

### Noto Fonts

```bash
sudo dnf install -y google-noto-fonts google-noto-emoji-fonts
```

**Note:** SF Pro Display and SF Pro Rounded are included in `quickshell/eqsh/media/fonts/` and don't need installation.

</details>

<details>
<summary>Font Installation (Arch)</summary>

### Inter Variable Font

```bash
curl -L "https://github.com/rsms/inter/releases/download/v4.0/Inter-4.0.zip" -o /tmp/Inter.zip
unzip -j /tmp/Inter.zip "InterVariable.ttf" "InterVariable-Italic.ttf" -d ~/.local/share/fonts/
rm /tmp/Inter.zip && fc-cache -f
```

### Fira Code

```bash
curl -L "https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip" -o /tmp/FiraCode.zip
unzip -j /tmp/FiraCode.zip "ttf/*.ttf" -d ~/.local/share/fonts/
rm /tmp/FiraCode.zip && fc-cache -f
```

### Material Symbols

**Manual:**

```bash
mkdir -p ~/.local/share/fonts
curl -L "https://github.com/google/material-design-icons/raw/master/variablefont/MaterialSymbolsRounded%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf" -o ~/.local/share/fonts/MaterialSymbolsRounded.ttf
fc-cache -f
```

**AUR:**

```bash
yay -S ttf-material-symbols-variable-git
```

### Noto Fonts

```bash
sudo pacman -S noto-fonts noto-fonts-emoji
```

**Note:** SF Pro Display and SF Pro Rounded are included in `quickshell/eqsh/media/fonts/` and don't need installation.

</details>

## Post-Installation

```bash
xdg-user-dirs-update
```

## License
This project was inspired by DankMaterialShell (https://github.com/AvengeMedia/DankMaterialShell),
but now stands on it's own and is no longer a fork and has been rewritten.
Design will also be changing as well.

You are free to fork, modify, and use this code in any way you wish. Attribution is not required.
