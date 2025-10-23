# EQSH Quickshell Configuration Analysis - Complete File Structure

## Overview
The `eqsh` configuration is an advanced Quickshell setup that provides draggable desktop widgets, drag-to-select desktop functionality, and a global menu system. This document provides a comprehensive analysis of EVERY SINGLE FILE in the configuration.

## Core Features

### 1. Draggable Desktop Widgets
- **Location**: `ui/components/widgets/`
- **Key Files**: `WidgetGrid.qml`, `WidgetGridItem.qml`, `BaseWidget.qml`
- **Functionality**: Allows widgets to be dragged and repositioned on a grid system

### 2. Drag-to-Select Desktop
- **Location**: `ui/components/desktop/Desktop.qml`
- **Functionality**: Enables drag selection on the desktop background

### 3. Global Menu
- **Location**: `ui/components/panel/StatusBar.qml`, `ui/components/notch/instances/GlobalMenu.qml`
- **Functionality**: Provides macOS-style global menu bar

### 4. Dynamic Notch System
- **Location**: `ui/components/notch/`
- **Functionality**: macOS Dynamic Island-style notifications and status indicators

### 5. Advanced Control Center
- **Location**: `ui/components/panel/ControlCenter.qml`
- **Functionality**: Comprehensive system controls with glass morphism effects

## Complete File Structure Analysis

### Root Level Files

#### `shell.qml`
- **Purpose**: Main entry point for the eqsh configuration
- **Imports**: 
  - `Quickshell`, `Quickshell.Wayland`, `Quickshell.Io`
  - `QtQuick`
  - Various component modules (`qs.ui.components.*`)
  - Configuration modules (`qs.config`, `qs.core.foundation`)
- **Key Components**:
  - `Settings`, `HyprPersist`, `ReloadPopup`
  - `Background` (wallpaper with widgets)
  - `StatusBar` (top bar with global menu)
  - `Dock` (bottom dock)
  - `LaunchPad` (application launcher)
  - `Notch` (dynamic island functionality)
  - Various OSD and notification components
- **Connections**: Orchestrates all major UI components

#### `Runtime.qml`
- **Purpose**: Runtime state management singleton
- **Imports**: `QtQuick`, `Quickshell`, `qs.config`, `Quickshell.Io`
- **Key Properties**:
  - `customAppName`: Current application name
  - `locked`: Lock screen state
  - `notchHeight`: Dynamic notch height
  - `settingsOpen`, `spotlightOpen`, `launchpadOpen`: UI state flags
- **Functionality**: Manages global runtime state and creates necessary runtime files
- **Connections**: Used by all components that need runtime state

#### `Time.qml`
- **Purpose**: Time and date management singleton
- **Imports**: `Quickshell`, `QtQuick`, `qs.config`
- **Key Functions**:
  - `getTime(format)`: Format time with locale support
  - `getSeconds()`: Get current seconds
- **Properties**: `date`, `time` (formatted)
- **Connections**: Used by clock widgets, status bar, and time displays

#### `Translation.qml`
- **Purpose**: Internationalization system
- **Imports**: `QtQuick`, `Quickshell`, `Quickshell.Io`, `qs.config`
- **Key Features**:
  - Multi-language support with JSON translation files
  - Auto-detection of available languages
  - Fallback to key names
  - Dynamic language switching
- **Functions**: `tr(text)` for translation
- **Connections**: Used throughout UI for text translation

#### `ReloadPopup.qml`
- **Purpose**: Shows reload status and errors
- **Imports**: `QtQuick`, `QtQuick.Layouts`, `Quickshell`
- **Key Features**:
  - Success/failure notifications
  - Error message display
  - Auto-dismiss with hover pause
  - Lazy loading for memory efficiency
- **Connections**: Listens to Quickshell reload signals

#### `ScreenCorners.qml`
- **Purpose**: Screen corner management
- **Imports**: `Quickshell`, `Quickshell.Wayland`, `QtQuick`, `qs.config`, `qs.ui.controls.auxiliary`
- **Key Features**:
  - Screen edge detection
  - Corner radius configuration
  - Overlay layer management
- **Connections**: Used by `ScreenCornersVisible.qml`

#### `ScreenCornersVisible.qml`
- **Purpose**: Visual screen corner implementation
- **Imports**: `Quickshell`, `QtQuick`, `qs.config`, `qs.ui.controls.auxiliary`
- **Key Features**:
  - Cutout corner rendering
  - Configurable corner height and type
  - Color customization
