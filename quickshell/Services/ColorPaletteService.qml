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
    
    // Force initialization when accessed
    property bool _initialized: false
    
    function initializeIfNeeded() {
        if (!_initialized) {
            _initialized = true
            Qt.callLater(function() {
                if (typeof SettingsData !== 'undefined' && SettingsData.savedColorThemes !== undefined) {
                    // // // console.log("ColorPaletteService: Force initializing from property access...")
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
        // // console.log("ColorPaletteService: extractColorsFromWallpaper called with:", wallpaperPath)
        if (!wallpaperPath || wallpaperPath === currentWallpaper) {
            // // console.log("ColorPaletteService: Skipping extraction - no path or same wallpaper")
            return
        }
        
        currentWallpaper = wallpaperPath
        isExtracting = true
        // // console.log("ColorPaletteService: Starting color extraction...")
        
        // Use matugen to extract colors from wallpaper
        matugenProcess.command = ["matugen", "image", wallpaperPath, "--json", "hex"]
        matugenProcess.running = true
    }

    function selectColor(color, selected) {
        // // console.log("ColorPaletteService: selectColor called with:", color, selected)
        if (selected) {
            if (!selectedColors.includes(color)) {
                selectedColors.push(color)
                // // console.log("ColorPaletteService: Added color to selection")
            }
        } else {
            const index = selectedColors.indexOf(color)
            if (index > -1) {
                selectedColors.splice(index, 1)
                // // console.log("ColorPaletteService: Removed color from selection")
            }
        }
        // // console.log("ColorPaletteService: Selected colors:", selectedColors)
        colorsChanged()
    }

    function clearSelection() {
        selectedColors = []
        colorsChanged()
    }

    function applySelectedColors() {
        // // console.log("ColorPaletteService: applySelectedColors called")
        // // console.log("ColorPaletteService: Selected colors count:", selectedColors.length)
        // // console.log("ColorPaletteService: Selected colors:", selectedColors)
        
        if (selectedColors.length === 0) {
            // // console.log("ColorPaletteService: No colors selected, returning")
            return
        }
        
        // Create a custom theme from selected colors
        // Use the colors more intelligently based on their brightness
        const getBrightness = (color) => {
            // Handle both QML color objects and hex strings
            let r, g, b
            if (typeof color === 'string' && color.startsWith('#')) {
                // Hex string format
                r = parseInt(color.slice(1, 3), 16) / 255
                g = parseInt(color.slice(3, 5), 16) / 255
                b = parseInt(color.slice(5, 7), 16) / 255
            } else {
                // QML color object - extract RGB values
                r = color.r || 0
                g = color.g || 0
                b = color.b || 0
            }
            return (r * 0.299 + g * 0.587 + b * 0.114)
        }
        
        // Function to get appropriate text color based on background brightness
        const getTextColorForBackground = (backgroundColor, isLightMode) => {
            const brightness = getBrightness(backgroundColor)
            
            if (isLightMode) {
                // In light mode, use dark text for light backgrounds, light text for dark backgrounds
                return brightness > 0.5 ? "#000000" : "#ffffff"
            } else {
                // In dark mode, use light text for dark backgrounds, dark text for light backgrounds
                return brightness > 0.5 ? "#000000" : "#ffffff"
            }
        }
        
        // Helper function to convert QML color to hex string
        const colorToHex = (color) => {
            if (typeof color === 'string') return color
            // Convert QML color object to hex
            const r = Math.round((color.r || 0) * 255)
            const g = Math.round((color.g || 0) * 255)
            const b = Math.round((color.b || 0) * 255)
            return "#" + r.toString(16).padStart(2, '0') + g.toString(16).padStart(2, '0') + b.toString(16).padStart(2, '0')
        }
        
        // Sort colors by brightness (darkest to lightest)
        const sortedColors = [...selectedColors].sort((a, b) => getBrightness(a) - getBrightness(b))
        
        // Use the single selected color as primary
        const primaryColor = selectedColors[0] || "#42a5f5"
        
        // Determine current mode from SessionData
        const isLightMode = typeof SessionData !== 'undefined' ? SessionData.isLightMode : false
        // // console.log("ColorPaletteService: Creating theme for mode:", isLightMode ? "light" : "dark")
        
        // Create a comprehensive theme based on the selected color and current mode
        // This will affect the entire UI like dynamic theming does
        const customTheme = {
            "name": "Custom Palette",
            "primary": primaryColor,
            "primaryText": getTextColorForBackground(primaryColor, isLightMode),
            "primaryContainer": isLightMode ? Qt.darker(primaryColor, 1.2) : Qt.lighter(primaryColor, 1.2),
            "primaryContainerText": getTextColorForBackground(colorToHex(isLightMode ? Qt.darker(primaryColor, 1.2) : Qt.lighter(primaryColor, 1.2)), isLightMode),
            
            // Secondary colors based on primary
            "secondary": isLightMode ? Qt.darker(primaryColor, 1.4) : Qt.lighter(primaryColor, 1.4),
            "secondaryText": getTextColorForBackground(colorToHex(isLightMode ? Qt.darker(primaryColor, 1.4) : Qt.lighter(primaryColor, 1.4)), isLightMode),
            "secondaryContainer": isLightMode ? Qt.darker(primaryColor, 1.6) : Qt.lighter(primaryColor, 1.6),
            "secondaryContainerText": getTextColorForBackground(colorToHex(isLightMode ? Qt.darker(primaryColor, 1.6) : Qt.lighter(primaryColor, 1.6)), isLightMode),
            
            // Tertiary colors
            "tertiary": isLightMode ? Qt.darker(primaryColor, 1.8) : Qt.lighter(primaryColor, 1.8),
            "tertiaryText": getTextColorForBackground(colorToHex(isLightMode ? Qt.darker(primaryColor, 1.8) : Qt.lighter(primaryColor, 1.8)), isLightMode),
            "tertiaryContainer": isLightMode ? Qt.darker(primaryColor, 2.0) : Qt.lighter(primaryColor, 2.0),
            "tertiaryContainerText": getTextColorForBackground(colorToHex(isLightMode ? Qt.darker(primaryColor, 2.0) : Qt.lighter(primaryColor, 2.0)), isLightMode),
            
            // Surface colors - use primary color variations for entire UI
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
            
            // Background colors - use primary color variations
            "background": isLightMode ? Qt.lighter(primaryColor, 3.2) : Qt.darker(primaryColor, 3.2),
            "backgroundText": getTextColorForBackground(colorToHex(isLightMode ? Qt.lighter(primaryColor, 3.2) : Qt.darker(primaryColor, 3.2)), isLightMode),
            
            // Outline and borders
            "outline": isLightMode ? Qt.darker(primaryColor, 1.5) : Qt.lighter(primaryColor, 1.5),
            "outlineVariant": isLightMode ? Qt.darker(primaryColor, 2.2) : Qt.lighter(primaryColor, 2.2),
            
            // Error, warning, info, success colors
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
            
            // Add matugen_type to indicate this is a custom theme
            "matugen_type": "scheme-custom",
            
            // Additional properties that might be needed by UI components
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
        
        // // console.log("ColorPaletteService: Created custom theme:", customTheme)
        // // console.log("ColorPaletteService: Primary color:", customTheme.primary)
        // // console.log("ColorPaletteService: Background color:", customTheme.background)
        // // console.log("ColorPaletteService: Surface color:", customTheme.surface)
        // // console.log("ColorPaletteService: Theme available:", typeof Theme !== 'undefined')

        // Update logo color to match the primary color
        if (typeof SettingsData !== 'undefined') {
            // Convert hex color to RGB values (0-1 range)
            const hex = primaryColor.replace('#', '')
            const r = parseInt(hex.substr(0, 2), 16) / 255
            const g = parseInt(hex.substr(2, 2), 16) / 255
            const b = parseInt(hex.substr(4, 2), 16) / 255
            
            SettingsData.launcherLogoRed = r
            SettingsData.launcherLogoGreen = g
            SettingsData.launcherLogoBlue = b
            SettingsData.osLogoColorOverride = primaryColor
            
            // Save the settings
            SettingsData.saveSettings()
            
            // // console.log("ColorPaletteService: Updated logo color to:", primaryColor, "RGB:", r, g, b)
        }

        // Store the custom theme data and emit signal
        // // console.log("ColorPaletteService: Storing custom theme data...")
        root.customThemeData = customTheme
        root.customThemeReady = true
        // // console.log("ColorPaletteService: Custom theme data stored")

        // Apply the custom theme to the Theme system
        // // console.log("ColorPaletteService: Applying custom theme to Theme system...")
        if (typeof Theme !== 'undefined') {
            // // console.log("ColorPaletteService: Current theme before switch:", Theme.currentTheme)
            // // console.log("ColorPaletteService: Custom theme data before load:", Theme.customThemeData)
            
            // // console.log("ColorPaletteService: Switching to custom theme...")
            Theme.switchTheme("custom", true, false)
            // // console.log("ColorPaletteService: Current theme after switch:", Theme.currentTheme)
            
            // // console.log("ColorPaletteService: Loading custom theme data...")
            Theme.loadCustomTheme(customTheme)
            // // console.log("ColorPaletteService: Custom theme data after load:", Theme.customThemeData)
            // // console.log("ColorPaletteService: Current theme data after load:", Theme.currentThemeData)
            
            // // console.log("ColorPaletteService: Generating system themes...")
            Theme.generateSystemThemesFromCurrentTheme()
            // // console.log("ColorPaletteService: Custom theme applied successfully!")
            
            // Force a color update trigger to refresh UI
            // // console.log("ColorPaletteService: Triggering color update...")
            // // console.log("ColorPaletteService: Theme.colorUpdateTrigger before:", Theme.colorUpdateTrigger)
            Theme.colorUpdateTrigger++
            // // console.log("ColorPaletteService: Theme.colorUpdateTrigger after:", Theme.colorUpdateTrigger)
        } else {
            // // console.log("ColorPaletteService: Theme system not available!")
        }

        // Save the custom theme to file
        saveCustomThemeToFile(customTheme)

        // Emit signal for other components to pick up
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
                        // // console.log("ColorPaletteService: Failed to parse matugen output:", e)
                        extractedColors = []
                    }
                }
            }
        }
    }

    function extractColorsFromMatugen(jsonData) {
        const colors = []
        
        // Determine current mode
        const isLightMode = typeof SessionData !== 'undefined' ? SessionData.isLightMode : false
        const currentMode = isLightMode ? 'light' : 'dark'
        
        // // console.log("ColorPaletteService: Extracting colors for mode:", currentMode)
        
        // Extract colors from current mode only
        if (jsonData.colors && jsonData.colors[currentMode]) {
            const modeColors = jsonData.colors[currentMode]
            
            // Extract key colors
            const keyColors = [
                modeColors.primary,
                modeColors.secondary,
                modeColors.tertiary,
                modeColors.surface,
                modeColors.surface_variant,
                modeColors.outline,
                modeColors.surface_container,
                modeColors.surface_container_high,
                modeColors.primary_container,
                modeColors.secondary_container,
                modeColors.tertiary_container
            ].filter(color => color && color.startsWith('#'))
            
            colors.push(...keyColors)
            // // console.log("ColorPaletteService: Extracted", keyColors.length, "colors for", currentMode, "mode")
        } else {
            // // console.log("ColorPaletteService: No colors found for mode:", currentMode)
        }
        
        // Remove duplicates and limit to 16 colors
        const uniqueColors = [...new Set(colors)].slice(0, 16)
        
        return uniqueColors
    }

    function saveCustomThemeToFile(themeData) {
        try {
            // // console.log("ColorPaletteService: saveCustomThemeToFile called with:", themeData)
            const colorName = themeData.primary.replace('#', '').toLowerCase()
            // // console.log("ColorPaletteService: Color name:", colorName)
            
            const themeInfo = {
                name: colorName,
                displayName: `#${colorName.toUpperCase()}`,
                primaryColor: themeData.primary,
                themeData: themeData
            }
            
            // // console.log("ColorPaletteService: Theme info created:", themeInfo)
            
            // Add or update theme in SettingsData
            if (typeof SettingsData !== 'undefined') {
                // // console.log("ColorPaletteService: SettingsData available, current themes:", SettingsData.savedColorThemes)
                let themes = SettingsData.savedColorThemes || []
                
                // Remove existing theme with same name if it exists
                themes = themes.filter(t => t.name !== colorName)
                // // console.log("ColorPaletteService: Themes after filter:", themes.length)
                
                // Add new theme
                themes.push(themeInfo)
                // // console.log("ColorPaletteService: Themes after push:", themes.length)
                
                // Save to SettingsData
                // // console.log("ColorPaletteService: About to save themes to SettingsData...")
                SettingsData.setSavedColorThemes(themes)
                // // console.log("ColorPaletteService: Themes saved, calling setCurrentColorTheme...")
                SettingsData.setCurrentColorTheme(colorName)
                // // console.log("ColorPaletteService: Current theme set, checking SettingsData values...")
                
                // // console.log("ColorPaletteService: Custom theme saved to settings:", colorName)
                // // console.log("ColorPaletteService: SettingsData.savedColorThemes after save:", SettingsData.savedColorThemes)
                // // console.log("ColorPaletteService: SettingsData.currentColorTheme after save:", SettingsData.currentColorTheme)
                
                // Update the list of available themes
                updateAvailableThemes()
            } else {
                // // console.log("ColorPaletteService: SettingsData not available, retrying in 100ms...")
                // Retry after a short delay
                Qt.callLater(function() {
                    if (typeof SettingsData !== 'undefined') {
                        // // console.log("ColorPaletteService: SettingsData now available on retry, saving...")
                        saveCustomThemeToFile(themeData)
                    } else {
                        // // console.log("ColorPaletteService: SettingsData still not available on retry")
                    }
                })
            }
        } catch (e) {
            // // console.log("ColorPaletteService: Error saving custom theme:", e)
        }
    }

    function loadCustomThemeFromSettings() {
        try {
            // // console.log("ColorPaletteService: Loading custom theme from SettingsData")
            // // console.log("ColorPaletteService: SettingsData available:", typeof SettingsData !== 'undefined')
            
            if (typeof SettingsData !== 'undefined') {
                // // console.log("ColorPaletteService: SettingsData.savedColorThemes:", SettingsData.savedColorThemes)
                // // console.log("ColorPaletteService: SettingsData.currentColorTheme:", SettingsData.currentColorTheme)
                
                if (SettingsData.currentColorTheme) {
                    const currentTheme = SettingsData.currentColorTheme
                    // // console.log("ColorPaletteService: Current color theme from settings:", currentTheme)
                    
                    // Find the theme in saved themes
                    const themes = SettingsData.savedColorThemes || []
                    // // console.log("ColorPaletteService: Available themes count:", themes.length)
                    
                    const theme = themes.find(t => t.name === currentTheme)
                    
                    if (theme) {
                        // // console.log("ColorPaletteService: Found theme in settings:", theme.name)
                        // // console.log("ColorPaletteService: Theme data:", theme.themeData)
                        
                        // Apply the loaded theme
                        if (typeof Theme !== 'undefined') {
                            // // console.log("ColorPaletteService: Setting customThemeData...")
                            Theme.customThemeData = theme.themeData
                            // // console.log("ColorPaletteService: Switching to custom theme...")
                            Theme.switchTheme("custom", true, false) // Save prefs, no transition
                            // // console.log("ColorPaletteService: Generating system themes...")
                            Theme.generateSystemThemesFromCurrentTheme()
                            // // console.log("ColorPaletteService: Applied loaded custom theme successfully")
                            
                            // Also update logo color
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
                                // // console.log("ColorPaletteService: Updated logo color to:", primaryColor)
                            }
                        } else {
                            // // console.log("ColorPaletteService: Theme system not available, cannot apply custom theme")
                        }
                        
                        return theme.themeData
                    } else {
                        // // console.log("ColorPaletteService: Theme not found in saved themes")
                        // // console.log("ColorPaletteService: Available theme names:", themes.map(t => t.name))
                    }
                } else {
                    // // console.log("ColorPaletteService: No current color theme in settings")
                }
            } else {
                // // console.log("ColorPaletteService: SettingsData not available")
            }
        } catch (e) {
            // // console.log("ColorPaletteService: Error loading custom theme from settings:", e)
        }
        return null
    }

    function updateAvailableThemes() {
        try {
            // // console.log("ColorPaletteService: updateAvailableThemes called")
            if (typeof SettingsData !== 'undefined') {
                // // console.log("ColorPaletteService: SettingsData available")
                const themes = SettingsData.savedColorThemes || []
                // // console.log("ColorPaletteService: Themes from SettingsData:", themes)
                availableThemes = themes
                themesUpdated()
                // // console.log("ColorPaletteService: Updated available themes from settings:", themes.length)
                // // console.log("ColorPaletteService: availableThemes after update:", availableThemes)
            } else {
                // // console.log("ColorPaletteService: SettingsData not available")
                availableThemes = []
                themesUpdated()
            }
        } catch (e) {
            // // console.log("ColorPaletteService: Error updating available themes:", e)
            availableThemes = []
            themesUpdated()
        }
    }

    function loadThemeByName(themeName) {
        const theme = availableThemes.find(t => t.name === themeName)
        if (theme) {
            // // console.log("ColorPaletteService: Loading theme:", themeName)
            
            // Update current theme in SettingsData
            if (typeof SettingsData !== 'undefined') {
                SettingsData.setCurrentColorTheme(themeName)
                // currentThemeName will update automatically via binding
            }
            
            // Apply the theme
            if (typeof Theme !== 'undefined') {
                Theme.customThemeData = theme.themeData
                Theme.switchTheme("custom", true, false)
                Theme.generateSystemThemesFromCurrentTheme()
                // // console.log("ColorPaletteService: Applied theme:", themeName)
            }
            
            // Update logo color
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
                
                // Clear current theme if it was deleted
                if (SettingsData.currentColorTheme === themeName) {
                    SettingsData.setCurrentColorTheme("")
                }
                
                updateAvailableThemes()
                // // console.log("ColorPaletteService: Deleted theme:", themeName)
                return true
            } catch (e) {
                // // console.log("ColorPaletteService: Error deleting theme:", e)
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
                // // console.log("ColorPaletteService: SettingsData now available, initializing...")
                running = false
                loadCustomThemeFromSettings()
                updateAvailableThemes()
            } else {
                // // console.log("ColorPaletteService: Waiting for SettingsData to be fully loaded...")
            }
        }
    }

    Component.onCompleted: {
        // // console.log("ColorPaletteService: Component completed")
        // // console.log("ColorPaletteService: SettingsData available:", typeof SettingsData !== 'undefined')
        
        // Try to initialize immediately if SettingsData is available
        if (typeof SettingsData !== 'undefined' && SettingsData.savedColorThemes !== undefined) {
            // // console.log("ColorPaletteService: SettingsData available immediately, initializing...")
            loadCustomThemeFromSettings()
            updateAvailableThemes()
        }
        
        // Extract colors from current wallpaper if available
        if (typeof Theme !== 'undefined' && Theme.wallpaperPath) {
            extractColorsFromWallpaper(Theme.wallpaperPath)
        }
        
        // Listen for mode changes to re-extract colors
        if (typeof SessionData !== 'undefined') {
            SessionData.lightModeChanged.connect(function() {
                // // console.log("ColorPaletteService: Mode changed, re-extracting colors...")
                if (typeof Theme !== 'undefined' && Theme.wallpaperPath) {
                    extractColorsFromWallpaper(Theme.wallpaperPath)
                }
            })
        }
    }

    // IPC handler for external queries
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
