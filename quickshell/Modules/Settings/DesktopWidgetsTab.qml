import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Widgets

Item {
    id: desktopWidgetsTab

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
                height: enableSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: enableSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    DarkToggle {
                        width: parent.width
                        text: "Enable Desktop Widgets"
                        description: "Master switch to enable/disable all desktop widgets"
                        checked: SettingsData.desktopWidgetsEnabled
                        onToggled: checked => {
                            SettingsData.setDesktopWidgetsEnabled(checked)
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: cpuTempSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1
                visible: SettingsData.desktopWidgetsEnabled
                opacity: visible ? 1 : 0

                Column {
                    id: cpuTempSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "device_thermostat"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.spacingXS
                            width: parent.width - Theme.iconSize - Theme.spacingM

                            StyledText {
                                text: "CPU Temperature Widget"
                                font.pixelSize: Theme.fontSizeLarge
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                            }

                            StyledText {
                                text: "Shows CPU temperature with color-coded warnings"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceTextMedium
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }
                    }

                    DarkToggle {
                        width: parent.width
                        text: "Enable CPU Temperature Widget"
                        checked: SettingsData.desktopCpuTempEnabled
                        onToggled: checked => {
                            SettingsData.setDesktopCpuTempEnabled(checked)
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingXS
                        visible: SettingsData.desktopCpuTempEnabled
                        opacity: visible ? 1 : 0

                        StyledText {
                            text: "Opacity: " + Math.round(SettingsData.desktopCpuTempOpacity * 100) + "%"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceTextMedium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 32
                            value: Math.round(SettingsData.desktopCpuTempOpacity * 100)
                            minimum: 10
                            maximum: 100
                            unit: "%"
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                SettingsData.setDesktopCpuTempOpacity(newValue / 100)
                            }
                        }
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.mediumDuration
                            easing.type: Theme.emphasizedEasing
                        }
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.mediumDuration
                        easing.type: Theme.emphasizedEasing
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: gpuTempSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1
                visible: SettingsData.desktopWidgetsEnabled
                opacity: visible ? 1 : 0

                Column {
                    id: gpuTempSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "auto_awesome_mosaic"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.spacingXS
                            width: parent.width - Theme.iconSize - Theme.spacingM

                            StyledText {
                                text: "GPU Temperature Widget"
                                font.pixelSize: Theme.fontSizeLarge
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                            }

                            StyledText {
                                text: "Shows GPU temperature with color-coded warnings"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceTextMedium
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }
                    }

                    DarkToggle {
                        width: parent.width
                        text: "Enable GPU Temperature Widget"
                        checked: SettingsData.desktopGpuTempEnabled
                        onToggled: checked => {
                            SettingsData.setDesktopGpuTempEnabled(checked)
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingXS
                        visible: SettingsData.desktopGpuTempEnabled
                        opacity: visible ? 1 : 0

                        StyledText {
                            text: "Opacity: " + Math.round(SettingsData.desktopGpuTempOpacity * 100) + "%"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceTextMedium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 32
                            value: Math.round(SettingsData.desktopGpuTempOpacity * 100)
                            minimum: 10
                            maximum: 100
                            unit: "%"
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                SettingsData.setDesktopGpuTempOpacity(newValue / 100)
                            }
                        }
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.mediumDuration
                            easing.type: Theme.emphasizedEasing
                        }
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.mediumDuration
                        easing.type: Theme.emphasizedEasing
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: systemMonitorSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1
                visible: SettingsData.desktopWidgetsEnabled
                opacity: visible ? 1 : 0

                Column {
                    id: systemMonitorSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "monitor"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.spacingXS
                            width: parent.width - Theme.iconSize - Theme.spacingM

                            StyledText {
                                text: "System Monitor Widget"
                                font.pixelSize: Theme.fontSizeLarge
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                            }

                            StyledText {
                                text: "Shows CPU temperature, GPU temperature, and RAM usage in one widget"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceTextMedium
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }
                    }

                    DarkToggle {
                        width: parent.width
                        text: "Enable System Monitor Widget"
                        checked: SettingsData.desktopSystemMonitorEnabled
                        onToggled: checked => {
                            SettingsData.setDesktopSystemMonitorEnabled(checked)
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingXS
                        visible: SettingsData.desktopSystemMonitorEnabled
                        opacity: visible ? 1 : 0

                        StyledText {
                            text: "Size: " + SettingsData.desktopSystemMonitorWidth + "x" + SettingsData.desktopSystemMonitorHeight
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceTextMedium
                        }

                        Column {
                            width: parent.width
                            spacing: 4

                            StyledText {
                                text: "Width: " + SettingsData.desktopSystemMonitorWidth + "px"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceTextMedium
                            }

                            DarkSlider {
                                width: parent.width
                                height: 32
                                value: SettingsData.desktopSystemMonitorWidth
                                minimum: 200
                                maximum: 600
                                unit: "px"
                                showValue: true
                                wheelEnabled: false
                                onSliderValueChanged: newValue => {
                                    SettingsData.setDesktopSystemMonitorWidth(newValue)
                                }
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: 4

                            StyledText {
                                text: "Height: " + SettingsData.desktopSystemMonitorHeight + "px"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceTextMedium
                            }

                            DarkSlider {
                                width: parent.width
                                height: 32
                                value: SettingsData.desktopSystemMonitorHeight
                                minimum: 120
                                maximum: 400
                                unit: "px"
                                showValue: true
                                wheelEnabled: false
                                onSliderValueChanged: newValue => {
                                    SettingsData.setDesktopSystemMonitorHeight(newValue)
                                }
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingXS
                        visible: SettingsData.desktopSystemMonitorEnabled
                        opacity: visible ? 1 : 0

                        StyledText {
                            text: "Opacity: " + Math.round(SettingsData.desktopSystemMonitorOpacity * 100) + "%"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceTextMedium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 32
                            value: Math.round(SettingsData.desktopSystemMonitorOpacity * 100)
                            minimum: 10
                            maximum: 100
                            unit: "%"
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                SettingsData.setDesktopSystemMonitorOpacity(newValue / 100)
                            }
                        }
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.mediumDuration
                            easing.type: Theme.emphasizedEasing
                        }
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.mediumDuration
                        easing.type: Theme.emphasizedEasing
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: clockSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1
                visible: SettingsData.desktopWidgetsEnabled
                opacity: visible ? 1 : 0

                Column {
                    id: clockSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "schedule"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.spacingXS
                            width: parent.width - Theme.iconSize - Theme.spacingM

                            StyledText {
                                text: "Desktop Clock Widget"
                                font.pixelSize: Theme.fontSizeLarge
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                            }

                            StyledText {
                                text: "Shows current time and date on the desktop"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceTextMedium
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }
                    }

                    DarkToggle {
                        width: parent.width
                        text: "Enable Desktop Clock Widget"
                        checked: SettingsData.desktopClockEnabled
                        onToggled: checked => {
                            SettingsData.setDesktopClockEnabled(checked)
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingXS
                        visible: SettingsData.desktopClockEnabled
                        opacity: visible ? 1 : 0

                        StyledText {
                            text: "Opacity: " + Math.round(SettingsData.desktopClockOpacity * 100) + "%"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceTextMedium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 32
                            value: Math.round(SettingsData.desktopClockOpacity * 100)
                            minimum: 10
                            maximum: 100
                            unit: "%"
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                SettingsData.setDesktopClockOpacity(newValue / 100)
                            }
                        }
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.mediumDuration
                            easing.type: Theme.emphasizedEasing
                        }
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.mediumDuration
                        easing.type: Theme.emphasizedEasing
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: terminalSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1
                visible: SettingsData.desktopWidgetsEnabled
                opacity: visible ? 1 : 0

                Column {
                    id: terminalSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "terminal"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.spacingXS
                            width: parent.width - Theme.iconSize - Theme.spacingM

                            StyledText {
                                text: "Desktop Terminal Widget"
                                font.pixelSize: Theme.fontSizeLarge
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                            }

                            StyledText {
                                text: "Interactive terminal widget for running commands directly on the desktop"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceTextMedium
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }
                    }

                    DarkToggle {
                        width: parent.width
                        text: "Enable Desktop Terminal Widget"
                        checked: SettingsData.desktopTerminalEnabled
                        onToggled: checked => {
                            SettingsData.setDesktopTerminalEnabled(checked)
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingXS
                        visible: SettingsData.desktopTerminalEnabled
                        opacity: visible ? 1 : 0

                        StyledText {
                            text: "Size: " + SettingsData.desktopTerminalWidth + "x" + SettingsData.desktopTerminalHeight
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceTextMedium
                        }

                        Column {
                            width: parent.width
                            spacing: 4

                            StyledText {
                                text: "Width: " + SettingsData.desktopTerminalWidth + "px"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceTextMedium
                            }

                            DarkSlider {
                                width: parent.width
                                height: 32
                                value: SettingsData.desktopTerminalWidth
                                minimum: 400
                                maximum: 1200
                                unit: "px"
                                showValue: true
                                wheelEnabled: false
                                onSliderValueChanged: newValue => {
                                    SettingsData.setDesktopTerminalWidth(newValue)
                                }
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: 4

                            StyledText {
                                text: "Height: " + SettingsData.desktopTerminalHeight + "px"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceTextMedium
                            }

                            DarkSlider {
                                width: parent.width
                                height: 32
                                value: SettingsData.desktopTerminalHeight
                                minimum: 200
                                maximum: 800
                                unit: "px"
                                showValue: true
                                wheelEnabled: false
                                onSliderValueChanged: newValue => {
                                    SettingsData.setDesktopTerminalHeight(newValue)
                                }
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: 4

                            StyledText {
                                text: "Font Size: " + SettingsData.desktopTerminalFontSize + "px"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceTextMedium
                            }

                            DarkSlider {
                                width: parent.width
                                height: 32
                                value: SettingsData.desktopTerminalFontSize
                                minimum: 8
                                maximum: 20
                                unit: "px"
                                showValue: true
                                wheelEnabled: false
                                onSliderValueChanged: newValue => {
                                    SettingsData.setDesktopTerminalFontSize(newValue)
                                }
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingXS
                        visible: SettingsData.desktopTerminalEnabled
                        opacity: visible ? 1 : 0

                        StyledText {
                            text: "Position"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceTextMedium
                        }

                        DarkDropdown {
                            width: 200
                            height: 40
                            options: ["top-left", "top-center", "top-right", "middle-left", "middle-center", "middle-right", "bottom-left", "bottom-center", "bottom-right"]
                            currentValue: SettingsData.desktopTerminalPosition
                            onValueChanged: {
                                SettingsData.setDesktopTerminalPosition(value)
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingXS
                        visible: SettingsData.desktopTerminalEnabled
                        opacity: visible ? 1 : 0

                        StyledText {
                            text: "Opacity: " + Math.round(SettingsData.desktopTerminalOpacity * 100) + "%"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceTextMedium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 32
                            value: Math.round(SettingsData.desktopTerminalOpacity * 100)
                            minimum: 10
                            maximum: 100
                            unit: "%"
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                SettingsData.setDesktopTerminalOpacity(newValue / 100)
                            }
                        }
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.mediumDuration
                            easing.type: Theme.emphasizedEasing
                        }
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.mediumDuration
                        easing.type: Theme.emphasizedEasing
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
                visible: SettingsData.desktopWidgetsEnabled
                opacity: visible ? 1 : 0

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

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.spacingXS
                            width: parent.width - Theme.iconSize - Theme.spacingM

                            StyledText {
                                text: "Desktop Dark Dash Widget"
                                font.pixelSize: Theme.fontSizeLarge
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                            }

                            StyledText {
                                text: "Persistent Dark Dash widget with overview, media, and weather tabs"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceTextMedium
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }
                    }

                    DarkToggle {
                        width: parent.width
                        text: "Enable Desktop Dark Dash Widget"
                        checked: SettingsData.desktopDarkDashEnabled
                        onToggled: checked => {
                            SettingsData.setDesktopDarkDashEnabled(checked)
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingXS
                        visible: SettingsData.desktopDarkDashEnabled
                        opacity: visible ? 1 : 0

                        StyledText {
                            text: "Size: " + SettingsData.desktopDarkDashWidth + "x" + SettingsData.desktopDarkDashHeight
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceTextMedium
                        }

                        Column {
                            width: parent.width
                            spacing: 4

                            StyledText {
                                text: "Width: " + SettingsData.desktopDarkDashWidth + "px"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceTextMedium
                            }

                            DarkSlider {
                                width: parent.width
                                height: 32
                                value: SettingsData.desktopDarkDashWidth
                                minimum: 500
                                maximum: 1200
                                unit: "px"
                                showValue: true
                                wheelEnabled: false
                                onSliderValueChanged: newValue => {
                                    SettingsData.setDesktopDarkDashWidth(newValue)
                                }
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: 4

                            StyledText {
                                text: "Height: " + SettingsData.desktopDarkDashHeight + "px"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceTextMedium
                            }

                            DarkSlider {
                                width: parent.width
                                height: 32
                                value: SettingsData.desktopDarkDashHeight
                                minimum: 400
                                maximum: 1000
                                unit: "px"
                                showValue: true
                                wheelEnabled: false
                                onSliderValueChanged: newValue => {
                                    SettingsData.setDesktopDarkDashHeight(newValue)
                                }
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingXS
                        visible: SettingsData.desktopDarkDashEnabled
                        opacity: visible ? 1 : 0

                        StyledText {
                            text: "Position"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceTextMedium
                        }

                        DarkDropdown {
                            width: 200
                            height: 40
                            options: ["top-left", "top-center", "top-right", "middle-left", "middle-center", "middle-right", "bottom-left", "bottom-center", "bottom-right"]
                            currentValue: SettingsData.desktopDarkDashPosition
                            onValueChanged: {
                                SettingsData.setDesktopDarkDashPosition(value)
                            }
                        }
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.mediumDuration
                            easing.type: Theme.emphasizedEasing
                        }
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.mediumDuration
                        easing.type: Theme.emphasizedEasing
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: weatherSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1
                visible: SettingsData.desktopWidgetsEnabled
                opacity: visible ? 1 : 0

                Column {
                    id: weatherSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "wb_sunny"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.spacingXS
                            width: parent.width - Theme.iconSize - Theme.spacingM

                            StyledText {
                                text: "Desktop Weather Widget"
                                font.pixelSize: Theme.fontSizeLarge
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                            }

                            StyledText {
                                text: "Shows current weather conditions, forecast, and detailed weather information on the desktop"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceTextMedium
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        Column {
                            spacing: Theme.spacingXS

                            StyledText {
                                text: "Position"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceTextMedium
                            }

                            DarkDropdown {
                                width: 200
                                height: 40
                                options: ["top-left", "top-center", "top-right", "center-left", "center", "center-right", "bottom-left", "bottom-center", "bottom-right"]
                                currentValue: SettingsData.desktopWeatherPosition
                                onValueChanged: {
                                    SettingsData.setDesktopWeatherPosition(value)
                                }
                            }
                        }

                        Column {
                            spacing: Theme.spacingXS

                            StyledText {
                                text: "Enabled"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceTextMedium
                            }

                            DarkToggle {
                                checked: SettingsData.desktopWeatherEnabled
                                onToggled: checked => {
                                    SettingsData.setDesktopWeatherEnabled(checked)
                                }
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingXS
                        visible: SettingsData.desktopWeatherEnabled
                        opacity: visible ? 1 : 0

                        StyledText {
                            text: "Opacity: " + Math.round(SettingsData.desktopWeatherOpacity * 100) + "%"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceTextMedium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 32
                            value: Math.round(SettingsData.desktopWeatherOpacity * 100)
                            minimum: 10
                            maximum: 100
                            unit: "%"
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                SettingsData.setDesktopWeatherOpacity(newValue / 100)
                            }
                        }
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.mediumDuration
                            easing.type: Theme.emphasizedEasing
                        }
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.mediumDuration
                        easing.type: Theme.emphasizedEasing
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: generalSettingsSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1
                visible: SettingsData.desktopWidgetsEnabled
                opacity: visible ? 1 : 0

                Column {
                    id: generalSettingsSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "settings"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.spacingXS
                            width: parent.width - Theme.iconSize - Theme.spacingM

                            StyledText {
                                text: "General Settings"
                                font.pixelSize: Theme.fontSizeLarge
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                            }

                            StyledText {
                                text: "Default settings for all desktop widgets"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceTextMedium
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingXS

                        StyledText {
                            text: "Width: " + SettingsData.desktopWidgetWidth + "px"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceTextMedium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 32
                            value: SettingsData.desktopWidgetWidth
                            minimum: 100
                            maximum: 500
                            unit: "px"
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                SettingsData.setDesktopWidgetWidth(newValue)
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingXS

                        StyledText {
                            text: "Height: " + SettingsData.desktopWidgetHeight + "px"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceTextMedium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 32
                            value: SettingsData.desktopWidgetHeight
                            minimum: 50
                            maximum: 500
                            unit: "px"
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                SettingsData.setDesktopWidgetHeight(newValue)
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingXS

                        StyledText {
                            text: "Font Size: " + SettingsData.desktopWidgetFontSize + "px"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceTextMedium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 32
                            value: SettingsData.desktopWidgetFontSize
                            minimum: 8
                            maximum: 32
                            unit: "px"
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                SettingsData.setDesktopWidgetFontSize(newValue)
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingXS

                        StyledText {
                            text: "Icon Size: " + SettingsData.desktopWidgetIconSize + "px"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceTextMedium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 32
                            value: SettingsData.desktopWidgetIconSize
                            minimum: 12
                            maximum: 48
                            unit: "px"
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                SettingsData.setDesktopWidgetIconSize(newValue)
                            }
                        }
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.mediumDuration
                        easing.type: Theme.emphasizedEasing
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: gpuSelectionSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1
                visible: SettingsData.desktopWidgetsEnabled
                opacity: visible ? 1 : 0

                Column {
                    id: gpuSelectionSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "memory"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.spacingXS
                            width: parent.width - Theme.iconSize - Theme.spacingM

                            StyledText {
                                text: "GPU Selection"
                                font.pixelSize: Theme.fontSizeLarge
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                            }

                            StyledText {
                                text: "Select which GPU to monitor for temperature and usage"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceTextMedium
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        StyledText {
                            text: "GPU Temperature Source"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                            width: 200
                        }

                        Item {
                            width: Math.max(0, (parent.width - 200 - 200 - Theme.spacingM) / 2)
                            height: 1
                        }

                        DarkDropdown {
                            width: 200
                            height: 40
                            options: SettingsData.getGpuDropdownOptions()
                            currentValue: SettingsData.desktopGpuSelection
                            onValueChanged: {
                                SettingsData.setDesktopGpuSelection(value)
                            }
                        }

                        Item {
                            width: Math.max(0, (parent.width - 200 - 200 - Theme.spacingM) / 2)
                            height: 1
                        }
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.mediumDuration
                        easing.type: Theme.emphasizedEasing
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: usageInstructionsSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1
                visible: SettingsData.desktopWidgetsEnabled
                opacity: visible ? 1 : 0

                Column {
                    id: usageInstructionsSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "info"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.spacingXS
                            width: parent.width - Theme.iconSize - Theme.spacingM

                            StyledText {
                                text: "Usage Instructions"
                                font.pixelSize: Theme.fontSizeLarge
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                            }

                            StyledText {
                                text: "• Widgets are draggable - click and drag to move them around\n• Widgets automatically update their data in real-time\n• Right-click or middle-click to interact with widgets\n• Widgets respect your theme colors and settings"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceTextMedium
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.mediumDuration
                        easing.type: Theme.emphasizedEasing
                    }
                }
            }
        }
    }
}