- **Connections**: Used by `ScreenCorners.qml`

#### `HyprPersist.qml`
- **Purpose**: Hyprland window manager integration
- **Imports**: `Quickshell.Io`, `QtQuick`, `qs.config`
- **Key Features**:
  - Sets Hyprland layer rules
  - Configures blur effects
  - Manages window behavior
- **Connections**: Integrates with Hyprland compositor

#### `Background.qml`
- **Purpose**: Desktop background with wallpaper and widget support
- **Imports**:
  - `Quickshell`, `Quickshell.Wayland`, `Quickshell.Widgets`
  - `QtQuick.Effects`, `QtQuick`
  - Configuration and component modules
- **Key Features**:
  - Wallpaper with optional shader effects
  - Desktop drag-to-select functionality
  - Widget grid system integration

### Configuration System

#### `config/Config.qml`
- **Purpose**: Main configuration singleton
- **Imports**: `Quickshell`, `QtQuick`, `qs.core.foundation`
- **Configuration Categories**:
  - `Account`: User information and activation
  - `General`: Dark mode, motion reduction, language
  - `Appearance`: Icon colors, glass mode, accent colors
  - `Notifications`: Background colors
  - `Dialogs`: Dialog styling and behavior
  - `Dock`: Dock configuration and app list
  - `Notch`: Dynamic island settings
  - `Launchpad`: Application launcher settings
  - `Bar`: Status bar and global menu settings
  - `ScreenEdges`: Screen edge behavior
  - `Osd`: On-screen display settings
  - `LockScreen`: Lock screen configuration
  - `Misc`: Miscellaneous settings
  - `Wallpaper`: Wallpaper and shader settings
  - `Widgets`: Widget grid and styling settings

#### `config/Default.qml`
- **Purpose**: Default configuration values
- **Imports**: `Quickshell`, `QtQuick`, `qs.core.foundation`
- **Function**: Provides default values for all configuration categories

### Desktop and Widget System

#### `ui/components/desktop/Desktop.qml`
- **Purpose**: Desktop drag-to-select functionality
- **Imports**: `Quickshell`, `QtQuick`
- **Key Features**:
  - Mouse area covering entire desktop
  - Selection box with visual feedback
  - Smooth animations for show/hide
  - Rectangle-based selection visualization

#### `ui/components/widgets/WidgetGrid.qml`
- **Purpose**: Grid system for widget management
- **Imports**:
  - `Quickshell`, `QtQuick`, `QtQuick.Layouts`
  - `QtQuick.Controls.Material`, `QtQuick.Effects`
  - `QtQuick.Controls.Fusion`
  - `Quickshell.Wayland`, `Quickshell.Widgets`, `Quickshell.Hyprland`
  - `Quickshell.Io`
  - Various control and component modules
- **Key Features**:
  - Configurable grid size (cellsX, cellsY)
  - Widget positioning and management
  - JSON-based widget persistence
  - Grid snapping and alignment
  - Widget movement signals

#### `ui/components/widgets/WidgetGridItem.qml`
- **Purpose**: Individual widget container with drag functionality
- **Imports**: Same as WidgetGrid plus `qs.ui.components.widgets.wi`
- **Key Features**:
  - Drag and drop functionality
  - Grid snapping with visual feedback
  - Ghost rectangle for drag preview
  - Smooth animations for positioning
  - Widget type loading system
  - Position persistence

#### `ui/components/widgets/wi/BaseWidget.qml`
- **Purpose**: Base class for all widgets
- **Imports**:
  - `QtQuick`, `Quickshell`, `Quickshell.Io`, `Quickshell.Widgets`
  - `QtQuick.Controls`, `QtQuick.Layouts`
  - `QtQuick.VectorImage`, `QtQuick.Effects`
  - Configuration and provider modules
- **Key Features**:
  - Standardized widget container
  - Gradient background system
  - Clipping rectangle for rounded corners
  - Content loading system

### Individual Widgets

#### Clock Widget (`wi/BCD2x2.qml`)
- **Purpose**: Digital clock with animated second indicator
- **Imports**: `QtQuick`, `QtQuick.Controls`, `qs`, `qs.config`, `Quickshell.Widgets`, `qs.ui.controls.providers`
- **Features**:
  - Time display with SF Pro Rounded font
  - Circular path animation for seconds
  - Tail effect for second indicators
  - Dark/light mode support

