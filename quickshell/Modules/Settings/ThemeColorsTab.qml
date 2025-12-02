import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Modals
import qs.Modals.FileBrowser
import qs.Services
import qs.Widgets

Item {
    id: themeColorsTab

    property var parentModal: null
    property var cachedFontFamilies: []
    property var cachedMonoFamilies: []
    property bool fontsEnumerated: false
    property bool forceUpdate: false

    function enumerateFonts() {
        var fonts = ["Default"]
        var availableFonts = Qt.fontFamilies()
        var rootFamilies = []
        var seenFamilies = new Set()
        for (var i = 0; i < availableFonts.length; i++) {
            var fontName = availableFonts[i]
            if (fontName.startsWith("."))
                continue

            if (fontName === SettingsData.defaultFontFamily)
                continue

            var rootName = fontName.replace(
                        / (Thin|Extra Light|Light|Regular|Medium|Semi Bold|Demi Bold|Bold|Extra Bold|Black|Heavy)$/i,
                        "").replace(
                        / (Italic|Oblique|Condensed|Extended|Narrow|Wide)$/i,
                        "").replace(/ (UI|Display|Text|Mono|Sans|Serif)$/i,
                                    function (match, suffix) {
                                        return match
                                    }).trim()
            if (!seenFamilies.has(rootName) && rootName !== "") {
                seenFamilies.add(rootName)
                rootFamilies.push(rootName)
            }
        }
        cachedFontFamilies = fonts.concat(rootFamilies.sort())
        var monoFonts = ["Default"]
        var monoFamilies = []
        var seenMonoFamilies = new Set()
        for (var j = 0; j < availableFonts.length; j++) {
            var fontName2 = availableFonts[j]
            if (fontName2.startsWith("."))
                continue

            if (fontName2 === SettingsData.defaultMonoFontFamily)
                continue

            var lowerName = fontName2.toLowerCase()
            if (lowerName.includes("mono") || lowerName.includes(
                        "code") || lowerName.includes(
                        "console") || lowerName.includes(
                        "terminal") || lowerName.includes(
                        "courier") || lowerName.includes(
                        "dejavu sans mono") || lowerName.includes(
                        "jetbrains") || lowerName.includes(
                        "fira") || lowerName.includes(
                        "hack") || lowerName.includes(
                        "source code") || lowerName.includes(
                        "ubuntu mono") || lowerName.includes("cascadia")) {
                var rootName2 = fontName2.replace(
                            / (Thin|Extra Light|Light|Regular|Medium|Semi Bold|Demi Bold|Bold|Extra Bold|Black|Heavy)$/i,
                            "").replace(
                            / (Italic|Oblique|Condensed|Extended|Narrow|Wide)$/i,
                            "").trim()
                if (!seenMonoFamilies.has(rootName2) && rootName2 !== "") {
                    seenMonoFamilies.add(rootName2)
                    monoFamilies.push(rootName2)
                }
            }
        }
        cachedMonoFamilies = monoFonts.concat(monoFamilies.sort())
    }

    Component.onCompleted: {
        if (!fontsEnumerated) {
            enumerateFonts()
            fontsEnumerated = true
        }
        
        if (typeof ColorPaletteService !== 'undefined') {
            
            ColorPaletteService.customThemeCreated.connect(function(themeData) {
                if (typeof Theme !== 'undefined') {
                    Theme.customThemeData = themeData
                    
                    Theme.switchTheme("custom", true, false) // Save prefs, no transition
                    
                    Theme.generateSystemThemesFromCurrentTheme()
                } else {
                }
            })
            
            ColorPaletteService.colorsExtracted.connect(function() {
                themeColorsTab.forceUpdate = !themeColorsTab.forceUpdate
            })
            
            ColorPaletteService.themesUpdated.connect(function() {
                themeColorsTab.forceUpdate = !themeColorsTab.forceUpdate
            })
        }
    }

    DarkFlickable {
        anchors.fill: parent
        anchors.topMargin: Theme.spacingL
        clip: true
        contentHeight: mainColumn.height
        contentWidth: width

        Column {
            id: mainColumn

            width: parent.width
            spacing: Theme.spacingXL


            StyledRect {
                width: parent.width
                height: uiScaleSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: uiScaleSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "zoom_in"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Settings UI Scale"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    StyledText {
                        text: "Scale the settings window, icons, and controls. Use Font Scale for text."
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        StyledText {
                            text: "Scale"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            width: 60
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        DarkSlider {
                            id: uiScaleSlider

                            width: parent.width - 60 - Theme.spacingM - 60
                            height: Theme.scaledHeight(32)
                            minimum: 80
                            maximum: 140
                            value: Math.round((SettingsData.settingsUiScale > 0 ? SettingsData.settingsUiScale : 1.0) * 100)
                            unit: "%"
                            showValue: false
                            wheelEnabled: false
                            anchors.verticalCenter: parent.verticalCenter

                            onSliderValueChanged: newValue => {
                                const scale = newValue / 100.0
                                SettingsData.setSettingsUiScale(scale)
                            }
                        }

                        StyledText {
                            text: (SettingsData.settingsUiScale * 100).toFixed(0) + "%"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            width: 60
                            horizontalAlignment: Text.AlignRight
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: advancedScaleSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: advancedScaleSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "tune"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Advanced Scaling"
                            font.pixelSize: Theme.fontSizeMedium
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Item {
                            width: 1
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        DarkToggle {
                            checked: SettingsData.settingsUiAdvancedScaling
                            anchors.verticalCenter: parent.verticalCenter
                            onToggled: value => {
                                SettingsData.settingsUiAdvancedScaling = value
                            }
                        }
                    }

                    StyledText {
                        text: "Individually adjust window size, controls, and icons in settings."
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS
                        visible: SettingsData.settingsUiAdvancedScaling

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: "Window Scale"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                width: 100
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            DarkSlider {
                                width: parent.width - 100 - Theme.spacingM - 60
                                height: Theme.scaledHeight(28)
                                minimum: 80
                                maximum: 140
                                value: Math.round((SettingsData.settingsUiWindowScale || 1.0) * 100)
                                unit: "%"
                                showValue: false
                                wheelEnabled: false
                                anchors.verticalCenter: parent.verticalCenter
                                onSliderValueChanged: newValue => {
                                    const scale = newValue / 100.0
                                    SettingsData.settingsUiWindowScale = scale
                                    SettingsData.setSettingsWindowWidth(0)
                                    SettingsData.setSettingsWindowHeight(0)
                                }
                            }

                            StyledText {
                                text: ((SettingsData.settingsUiWindowScale || 1.0) * 100).toFixed(0) + "%"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                width: 60
                                horizontalAlignment: Text.AlignRight
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: "Window Width"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                width: 100
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            DarkSlider {
                                width: parent.width - 100 - Theme.spacingM - 60
                                height: Theme.scaledHeight(28)
                                minimum: 600
                                maximum: Math.min(Screen.width - 40, 3000)
                                value: SettingsData.settingsWindowWidth > 0
                                       ? SettingsData.settingsWindowWidth
                                       : Math.min(Screen.width - 40, 1280)
                                unit: "px"
                                showValue: true
                                wheelEnabled: false
                                anchors.verticalCenter: parent.verticalCenter
                                onSliderValueChanged: newValue => {
                                    SettingsData.setSettingsWindowWidth(newValue)
                                }
                            }

                            StyledText {
                                text: (SettingsData.settingsWindowWidth > 0
                                       ? SettingsData.settingsWindowWidth
                                       : Math.min(Screen.width - 40, 1280)) + "px"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                width: 60
                                horizontalAlignment: Text.AlignRight
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: "Window Height"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                width: 100
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            DarkSlider {
                                width: parent.width - 100 - Theme.spacingM - 60
                                height: Theme.scaledHeight(28)
                                minimum: 500
                                maximum: Math.min(Screen.height - 20, 2000)
                                value: SettingsData.settingsWindowHeight > 0
                                       ? SettingsData.settingsWindowHeight
                                       : Math.min(Screen.height - 20, 950)
                                unit: "px"
                                showValue: true
                                wheelEnabled: false
                                anchors.verticalCenter: parent.verticalCenter
                                onSliderValueChanged: newValue => {
                                    SettingsData.setSettingsWindowHeight(newValue)
                                }
                            }

                            StyledText {
                                text: (SettingsData.settingsWindowHeight > 0
                                       ? SettingsData.settingsWindowHeight
                                       : Math.min(Screen.height - 20, 950)) + "px"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                width: 60
                                horizontalAlignment: Text.AlignRight
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: "Font Scale"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                width: 100
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            DarkSlider {
                                width: parent.width - 100 - Theme.spacingM - 60
                                height: Theme.scaledHeight(28)
                                minimum: 80
                                maximum: 200
                                value: Math.round((SettingsData.fontScale || 1.0) * 100)
                                unit: "%"
                                showValue: false
                                wheelEnabled: false
                                anchors.verticalCenter: parent.verticalCenter
                                onSliderValueChanged: newValue => {
                                    const scale = newValue / 100.0
                                    SettingsData.setFontScale(scale)
                                }
                            }

                            StyledText {
                                text: (SettingsData.fontScale * 100).toFixed(0) + "%"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                width: 60
                                horizontalAlignment: Text.AlignRight
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: "Controls"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                width: 100
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            DarkSlider {
                                width: parent.width - 100 - Theme.spacingM - 60
                                height: Theme.scaledHeight(28)
                                minimum: 80
                                maximum: 140
                                value: Math.round((SettingsData.settingsUiControlScale || 1.0) * 100)
                                unit: "%"
                                showValue: false
                                wheelEnabled: false
                                anchors.verticalCenter: parent.verticalCenter
                                onSliderValueChanged: newValue => {
                                    SettingsData.settingsUiControlScale = newValue / 100.0
                                }
                            }

                            StyledText {
                                text: ((SettingsData.settingsUiControlScale || 1.0) * 100).toFixed(0) + "%"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                width: 60
                                horizontalAlignment: Text.AlignRight
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: "Icons"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                width: 100
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            DarkSlider {
                                width: parent.width - 100 - Theme.spacingM - 60
                                height: Theme.scaledHeight(28)
                                minimum: 80
                                maximum: 140
                                value: Math.round((SettingsData.settingsUiIconScale || 1.0) * 100)
                                unit: "%"
                                showValue: false
                                wheelEnabled: false
                                anchors.verticalCenter: parent.verticalCenter
                                onSliderValueChanged: newValue => {
                                    SettingsData.settingsUiIconScale = newValue / 100.0
                                }
                            }

                            StyledText {
                                text: ((SettingsData.settingsUiIconScale || 1.0) * 100).toFixed(0) + "%"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                width: 60
                                horizontalAlignment: Text.AlignRight
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
            }


            StyledRect {
                width: parent.width
                height: themeSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: themeSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "palette"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Theme Color"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: {
                                if (Theme.currentTheme === Theme.dynamic) {
                                    return "Current Theme: Dynamic"
                                } else if (Theme.currentThemeCategory === "catppuccin") {
                                    return "Current Theme: Catppuccin " + Theme.getThemeColors(Theme.currentThemeName).name
                                } else {
                                    return "Current Theme: " + Theme.getThemeColors(Theme.currentThemeName).name
                                }
                            }
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        StyledText {
                            text: {
                                if (Theme.currentTheme === Theme.dynamic) {
                                    return "Material colors generated from wallpaper"
                                }
                                if (Theme.currentThemeCategory === "catppuccin") {
                                    return "Soothing pastel theme based on Catppuccin"
                                }
                                if (Theme.currentTheme === Theme.custom) {
                                    return "Custom theme loaded from JSON file"
                                }
                                return "Material Design inspired color themes"
                            }
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            anchors.horizontalCenter: parent.horizontalCenter
                            wrapMode: Text.WordWrap
                            width: Math.min(parent.width, 400)
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    Column {
                        spacing: Theme.spacingM
                        anchors.horizontalCenter: parent.horizontalCenter

                        DarkButtonGroup {
                            property int currentThemeIndex: {
                                if (Theme.currentTheme === Theme.dynamic) return 2
                                if (Theme.currentThemeName === "custom") return 3
                                if (Theme.currentThemeCategory === "catppuccin") return 1
                                return 0
                            }

                            model: ["Generic", "Catppuccin", "Auto", "Custom"]
                            currentIndex: currentThemeIndex
                            selectionMode: "single"
                            anchors.horizontalCenter: parent.horizontalCenter
                            onSelectionChanged: (index, selected) => {
                                if (!selected) return
                                switch (index) {
                                    case 0: Theme.switchThemeCategory("generic", "blue"); break
                                    case 1: Theme.switchThemeCategory("catppuccin", "cat-mauve"); break
                                    case 2:
                                        if (ToastService.wallpaperErrorStatus === "matugen_missing")
                                            ToastService.showError("matugen not found - install matugen package for dynamic theming")
                                        else if (ToastService.wallpaperErrorStatus === "error")
                                            ToastService.showError("Wallpaper processing failed - check wallpaper path")
                                        else
                                            Theme.switchTheme(Theme.dynamic, true, false)
                                        break
                                    case 3:
                                        if (Theme.currentThemeName !== "custom") {
                                            Theme.switchTheme("custom", true, false)
                                        }
                                        break
                                }
                            }
                        }

                        Column {
                            spacing: Theme.spacingS
                            anchors.horizontalCenter: parent.horizontalCenter
                            visible: Theme.currentThemeCategory === "generic" && Theme.currentTheme !== Theme.dynamic && Theme.currentThemeName !== "custom"

                            Rectangle {
                                width: 140
                                height: 32
                                radius: Theme.cornerRadius
                                color: (!ColorPaletteService.isExtracting && Theme.wallpaperPath) ? Theme.primary : Theme.surfaceVariant
                                opacity: (!ColorPaletteService.isExtracting && Theme.wallpaperPath) ? 1.0 : 0.5
                                anchors.horizontalCenter: parent.horizontalCenter
                                
                                StyledText {
                                    text: ColorPaletteService.isExtracting ? "Extracting..." : "Extract Colors"
                                    color: (!ColorPaletteService.isExtracting && Theme.wallpaperPath) ? Theme.primaryText : Theme.surfaceVariantText
                                    anchors.centerIn: parent
                                    font.pixelSize: Theme.fontSizeSmall
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    enabled: !ColorPaletteService.isExtracting && Theme.wallpaperPath
                                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    onClicked: {
                                        if (Theme.wallpaperPath && typeof ColorPaletteService !== 'undefined') {
                                            ColorPaletteService.extractColorsFromWallpaper(Theme.wallpaperPath)
                                        }
                                    }
                                }
                            }

                            Column {
                                spacing: Theme.spacingS
                                anchors.horizontalCenter: parent.horizontalCenter
                                visible: true // Always show, even when empty

                                StyledText {
                                    text: "Saved Color Themes"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Row {
                                    spacing: Theme.spacingS
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    Rectangle {
                                        width: 200
                                        height: 32
                                        radius: Theme.cornerRadius
                                        color: Theme.surfaceVariant
                                        border.color: Theme.outline
                                        border.width: 1

                                        StyledText {
                                            id: selectedThemeText
                                            text: {
                                                if (SettingsData.currentColorTheme) {
                                                    return `#${SettingsData.currentColorTheme.toUpperCase()}`
                                                } else if (ColorPaletteService.availableThemes.length > 0) {
                                                    return "Select Theme"
                                                } else {
                                                    return "No themes saved"
                                                }
                                            }
                                            color: Theme.surfaceVariantText
                                            anchors.left: parent.left
                                            anchors.leftMargin: Theme.spacingS
                                            anchors.verticalCenter: parent.verticalCenter
                                            font.pixelSize: Theme.fontSizeSmall
                                        }

                                        DarkIcon {
                                            name: "keyboard_arrow_down"
                                            size: 16
                                            color: Theme.surfaceVariantText
                                            anchors.right: parent.right
                                            anchors.rightMargin: Theme.spacingS
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (themeDropdown.visible) {
                                                    themeDropdown.visible = false
                                                } else {
                                                    themeDropdown.visible = true
                                                }
                                            }
                                        }
                                    }

                                    Rectangle {
                                        width: 32
                                        height: 32
                                        radius: Theme.cornerRadius
                                        color: Theme.error || "#f44336"
                                        visible: SettingsData.currentColorTheme !== ""

                                        DarkIcon {
                                            name: "delete"
                                            size: 16
                                            color: Theme.errorText || "#ffffff"
                                            anchors.centerIn: parent
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (SettingsData.currentColorTheme) {
                                                    ColorPaletteService.deleteTheme(SettingsData.currentColorTheme)
                                                }
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    id: themeDropdown
                                    width: 200
                                    height: Math.min(200, ColorPaletteService.availableThemes.length * 32)
                                    radius: Theme.cornerRadius
                                    color: Theme.surfaceContainer
                                    border.color: Theme.outline
                                    border.width: 1
                                    visible: false
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    ListView {
                                        anchors.fill: parent
                                        anchors.margins: 4
                                        model: ColorPaletteService.availableThemes
                                        clip: true

                                        delegate: Rectangle {
                                            width: parent.width
                                            height: 28
                                            color: mouseArea.containsMouse ? Theme.surfaceVariant : "transparent"
                                            radius: 4

                                            Row {
                                                anchors.left: parent.left
                                                anchors.leftMargin: Theme.spacingS
                                                anchors.verticalCenter: parent.verticalCenter
                                                spacing: Theme.spacingS

                                                Rectangle {
                                                    width: 16
                                                    height: 16
                                                    radius: 8
                                                    color: modelData.primaryColor
                                                    border.color: Theme.outline
                                                    border.width: 1
                                                }

                                                StyledText {
                                                    text: modelData.displayName
                                                    color: Theme.surfaceVariantText
                                                    font.pixelSize: Theme.fontSizeSmall
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }
                                            }

                                            MouseArea {
                                                id: mouseArea
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    ColorPaletteService.loadThemeByName(modelData.name)
                                                    themeDropdown.visible = false
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Row {
                                spacing: Theme.spacingM
                                anchors.horizontalCenter: parent.horizontalCenter

                                Repeater {
                                    model: {
                                        forceUpdate // Trigger update when this changes
                                        return ColorPaletteService.extractedColors.length > 0 ? 
                                               ColorPaletteService.extractedColors.slice(0, 8) : // Show first 8 extracted colors
                                               ["blue", "purple", "green", "orange", "red"] // Fallback to original colors
                                    }

                                    Rectangle {
                                        property string colorValue: modelData
                                        property bool isExtractedColor: ColorPaletteService.extractedColors.length > 0
                                        width: 32
                                        height: 32
                                        radius: 16
                                        color: isExtractedColor ? colorValue : Theme.getThemeColors(colorValue).primary
                                        border.color: Theme.outline
                                        border.width: (isExtractedColor && ColorPaletteService.selectedColors.includes(colorValue)) ? 3 : 1
                                        scale: (isExtractedColor && ColorPaletteService.selectedColors.includes(colorValue)) ? 1.1 : 1

                                        Rectangle {
                                            width: nameText.contentWidth + Theme.spacingS * 2
                                            height: nameText.contentHeight + Theme.spacingXS * 2
                                            color: Theme.surfaceContainer
                                            border.color: Theme.outline
                                            border.width: 1
                                            radius: Theme.cornerRadius
                                            anchors.bottom: parent.top
                                            anchors.bottomMargin: Theme.spacingXS
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            visible: mouseArea.containsMouse

                                            StyledText {
                                                id: nameText
                                                text: isExtractedColor ? colorValue : Theme.getThemeColors(colorValue).name
                                                font.pixelSize: Theme.fontSizeSmall
                                                color: Theme.surfaceText
                                                anchors.centerIn: parent
                                            }
                                        }

                                        MouseArea {
                                            id: mouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (isExtractedColor) {
                                                    
                                                    ColorPaletteService.clearSelection()
                                                    ColorPaletteService.selectColor(colorValue, true)
                                                    
                                                    ColorPaletteService.applySelectedColors()
                                                } else {
                                                    Theme.switchTheme(colorValue)
                                                }
                                            }
                                        }

                                        Behavior on scale {
                                            NumberAnimation {
                                                duration: Theme.shortDuration
                                                easing.type: Theme.emphasizedEasing
                                            }
                                        }

                                        Behavior on border.width {
                                            NumberAnimation {
                                                duration: Theme.shortDuration
                                                easing.type: Theme.emphasizedEasing
                                            }
                                        }
                                    }
                                }
                            }

                            Row {
                                spacing: Theme.spacingM
                                anchors.horizontalCenter: parent.horizontalCenter

                                Repeater {
                                    model: {
                                        forceUpdate // Trigger update when this changes
                                        return ColorPaletteService.extractedColors.length > 8 ? 
                                               ColorPaletteService.extractedColors.slice(8, 16) : // Show next 8 extracted colors
                                               ["cyan", "pink", "amber", "coral", "monochrome"] // Fallback to original colors
                                    }

                                    Rectangle {
                                        property string colorValue: modelData
                                        property bool isExtractedColor: ColorPaletteService.extractedColors.length > 8
                                        width: 32
                                        height: 32
                                        radius: 16
                                        color: isExtractedColor ? colorValue : Theme.getThemeColors(colorValue).primary
                                        border.color: Theme.outline
                                        border.width: (isExtractedColor && ColorPaletteService.selectedColors.includes(colorValue)) ? 3 : 1
                                        scale: (isExtractedColor && ColorPaletteService.selectedColors.includes(colorValue)) ? 1.1 : 1

                                        Rectangle {
                                            width: nameText2.contentWidth + Theme.spacingS * 2
                                            height: nameText2.contentHeight + Theme.spacingXS * 2
                                            color: Theme.surfaceContainer
                                            border.color: Theme.outline
                                            border.width: 1
                                            radius: Theme.cornerRadius
                                            anchors.bottom: parent.top
                                            anchors.bottomMargin: Theme.spacingXS
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            visible: mouseArea2.containsMouse

                                            StyledText {
                                                id: nameText2
                                                text: isExtractedColor ? colorValue : Theme.getThemeColors(colorValue).name
                                                font.pixelSize: Theme.fontSizeSmall
                                                color: Theme.surfaceText
                                                anchors.centerIn: parent
                                            }
                                        }

                                        MouseArea {
                                            id: mouseArea2
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (isExtractedColor) {
                                                    
                                                    ColorPaletteService.clearSelection()
                                                    ColorPaletteService.selectColor(colorValue, true)
                                                    
                                                    ColorPaletteService.applySelectedColors()
                                                } else {
                                                    Theme.switchTheme(colorValue)
                                                }
                                            }
                                        }

                                        Behavior on scale {
                                            NumberAnimation {
                                                duration: Theme.shortDuration
                                                easing.type: Theme.emphasizedEasing
                                            }
                                        }

                                        Behavior on border.width {
                                            NumberAnimation {
                                                duration: Theme.shortDuration
                                                easing.type: Theme.emphasizedEasing
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Column {
                            spacing: Theme.spacingS
                            anchors.horizontalCenter: parent.horizontalCenter
                            visible: Theme.currentThemeCategory === "catppuccin" && Theme.currentTheme !== Theme.dynamic && Theme.currentThemeName !== "custom"

                            Row {
                                spacing: Theme.spacingM
                                anchors.horizontalCenter: parent.horizontalCenter

                                Repeater {
                                    model: ["cat-rosewater", "cat-flamingo", "cat-pink", "cat-mauve", "cat-red", "cat-maroon", "cat-peach"]

                                    Rectangle {
                                        property string themeName: modelData
                                        width: 32
                                        height: 32
                                        radius: 16
                                        color: Theme.getCatppuccinColor(themeName)
                                        border.color: Theme.outline
                                        border.width: (Theme.currentThemeName === themeName && Theme.currentTheme !== Theme.dynamic) ? 2 : 1
                                        scale: (Theme.currentThemeName === themeName && Theme.currentTheme !== Theme.dynamic) ? 1.1 : 1

                                        Rectangle {
                                            width: nameTextCat.contentWidth + Theme.spacingS * 2
                                            height: nameTextCat.contentHeight + Theme.spacingXS * 2
                                            color: Theme.surfaceContainer
                                            border.color: Theme.outline
                                            border.width: 1
                                            radius: Theme.cornerRadius
                                            anchors.bottom: parent.top
                                            anchors.bottomMargin: Theme.spacingXS
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            visible: mouseAreaCat.containsMouse

                                            StyledText {
                                                id: nameTextCat
                                                text: Theme.getCatppuccinVariantName(themeName)
                                                font.pixelSize: Theme.fontSizeSmall
                                                color: Theme.surfaceText
                                                anchors.centerIn: parent
                                            }
                                        }

                                        MouseArea {
                                            id: mouseAreaCat
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                Theme.switchTheme(themeName)
                                            }
                                        }

                                        Behavior on scale {
                                            NumberAnimation {
                                                duration: Theme.shortDuration
                                                easing.type: Theme.emphasizedEasing
                                            }
                                        }

                                        Behavior on border.width {
                                            NumberAnimation {
                                                duration: Theme.shortDuration
                                                easing.type: Theme.emphasizedEasing
                                            }
                                        }
                                    }
                                }
                            }

                            Row {
                                spacing: Theme.spacingM
                                anchors.horizontalCenter: parent.horizontalCenter

                                Repeater {
                                    model: ["cat-yellow", "cat-green", "cat-teal", "cat-sky", "cat-sapphire", "cat-blue", "cat-lavender"]

                                    Rectangle {
                                        property string themeName: modelData
                                        width: 32
                                        height: 32
                                        radius: 16
                                        color: Theme.getCatppuccinColor(themeName)
                                        border.color: Theme.outline
                                        border.width: (Theme.currentThemeName === themeName && Theme.currentTheme !== Theme.dynamic) ? 2 : 1
                                        scale: (Theme.currentThemeName === themeName && Theme.currentTheme !== Theme.dynamic) ? 1.1 : 1

                                        Rectangle {
                                            width: nameTextCat2.contentWidth + Theme.spacingS * 2
                                            height: nameTextCat2.contentHeight + Theme.spacingXS * 2
                                            color: Theme.surfaceContainer
                                            border.color: Theme.outline
                                            border.width: 1
                                            radius: Theme.cornerRadius
                                            anchors.bottom: parent.top
                                            anchors.bottomMargin: Theme.spacingXS
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            visible: mouseAreaCat2.containsMouse

                                            StyledText {
                                                id: nameTextCat2
                                                text: Theme.getCatppuccinVariantName(themeName)
                                                font.pixelSize: Theme.fontSizeSmall
                                                color: Theme.surfaceText
                                                anchors.centerIn: parent
                                            }
                                        }

                                        MouseArea {
                                            id: mouseAreaCat2
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                Theme.switchTheme(themeName)
                                            }
                                        }

                                        Behavior on scale {
                                            NumberAnimation {
                                                duration: Theme.shortDuration
                                                easing.type: Theme.emphasizedEasing
                                            }
                                        }

                                        Behavior on border.width {
                                            NumberAnimation {
                                                duration: Theme.shortDuration
                                                easing.type: Theme.emphasizedEasing
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: Theme.spacingM
                            visible: Theme.currentTheme === Theme.dynamic

                            Row {
                                width: parent.width
                                spacing: Theme.spacingM

                                StyledRect {
                                    width: 120
                                    height: 90
                                    radius: Theme.cornerRadius
                                    color: Theme.surfaceVariant
                                    border.color: Theme.outline
                                    border.width: 1

                                    CachingImage {
                                        anchors.fill: parent
                                        anchors.margins: 1
                                        source: Theme.wallpaperPath ? "file://" + Theme.wallpaperPath : ""
                                        fillMode: Image.PreserveAspectCrop
                                        visible: Theme.wallpaperPath && !Theme.wallpaperPath.startsWith("#")
                                        layer.enabled: true
                                        layer.effect: MultiEffect {
                                            maskEnabled: true
                                            maskSource: autoWallpaperMask
                                            maskThresholdMin: 0.5
                                            maskSpreadAtMin: 1
                                        }
                                    }

                                    Rectangle {
                                        anchors.fill: parent
                                        anchors.margins: 1
                                        radius: Theme.cornerRadius - 1
                                        color: Theme.wallpaperPath && Theme.wallpaperPath.startsWith("#") ? Theme.wallpaperPath : "transparent"
                                        visible: Theme.wallpaperPath && Theme.wallpaperPath.startsWith("#")
                                    }

                                    Rectangle {
                                        id: autoWallpaperMask
                                        anchors.fill: parent
                                        anchors.margins: 1
                                        radius: Theme.cornerRadius - 1
                                        color: "black"
                                        visible: false
                                        layer.enabled: true
                                    }

                                    DarkIcon {
                                        anchors.centerIn: parent
                                        name: {
                                            if (ToastService.wallpaperErrorStatus === "error" || ToastService.wallpaperErrorStatus === "matugen_missing")
                                                return "error"
                                            else
                                                return "palette"
                                        }
                                        size: Theme.iconSizeLarge
                                        color: {
                                            if (ToastService.wallpaperErrorStatus === "error" || ToastService.wallpaperErrorStatus === "matugen_missing")
                                                return Theme.error
                                            else
                                                return Theme.surfaceVariantText
                                        }
                                        visible: !Theme.wallpaperPath
                                    }
                                }

                                Column {
                                    width: parent.width - 120 - Theme.spacingM
                                    spacing: Theme.spacingS
                                    anchors.verticalCenter: parent.verticalCenter

                                    StyledText {
                                        text: {
                                            if (ToastService.wallpaperErrorStatus === "error")
                                                return "Wallpaper Error"
                                            else if (ToastService.wallpaperErrorStatus === "matugen_missing")
                                                return "Matugen Missing"
                                            else if (Theme.wallpaperPath)
                                                return Theme.wallpaperPath.split('/').pop()
                                            else
                                                return "No wallpaper selected"
                                        }
                                        font.pixelSize: Theme.fontSizeLarge
                                        color: Theme.surfaceText
                                        elide: Text.ElideMiddle
                                        maximumLineCount: 1
                                        width: parent.width
                                    }

                                    StyledText {
                                        text: {
                                            if (ToastService.wallpaperErrorStatus === "error")
                                                return "Wallpaper processing failed"
                                            else if (ToastService.wallpaperErrorStatus === "matugen_missing")
                                                return "Install matugen package for dynamic theming"
                                            else if (Theme.wallpaperPath)
                                                return Theme.wallpaperPath
                                            else
                                                return "Dynamic colors from wallpaper"
                                        }
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: {
                                            if (ToastService.wallpaperErrorStatus === "error" || ToastService.wallpaperErrorStatus === "matugen_missing")
                                                return Theme.error
                                            else
                                                return Theme.surfaceVariantText
                                        }
                                        elide: Text.ElideMiddle
                                        maximumLineCount: 2
                                        width: parent.width
                                        wrapMode: Text.WordWrap
                                    }
                                }
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: Theme.spacingM
                            visible: Theme.currentThemeName === "custom"

                            Row {
                                width: parent.width
                                spacing: Theme.spacingM

                                DarkActionButton {
                                    buttonSize: 48
                                    iconName: "folder_open"
                                    iconSize: Theme.iconSize
                                    backgroundColor: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12)
                                    iconColor: Theme.primary
                                    onClicked: fileBrowserModal.open()
                                }

                                Column {
                                    width: parent.width - 48 - Theme.spacingM
                                    spacing: Theme.spacingXS
                                    anchors.verticalCenter: parent.verticalCenter

                                    StyledText {
                                        text: SettingsData.customThemeFile ? SettingsData.customThemeFile.split('/').pop() : "No custom theme file"
                                        font.pixelSize: Theme.fontSizeLarge
                                        color: Theme.surfaceText
                                        elide: Text.ElideMiddle
                                        maximumLineCount: 1
                                        width: parent.width
                                    }

                                    StyledText {
                                        text: SettingsData.customThemeFile || "Click to select a custom theme JSON file"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                        elide: Text.ElideMiddle
                                        maximumLineCount: 1
                                        width: parent.width
                                    }
                                }
                            }
                        }
                    }
                }
            }


            StyledRect {
                width: parent.width
                height: transparencySection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: transparencySection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "opacity"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                    StyledText {
                        text: "Transparency & Opacity"
                        font.pixelSize: Theme.fontSizeLarge
                        font.weight: Font.Medium
                        color: Theme.surfaceText
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                StyledText {
                    text: "Control the transparency levels of various UI elements"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    wrapMode: Text.WordWrap
                    width: parent.width
                    horizontalAlignment: Text.AlignLeft
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.spacingL
                }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        Item {
                            width: parent.width
                            height: Math.max(transparencyLabel.height, widgetColorGroup.height)

                            StyledText {
                                id: transparencyLabel
                                text: "Top Bar Widget Transparency"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            DarkButtonGroup {
                                id: widgetColorGroup
                                property int currentColorIndex: {
                                    switch (SettingsData.widgetBackgroundColor) {
                                        case "sth": return 0
                                        case "s": return 1
                                        case "sc": return 2
                                        case "sch": return 3
                                        default: return 0
                                    }
                                }

                                model: ["sth", "s", "sc", "sch"]
                                currentIndex: currentColorIndex
                                selectionMode: "single"
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter

                                buttonHeight: 20
                                minButtonWidth: 32
                                buttonPadding: Theme.spacingS
                                checkIconSize: Theme.iconSizeSmall - 2
                                textSize: Theme.fontSizeSmall - 2
                                spacing: 1

                                onSelectionChanged: (index, selected) => {
                                    if (!selected) return
                                    const colorOptions = ["sth", "s", "sc", "sch"]
                                    SettingsData.setWidgetBackgroundColor(colorOptions[index])
                                }
                            }
                        }

                        DarkSlider {
                            width: parent.width
                            height: 24
                            value: Math.round(
                                       SettingsData.topBarWidgetTransparency * 100)
                            minimum: 0
                            maximum: 100
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setTopBarWidgetTransparency(
                                                          newValue / 100)
                                                  }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Popup Transparency"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 24
                            value: Math.round(
                                       SettingsData.popupTransparency * 100)
                            minimum: 0
                            maximum: 100
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setPopupTransparency(
                                                          newValue / 100)
                                                  }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Modal Transparency"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 24
                            value: Math.round(
                                       SettingsData.modalTransparency * 100)
                            minimum: 0
                            maximum: 100
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setModalTransparency(
                                                          newValue / 100)
                                                  }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Notification Transparency"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 24
                            value: Math.round(
                                       SettingsData.notificationTransparency * 100)
                            minimum: 0
                            maximum: 100
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setNotificationTransparency(
                                                          newValue / 100)
                                                  }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Control Center Transparency"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 24
                            value: Math.round(
                                       SettingsData.controlCenterTransparency * 100)
                            minimum: 0
                            maximum: 100
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setControlCenterTransparency(
                                                          newValue / 100)
                                                  }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Control Center Widget Background Opacity"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 24
                            value: Math.round(
                                       SettingsData.controlCenterWidgetBackgroundOpacity * 100)
                            minimum: 0
                            maximum: 100
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setControlCenterWidgetBackgroundOpacity(
                                                          newValue / 100)
                                                  }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: darkDashSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: darkDashSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "dashboard"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Dark Dash"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    StyledText {
                        text: "Customize transparency and shadow effects for the Dark Dash popout"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Dark Dash Transparency"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 24
                            value: Math.round(
                                       SettingsData.darkDashTransparency * 100)
                            minimum: 0
                            maximum: 100
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setDarkDashTransparency(
                                                          newValue / 100)
                                                  }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Dark Dash Drop Shadow Opacity"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 24
                            value: Math.round(
                                       SettingsData.darkDashDropShadowOpacity * 100)
                            minimum: 0
                            maximum: 100
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setDarkDashDropShadowOpacity(
                                                          newValue / 100)
                                                  }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Dark Dash Border Opacity"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 24
                            value: Math.round(
                                       SettingsData.darkDashBorderOpacity * 100)
                            minimum: 0
                            maximum: 100
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setDarkDashBorderOpacity(
                                                          newValue / 100)
                                                  }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Dark Dash Border Thickness"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 24
                            value: SettingsData.darkDashBorderThickness
                            minimum: 0
                            maximum: 10
                            unit: "px"
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setDarkDashBorderThickness(
                                                          newValue)
                                                  }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Dark Dash Tab Bar Opacity"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 24
                            value: Math.round(
                                       SettingsData.darkDashTabBarOpacity * 100)
                            minimum: 0
                            maximum: 100
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setDarkDashTabBarOpacity(
                                                          newValue / 100)
                                                  }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Dark Dash Content Background Opacity"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 24
                            value: Math.round(
                                       SettingsData.darkDashContentBackgroundOpacity * 100)
                            minimum: 0
                            maximum: 100
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setDarkDashContentBackgroundOpacity(
                                                          newValue / 100)
                                                  }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Dark Dash Animated Tint Opacity"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 24
                            value: Math.round(
                                       SettingsData.darkDashAnimatedTintOpacity * 100)
                            minimum: 0
                            maximum: 100
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setDarkDashAnimatedTintOpacity(
                                                          newValue / 100)
                                                  }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: desktopDarkDashSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: desktopDarkDashSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "dashboard"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Desktop Dark Dash Widget"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    StyledText {
                        text: "Customize transparency and shadow effects for the Desktop Dark Dash widget"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Desktop Dark Dash Transparency"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 24
                            value: Math.round(
                                       SettingsData.desktopDarkDashTransparency * 100)
                            minimum: 0
                            maximum: 100
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setDesktopDarkDashTransparency(
                                                          newValue / 100)
                                                  }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Desktop Dark Dash Drop Shadow Opacity"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 24
                            value: Math.round(
                                       SettingsData.desktopDarkDashDropShadowOpacity * 100)
                            minimum: 0
                            maximum: 100
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setDesktopDarkDashDropShadowOpacity(
                                                          newValue / 100)
                                                  }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Desktop Dark Dash Border Opacity"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 24
                            value: Math.round(
                                       SettingsData.desktopDarkDashBorderOpacity * 100)
                            minimum: 0
                            maximum: 100
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setDesktopDarkDashBorderOpacity(
                                                          newValue / 100)
                                                  }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Desktop Dark Dash Border Thickness"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 24
                            value: SettingsData.desktopDarkDashBorderThickness
                            minimum: 0
                            maximum: 10
                            unit: "px"
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setDesktopDarkDashBorderThickness(
                                                          newValue)
                                                  }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Desktop Dark Dash Tab Bar Opacity"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 24
                            value: Math.round(
                                       SettingsData.desktopDarkDashTabBarOpacity * 100)
                            minimum: 0
                            maximum: 100
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setDesktopDarkDashTabBarOpacity(
                                                          newValue / 100)
                                                  }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Desktop Dark Dash Content Background Opacity"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 24
                            value: Math.round(
                                       SettingsData.desktopDarkDashContentBackgroundOpacity * 100)
                            minimum: 0
                            maximum: 100
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setDesktopDarkDashContentBackgroundOpacity(
                                                          newValue / 100)
                                                  }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Desktop Dark Dash Animated Tint Opacity"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 24
                            value: Math.round(
                                       SettingsData.desktopDarkDashAnimatedTintOpacity * 100)
                            minimum: 0
                            maximum: 100
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setDesktopDarkDashAnimatedTintOpacity(
                                                          newValue / 100)
                                                  }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: desktopWidgetsSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: desktopWidgetsSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "widgets"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Desktop Widgets"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    StyledText {
                        text: "Customize transparency, shadow, and border effects for desktop widgets"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Desktop Widget Drop Shadow Opacity"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 24
                            value: Math.round(
                                       SettingsData.desktopWidgetDropShadowOpacity * 100)
                            minimum: 0
                            maximum: 100
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setDesktopWidgetDropShadowOpacity(
                                                          newValue / 100)
                                                  }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Desktop Widget Border Opacity"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 24
                            value: Math.round(
                                       SettingsData.desktopWidgetBorderOpacity * 100)
                            minimum: 0
                            maximum: 100
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setDesktopWidgetBorderOpacity(
                                                          newValue / 100)
                                                  }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Desktop Widget Border Thickness"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 24
                            value: SettingsData.desktopWidgetBorderThickness
                            minimum: 0
                            maximum: 10
                            unit: "px"
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setDesktopWidgetBorderThickness(
                                                          newValue)
                                                  }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: iconTintingSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: iconTintingSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "palette"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingM
                                   - iconTintingToggle.width - Theme.spacingM
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: "Icon Color Tinting"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Apply wallpaper-based color tinting to system icons and system tray icons"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }

                        DarkToggle {
                            id: iconTintingToggle

                            anchors.verticalCenter: parent.verticalCenter
                            checked: SettingsData.systemIconTinting
                            onToggled: checked => {
                                SettingsData.setSystemIconTinting(checked)
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS
                        visible: SettingsData.systemIconTinting

                        StyledText {
                            text: "Tint Intensity"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 24
                            value: Math.round(SettingsData.iconTintIntensity * 100)
                            minimum: 0
                            maximum: 100
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                SettingsData.setIconTintIntensity(newValue / 100)
                            }
                        }

                        StyledText {
                            text: "Controls how strongly the wallpaper colors are applied to icons"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: bordersShadowsSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: bordersShadowsSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "border_style"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                    StyledText {
                        text: "Borders & Shadows"
                        font.pixelSize: Theme.fontSizeLarge
                        font.weight: Font.Medium
                        color: Theme.surfaceText
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                StyledText {
                    text: "Customize border styles and shadow effects for UI components"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    wrapMode: Text.WordWrap
                    width: parent.width
                    horizontalAlignment: Text.AlignLeft
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.spacingL
                }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Control Center Drop Shadow Opacity"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 24
                            value: Math.round(
                                       SettingsData.controlCenterDropShadowOpacity * 100)
                            minimum: 0
                            maximum: 100
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setControlCenterDropShadowOpacity(
                                                          newValue / 100)
                                                  }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Top Bar Drop Shadow Opacity"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 24
                            value: Math.round(
                                       SettingsData.topBarDropShadowOpacity * 100)
                            minimum: 0
                            maximum: 100
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setTopBarDropShadowOpacity(
                                                          newValue / 100)
                                                  }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Control Center Border Opacity"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 24
                            value: Math.round(
                                       SettingsData.controlCenterBorderOpacity * 100)
                            minimum: 0
                            maximum: 100
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setControlCenterBorderOpacity(
                                                          newValue / 100)
                                                  }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Control Center Border Thickness"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 24
                            value: SettingsData.controlCenterBorderThickness
                            minimum: 0
                            maximum: 10
                            unit: "px"
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setControlCenterBorderThickness(
                                                          newValue)
                                                  }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Settings Border Opacity"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 24
                            value: Math.round(
                                       SettingsData.settingsBorderOpacity * 100)
                            minimum: 0
                            maximum: 100
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setSettingsBorderOpacity(
                                                          newValue / 100)
                                                  }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Settings Border Thickness"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 24
                            value: SettingsData.settingsBorderThickness
                            minimum: 0
                            maximum: 10
                            unit: "px"
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setSettingsBorderThickness(
                                                          newValue)
                                                  }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: visualEffectsSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: visualEffectsSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "auto_fix_high"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                    StyledText {
                        text: "Visual Effects"
                        font.pixelSize: Theme.fontSizeLarge
                        font.weight: Font.Medium
                        color: Theme.surfaceText
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                StyledText {
                    text: "Adjust color intensity, corner rounding, and blur effects"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    wrapMode: Text.WordWrap
                    width: parent.width
                    horizontalAlignment: Text.AlignLeft
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.spacingL
                }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Color Vibrance"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 24
                            value: SettingsData.colorVibrance * 100
                            minimum: 0
                            maximum: 100
                            unit: "%"
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setColorVibrance(
                                                          newValue / 100)
                                                  }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Corner Radius (0 = square corners)"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 24
                            value: SettingsData.cornerRadius
                            minimum: 0
                            maximum: 32
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setCornerRadius(
                                                          newValue)
                                                  }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Hyprland Blur Size"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 24
                            value: SettingsData.hyprlandBlurSize
                            minimum: 0
                            maximum: 20
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setHyprlandBlurSize(
                                                          newValue)
                                                  }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Hyprland Blur Passes"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 24
                            value: SettingsData.hyprlandBlurPasses
                            minimum: 1
                            maximum: 10
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setHyprlandBlurPasses(
                                                          newValue)
                                                  }
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: warningText.implicitHeight + Theme.spacingM * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.warning.r, Theme.warning.g,
                               Theme.warning.b, 0.12)
                border.color: Qt.rgba(Theme.warning.r, Theme.warning.g,
                                      Theme.warning.b, 0.3)
                border.width: 1

                Row {
                    anchors.fill: parent
                    anchors.margins: Theme.spacingM
                    spacing: Theme.spacingM

                    DarkIcon {
                        name: "info"
                        size: Theme.iconSizeSmall
                        color: Theme.warning
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    StyledText {
                        id: warningText
                        font.pixelSize: Theme.fontSizeSmall
                        text: "The below settings will modify your GTK and Qt settings. If you wish to preserve your current configurations, please back them up (qt5ct.conf|qt6ct.conf and ~/.config/gtk-3.0|gtk-4.0)."
                        wrapMode: Text.WordWrap
                        width: parent.width - Theme.iconSizeSmall - Theme.spacingM
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: iconThemeSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: iconThemeSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingXS

                        DarkIcon {
                            name: "image"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        DarkDropdown {
                            width: parent.width - Theme.iconSize - Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Icon Theme"
                            description: "DarkShell & System Icons\n(requires restart)"
                            currentValue: SettingsData.iconTheme
                            enableFuzzySearch: true
                            popupWidthOffset: 100
                            maxPopupHeight: 236
                            options: {
                                SettingsData.detectAvailableIconThemes()
                                return SettingsData.availableIconThemes
                            }
                            onValueChanged: value => {
                                                SettingsData.setIconTheme(value)
                                                if (Quickshell.env("QT_QPA_PLATFORMTHEME") != "gtk3" &&
                                                    Quickshell.env("QT_QPA_PLATFORMTHEME") != "qt6ct" &&
                                                    Quickshell.env("QT_QPA_PLATFORMTHEME_QT6") != "qt6ct") {
                                                    ToastService.showError("Missing Environment Variables", "You need to set either:\nQT_QPA_PLATFORMTHEME=gtk3 OR\nQT_QPA_PLATFORMTHEME=qt6ct\nas environment variables, and then restart the shell.\n\nqt6ct requires qt6ct-kde to be installed.")
                                                }
                                            }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: gtkThemeSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: gtkThemeSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingXS

                        DarkIcon {
                            name: "palette"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        DarkDropdown {
                            width: parent.width - Theme.iconSize - Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter
                            text: "GTK Theme"
                            description: "GTK3/GTK4 Applications\n(requires restart)"
                            currentValue: SettingsData.gtkTheme
                            enableFuzzySearch: true
                            popupWidthOffset: 100
                            maxPopupHeight: 236
                            options: {
                                SettingsData.detectAvailableGtkThemes()
                                return SettingsData.availableGtkThemes
                            }
                            onValueChanged: value => {
                                                SettingsData.setGtkTheme(value)
                                                ToastService.showInfo("GTK theme changed", "Restart GTK applications to see changes")
                                            }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: shellThemeSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: shellThemeSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingXS

                        DarkIcon {
                            name: "extension"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingXS
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            DarkDropdown {
                                width: parent.width
                                text: "GNOME Shell Theme"
                                description: SettingsData.userThemeExtensionAvailable && SettingsData.userThemeExtensionEnabled 
                                            ? "Shell Interface Theme\n(requires shell restart)" 
                                            : SettingsData.userThemeExtensionAvailable 
                                            ? "Shell Interface Theme\n(extension not enabled)" 
                                            : "Shell Interface Theme\n(CSS fallback, no extension)"
                                currentValue: SettingsData.shellTheme
                                enableFuzzySearch: true
                                popupWidthOffset: 100
                                maxPopupHeight: 236
                                options: {
                                    SettingsData.detectAvailableShellThemes()
                                    return SettingsData.availableShellThemes
                                }
                                onValueChanged: value => {
                                                    SettingsData.setShellTheme(value)
                                                }
                            }

                            StyledText {
                                visible: !SettingsData.userThemeExtensionAvailable
                                text: "Note: Using CSS fallback method. Only CSS styling is applied, not full theme assets. Install the user-theme extension for full theme support."
                                font.pixelSize: Theme.fontSizeSmall - 1
                                color: Theme.warning || "#ff9800"
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }

                            StyledText {
                                visible: SettingsData.userThemeExtensionAvailable && !SettingsData.userThemeExtensionEnabled
                                text: "Note: Extension is installed but not enabled. Enable it in GNOME Tweaks or Extensions app for full theme support."
                                font.pixelSize: Theme.fontSizeSmall - 1
                                color: Theme.warning || "#ff9800"
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: qtThemeSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: qtThemeSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingXS

                        DarkIcon {
                            name: "settings"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingXS
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            DarkDropdown {
                                width: parent.width
                                text: "QT Theme"
                                description: SettingsData.qt5ctAvailable || SettingsData.qt6ctAvailable
                                            ? "QT5/QT6 Applications\n(requires restart)"
                                            : "QT5/QT6 Applications\n(qt5ct/qt6ct not found)"
                                currentValue: SettingsData.qtTheme
                                enableFuzzySearch: true
                                popupWidthOffset: 100
                                maxPopupHeight: 236
                                options: {
                                    SettingsData.detectAvailableQtThemes()
                                    return SettingsData.availableQtThemes
                                }
                                onValueChanged: value => {
                                                    SettingsData.setQtTheme(value)
                                                    if (SettingsData.qt5ctAvailable || SettingsData.qt6ctAvailable) {
                                                        ToastService.showInfo("QT theme changed", "Restart QT applications to see changes")
                                                    }
                                                }
                            }

                            StyledText {
                                visible: !SettingsData.qt5ctAvailable && !SettingsData.qt6ctAvailable
                                text: "Note: Install qt5ct or qt6ct for QT theme support. Without these tools, theme changes will not be applied."
                                font.pixelSize: Theme.fontSizeSmall - 1
                                color: Theme.warning || "#ff9800"
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: cursorThemeSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: cursorThemeSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingXS

                        DarkIcon {
                            name: "ads_click"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingXS
                            spacing: Theme.spacingS
                            anchors.verticalCenter: parent.verticalCenter

                            DarkDropdown {
                                width: parent.width
                                text: "Cursor Theme"
                                description: "Mouse Cursor Appearance"
                                currentValue: SettingsData.cursorTheme
                                enableFuzzySearch: true
                                popupWidthOffset: 100
                                maxPopupHeight: 236
                                options: {
                                    SettingsData.detectAvailableCursorThemes()
                                    return SettingsData.availableCursorThemes
                                }
                                onValueChanged: value => {
                                                    SettingsData.setCursorTheme(value, SettingsData.cursorSize)
                                                    ToastService.showInfo("Cursor theme changed", "Cursor theme updated. You may need to log out and back in for full effect.")
                                                }
                            }

                            Column {
                                width: parent.width
                                spacing: Theme.spacingXS

                                StyledText {
                                    text: "Cursor Size: " + SettingsData.cursorSize + "px"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceText
                                    font.weight: Font.Medium
                                }

                                DarkSlider {
                                    width: parent.width
                                    height: 24
                                    value: SettingsData.cursorSize
                                    minimum: 16
                                    maximum: 48
                                    unit: "px"
                                    showValue: true
                                    wheelEnabled: false
                                    onSliderValueChanged: newValue => {
                                                              SettingsData.setCursorTheme(SettingsData.cursorTheme, newValue)
                                                              ToastService.showInfo("Cursor size changed", "Cursor size updated to " + newValue + "px")
                                                          }
                                }
                            }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: systemThemingSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1
                visible: Theme.matugenAvailable

                Column {
                    id: systemThemingSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "extension"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "System App Theming"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        Rectangle {
                            width: (parent.width - Theme.spacingM) / 2
                            height: 48
                            radius: Theme.cornerRadius
                            color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12)
                            border.color: Theme.primary
                            border.width: 1

                            Row {
                                anchors.centerIn: parent
                                spacing: Theme.spacingS

                                DarkIcon {
                                    name: "folder"
                                    size: 16
                                    color: Theme.primary
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                StyledText {
                                    text: "Apply GTK Colors"
                                    font.pixelSize: Theme.fontSizeMedium
                                    color: Theme.primary
                                    font.weight: Font.Medium
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Theme.applyGtkColors()
                            }
                        }

                        Rectangle {
                            width: (parent.width - Theme.spacingM) / 2
                            height: 48
                            radius: Theme.cornerRadius
                            color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12)
                            border.color: Theme.primary
                            border.width: 1

                            Row {
                                anchors.centerIn: parent
                                spacing: Theme.spacingS

                                DarkIcon {
                                    name: "settings"
                                    size: 16
                                    color: Theme.primary
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                StyledText {
                                    text: "Apply Qt Colors"
                                    font.pixelSize: Theme.fontSizeMedium
                                    color: Theme.primary
                                    font.weight: Font.Medium
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Theme.applyQtColors()
                            }
                        }
                    }

                    StyledText {
                        text: `Generate baseline GTK3/4 or QT5/QT6 (requires qt6ct-kde) configurations to follow DMS colors. Only needed once.<br /><br />It is recommended to install <a href="https://github.com/AvengeMedia/DarkMaterialShell/blob/master/README.md#Theming" style="text-decoration:none; color:${Theme.primary};">Colloid</a> GTK theme prior to applying GTK themes.`
                        textFormat: Text.RichText
                        linkColor: Theme.primary
                        onLinkActivated: url => Qt.openUrlExternally(url)
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        wrapMode: Text.WordWrap
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                            acceptedButtons: Qt.NoButton
                            propagateComposedEvents: true
                        }
                    }
                }
            }
        }
    }

    FileBrowserModal {
        id: fileBrowserModal
        browserTitle: "Select Custom Theme"
        filterExtensions: ["*.json"]
        showHiddenFiles: true

        function selectCustomTheme() {
            shouldBeVisible = true
        }

        onFileSelected: function(filePath) {
            if (filePath.endsWith(".json")) {
                SettingsData.setCustomThemeFile(filePath)
                Theme.switchTheme("custom")
                close()
            }
        }
    }
}
