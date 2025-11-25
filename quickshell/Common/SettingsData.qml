pragma Singleton

pragma ComponentBehavior: Bound

import QtCore
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services

Singleton {
    id: root

    // Theme settings
    // Audio routing persistence
    property var audioRoutesOutput: ({}) // map appKey -> deviceId
    property var audioRoutesInput: ({})  // map appKey -> deviceId
    property string currentThemeName: "blue"
    property string customThemeFile: ""
    property var savedColorThemes: [] // Array of saved color themes
    property string currentColorTheme: "" // Currently selected color theme name
    property real colorVibrance: 1.0
    property real topBarTransparency: 0.75
    property real topBarWidgetTransparency: 0.85
    property real popupTransparency: 0.92
    property real modalTransparency: 0.85
    property real notificationTransparency: 0.9
    property real controlCenterTransparency: 0.85
    property real controlCenterWidgetBackgroundOpacity: 0.60
    property real controlCenterDropShadowOpacity: 0.15
    property real controlCenterBorderOpacity: 0.30
    property real controlCenterBorderThickness: 1
    property real settingsBorderOpacity: 0.30
    property real settingsBorderThickness: 1
    property real launcherLogoRed: 1.0
    property real launcherLogoGreen: 1.0
    property real launcherLogoBlue: 1.0
    property bool launcherLogoAutoSync: false
    property real launcherLogoDropShadowOpacity: 0.15
    property real dockIconDropShadowOpacity: 0.15
    property real topBarDropShadowOpacity: 0.15
    property bool systemIconTinting: false
    property real iconTintIntensity: 0.5 // 0.0 to 1.0
    property int settingsWindowWidth: 0 // 0 means auto sizing
    property int settingsWindowHeight: 0 // 0 means auto sizing
    property int settingsWindowX: -1 // -1 means auto centering
    property int settingsWindowY: -1 // -1 means auto centering
    property bool desktopWidgetsEnabled: true
    property bool desktopCpuTempEnabled: true
    property bool desktopGpuTempEnabled: true
    property bool desktopSystemMonitorEnabled: true
    property bool desktopClockEnabled: true
    property bool desktopWeatherEnabled: false
    property bool desktopTerminalEnabled: false
    property string desktopWidgetsDisplay: "primary"
    property string desktopWidgetsPosition: "top-left"
    
    // Individual widget positions
    property string desktopCpuTempPosition: "top-left"
    property string desktopGpuTempPosition: "top-center"
    property string desktopSystemMonitorPosition: "top-right"
    property string desktopClockPosition: "bottom-right"
    property string desktopWeatherPosition: "top-left"
    property string desktopTerminalPosition: "bottom-left"
    
    // Desktop widget opacity settings
    property real desktopCpuTempOpacity: 0.9
    property real desktopGpuTempOpacity: 0.9
    property real desktopSystemMonitorOpacity: 0.9
    property real desktopClockOpacity: 0.9
    property real desktopClockBackgroundOpacity: 0.9
    property real desktopWeatherOpacity: 0.9
    property real desktopTerminalOpacity: 0.9
    
    // Desktop widget sizing
    property real desktopWidgetWidth: 180
    property real desktopWidgetHeight: 80
    property real desktopWidgetFontSize: 14
    property real desktopWidgetIconSize: 20
    
    // System Monitor Widget specific sizing
    property real desktopSystemMonitorWidth: 320
    property real desktopSystemMonitorHeight: 200
    property real desktopWeatherWidth: 800
    property real desktopWeatherHeight: 500
    property real desktopTerminalWidth: 600
    property real desktopTerminalHeight: 400
    property real desktopTerminalFontSize: 12
    property real desktopWeatherFontSize: 20
    property real desktopWeatherIconSize: 24
    property real desktopWeatherSpacing: 8
    property real desktopWeatherPadding: 16
    property real desktopWeatherBorderRadius: 8
    property real desktopWeatherCurrentTempSize: 2.0
    property real desktopWeatherCitySize: 2.0
    property real desktopWeatherDetailsSize: 1.2
    property real desktopWeatherForecastSize: 1.2
    property string desktopGpuSelection: "auto"
    property real dockTransparency: 1
    
    // Dock border settings
    property bool dockBorderEnabled: false
    property real dockBorderWidth: 2
    property real dockBorderRadius: 8
    property real dockRadius: 12
    property real dockBorderRed: 0.0
    property real dockBorderGreen: 0.0
    property real dockBorderBlue: 0.0
    property real dockBorderAlpha: 1.0
    
    // TopBar border settings
    property bool topBarBorderEnabled: false
    property real topBarBorderWidth: 2
    property real topBarBorderRadius: 8
    property real topBarBorderRed: 0.0
    property real topBarBorderGreen: 0.0
    property real topBarBorderBlue: 0.0
    property real topBarBorderAlpha: 1.0
    property bool topBarBorderTop: true
    property bool topBarBorderLeft: true
    property bool topBarBorderRight: true
    property bool topBarBorderBottom: true
    property real topBarBorderBottomLeftInset: 1
    property real topBarBorderBottomRightInset: 1
    
    // TopBar floating and appearance settings
    property bool topBarFloat: true
    property bool topBarRoundedCorners: true
    property real topBarCornerRadius: 12
    property real topBarLeftMargin: 0
    property real topBarRightMargin: 0
    property real topBarTopMargin: 0
    property real topBarHeight: 40
    property bool use24HourClock: true
    property bool useFahrenheit: false
    property bool nightModeEnabled: false
    property string weatherLocation: "New York, NY"
    property string weatherCoordinates: "40.7128,-74.0060"
    property bool useAutoLocation: false
    property bool showLauncherButton: true
    property bool showWorkspaceSwitcher: true
    property bool showFocusedWindow: true
    property bool showWeather: true
    property bool showMusic: true
    property bool showClipboard: true
    property bool showCpuUsage: true
    property bool showMemUsage: true
    property bool showCpuTemp: true
    property bool showGpuTemp: true
    property int selectedGpuIndex: 0
    property var enabledGpuPciIds: []
    property bool showSystemTray: true
    property bool showClock: true
    property bool showNotificationButton: true
    property bool showBattery: true
    property bool showControlCenterButton: true
    property bool controlCenterShowNetworkIcon: true
    property bool controlCenterShowBluetoothIcon: true
    property bool controlCenterShowAudioIcon: true
    property bool controlCenterShowMicIcon: true
    property var controlCenterWidgets: [
        {"id": "volumeSlider", "enabled": true, "width": 50},
        {"id": "inputVolumeSlider", "enabled": true, "width": 50},
        {"id": "brightnessSlider", "enabled": true, "width": 50},
        {"id": "wifi", "enabled": true, "width": 50},
        {"id": "bluetooth", "enabled": true, "width": 50},
        {"id": "audioOutput", "enabled": true, "width": 50},
        {"id": "audioInput", "enabled": true, "width": 50},
        {"id": "performance", "enabled": true, "width": 50},
        {"id": "nightMode", "enabled": true, "width": 50},
        {"id": "darkMode", "enabled": true, "width": 50}
    ]
    property bool showWorkspaceIndex: false
    property bool showWorkspacePadding: false
    property bool showWorkspaceApps: false
    property int maxWorkspaceIcons: 3
    property int maxWorkspaces: 10
    property bool workspacesPerMonitor: true
    property var workspaceNameIcons: ({})
    property bool waveProgressEnabled: true
    property bool clockCompactMode: false
    property bool focusedWindowCompactMode: false
    property bool runningAppsCompactMode: true
    property bool runningAppsCurrentWorkspace: false
    property string clockDateFormat: ""
    property string lockDateFormat: ""
    property int firstDayOfWeek: 1 // 0 = Sunday, 1 = Monday, etc.
    property string weekNumbering: "ISO" // "ISO", "US", "None"
    property string systemTimezone: ""
    property int mediaSize: 1
    property var topBarLeftWidgets: ["launcherButton", "workspaceSwitcher", "focusedWindow"]
    property var topBarCenterWidgets: ["music", "clock", "weather"]
    property var topBarRightWidgets: ["systemTray", "clipboard", "cpuUsage", "memUsage", "notificationButton", "battery", "controlCenterButton"]
    property alias topBarLeftWidgetsModel: leftWidgetsModel
    property alias topBarCenterWidgetsModel: centerWidgetsModel
    property alias topBarRightWidgetsModel: rightWidgetsModel
    
    // Dock widgets
    property var dockLeftWidgets: ["launcherButton", "music", "clock"]
    property var dockRightWidgets: ["systemTray", "controlCenterButton", "settingsButton"]
    
    // Widget positioning settings
    property string controlCenterPosition: "bottom-right" // "bottom-right", "top-right", "bottom-left", "top-left", "center"
    property string notificationCenterPosition: "top-right" // "top-right", "bottom-right", "top-left", "bottom-left", "center"
    property string appDrawerPosition: "center" // "center", "top-left", "top-right", "bottom-left", "bottom-right"
    property string clipboardPosition: "bottom-right" // "bottom-right", "top-right", "bottom-left", "top-left", "center"
    
    // Start Menu and Control Center positioning
    property real startMenuXOffset: 0.0 // -1.0 to 1.0, where -1 is left edge, 1 is right edge
    property real startMenuYOffset: 0.0 // -1.0 to 1.0, where -1 is top edge, 1 is bottom edge
    property real controlCenterXOffset: 0.0 // -1.0 to 1.0, where -1 is left edge, 1 is right edge
    property real controlCenterYOffset: 0.0 // -1.0 to 1.0, where -1 is top edge, 1 is bottom edge
    
    property alias dockLeftWidgetsModel: dockLeftWidgetsModel
    property alias dockRightWidgetsModel: dockRightWidgetsModel
    property string appLauncherViewMode: "list"
    property string spotlightModalViewMode: "list"
    property string networkPreference: "auto"
    property string iconTheme: "System Default"
    property var availableIconThemes: ["System Default"]
    property string systemDefaultIconTheme: ""
    property bool qt5ctAvailable: false
    property bool qt6ctAvailable: false
    property bool gtkAvailable: false
    
    // GTK Theme Properties
    property var availableGtkThemes: ["System Default"]
    property string systemDefaultGtkTheme: ""
    property string gtkTheme: "System Default"
    
    // QT Theme Properties  
    property var availableQtThemes: ["System Default"]
    property string systemDefaultQtTheme: ""
    property string qtTheme: "System Default"
    
    // GNOME Shell Theme Properties
    property var availableShellThemes: ["System Default"]
    property string systemDefaultShellTheme: ""
    property string shellTheme: "System Default"
    property bool userThemeExtensionAvailable: false
    property bool userThemeExtensionEnabled: false
    
    // Cursor Theme Properties
    property var availableCursorThemes: ["System Default"]
    property string systemDefaultCursorTheme: ""
    property string cursorTheme: "System Default"
    property int cursorSize: 24
    property bool useOSLogo: false
    property string osLogoColorOverride: ""
    property real osLogoBrightness: 0.5
    property real osLogoContrast: 1
    property bool useCustomLauncherImage: false
    property string customLauncherImagePath: ""
    property real launcherLogoSize: 24
    property string launcherPosition: "bottom-center" // "bottom-center", "bottom-left", "bottom-right"
    property bool wallpaperDynamicTheming: true
    property bool weatherEnabled: true
    property string fontFamily: "Inter Variable"
    property string monoFontFamily: "Fira Code"
    property int fontWeight: Font.Normal
    property real fontScale: 1.0
    property bool notepadUseMonospace: true
    property string notepadFontFamily: ""
    property real notepadFontSize: 14
    property bool notepadShowLineNumbers: false
    property real notepadTransparencyOverride: -1
    property real notepadLastCustomTransparency: 0.7
    property string terminalEmulator: ""
    property var availableTerminals: []
    property string aurHelper: ""
    property var availableAurHelpers: []

    onNotepadUseMonospaceChanged: saveSettings()
    onNotepadFontFamilyChanged: saveSettings()
    onNotepadFontSizeChanged: saveSettings()
    onNotepadShowLineNumbersChanged: saveSettings()
    onNotepadTransparencyOverrideChanged: {
        if (notepadTransparencyOverride > 0) {
            notepadLastCustomTransparency = notepadTransparencyOverride
        }
        saveSettings()
    }
    onNotepadLastCustomTransparencyChanged: saveSettings()
    onTerminalEmulatorChanged: saveSettings()
    onAurHelperChanged: saveSettings()
    property bool gtkThemingEnabled: false
    property bool qtThemingEnabled: false
    property bool showDock: true
    property bool dockAutoHide: false
    property bool dockGroupApps: false
    property bool dockHideOnGames: true
    property bool dockExpandToScreen: false
    property bool dockCenterApps: false
    property real dockBottomGap: 16
    property real dockExclusiveZone: 65
    property real dockLeftPadding: 0
    property real dockRightPadding: 0
    property real dockTopPadding: 0
    property real dockBottomPadding: 0
    property bool dockTooltipsEnabled: true
    property real dockIconSize: 40
    property real dockIconSpacing: 2
    // Dock advanced customization
    property real dockWidgetAreaOpacity: 0.30
    property real dockBackgroundTintOpacity: 0.04
    property real dockCollapsedHeight: 20
    property real dockSlideDistance: 60
    property int dockAnimationDuration: 200
    property real dockLeftWidgetAreaMinWidth: 60
    property real dockRightWidgetAreaMinWidth: 40
    property real cornerRadius: 12
    property bool notificationOverlayEnabled: false
    
    // Hyprland blur settings
    property real hyprlandBlurSize: 2
    property int hyprlandBlurPasses: 2
    property bool topBarAutoHide: false
    property bool topBarOpenOnOverview: false
    property bool topBarVisible: true
    property real topBarSpacing: 4
    property real topBarBottomGap: 0
    property real topBarInnerPadding: 8
    property bool topBarSquareCorners: false
    property bool topBarNoBackground: true // Transparent widgets
    property bool topBarGothCornersEnabled: false
    property bool lockScreenShowPowerActions: true
    property bool hideBrightnessSlider: false
    property string widgetBackgroundColor: "sth"
    property int notificationTimeoutLow: 5000
    property int notificationTimeoutNormal: 5000
    property int notificationTimeoutCritical: 0
    property var screenPreferences: ({})
    readonly property string defaultFontFamily: "Inter Variable"
    readonly property string defaultMonoFontFamily: "Fira Code"
    readonly property string _homeUrl: StandardPaths.writableLocation(StandardPaths.HomeLocation)
    readonly property string _configUrl: StandardPaths.writableLocation(StandardPaths.ConfigLocation)
    readonly property string _configDir: Paths.strip(_configUrl)

    signal forceTopBarLayoutRefresh
    signal widgetDataChanged
    signal workspaceIconsUpdated

    property bool _loading: false

    function getEffectiveTimeFormat() {
        if (use24HourClock) {
            return Locale.ShortFormat
        } else {
            return "h:mm AP"
        }
    }

    function getEffectiveClockDateFormat() {
        return clockDateFormat && clockDateFormat.length > 0 ? clockDateFormat : "ddd d"
    }

    function getEffectiveLockDateFormat() {
        return lockDateFormat && lockDateFormat.length > 0 ? lockDateFormat : Locale.LongFormat
    }

    function initializeListModels() {
        // ! Hack-ish to add all properties to the listmodel once
        // ! allows the properties to be bound on new widget addtions
        var dummyItem = {
            "widgetId": "dummy",
            "enabled": true,
            "size": 20,
            "selectedGpuIndex": 0,
            "pciId": ""
        }
        leftWidgetsModel.append(dummyItem)
        centerWidgetsModel.append(dummyItem)
        rightWidgetsModel.append(dummyItem)

        updateListModel(leftWidgetsModel, topBarLeftWidgets)
        updateListModel(centerWidgetsModel, topBarCenterWidgets)
        updateListModel(rightWidgetsModel, topBarRightWidgets)
    }

    function loadSettings() {
        _loading = true
        parseSettings(settingsFile.text())
        _loading = false
    }

    function parseSettings(content) {
        _loading = true
        try {
            if (content && content.trim()) {
                var settings = JSON.parse(content)
                // Auto-migrate from old theme system
                if (settings.themeIndex !== undefined || settings.themeIsDynamic !== undefined) {
                    const themeNames = ["blue", "deepBlue", "purple", "green", "orange", "red", "cyan", "pink", "amber", "coral"]
                    if (settings.themeIsDynamic) {
                        currentThemeName = "dynamic"
                    } else if (settings.themeIndex >= 0 && settings.themeIndex < themeNames.length) {
                        currentThemeName = themeNames[settings.themeIndex]
                    }
                    // console.log("Auto-migrated theme from index", settings.themeIndex, "to", currentThemeName)
                } else {
                    currentThemeName = settings.currentThemeName !== undefined ? settings.currentThemeName : "blue"
                }
                customThemeFile = settings.customThemeFile !== undefined ? settings.customThemeFile : ""
                savedColorThemes = settings.savedColorThemes !== undefined ? settings.savedColorThemes : []
                currentColorTheme = settings.currentColorTheme !== undefined ? settings.currentColorTheme : ""
                colorVibrance = settings.colorVibrance !== undefined ? settings.colorVibrance : 1.0
                topBarTransparency = settings.topBarTransparency !== undefined ? (settings.topBarTransparency > 1 ? settings.topBarTransparency / 100 : settings.topBarTransparency) : 0.75
                topBarWidgetTransparency = settings.topBarWidgetTransparency !== undefined ? (settings.topBarWidgetTransparency > 1 ? settings.topBarWidgetTransparency / 100 : settings.topBarWidgetTransparency) : 0.85
                popupTransparency = settings.popupTransparency !== undefined ? (settings.popupTransparency > 1 ? settings.popupTransparency / 100 : settings.popupTransparency) : 0.92
                modalTransparency = settings.modalTransparency !== undefined ? (settings.modalTransparency > 1 ? settings.modalTransparency / 100 : settings.modalTransparency) : 0.85
                notificationTransparency = settings.notificationTransparency !== undefined ? (settings.notificationTransparency > 1 ? settings.notificationTransparency / 100 : settings.notificationTransparency) : 0.9
                controlCenterTransparency = settings.controlCenterTransparency !== undefined ? (settings.controlCenterTransparency > 1 ? settings.controlCenterTransparency / 100 : settings.controlCenterTransparency) : 0.85
                controlCenterWidgetBackgroundOpacity = settings.controlCenterWidgetBackgroundOpacity !== undefined ? (settings.controlCenterWidgetBackgroundOpacity > 1 ? settings.controlCenterWidgetBackgroundOpacity / 100 : settings.controlCenterWidgetBackgroundOpacity) : 0.60
                audioRoutesOutput = settings.audioRoutesOutput !== undefined ? settings.audioRoutesOutput : ({})
                audioRoutesInput = settings.audioRoutesInput !== undefined ? settings.audioRoutesInput : ({})
                controlCenterDropShadowOpacity = settings.controlCenterDropShadowOpacity !== undefined ? (settings.controlCenterDropShadowOpacity > 1 ? settings.controlCenterDropShadowOpacity / 100 : settings.controlCenterDropShadowOpacity) : 0.15
                controlCenterBorderOpacity = settings.controlCenterBorderOpacity !== undefined ? (settings.controlCenterBorderOpacity > 1 ? settings.controlCenterBorderOpacity / 100 : settings.controlCenterBorderOpacity) : 0.30
                controlCenterBorderThickness = settings.controlCenterBorderThickness !== undefined ? settings.controlCenterBorderThickness : 1
                settingsBorderOpacity = settings.settingsBorderOpacity !== undefined ? (settings.settingsBorderOpacity > 1 ? settings.settingsBorderOpacity / 100 : settings.settingsBorderOpacity) : 0.30
                settingsBorderThickness = settings.settingsBorderThickness !== undefined ? settings.settingsBorderThickness : 1
                launcherLogoRed = settings.launcherLogoRed !== undefined ? (settings.launcherLogoRed > 1 ? settings.launcherLogoRed / 255 : settings.launcherLogoRed) : 1.0
                launcherLogoGreen = settings.launcherLogoGreen !== undefined ? (settings.launcherLogoGreen > 1 ? settings.launcherLogoGreen / 255 : settings.launcherLogoGreen) : 1.0
                launcherLogoBlue = settings.launcherLogoBlue !== undefined ? (settings.launcherLogoBlue > 1 ? settings.launcherLogoBlue / 255 : settings.launcherLogoBlue) : 1.0
                launcherLogoAutoSync = settings.launcherLogoAutoSync !== undefined ? settings.launcherLogoAutoSync : false
                launcherLogoDropShadowOpacity = settings.launcherLogoDropShadowOpacity !== undefined ? (settings.launcherLogoDropShadowOpacity > 1 ? settings.launcherLogoDropShadowOpacity / 100 : settings.launcherLogoDropShadowOpacity) : 0.15
                dockIconDropShadowOpacity = settings.dockIconDropShadowOpacity !== undefined ? (settings.dockIconDropShadowOpacity > 1 ? settings.dockIconDropShadowOpacity / 100 : settings.dockIconDropShadowOpacity) : 0.15
                topBarDropShadowOpacity = settings.topBarDropShadowOpacity !== undefined ? (settings.topBarDropShadowOpacity > 1 ? settings.topBarDropShadowOpacity / 100 : settings.topBarDropShadowOpacity) : 0.15
                systemIconTinting = settings.systemIconTinting !== undefined ? settings.systemIconTinting : false
                iconTintIntensity = settings.iconTintIntensity !== undefined ? settings.iconTintIntensity : 0.5
                settingsWindowWidth = settings.settingsWindowWidth !== undefined ? settings.settingsWindowWidth : 0
                settingsWindowHeight = settings.settingsWindowHeight !== undefined ? settings.settingsWindowHeight : 0
                settingsWindowX = settings.settingsWindowX !== undefined ? settings.settingsWindowX : -1
                settingsWindowY = settings.settingsWindowY !== undefined ? settings.settingsWindowY : -1
                desktopWidgetsEnabled = settings.desktopWidgetsEnabled !== undefined ? settings.desktopWidgetsEnabled : true
                desktopCpuTempEnabled = settings.desktopCpuTempEnabled !== undefined ? settings.desktopCpuTempEnabled : true
                desktopGpuTempEnabled = settings.desktopGpuTempEnabled !== undefined ? settings.desktopGpuTempEnabled : true
                desktopSystemMonitorEnabled = settings.desktopSystemMonitorEnabled !== undefined ? settings.desktopSystemMonitorEnabled : true
                desktopClockEnabled = settings.desktopClockEnabled !== undefined ? settings.desktopClockEnabled : true
                desktopWeatherEnabled = settings.desktopWeatherEnabled !== undefined ? settings.desktopWeatherEnabled : false
                desktopTerminalEnabled = settings.desktopTerminalEnabled !== undefined ? settings.desktopTerminalEnabled : false
        desktopWidgetsDisplay = settings.desktopWidgetsDisplay !== undefined ? settings.desktopWidgetsDisplay : "primary"
        desktopWidgetsPosition = settings.desktopWidgetsPosition !== undefined ? settings.desktopWidgetsPosition : "top-left"
        desktopCpuTempPosition = settings.desktopCpuTempPosition !== undefined ? settings.desktopCpuTempPosition : "top-left"
        desktopGpuTempPosition = settings.desktopGpuTempPosition !== undefined ? settings.desktopGpuTempPosition : "top-center"
        desktopSystemMonitorPosition = settings.desktopSystemMonitorPosition !== undefined ? settings.desktopSystemMonitorPosition : "top-right"
        desktopClockPosition = settings.desktopClockPosition !== undefined ? settings.desktopClockPosition : "bottom-right"
        desktopWeatherPosition = settings.desktopWeatherPosition !== undefined ? settings.desktopWeatherPosition : "top-left"
        desktopTerminalPosition = settings.desktopTerminalPosition !== undefined ? settings.desktopTerminalPosition : "bottom-left"
        desktopCpuTempOpacity = settings.desktopCpuTempOpacity !== undefined ? settings.desktopCpuTempOpacity : 0.9
        desktopGpuTempOpacity = settings.desktopGpuTempOpacity !== undefined ? settings.desktopGpuTempOpacity : 0.9
        desktopSystemMonitorOpacity = settings.desktopSystemMonitorOpacity !== undefined ? settings.desktopSystemMonitorOpacity : 0.9
        desktopClockOpacity = settings.desktopClockOpacity !== undefined ? settings.desktopClockOpacity : 0.9
        desktopClockBackgroundOpacity = settings.desktopClockBackgroundOpacity !== undefined ? settings.desktopClockBackgroundOpacity : 0.9
        desktopWeatherOpacity = settings.desktopWeatherOpacity !== undefined ? settings.desktopWeatherOpacity : 0.9
        desktopTerminalOpacity = settings.desktopTerminalOpacity !== undefined ? settings.desktopTerminalOpacity : 0.9
        desktopWidgetWidth = settings.desktopWidgetWidth !== undefined ? settings.desktopWidgetWidth : 180
        desktopWidgetHeight = settings.desktopWidgetHeight !== undefined ? settings.desktopWidgetHeight : 80
        desktopWidgetFontSize = settings.desktopWidgetFontSize !== undefined ? settings.desktopWidgetFontSize : 14
        desktopWidgetIconSize = settings.desktopWidgetIconSize !== undefined ? settings.desktopWidgetIconSize : 20
        desktopSystemMonitorWidth = settings.desktopSystemMonitorWidth !== undefined ? settings.desktopSystemMonitorWidth : 320
        desktopSystemMonitorHeight = settings.desktopSystemMonitorHeight !== undefined ? settings.desktopSystemMonitorHeight : 200
        desktopWeatherWidth = settings.desktopWeatherWidth !== undefined ? settings.desktopWeatherWidth : 400
        desktopWeatherHeight = settings.desktopWeatherHeight !== undefined ? settings.desktopWeatherHeight : 500
        desktopWeatherFontSize = settings.desktopWeatherFontSize !== undefined ? settings.desktopWeatherFontSize : 20
        desktopTerminalWidth = settings.desktopTerminalWidth !== undefined ? settings.desktopTerminalWidth : 600
        desktopTerminalHeight = settings.desktopTerminalHeight !== undefined ? settings.desktopTerminalHeight : 400
        desktopTerminalFontSize = settings.desktopTerminalFontSize !== undefined ? settings.desktopTerminalFontSize : 12
        desktopWeatherIconSize = settings.desktopWeatherIconSize !== undefined ? settings.desktopWeatherIconSize : 24
        desktopWeatherSpacing = settings.desktopWeatherSpacing !== undefined ? settings.desktopWeatherSpacing : 8
        desktopWeatherPadding = settings.desktopWeatherPadding !== undefined ? settings.desktopWeatherPadding : 16
        desktopWeatherBorderRadius = settings.desktopWeatherBorderRadius !== undefined ? settings.desktopWeatherBorderRadius : 8
        desktopWeatherCurrentTempSize = settings.desktopWeatherCurrentTempSize !== undefined ? settings.desktopWeatherCurrentTempSize : 2.0
        desktopWeatherCitySize = settings.desktopWeatherCitySize !== undefined ? settings.desktopWeatherCitySize : 2.0
        desktopWeatherDetailsSize = settings.desktopWeatherDetailsSize !== undefined ? settings.desktopWeatherDetailsSize : 1.2
        desktopWeatherForecastSize = settings.desktopWeatherForecastSize !== undefined ? settings.desktopWeatherForecastSize : 1.2
        desktopGpuSelection = settings.desktopGpuSelection !== undefined ? settings.desktopGpuSelection : "auto"
                dockTransparency = settings.dockTransparency !== undefined ? (settings.dockTransparency > 1 ? settings.dockTransparency / 100 : settings.dockTransparency) : 1
                
                // Dock border settings
                dockBorderEnabled = settings.dockBorderEnabled !== undefined ? settings.dockBorderEnabled : false
                dockBorderWidth = settings.dockBorderWidth !== undefined ? settings.dockBorderWidth : 2
                dockBorderRadius = settings.dockBorderRadius !== undefined ? settings.dockBorderRadius : 8
                dockRadius = settings.dockRadius !== undefined ? settings.dockRadius : 12
                dockBorderRed = settings.dockBorderRed !== undefined ? settings.dockBorderRed : 0.0
                dockBorderGreen = settings.dockBorderGreen !== undefined ? settings.dockBorderGreen : 0.0
                dockBorderBlue = settings.dockBorderBlue !== undefined ? settings.dockBorderBlue : 0.0
                dockBorderAlpha = settings.dockBorderAlpha !== undefined ? settings.dockBorderAlpha : 1.0
                
                // TopBar border settings
                topBarBorderEnabled = settings.topBarBorderEnabled !== undefined ? settings.topBarBorderEnabled : false
                topBarBorderWidth = settings.topBarBorderWidth !== undefined ? settings.topBarBorderWidth : 2
                topBarBorderRadius = settings.topBarBorderRadius !== undefined ? settings.topBarBorderRadius : 8
                topBarBorderRed = settings.topBarBorderRed !== undefined ? settings.topBarBorderRed : 0.0
                topBarBorderGreen = settings.topBarBorderGreen !== undefined ? settings.topBarBorderGreen : 0.0
                topBarBorderBlue = settings.topBarBorderBlue !== undefined ? settings.topBarBorderBlue : 0.0
                topBarBorderAlpha = settings.topBarBorderAlpha !== undefined ? settings.topBarBorderAlpha : 1.0
                topBarBorderTop = settings.topBarBorderTop !== undefined ? settings.topBarBorderTop : true
                topBarBorderLeft = settings.topBarBorderLeft !== undefined ? settings.topBarBorderLeft : true
                topBarBorderRight = settings.topBarBorderRight !== undefined ? settings.topBarBorderRight : true
                topBarBorderBottom = settings.topBarBorderBottom !== undefined ? settings.topBarBorderBottom : true
                topBarBorderBottomLeftInset = settings.topBarBorderBottomLeftInset !== undefined ? settings.topBarBorderBottomLeftInset : 1
                topBarBorderBottomRightInset = settings.topBarBorderBottomRightInset !== undefined ? settings.topBarBorderBottomRightInset : 1
                topBarFloat = settings.topBarFloat !== undefined ? settings.topBarFloat : true
                topBarRoundedCorners = settings.topBarRoundedCorners !== undefined ? settings.topBarRoundedCorners : true
                topBarCornerRadius = settings.topBarCornerRadius !== undefined ? settings.topBarCornerRadius : 12
                topBarLeftMargin = settings.topBarLeftMargin !== undefined ? settings.topBarLeftMargin : 0
                topBarRightMargin = settings.topBarRightMargin !== undefined ? settings.topBarRightMargin : 0
                topBarTopMargin = settings.topBarTopMargin !== undefined ? settings.topBarTopMargin : 0
                topBarHeight = settings.topBarHeight !== undefined ? settings.topBarHeight : 40
                use24HourClock = settings.use24HourClock !== undefined ? settings.use24HourClock : true
                useFahrenheit = settings.useFahrenheit !== undefined ? settings.useFahrenheit : false
                nightModeEnabled = settings.nightModeEnabled !== undefined ? settings.nightModeEnabled : false
                weatherLocation = settings.weatherLocation !== undefined ? settings.weatherLocation : "New York, NY"
                weatherCoordinates = settings.weatherCoordinates !== undefined ? settings.weatherCoordinates : "40.7128,-74.0060"
                useAutoLocation = settings.useAutoLocation !== undefined ? settings.useAutoLocation : false
                weatherEnabled = settings.weatherEnabled !== undefined ? settings.weatherEnabled : true
                showLauncherButton = settings.showLauncherButton !== undefined ? settings.showLauncherButton : true
                showWorkspaceSwitcher = settings.showWorkspaceSwitcher !== undefined ? settings.showWorkspaceSwitcher : true
                showFocusedWindow = settings.showFocusedWindow !== undefined ? settings.showFocusedWindow : true
                showWeather = settings.showWeather !== undefined ? settings.showWeather : true
                showMusic = settings.showMusic !== undefined ? settings.showMusic : true
                showClipboard = settings.showClipboard !== undefined ? settings.showClipboard : true
                showCpuUsage = settings.showCpuUsage !== undefined ? settings.showCpuUsage : true
                showMemUsage = settings.showMemUsage !== undefined ? settings.showMemUsage : true
                showCpuTemp = settings.showCpuTemp !== undefined ? settings.showCpuTemp : true
                showGpuTemp = settings.showGpuTemp !== undefined ? settings.showGpuTemp : true
                selectedGpuIndex = settings.selectedGpuIndex !== undefined ? settings.selectedGpuIndex : 0
                enabledGpuPciIds = settings.enabledGpuPciIds !== undefined ? settings.enabledGpuPciIds : []
                showSystemTray = settings.showSystemTray !== undefined ? settings.showSystemTray : true
                showClock = settings.showClock !== undefined ? settings.showClock : true
                showNotificationButton = settings.showNotificationButton !== undefined ? settings.showNotificationButton : true
                showBattery = settings.showBattery !== undefined ? settings.showBattery : true
                showControlCenterButton = settings.showControlCenterButton !== undefined ? settings.showControlCenterButton : true
                controlCenterShowNetworkIcon = settings.controlCenterShowNetworkIcon !== undefined ? settings.controlCenterShowNetworkIcon : true
                controlCenterShowBluetoothIcon = settings.controlCenterShowBluetoothIcon !== undefined ? settings.controlCenterShowBluetoothIcon : true
                controlCenterShowAudioIcon = settings.controlCenterShowAudioIcon !== undefined ? settings.controlCenterShowAudioIcon : true
                controlCenterShowMicIcon = settings.controlCenterShowMicIcon !== undefined ? settings.controlCenterShowMicIcon : true
                controlCenterWidgets = settings.controlCenterWidgets !== undefined ? settings.controlCenterWidgets : [
                    {"id": "volumeSlider", "enabled": true, "width": 50},
                    {"id": "inputVolumeSlider", "enabled": true, "width": 50},
                    {"id": "brightnessSlider", "enabled": true, "width": 50},
                    {"id": "wifi", "enabled": true, "width": 50},
                    {"id": "bluetooth", "enabled": true, "width": 50},
                    {"id": "audioOutput", "enabled": true, "width": 50},
                    {"id": "audioInput", "enabled": true, "width": 50},
                    {"id": "performance", "enabled": true, "width": 50},
                    {"id": "nightMode", "enabled": true, "width": 50},
                    {"id": "darkMode", "enabled": true, "width": 50}
                ]
                showWorkspaceIndex = settings.showWorkspaceIndex !== undefined ? settings.showWorkspaceIndex : false
                showWorkspacePadding = settings.showWorkspacePadding !== undefined ? settings.showWorkspacePadding : false
                showWorkspaceApps = settings.showWorkspaceApps !== undefined ? settings.showWorkspaceApps : false
                maxWorkspaceIcons = settings.maxWorkspaceIcons !== undefined ? settings.maxWorkspaceIcons : 3
                maxWorkspaces = settings.maxWorkspaces !== undefined ? settings.maxWorkspaces : 10
                workspaceNameIcons = settings.workspaceNameIcons !== undefined ? settings.workspaceNameIcons : ({})
                workspacesPerMonitor = settings.workspacesPerMonitor !== undefined ? settings.workspacesPerMonitor : true
                waveProgressEnabled = settings.waveProgressEnabled !== undefined ? settings.waveProgressEnabled : true
                clockCompactMode = settings.clockCompactMode !== undefined ? settings.clockCompactMode : false
                focusedWindowCompactMode = settings.focusedWindowCompactMode !== undefined ? settings.focusedWindowCompactMode : false
                runningAppsCompactMode = settings.runningAppsCompactMode !== undefined ? settings.runningAppsCompactMode : true
                runningAppsCurrentWorkspace = settings.runningAppsCurrentWorkspace !== undefined ? settings.runningAppsCurrentWorkspace : false
                clockDateFormat = settings.clockDateFormat !== undefined ? settings.clockDateFormat : ""
                lockDateFormat = settings.lockDateFormat !== undefined ? settings.lockDateFormat : ""
                firstDayOfWeek = settings.firstDayOfWeek !== undefined ? settings.firstDayOfWeek : 1
                weekNumbering = settings.weekNumbering !== undefined ? settings.weekNumbering : "ISO"
                systemTimezone = settings.systemTimezone !== undefined ? settings.systemTimezone : ""
                mediaSize = settings.mediaSize !== undefined ? settings.mediaSize : (settings.mediaCompactMode !== undefined ? (settings.mediaCompactMode ? 0 : 1) : 1)
                if (settings.topBarWidgetOrder) {
                    topBarLeftWidgets = settings.topBarWidgetOrder.filter(w => {
                                                                              return ["launcherButton", "workspaceSwitcher", "focusedWindow"].includes(w)
                                                                          })
                    topBarCenterWidgets = settings.topBarWidgetOrder.filter(w => {
                                                                                return ["clock", "music", "weather"].includes(w)
                                                                            })
                    topBarRightWidgets = settings.topBarWidgetOrder.filter(w => {
                                                                               return ["systemTray", "clipboard", "systemResources", "notificationButton", "battery", "controlCenterButton"].includes(w)
                                                                           })
                } else {
                    var leftWidgets = settings.topBarLeftWidgets !== undefined ? settings.topBarLeftWidgets : ["launcherButton", "workspaceSwitcher", "focusedWindow"]
                    var centerWidgets = settings.topBarCenterWidgets !== undefined ? settings.topBarCenterWidgets : ["music", "clock", "weather"]
                    var rightWidgets = settings.topBarRightWidgets !== undefined ? settings.topBarRightWidgets : ["systemTray", "clipboard", "cpuUsage", "memUsage", "notificationButton", "battery", "controlCenterButton"]
                    topBarLeftWidgets = leftWidgets
                    topBarCenterWidgets = centerWidgets
                    topBarRightWidgets = rightWidgets
                    updateListModel(leftWidgetsModel, leftWidgets)
                    updateListModel(centerWidgetsModel, centerWidgets)
                    updateListModel(rightWidgetsModel, rightWidgets)
                }
                
                // Load dock widgets
                dockLeftWidgets = settings.dockLeftWidgets !== undefined ? settings.dockLeftWidgets : ["launcherButton", "music", "clock"]
                dockRightWidgets = settings.dockRightWidgets !== undefined ? settings.dockRightWidgets : ["systemTray", "controlCenterButton"]
                updateListModel(dockLeftWidgetsModel, dockLeftWidgets)
                updateListModel(dockRightWidgetsModel, dockRightWidgets)
                
                // Load widget positioning settings
                controlCenterPosition = settings.controlCenterPosition !== undefined ? settings.controlCenterPosition : "bottom-right"
                notificationCenterPosition = settings.notificationCenterPosition !== undefined ? settings.notificationCenterPosition : "top-right"
                appDrawerPosition = settings.appDrawerPosition !== undefined ? settings.appDrawerPosition : "center"
                clipboardPosition = settings.clipboardPosition !== undefined ? settings.clipboardPosition : "bottom-right"
                
                // Load Start Menu and Control Center positioning
                startMenuXOffset = settings.startMenuXOffset !== undefined ? settings.startMenuXOffset : 0.0
                startMenuYOffset = settings.startMenuYOffset !== undefined ? settings.startMenuYOffset : 0.0
                controlCenterXOffset = settings.controlCenterXOffset !== undefined ? settings.controlCenterXOffset : 0.0
                controlCenterYOffset = settings.controlCenterYOffset !== undefined ? settings.controlCenterYOffset : 0.0
                
                appLauncherViewMode = settings.appLauncherViewMode !== undefined ? settings.appLauncherViewMode : "list"
                spotlightModalViewMode = settings.spotlightModalViewMode !== undefined ? settings.spotlightModalViewMode : "list"
                networkPreference = settings.networkPreference !== undefined ? settings.networkPreference : "auto"
                iconTheme = settings.iconTheme !== undefined ? settings.iconTheme : "System Default"
                gtkTheme = settings.gtkTheme !== undefined ? settings.gtkTheme : "System Default"
                qtTheme = settings.qtTheme !== undefined ? settings.qtTheme : "System Default"
                shellTheme = settings.shellTheme !== undefined ? settings.shellTheme : "System Default"
                cursorTheme = settings.cursorTheme !== undefined ? settings.cursorTheme : "System Default"
                cursorSize = settings.cursorSize !== undefined ? settings.cursorSize : 24
                useOSLogo = settings.useOSLogo !== undefined ? settings.useOSLogo : false
                osLogoColorOverride = settings.osLogoColorOverride !== undefined ? settings.osLogoColorOverride : ""
                osLogoBrightness = settings.osLogoBrightness !== undefined ? settings.osLogoBrightness : 0.5
                osLogoContrast = settings.osLogoContrast !== undefined ? settings.osLogoContrast : 1
                useCustomLauncherImage = settings.useCustomLauncherImage !== undefined ? settings.useCustomLauncherImage : false
                customLauncherImagePath = settings.customLauncherImagePath !== undefined ? settings.customLauncherImagePath : ""
                launcherLogoSize = settings.launcherLogoSize !== undefined ? settings.launcherLogoSize : 24
                launcherPosition = settings.launcherPosition !== undefined ? settings.launcherPosition : "bottom-center"
                wallpaperDynamicTheming = settings.wallpaperDynamicTheming !== undefined ? settings.wallpaperDynamicTheming : true
                fontFamily = settings.fontFamily !== undefined ? settings.fontFamily : defaultFontFamily
                monoFontFamily = settings.monoFontFamily !== undefined ? settings.monoFontFamily : defaultMonoFontFamily
                fontWeight = settings.fontWeight !== undefined ? settings.fontWeight : Font.Normal
                fontScale = settings.fontScale !== undefined ? settings.fontScale : 1.0
                notepadUseMonospace = settings.notepadUseMonospace !== undefined ? settings.notepadUseMonospace : true
                notepadFontFamily = settings.notepadFontFamily !== undefined ? settings.notepadFontFamily : ""
                notepadFontSize = settings.notepadFontSize !== undefined ? settings.notepadFontSize : 14
                notepadShowLineNumbers = settings.notepadShowLineNumbers !== undefined ? settings.notepadShowLineNumbers : false
                notepadTransparencyOverride = settings.notepadTransparencyOverride !== undefined ? settings.notepadTransparencyOverride : -1
                notepadLastCustomTransparency = settings.notepadLastCustomTransparency !== undefined ? settings.notepadLastCustomTransparency : 0.95
                terminalEmulator = settings.terminalEmulator !== undefined ? settings.terminalEmulator : ""
                aurHelper = settings.aurHelper !== undefined ? settings.aurHelper : ""
                gtkThemingEnabled = settings.gtkThemingEnabled !== undefined ? settings.gtkThemingEnabled : false
                qtThemingEnabled = settings.qtThemingEnabled !== undefined ? settings.qtThemingEnabled : false
                showDock = settings.showDock !== undefined ? settings.showDock : true
                dockAutoHide = settings.dockAutoHide !== undefined ? settings.dockAutoHide : false
                dockGroupApps = settings.dockGroupApps !== undefined ? settings.dockGroupApps : false
                dockHideOnGames = settings.dockHideOnGames !== undefined ? settings.dockHideOnGames : true
                dockExpandToScreen = settings.dockExpandToScreen !== undefined ? settings.dockExpandToScreen : false
                dockCenterApps = settings.dockCenterApps !== undefined ? settings.dockCenterApps : false
                dockBottomGap = settings.dockBottomGap !== undefined ? settings.dockBottomGap : 16
                dockExclusiveZone = settings.dockExclusiveZone !== undefined ? settings.dockExclusiveZone : 65
                dockLeftPadding = settings.dockLeftPadding !== undefined ? settings.dockLeftPadding : 0
                dockRightPadding = settings.dockRightPadding !== undefined ? settings.dockRightPadding : 0
                dockTopPadding = settings.dockTopPadding !== undefined ? settings.dockTopPadding : 0
                dockBottomPadding = settings.dockBottomPadding !== undefined ? settings.dockBottomPadding : 0
                dockTooltipsEnabled = settings.dockTooltipsEnabled !== undefined ? settings.dockTooltipsEnabled : true
                dockIconSize = settings.dockIconSize !== undefined ? settings.dockIconSize : 40
                dockIconSpacing = settings.dockIconSpacing !== undefined ? settings.dockIconSpacing : 2
                dockWidgetAreaOpacity = settings.dockWidgetAreaOpacity !== undefined ? (settings.dockWidgetAreaOpacity > 1 ? settings.dockWidgetAreaOpacity / 100 : settings.dockWidgetAreaOpacity) : 0.30
                dockBackgroundTintOpacity = settings.dockBackgroundTintOpacity !== undefined ? (settings.dockBackgroundTintOpacity > 1 ? settings.dockBackgroundTintOpacity / 100 : settings.dockBackgroundTintOpacity) : 0.04
                dockCollapsedHeight = settings.dockCollapsedHeight !== undefined ? settings.dockCollapsedHeight : 20
                dockSlideDistance = settings.dockSlideDistance !== undefined ? settings.dockSlideDistance : 60
                dockAnimationDuration = settings.dockAnimationDuration !== undefined ? settings.dockAnimationDuration : 200
                dockLeftWidgetAreaMinWidth = settings.dockLeftWidgetAreaMinWidth !== undefined ? settings.dockLeftWidgetAreaMinWidth : 60
                dockRightWidgetAreaMinWidth = settings.dockRightWidgetAreaMinWidth !== undefined ? settings.dockRightWidgetAreaMinWidth : 40
                cornerRadius = settings.cornerRadius !== undefined ? settings.cornerRadius : 12
                notificationOverlayEnabled = settings.notificationOverlayEnabled !== undefined ? settings.notificationOverlayEnabled : false
                hyprlandBlurSize = settings.hyprlandBlurSize !== undefined ? settings.hyprlandBlurSize : 2
                hyprlandBlurPasses = settings.hyprlandBlurPasses !== undefined ? settings.hyprlandBlurPasses : 2
                topBarAutoHide = settings.topBarAutoHide !== undefined ? settings.topBarAutoHide : false
                topBarOpenOnOverview = settings.topBarOpenOnOverview !== undefined ? settings.topBarOpenOnOverview : false
                topBarVisible = settings.topBarVisible !== undefined ? settings.topBarVisible : true
                notificationTimeoutLow = settings.notificationTimeoutLow !== undefined ? settings.notificationTimeoutLow : 5000
                notificationTimeoutNormal = settings.notificationTimeoutNormal !== undefined ? settings.notificationTimeoutNormal : 5000
                notificationTimeoutCritical = settings.notificationTimeoutCritical !== undefined ? settings.notificationTimeoutCritical : 0
                topBarSpacing = settings.topBarSpacing !== undefined ? settings.topBarSpacing : 4
                topBarBottomGap = settings.topBarBottomGap !== undefined ? settings.topBarBottomGap : 0
                topBarInnerPadding = settings.topBarInnerPadding !== undefined ? settings.topBarInnerPadding : 8
                topBarSquareCorners = settings.topBarSquareCorners !== undefined ? settings.topBarSquareCorners : false
                topBarNoBackground = settings.topBarNoBackground !== undefined ? settings.topBarNoBackground : true
                topBarGothCornersEnabled = settings.topBarGothCornersEnabled !== undefined ? settings.topBarGothCornersEnabled : false
                lockScreenShowPowerActions = settings.lockScreenShowPowerActions !== undefined ? settings.lockScreenShowPowerActions : true
                hideBrightnessSlider = settings.hideBrightnessSlider !== undefined ? settings.hideBrightnessSlider : false
                widgetBackgroundColor = settings.widgetBackgroundColor !== undefined ? settings.widgetBackgroundColor : "sth"
                screenPreferences = settings.screenPreferences !== undefined ? settings.screenPreferences : ({})
                applyStoredTheme()
                detectAvailableIconThemes()
                detectQtTools()
                updateGtkIconTheme(iconTheme)
                applyStoredIconTheme()
                applyStoredGtkTheme()
                applyStoredQtTheme()
                applyStoredShellTheme()
                applyStoredCursorTheme()
            } else {
                applyStoredTheme()
            }
        } catch (e) {
            applyStoredTheme()
        } finally {
            _loading = false
        }
    }

    function saveSettings() {
        if (_loading) {
            // console.log("SettingsData: saveSettings called but _loading is true, skipping")
            return
        }
        // console.log("SettingsData: saveSettings called, saving color themes:", savedColorThemes)
        // console.log("SettingsData: currentColorTheme:", currentColorTheme)
        settingsFile.setText(JSON.stringify({
                                                "currentThemeName": currentThemeName,
                                                "customThemeFile": customThemeFile,
                                                "savedColorThemes": savedColorThemes,
                                                "currentColorTheme": currentColorTheme,
                                                "colorVibrance": colorVibrance,
                                                "topBarTransparency": topBarTransparency,
                                                "topBarWidgetTransparency": topBarWidgetTransparency,
                                                "popupTransparency": popupTransparency,
                                                "modalTransparency": modalTransparency,
                                                "notificationTransparency": notificationTransparency,
                                                "controlCenterTransparency": controlCenterTransparency,
                                                "controlCenterWidgetBackgroundOpacity": controlCenterWidgetBackgroundOpacity,
                                                "controlCenterDropShadowOpacity": controlCenterDropShadowOpacity,
                                                "controlCenterBorderOpacity": controlCenterBorderOpacity,
                                                "controlCenterBorderThickness": controlCenterBorderThickness,
                                                "settingsBorderOpacity": settingsBorderOpacity,
                                                "settingsBorderThickness": settingsBorderThickness,
                                                "audioRoutesOutput": audioRoutesOutput,
                                                "audioRoutesInput": audioRoutesInput,
                                                "launcherLogoRed": launcherLogoRed,
                                                "launcherLogoGreen": launcherLogoGreen,
                                                "launcherLogoBlue": launcherLogoBlue,
                                                "launcherLogoAutoSync": launcherLogoAutoSync,
                                                "launcherLogoDropShadowOpacity": launcherLogoDropShadowOpacity,
                                                "dockIconDropShadowOpacity": dockIconDropShadowOpacity,
                                                "topBarDropShadowOpacity": topBarDropShadowOpacity,
                                                "systemIconTinting": systemIconTinting,
                                                "iconTintIntensity": iconTintIntensity,
                                                "settingsWindowWidth": settingsWindowWidth,
                                                "settingsWindowHeight": settingsWindowHeight,
                                                "settingsWindowX": settingsWindowX,
                                                "settingsWindowY": settingsWindowY,
                                                "desktopWidgetsEnabled": desktopWidgetsEnabled,
                                                "desktopCpuTempEnabled": desktopCpuTempEnabled,
                                                "desktopGpuTempEnabled": desktopGpuTempEnabled,
                                                "desktopSystemMonitorEnabled": desktopSystemMonitorEnabled,
                                                "desktopClockEnabled": desktopClockEnabled,
                                                "desktopWeatherEnabled": desktopWeatherEnabled,
                                                "desktopTerminalEnabled": desktopTerminalEnabled,
            "desktopWidgetsDisplay": desktopWidgetsDisplay,
            "desktopWidgetsPosition": desktopWidgetsPosition,
            "desktopCpuTempPosition": desktopCpuTempPosition,
            "desktopGpuTempPosition": desktopGpuTempPosition,
            "desktopSystemMonitorPosition": desktopSystemMonitorPosition,
            "desktopClockPosition": desktopClockPosition,
            "desktopWeatherPosition": desktopWeatherPosition,
            "desktopTerminalPosition": desktopTerminalPosition,
            "desktopCpuTempOpacity": desktopCpuTempOpacity,
            "desktopGpuTempOpacity": desktopGpuTempOpacity,
            "desktopSystemMonitorOpacity": desktopSystemMonitorOpacity,
            "desktopClockOpacity": desktopClockOpacity,
            "desktopClockBackgroundOpacity": desktopClockBackgroundOpacity,
            "desktopWeatherOpacity": desktopWeatherOpacity,
            "desktopTerminalOpacity": desktopTerminalOpacity,
            "desktopWidgetWidth": desktopWidgetWidth,
            "desktopWidgetHeight": desktopWidgetHeight,
            "desktopWidgetFontSize": desktopWidgetFontSize,
            "desktopWidgetIconSize": desktopWidgetIconSize,
            "desktopSystemMonitorWidth": desktopSystemMonitorWidth,
            "desktopSystemMonitorHeight": desktopSystemMonitorHeight,
            "desktopWeatherWidth": desktopWeatherWidth,
            "desktopWeatherHeight": desktopWeatherHeight,
            "desktopWeatherFontSize": desktopWeatherFontSize,
            "desktopWeatherIconSize": desktopWeatherIconSize,
            "desktopTerminalWidth": desktopTerminalWidth,
            "desktopTerminalHeight": desktopTerminalHeight,
            "desktopTerminalFontSize": desktopTerminalFontSize,
            "desktopWeatherSpacing": desktopWeatherSpacing,
            "desktopWeatherPadding": desktopWeatherPadding,
            "desktopWeatherBorderRadius": desktopWeatherBorderRadius,
            "desktopWeatherCurrentTempSize": desktopWeatherCurrentTempSize,
            "desktopWeatherCitySize": desktopWeatherCitySize,
            "desktopWeatherDetailsSize": desktopWeatherDetailsSize,
            "desktopWeatherForecastSize": desktopWeatherForecastSize,
            "desktopGpuSelection": desktopGpuSelection,
                                                "dockTransparency": dockTransparency,
                                                "dockWidgetAreaOpacity": dockWidgetAreaOpacity,
                                                "dockBackgroundTintOpacity": dockBackgroundTintOpacity,
                                                "dockCollapsedHeight": dockCollapsedHeight,
                                                "dockSlideDistance": dockSlideDistance,
                                                "dockAnimationDuration": dockAnimationDuration,
                                                "dockLeftWidgetAreaMinWidth": dockLeftWidgetAreaMinWidth,
                                                "dockRightWidgetAreaMinWidth": dockRightWidgetAreaMinWidth,
                                                "dockBorderEnabled": dockBorderEnabled,
                                                "dockBorderWidth": dockBorderWidth,
                                                "dockBorderRadius": dockBorderRadius,
                                                "dockRadius": dockRadius,
                                                "dockBorderRed": dockBorderRed,
                                                "dockBorderGreen": dockBorderGreen,
                                                "dockBorderBlue": dockBorderBlue,
                                                "dockBorderAlpha": dockBorderAlpha,
                                                "topBarBorderEnabled": topBarBorderEnabled,
                                                "topBarBorderWidth": topBarBorderWidth,
                                                "topBarBorderRadius": topBarBorderRadius,
                                                "topBarBorderRed": topBarBorderRed,
                                                "topBarBorderGreen": topBarBorderGreen,
                                                "topBarBorderBlue": topBarBorderBlue,
                                                "topBarBorderAlpha": topBarBorderAlpha,
                                                "topBarBorderTop": topBarBorderTop,
                                                "topBarBorderLeft": topBarBorderLeft,
                                                "topBarBorderRight": topBarBorderRight,
                                                "topBarBorderBottom": topBarBorderBottom,
                                                "topBarBorderBottomLeftInset": topBarBorderBottomLeftInset,
                                                "topBarBorderBottomRightInset": topBarBorderBottomRightInset,
                                                "topBarFloat": topBarFloat,
                                                "topBarRoundedCorners": topBarRoundedCorners,
                                                "topBarCornerRadius": topBarCornerRadius,
                                                "topBarLeftMargin": topBarLeftMargin,
                                                "topBarRightMargin": topBarRightMargin,
                                                "topBarTopMargin": topBarTopMargin,
                                                "topBarHeight": topBarHeight,
                                                "use24HourClock": use24HourClock,
                                                "useFahrenheit": useFahrenheit,
                                                "nightModeEnabled": nightModeEnabled,
                                                "weatherLocation": weatherLocation,
                                                "weatherCoordinates": weatherCoordinates,
                                                "useAutoLocation": useAutoLocation,
                                                "weatherEnabled": weatherEnabled,
                                                "showLauncherButton": showLauncherButton,
                                                "showWorkspaceSwitcher": showWorkspaceSwitcher,
                                                "showFocusedWindow": showFocusedWindow,
                                                "showWeather": showWeather,
                                                "showMusic": showMusic,
                                                "showClipboard": showClipboard,
                                                "showCpuUsage": showCpuUsage,
                                                "showMemUsage": showMemUsage,
                                                "showCpuTemp": showCpuTemp,
                                                "showGpuTemp": showGpuTemp,
                                                "selectedGpuIndex": selectedGpuIndex,
                                                "enabledGpuPciIds": enabledGpuPciIds,
                                                "showSystemTray": showSystemTray,
                                                "showClock": showClock,
                                                "showNotificationButton": showNotificationButton,
                                                "showBattery": showBattery,
                                                "showControlCenterButton": showControlCenterButton,
                                                "controlCenterShowNetworkIcon": controlCenterShowNetworkIcon,
                                                "controlCenterShowBluetoothIcon": controlCenterShowBluetoothIcon,
                                                "controlCenterShowAudioIcon": controlCenterShowAudioIcon,
                                                "controlCenterWidgets": controlCenterWidgets,
                                                "showWorkspaceIndex": showWorkspaceIndex,
                                                "showWorkspacePadding": showWorkspacePadding,
                                                "showWorkspaceApps": showWorkspaceApps,
                                                "maxWorkspaceIcons": maxWorkspaceIcons,
                                                "maxWorkspaces": maxWorkspaces,
                                                "workspacesPerMonitor": workspacesPerMonitor,
                                                "workspaceNameIcons": workspaceNameIcons,
                                                "waveProgressEnabled": waveProgressEnabled,
                                                "clockCompactMode": clockCompactMode,
                                                "focusedWindowCompactMode": focusedWindowCompactMode,
                                                "runningAppsCompactMode": runningAppsCompactMode,
                                                "runningAppsCurrentWorkspace": runningAppsCurrentWorkspace,
                                                "clockDateFormat": clockDateFormat,
                                                "lockDateFormat": lockDateFormat,
                                                "firstDayOfWeek": firstDayOfWeek,
                                                "weekNumbering": weekNumbering,
                                                "systemTimezone": systemTimezone,
                                                "mediaSize": mediaSize,
                                                "topBarLeftWidgets": topBarLeftWidgets,
                                                "topBarCenterWidgets": topBarCenterWidgets,
                                                "topBarRightWidgets": topBarRightWidgets,
                                                "dockLeftWidgets": dockLeftWidgets,
                                                "dockRightWidgets": dockRightWidgets,
                                                "controlCenterPosition": controlCenterPosition,
                                                "notificationCenterPosition": notificationCenterPosition,
                                                "appDrawerPosition": appDrawerPosition,
                                                "clipboardPosition": clipboardPosition,
                                                "startMenuXOffset": startMenuXOffset,
                                                "startMenuYOffset": startMenuYOffset,
                                                "controlCenterXOffset": controlCenterXOffset,
                                                "controlCenterYOffset": controlCenterYOffset,
                                                "appLauncherViewMode": appLauncherViewMode,
                                                "spotlightModalViewMode": spotlightModalViewMode,
                                                "networkPreference": networkPreference,
                                                "iconTheme": iconTheme,
                                                "gtkTheme": gtkTheme,
                                                "qtTheme": qtTheme,
                                                "shellTheme": shellTheme,
                                                "cursorTheme": cursorTheme,
                                                "cursorSize": cursorSize,
                                                "useOSLogo": useOSLogo,
                                                "osLogoColorOverride": osLogoColorOverride,
                                                "osLogoBrightness": osLogoBrightness,
                                                "osLogoContrast": osLogoContrast,
                                                "useCustomLauncherImage": useCustomLauncherImage,
                                                "customLauncherImagePath": customLauncherImagePath,
                                                "launcherLogoSize": launcherLogoSize,
                                                "launcherPosition": launcherPosition,
                                                "wallpaperDynamicTheming": wallpaperDynamicTheming,
                                                "fontFamily": fontFamily,
                                                "monoFontFamily": monoFontFamily,
                                                "fontWeight": fontWeight,
                                                "fontScale": fontScale,
                                                "notepadUseMonospace": notepadUseMonospace,
                                                "notepadFontFamily": notepadFontFamily,
                                                "notepadFontSize": notepadFontSize,
                                                "notepadShowLineNumbers": notepadShowLineNumbers,
                                                "notepadTransparencyOverride": notepadTransparencyOverride,
                                                "notepadLastCustomTransparency": notepadLastCustomTransparency,
                                                "terminalEmulator": terminalEmulator,
                                                "aurHelper": aurHelper,
                                                "gtkThemingEnabled": gtkThemingEnabled,
                                                "qtThemingEnabled": qtThemingEnabled,
                                                "showDock": showDock,
                                                "dockAutoHide": dockAutoHide,
                                                "dockGroupApps": dockGroupApps,
                                                "dockHideOnGames": dockHideOnGames,
                                                "dockExpandToScreen": dockExpandToScreen,
                                                "dockCenterApps": dockCenterApps,
                                                "dockBottomGap": dockBottomGap,
                                                "dockIconSize": dockIconSize,
                                                "dockIconSpacing": dockIconSpacing,
                                                "cornerRadius": cornerRadius,
                                                "notificationOverlayEnabled": notificationOverlayEnabled,
                                                "hyprlandBlurSize": hyprlandBlurSize,
                                                "hyprlandBlurPasses": hyprlandBlurPasses,
                                                "topBarAutoHide": topBarAutoHide,
                                                "topBarOpenOnOverview": topBarOpenOnOverview,
                                                "topBarVisible": topBarVisible,
                                                "topBarSpacing": topBarSpacing,
                                                "topBarBottomGap": topBarBottomGap,
                                                "topBarInnerPadding": topBarInnerPadding,
                                                "topBarSquareCorners": topBarSquareCorners,
                                                "topBarNoBackground": topBarNoBackground,
                                                "topBarGothCornersEnabled": topBarGothCornersEnabled,
                                                "lockScreenShowPowerActions": lockScreenShowPowerActions,
                                                "hideBrightnessSlider": hideBrightnessSlider,
                                                "widgetBackgroundColor": widgetBackgroundColor,
                                                "notificationTimeoutLow": notificationTimeoutLow,
                                                "notificationTimeoutNormal": notificationTimeoutNormal,
                                                "notificationTimeoutCritical": notificationTimeoutCritical,
                                                "screenPreferences": screenPreferences
                                            }, null, 2))
    }

    function setShowWorkspaceIndex(enabled) {
        showWorkspaceIndex = enabled
        saveSettings()
    }

    function setShowWorkspacePadding(enabled) {
        showWorkspacePadding = enabled
        saveSettings()
    }

    function setShowWorkspaceApps(enabled) {
        showWorkspaceApps = enabled
        saveSettings()
    }

    function setMaxWorkspaces(count) {
        maxWorkspaces = Math.max(1, Math.min(10, count))
        saveSettings()
    }

    function setMaxWorkspaceIcons(maxIcons) {
        maxWorkspaceIcons = maxIcons
        saveSettings()
    }

    function setWorkspacesPerMonitor(enabled) {
        workspacesPerMonitor = enabled
        saveSettings()
    }

    function setWaveProgressEnabled(enabled) {
        waveProgressEnabled = enabled
        saveSettings()
    }

    function setWorkspaceNameIcon(workspaceName, iconData) {
        var iconMap = JSON.parse(JSON.stringify(workspaceNameIcons))
        iconMap[workspaceName] = iconData
        workspaceNameIcons = iconMap
        saveSettings()
        workspaceIconsUpdated()
    }

    function removeWorkspaceNameIcon(workspaceName) {
        var iconMap = JSON.parse(JSON.stringify(workspaceNameIcons))
        delete iconMap[workspaceName]
        workspaceNameIcons = iconMap
        saveSettings()
        workspaceIconsUpdated()
    }

    function getWorkspaceNameIcon(workspaceName) {
        return workspaceNameIcons[workspaceName] || null
    }

    function hasNamedWorkspaces() {
        if (typeof NiriService === "undefined" || !CompositorService.isNiri)
            return false

        for (var i = 0; i < NiriService.allWorkspaces.length; i++) {
            var ws = NiriService.allWorkspaces[i]
            if (ws.name && ws.name.trim() !== "")
                return true
        }
        return false
    }

    function getNamedWorkspaces() {
        var namedWorkspaces = []
        if (typeof NiriService === "undefined" || !CompositorService.isNiri)
            return namedWorkspaces

        for (const ws of NiriService.allWorkspaces) {
            if (ws.name && ws.name.trim() !== "") {
                namedWorkspaces.push(ws.name)
            }
        }
        return namedWorkspaces
    }

    function setClockCompactMode(enabled) {
        clockCompactMode = enabled
        saveSettings()
    }

    function setFocusedWindowCompactMode(enabled) {
        focusedWindowCompactMode = enabled
        saveSettings()
    }

    function setRunningAppsCompactMode(enabled) {
        runningAppsCompactMode = enabled
        saveSettings()
    }

    function setRunningAppsCurrentWorkspace(enabled) {
        runningAppsCurrentWorkspace = enabled
        saveSettings()
    }

    function setClockDateFormat(format) {
        clockDateFormat = format || ""
        saveSettings()
    }

    function setLockDateFormat(format) {
        lockDateFormat = format || ""
        saveSettings()
    }

    function setFirstDayOfWeek(day) {
        firstDayOfWeek = day
        saveSettings()
    }

    function setWeekNumbering(mode) {
        weekNumbering = mode
        saveSettings()
    }

    function setSystemTimezone(timezone) {
        systemTimezone = timezone
        saveSettings()
    }

    function setMediaSize(size) {
        mediaSize = size
        saveSettings()
    }

    function applyStoredTheme() {
        if (typeof Theme !== "undefined")
            Theme.switchTheme(currentThemeName, false)
        else
            Qt.callLater(() => {
                             if (typeof Theme !== "undefined")
                             Theme.switchTheme(currentThemeName, false)
                         })
    }

    function setTheme(themeName) {
        currentThemeName = themeName
        saveSettings()
    }

    function setCustomThemeFile(filePath) {
        customThemeFile = filePath
        saveSettings()
    }

    function setColorVibrance(vibrance) {
        colorVibrance = vibrance
        saveSettings()
    }

    function setSavedColorThemes(themes) {
        // console.log("SettingsData: setSavedColorThemes called with:", themes)
        savedColorThemes = themes
        // console.log("SettingsData: savedColorThemes set to:", savedColorThemes)
        saveSettings()
        // console.log("SettingsData: saveSettings called after setSavedColorThemes")
    }

    function setCurrentColorTheme(themeName) {
        // console.log("SettingsData: setCurrentColorTheme called with:", themeName)
        currentColorTheme = themeName
        // console.log("SettingsData: currentColorTheme set to:", currentColorTheme)
        saveSettings()
        // console.log("SettingsData: saveSettings called after setCurrentColorTheme")
    }

    function setTopBarTransparency(transparency) {
        topBarTransparency = transparency
        saveSettings()
    }

    function setTopBarWidgetTransparency(transparency) {
        topBarWidgetTransparency = transparency
        saveSettings()
    }

    function setPopupTransparency(transparency) {
        popupTransparency = transparency
        saveSettings()
    }

    function setModalTransparency(transparency) {
        modalTransparency = transparency
        saveSettings()
    }

    function setNotificationTransparency(transparency) {
        notificationTransparency = transparency
        saveSettings()
    }

    function setControlCenterTransparency(transparency) {
        controlCenterTransparency = transparency
        saveSettings()
    }

    function setControlCenterWidgetBackgroundOpacity(opacity) {
        controlCenterWidgetBackgroundOpacity = opacity
        saveSettings()
    }

    function setControlCenterDropShadowOpacity(opacity) {
        controlCenterDropShadowOpacity = opacity
        saveSettings()
    }

    function setControlCenterBorderOpacity(opacity) {
        controlCenterBorderOpacity = opacity
        saveSettings()
    }

    function setControlCenterBorderThickness(thickness) {
        controlCenterBorderThickness = thickness
        saveSettings()
    }

    function setSettingsBorderOpacity(opacity) {
        settingsBorderOpacity = opacity
        saveSettings()
    }

    function setSettingsBorderThickness(thickness) {
        settingsBorderThickness = thickness
        saveSettings()
    }

    function setLauncherLogoRed(red) {
        launcherLogoRed = red
        saveSettings()
    }

    function setLauncherLogoGreen(green) {
        launcherLogoGreen = green
        saveSettings()
    }

    function setLauncherLogoBlue(blue) {
        launcherLogoBlue = blue
        saveSettings()
    }

    function setLauncherLogoAutoSync(enabled) {
        launcherLogoAutoSync = enabled
        saveSettings()
    }

    function syncLauncherLogoWithWallpaper() {
        if (launcherLogoAutoSync && typeof Theme !== 'undefined' && Theme.primary) {
            const primaryColor = Theme.primary
            // Only update if the color actually changed to avoid unnecessary saves
            if (Math.abs(launcherLogoRed - primaryColor.r) > 0.001 ||
                Math.abs(launcherLogoGreen - primaryColor.g) > 0.001 ||
                Math.abs(launcherLogoBlue - primaryColor.b) > 0.001) {
                launcherLogoRed = primaryColor.r
                launcherLogoGreen = primaryColor.g
                launcherLogoBlue = primaryColor.b
                saveSettings()
            }
        }
    }

    function setLauncherLogoDropShadowOpacity(opacity) {
        launcherLogoDropShadowOpacity = opacity
        saveSettings()
    }

    function setDockIconDropShadowOpacity(opacity) {
        dockIconDropShadowOpacity = opacity
        saveSettings()
    }
    function setTopBarDropShadowOpacity(opacity) {
        topBarDropShadowOpacity = opacity
        saveSettings()
    }

    function setSystemIconTinting(enabled) {
        systemIconTinting = enabled
        saveSettings()
    }

    function setIconTintIntensity(intensity) {
        iconTintIntensity = Math.max(0.0, Math.min(1.0, intensity))
        saveSettings()
    }
    function setSettingsWindowWidth(width) {
        settingsWindowWidth = width
        saveSettings()
    }
    function setSettingsWindowHeight(height) {
        settingsWindowHeight = height
        saveSettings()
    }
    function setSettingsWindowX(x) {
        settingsWindowX = x
        saveSettings()
    }
    function setSettingsWindowY(y) {
        settingsWindowY = y
        saveSettings()
    }
    function setDesktopWidgetsEnabled(enabled) {
        desktopWidgetsEnabled = enabled
        saveSettings()
    }
    function setDesktopCpuTempEnabled(enabled) {
        desktopCpuTempEnabled = enabled
        saveSettings()
    }
    function setDesktopGpuTempEnabled(enabled) {
        desktopGpuTempEnabled = enabled
        saveSettings()
    }
    function setDesktopSystemMonitorEnabled(enabled) {
        desktopSystemMonitorEnabled = enabled
        saveSettings()
    }
    function setDesktopClockEnabled(enabled) {
        desktopClockEnabled = enabled
        saveSettings()
    }
    function setDesktopWidgetsDisplay(display) {
        desktopWidgetsDisplay = display
        saveSettings()
    }
    function setDesktopWidgetsPosition(position) {
        desktopWidgetsPosition = position
        saveSettings()
    }
    function setDesktopCpuTempPosition(position) {
        desktopCpuTempPosition = position
        saveSettings()
    }
    function setDesktopGpuTempPosition(position) {
        desktopGpuTempPosition = position
        saveSettings()
    }
    function setDesktopSystemMonitorPosition(position) {
        desktopSystemMonitorPosition = position
        saveSettings()
    }
    function setDesktopClockPosition(position) {
        desktopClockPosition = position
        saveSettings()
    }
    
    function setDesktopCpuTempOpacity(opacity) {
        desktopCpuTempOpacity = opacity
        saveSettings()
    }
    
    function setDesktopGpuTempOpacity(opacity) {
        desktopGpuTempOpacity = opacity
        saveSettings()
    }
    
    function setDesktopSystemMonitorOpacity(opacity) {
        desktopSystemMonitorOpacity = opacity
        saveSettings()
    }
    
    function setDesktopClockOpacity(opacity) {
        desktopClockOpacity = opacity
        saveSettings()
    }
    
    function setDesktopClockBackgroundOpacity(opacity) {
        desktopClockBackgroundOpacity = opacity
        saveSettings()
    }
    
    function setDesktopWeatherEnabled(enabled) {
        desktopWeatherEnabled = enabled
        saveSettings()
    }
    
    function setDesktopWeatherPosition(position) {
        desktopWeatherPosition = position
        saveSettings()
    }
    
    function setDesktopTerminalEnabled(enabled) {
        desktopTerminalEnabled = enabled
        saveSettings()
    }
    
    function setDesktopTerminalPosition(position) {
        desktopTerminalPosition = position
        saveSettings()
    }
    
    function setDesktopTerminalOpacity(opacity) {
        desktopTerminalOpacity = opacity
        saveSettings()
    }
    
    function setDesktopTerminalWidth(width) {
        desktopTerminalWidth = width
        saveSettings()
    }
    
    function setDesktopTerminalHeight(height) {
        desktopTerminalHeight = height
        saveSettings()
    }
    
    function setDesktopTerminalFontSize(size) {
        desktopTerminalFontSize = size
        saveSettings()
    }
    
    function setStartMenuXOffset(offset) {
        startMenuXOffset = Math.max(-1.0, Math.min(1.0, offset))
        saveSettings()
    }
    
    function setStartMenuYOffset(offset) {
        startMenuYOffset = Math.max(-1.0, Math.min(1.0, offset))
        saveSettings()
    }
    
    function setControlCenterXOffset(offset) {
        controlCenterXOffset = Math.max(-1.0, Math.min(1.0, offset))
        saveSettings()
    }
    
    function setControlCenterYOffset(offset) {
        controlCenterYOffset = Math.max(-1.0, Math.min(1.0, offset))
        saveSettings()
    }
    
    function setDesktopWeatherOpacity(opacity) {
        desktopWeatherOpacity = opacity
        saveSettings()
    }
    
    function setDesktopWeatherWidth(width) {
        desktopWeatherWidth = width
        saveSettings()
    }
    
    function setDesktopWeatherHeight(height) {
        desktopWeatherHeight = height
        saveSettings()
    }
    
    function setDesktopWeatherFontSize(fontSize) {
        desktopWeatherFontSize = fontSize
        saveSettings()
    }
    
    function setDesktopWeatherIconSize(iconSize) {
        desktopWeatherIconSize = iconSize
        saveSettings()
    }
    
    function setDesktopWeatherSpacing(spacing) {
        desktopWeatherSpacing = spacing
        saveSettings()
    }
    
    function setDesktopWeatherPadding(padding) {
        desktopWeatherPadding = padding
        saveSettings()
    }
    
    function setDesktopWeatherBorderRadius(radius) {
        desktopWeatherBorderRadius = radius
        saveSettings()
    }
    
    function setDesktopWeatherCurrentTempSize(size) {
        desktopWeatherCurrentTempSize = size
        saveSettings()
    }
    
    function setDesktopWeatherCitySize(size) {
        desktopWeatherCitySize = size
        saveSettings()
    }
    
    function setDesktopWeatherDetailsSize(size) {
        desktopWeatherDetailsSize = size
        saveSettings()
    }
    
    function setDesktopWeatherForecastSize(size) {
        desktopWeatherForecastSize = size
        saveSettings()
    }
    
    function setDesktopSystemMonitorWidth(width) {
        desktopSystemMonitorWidth = width
        saveSettings()
    }
    
    function setDesktopSystemMonitorHeight(height) {
        desktopSystemMonitorHeight = height
        saveSettings()
    }

    function setDesktopWidgetWidth(width) {
        desktopWidgetWidth = width
        saveSettings()
    }

    function setDesktopWidgetHeight(height) {
        desktopWidgetHeight = height
        saveSettings()
    }

    function setDesktopWidgetFontSize(fontSize) {
        desktopWidgetFontSize = fontSize
        saveSettings()
    }

    function setDesktopWidgetIconSize(iconSize) {
        desktopWidgetIconSize = iconSize
        saveSettings()
    }

    function setDesktopGpuSelection(gpuSelection) {
        desktopGpuSelection = gpuSelection
        saveSettings()
    }

    // Function to get GPU dropdown options based on detected GPUs
    function getGpuDropdownOptions() {
        if (!DgopService.availableGpus || DgopService.availableGpus.length === 0) {
            return ["No GPUs detected"];
        }
        
        const options = ["auto"];
        for (let i = 0; i < DgopService.availableGpus.length; i++) {
            const gpu = DgopService.availableGpus[i];
            let vendorName = "Unknown";
            
            // Map vendor strings to display names
            if (gpu.vendor) {
                const vendor = gpu.vendor.toLowerCase();
                if (vendor.includes("nvidia")) {
                    vendorName = "NVIDIA";
                } else if (vendor.includes("amd") || vendor.includes("radeon")) {
                    vendorName = "AMD";
                } else if (vendor.includes("intel")) {
                    vendorName = "INTEL";
                } else {
                    vendorName = gpu.vendor.toUpperCase();
                }
            }
            
            // Use display name if available, otherwise use vendor
            const displayName = gpu.displayName || gpu.fullName || vendorName;
            options.push(`${vendorName} (${displayName})`);
        }
        
        return options;
    }

    // Dock border setters
    function setDockBorderEnabled(enabled) {
        dockBorderEnabled = enabled
        saveSettings()
    }

    function setDockBorderWidth(width) {
        dockBorderWidth = width
        saveSettings()
    }

    function setDockBorderRadius(radius) {
        dockBorderRadius = radius
        saveSettings()
    }

    function setDockRadius(radius) {
        dockRadius = radius
        saveSettings()
    }

    function setDockBorderRed(red) {
        dockBorderRed = red
        saveSettings()
    }

    function setDockBorderGreen(green) {
        dockBorderGreen = green
        saveSettings()
    }

    function setDockBorderBlue(blue) {
        dockBorderBlue = blue
        saveSettings()
    }

    function setDockBorderAlpha(alpha) {
        dockBorderAlpha = alpha
        saveSettings()
    }

    // TopBar border setters
    function setTopBarBorderEnabled(enabled) {
        topBarBorderEnabled = enabled
        saveSettings()
    }

    function setTopBarBorderWidth(width) {
        topBarBorderWidth = width
        saveSettings()
    }

    function setTopBarBorderRadius(radius) {
        topBarBorderRadius = radius
        saveSettings()
    }

    function setTopBarBorderRed(red) {
        topBarBorderRed = red
        saveSettings()
    }

    function setTopBarBorderGreen(green) {
        topBarBorderGreen = green
        saveSettings()
    }

    function setTopBarBorderBlue(blue) {
        topBarBorderBlue = blue
        saveSettings()
    }

    function setTopBarBorderAlpha(alpha) {
        topBarBorderAlpha = alpha
        saveSettings()
    }

    function setTopBarBorderTop(enabled) {
        topBarBorderTop = enabled
        saveSettings()
    }

    function setTopBarBorderLeft(enabled) {
        topBarBorderLeft = enabled
        saveSettings()
    }

    function setTopBarBorderRight(enabled) {
        topBarBorderRight = enabled
        saveSettings()
    }

    function setTopBarBorderBottom(enabled) {
        topBarBorderBottom = enabled
        saveSettings()
    }

    function setTopBarBorderBottomLeftInset(inset) {
        topBarBorderBottomLeftInset = inset
        saveSettings()
    }

    function setTopBarBorderBottomRightInset(inset) {
        topBarBorderBottomRightInset = inset
        saveSettings()
    }

    // TopBar floating and appearance setters
    function setTopBarFloat(enabled) {
        topBarFloat = enabled
        saveSettings()
    }

    function setTopBarRoundedCorners(enabled) {
        topBarRoundedCorners = enabled
        saveSettings()
    }

    function setTopBarCornerRadius(radius) {
        topBarCornerRadius = radius
        saveSettings()
    }

    function setTopBarLeftMargin(margin) {
        topBarLeftMargin = margin
        saveSettings()
    }

    function setTopBarRightMargin(margin) {
        topBarRightMargin = margin
        saveSettings()
    }

    function setTopBarTopMargin(margin) {
        topBarTopMargin = margin
        saveSettings()
    }

    function setTopBarHeight(height) {
        topBarHeight = height
        saveSettings()
    }

    function setDockTransparency(transparency) {
        dockTransparency = transparency
        saveSettings()
    }

    // New preference setters
    function setClockFormat(use24Hour) {
        use24HourClock = use24Hour
        saveSettings()
    }

    function setTemperatureUnit(fahrenheit) {
        useFahrenheit = fahrenheit
        saveSettings()
    }

    function setNightModeEnabled(enabled) {
        nightModeEnabled = enabled
        saveSettings()
    }

    // Widget visibility setters
    function setShowLauncherButton(enabled) {
        showLauncherButton = enabled
        saveSettings()
    }

    function setShowWorkspaceSwitcher(enabled) {
        showWorkspaceSwitcher = enabled
        saveSettings()
    }

    function setShowFocusedWindow(enabled) {
        showFocusedWindow = enabled
        saveSettings()
    }

    function setShowWeather(enabled) {
        showWeather = enabled
        saveSettings()
    }

    function setShowMusic(enabled) {
        showMusic = enabled
        saveSettings()
    }

    function setShowClipboard(enabled) {
        showClipboard = enabled
        saveSettings()
    }

    function setShowCpuUsage(enabled) {
        showCpuUsage = enabled
        saveSettings()
    }

    function setShowMemUsage(enabled) {
        showMemUsage = enabled
        saveSettings()
    }

    function setShowCpuTemp(enabled) {
        showCpuTemp = enabled
        saveSettings()
    }

    function setShowGpuTemp(enabled) {
        showGpuTemp = enabled
        saveSettings()
    }

    function setSelectedGpuIndex(index) {
        selectedGpuIndex = index
        saveSettings()
    }

    function setEnabledGpuPciIds(pciIds) {
        enabledGpuPciIds = pciIds
        saveSettings()
    }

    function setShowSystemTray(enabled) {
        showSystemTray = enabled
        saveSettings()
    }

    function setShowClock(enabled) {
        showClock = enabled
        saveSettings()
    }

    function setShowNotificationButton(enabled) {
        showNotificationButton = enabled
        saveSettings()
    }

    function setShowBattery(enabled) {
        showBattery = enabled
        saveSettings()
    }

    function setShowControlCenterButton(enabled) {
        showControlCenterButton = enabled
        saveSettings()
    }

    function setControlCenterShowNetworkIcon(enabled) {
        controlCenterShowNetworkIcon = enabled
        saveSettings()
    }

    function setControlCenterShowBluetoothIcon(enabled) {
        controlCenterShowBluetoothIcon = enabled
        saveSettings()
    }

    function setControlCenterShowAudioIcon(enabled) {
        controlCenterShowAudioIcon = enabled
        saveSettings()
    }

    function setControlCenterShowMicIcon(enabled) {
        controlCenterShowMicIcon = enabled
        saveSettings()
    }
    function setControlCenterWidgets(widgets) {
        controlCenterWidgets = widgets
        saveSettings()
    }

    function setTopBarWidgetOrder(order) {
        topBarWidgetOrder = order
        saveSettings()
    }

    function setTopBarLeftWidgets(order) {
        topBarLeftWidgets = order
        updateListModel(leftWidgetsModel, order)
        saveSettings()
    }

    function setTopBarCenterWidgets(order) {
        topBarCenterWidgets = order
        updateListModel(centerWidgetsModel, order)
        saveSettings()
    }

    function setTopBarRightWidgets(order) {
        topBarRightWidgets = order
        updateListModel(rightWidgetsModel, order)
        saveSettings()
    }

    function setDockLeftWidgets(order) {
        dockLeftWidgets = order
        updateListModel(dockLeftWidgetsModel, order)
        saveSettings()
    }

    function setDockRightWidgets(order) {
        dockRightWidgets = order
        updateListModel(dockRightWidgetsModel, order)
        saveSettings()
    }

    // Audio routing helpers
    function setAudioRoute(appKey, deviceId, isInput) {
        if (!appKey || !deviceId)
            return
        if (isInput) {
            audioRoutesInput[appKey] = deviceId
        } else {
            audioRoutesOutput[appKey] = deviceId
        }
        saveSettings()
    }
    function getAudioRoute(appKey, isInput) {
        if (!appKey)
            return ""
        return isInput ? (audioRoutesInput[appKey] || "") : (audioRoutesOutput[appKey] || "")
    }

    function updateListModel(listModel, order) {
        listModel.clear()
        for (var i = 0; i < order.length; i++) {
            var widgetId = typeof order[i] === "string" ? order[i] : order[i].id
            var enabled = typeof order[i] === "string" ? true : order[i].enabled
            var size = typeof order[i] === "string" ? undefined : order[i].size
            var selectedGpuIndex = typeof order[i] === "string" ? undefined : order[i].selectedGpuIndex
            var pciId = typeof order[i] === "string" ? undefined : order[i].pciId
            var item = {
                "widgetId": widgetId,
                "enabled": enabled
            }
            if (size !== undefined)
                item.size = size
            if (selectedGpuIndex !== undefined)
                item.selectedGpuIndex = selectedGpuIndex
            if (pciId !== undefined)
                item.pciId = pciId

            listModel.append(item)
        }
        // Emit signal to notify widgets that data has changed
        widgetDataChanged()
    }

    function resetTopBarWidgetsToDefault() {
        var defaultLeft = ["launcherButton", "workspaceSwitcher", "focusedWindow"]
        var defaultCenter = ["music", "clock", "weather"]
        var defaultRight = ["systemTray", "clipboard", "notificationButton", "battery", "controlCenterButton"]
        topBarLeftWidgets = defaultLeft
        topBarCenterWidgets = defaultCenter
        topBarRightWidgets = defaultRight
        updateListModel(leftWidgetsModel, defaultLeft)
        updateListModel(centerWidgetsModel, defaultCenter)
        updateListModel(rightWidgetsModel, defaultRight)
        showLauncherButton = true
        showWorkspaceSwitcher = true
        showFocusedWindow = true
        showWeather = true
        showMusic = true
        showClipboard = true
        showCpuUsage = true
        showMemUsage = true
        showCpuTemp = true
        showGpuTemp = true
        showSystemTray = true
        showClock = true
        showNotificationButton = true
        showBattery = true
        showControlCenterButton = true
        saveSettings()
    }

    // View mode setters
    function setAppLauncherViewMode(mode) {
        appLauncherViewMode = mode
        saveSettings()
    }

    function setSpotlightModalViewMode(mode) {
        spotlightModalViewMode = mode
        saveSettings()
    }

    // Weather location setter
    function setWeatherLocation(displayName, coordinates) {
        weatherLocation = displayName
        weatherCoordinates = coordinates
        saveSettings()
    }

    function setAutoLocation(enabled) {
        useAutoLocation = enabled
        saveSettings()
    }

    function setWeatherEnabled(enabled) {
        weatherEnabled = enabled
        saveSettings()
    }

    // Network preference setter
    function setNetworkPreference(preference) {
        networkPreference = preference
        saveSettings()
    }

    function detectAvailableIconThemes() {
        // First detect system default, then available themes
        systemDefaultDetectionProcess.running = true
    }

    function detectQtTools() {
        qtToolsDetectionProcess.running = true
    }

    function setIconTheme(themeName) {
        iconTheme = themeName
        updateGtkIconTheme(themeName)
        updateQtIconTheme(themeName)
        saveSettings()
        if (typeof Theme !== "undefined" && Theme.currentTheme === Theme.dynamic)
            Theme.generateSystemThemes()
    }

    function updateGtkIconTheme(themeName) {
        var gtkThemeName = (themeName === "System Default") ? systemDefaultIconTheme : themeName
        if (gtkThemeName !== "System Default" && gtkThemeName !== "") {
            var script = "if command -v gsettings >/dev/null 2>&1 && gsettings list-schemas | grep -q org.gnome.desktop.interface; then\n"
                    + "    gsettings set org.gnome.desktop.interface icon-theme '" + gtkThemeName + "'\n" + "    echo 'Updated via gsettings'\n" + "elif command -v dconf >/dev/null 2>&1; then\n" + "    dconf write /org/gnome/desktop/interface/icon-theme \\\"" + gtkThemeName + "\\\"\n"
                    + "    echo 'Updated via dconf'\n" + "fi\n" + "\n" + "# Ensure config directories exist\n" + "mkdir -p " + _configDir + "/gtk-3.0 " + _configDir
                    + "/gtk-4.0\n" + "\n" + "# Update settings.ini files (keep existing gtk-theme-name)\n" + "for config_dir in " + _configDir + "/gtk-3.0 " + _configDir + "/gtk-4.0; do\n"
                    + "    settings_file=\"$config_dir/settings.ini\"\n" + "    if [ -f \"$settings_file\" ]; then\n" + "        # Update existing icon-theme-name line or add it\n" + "        if grep -q '^gtk-icon-theme-name=' \"$settings_file\"; then\n" + "            sed -i 's/^gtk-icon-theme-name=.*/gtk-icon-theme-name=" + gtkThemeName + "/' \"$settings_file\"\n" + "        else\n"
                    + "            # Add icon theme setting to [Settings] section or create it\n" + "            if grep -q '\\[Settings\\]' \"$settings_file\"; then\n" + "                sed -i '/\\[Settings\\]/a gtk-icon-theme-name=" + gtkThemeName + "' \"$settings_file\"\n" + "            else\n" + "                echo -e '\\n[Settings]\\ngtk-icon-theme-name=" + gtkThemeName
                    + "' >> \"$settings_file\"\n" + "            fi\n" + "        fi\n" + "    else\n" + "        # Create new settings.ini file\n" + "        echo -e '[Settings]\\ngtk-icon-theme-name=" + gtkThemeName + "' > \"$settings_file\"\n"
                    + "    fi\n" + "    echo \"Updated $settings_file\"\n" + "done\n" + "\n" + "# Clear icon cache and force refresh\n" + "rm -rf ~/.cache/icon-cache ~/.cache/thumbnails 2>/dev/null || true\n" + "# Send SIGHUP to running GTK applications to reload themes (Fedora-specific)\n" + "pkill -HUP -f 'gtk' 2>/dev/null || true\n"
            Quickshell.execDetached(["sh", "-lc", script])
        }
    }

    function updateQtIconTheme(themeName) {
        var qtThemeName = (themeName === "System Default") ? "" : themeName
        var home = _shq(Paths.strip(root._homeUrl))
        if (!qtThemeName) {
            // When "System Default" is selected, don't modify the config files at all
            // This preserves the user's existing qt6ct configuration
            return
        }
        var script = "mkdir -p " + _configDir + "/qt5ct " + _configDir + "/qt6ct " + _configDir + "/environment.d 2>/dev/null || true\n" + "update_qt_icon_theme() {\n" + "  local config_file=\"$1\"\n"
                + "  local theme_name=\"$2\"\n" + "  if [ -f \"$config_file\" ]; then\n" + "    if grep -q '^\\[Appearance\\]' \"$config_file\"; then\n" + "      if grep -q '^icon_theme=' \"$config_file\"; then\n" + "        sed -i \"s/^icon_theme=.*/icon_theme=$theme_name/\" \"$config_file\"\n" + "      else\n" + "        sed -i \"/^\\[Appearance\\]/a icon_theme=$theme_name\" \"$config_file\"\n" + "      fi\n"
                + "    else\n" + "      printf '\\n[Appearance]\\nicon_theme=%s\\n' \"$theme_name\" >> \"$config_file\"\n" + "    fi\n" + "  else\n" + "    printf '[Appearance]\\nicon_theme=%s\\n' \"$theme_name\" > \"$config_file\"\n" + "  fi\n" + "}\n" + "update_qt_icon_theme " + _configDir + "/qt5ct/qt5ct.conf " + _shq(
                    qtThemeName) + "\n" + "update_qt_icon_theme " + _configDir + "/qt6ct/qt6ct.conf " + _shq(qtThemeName) + "\n" + "rm -rf " + home + "/.cache/icon-cache " + home + "/.cache/thumbnails 2>/dev/null || true\n"
        Quickshell.execDetached(["sh", "-lc", script])
    }

    function applyStoredIconTheme() {
        updateGtkIconTheme(iconTheme)
        updateQtIconTheme(iconTheme)
    }

    // GTK Theme Functions
    function detectAvailableGtkThemes() {
        systemDefaultGtkThemeProcess.running = true
    }

    function setGtkTheme(themeName) {
        gtkTheme = themeName
        updateGtkTheme(themeName)
        saveSettings()
    }

    function updateGtkTheme(themeName) {
        var gtkThemeName = (themeName === "System Default") ? systemDefaultGtkTheme : themeName
        if (gtkThemeName !== "System Default" && gtkThemeName !== "") {
            // Use _shq for proper shell escaping
            var escapedTheme = _shq(gtkThemeName)
            var script = "if command -v gsettings >/dev/null 2>&1 && gsettings list-schemas | grep -q org.gnome.desktop.interface; then\n"
                    + "    gsettings set org.gnome.desktop.interface gtk-theme " + escapedTheme + "\n"
                    + "    echo 'Updated via gsettings'\n"
                    + "elif command -v dconf >/dev/null 2>&1; then\n"
                    + "    dconf write /org/gnome/desktop/interface/gtk-theme " + escapedTheme + "\n"
                    + "    echo 'Updated via dconf'\n"
                    + "fi\n"
                    + "\n"
                    + "# Ensure config directories exist\n"
                    + "mkdir -p " + _configDir + "/gtk-3.0 " + _configDir + "/gtk-4.0\n"
                    + "\n"
                    + "# Update settings.ini files (keep existing icon-theme-name and other settings)\n"
                    + "for config_dir in " + _configDir + "/gtk-3.0 " + _configDir + "/gtk-4.0; do\n"
                    + "    settings_file=\"$config_dir/settings.ini\"\n"
                    + "    if [ -f \"$settings_file\" ]; then\n"
                    + "        # Update existing gtk-theme-name line or add it\n"
                    + "        if grep -q '^gtk-theme-name=' \"$settings_file\"; then\n"
                    + "            sed -i 's/^gtk-theme-name=.*/gtk-theme-name=" + gtkThemeName.replace(/'/g, "'\\''") + "/' \"$settings_file\"\n"
                    + "        else\n"
                    + "            # Add theme setting to [Settings] section or create it\n"
                    + "            if grep -q '\\[Settings\\]' \"$settings_file\"; then\n"
                    + "                sed -i '/\\[Settings\\]/a gtk-theme-name=" + gtkThemeName.replace(/'/g, "'\\''") + "' \"$settings_file\"\n"
                    + "            else\n"
                    + "                echo -e '\\n[Settings]\\ngtk-theme-name=" + gtkThemeName.replace(/'/g, "'\\''") + "' >> \"$settings_file\"\n"
                    + "            fi\n"
                    + "        fi\n"
                    + "    else\n"
                    + "        # Create new settings.ini file\n"
                    + "        echo -e '[Settings]\\ngtk-theme-name=" + gtkThemeName.replace(/'/g, "'\\''") + "' > \"$settings_file\"\n"
                    + "    fi\n"
                    + "    echo \"Updated $settings_file\"\n"
                    + "done\n"
                    + "\n"
                    + "# Update GTK2 config\n"
                    + "if [ ! -f ~/.gtkrc-2.0 ]; then\n"
                    + "    echo 'gtk-theme-name=" + escapedTheme + "' > ~/.gtkrc-2.0\n"
                    + "else\n"
                    + "    if grep -q '^gtk-theme-name=' ~/.gtkrc-2.0; then\n"
                    + "        sed -i 's/^gtk-theme-name=.*/gtk-theme-name=" + escapedTheme + "/' ~/.gtkrc-2.0\n"
                    + "    else\n"
                    + "        echo 'gtk-theme-name=" + escapedTheme + "' >> ~/.gtkrc-2.0\n"
                    + "    fi\n"
                    + "fi\n"
                    + "\n"
                    + "# Send SIGHUP to running GTK applications to reload themes (optional, may not work on all systems)\n"
                    + "pkill -HUP -f 'gtk' 2>/dev/null || true\n"
            
            Quickshell.execDetached(["sh", "-lc", script])
        }
    }

    function applyStoredGtkTheme() {
        updateGtkTheme(gtkTheme)
    }

    // QT Theme Functions
    function detectAvailableQtThemes() {
        systemDefaultQtThemeProcess.running = true
    }

    function setQtTheme(themeName) {
        qtTheme = themeName
        updateQtTheme(themeName)
        saveSettings()
    }

    function updateQtTheme(themeName) {
        var qtThemeName = (themeName === "System Default") ? systemDefaultQtTheme : themeName
        if (!qtThemeName || qtThemeName === "System Default" || qtThemeName === "") {
            // When "System Default" is selected, don't modify the config files at all
            // This preserves the user's existing qt5ct/qt6ct configuration
            return
        }
        
        // Use _shq for proper shell escaping
        var escapedTheme = _shq(qtThemeName)
        var home = _shq(Paths.strip(root._homeUrl))
        
        var script = "mkdir -p " + _configDir + "/qt5ct " + _configDir + "/qt6ct 2>/dev/null || true\n"
                + "update_qt_theme() {\n"
                + "  local config_file=\"$1\"\n"
                + "  local theme_name=\"$2\"\n"
                + "  if [ -f \"$config_file\" ]; then\n"
                + "    if grep -q '^\\[Appearance\\]' \"$config_file\"; then\n"
                + "      if grep -q '^style=' \"$config_file\"; then\n"
                + "        sed -i \"s/^style=.*/style=$theme_name/\" \"$config_file\"\n"
                + "      else\n"
                + "        sed -i \"/^\\[Appearance\\]/a style=$theme_name\" \"$config_file\"\n"
                + "      fi\n"
                + "    else\n"
                + "      printf '\\n[Appearance]\\nstyle=%s\\n' \"$theme_name\" >> \"$config_file\"\n"
                + "    fi\n"
                + "  else\n"
                + "    printf '[Appearance]\\nstyle=%s\\n' \"$theme_name\" > \"$config_file\"\n"
                + "  fi\n"
                + "}\n"
                + "update_qt_theme " + _configDir + "/qt5ct/qt5ct.conf " + escapedTheme + "\n"
                + "update_qt_theme " + _configDir + "/qt6ct/qt6ct.conf " + escapedTheme + "\n"
                + "rm -rf " + home + "/.cache/icon-cache " + home + "/.cache/thumbnails 2>/dev/null || true\n"
        
        Quickshell.execDetached(["sh", "-lc", script])
    }

    function applyStoredQtTheme() {
        updateQtTheme(qtTheme)
    }

    // GNOME Shell Theme Functions
    function detectAvailableShellThemes() {
        userThemeExtensionCheckProcess.running = true
    }

    function setShellTheme(themeName) {
        shellTheme = themeName
        updateShellTheme(themeName)
        saveSettings()
    }

    function updateShellTheme(themeName) {
        var shellThemeName = (themeName === "System Default") ? systemDefaultShellTheme : themeName
        var home = _shq(Paths.strip(root._homeUrl))
        
        if (shellThemeName !== "System Default" && shellThemeName !== "") {
            // Use _shq for proper shell escaping
            var escapedTheme = _shq(shellThemeName)
            
            var script = "# Try extension method first (preferred)\n"
                    + "if command -v gsettings >/dev/null 2>&1 && gsettings list-schemas | grep -q org.gnome.shell.extensions.user-theme; then\n"
                    + "    gsettings set org.gnome.shell.extensions.user-theme name " + escapedTheme + "\n"
                    + "    echo 'Updated via user-theme extension (gsettings)'\n"
                    + "elif command -v dconf >/dev/null 2>&1 && dconf list /org/gnome/shell/extensions/user-theme/ 2>/dev/null | grep -q name; then\n"
                    + "    dconf write /org/gnome/shell/extensions/user-theme/name " + escapedTheme + "\n"
                    + "    echo 'Updated via user-theme extension (dconf)'\n"
                    + "else\n"
                    + "    # Fallback: Copy theme CSS to ~/.config/gnome-shell/gnome-shell.css\n"
                    + "    # This works without the extension but only applies CSS (not full theme assets)\n"
                    + "    theme_css=\"\"\n"
                    + "    for dir in " + home + "/.themes " + home + "/.local/share/themes /usr/share/themes; do\n"
                    + "        if [ -f \"$dir/" + shellThemeName.replace(/'/g, "'\\''") + "/gnome-shell/gnome-shell.css\" ]; then\n"
                    + "            theme_css=\"$dir/" + shellThemeName.replace(/'/g, "'\\''") + "/gnome-shell/gnome-shell.css\"\n"
                    + "            break\n"
                    + "        fi\n"
                    + "    done\n"
                    + "    \n"
                    + "    if [ -n \"$theme_css\" ] && [ -f \"$theme_css\" ]; then\n"
                    + "        mkdir -p " + home + "/.config/gnome-shell\n"
                    + "        cp \"$theme_css\" " + home + "/.config/gnome-shell/gnome-shell.css\n"
                    + "        echo 'Updated via CSS file copy (extension not available)'\n"
                    + "    else\n"
                    + "        echo 'Error: Theme CSS file not found'\n"
                    + "        exit 1\n"
                    + "    fi\n"
                    + "fi\n"
            
            Quickshell.execDetached(["sh", "-lc", script])
            
            if (typeof ToastService !== "undefined") {
                if (userThemeExtensionAvailable && userThemeExtensionEnabled) {
                    ToastService.showInfo("Shell theme changed", "Restart GNOME Shell to see changes:\nPress Alt+F2, type 'r', then press Enter")
                } else {
                    ToastService.showInfo("Shell theme changed (CSS only)", "Applied theme CSS without extension.\nNote: Only CSS is applied, not full theme assets.\nRestart GNOME Shell (Alt+F2, type 'r', Enter) to see changes.")
                }
            }
        } else if (themeName === "System Default") {
            // Reset to default
            var script = "# Try extension method first\n"
                    + "if command -v gsettings >/dev/null 2>&1 && gsettings list-schemas | grep -q org.gnome.shell.extensions.user-theme; then\n"
                    + "    gsettings reset org.gnome.shell.extensions.user-theme name\n"
                    + "    echo 'Reset to system default (extension)'\n"
                    + "elif command -v dconf >/dev/null 2>&1 && dconf list /org/gnome/shell/extensions/user-theme/ 2>/dev/null | grep -q name; then\n"
                    + "    dconf reset /org/gnome/shell/extensions/user-theme/name\n"
                    + "    echo 'Reset to system default (extension)'\n"
                    + "else\n"
                    + "    # Fallback: Remove custom CSS file\n"
                    + "    if [ -f " + home + "/.config/gnome-shell/gnome-shell.css ]; then\n"
                    + "        rm " + home + "/.config/gnome-shell/gnome-shell.css\n"
                    + "        echo 'Removed custom CSS file'\n"
                    + "    fi\n"
                    + "    echo 'Reset to system default (CSS fallback)'\n"
                    + "fi\n"
            Quickshell.execDetached(["sh", "-lc", script])
            
            if (typeof ToastService !== "undefined") {
                ToastService.showInfo("Shell theme reset", "Restart GNOME Shell to see changes:\nPress Alt+F2, type 'r', then press Enter")
            }
        }
    }

    function applyStoredShellTheme() {
        updateShellTheme(shellTheme)
    }

    // Cursor Theme Functions
    function detectAvailableCursorThemes() {
        systemDefaultCursorThemeProcess.running = true
    }

    function setCursorTheme(themeName, size) {
        cursorTheme = themeName
        if (size !== undefined && size > 0) cursorSize = size
        updateCursorTheme(themeName, cursorSize)
        saveSettings()
    }

    function updateCursorTheme(themeName, size) {
        var cursorThemeName = (themeName === "System Default") ? systemDefaultCursorTheme : themeName
        var cursorSizeValue = size || 24
        
        if (cursorThemeName !== "System Default" && cursorThemeName !== "" && cursorSizeValue > 0) {
            // Use _shq for proper shell escaping
            var escapedTheme = _shq(cursorThemeName)
            var home = _shq(Paths.strip(root._homeUrl))
            
            var script = "# Update via gsettings/dconf\n"
                    + "if command -v gsettings >/dev/null 2>&1 && gsettings list-schemas | grep -q org.gnome.desktop.interface; then\n"
                    + "    gsettings set org.gnome.desktop.interface cursor-theme " + escapedTheme + "\n"
                    + "    gsettings set org.gnome.desktop.interface cursor-size " + cursorSizeValue + "\n"
                    + "    echo 'Updated via gsettings'\n"
                    + "elif command -v dconf >/dev/null 2>&1; then\n"
                    + "    dconf write /org/gnome/desktop/interface/cursor-theme " + escapedTheme + "\n"
                    + "    dconf write /org/gnome/desktop/interface/cursor-size " + cursorSizeValue + "\n"
                    + "    echo 'Updated via dconf'\n"
                    + "fi\n"
                    + "\n"
                    + "# Update GTK settings.ini files\n"
                    + "mkdir -p " + _configDir + "/gtk-3.0 " + _configDir + "/gtk-4.0\n"
                    + "\n"
                    + "for config_dir in " + _configDir + "/gtk-3.0 " + _configDir + "/gtk-4.0; do\n"
                    + "    settings_file=\"$config_dir/settings.ini\"\n"
                    + "    if [ -f \"$settings_file\" ]; then\n"
                    + "        # Update cursor theme name\n"
                    + "        if grep -q '^gtk-cursor-theme-name=' \"$settings_file\"; then\n"
                    + "            sed -i 's/^gtk-cursor-theme-name=.*/gtk-cursor-theme-name=" + cursorThemeName.replace(/'/g, "'\\''") + "/' \"$settings_file\"\n"
                    + "        else\n"
                    + "            if grep -q '\\[Settings\\]' \"$settings_file\"; then\n"
                    + "                sed -i '/\\[Settings\\]/a gtk-cursor-theme-name=" + cursorThemeName.replace(/'/g, "'\\''") + "' \"$settings_file\"\n"
                    + "            else\n"
                    + "                echo -e '\\n[Settings]\\ngtk-cursor-theme-name=" + cursorThemeName.replace(/'/g, "'\\''") + "' >> \"$settings_file\"\n"
                    + "            fi\n"
                    + "        fi\n"
                    + "        # Update cursor size\n"
                    + "        if grep -q '^gtk-cursor-theme-size=' \"$settings_file\"; then\n"
                    + "            sed -i 's/^gtk-cursor-theme-size=.*/gtk-cursor-theme-size=" + cursorSizeValue + "/' \"$settings_file\"\n"
                    + "        else\n"
                    + "            if grep -q '\\[Settings\\]' \"$settings_file\"; then\n"
                    + "                sed -i '/\\[Settings\\]/a gtk-cursor-theme-size=" + cursorSizeValue + "' \"$settings_file\"\n"
                    + "            fi\n"
                    + "        fi\n"
                    + "    else\n"
                    + "        # Create new settings.ini file\n"
                    + "        echo -e '[Settings]\\ngtk-cursor-theme-name=" + cursorThemeName.replace(/'/g, "'\\''") + "\\ngtk-cursor-theme-size=" + cursorSizeValue + "' > \"$settings_file\"\n"
                    + "    fi\n"
                    + "    echo \"Updated $settings_file\"\n"
                    + "done\n"
                    + "\n"
                    + "# Update X11 cursor theme\n"
                    + "xresources_file=" + home + "/.Xresources\n"
                    + "if [ -f \"$xresources_file\" ]; then\n"
                    + "    if grep -q '^Xcursor\\.theme:' \"$xresources_file\"; then\n"
                    + "        sed -i \"s/^Xcursor\\.theme:.*/Xcursor.theme: " + cursorThemeName.replace(/[.\\]/g, "\\$&") + "/\" \"$xresources_file\"\n"
                    + "    else\n"
                    + "        echo \"Xcursor.theme: " + cursorThemeName.replace(/[.\\]/g, "\\$&") + "\" >> \"$xresources_file\"\n"
                    + "    fi\n"
                    + "    if grep -q '^Xcursor\\.size:' \"$xresources_file\"; then\n"
                    + "        sed -i \"s/^Xcursor\\.size:.*/Xcursor.size: " + cursorSizeValue + "/\" \"$xresources_file\"\n"
                    + "    else\n"
                    + "        echo \"Xcursor.size: " + cursorSizeValue + "\" >> \"$xresources_file\"\n"
                    + "    fi\n"
                    + "    # Apply Xresources changes\n"
                    + "    if command -v xrdb >/dev/null 2>&1; then\n"
                    + "        xrdb -merge \"$xresources_file\"\n"
                    + "    fi\n"
                    + "else\n"
                    + "    echo \"Xcursor.theme: " + cursorThemeName.replace(/[.\\]/g, "\\$&") + "\" > \"$xresources_file\"\n"
                    + "    echo \"Xcursor.size: " + cursorSizeValue + "\" >> \"$xresources_file\"\n"
                    + "    if command -v xrdb >/dev/null 2>&1; then\n"
                    + "        xrdb -merge \"$xresources_file\"\n"
                    + "    fi\n"
                    + "fi\n"
                    + "\n"
                    + "# Update GTK2 config\n"
                    + "gtk2_file=" + home + "/.gtkrc-2.0\n"
                    + "if [ ! -f \"$gtk2_file\" ]; then\n"
                    + "    echo 'gtk-cursor-theme-name=" + escapedTheme + "' > \"$gtk2_file\"\n"
                    + "    echo 'gtk-cursor-theme-size=" + cursorSizeValue + "' >> \"$gtk2_file\"\n"
                    + "else\n"
                    + "    if grep -q '^gtk-cursor-theme-name=' \"$gtk2_file\"; then\n"
                    + "        sed -i 's/^gtk-cursor-theme-name=.*/gtk-cursor-theme-name=" + escapedTheme + "/' \"$gtk2_file\"\n"
                    + "    else\n"
                    + "        echo 'gtk-cursor-theme-name=" + escapedTheme + "' >> \"$gtk2_file\"\n"
                    + "    fi\n"
                    + "    if grep -q '^gtk-cursor-theme-size=' \"$gtk2_file\"; then\n"
                    + "        sed -i 's/^gtk-cursor-theme-size=.*/gtk-cursor-theme-size=" + cursorSizeValue + "/' \"$gtk2_file\"\n"
                    + "    else\n"
                    + "        echo 'gtk-cursor-theme-size=" + cursorSizeValue + "' >> \"$gtk2_file\"\n"
                    + "    fi\n"
                    + "fi\n"
            
            Quickshell.execDetached(["sh", "-lc", script])
        }
    }

    function applyStoredCursorTheme() {
        updateCursorTheme(cursorTheme, cursorSize)
    }

    function setUseOSLogo(enabled) {
        useOSLogo = enabled
        saveSettings()
    }

    function setOSLogoColorOverride(color) {
        osLogoColorOverride = color
        saveSettings()
    }

    function setOSLogoBrightness(brightness) {
        osLogoBrightness = brightness
        saveSettings()
    }

    function setOSLogoContrast(contrast) {
        osLogoContrast = contrast
        saveSettings()
    }

    function setUseCustomLauncherImage(enabled) {
        useCustomLauncherImage = enabled
        saveSettings()
    }

    function setCustomLauncherImagePath(path) {
        customLauncherImagePath = path
        saveSettings()
    }

    function setLauncherLogoSize(size) {
        launcherLogoSize = size
        saveSettings()
    }

    function setWallpaperDynamicTheming(enabled) {
        wallpaperDynamicTheming = enabled
        saveSettings()
    }

    function setFontFamily(family) {
        fontFamily = family
        saveSettings()
    }

    function setFontWeight(weight) {
        fontWeight = weight
        saveSettings()
    }

    function setMonoFontFamily(family) {
        monoFontFamily = family
        saveSettings()
    }

    function setFontScale(scale) {
        fontScale = scale
        saveSettings()
    }

    function setGtkThemingEnabled(enabled) {
        gtkThemingEnabled = enabled
        saveSettings()
        if (enabled && typeof Theme !== "undefined") {
            Theme.generateSystemThemesFromCurrentTheme()
        }
    }

    function setQtThemingEnabled(enabled) {
        qtThemingEnabled = enabled
        saveSettings()
        if (enabled && typeof Theme !== "undefined") {
            Theme.generateSystemThemesFromCurrentTheme()
        }
    }

    function setShowDock(enabled) {
        showDock = enabled
        saveSettings()
    }

    function setDockAutoHide(enabled) {
        dockAutoHide = enabled
        saveSettings()
    }

    function setDockGroupApps(enabled) {
        dockGroupApps = enabled
        saveSettings()
    }

    function setDockHideOnGames(enabled) {
        dockHideOnGames = enabled
        saveSettings()
    }

    function setDockExpandToScreen(enabled) {
        dockExpandToScreen = enabled
        saveSettings()
    }

    function setDockCenterApps(enabled) {
        dockCenterApps = enabled
        saveSettings()
    }

    function setDockBottomGap(gap) {
        dockBottomGap = gap
        saveSettings()
    }

    function setDockExclusiveZone(zone) {
        dockExclusiveZone = zone
        saveSettings()
    }

    function setDockLeftPadding(padding) {
        dockLeftPadding = padding
        saveSettings()
    }

    function setDockRightPadding(padding) {
        dockRightPadding = padding
        saveSettings()
    }

    function setDockTopPadding(padding) {
        dockTopPadding = padding
        saveSettings()
    }

    function setDockBottomPadding(padding) {
        dockBottomPadding = padding
        saveSettings()
    }

    function setDockTooltipsEnabled(enabled) {
        dockTooltipsEnabled = enabled
        saveSettings()
    }

    function setDockIconSize(size) {
        dockIconSize = size
        saveSettings()
    }

    function setDockIconSpacing(spacing) {
        dockIconSpacing = spacing
        saveSettings()
    }

    function setDockWidgetAreaOpacity(opacity) {
        dockWidgetAreaOpacity = opacity
        saveSettings()
    }

    function setDockBackgroundTintOpacity(opacity) {
        dockBackgroundTintOpacity = opacity
        saveSettings()
    }

    function setDockCollapsedHeight(height) {
        dockCollapsedHeight = height
        saveSettings()
    }

    function setDockSlideDistance(distance) {
        dockSlideDistance = distance
        saveSettings()
    }

    function setDockAnimationDuration(ms) {
        dockAnimationDuration = ms
        saveSettings()
    }

    function setDockLeftWidgetAreaMinWidth(width) {
        dockLeftWidgetAreaMinWidth = width
        saveSettings()
    }

    function setDockRightWidgetAreaMinWidth(width) {
        dockRightWidgetAreaMinWidth = width
        saveSettings()
    }

    function setCornerRadius(radius) {
        cornerRadius = radius
        saveSettings()
    }

    function setHyprlandBlurSize(size) {
        hyprlandBlurSize = size
        saveSettings()
        // Apply blur settings to Hyprland if available
        if (typeof CompositorService !== 'undefined' && CompositorService.isHyprland) {
            CompositorService.applyBlurSettings(hyprlandBlurSize, hyprlandBlurPasses)
        }
    }

    function setHyprlandBlurPasses(passes) {
        hyprlandBlurPasses = passes
        saveSettings()
        // Apply blur settings to Hyprland if available
        if (typeof CompositorService !== 'undefined' && CompositorService.isHyprland) {
            CompositorService.applyBlurSettings(hyprlandBlurSize, hyprlandBlurPasses)
        }
    }

    function setNotificationOverlayEnabled(enabled) {
        notificationOverlayEnabled = enabled
        saveSettings()
    }

    function setTopBarAutoHide(enabled) {
        topBarAutoHide = enabled
        saveSettings()
    }

    function setTopBarOpenOnOverview(enabled) {
        topBarOpenOnOverview = enabled
        saveSettings()
    }

    function setTopBarVisible(visible) {
        topBarVisible = visible
        saveSettings()
    }

    function toggleTopBarVisible() {
        topBarVisible = !topBarVisible
        saveSettings()
    }

    function setNotificationTimeoutLow(timeout) {
        notificationTimeoutLow = timeout
        saveSettings()
    }

    function setNotificationTimeoutNormal(timeout) {
        notificationTimeoutNormal = timeout
        saveSettings()
    }

    function setNotificationTimeoutCritical(timeout) {
        notificationTimeoutCritical = timeout
        saveSettings()
    }

    function setTopBarSpacing(spacing) {
        topBarSpacing = spacing
        saveSettings()
    }

    function setTopBarBottomGap(gap) {
        topBarBottomGap = gap
        saveSettings()
    }

    function setTopBarInnerPadding(padding) {
        topBarInnerPadding = padding
        saveSettings()
    }

    function setTopBarSquareCorners(enabled) {
        topBarSquareCorners = enabled
        saveSettings()
    }

    function setTopBarNoBackground(enabled) {
        topBarNoBackground = enabled
        saveSettings()
    }

    function setTopBarGothCornersEnabled(enabled) {
        topBarGothCornersEnabled = enabled
        saveSettings()
    }

    function setLockScreenShowPowerActions(enabled) {
        lockScreenShowPowerActions = enabled
        saveSettings()
    }

    function setHideBrightnessSlider(enabled) {
        hideBrightnessSlider = enabled
        saveSettings()
    }

    function setWidgetBackgroundColor(color) {
        widgetBackgroundColor = color
        saveSettings()
    }

    function setScreenPreferences(prefs) {
        screenPreferences = prefs
        saveSettings()
    }

    function setDesktopWidgetsScreen(screenName) {
        var prefs = screenPreferences || {}
        prefs["desktopWidgets"] = [screenName]
        screenPreferences = prefs
        saveSettings()
    }

    function getFilteredScreens(componentId) {
        var prefs = screenPreferences && screenPreferences[componentId] || ["all"]
        if (prefs.includes("all")) {
            return Quickshell.screens
        }
        return Quickshell.screens.filter(screen => prefs.includes(screen.name))
    }

    function _shq(s) {
        return "'" + String(s).replace(/'/g, "'\\''") + "'"
    }

    Component.onCompleted: {
        loadSettings()
        fontCheckTimer.start()
        initializeListModels()
        terminalDetectionProcess.running = true
        aurHelperDetectionProcess.running = true
        detectAvailableGtkThemes()
        detectAvailableQtThemes()
        detectAvailableShellThemes()
        detectAvailableCursorThemes()
        
        // Set desktop widgets to DP-2 if not already configured
        if (!screenPreferences || !screenPreferences["desktopWidgets"]) {
            // console.log("SettingsData: Setting desktop widgets to DP-2");
            setDesktopWidgetsScreen("DP-2");
        }
        
        // Apply Hyprland blur settings on startup
        Qt.callLater(function() {
            if (typeof CompositorService !== 'undefined' && CompositorService.isHyprland) {
                CompositorService.applyBlurSettings(hyprlandBlurSize, hyprlandBlurPasses)
            }
        })
        
        // Initialize launcher logo auto-sync if enabled
        if (launcherLogoAutoSync) {
            Qt.callLater(() => {
                syncLauncherLogoWithWallpaper()
            })
        }
    }

    Connections {
        target: typeof Theme !== "undefined" ? Theme : null
        function onColorUpdateTriggerChanged() {
            // When colorUpdateTrigger changes, it means matugen colors were updated
            if (launcherLogoAutoSync) {
                // Use a small delay to ensure Theme.primary has been updated
                Qt.callLater(() => {
                    syncLauncherLogoWithWallpaper()
                })
            }
        }
    }

    Connections {
        target: typeof ColorPaletteService !== "undefined" ? ColorPaletteService : null
        function onColorsExtracted() {
            // When colors are extracted from wallpaper, sync if auto-sync is enabled
            if (launcherLogoAutoSync) {
                // Use a small delay to ensure Theme.primary has been updated
                Qt.callLater(() => {
                    syncLauncherLogoWithWallpaper()
                })
            }
        }
    }

    Connections {
        target: typeof SessionData !== "undefined" ? SessionData : null
        function onWallpaperPathChanged() {
            // When wallpaper changes, wait for colors to be extracted
            if (launcherLogoAutoSync) {
                // Use a longer delay to allow matugen to extract colors
                Qt.callLater(() => {
                    Qt.callLater(() => {
                        syncLauncherLogoWithWallpaper()
                    })
                })
            }
        }
    }

    onLauncherLogoAutoSyncChanged: {
        if (launcherLogoAutoSync) {
            syncLauncherLogoWithWallpaper()
        }
    }

    ListModel {
        id: leftWidgetsModel
    }

    ListModel {
        id: centerWidgetsModel
    }

    ListModel {
        id: rightWidgetsModel
    }

    ListModel {
        id: dockLeftWidgetsModel
    }

    ListModel {
        id: dockRightWidgetsModel
    }

    Timer {
        id: fontCheckTimer

        interval: 3000
        repeat: false
        onTriggered: {
            var availableFonts = Qt.fontFamilies()
            var missingFonts = []
            if (fontFamily === defaultFontFamily && !availableFonts.includes(defaultFontFamily))
            missingFonts.push(defaultFontFamily)

            if (monoFontFamily === defaultMonoFontFamily && !availableFonts.includes(defaultMonoFontFamily))
            missingFonts.push(defaultMonoFontFamily)

            if (missingFonts.length > 0) {
                var message = "Missing fonts: " + missingFonts.join(", ") + ". Using system defaults."
                ToastService.showWarning(message)
            }
        }
    }

    property bool hasTriedDefaultSettings: false

    FileView {
        id: settingsFile

        path: StandardPaths.writableLocation(StandardPaths.ConfigLocation) + "/DarkMaterialShell/settings.json"
        blockLoading: true
        blockWrites: true
        atomicWrites: true
        watchChanges: true
        onLoaded: {
            parseSettings(settingsFile.text())
            hasTriedDefaultSettings = false
        }
        onLoadFailed: error => {
            if (!hasTriedDefaultSettings) {
                hasTriedDefaultSettings = true
                defaultSettingsCheckProcess.running = true
            } else {
                applyStoredTheme()
            }
        }
    }

    Process {
        id: systemDefaultDetectionProcess

        command: ["sh", "-c", "gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null | sed \"s/'//g\" || echo ''"]
        running: false
        onExited: exitCode => {
            if (exitCode === 0 && stdout && stdout.length > 0)
            systemDefaultIconTheme = stdout.trim()
            else
            systemDefaultIconTheme = ""
            iconThemeDetectionProcess.running = true
        }
    }

    Process {
        id: iconThemeDetectionProcess

        command: ["sh", "-c", "find /usr/share/icons ~/.local/share/icons ~/.icons -maxdepth 1 -type d 2>/dev/null | sed 's|.*/||' | grep -v '^icons$' | sort -u"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                var detectedThemes = ["System Default"]
                if (text && text.trim()) {
                    var themes = text.trim().split('\n')
                    for (var i = 0; i < themes.length; i++) {
                        var theme = themes[i].trim()
                        if (theme && theme !== "" && theme !== "default" && theme !== "hicolor" && theme !== "locolor")
                        detectedThemes.push(theme)
                    }
                }
                availableIconThemes = detectedThemes
            }
        }
    }

    Process {
        id: qtToolsDetectionProcess

        command: ["sh", "-c", "echo -n 'qt5ct:'; command -v qt5ct >/dev/null && echo 'true' || echo 'false'; echo -n 'qt6ct:'; command -v qt6ct >/dev/null && echo 'true' || echo 'false'; echo -n 'gtk:'; (command -v gsettings >/dev/null || command -v dconf >/dev/null) && echo 'true' || echo 'false'"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                if (text && text.trim()) {
                    var lines = text.trim().split('\n')
                    for (var i = 0; i < lines.length; i++) {
                        var line = lines[i]
                        if (line.startsWith('qt5ct:'))
                        qt5ctAvailable = line.split(':')[1] === 'true'
                        else if (line.startsWith('qt6ct:'))
                        qt6ctAvailable = line.split(':')[1] === 'true'
                        else if (line.startsWith('gtk:'))
                        gtkAvailable = line.split(':')[1] === 'true'
                    }
                }
            }
        }
    }

    // GTK Theme Detection Processes
    Process {
        id: systemDefaultGtkThemeProcess
        
        command: ["sh", "-c", "gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null | sed \"s/'//g\" || echo ''"]
        running: false
        onExited: exitCode => {
            if (exitCode === 0 && stdout && stdout.length > 0)
                systemDefaultGtkTheme = stdout.trim()
            else
                systemDefaultGtkTheme = ""
            gtkThemeDetectionProcess.running = true
        }
    }

    Process {
        id: gtkThemeDetectionProcess
        
        // Find themes with gtk-3.0 or gtk-4.0 subdirectories (validates theme structure)
        command: ["sh", "-c", "for dir in /usr/share/themes ~/.local/share/themes ~/.themes; do [ -d \"$dir\" ] && find \"$dir\" -maxdepth 1 -type d -exec sh -c 'test -d \"$1/gtk-3.0\" || test -d \"$1/gtk-4.0\"' _ {} \\; -print 2>/dev/null; done | sed 's|.*/||' | sort -u"]
        running: false
        
        stdout: StdioCollector {
            onStreamFinished: {
                var detectedThemes = ["System Default"]
                if (text && text.trim()) {
                    var themes = text.trim().split('\n')
                    for (var i = 0; i < themes.length; i++) {
                        var theme = themes[i].trim()
                        // Filter out invalid entries
                        if (theme && theme !== "" && theme !== "default" && theme !== "hicolor" && theme !== "locolor") {
                            detectedThemes.push(theme)
                        }
                    }
                }
                availableGtkThemes = detectedThemes
            }
        }
    }

    // QT Theme Detection Processes
    Process {
        id: systemDefaultQtThemeProcess
        
        command: ["sh", "-c", "qt5_theme=\"\"; qt6_theme=\"\"; if [ -f ~/.config/qt5ct/qt5ct.conf ]; then qt5_theme=$(grep '^style=' ~/.config/qt5ct/qt5ct.conf 2>/dev/null | cut -d'=' -f2 | tr -d ' ' | head -n1); fi; if [ -f ~/.config/qt6ct/qt6ct.conf ]; then qt6_theme=$(grep '^style=' ~/.config/qt6ct/qt6ct.conf 2>/dev/null | cut -d'=' -f2 | tr -d ' ' | head -n1); fi; if [ -n \"$qt6_theme\" ]; then echo \"$qt6_theme\"; elif [ -n \"$qt5_theme\" ]; then echo \"$qt5_theme\"; else echo ''; fi"]
        running: false
        onExited: exitCode => {
            if (exitCode === 0 && stdout && stdout.length > 0) {
                var theme = stdout.trim()
                systemDefaultQtTheme = theme || ""
            } else {
                systemDefaultQtTheme = ""
            }
            qtThemeDetectionProcess.running = true
        }
    }

    Process {
        id: qtThemeDetectionProcess
        
        command: ["sh", "-c", `
            themes="Fusion\\nWindows\\nWindowsVista\\nGTK+\\n"
            
            # Check qt5ct/qt6ct theme/style directories (standard KDE locations)
            # These directories may contain additional style plugins or themes
            for base_dir in /usr/share/qt5ct /usr/share/qt6ct ~/.local/share/qt5ct ~/.local/share/qt6ct; do
                if [ -d "$base_dir" ]; then
                    # Check for themes directory
                    if [ -d "$base_dir/themes" ]; then
                        qt_themes=$(find "$base_dir/themes" -maxdepth 1 -type d ! -path "$base_dir/themes" 2>/dev/null | sed 's|.*/||' | sort -u)
                        if [ -n "$qt_themes" ]; then
                            themes="$themes$qt_themes\\n"
                        fi
                    fi
                    # Check for styles directory (some installations use this)
                    if [ -d "$base_dir/styles" ]; then
                        qt_styles=$(find "$base_dir/styles" -maxdepth 1 -type d ! -path "$base_dir/styles" 2>/dev/null | sed 's|.*/||' | sort -u)
                        if [ -n "$qt_styles" ]; then
                            themes="$themes$qt_styles\\n"
                        fi
                    fi
                    # Check for plugins directory (may contain style plugins)
                    if [ -d "$base_dir/plugins" ]; then
                        qt_plugins=$(find "$base_dir/plugins" -maxdepth 1 -type d ! -path "$base_dir/plugins" 2>/dev/null | sed 's|.*/||' | sort -u)
                        if [ -n "$qt_plugins" ]; then
                            themes="$themes$qt_plugins\\n"
                        fi
                    fi
                fi
            done
            
            # Check for Kvantum themes (KDE's popular theme engine)
            if [ -d /usr/share/Kvantum ] || [ -d ~/.config/Kvantum ]; then
                kvantum_themes=$(find /usr/share/Kvantum ~/.config/Kvantum -maxdepth 1 -type d -name "Kv*" 2>/dev/null | sed 's|.*/||' | sort -u)
                if [ -n "$kvantum_themes" ]; then
                    themes="$themes$kvantum_themes\\n"
                fi
            fi
            
            # Also check KDE-specific locations for QT styles
            # KDE may install additional QT styles in these locations
            for kde_dir in /usr/share/qt5/plugins/styles /usr/share/qt6/plugins/styles ~/.local/share/qt5/plugins/styles ~/.local/share/qt6/plugins/styles; do
                if [ -d "$kde_dir" ]; then
                    kde_styles=$(find "$kde_dir" -maxdepth 1 -type f -name "*.so" 2>/dev/null | sed 's|.*/||' | sed 's|^libq||' | sed 's|style\\.so$||' | sed 's|Style\\.so$||' | sort -u)
                    if [ -n "$kde_styles" ]; then
                        themes="$themes$kde_styles\\n"
                    fi
                fi
            done
            
            # Check KDE Plasma theme directories
            # Plasma themes may include QT styles or be usable as QT theme names
            for plasma_dir in /usr/share/plasma/look-and-feel /usr/share/plasma/desktoptheme ~/.local/share/plasma/look-and-feel ~/.local/share/plasma/desktoptheme; do
                if [ -d "$plasma_dir" ]; then
                    # Extract theme names from Plasma directories
                    # Handle both simple names (MacTahoe-Dark) and app IDs (com.github.vinceliuice.MacTahoe-Dark)
                    plasma_themes=$(find "$plasma_dir" -maxdepth 1 -type d ! -path "$plasma_dir" 2>/dev/null | sed 's|.*/||' | while read theme_name; do
                        # If it's an app ID (contains dots), extract the last part after the last dot
                        if echo "$theme_name" | grep -q '\.'; then
                            echo "$theme_name" | sed 's|.*\.||'
                        else
                            echo "$theme_name"
                        fi
                    done | sort -u)
                    if [ -n "$plasma_themes" ]; then
                        themes="$themes$plasma_themes\\n"
                    fi
                fi
            done
            
            echo -e "$themes" | sort -u
        `]
        running: false
        
        stdout: StdioCollector {
            onStreamFinished: {
                var detectedThemes = ["System Default"]
                if (text && text.trim()) {
                    var themes = text.trim().split('\n')
                    for (var i = 0; i < themes.length; i++) {
                        var theme = themes[i].trim()
                        if (theme && theme !== "" && theme !== "default")
                            detectedThemes.push(theme)
                    }
                }
                availableQtThemes = detectedThemes
            }
        }
    }

    // GNOME Shell Theme Detection Processes
    Process {
        id: userThemeExtensionCheckProcess
        
        command: ["sh", "-c", "if command -v gsettings >/dev/null 2>&1 && gsettings list-schemas | grep -q org.gnome.shell.extensions.user-theme; then echo 'available'; gsettings get org.gnome.shell.extensions.user-theme name 2>/dev/null | sed \"s/'//g\" || echo ''; else echo ''; fi"]
        running: false
        onExited: exitCode => {
            if (exitCode === 0 && stdout && stdout.length > 0) {
                var lines = stdout.trim().split('\n')
                if (lines.length > 0 && lines[0] === 'available') {
                    userThemeExtensionAvailable = true
                    if (lines.length > 1 && lines[1].trim() !== '') {
                        systemDefaultShellTheme = lines[1].trim()
                    } else {
                        systemDefaultShellTheme = ""
                    }
                    // Check if extension is enabled
                    extensionEnabledCheckProcess.running = true
                } else {
                    userThemeExtensionAvailable = false
                    userThemeExtensionEnabled = false
                    systemDefaultShellTheme = ""
                    shellThemeDetectionProcess.running = true
                }
            } else {
                userThemeExtensionAvailable = false
                userThemeExtensionEnabled = false
                systemDefaultShellTheme = ""
                shellThemeDetectionProcess.running = true
            }
        }
    }

    Process {
        id: extensionEnabledCheckProcess
        
        command: ["sh", "-c", "gsettings get org.gnome.shell enabled-extensions 2>/dev/null | grep -o 'user-theme' | head -n1"]
        running: false
        onExited: exitCode => {
            if (exitCode === 0 && stdout && stdout.trim() === 'user-theme') {
                userThemeExtensionEnabled = true
            } else {
                userThemeExtensionEnabled = false
            }
            shellThemeDetectionProcess.running = true
        }
    }

    Process {
        id: shellThemeDetectionProcess
        
        // Find themes with gnome-shell subdirectory containing gnome-shell.css
        // Use -exec to avoid subshell issues with while read loops
        command: ["sh", "-c", "for dir in /usr/share/themes ~/.local/share/themes ~/.themes; do [ -d \"$dir\" ] && find \"$dir\" -maxdepth 1 -type d -exec sh -c 'test -f \"$1/gnome-shell/gnome-shell.css\"' _ {} \\; -print 2>/dev/null; done | sed 's|.*/||' | sort -u"]
        running: false
        
        stdout: StdioCollector {
            onStreamFinished: {
                var detectedThemes = ["System Default"]
                if (text && text.trim()) {
                    var themes = text.trim().split('\n')
                    for (var i = 0; i < themes.length; i++) {
                        var theme = themes[i].trim()
                        // Filter out invalid entries
                        if (theme && theme !== "" && theme !== "default" && theme !== "hicolor" && theme !== "locolor")
                            detectedThemes.push(theme)
                    }
                }
                availableShellThemes = detectedThemes
            }
        }
    }

    // Cursor Theme Detection Processes
    Process {
        id: systemDefaultCursorThemeProcess
        
        command: ["sh", "-c", "gsettings get org.gnome.desktop.interface cursor-theme 2>/dev/null | sed \"s/'//g\" || echo ''"]
        running: false
        onExited: exitCode => {
            if (exitCode === 0 && stdout && stdout.length > 0)
                systemDefaultCursorTheme = stdout.trim()
            else
                systemDefaultCursorTheme = ""
            cursorThemeDetectionProcess.running = true
        }
    }

    Process {
        id: cursorThemeDetectionProcess
        
        // Find cursor themes by checking for cursors/left_ptr file
        command: ["sh", "-c", "find /usr/share/icons ~/.local/share/icons ~/.icons -maxdepth 1 -type d -exec test -f {}/cursors/left_ptr \\; -print 2>/dev/null | sed 's|.*/||' | sort -u"]
        running: false
        
        stdout: StdioCollector {
            onStreamFinished: {
                var detectedThemes = ["System Default"]
                if (text && text.trim()) {
                    var themes = text.trim().split('\n')
                    for (var i = 0; i < themes.length; i++) {
                        var theme = themes[i].trim()
                        // Filter out invalid entries (same as icon theme detection)
                        if (theme && theme !== "" && theme !== "default" && theme !== "hicolor" && theme !== "locolor")
                            detectedThemes.push(theme)
                    }
                }
                availableCursorThemes = detectedThemes
            }
        }
    }

    Process {
        id: defaultSettingsCheckProcess

        command: ["sh", "-c", "CONFIG_DIR=\"" + _configDir
            + "/DarkMaterialShell\"; if [ -f \"$CONFIG_DIR/default-settings.json\" ] && [ ! -f \"$CONFIG_DIR/settings.json\" ]; then cp \"$CONFIG_DIR/default-settings.json\" \"$CONFIG_DIR/settings.json\" && echo 'copied'; else echo 'not_found'; fi"]
        running: false
        onExited: exitCode => {
            if (exitCode === 0) {
                // console.log("Copied default-settings.json to settings.json")
                settingsFile.reload()
            } else {
                // No default settings file found, just apply stored theme
                applyStoredTheme()
            }
        }
    }

    Process {
        id: terminalDetectionProcess

        command: ["sh", "-c", "for term in alacritty foot kitty konsole gnome-terminal xterm termite st wezterm tilde rxvt urxvt xfce4-terminal lxterminal mate-terminal qterminal ptyxis; do which $term 2>/dev/null && echo $term; done"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                var terminals = []
                if (text && text.trim()) {
                    var lines = text.trim().split('\n')
                    for (var i = 0; i < lines.length; i++) {
                        var term = lines[i].trim()
                        if (term && term !== "" && !terminals.includes(term)) {
                            terminals.push(term)
                        }
                    }
                }
                // Fallback to common terminals if none detected
                if (terminals.length === 0) {
                    terminals = ["xterm", "gnome-terminal", "konsole"]
                }
                availableTerminals = terminals
                
                // Set default if not already set
                if (!terminalEmulator || terminalEmulator === "") {
                    var envTerminal = Quickshell.env("TERMINAL") || ""
                    if (envTerminal && terminals.includes(envTerminal)) {
                        terminalEmulator = envTerminal
                    } else if (terminals.length > 0) {
                        // Prefer common terminals
                        var preferred = ["alacritty", "foot", "kitty", "wezterm", "xterm"]
                        for (var j = 0; j < preferred.length; j++) {
                            if (terminals.includes(preferred[j])) {
                                terminalEmulator = preferred[j]
                                break
                            }
                        }
                        // If no preferred found, use first available
                        if (!terminalEmulator || terminalEmulator === "") {
                            terminalEmulator = terminals[0]
                        }
                    }
                }
            }
        }
    }

    Process {
        id: aurHelperDetectionProcess

        command: ["sh", "-c", "for helper in yay paru trizen aurutils pikaur pakku paruz yay-bin; do which $helper 2>/dev/null && echo $helper; done"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                var helpers = []
                if (text && text.trim()) {
                    var lines = text.trim().split('\n')
                    for (var i = 0; i < lines.length; i++) {
                        var helper = lines[i].trim()
                        if (helper && helper !== "" && !helpers.includes(helper)) {
                            helpers.push(helper)
                        }
                    }
                }
                availableAurHelpers = helpers
                
                // Set default if not already set (prefer yay, then paru)
                if (!aurHelper || aurHelper === "") {
                    if (helpers.length > 0) {
                        var preferred = ["yay", "paru", "pikaur"]
                        for (var j = 0; j < preferred.length; j++) {
                            if (helpers.includes(preferred[j])) {
                                aurHelper = preferred[j]
                                break
                            }
                        }
                        // If no preferred found, use first available
                        if (!aurHelper || aurHelper === "") {
                            aurHelper = helpers[0]
                        }
                    }
                }
            }
        }
    }

    IpcHandler {
        function reveal(): string {
            root.setTopBarVisible(true)
            return "BAR_SHOW_SUCCESS"
        }

        function hide(): string {
            root.setTopBarVisible(false)
            return "BAR_HIDE_SUCCESS"
        }

        function toggle(): string {
            root.toggleTopBarVisible()
            return topBarVisible ? "BAR_SHOW_SUCCESS" : "BAR_HIDE_SUCCESS"
        }

        function status(): string {
            return topBarVisible ? "visible" : "hidden"
        }

        target: "bar"
    }
}