#### Battery Widget (`wi/BBD4x2.qml`)
- **Purpose**: Battery status display for multiple devices
- **Imports**: `QtQuick`, `QtQuick.Controls`, `QtQuick.Effects`, `QtQuick.Layouts`, `QtQuick.VectorImage`, `qs`, `qs.config`, `qs.ui.controls.providers`, `qs.ui.controls.primitives`, `Quickshell`, `Quickshell.Services.UPower`
- **Features**:
  - Circular progress indicators
  - Device type icons
  - Percentage display
  - UPower integration

#### Calendar Widget (`wi/CLD2x2.qml`)
- **Purpose**: Monthly calendar display
- **Imports**: `QtQuick`, `QtQuick.Controls`, `QtQuick.Layouts`, `qs.config`, `qs`, `qs.ui.controls.providers`
- **Features**:
  - Monthly calendar grid
  - Today highlighting
  - Month name display
  - Day name headers

### Panel and Status Bar System

#### `ui/components/panel/StatusBar.qml`
- **Purpose**: Top status bar with global menu
- **Imports**:
  - `Quickshell`, `QtQuick`, `QtQuick.VectorImage`, `QtQuick.Layouts`
  - `QtQuick.Effects`, `Quickshell.Wayland`, `Quickshell.Hyprland`
  - `qs.config`, `qs`, `qs.core.foundation`
  - Various control and provider modules
- **Key Features**:
  - Global menu with File, Edit, View, Go, Window, Help
  - System tray integration
  - Battery, WiFi, Bluetooth indicators
  - Time display
  - Control center access
  - Auto-hide functionality
  - Drag-to-reveal global menu

#### `ui/components/panel/DropDownMenu.qml`
- **Purpose**: Dropdown menu system for global menu
- **Imports**:
  - `Quickshell`, `QtQuick`, `QtQuick.VectorImage`, `QtQuick.Layouts`
  - `QtQuick.Effects`, `Quickshell.Wayland`, `Quickshell.Hyprland`
  - `qs.config`, `qs`, `qs.core.foundation`
  - Various control modules
- **Features**:
  - Popup window system
  - Menu positioning
  - Visual styling

### Dock System

#### `ui/components/dock/Dock.qml`
- **Purpose**: Bottom dock for application shortcuts
- **Imports**:
  - `Quickshell`, `Quickshell.Widgets`, `QtQuick`, `QtQuick.VectorImage`
  - `QtQuick.Layouts`, `QtQuick.Effects`, `Quickshell.Wayland`, `Quickshell.Hyprland`
  - `qs.config`, `qs`, `qs.core.foundation`
  - Various control modules
- **Key Features**:
  - Application icons with hover effects
  - Launchpad and settings integration
  - Spacer support
  - Desktop entry integration
  - Auto-hide functionality
  - Edge trigger system

### Launchpad System

#### `ui/components/launchpad/LaunchPad.qml`
- **Purpose**: Full-screen application launcher
- **Imports**:
  - `Quickshell`, `QtQuick`, `QtQuick.VectorImage`, `QtQuick.Layouts`
  - `QtQuick.Effects`, `Quickshell.Wayland`, `Quickshell.Hyprland`, `Quickshell.Io`
  - `qs.config`, `qs`, `qs.core.foundation`
  - Various control modules
- **Key Features**:
  - Full-screen overlay
  - Search functionality
  - Paginated application grid
  - Blur background effect
  - Keyboard navigation
  - Application execution

### Notch System

#### `ui/components/notch/instances/GlobalMenu.qml`
- **Purpose**: Notch-based global menu
- **Imports**:
  - `QtQuick`, `QtQuick.Layouts`, `Quickshell`
  - `qs.config`, `qs`, `qs.core.system`
  - Various control and component modules
- **Features**:
  - Menu bar items (File, Edit, View, Go, Window, Help)
  - SF Pro font styling
  - Notch application integration

### Control System

#### `ui/controls/auxiliary/EdgeTrigger.qml`
- **Purpose**: Edge-based trigger system for panels
- **Imports**:
  - `Quickshell`, `QtQuick`, `QtQuick.VectorImage`, `QtQuick.Layouts`
  - `QtQuick.Effects`, `Quickshell.Wayland`, `Quickshell.Hyprland`
  - `qs.config`, `qs`, `qs.core.foundation`
  - Various control modules
- **Features**:
  - Configurable edge positions (top, right, bottom, left)
  - Hover detection with timer
  - Click and hover events
  - Margin configuration

### Core System Files

#### `core/foundation/SPAppName.qml`
- **Purpose**: Application name resolution
- **Imports**: `Quickshell`, `QtQuick`, `qs.core.foundation`

