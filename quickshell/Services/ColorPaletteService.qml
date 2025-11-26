pragma Singleton

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common

Singleton {
    id: root

    property var extractedColors: []
    property var selectedColors: []
    property bool isExtracting: false
    property string currentWallpaper: ""
    property var customThemeData: null
    property string customThemeFilePath: ""
    property bool customThemeReady: false
    property var availableThemes: [] // List of available custom themes
    property string currentThemeName: {
        if (typeof SettingsData !== 'undefined') {
            return SettingsData.currentColorTheme || ""
        }
        return ""
    } // Currently selected theme name
    
    property bool _initialized: false
    
    function initializeIfNeeded() {
        if (!_initialized) {
            _initialized = true
            Qt.callLater(function() {
                if (typeof SettingsData !== 'undefined' && SettingsData.savedColorThemes !== undefined) {
                    loadCustomThemeFromSettings()
                    updateAvailableThemes()
                }
            })
        }
    }

    signal colorsExtracted()
    signal colorsChanged()
    signal customThemeCreated(var themeData)
    signal themesUpdated()

    function extractColorsFromWallpaper(wallpaperPath) {
        if (!wallpaperPath || wallpaperPath === currentWallpaper) {
            return
        }
        
        currentWallpaper = wallpaperPath
        isExtracting = true
        
        matugenProcess.command = ["matugen", "--json", "hex", "image", wallpaperPath]
        matugenProcess.running = true
    }

    function selectColor(color, selected) {
        if (selected) {
            if (!selectedColors.includes(color)) {
                selectedColors.push(color)
            }
        } else {
            const index = selectedColors.indexOf(color)
            if (index > -1) {
                selectedColors.splice(index, 1)
            }
        }
        colorsChanged()
    }

    function clearSelection() {
        selectedColors = []
        colorsChanged()
    }

    function applySelectedColors() {
        
        if (selectedColors.length === 0) {
            return
        }
        
        const getBrightness = (color) => {
            let r, g, b
            if (typeof color === 'string' && color.startsWith('#')) {
                r = parseInt(color.slice(1, 3), 16) / 255
                g = parseInt(color.slice(3, 5), 16) / 255
                b = parseInt(color.slice(5, 7), 16) / 255
            } else {
                r = color.r || 0
                g = color.g || 0
                b = color.b || 0
            }
            return (r * 0.299 + g * 0.587 + b * 0.114)
        }
        
        const getTextColorForBackground = (backgroundColor, isLightMode) => {
            const brightness = getBrightness(backgroundColor)
            
            if (isLightMode) {
                return brightness > 0.5 ? "#000000" : "#ffffff"
            } else {
                return brightness > 0.5 ? "#000000" : "#ffffff"
            }
        }
        
        const colorToHex = (color) => {
            if (typeof color === 'string') return color
            const r = Math.round((color.r || 0) * 255)
            const g = Math.round((color.g || 0) * 255)
            const b = Math.round((color.b || 0) * 255)
            return "#" + r.toString(16).padStart(2, '0') + g.toString(16).padStart(2, '0') + b.toString(16).padStart(2, '0')
        }
        
        const sortedColors = [...selectedColors].sort((a, b) => getBrightness(a) - getBrightness(b))
        
        const primaryColor = selectedColors[0] || "#42a5f5"
        
        const isLightMode = typeof SessionData !== 'undefined' ? SessionData.isLightMode : false
        
        const customTheme = {
            "name": "Custom Palette",
            "primary": primaryColor,
            "primaryText": getTextColorForBackground(primaryColor, isLightMode),
            "primaryContainer": isLightMode ? Qt.darker(primaryColor, 1.2) : Qt.lighter(primaryColor, 1.2),
            "primaryContainerText": getTextColorForBackground(colorToHex(isLightMode ? Qt.darker(primaryColor, 1.2) : Qt.lighter(primaryColor, 1.2)), isLightMode),
            
            "secondary": isLightMode ? Qt.darker(primaryColor, 1.4) : Qt.lighter(primaryColor, 1.4),
            "secondaryText": getTextColorForBackground(colorToHex(isLightMode ? Qt.darker(primaryColor, 1.4) : Qt.lighter(primaryColor, 1.4)), isLightMode),
            "secondaryContainer": isLightMode ? Qt.darker(primaryColor, 1.6) : Qt.lighter(primaryColor, 1.6),
            "secondaryContainerText": getTextColorForBackground(colorToHex(isLightMode ? Qt.darker(primaryColor, 1.6) : Qt.lighter(primaryColor, 1.6)), isLightMode),
            
            "tertiary": isLightMode ? Qt.darker(primaryColor, 1.8) : Qt.lighter(primaryColor, 1.8),
            "tertiaryText": getTextColorForBackground(colorToHex(isLightMode ? Qt.darker(primaryColor, 1.8) : Qt.lighter(primaryColor, 1.8)), isLightMode),
            "tertiaryContainer": isLightMode ? Qt.darker(primaryColor, 2.0) : Qt.lighter(primaryColor, 2.0),
            "tertiaryContainerText": getTextColorForBackground(colorToHex(isLightMode ? Qt.darker(primaryColor, 2.0) : Qt.lighter(primaryColor, 2.0)), isLightMode),
            
            "surface": isLightMode ? Qt.lighter(primaryColor, 3.0) : Qt.darker(primaryColor, 3.0),
            "surfaceText": getTextColorForBackground(colorToHex(isLightMode ? Qt.lighter(primaryColor, 3.0) : Qt.darker(primaryColor, 3.0)), isLightMode),
            "surfaceVariant": isLightMode ? Qt.lighter(primaryColor, 2.5) : Qt.darker(primaryColor, 2.5),
            "surfaceVariantText": getTextColorForBackground(colorToHex(isLightMode ? Qt.lighter(primaryColor, 2.5) : Qt.darker(primaryColor, 2.5)), isLightMode),
            "surfaceTint": primaryColor,
            "surfaceContainer": isLightMode ? Qt.lighter(primaryColor, 2.8) : Qt.darker(primaryColor, 2.8),
            "surfaceContainerText": getTextColorForBackground(colorToHex(isLightMode ? Qt.lighter(primaryColor, 2.8) : Qt.darker(primaryColor, 2.8)), isLightMode),
            "surfaceContainerHigh": isLightMode ? Qt.lighter(primaryColor, 2.6) : Qt.darker(primaryColor, 2.6),
            "surfaceContainerHighText": getTextColorForBackground(colorToHex(isLightMode ? Qt.lighter(primaryColor, 2.6) : Qt.darker(primaryColor, 2.6)), isLightMode),
            "surfaceContainerHighest": isLightMode ? Qt.lighter(primaryColor, 2.4) : Qt.darker(primaryColor, 2.4),
            "surfaceContainerHighestText": getTextColorForBackground(colorToHex(isLightMode ? Qt.lighter(primaryColor, 2.4) : Qt.darker(primaryColor, 2.4)), isLightMode),
            
            "background": isLightMode ? Qt.lighter(primaryColor, 3.2) : Qt.darker(primaryColor, 3.2),
            "backgroundText": getTextColorForBackground(colorToHex(isLightMode ? Qt.lighter(primaryColor, 3.2) : Qt.darker(primaryColor, 3.2)), isLightMode),
            
            "outline": isLightMode ? Qt.darker(primaryColor, 1.5) : Qt.lighter(primaryColor, 1.5),
            "outlineVariant": isLightMode ? Qt.darker(primaryColor, 2.2) : Qt.lighter(primaryColor, 2.2),
            
            "error": isLightMode ? "#B3261E" : "#F2B8B5",
            "errorText": isLightMode ? "#ffffff" : "#000000",
            "errorContainer": isLightMode ? "#FDEAEA" : "#8C1D18",
            "errorContainerText": getTextColorForBackground(colorToHex(isLightMode ? Qt.lighter("#B3261E", 1.5) : Qt.darker("#F2B8B5", 1.5)), isLightMode),
            
            "warning": isLightMode ? "#F57C00" : "#FFB74D",
            "warningText": isLightMode ? "#ffffff" : "#000000",
            "warningContainer": isLightMode ? "#FFF3E0" : "#E65100",
            "warningContainerText": getTextColorForBackground(isLightMode ? "#FFF3E0" : "#E65100", isLightMode),
            
            "info": isLightMode ? "#1976D2" : "#64B5F6",
            "infoText": isLightMode ? "#ffffff" : "#000000",
            "infoContainer": isLightMode ? "#E3F2FD" : "#0D47A1",
            "infoContainerText": getTextColorForBackground(isLightMode ? "#E3F2FD" : "#0D47A1", isLightMode),
            
            "success": isLightMode ? "#388E3C" : "#81C784",
            "successText": isLightMode ? "#ffffff" : "#000000",
            "successContainer": isLightMode ? "#E8F5E8" : "#1B5E20",
            "successContainerText": getTextColorForBackground(isLightMode ? "#E8F5E8" : "#1B5E20", isLightMode),
            
            "matugen_type": "scheme-custom",
            
            "surfaceContainerHighest": isLightMode ? Qt.lighter(primaryColor, 2.4) : Qt.darker(primaryColor, 2.4),
            "onSurface": getTextColorForBackground(colorToHex(isLightMode ? Qt.lighter(primaryColor, 3.0) : Qt.darker(primaryColor, 3.0)), isLightMode),
            "onSurfaceVariant": getTextColorForBackground(colorToHex(isLightMode ? Qt.lighter(primaryColor, 2.5) : Qt.darker(primaryColor, 2.5)), isLightMode),
            "onPrimary": getTextColorForBackground(primaryColor, isLightMode),
            "onSurface_12": isLightMode ? "rgba(0,0,0,0.12)" : "rgba(255,255,255,0.12)",
            "onSurface_38": isLightMode ? "rgba(0,0,0,0.38)" : "rgba(255,255,255,0.38)",
            "onSurfaceVariant_30": isLightMode ? "rgba(0,0,0,0.30)" : "rgba(255,255,255,0.30)",
            "primaryHover": isLightMode ? Qt.darker(primaryColor, 1.1) : Qt.lighter(primaryColor, 1.1),
            "primaryHoverLight": isLightMode ? Qt.darker(primaryColor, 1.05) : Qt.lighter(primaryColor, 1.05),
            "primaryPressed": isLightMode ? Qt.darker(primaryColor, 1.3) : Qt.lighter(primaryColor, 1.3),
            "primarySelected": isLightMode ? Qt.darker(primaryColor, 1.4) : Qt.lighter(primaryColor, 1.4),
            "primaryBackground": isLightMode ? Qt.lighter(primaryColor, 2.0) : Qt.darker(primaryColor, 2.0),
            "secondaryHover": isLightMode ? Qt.darker(primaryColor, 1.3) : Qt.lighter(primaryColor, 1.3),
            "surfaceHover": isLightMode ? Qt.darker(primaryColor, 1.1) : Qt.lighter(primaryColor, 1.1),
            "surfacePressed": isLightMode ? Qt.darker(primaryColor, 1.2) : Qt.lighter(primaryColor, 1.2),
            "surfaceSelected": isLightMode ? Qt.darker(primaryColor, 1.3) : Qt.lighter(primaryColor, 1.3),
            "surfaceLight": isLightMode ? Qt.darker(primaryColor, 1.05) : Qt.lighter(primaryColor, 1.05),
            "surfaceVariantAlpha": isLightMode ? Qt.darker(primaryColor, 1.1) : Qt.lighter(primaryColor, 1.1),
            "surfaceTextHover": isLightMode ? "rgba(0,0,0,0.08)" : "rgba(255,255,255,0.08)",
            "surfaceTextAlpha": isLightMode ? "rgba(0,0,0,0.3)" : "rgba(255,255,255,0.3)",
            "surfaceTextLight": isLightMode ? "rgba(0,0,0,0.06)" : "rgba(255,255,255,0.06)",
            "surfaceTextMedium": isLightMode ? "rgba(0,0,0,0.7)" : "rgba(255,255,255,0.7)",
            "outlineButton": isLightMode ? Qt.darker(primaryColor, 1.2) : Qt.lighter(primaryColor, 1.2),
            "outlineLight": isLightMode ? Qt.darker(primaryColor, 1.05) : Qt.lighter(primaryColor, 1.05),
            "outlineMedium": isLightMode ? Qt.darker(primaryColor, 1.1) : Qt.lighter(primaryColor, 1.1),
            "outlineStrong": isLightMode ? Qt.darker(primaryColor, 1.3) : Qt.lighter(primaryColor, 1.3),
            "errorHover": isLightMode ? Qt.darker("#B3261E", 1.1) : Qt.lighter("#F2B8B5", 1.1),
            "errorPressed": isLightMode ? Qt.darker("#B3261E", 1.3) : Qt.lighter("#F2B8B5", 1.3),
            "shadowMedium": "rgba(0,0,0,0.08)",
            "shadowStrong": "rgba(0,0,0,0.3)"
        }
        

        if (typeof SettingsData !== 'undefined') {
            const hex = primaryColor.replace('#', '')
            const r = parseInt(hex.substr(0, 2), 16) / 255
            const g = parseInt(hex.substr(2, 2), 16) / 255
            const b = parseInt(hex.substr(4, 2), 16) / 255
            
            SettingsData.launcherLogoRed = r
            SettingsData.launcherLogoGreen = g
            SettingsData.launcherLogoBlue = b
            SettingsData.osLogoColorOverride = primaryColor
            
            SettingsData.saveSettings()
            
        }

        root.customThemeData = customTheme
        root.customThemeReady = true

        if (typeof Theme !== 'undefined') {
            
            Theme.switchTheme("custom", true, false)
            
            Theme.loadCustomTheme(customTheme)
            
            Theme.generateSystemThemesFromCurrentTheme()
            
            Theme.colorUpdateTrigger++
        } else {
        }

        saveCustomThemeToFile(customTheme)

        customThemeCreated(customTheme)
    }

    Process {
        id: matugenProcess
        
        stdout: StdioCollector {
            onStreamFinished: {
                isExtracting = false
                if (text && text.trim()) {
                    try {
                        const jsonData = JSON.parse(text.trim())
                        const colors = extractColorsFromMatugen(jsonData)
                        extractedColors = colors
                        colorsExtracted()
                    } catch (e) {
                        extractedColors = []
                    }
                }
            }
        }
    }

    function extractColorsFromMatugen(jsonData) {
        const colors = []
        
        const isLightMode = typeof SessionData !== 'undefined' ? SessionData.isLightMode : false
        const currentMode = isLightMode ? 'light' : 'dark'
        
        
        if (jsonData.colors) {
            const colorKeys = [
                'primary',
                'secondary',
                'tertiary',
                'surface',
                'surface_variant',
                'outline',
                'surface_container',
                'surface_container_high',
                'primary_container',
                'secondary_container',
                'tertiary_container'
            ]
            
            colorKeys.forEach(colorKey => {
                if (jsonData.colors[colorKey] && jsonData.colors[colorKey][currentMode]) {
                    const colorValue = jsonData.colors[colorKey][currentMode]
                    if (colorValue && colorValue.startsWith('#')) {
                        colors.push(colorValue)
                    }
                }
            })
            
        } else {
        }
        
        const uniqueColors = [...new Set(colors)].slice(0, 16)
        
        return uniqueColors
    }

    function saveCustomThemeToFile(themeData) {
        try {
            const colorName = themeData.primary.replace('#', '').toLowerCase()
            
            const themeInfo = {
                name: colorName,
                displayName: `#${colorName.toUpperCase()}`,
                primaryColor: themeData.primary,
                themeData: themeData
            }
            
            
            if (typeof SettingsData !== 'undefined') {
                let themes = SettingsData.savedColorThemes || []
                
                themes = themes.filter(t => t.name !== colorName)
                
                themes.push(themeInfo)
                
                SettingsData.setSavedColorThemes(themes)
                SettingsData.setCurrentColorTheme(colorName)
                
                
                updateAvailableThemes()
            } else {
                Qt.callLater(function() {
                    if (typeof SettingsData !== 'undefined') {
                        saveCustomThemeToFile(themeData)
                    } else {
                    }
                })
            }
        } catch (e) {
        }
    }

    function loadCustomThemeFromSettings() {
        try {
            
            if (typeof SettingsData !== 'undefined') {
                
                if (SettingsData.currentColorTheme) {
                    const currentTheme = SettingsData.currentColorTheme
                    
                    const themes = SettingsData.savedColorThemes || []
                    
                    const theme = themes.find(t => t.name === currentTheme)
                    
                    if (theme) {
                        
                        if (typeof Theme !== 'undefined') {
                            Theme.customThemeData = theme.themeData
                            Theme.switchTheme("custom", true, false) // Save prefs, no transition
                            Theme.generateSystemThemesFromCurrentTheme()
                            
                            if (typeof SettingsData !== 'undefined') {
                                const primaryColor = theme.themeData.primary
                                const hex = primaryColor.replace('#', '')
                                const r = parseInt(hex.substr(0, 2), 16) / 255
                                const g = parseInt(hex.substr(2, 2), 16) / 255
                                const b = parseInt(hex.substr(4, 2), 16) / 255
                                
                                SettingsData.launcherLogoRed = r
                                SettingsData.launcherLogoGreen = g
                                SettingsData.launcherLogoBlue = b
                                SettingsData.osLogoColorOverride = primaryColor
                            }
                        } else {
                        }
                        
                        return theme.themeData
                    } else {
                    }
                } else {
                }
            } else {
            }
        } catch (e) {
        }
        return null
    }

    function updateAvailableThemes() {
        try {
            if (typeof SettingsData !== 'undefined') {
                const themes = SettingsData.savedColorThemes || []
                availableThemes = themes
                themesUpdated()
            } else {
                availableThemes = []
                themesUpdated()
            }
        } catch (e) {
            availableThemes = []
            themesUpdated()
        }
    }

    function loadThemeByName(themeName) {
        const theme = availableThemes.find(t => t.name === themeName)
        if (theme) {
            
            if (typeof SettingsData !== 'undefined') {
                SettingsData.setCurrentColorTheme(themeName)
            }
            
            if (typeof Theme !== 'undefined') {
                Theme.customThemeData = theme.themeData
                Theme.switchTheme("custom", true, false)
                Theme.generateSystemThemesFromCurrentTheme()
            }
            
            if (typeof SettingsData !== 'undefined') {
                const primaryColor = theme.themeData.primary
                const hex = primaryColor.replace('#', '')
                const r = parseInt(hex.substr(0, 2), 16) / 255
                const g = parseInt(hex.substr(2, 2), 16) / 255
                const b = parseInt(hex.substr(4, 2), 16) / 255
                
                SettingsData.launcherLogoRed = r
                SettingsData.launcherLogoGreen = g
                SettingsData.launcherLogoBlue = b
                SettingsData.osLogoColorOverride = primaryColor
                SettingsData.saveSettings()
            }
            
            return true
        }
        return false
    }

    function deleteTheme(themeName) {
        if (typeof SettingsData !== 'undefined') {
            try {
                let themes = SettingsData.savedColorThemes || []
                themes = themes.filter(t => t.name !== themeName)
                SettingsData.setSavedColorThemes(themes)
                
                if (SettingsData.currentColorTheme === themeName) {
                    SettingsData.setCurrentColorTheme("")
                }
                
                updateAvailableThemes()
                return true
            } catch (e) {
            }
        }
        return false
    }

    Timer {
        id: initTimer
        interval: 200
        repeat: true
        running: true
        onTriggered: {
            if (typeof SettingsData !== 'undefined' && SettingsData.savedColorThemes !== undefined) {
                running = false
                loadCustomThemeFromSettings()
                updateAvailableThemes()
            } else {
            }
        }
    }

    Component.onCompleted: {
        
        if (typeof SettingsData !== 'undefined' && SettingsData.savedColorThemes !== undefined) {
            loadCustomThemeFromSettings()
            updateAvailableThemes()
        }
        
        if (typeof Theme !== 'undefined' && Theme.wallpaperPath) {
            extractColorsFromWallpaper(Theme.wallpaperPath)
        }
        
        if (typeof SessionData !== 'undefined' && typeof SessionData.lightModeChanged !== 'undefined') {
            SessionData.lightModeChanged.connect(function() {
                if (typeof Theme !== 'undefined' && Theme.wallpaperPath) {
                    extractColorsFromWallpaper(Theme.wallpaperPath)
                }
            })
        }
    }

    IpcHandler {
        target: "colorpalette"

        function extract(wallpaperPath: string): string {
            extractColorsFromWallpaper(wallpaperPath)
            return "SUCCESS: Color extraction started"
        }

        function getcolors(): string {
            return JSON.stringify(extractedColors)
        }

        function select(color: string, selected: bool): string {
            selectColor(color, selected)
            return "SUCCESS: Color selection updated"
        }

        function apply(): string {
            applySelectedColors()
            return "SUCCESS: Selected colors applied to theme"
        }
    }
}
