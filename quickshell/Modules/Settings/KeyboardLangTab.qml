import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Widgets
import qs.Services

Item {
    id: keyboardLangTab

    property var filteredLayouts: []
    property string layoutSearchText: ""
    property var filteredLocales: []
    property string localeSearchText: ""

    Component.onCompleted: {
        KeyboardService.refreshStatus()
        KeyboardService.listLayouts()
        KeyboardService.listLocales()
        // Initialize filtered lists
        filteredLayouts = KeyboardService.availableLayouts
        filteredLocales = KeyboardService.availableLocales
    }

    Connections {
        target: KeyboardService
        function onAvailableLayoutsChanged() {
            updateFilteredLayouts()
        }
        function onAvailableLocalesChanged() {
            updateFilteredLocales()
        }
        function onCurrentLayoutChanged() {
            // Update UI when layout changes
        }
        function onCurrentLocaleChanged() {
            // Update UI when locale changes
        }
    }

    function updateFilteredLayouts() {
        if (!layoutSearchText || layoutSearchText.length === 0) {
            filteredLayouts = KeyboardService.availableLayouts
        } else {
            const search = layoutSearchText.toLowerCase()
            filteredLayouts = KeyboardService.availableLayouts.filter(layout => {
                return layout.toLowerCase().includes(search)
            })
        }
    }

    function updateFilteredLocales() {
        if (!localeSearchText || localeSearchText.length === 0) {
            filteredLocales = KeyboardService.availableLocales
        } else {
            const search = localeSearchText.toLowerCase()
            filteredLocales = KeyboardService.availableLocales.filter(locale => {
                return locale.toLowerCase().includes(search)
            })
        }
    }

    DankFlickable {
        anchors.fill: parent
        anchors.topMargin: Theme.spacingL
        clip: true
        contentHeight: mainColumn.height
        contentWidth: width

        Column {
            id: mainColumn

            width: parent.width
            spacing: Theme.spacingXL

            // Current Keyboard Layout Section
            StyledRect {
                width: parent.width
                height: currentLayoutSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: currentLayoutSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "keyboard"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingM
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: "Current Keyboard Layout"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: KeyboardService.currentLayout ? (KeyboardService.currentLayout + (KeyboardService.currentVariant ? " (" + KeyboardService.currentVariant + ")" : "")) : "Unknown"
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.surfaceVariantText
                            }
                        }
                    }
                }
            }

            // Keyboard Layout Selection Section
            StyledRect {
                width: parent.width
                height: layoutSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: layoutSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "keyboard"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Keyboard Layout"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    StyledText {
                        text: "Select a keyboard layout to use for typing"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }

                    DankTextField {
                        width: parent.width
                        placeholderText: "Search keyboard layouts..."
                        text: layoutSearchText
                        onTextEdited: {
                            layoutSearchText = text
                            updateFilteredLayouts()
                        }
                    }

                    DankDropdown {
                        width: parent.width
                        text: "Layout"
                        description: "Choose keyboard layout"
                        enableFuzzySearch: true
                        popupWidthOffset: 100
                        maxPopupHeight: 400
                        currentValue: KeyboardService.currentLayout || ""
                        options: filteredLayouts
                        onValueChanged: value => {
                            if (value && value.length > 0) {
                                KeyboardService.setLayout(value, KeyboardService.currentVariant)
                                // Load variants for this layout
                                KeyboardService.listVariants(value)
                            }
                        }
                    }

                    DankDropdown {
                        width: parent.width
                        text: "Variant"
                        description: "Choose keyboard layout variant (optional)"
                        enableFuzzySearch: true
                        popupWidthOffset: 100
                        maxPopupHeight: 300
                        currentValue: KeyboardService.currentVariant || ""
                        options: ["", ...KeyboardService.availableVariants]
                        visible: KeyboardService.availableVariants.length > 0
                        onValueChanged: value => {
                            if (KeyboardService.currentLayout) {
                                KeyboardService.setLayout(KeyboardService.currentLayout, value || "")
                            }
                        }
                    }

                    Connections {
                        target: KeyboardService
                        function onCurrentLayoutChanged() {
                            if (KeyboardService.currentLayout) {
                                KeyboardService.listVariants(KeyboardService.currentLayout)
                            }
                        }
                    }

                    // Error display
                    Rectangle {
                        width: parent.width
                        height: errorLayoutInfo.implicitHeight + Theme.spacingM * 2
                        radius: Theme.cornerRadius
                        color: Qt.rgba(Theme.error.r, Theme.error.g,
                                       Theme.error.b, 0.1)
                        border.color: Qt.rgba(Theme.error.r, Theme.error.g,
                                              Theme.error.b, 0.3)
                        border.width: 1
                        visible: KeyboardService.lastError && KeyboardService.lastError.length > 0

                        Column {
                            id: errorLayoutInfo

                            anchors.fill: parent
                            anchors.margins: Theme.spacingM
                            spacing: Theme.spacingXS

                            StyledText {
                                text: "Error: " + KeyboardService.lastError
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.error
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }
                    }
                }
            }

            // Language and Region Section
            StyledRect {
                width: parent.width
                height: localeSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: localeSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "language"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Language & Region"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    StyledText {
                        text: "Change system language and regional settings"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }

                    // Current Locale Display
                    Rectangle {
                        width: parent.width
                        height: currentLocaleInfo.implicitHeight + Theme.spacingM * 2
                        radius: Theme.cornerRadius
                        color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                                       Theme.surfaceVariant.b, 0.2)
                        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                              Theme.outline.b, 0.1)
                        border.width: 1

                        Column {
                            id: currentLocaleInfo

                            anchors.fill: parent
                            anchors.margins: Theme.spacingM
                            spacing: Theme.spacingXS

                            StyledText {
                                text: "Current Locale: " + (KeyboardService.currentLocale || "Unknown")
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                width: parent.width
                            }

                            StyledText {
                                text: "Language: " + (KeyboardService.currentLanguage || "Unknown") + " | Region: " + (KeyboardService.currentRegion || "Unknown")
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                width: parent.width
                            }
                        }
                    }

                    DankTextField {
                        width: parent.width
                        placeholderText: "Search locales..."
                        text: localeSearchText
                        onTextEdited: {
                            localeSearchText = text
                            updateFilteredLocales()
                        }
                    }

                    DankDropdown {
                        width: parent.width
                        text: "System Locale"
                        description: "Choose system language and region"
                        enableFuzzySearch: true
                        popupWidthOffset: 100
                        maxPopupHeight: 400
                        currentValue: KeyboardService.currentLocale || ""
                        options: filteredLocales
                        onValueChanged: value => {
                            if (value && value.length > 0) {
                                KeyboardService.setLocale(value)
                            }
                        }
                    }

                    StyledText {
                        text: "Note: Changing the locale may require a system restart to take full effect. Some applications may need to be restarted."
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }

                    // Error display
                    Rectangle {
                        width: parent.width
                        height: errorLocaleInfo.implicitHeight + Theme.spacingM * 2
                        radius: Theme.cornerRadius
                        color: Qt.rgba(Theme.error.r, Theme.error.g,
                                       Theme.error.b, 0.1)
                        border.color: Qt.rgba(Theme.error.r, Theme.error.g,
                                              Theme.error.b, 0.3)
                        border.width: 1
                        visible: KeyboardService.lastError && KeyboardService.lastError.length > 0

                        Column {
                            id: errorLocaleInfo

                            anchors.fill: parent
                            anchors.margins: Theme.spacingM
                            spacing: Theme.spacingXS

                            StyledText {
                                text: "Error: " + KeyboardService.lastError
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.error
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }
                    }
                }
            }
        }
    }
}