#### `core/foundation/SPPathResolver.qml`
- **Purpose**: Path resolution utilities
- **Imports**: `Quickshell`, `QtQuick`, `qs.core.foundation`

#### `core/system/` Files
- **Brightness.qml**: Brightness control
- **MusicPlayerProvider.qml**: Music player integration
- **NetworkManager.qml**: Network management
- **NotificationDaemon.qml**: Notification system

## Key Technical Features

### 1. Draggable Widgets
- Grid-based positioning system
- Visual feedback with ghost rectangles
- Smooth animations and snapping
- JSON persistence for widget positions
- Configurable grid size and margins

### 2. Drag-to-Select Desktop - done
- Full-screen mouse area
- Visual selection rectangle
- Smooth show/hide animations
- Configurable selection styling

### 3. Global Menu - done
- macOS-style menu bar
- Auto-hide functionality with hover/drag triggers
- Dropdown menu system
- Application name display
- System integration

### 4. Configuration System
- JSON-based configuration
- Real-time configuration updates
- Comprehensive settings categories
- Default value system
- File watching for changes

### 5. Widget System
- Modular widget architecture
- Base widget class for consistency
- Multiple widget types (clock, battery, calendar, etc.)
- Theme integration
- Responsive design

## Dependencies

### Quickshell Modules
- `Quickshell` - Core functionality
- `Quickshell.Wayland` - Wayland integration
- `Quickshell.Widgets` - Widget system
- `Quickshell.Hyprland` - Hyprland integration
- `Quickshell.Io` - I/O operations

### Qt Modules
- `QtQuick` - Core QML functionality
- `QtQuick.Controls` - UI controls
- `QtQuick.Layouts` - Layout management
- `QtQuick.Effects` - Visual effects
- `QtQuick.VectorImage` - Vector graphics

### Custom Modules
- `qs.config` - Configuration system
- `qs.core.foundation` - Core utilities
- `qs.ui.controls.*` - UI control components
- `qs.ui.components.*` - UI components

## Usage Patterns

### Widget Management
1. Widgets are defined in JSON configuration
2. `WidgetGrid` loads and positions widgets
3. `WidgetGridItem` handles individual widget behavior
4. Drag operations update positions and save to JSON

### Global Menu
1. `StatusBar` provides the menu bar
2. `DropDownMenu` handles dropdown functionality
3. Edge triggers show/hide the menu
4. Application name updates based on focused window

### Desktop Interaction
1. `Desktop.qml` provides drag-to-select
2. `Background.qml` integrates desktop and widgets
3. Edge triggers control panel visibility
4. Widget grid overlays on desktop

## Complete Panel System Analysis

### Status Bar Components

#### `ui/components/panel/StatusBar.qml`
- **Purpose**: Main status bar with global menu
- **Imports**: `Quickshell`, `QtQuick`, `QtQuick.VectorImage`, `QtQuick.Layouts`, `QtQuick.Effects`, `Quickshell.Wayland`, `Quickshell.Hyprland`, `qs.config`, `qs`, `qs.core.foundation`, `qs.ui.controls.auxiliary`, `qs.ui.controls.providers`, `QtQuick.Controls.Fusion`
- **Key Features**:
  - Global menu with File, Edit, View, Go, Window, Help
  - Auto-hide functionality with hover/drag triggers
  - System tray integration
  - Battery, WiFi, Bluetooth indicators
  - Time display
  - Control center access
  - Application name display
- **Connections**: Integrates with `Barblock.qml`, `SystemTray.qml`, `Battery.qml`, `Wifi.qml`, `ControlCenter.qml`

#### `ui/components/panel/Barblock.qml`
- **Purpose**: Status bar container
- **Imports**: `Quickshell`, `QtQuick`, `QtQuick.VectorImage`, `QtQuick.Layouts`, `QtQuick.Effects`, `Quickshell.Wayland`, `Quickshell.Hyprland`, `qs.config`, `qs`, `qs.core.foundation`, `qs.ui.controls.auxiliary`, `QtQuick.Controls.Fusion`
- **Key Features**:
  - Panel window management
  - Blur namespace configuration
  - Application name handling
- **Connections**: Used by `StatusBar.qml`

#### `ui/components/panel/Battery.qml`
- **Purpose**: Battery status display
- **Imports**: `QtQuick`, `QtQuick.Shapes`, `QtQuick.VectorImage`, `QtQuick.Layouts`, `QtQuick.Effects`, `Quickshell`, `qs.config`, `Quickshell.Widgets`, `Quickshell.Services.UPower`
- **Key Features**:
  - Multiple display modes (pill, percentage, bubble)
  - Charging indicator
  - UPower integration
  - Customizable colors and styling
