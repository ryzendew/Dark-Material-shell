import QtQuick
import QtQuick.Controls
import Quickshell.Widgets
import qs.Common
import qs.Widgets
import qs.Modules.Settings
import qs.Services

Item {
    id: dockTab

    Component.onCompleted: {
        // Ensure settings are properly loaded when the tab is created
        // console.log("DockTab loaded, dockGroupApps:", SettingsData.dockGroupApps)
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

            // Enable Dock
            StyledRect {
                width: parent.width
                height: enableDockSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: enableDockSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "dock_to_bottom"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingM
                                   - enableToggle.width - Theme.spacingM
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: "Show Dock"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Display a dock at the bottom of the screen with pinned and running applications"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }

                        DankToggle {
                            id: enableToggle

                            anchors.verticalCenter: parent.verticalCenter
                            checked: SettingsData.showDock
                            onToggled: checked => {
                                           SettingsData.setShowDock(checked)
                                       }
                        }
                    }
                }
            }

            // Tooltips Section
            StyledRect {
                width: parent.width
                height: tooltipsSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1
                visible: SettingsData.showDock
                opacity: visible ? 1 : 0

                Column {
                    id: tooltipsSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "info"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingM
                                   - tooltipsToggle.width - Theme.spacingM
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: "Show Tooltips"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Show application names and window titles when hovering over dock icons"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }

                        DankToggle {
                            id: tooltipsToggle

                            anchors.verticalCenter: parent.verticalCenter
                            checked: SettingsData.dockTooltipsEnabled
                            onToggled: checked => {
                                           SettingsData.setDockTooltipsEnabled(checked)
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

            // Group Apps
            StyledRect {
                width: parent.width
                height: groupAppsSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1
                visible: SettingsData.showDock
                opacity: visible ? 1 : 0

                Column {
                    id: groupAppsSection

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

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingM
                                   - groupAppsToggle.width - Theme.spacingM
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: "Group Apps"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Group multiple windows of the same application into a single dock entry"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }

                        DankToggle {
                            id: groupAppsToggle

                            anchors.verticalCenter: parent.verticalCenter
                            checked: SettingsData.dockGroupApps
                            
                            // Ensure the toggle updates when the setting changes
                            Binding {
                                target: groupAppsToggle
                                property: "checked"
                                value: SettingsData.dockGroupApps
                                when: SettingsData.dockGroupApps !== groupAppsToggle.checked
                            }
                            
                            onToggled: checked => {
                                           SettingsData.setDockGroupApps(checked)
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

            // Hide on Games Section
            StyledRect {
                width: parent.width
                height: hideOnGamesSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r,
                               Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1
                visible: SettingsData.showDock
                opacity: visible ? 1 : 0

                Column {
                    id: hideOnGamesSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "visibility_off"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingM
                                   - hideOnGamesToggle.width - Theme.spacingM
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: "Hide on Games/Apps"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Automatically hide the dock when games or fullscreen applications are running. Group multiple windows of the same application into a single dock entry"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }

                        DankToggle {
                            id: hideOnGamesToggle

                            anchors.verticalCenter: parent.verticalCenter
                            checked: SettingsData.dockHideOnGames
                            
                            // Ensure the toggle updates when the setting changes
                            Binding {
                                target: hideOnGamesToggle
                                property: "checked"
                                value: SettingsData.dockHideOnGames
                                when: SettingsData.dockHideOnGames !== hideOnGamesToggle.checked
                            }
                            
                            onToggled: checked => {
                                           SettingsData.setDockHideOnGames(checked)
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

            // Auto-hide Dock
            StyledRect {
                width: parent.width
                height: autoHideSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1
                visible: SettingsData.showDock
                opacity: visible ? 1 : 0

                Column {
                    id: autoHideSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "visibility_off"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingM
                                   - autoHideToggle.width - Theme.spacingM
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: "Auto-hide Dock"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Hide the dock when not in use and reveal it when hovering near the bottom of the screen"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }

                        DankToggle {
                            id: autoHideToggle

                            anchors.verticalCenter: parent.verticalCenter
                            checked: SettingsData.dockAutoHide
                            onToggled: checked => {
                                           SettingsData.setDockAutoHide(checked)
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

            // Expand to Screen Section
            StyledRect {
                width: parent.width
                height: expandToScreenSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1
                visible: SettingsData.showDock
                opacity: visible ? 1 : 0

                Column {
                    id: expandToScreenSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "fullscreen"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingM
                                   - expandToScreenToggle.width - Theme.spacingM
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: "Expand to Screen"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Expand the dock to full screen width, hiding the left and right widget areas"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }

                        DankToggle {
                            id: expandToScreenToggle

                            anchors.verticalCenter: parent.verticalCenter
                            checked: SettingsData.dockExpandToScreen
                            onToggled: checked => {
                                           SettingsData.setDockExpandToScreen(checked)
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

            // Center Apps Section
            StyledRect {
                width: parent.width
                height: centerAppsSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1
                visible: SettingsData.showDock
                opacity: visible ? 1 : 0

                Column {
                    id: centerAppsSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "center_focus_strong"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingM
                                   - centerAppsToggle.width - Theme.spacingM
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: "Center Apps"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Center the pinned and running apps in the middle of the screen"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }

                        DankToggle {
                            id: centerAppsToggle

                            anchors.verticalCenter: parent.verticalCenter
                            checked: SettingsData.dockCenterApps
                            onToggled: checked => {
                                           SettingsData.setDockCenterApps(checked)
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

            // Dock Transparency Section
            StyledRect {
                width: parent.width
                height: transparencySection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1
                visible: SettingsData.showDock
                opacity: visible ? 1 : 0

                Column {
                    id: transparencySection

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
                            text: "Dock Transparency"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    DankSlider {
                        width: parent.width
                        height: 32
                        value: Math.round(SettingsData.dockTransparency * 100)
                        minimum: 0
                        maximum: 100
                        unit: "%"
                        showValue: true
                        wheelEnabled: false
                        onSliderValueChanged: newValue => {
                                                  SettingsData.setDockTransparency(
                                                      newValue / 100)
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

            // Dock Bottom Gap Section
            StyledRect {
                width: parent.width
                height: bottomGapSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1
                visible: SettingsData.showDock
                opacity: visible ? 1 : 0

                Column {
                    id: bottomGapSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "vertical_align_bottom"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Dock Bottom Gap"
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
                            text: "Bottom Gap (0 = edge-to-edge)"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DankSlider {
                            width: parent.width
                            height: 24
                            value: SettingsData.dockBottomGap
                            minimum: 0
                            maximum: 64
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            thumbOutlineColor: Theme.surfaceContainer
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setDockBottomGap(
                                                          newValue)
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

            // Dock Icon Size and Spacing Section
            StyledRect {
                width: parent.width
                height: iconSettingsSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1
                visible: SettingsData.showDock
                opacity: visible ? 1 : 0

                Column {
                    id: iconSettingsSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "tune"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Icon Settings"
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
                            text: "Icon Size"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DankSlider {
                            width: parent.width
                            height: 24
                            value: SettingsData.dockIconSize
                            minimum: 24
                            maximum: 80
                            unit: "px"
                            showValue: true
                            wheelEnabled: false
                            thumbOutlineColor: Theme.surfaceContainer
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setDockIconSize(
                                                          newValue)
                                                  }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Icon Spacing"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DankSlider {
                            width: parent.width
                            height: 24
                            value: SettingsData.dockIconSpacing
                            minimum: 0
                            maximum: 20
                            unit: "px"
                            showValue: true
                            wheelEnabled: false
                            thumbOutlineColor: Theme.surfaceContainer
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setDockIconSpacing(
                                                          newValue)
                                                  }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Icon Drop Shadow Opacity"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DankSlider {
                            width: parent.width
                            height: 24
                            value: Math.round(SettingsData.dockIconDropShadowOpacity * 100)
                            minimum: 0
                            maximum: 100
                            unit: "%"
                            showValue: true
                            wheelEnabled: false
                            thumbOutlineColor: Theme.surfaceContainer
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setDockIconDropShadowOpacity(
                                                          newValue / 100)
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

            // Dock Exclusive Zone Section
            StyledRect {
                width: parent.width
                height: dockExclusiveZoneSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1
                visible: SettingsData.showDock
                opacity: visible ? 1 : 0

                Column {
                    id: dockExclusiveZoneSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "vertical_align_bottom"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Dock Exclusive Zone"
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
                            text: "Exclusive Zone (0 = no exclusive zone, -1 = always exclusive)"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DankSlider {
                            width: parent.width
                            height: 24
                            value: SettingsData.dockExclusiveZone
                            minimum: -1
                            maximum: 200
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            thumbOutlineColor: Theme.surfaceContainer
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setDockExclusiveZone(newValue)
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

            // Dock Padding Section
            StyledRect {
                width: parent.width
                height: dockPaddingSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1
                visible: SettingsData.showDock
                opacity: visible ? 1 : 0

                Column {
                    id: dockPaddingSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "padding"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Dock Padding"
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
                            text: "Left Padding"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DankSlider {
                            width: parent.width
                            height: 24
                            value: SettingsData.dockLeftPadding
                            minimum: 0
                            maximum: 100
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            thumbOutlineColor: Theme.surfaceContainer
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setDockLeftPadding(newValue)
                                                  }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Right Padding (Auto-synced with Left)"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DankSlider {
                            width: parent.width
                            height: 24
                            value: SettingsData.dockLeftPadding
                            minimum: 0
                            maximum: 100
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            thumbOutlineColor: Theme.surfaceContainer
                            enabled: false
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Top Padding"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DankSlider {
                            width: parent.width
                            height: 24
                            value: SettingsData.dockTopPadding
                            minimum: 0
                            maximum: 100
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            thumbOutlineColor: Theme.surfaceContainer
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setDockTopPadding(newValue)
                                                  }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Bottom Padding (Auto-synced with Top)"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DankSlider {
                            width: parent.width
                            height: 24
                            value: SettingsData.dockTopPadding
                            minimum: 0
                            maximum: 100
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            thumbOutlineColor: Theme.surfaceContainer
                            enabled: false
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

            // Dock Widgets Section
            Column {
                width: parent.width
                spacing: Theme.spacingL
                visible: SettingsData.showDock
                opacity: visible ? 1 : 0

                // Left Section
                StyledRect {
                    width: parent.width
                    height: leftSection.implicitHeight + Theme.spacingL * 2
                    radius: Theme.cornerRadius
                    color: Qt.rgba(Theme.surfaceVariant.r,
                                   Theme.surfaceVariant.g,
                                   Theme.surfaceVariant.b, 0.3)
                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                          Theme.outline.b, 0.2)
                    border.width: 1

                    WidgetsTabSection {
                        id: leftSection
                        anchors.fill: parent
                        anchors.margins: Theme.spacingL
                        title: "Left Side Widgets"
                        titleIcon: "format_align_left"
                        sectionId: "dockLeft"
                        items: dockTab.getItemsForSection("dockLeft")
                        allWidgets: dockTab.dockWidgetDefinitions

                        onItemEnabledChanged: (sectionId, itemId, enabled) => {
                                                  dockTab.handleItemEnabledChanged(sectionId, itemId, enabled)
                                              }
                        onItemOrderChanged: newOrder => {
                                                dockTab.handleItemOrderChanged("dockLeft", newOrder)
                                            }
                        onAddWidget: sectionId => {
                                         widgetSelectionPopup.allWidgets = dockTab.dockWidgetDefinitions
                                         widgetSelectionPopup.targetSection = sectionId
                                         widgetSelectionPopup.safeOpen()
                                     }
                        onRemoveWidget: (sectionId, widgetIndex) => {
                                            dockTab.removeWidgetFromSection(sectionId, widgetIndex)
                                        }
                        onSpacerSizeChanged: (sectionId, widgetIndex, newSize) => {
                                                 dockTab.handleSpacerSizeChanged(sectionId, widgetIndex, newSize)
                                             }
                    }
                }

                // Right Section
                StyledRect {
                    width: parent.width
                    height: rightSection.implicitHeight + Theme.spacingL * 2
                    radius: Theme.cornerRadius
                    color: Qt.rgba(Theme.surfaceVariant.r,
                                   Theme.surfaceVariant.g,
                                   Theme.surfaceVariant.b, 0.3)
                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                          Theme.outline.b, 0.2)
                    border.width: 1

                    WidgetsTabSection {
                        id: rightSection
                        anchors.fill: parent
                        anchors.margins: Theme.spacingL
                        title: "Right Side Widgets"
                        titleIcon: "format_align_right"
                        sectionId: "dockRight"
                        items: dockTab.getItemsForSection("dockRight")
                        allWidgets: dockTab.dockWidgetDefinitions

                        onItemEnabledChanged: (sectionId, itemId, enabled) => {
                                                  dockTab.handleItemEnabledChanged(sectionId, itemId, enabled)
                                              }
                        onItemOrderChanged: newOrder => {
                                                dockTab.handleItemOrderChanged("dockRight", newOrder)
                                            }
                        onAddWidget: sectionId => {
                                         widgetSelectionPopup.allWidgets = dockTab.dockWidgetDefinitions
                                         widgetSelectionPopup.targetSection = sectionId
                                         widgetSelectionPopup.safeOpen()
                                     }
                        onRemoveWidget: (sectionId, widgetIndex) => {
                                            dockTab.removeWidgetFromSection(sectionId, widgetIndex)
                                        }
                        onSpacerSizeChanged: (sectionId, widgetIndex, newSize) => {
                                                 dockTab.handleSpacerSizeChanged(sectionId, widgetIndex, newSize)
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

            // Dock Border Settings
            StyledRect {
                width: parent.width
                height: dockBorderSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: dockBorderSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "border_all"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Dock Border"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    DankToggle {
                        width: parent.width
                        text: "Enable Border"
                        description: "Add a customizable border around the dock"
                        checked: SettingsData.dockBorderEnabled
                        onToggled: checked => {
                                       SettingsData.setDockBorderEnabled(checked)
                                   }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS
                        visible: SettingsData.dockBorderEnabled
                        opacity: visible ? 1 : 0

                        StyledText {
                            text: "Border Width"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DankSlider {
                            width: parent.width
                            height: 24
                            value: SettingsData.dockBorderWidth
                            minimum: 1
                            maximum: 20
                            unit: "px"
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setDockBorderWidth(newValue)
                                                  }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS
                        visible: SettingsData.dockBorderEnabled
                        opacity: visible ? 1 : 0

                        StyledText {
                            text: "Border Radius"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DankSlider {
                            width: parent.width
                            height: 24
                            value: SettingsData.dockBorderRadius
                            minimum: 0
                            maximum: 50
                            unit: "px"
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setDockBorderRadius(newValue)
                                                  }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS
                        visible: SettingsData.dockBorderEnabled
                        opacity: visible ? 1 : 0

                        StyledText {
                            text: "Border Color"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacingS

                            Column {
                                width: (parent.width - Theme.spacingS * 3) / 4
                                spacing: Theme.spacingS

                                StyledText {
                                    text: "Red"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                }

                                DankSlider {
                                    width: parent.width
                                    height: 24
                                    value: Math.round(SettingsData.dockBorderRed * 255)
                                    minimum: 0
                                    maximum: 255
                                    unit: ""
                                    showValue: true
                                    wheelEnabled: false
                                    onSliderValueChanged: newValue => {
                                                              SettingsData.setDockBorderRed(newValue / 255)
                                                          }
                                }
                            }

                            Column {
                                width: (parent.width - Theme.spacingS * 3) / 4
                                spacing: Theme.spacingS

                                StyledText {
                                    text: "Green"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                }

                                DankSlider {
                                    width: parent.width
                                    height: 24
                                    value: Math.round(SettingsData.dockBorderGreen * 255)
                                    minimum: 0
                                    maximum: 255
                                    unit: ""
                                    showValue: true
                                    wheelEnabled: false
                                    onSliderValueChanged: newValue => {
                                                              SettingsData.setDockBorderGreen(newValue / 255)
                                                          }
                                }
                            }

                            Column {
                                width: (parent.width - Theme.spacingS * 3) / 4
                                spacing: Theme.spacingS

                                StyledText {
                                    text: "Blue"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                }

                                DankSlider {
                                    width: parent.width
                                    height: 24
                                    value: Math.round(SettingsData.dockBorderBlue * 255)
                                    minimum: 0
                                    maximum: 255
                                    unit: ""
                                    showValue: true
                                    wheelEnabled: false
                                    onSliderValueChanged: newValue => {
                                                              SettingsData.setDockBorderBlue(newValue / 255)
                                                          }
                                }
                            }

                            Column {
                                width: (parent.width - Theme.spacingS * 3) / 4
                                spacing: Theme.spacingS

                                StyledText {
                                    text: "Alpha"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                }

                                DankSlider {
                                    width: parent.width
                                    height: 24
                                    value: Math.round(SettingsData.dockBorderAlpha * 100)
                                    minimum: 0
                                    maximum: 100
                                    unit: "%"
                                    showValue: true
                                    wheelEnabled: false
                                    onSliderValueChanged: newValue => {
                                                              SettingsData.setDockBorderAlpha(newValue / 100)
                                                          }
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

    // Use the same widget definitions as topbar
    property var dockWidgetDefinitions: [{
            "id": "launcherButton",
            "text": "App Launcher",
            "description": "Quick access to application launcher",
            "icon": "apps",
            "enabled": true
        }, {
            "id": "workspaceSwitcher",
            "text": "Workspace Switcher",
            "description": "Shows current workspace and allows switching",
            "icon": "view_module",
            "enabled": true
        }, {
            "id": "focusedWindow",
            "text": "Focused Window",
            "description": "Display currently focused application title",
            "icon": "window",
            "enabled": true
        }, {
            "id": "runningApps",
            "text": "Running Apps",
            "description": "Shows all running applications with focus indication",
            "icon": "apps",
            "enabled": true
        }, {
            "id": "clock",
            "text": "Clock",
            "description": "Current time and date display",
            "icon": "schedule",
            "enabled": true
        }, {
            "id": "weather",
            "text": "Weather Widget",
            "description": "Current weather conditions and temperature",
            "icon": "wb_sunny",
            "enabled": true
        }, {
            "id": "music",
            "text": "Media Controls",
            "description": "Control currently playing media",
            "icon": "music_note",
            "enabled": true
        }, {
            "id": "clipboard",
            "text": "Clipboard Manager",
            "description": "Access clipboard history",
            "icon": "content_paste",
            "enabled": true
        }, {
            "id": "cpuUsage",
            "text": "CPU Usage",
            "description": "CPU usage indicator",
            "icon": "memory",
            "enabled": DgopService.dgopAvailable,
            "warning": !DgopService.dgopAvailable ? "Requires 'dgop' tool" : undefined
        }, {
            "id": "memUsage",
            "text": "Memory Usage",
            "description": "Memory usage indicator",
            "icon": "storage",
            "enabled": DgopService.dgopAvailable,
            "warning": !DgopService.dgopAvailable ? "Requires 'dgop' tool" : undefined
        }, {
            "id": "cpuTemp",
            "text": "CPU Temperature",
            "description": "CPU temperature display",
            "icon": "device_thermostat",
            "enabled": DgopService.dgopAvailable,
            "warning": !DgopService.dgopAvailable ? "Requires 'dgop' tool" : undefined
        }, {
            "id": "gpuTemp",
            "text": "GPU Temperature",
            "description": "GPU temperature display",
            "icon": "auto_awesome_mosaic",
            "warning": !DgopService.dgopAvailable ? "Requires 'dgop' tool" : "This widget prevents GPU power off states, which can significantly impact battery life on laptops. It is not recommended to use this on laptops with hybrid graphics.",
            "enabled": DgopService.dgopAvailable
        }, {
            "id": "systemTray",
            "text": "System Tray",
            "description": "System notification area icons",
            "icon": "notifications",
            "enabled": true
        }, {
            "id": "privacyIndicator",
            "text": "Privacy Indicator",
            "description": "Shows when microphone, camera, or screen sharing is active",
            "icon": "privacy_tip",
            "enabled": true
        }, {
            "id": "controlCenterButton",
            "text": "Control Center",
            "description": "Access to system controls and settings",
            "icon": "settings",
            "enabled": true
        }, {
            "id": "notificationButton",
            "text": "Notification Center",
            "description": "Access to notifications and do not disturb",
            "icon": "notifications",
            "enabled": true
        }, {
            "id": "battery",
            "text": "Battery",
            "description": "Battery level and power management",
            "icon": "battery_std",
            "enabled": true
        }, {
            "id": "vpn",
            "text": "VPN",
            "description": "VPN status and quick connect",
            "icon": "vpn_lock",
            "enabled": true
        }, {
            "id": "idleInhibitor",
            "text": "Idle Inhibitor",
            "description": "Prevent screen timeout",
            "icon": "motion_sensor_active",
            "enabled": true
        }, {
            "id": "spacer",
            "text": "Spacer",
            "description": "Customizable empty space",
            "icon": "more_horiz",
            "enabled": true
        }, {
            "id": "separator",
            "text": "Separator",
            "description": "Visual divider between widgets",
            "icon": "remove",
            "enabled": true
        }, {
            "id": "network_speed_monitor",
            "text": "Network Speed Monitor",
            "description": "Network download and upload speed display",
            "icon": "network_check",
            "warning": !DgopService.dgopAvailable ? "Requires 'dgop' tool" : undefined,
            "enabled": DgopService.dgopAvailable
        }, {
            "id": "keyboard_layout_name",
            "text": "Keyboard Layout Name",
            "description": "Displays the active keyboard layout and allows switching",
            "icon": "keyboard",
            "enabled": true
        }, {
            "id": "notepadButton",
            "text": "Notepad",
            "description": "Quick access to notepad",
            "icon": "assignment",
            "enabled": true
        }, {
            "id": "colorPicker",
            "text": "Color Picker",
            "description": "Quick access to color picker",
            "icon": "palette",
            "enabled": true
        }, {
            "id": "systemUpdate",
            "text": "System Update",
            "description": "Check for system updates",
            "icon": "update",
            "enabled": SystemUpdateService.distributionSupported
        }, {
            "id": "settingsButton",
            "text": "Settings Button",
            "description": "Quick access to settings modal",
            "icon": "settings",
            "enabled": true
        }]

    function addWidgetToSection(widgetId, targetSection) {
        var widgetObj = {
            "id": widgetId,
            "enabled": true
        }
        if (widgetId === "spacer")
            widgetObj.size = 20

        var widgets = []
        if (targetSection === "dockLeft") {
            widgets = SettingsData.dockLeftWidgets.slice()
            widgets.push(widgetObj)
            SettingsData.setDockLeftWidgets(widgets)
        } else if (targetSection === "dockRight") {
            widgets = SettingsData.dockRightWidgets.slice()
            widgets.push(widgetObj)
            SettingsData.setDockRightWidgets(widgets)
        }
    }

    function removeWidgetFromSection(sectionId, widgetIndex) {
        var widgets = []
        if (sectionId === "dockLeft") {
            widgets = SettingsData.dockLeftWidgets.slice()
            if (widgetIndex >= 0 && widgetIndex < widgets.length) {
                widgets.splice(widgetIndex, 1)
                SettingsData.setDockLeftWidgets(widgets)
            }
        } else if (sectionId === "dockRight") {
            widgets = SettingsData.dockRightWidgets.slice()
            if (widgetIndex >= 0 && widgetIndex < widgets.length) {
                widgets.splice(widgetIndex, 1)
                SettingsData.setDockRightWidgets(widgets)
            }
        }
    }

    function handleItemEnabledChanged(sectionId, itemId, enabled) {
        var widgets = []
        if (sectionId === "dockLeft")
            widgets = SettingsData.dockLeftWidgets.slice()
        else if (sectionId === "dockRight")
            widgets = SettingsData.dockRightWidgets.slice()
        
        for (var i = 0; i < widgets.length; i++) {
            var widget = widgets[i]
            var widgetId = typeof widget === "string" ? widget : widget.id
            if (widgetId === itemId) {
                if (typeof widget === "string") {
                    widgets[i] = {
                        "id": widget,
                        "enabled": enabled
                    }
                } else {
                    var newWidget = {
                        "id": widget.id,
                        "enabled": enabled
                    }
                    if (widget.size !== undefined)
                        newWidget.size = widget.size
                    widgets[i] = newWidget
                }
                break
            }
        }
        
        if (sectionId === "dockLeft")
            SettingsData.setDockLeftWidgets(widgets)
        else if (sectionId === "dockRight")
            SettingsData.setDockRightWidgets(widgets)
    }

    function handleItemOrderChanged(sectionId, newOrder) {
        if (sectionId === "dockLeft")
            SettingsData.setDockLeftWidgets(newOrder)
        else if (sectionId === "dockRight")
            SettingsData.setDockRightWidgets(newOrder)
    }

    function handleSpacerSizeChanged(sectionId, widgetIndex, newSize) {
        var widgets = []
        if (sectionId === "dockLeft")
            widgets = SettingsData.dockLeftWidgets.slice()
        else if (sectionId === "dockRight")
            widgets = SettingsData.dockRightWidgets.slice()
        
        if (widgetIndex >= 0 && widgetIndex < widgets.length) {
            var widget = widgets[widgetIndex]
            var widgetId = typeof widget === "string" ? widget : widget.id
            if (widgetId === "spacer") {
                if (typeof widget === "string") {
                    widgets[widgetIndex] = {
                        "id": widget,
                        "enabled": true,
                        "size": newSize
                    }
                } else {
                    var newWidget = {
                        "id": widget.id,
                        "enabled": widget.enabled,
                        "size": newSize
                    }
                    widgets[widgetIndex] = newWidget
                }
            }
        }
        
        if (sectionId === "dockLeft")
            SettingsData.setDockLeftWidgets(widgets)
        else if (sectionId === "dockRight")
            SettingsData.setDockRightWidgets(widgets)
    }

    function getItemsForSection(sectionId) {
        var widgets = []
        var widgetData = []
        if (sectionId === "dockLeft")
            widgetData = SettingsData.dockLeftWidgets || []
        else if (sectionId === "dockRight")
            widgetData = SettingsData.dockRightWidgets || []
        
        widgetData.forEach(widget => {
            var widgetId = typeof widget === "string" ? widget : widget.id
            var widgetDef = dockWidgetDefinitions.find(def => def.id === widgetId)
            if (widgetDef) {
                var item = {
                    "id": widgetId,
                    "text": widgetDef.text,
                    "description": widgetDef.description,
                    "icon": widgetDef.icon,
                    "enabled": typeof widget === "string" ? true : widget.enabled
                }
                if (widgetId === "spacer" && widget.size !== undefined)
                    item.size = widget.size
                widgets.push(item)
            }
        })
        
        return widgets
    }

    // Widget Selection Popup
    WidgetSelectionPopup {
        id: widgetSelectionPopup
        
        onWidgetSelected: (widgetId, targetSection) => {
                             dockTab.addWidgetToSection(widgetId, targetSection)
                         }
    }
}
