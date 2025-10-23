import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Common
import qs.Services
import qs.Widgets

PanelWindow {
    id: dock

    WlrLayershell.namespace: "quickshell:dock:blur"

    WlrLayershell.layer: WlrLayershell.Top
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    property var modelData
    property var contextMenu
    property bool autoHide: SettingsData.dockAutoHide
    property real backgroundTransparency: SettingsData.dockTransparency
    
    // Use global minimized window manager

    property bool contextMenuOpen: (contextMenu && contextMenu.visible && contextMenu.screen === modelData)
    property bool windowIsFullscreen: {
        if (!SettingsData.dockHideOnGames || !ToplevelManager.activeToplevel) {
            return false
        }
        const activeWindow = ToplevelManager.activeToplevel
        const fullscreenApps = ["vlc", "mpv", "kodi", "steam", "lutris", "wine", "dosbox"]
        return fullscreenApps.some(app => activeWindow.appId && activeWindow.appId.toLowerCase().includes(app))
    }
    property bool reveal: (!autoHide || dockMouseArea.containsMouse || dockApps.requestDockShow || contextMenuOpen) && !windowIsFullscreen

    Connections {
        target: SettingsData
        function onDockTransparencyChanged() {
            dock.backgroundTransparency = SettingsData.dockTransparency
        }
    }

    // Theme change detection for debugging
    Connections {
        target: Theme
        function onColorUpdateTriggerChanged() {
            console.log("Dock: Theme color update triggered")
            console.log("Dock: Current theme:", Theme.currentTheme)
            console.log("Dock: Surface container color:", Theme.surfaceContainer)
        }
    }

    screen: modelData
    visible: SettingsData.showDock
    color: "transparent"

    anchors {
        bottom: true
        left: true
        right: true
    }

    margins {
        left: 0
        right: 0
        bottom: SettingsData.dockBottomGap
    }

    implicitHeight: 100
    exclusiveZone: autoHide ? -1 : SettingsData.dockExclusiveZone + SettingsData.dockBottomGap + (SettingsData.dockTopPadding * 2)

    mask: Region {
        item: dockMouseArea
    }

    MouseArea {
        id: dockMouseArea
        property real currentScreen: modelData ? modelData : dock.screen
        property real screenWidth: currentScreen ? currentScreen.geometry.width : 1920
        property real maxDockWidth: Math.min(screenWidth * 0.8, 1200)

        height: dock.reveal ? (65 + SettingsData.dockTopPadding + SettingsData.dockBottomPadding) : 20
        width: dock.reveal ? Math.min(dockBackground.width + 32, maxDockWidth) : Math.min(Math.max(dockBackground.width + 64, 200), screenWidth * 0.5)
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        hoverEnabled: true

        Behavior on height {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        Item {
            id: dockContainer
            anchors.fill: parent

            transform: Translate {
                id: dockSlide
                y: dock.reveal ? 0 : 60

                Behavior on y {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }
            }

            Rectangle {
                id: dockBackground
                objectName: "dockBackground"
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                }

                width: {
                    const appsWidth = dockApps.implicitWidth || 0
                    const leftWidth = leftWidgets.implicitWidth || 0
                    const rightWidth = rightWidgets.implicitWidth || 0
                    const settingsWidth = 40
                    const separatorWidth = 1
                    const spacing = 8 + 8 // Left margin for separator + right margin for settings
                    const padding = 12
                    const totalPadding = SettingsData.dockLeftPadding * 2 // Left + Right padding (both use same value)
                    return appsWidth + leftWidth + rightWidth + settingsWidth + separatorWidth + spacing + padding + totalPadding
                }

                height: parent.height - 8 + (SettingsData.dockTopPadding * 2)

                anchors.topMargin: 4
                anchors.bottomMargin: 1

                color: {
                    var baseColor = Theme.surfaceContainer
                    return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, backgroundTransparency)
                }
                radius: SettingsData.dockBorderEnabled ? SettingsData.dockBorderRadius : Theme.cornerRadius
                border.width: SettingsData.dockBorderEnabled ? SettingsData.dockBorderWidth : 1
                border.color: SettingsData.dockBorderEnabled ? Qt.rgba(SettingsData.dockBorderRed, SettingsData.dockBorderGreen, SettingsData.dockBorderBlue, SettingsData.dockBorderAlpha) : Theme.outlineMedium
                layer.enabled: true

                Rectangle {
                    anchors.fill: parent
                    color: {
                        var baseColor = Theme.surfaceTint
                        return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, 0.04)
                    }
                    radius: parent.radius
                }

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 8 + SettingsData.dockLeftPadding
                    anchors.rightMargin: 4 + SettingsData.dockLeftPadding
                    anchors.topMargin: 4 + SettingsData.dockTopPadding
                    anchors.bottomMargin: 4 + SettingsData.dockTopPadding
                    spacing: 8

                    // Left Widgets
                    DockWidgets {
                        id: leftWidgets
                        width: Math.max(0, implicitWidth)
                        height: parent.height
                        widgetList: SettingsData.dockLeftWidgets
                        side: "left"
                    }

                    // Dock Apps (Center)
                    DockApps {
                        id: dockApps
                        width: implicitWidth
                        height: parent.height
                        contextMenu: dock.contextMenu
                    }

                    // Right Widgets
                    DockWidgets {
                        id: rightWidgets
                        width: Math.max(0, implicitWidth)
                        height: parent.height
                        widgetList: SettingsData.dockRightWidgets
                        side: "right"
                    }

                    // Separator with spacing
                    Rectangle {
                        width: 1
                        height: parent.height * 0.6
                        color: Theme.outline
                        opacity: 0.3
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 8
                    }

                    // Settings Button with spacing
                    Rectangle {
                        width: 40
                        height: parent.height
                        radius: Theme.cornerRadius
                        color: settingsArea.containsMouse ? Theme.widgetBaseHoverColor : "transparent"
                        anchors.rightMargin: 8
                        
                        MouseArea {
                            id: settingsArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                // Open settings modal
                                settingsModal.show()
                            }
                        }

                        DankIcon {
                            anchors.centerIn: parent
                            name: "settings"
                            size: Theme.iconSize
                            color: Theme.surfaceText
                        }
                    }
                }
            }

            Rectangle {
                id: appTooltip

                property var hoveredButton: {
                    if (!dockApps.children[0]) {
                        return null
                    }
                    const row = dockApps.children[0]
                    let repeater = null
                    for (var i = 0; i < row.children.length; i++) {
                        const child = row.children[i]
                        if (child && typeof child.count !== "undefined" && typeof child.itemAt === "function") {
                            repeater = child
                            break
                        }
                    }
                    if (!repeater || !repeater.itemAt) {
                        return null
                    }
                    for (var i = 0; i < repeater.count; i++) {
                        const item = repeater.itemAt(i)
                        if (item && item.dockButton && item.dockButton.showTooltip) {
                            return item.dockButton
                        }
                    }
                    return null
                }

                property string tooltipText: hoveredButton ? hoveredButton.tooltipText : ""

                visible: SettingsData.dockTooltipsEnabled && hoveredButton !== null && tooltipText !== ""
                width: tooltipLabel.implicitWidth + 24
                height: tooltipLabel.implicitHeight + 12

                color: Theme.surfaceContainer
                radius: Theme.cornerRadius
                border.width: 1
                border.color: Theme.outlineMedium

                y: -height - 8
                x: hoveredButton ? hoveredButton.mapToItem(dockContainer, hoveredButton.width / 2, 0).x - width / 2 : 0

                StyledText {
                    id: tooltipLabel
                    anchors.centerIn: parent
                    text: appTooltip.tooltipText
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceText
                }
            }
            
            // Minimized window preview
            DockMinimizedPreview {
                id: minimizedPreview
                
                property var hoveredButton: {
                    if (!dockApps.children[0]) {
                        return null
                    }
                    const row = dockApps.children[0]
                    let repeater = null
                    for (var i = 0; i < row.children.length; i++) {
                        const child = row.children[i]
                        if (child && typeof child.count !== "undefined" && typeof child.itemAt === "function") {
                            repeater = child
                            break
                        }
                    }
                    if (!repeater || !repeater.itemAt) {
                        return null
                    }
                    for (var i = 0; i < repeater.count; i++) {
                        const item = repeater.itemAt(i)
                        if (item && item.dockButton && item.dockButton.isHovered && item.dockButton.isMinimized) {
                            return item.dockButton
                        }
                    }
                    return null
                }
                
                minimizedWindow: hoveredButton ? globalMinimizedWindowManager.getMinimizedWindow(hoveredButton.getToplevelObject()) : null
                visible: minimizedWindow !== null
                
                y: -height - 16
                x: hoveredButton ? hoveredButton.mapToItem(dockContainer, hoveredButton.width / 2, 0).x - width / 2 : 0
            }
        }
    }
}