- **Connections**: Used by status bar and control center

#### `ui/components/panel/Wifi.qml`
- **Purpose**: WiFi status indicator
- **Imports**: `QtQuick`, `QtQuick.VectorImage`, `QtQuick.Layouts`, `Quickshell`, `qs.core.system`
- **Key Features**:
  - Signal strength visualization
  - Network status detection
  - Dynamic icon switching
- **Connections**: Used by status bar and control center

#### `ui/components/panel/SystemTray.qml`
- **Purpose**: System tray management
- **Imports**: `Quickshell`, `Quickshell.Widgets`, `QtQuick.VectorImage`, `QtQuick`, `QtQuick.Layouts`, `qs.ui.controls.auxiliary`, `Quickshell.Services.SystemTray`
- **Key Features**:
  - Tray item management
  - Expand/collapse functionality
  - Smooth animations
- **Connections**: Uses `SysTrayItem.qml` for individual items

#### `ui/components/panel/SysTrayItem.qml`
- **Purpose**: Individual system tray item
- **Imports**: `QtQuick`, `QtQuick.Layouts`, `QtQuick.Effects`, `Quickshell`, `Quickshell.Services.SystemTray`, `Quickshell.Widgets`, `qs.config`, `Qt.labs.folderlistmodel`
- **Key Features**:
  - Icon loading and display
  - Context menu support
  - Monochrome theming
  - Recursive icon search
- **Connections**: Used by `SystemTray.qml`

#### `ui/components/panel/TrayMenu.qml`
- **Purpose**: System tray context menu
- **Imports**: `QtQuick`, `QtQuick.Controls`, `QtQuick.Layouts`, `Quickshell`, `qs.config`, `qs.ui.controls.providers`, `qs.ui.controls.primitives`, `qs.ui.controls.advanced`, `Quickshell.Wayland`
- **Key Features**:
  - Popup menu system
  - Submenu support
  - Dynamic positioning
  - Menu item styling
- **Connections**: Used by `SysTrayItem.qml`

#### `ui/components/panel/MusicPlayer.qml`
- **Purpose**: Music player widget
- **Imports**: `QtQuick`, `QtQuick.VectorImage`, `QtQuick.Effects`, `Quickshell`, `Quickshell.Bluetooth`, `Quickshell.Widgets`, `QtQuick.Layouts`, `Quickshell.Wayland`, `qs.ui.controls.auxiliary`, `qs.ui.controls.providers`, `qs.ui.controls.advanced`, `qs.ui.controls.windows`, `qs.core.system`, `qs.config`, `qs`, `QtQuick.Controls.Fusion`
- **Key Features**:
  - Album art display
  - Track information
  - Playback controls
  - Music player provider integration
- **Connections**: Used by control center

#### `ui/components/panel/ControlCenter.qml`
- **Purpose**: Comprehensive control center
- **Imports**: `QtQuick`, `QtQuick.VectorImage`, `QtQuick.Effects`, `Quickshell`, `Quickshell.Bluetooth`, `Quickshell.Widgets`, `Quickshell.Services.Pipewire`, `QtQuick.Layouts`, `Quickshell.Wayland`, `qs.ui.controls.auxiliary`, `qs.ui.controls.providers`, `qs.ui.controls.advanced`, `qs.ui.controls.primitives`, `qs.ui.controls.windows`, `qs.core.system`, `qs.config`, `qs`, `QtQuick.Controls.Fusion`
- **Key Features**:
  - WiFi management
  - Bluetooth controls
  - Focus/Do Not Disturb toggle
  - Music player integration
  - Display brightness control
  - Volume control
  - Glass morphism effects
- **Connections**: Uses `MusicPlayer.qml`, `Battery.qml`, `Wifi.qml`

#### `ui/components/panel/DropDownMenu.qml`
- **Purpose**: Dropdown menu system
- **Imports**: `Quickshell`, `QtQuick`, `QtQuick.VectorImage`, `QtQuick.Layouts`, `QtQuick.Effects`, `Quickshell.Wayland`, `Quickshell.Hyprland`, `qs.config`, `qs`, `qs.core.foundation`, `qs.ui.controls.auxiliary`, `QtQuick.Controls.Fusion`, `qs.ui.controls.windows`
- **Key Features**:
  - Popup positioning
  - Menu content management
  - Visual styling
