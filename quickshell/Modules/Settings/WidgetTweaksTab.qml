import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modals.FileBrowser

Item {
    id: widgetTweaksTab

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



            // Widget Transparency Section
            StyledRect {
                width: parent.width
                height: widgetTransparencySection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: widgetTransparencySection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "opacity"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Widget Background Transparency"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    DankSlider {
                        width: parent.width
                        height: 32
                        value: Math.round(SettingsData.topBarWidgetTransparency * 100)
                        minimum: 0
                        maximum: 100
                        unit: "%"
                        showValue: true
                        wheelEnabled: false
                        onSliderValueChanged: newValue => {
                                                  SettingsData.setTopBarWidgetTransparency(
                                                      newValue / 100)
                                              }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: workspaceSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: workspaceSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "view_module"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Workspace Settings"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    DankToggle {
                        width: parent.width
                        text: "Workspace Index Numbers"
                        description: "Show workspace index numbers in the top bar workspace switcher"
                        checked: SettingsData.showWorkspaceIndex
                        onToggled: checked => {
                                       return SettingsData.setShowWorkspaceIndex(
                                           checked)
                                   }
                    }

                    DankToggle {
                        width: parent.width
                        text: "Workspace Padding"
                        description: "Always show a minimum of 3 workspaces, even if fewer are available"
                        checked: SettingsData.showWorkspacePadding
                        onToggled: checked => {
                                       return SettingsData.setShowWorkspacePadding(
                                           checked)
                                   }
                    }

                    DankToggle {
                        width: parent.width
                        text: "Show Workspace Apps"
                        description: "Display application icons in workspace indicators"
                        checked: SettingsData.showWorkspaceApps
                        onToggled: checked => {
                                       return SettingsData.setShowWorkspaceApps(
                                           checked)
                                   }
                    }

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        Column {
                            width: 200
                            spacing: Theme.spacingS

                            StyledText {
                                text: "Maximum Workspaces"
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                            }

                            StyledText {
                                text: "Maximum number of workspaces to display (1-10)"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceTextMedium
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }

                        Column {
                            width: 100
                            spacing: Theme.spacingS

                            StyledText {
                                text: "Count"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                            }

                            DankTextField {
                                width: parent.width
                                text: SettingsData.maxWorkspaces.toString()
                                validator: IntValidator {
                                    bottom: 1
                                    top: 10
                                }
                                onTextChanged: {
                                    const value = parseInt(text)
                                    if (value >= 1 && value <= 10) {
                                        SettingsData.setMaxWorkspaces(value)
                                    }
                                }
                            }
                        }
                    }

		    Row {
                        width: parent.width - Theme.spacingL
                        spacing: Theme.spacingL
                        visible: SettingsData.showWorkspaceApps
                        opacity: visible ? 1 : 0
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.spacingL

                        Column {
                            width: 120
                            spacing: Theme.spacingS

                            StyledText {
                                text: "Max apps to show"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                            }

                            DankTextField {
                                width: 100
                                height: 28
                                placeholderText: "#ffffff"
                                text: SettingsData.maxWorkspaceIcons
                                maximumLength: 7
                                font.pixelSize: Theme.fontSizeSmall
                                topPadding: Theme.spacingXS
                                bottomPadding: Theme.spacingXS
                                onEditingFinished: {
                                    SettingsData.setMaxWorkspaceIcons(parseInt(text, 10))
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

                    DankToggle {
                        width: parent.width
                        text: "Per-Monitor Workspaces"
                        description: "Show only workspaces belonging to each specific monitor."
                        checked: SettingsData.workspacesPerMonitor
                        onToggled: checked => {
                            return SettingsData.setWorkspacesPerMonitor(checked);
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: mediaSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: mediaSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "music_note"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Media Player Settings"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    DankToggle {
                        width: parent.width
                        text: "Wave Progress Bars"
                        description: "Use animated wave progress bars for media playback"
                        checked: SettingsData.waveProgressEnabled
                        onToggled: checked => {
                            return SettingsData.setWaveProgressEnabled(checked)
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: runningAppsSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: runningAppsSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "apps"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Running Apps Settings"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    DankToggle {
                        width: parent.width
                        text: "Running Apps Only In Current Workspace"
                        description: "Show only apps running in current workspace"
                        checked: SettingsData.runningAppsCurrentWorkspace
                        onToggled: checked => {
                                       return SettingsData.setRunningAppsCurrentWorkspace(
                                           checked)
                                   }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: workspaceIconsSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1
                visible: SettingsData.hasNamedWorkspaces()

                Column {
                    id: workspaceIconsSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "label"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Named Workspace Icons"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    StyledText {
                        width: parent.width
                        text: "Configure icons for named workspaces. Icons take priority over numbers when both are enabled."
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.outline
                        wrapMode: Text.WordWrap
                    }

                    Repeater {
                        model: SettingsData.getNamedWorkspaces()

                        Rectangle {
                            width: parent.width
                            height: workspaceIconRow.implicitHeight + Theme.spacingM
                            radius: Theme.cornerRadius
                            color: Qt.rgba(Theme.surfaceContainer.r,
                                           Theme.surfaceContainer.g,
                                           Theme.surfaceContainer.b, 0.5)
                            border.color: Qt.rgba(Theme.outline.r,
                                                  Theme.outline.g,
                                                  Theme.outline.b, 0.3)
                            border.width: 1

                            Row {
                                id: workspaceIconRow

                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.leftMargin: Theme.spacingM
                                anchors.rightMargin: Theme.spacingM
                                spacing: Theme.spacingM

                                StyledText {
                                    text: "\"" + modelData + "\""
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 150
                                    elide: Text.ElideRight
                                }

                                DankIconPicker {
                                    id: iconPicker
                                    anchors.verticalCenter: parent.verticalCenter

                                    Component.onCompleted: {
                                        var iconData = SettingsData.getWorkspaceNameIcon(
                                                    modelData)
                                        if (iconData) {
                                            setIcon(iconData.value,
                                                    iconData.type)
                                        }
                                    }

                                    onIconSelected: (iconName, iconType) => {
                                                        SettingsData.setWorkspaceNameIcon(
                                                            modelData, {
                                                                "type": iconType,
                                                                "value": iconName
                                                            })
                                                        setIcon(iconName,
                                                                iconType)
                                                    }

                                    Connections {
                                        target: SettingsData
                                        function onWorkspaceIconsUpdated() {
                                            var iconData = SettingsData.getWorkspaceNameIcon(
                                                        modelData)
                                            if (iconData) {
                                                iconPicker.setIcon(
                                                            iconData.value,
                                                            iconData.type)
                                            } else {
                                                iconPicker.setIcon("", "icon")
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    width: 28
                                    height: 28
                                    radius: Theme.cornerRadius
                                    color: clearMouseArea.containsMouse ? Theme.errorHover : Theme.surfaceContainer
                                    border.color: clearMouseArea.containsMouse ? Theme.error : Theme.outline
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter

                                    DankIcon {
                                        name: "close"
                                        size: 16
                                        color: clearMouseArea.containsMouse ? Theme.error : Theme.outline
                                        anchors.centerIn: parent
                                    }

                                    MouseArea {
                                        id: clearMouseArea

                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            SettingsData.removeWorkspaceNameIcon(
                                                        modelData)
                                        }
                                    }
                                }

                                Item {
                                    width: parent.width - 150 - 240 - 28 - Theme.spacingM * 4
                                    height: 1
                                }
                            }
                        }
                    }
                }
            }

            // Desktop Widgets Section
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

                        DankIcon {
                            name: "widgets"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.spacingXS
                            width: parent.width - Theme.iconSize - Theme.spacingM

                            StyledText {
                                text: "Desktop Widgets"
                                font.pixelSize: Theme.fontSizeLarge
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                            }

                            StyledText {
                                text: "Floating desktop widgets for system monitoring"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceTextMedium
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }
                    }

                    // Master Toggle
                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        StyledText {
                            id: enableDesktopWidgetsText
                            text: "Enable Desktop Widgets"
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Item {
                            width: Math.max(0, parent.width - enableDesktopWidgetsText.implicitWidth - 60 - Theme.spacingM * 2)
                            height: 1
                        }

                        DankToggle {
                            id: enableDesktopWidgetsToggle
                            anchors.verticalCenter: parent.verticalCenter
                            checked: SettingsData.desktopWidgetsEnabled
                            onToggled: checked => {
                                SettingsData.setDesktopWidgetsEnabled(checked)
                            }
                        }
                    }

                    // Display selection is now handled in Settings → Displays tab

        // Individual Widget Controls
        Column {
            width: parent.width
            spacing: Theme.spacingM
            visible: SettingsData.desktopWidgetsEnabled

            StyledText {
                text: "Widget Controls"
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.surfaceText
                font.weight: Font.Medium
            }
        }

                    // Individual Widget Controls (only visible when master is enabled)
                    Column {
                        width: parent.width
                        spacing: Theme.spacingS
                        visible: SettingsData.desktopWidgetsEnabled

                        // CPU Temperature Widget
                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: "CPU Temperature"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                anchors.verticalCenter: parent.verticalCenter
                                width: 120
                            }

                            Item {
                                width: Math.max(0, (parent.width - 120 - 150 - 60 - Theme.spacingM * 3) / 2 + 20)
                                height: 1
                            }

                            DankDropdown {
                                width: 150
                                height: 40
                                options: [
                                    "top-left",
                                    "top-center", 
                                    "top-right",
                                    "middle-left",
                                    "middle-center",
                                    "middle-right",
                                    "bottom-left",
                                    "bottom-center",
                                    "bottom-right"
                                ]
                                currentValue: SettingsData.desktopCpuTempPosition
                                onValueChanged: {
                                    SettingsData.setDesktopCpuTempPosition(value)
                                }
                            }

                            Item {
                                width: Math.max(0, (parent.width - 120 - 150 - 60 - Theme.spacingM * 3) / 2 - 20)
                                height: 1
                            }

                            DankToggle {
                                anchors.verticalCenter: parent.verticalCenter
                                checked: SettingsData.desktopCpuTempEnabled
                                onToggled: checked => {
                                    SettingsData.setDesktopCpuTempEnabled(checked)
                                }
                            }
                        }

                        // GPU Temperature Widget
                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: "GPU Temperature"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                anchors.verticalCenter: parent.verticalCenter
                                width: 120
                            }

                            Item {
                                width: Math.max(0, (parent.width - 120 - 150 - 60 - Theme.spacingM * 3) / 2 + 20)
                                height: 1
                            }

                            DankDropdown {
                                width: 150
                                height: 40
                                options: [
                                    "top-left",
                                    "top-center", 
                                    "top-right",
                                    "middle-left",
                                    "middle-center",
                                    "middle-right",
                                    "bottom-left",
                                    "bottom-center",
                                    "bottom-right"
                                ]
                                currentValue: SettingsData.desktopGpuTempPosition
                                onValueChanged: {
                                    SettingsData.setDesktopGpuTempPosition(value)
                                }
                            }

                            Item {
                                width: Math.max(0, (parent.width - 120 - 150 - 60 - Theme.spacingM * 3) / 2 - 20)
                                height: 1
                            }

                            DankToggle {
                                anchors.verticalCenter: parent.verticalCenter
                                checked: SettingsData.desktopGpuTempEnabled
                                onToggled: checked => {
                                    SettingsData.setDesktopGpuTempEnabled(checked)
                                }
                            }
                        }

                        // System Monitor Widget
                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: "System Monitor"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                anchors.verticalCenter: parent.verticalCenter
                                width: 120
                            }

                            Item {
                                width: Math.max(0, (parent.width - 120 - 150 - 60 - Theme.spacingM * 3) / 2 + 20)
                                height: 1
                            }

                            DankDropdown {
                                width: 150
                                height: 40
                                options: [
                                    "top-left",
                                    "top-center", 
                                    "top-right",
                                    "middle-left",
                                    "middle-center",
                                    "middle-right",
                                    "bottom-left",
                                    "bottom-center",
                                    "bottom-right"
                                ]
                                currentValue: SettingsData.desktopSystemMonitorPosition
                                onValueChanged: {
                                    SettingsData.setDesktopSystemMonitorPosition(value)
                                }
                            }

                            Item {
                                width: Math.max(0, (parent.width - 120 - 150 - 60 - Theme.spacingM * 3) / 2 - 20)
                                height: 1
                            }

                            DankToggle {
                                anchors.verticalCenter: parent.verticalCenter
                                checked: SettingsData.desktopSystemMonitorEnabled
                                onToggled: checked => {
                                    SettingsData.setDesktopSystemMonitorEnabled(checked)
                                }
                            }
                        }

                        // Desktop Clock Widget
                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: "Desktop Clock"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                anchors.verticalCenter: parent.verticalCenter
                                width: 120
                            }

                            Item {
                                width: Math.max(0, (parent.width - 120 - 150 - 60 - Theme.spacingM * 3) / 2 + 20)
                                height: 1
                            }

                            DankDropdown {
                                width: 150
                                height: 40
                                options: [
                                    "top-left",
                                    "top-center", 
                                    "top-right",
                                    "middle-left",
                                    "middle-center",
                                    "middle-right",
                                    "bottom-left",
                                    "bottom-center",
                                    "bottom-right"
                                ]
                                currentValue: SettingsData.desktopClockPosition
                                onValueChanged: {
                                    SettingsData.setDesktopClockPosition(value)
                                }
                            }

                            Item {
                                width: Math.max(0, (parent.width - 120 - 150 - 60 - Theme.spacingM * 3) / 2 - 20)
                                height: 1
                            }

                            DankToggle {
                                anchors.verticalCenter: parent.verticalCenter
                                checked: SettingsData.desktopClockEnabled
                                onToggled: checked => {
                                    SettingsData.setDesktopClockEnabled(checked)
                                }
                            }
                        }

                        // Desktop Weather Widget
                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: "Desktop Weather"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                anchors.verticalCenter: parent.verticalCenter
                                width: 120
                            }

                            Item {
                                width: Math.max(0, (parent.width - 120 - 150 - 60 - Theme.spacingM * 3) / 2 + 20)
                                height: 1
                            }

                            DankDropdown {
                                width: 150
                                height: 40
                                options: [
                                    "top-left",
                                    "top-center", 
                                    "top-right",
                                    "middle-left",
                                    "middle-center",
                                    "middle-right",
                                    "bottom-left",
                                    "bottom-center",
                                    "bottom-right"
                                ]
                                currentValue: SettingsData.desktopWeatherPosition
                                onValueChanged: {
                                    SettingsData.setDesktopWeatherPosition(value)
                                }
                            }

                            Item {
                                width: Math.max(0, (parent.width - 120 - 150 - 60 - Theme.spacingM * 3) / 2 - 20)
                                height: 1
                            }

                            DankToggle {
                                anchors.verticalCenter: parent.verticalCenter
                                checked: SettingsData.desktopWeatherEnabled
                                onToggled: checked => {
                                    SettingsData.setDesktopWeatherEnabled(checked)
                                }
                            }
                        }

                        // Desktop Terminal Widget
                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: "Desktop Terminal"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                anchors.verticalCenter: parent.verticalCenter
                                width: 120
                            }

                            Item {
                                width: Math.max(0, (parent.width - 120 - 150 - 60 - Theme.spacingM * 3) / 2 + 20)
                                height: 1
                            }

                            DankDropdown {
                                width: 150
                                height: 40
                                options: [
                                    "top-left",
                                    "top-center", 
                                    "top-right",
                                    "middle-left",
                                    "middle-center",
                                    "middle-right",
                                    "bottom-left",
                                    "bottom-center",
                                    "bottom-right"
                                ]
                                currentValue: SettingsData.desktopTerminalPosition
                                onValueChanged: {
                                    SettingsData.setDesktopTerminalPosition(value)
                                }
                            }

                            Item {
                                width: Math.max(0, (parent.width - 120 - 150 - 60 - Theme.spacingM * 3) / 2 - 20)
                                height: 1
                            }

                            DankToggle {
                                anchors.verticalCenter: parent.verticalCenter
                                checked: SettingsData.desktopTerminalEnabled
                                onToggled: checked => {
                                    SettingsData.setDesktopTerminalEnabled(checked)
                                }
                            }
                        }
                        
                        // Clock Background Opacity
                        Row {
                            width: parent.width
                            spacing: Theme.spacingM
                            visible: SettingsData.desktopClockEnabled

                            StyledText {
                                text: "Background Opacity"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                anchors.verticalCenter: parent.verticalCenter
                                width: 120
                            }

                            Item {
                                width: Math.max(0, (parent.width - 120 - 200 - Theme.spacingM * 2) / 2)
                                height: 1
                            }

                            DankSlider {
                                width: 200
                                height: 32
                                value: SettingsData.desktopClockBackgroundOpacity * 100
                                minimum: 0
                                maximum: 100
                                showValue: true
                                wheelEnabled: false
                                onSliderValueChanged: newValue => {
                                    SettingsData.setDesktopClockBackgroundOpacity(newValue / 100)
                                }
                            }

                            Item {
                                width: Math.max(0, (parent.width - 120 - 200 - Theme.spacingM * 2) / 2)
                                height: 1
                            }
                        }
                    }
                }
            }

            // GPU Selection
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

                Column {
                    id: gpuSelectionSection
                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "memory"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "GPU Selection"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
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

                        DankDropdown {
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
            }

            // Desktop Widget Width
            StyledRect {
                width: parent.width
                height: desktopWidgetWidthSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1
                visible: SettingsData.desktopWidgetsEnabled

                Column {
                    id: desktopWidgetWidthSection
                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "width"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Desktop Widget Width"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    DankSlider {
                        width: parent.width
                        height: 32
                        value: SettingsData.desktopWidgetWidth
                        minimum: 1
                        maximum: 500
                        unit: "px"
                        showValue: true
                        wheelEnabled: false
                        onSliderValueChanged: newValue => {
                            SettingsData.setDesktopWidgetWidth(newValue)
                        }
                    }
                }
            }

            // Desktop Widget Height
            StyledRect {
                width: parent.width
                height: desktopWidgetHeightSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1
                visible: SettingsData.desktopWidgetsEnabled

                Column {
                    id: desktopWidgetHeightSection
                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "height"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Desktop Widget Height"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    DankSlider {
                        width: parent.width
                        height: 32
                        value: SettingsData.desktopWidgetHeight
                        minimum: 1
                        maximum: 500
                        unit: "px"
                        showValue: true
                        wheelEnabled: false
                        onSliderValueChanged: newValue => {
                            SettingsData.setDesktopWidgetHeight(newValue)
                        }
                    }
                }
            }

            // Desktop Widget Font Size
            StyledRect {
                width: parent.width
                height: desktopWidgetFontSizeSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1
                visible: SettingsData.desktopWidgetsEnabled

                Column {
                    id: desktopWidgetFontSizeSection
                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "text_fields"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Desktop Widget Font Size"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    DankSlider {
                        width: parent.width
                        height: 32
                        value: SettingsData.desktopWidgetFontSize
                        minimum: 1
                        maximum: 500
                        unit: "px"
                        showValue: true
                        wheelEnabled: false
                        onSliderValueChanged: newValue => {
                            SettingsData.setDesktopWidgetFontSize(newValue)
                        }
                    }
                }
            }

            // Desktop Widget Icon Size
            StyledRect {
                width: parent.width
                height: desktopWidgetIconSizeSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1
                visible: SettingsData.desktopWidgetsEnabled

                Column {
                    id: desktopWidgetIconSizeSection
                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "image"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Desktop Widget Icon Size"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    DankSlider {
                        width: parent.width
                        height: 32
                        value: SettingsData.desktopWidgetIconSize
                        minimum: 1
                        maximum: 500
                        unit: "px"
                        showValue: true
                        wheelEnabled: false
                        onSliderValueChanged: newValue => {
                            SettingsData.setDesktopWidgetIconSize(newValue)
                        }
                    }
                }
            }

            // System Monitor Widget Size
            StyledRect {
                width: parent.width
                height: systemMonitorSizeSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1
                visible: SettingsData.desktopSystemMonitorEnabled

                Column {
                    id: systemMonitorSizeSection
                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "aspect_ratio"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "System Monitor Widget Size"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    StyledText {
                        text: "Size: " + SettingsData.desktopSystemMonitorWidth + "x" + SettingsData.desktopSystemMonitorHeight
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceTextMedium
                    }

                    // Width slider
                    Column {
                        width: parent.width
                        spacing: Theme.spacingXS

                        StyledText {
                            text: "Width: " + SettingsData.desktopSystemMonitorWidth + "px"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceTextMedium
                        }

                        DankSlider {
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

                    // Height slider
                    Column {
                        width: parent.width
                        spacing: Theme.spacingXS

                        StyledText {
                            text: "Height: " + SettingsData.desktopSystemMonitorHeight + "px"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceTextMedium
                        }

                        DankSlider {
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
            }
        }
    }

}