- **Connections**: Used by global menu system

## Complete Notch System Analysis

### Main Notch Component

#### `ui/components/notch/Notch.qml`
- **Purpose**: Dynamic notch system management
- **Imports**: `QtQuick.Controls.Fusion`, `Quickshell.Wayland`, `Quickshell.Hyprland`, `Quickshell.Widgets`, `Quickshell.Services.UPower`, `Quickshell.Io`, `Quickshell`, `QtQuick`, `QtQuick.Effects`, `QtQuick.VectorImage`, `qs.config`, `qs`, `qs.core.system`, `qs.ui.controls.auxiliary`, `qs.ui.controls.providers`
- **Key Features**:
  - Dynamic Island functionality
  - Multiple notch instances management
  - Size and positioning control
  - State management (active/indicative)
  - Auto-hide functionality
  - Fluid edge effects
  - Shadow and blur effects
- **Connections**: Manages all notch instances

### Notch Instances

#### `ui/components/notch/instances/GlobalMenu.qml`
- **Purpose**: Notch-based global menu
- **Imports**: `QtQuick`, `QtQuick.Layouts`, `Quickshell`, `qs.config`, `qs`, `qs.core.system`, `qs.ui.controls.providers`, `qs.ui.controls.auxiliary`, `qs.ui.components.panel`, `QtQuick.VectorImage`, `QtQuick.Effects`
- **Key Features**:
  - Menu bar items (File, Edit, View, Go, Window, Help)
  - SF Pro font styling
  - Notch application integration
- **Connections**: Used by notch system

#### `ui/components/notch/instances/Charging.qml`
- **Purpose**: Battery charging notification
- **Imports**: `QtQuick`, `Quickshell`, `qs.config`, `qs`, `qs.core.system`, `qs.ui.controls.providers`, `qs.ui.controls.auxiliary`, `qs.ui.components.panel`, `QtQuick.VectorImage`, `QtQuick.Effects`
- **Key Features**:
  - Battery percentage display
  - Charging status indicator
  - Auto-close after 2 seconds
  - Green accent color theme
- **Connections**: Triggered by battery charging state

#### `ui/components/notch/instances/DND.qml`
- **Purpose**: Do Not Disturb notification
- **Imports**: `QtQuick`, `Quickshell`, `qs.config`, `qs.core.system`, `qs`, `qs.ui.controls.providers`, `qs.ui.controls.auxiliary`, `QtQuick.VectorImage`, `QtQuick.Effects`
- **Key Features**:
  - DND status display
  - Purple accent color theme
  - Auto-close after 1 second
- **Connections**: Triggered by DND mode changes

#### `ui/components/notch/instances/Lock.qml`
- **Purpose**: Lock screen indicator
- **Imports**: `QtQuick`, `Quickshell`, `qs.config`, `qs.core.system`, `qs.ui.controls.providers`, `qs.ui.controls.auxiliary`, `QtQuick.VectorImage`, `QtQuick.Effects`
- **Key Features**:
  - Lock icon display
  - Indicative mode only
  - Gray color theme
- **Connections**: Triggered by lock screen state

#### `ui/components/notch/instances/Welcome.qml`
- **Purpose**: First-time user welcome
- **Imports**: `QtQuick`, `Quickshell`, `qs.config`, `qs.core.system`, `qs`, `qs.ui.controls.providers`, `qs.ui.controls.auxiliary`, `QtQuick.VectorImage`, `QtQuick.Effects`
- **Key Features**:
  - Welcome message
  - Click to close functionality
  - Accent color theming
  - First-time user detection
- **Connections**: Triggered by first-time running

## Complete Control System Analysis

### Auxiliary Controls

#### `ui/controls/auxiliary/BButton.qml`
- **Purpose**: Custom button component
- **Imports**: `Quickshell`, `QtQuick`, `QtQuick.VectorImage`, `QtQuick.Layouts`, `QtQuick.Effects`, `Quickshell.Wayland`, `Quickshell.Hyprland`, `qs.config`, `qs`, `qs.core.foundation`, `qs.ui.controls.auxiliary`, `qs.ui.controls.providers`, `QtQuick.Controls.Fusion`
- **Key Features**:
  - Hover effects
  - Jump animation
  - Configurable colors
  - Shadow effects
- **Connections**: Used throughout UI for buttons

#### `ui/controls/auxiliary/Box.qml`
- **Purpose**: Custom rounded rectangle with highlights
- **Imports**: `QtQuick`, `QtQuick.Controls`, `QtQuick.Effects`
- **Key Features**:
  - Canvas-based rendering
  - Individual corner radius control
  - Highlight effects
  - Gradient support
  - Corner cutouts
- **Connections**: Used by `BoxExperimental.qml`

#### `ui/controls/auxiliary/BoxExperimental.qml`
- **Purpose**: Advanced box with glass effects
- **Imports**: `QtQuick`, `QtQuick.Controls`, `qs.ui.controls.auxiliary`, `qs.ui.controls.providers`, `QtQuick.Effects`
- **Key Features**:
  - Inner shadow effects
  - Glow effects
  - Glass morphism
  - Highlight system
- **Connections**: Uses `Box.qml`, `InnerShadow.qml`

#### `ui/controls/auxiliary/EdgeTrigger.qml`
- **Purpose**: Edge-based trigger system
- **Imports**: `Quickshell`, `QtQuick`, `QtQuick.VectorImage`, `QtQuick.Layouts`, `QtQuick.Effects`, `Quickshell.Wayland`, `Quickshell.Hyprland`, `qs.config`, `qs`, `qs.core.foundation`, `qs.ui.controls.auxiliary`, `QtQuick.Controls.Fusion`
- **Key Features**:
  - Configurable edge positions
  - Hover detection with timer
  - Click and hover events
  - Margin configuration
- **Connections**: Used by panels for auto-hide

#### `ui/controls/auxiliary/GlintButton.qml`
- **Purpose**: Glint effect button
- **Imports**: `Quickshell`, `QtQuick`, `QtQuick.VectorImage`, `QtQuick.Layouts`, `QtQuick.Effects`, `Quickshell.Wayland`, `Quickshell.Hyprland`, `qs.config`, `qs`, `qs.core.foundation`, `qs.ui.controls.auxiliary`, `QtQuick.Controls.Fusion`
- **Key Features**:
  - Glint animation effects
  - Custom styling
- **Connections**: Used by system tray

#### `ui/controls/auxiliary/NotchApplication.qml`
- **Purpose**: Base class for notch applications
- **Imports**: `QtQuick`, `Quickshell`, `Quickshell.Hyprland`, `qs.config`, `qs.core.system`, `qs.ui.controls.providers`, `QtQuick.VectorImage`, `QtQuick.Effects`
- **Key Features**:
  - Notch state management
  - Focus grabbing
  - Animation system
  - Auto-close timers
  - Meta data system
- **Connections**: Base class for all notch instances

#### `ui/controls/auxiliary/CustomShortcut.qml`
- **Purpose**: Global shortcut management
- **Imports**: `Quickshell.Hyprland`
- **Key Features**:
  - Global shortcut registration
  - App ID configuration
- **Connections**: Used by launchpad and other components

### Advanced Controls

#### `ui/controls/advanced/LiquidGlass.qml`
- **Purpose**: Liquid glass effect
- **Imports**: `QtQuick`
- **Key Features**:
  - Shader-based effects
  - Blur helper integration
  - Inner shadow effects
  - Customizable parameters
- **Connections**: Uses `BlurHelper.qml`

#### `ui/controls/advanced/BoxExperimental.qml`
- **Purpose**: Experimental box with advanced effects
- **Imports**: `QtQuick`, `QtQuick.Controls`, `qs.ui.controls.auxiliary`, `qs.ui.controls.providers`, `QtQuick.Effects`
- **Key Features**:
  - Multiple shadow layers
  - Glow effects
  - Glass morphism
  - Highlight system
- **Connections**: Uses `Box.qml`, `InnerShadow.qml`

### Primitive Controls

#### `ui/controls/primitives/CFCircularProgress.qml`
- **Purpose**: Circular progress indicator
- **Imports**: `QtQuick`, `QtQuick.Shapes`
- **Key Features**:
  - Animated progress
  - Customizable colors
  - Gap angle support
  - Fill mode option
- **Connections**: Used by battery widget

#### `ui/controls/primitives/CFSlider.qml`
- **Purpose**: Custom slider control
- **Imports**: `Quickshell`, `qs.ui.controls.advanced`, `QtQuick`, `QtQuick.Controls`
- **Key Features**:
  - Custom handle styling
  - Smooth animations
  - Press state handling
  - BoxExperimental integration
- **Connections**: Uses `BoxExperimental.qml`

### Provider Controls

#### `ui/controls/providers/AccentColor.qml`
- **Purpose**: Dynamic accent color system
- **Imports**: `Quickshell`, `QtQuick`, `qs.config`
- **Key Features**:
  - Wallpaper color extraction
  - Color quantization
  - Dynamic/static mode
  - Text color generation
- **Connections**: Used throughout UI for theming

#### `ui/controls/providers/Fonts.qml`
- **Purpose**: Font management system
- **Imports**: `QtQuick`, `Quickshell`
- **Key Features**:
  - SF Pro font family loading
  - Multiple weights and styles
  - Font caching
- **Connections**: Used throughout UI for typography

### Window Controls

#### `ui/controls/windows/Pop.qml`
- **Purpose**: Popup window system
- **Imports**: `QtQuick`, `Quickshell`, `Quickshell.Wayland`, `Quickshell.Widgets`
- **Key Features**:
  - Overlay layer management
  - Auto-hide functionality
  - Click-outside dismissal
  - Animation system
- **Connections**: Used by control center and menus

## Complete Widget System Analysis

### Individual Widgets

#### `ui/components/widgets/wi/BWD2x2.qml` (Weather Widget)
- **Purpose**: Weather information display
- **Imports**: `QtQuick`, `Quickshell`, `Quickshell.Io`, `Quickshell.Widgets`, `QtQuick.Controls`, `QtQuick.Layouts`, `QtQuick.VectorImage`, `QtQuick.Effects`, `qs`, `qs.config`, `qs.ui.controls.providers`
- **Key Features**:
  - Weather API integration (wttr.in)
  - Temperature display
  - Location information
  - High/low temperature
  - Weather icons
  - Auto-refresh timer
- **Connections**: Uses `BaseWidget.qml`, weather API

#### `ui/components/widgets/wi/DED2x2.qml` (Day Event Display)
- **Purpose**: Daily event display
- **Imports**: `QtQuick`, `QtQuick.Controls`, `QtQuick.Effects`, `qs`, `qs.config`, `qs.ui.controls.providers`
- **Key Features**:
  - Day of week display
  - Date display
  - Event placeholder
  - Accent color theming
- **Connections**: Uses `BaseWidget.qml`, `Time.qml`

#### `ui/components/widgets/wi/DCD2x2.qml` (Day Calendar Display)
- **Purpose**: Calendar date display
- **Imports**: `QtQuick`, `QtQuick.Controls`, `QtQuick.Layouts`, `qs`, `qs.config`, `qs.ui.controls.providers`
- **Key Features**:
  - Day and month display
  - Large date number
  - SF Pro font styling
  - Accent color theming
- **Connections**: Uses `BaseWidget.qml`, `Time.qml`

## Complete Configuration System

### Configuration Files

#### `config/Directories.qml`
- **Purpose**: Directory path management
- **Imports**: `Quickshell`, `QtQuick`
- **Key Properties**:
  - `runtimeDir`: Runtime directory path
  - `notificationsPath`: Notifications file path
  - `widgetsPath`: Widgets file path
- **Connections**: Used by all components that need file paths

## Complete File Connection Map

### Core Dependencies
- `shell.qml` → All major components
- `Runtime.qml` → All UI components (state management)
- `Time.qml` → Clock widgets, status bar
- `Translation.qml` → All text elements
- `Config.qml` → All components (configuration)

### Widget System Dependencies
- `WidgetGrid.qml` → `WidgetGridItem.qml` → Individual widgets
- `BaseWidget.qml` → All widget implementations
- Individual widgets → `Time.qml`, `AccentColor.qml`, `Fonts.qml`

### Panel System Dependencies
- `StatusBar.qml` → `Barblock.qml`, `SystemTray.qml`, `Battery.qml`, `Wifi.qml`, `ControlCenter.qml`
- `ControlCenter.qml` → `MusicPlayer.qml`, `CFSlider.qml`, `BoxExperimental.qml`
- `SystemTray.qml` → `SysTrayItem.qml` → `TrayMenu.qml`

### Notch System Dependencies
- `Notch.qml` → All notch instances
- Notch instances → `NotchApplication.qml` → Various providers

### Control Dependencies
- `BoxExperimental.qml` → `Box.qml` → `InnerShadow.qml`
- `CFSlider.qml` → `BoxExperimental.qml`
- `BButton.qml` → `Box.qml`
- `AccentColor.qml` → All themed components
- `Fonts.qml` → All text components

This configuration represents a sophisticated desktop environment with modern UI patterns, comprehensive customization options, and smooth user interactions. Every file has been analyzed and documented with its complete functionality, imports, and connections.
