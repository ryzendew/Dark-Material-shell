import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Services.Mpris
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

    Component.onCompleted: {
    }

    Connections {
        target: SettingsData
        function onDockTransparencyChanged() {
            dock.backgroundTransparency = SettingsData.dockTransparency
        }
    }

    Connections {
        target: Theme
        function onColorUpdateTriggerChanged() {
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

        height: dock.reveal ? (65 + SettingsData.dockTopPadding + SettingsData.dockBottomPadding) : SettingsData.dockCollapsedHeight
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        
        x: SettingsData.dockExpandToScreen ? 0 : leftWidgetArea.width + 8
        width: SettingsData.dockExpandToScreen ? parent.width : parent.width - leftWidgetArea.width - 8
        hoverEnabled: true
        acceptedButtons: Qt.NoButton // Don't intercept any button clicks
        propagateComposedEvents: true // Allow events to propagate to child components
        preventStealing: false // Allow child MouseAreas to steal events
        
        onPressed: mouse.accepted = false
        onReleased: mouse.accepted = false
        onClicked: mouse.accepted = false

        Behavior on height {
            NumberAnimation {
                duration: SettingsData.dockAnimationDuration
                easing.type: Easing.OutCubic
            }
        }

        Item {
            id: dockContainer
            anchors.fill: parent

            transform: Translate {
                id: dockSlide
                y: dock.reveal ? 0 : SettingsData.dockSlideDistance

                Behavior on y {
                    NumberAnimation {
                        duration: SettingsData.dockAnimationDuration
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
                    if (SettingsData.dockExpandToScreen) {
                        return parent.width - 16 // 8px margin on each side
                    } else {
                        const appsWidth = dockApps.implicitWidth || 0
                        const leftWidgetAreaWidth = leftWidgetArea.width || 0
                        const rightWidgetAreaWidth = rightWidgetArea.width || 0
                        const spacing = 8 + 8 + 8 + 8 // Left widget area margin + main container margins + right widget area margin
                        const padding = 12
                        const totalPadding = SettingsData.dockLeftPadding * 2 // Left + Right padding (both use same value)
                        return appsWidth + leftWidgetAreaWidth + rightWidgetAreaWidth + spacing + padding + totalPadding
                    }
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
                        return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, SettingsData.dockBackgroundTintOpacity)
                    }
                    radius: parent.radius
                }

                Rectangle {
                    id: leftWidgetArea
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    height: parent.height - 8
                    width: SettingsData.dockWidgetsEnabled ? Math.max(SettingsData.dockLeftWidgetAreaMinWidth, leftWidgets.implicitWidth + 16) : 0
                    radius: Theme.cornerRadius
                    color: {
                        const baseColor = Theme.surfaceContainer
                        return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, SettingsData.dockWidgetAreaOpacity)
                    }
                    border.width: 1
                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                    z: 10 // Ensure it's on top
                    visible: !SettingsData.dockExpandToScreen && SettingsData.dockWidgetsEnabled // Hide when expanding to screen or widgets disabled
                    
                    Behavior on width {
                        NumberAnimation {
                            duration: SettingsData.dockAnimationDuration
                            easing.type: Easing.OutCubic
                        }
                    }
                    
                    Connections {
                        target: SettingsData
                        function onWidgetDataChanged() {
                            Qt.callLater(() => {
                                leftWidgets.visible = false
                                Qt.callLater(() => {
                                    leftWidgets.visible = true
                                })
                            })
                        }
                    }
                    
                    Connections {
                        target: MprisController
                        function onActivePlayerChanged() {
                            if (MprisController.activePlayer === null) {
                                Qt.callLater(() => {
                                    leftWidgets.visible = false
                                    Qt.callLater(() => {
                                        leftWidgets.visible = true
                                    })
                                })
                            }
                        }
                    }

                    DockWidgets {
                        id: leftWidgets
                        anchors.centerIn: parent
                        height: parent.height - 8
                        widgetList: SettingsData.dockLeftWidgetsModel
                        side: "left"
                        z: 11 // Ensure widgets are on top
                        
                        Component.onCompleted: {
                        }
                    }
                }


                Rectangle {
                    id: rightWidgetArea
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    height: parent.height - 8
                    width: SettingsData.dockWidgetsEnabled ? Math.max(SettingsData.dockRightWidgetAreaMinWidth, rightWidgets.implicitWidth + 16) : 0
                    radius: Theme.cornerRadius
                    color: {
                        const baseColor = Theme.surfaceContainer
                        return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, SettingsData.dockWidgetAreaOpacity)
                    }
                    border.width: 1
                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                    visible: !SettingsData.dockExpandToScreen && SettingsData.dockWidgetsEnabled // Hide when expanding to screen or widgets disabled
                    
                    Behavior on width {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }
                    
                    Connections {
                        target: SettingsData
                        function onWidgetDataChanged() {
                            Qt.callLater(() => {
                                rightWidgets.visible = false
                                Qt.callLater(() => {
                                    rightWidgets.visible = true
                                })
                            })
                        }
                    }
                    
                    Connections {
                        target: MprisController
                        function onActivePlayerChanged() {
                            if (MprisController.activePlayer === null) {
                                Qt.callLater(() => {
                                    rightWidgets.visible = false
                                    Qt.callLater(() => {
                                        rightWidgets.visible = true
                                    })
                                })
                            }
                        }
                    }

                    DockWidgets {
                        id: rightWidgets
                        anchors.centerIn: parent
                        height: parent.height - 8
                        widgetList: SettingsData.dockRightWidgetsModel
                        side: "right"
                        
                        Component.onCompleted: {
                        }
                    }
                }

                Item {
                    id: mainDockContainer
                    anchors.left: SettingsData.dockExpandToScreen ? parent.left : leftWidgetArea.right
                    anchors.leftMargin: SettingsData.dockExpandToScreen ? 8 : 12
                    anchors.right: SettingsData.dockExpandToScreen ? parent.right : parent.right
                    anchors.rightMargin: SettingsData.dockExpandToScreen ? 8 : 8
                    anchors.top: parent.top
                    anchors.topMargin: 4 + SettingsData.dockTopPadding
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 4 + SettingsData.dockTopPadding
                    
                    clip: false
                    z: 5 // Lower than left widget area (z: 10)

                    Item {
                        anchors.fill: parent

                        DockApps {
                            id: dockApps
                            anchors.left: SettingsData.dockCenterApps ? undefined : (SettingsData.dockExpandToScreen ? expandedLeftWidgets.right : parent.left)
                            anchors.leftMargin: SettingsData.dockExpandToScreen ? 4 : (SettingsData.dockLeftPadding > 0 ? SettingsData.dockLeftPadding : 4)
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: SettingsData.dockCenterApps ? parent.horizontalCenter : undefined
                            height: parent.height
                            contextMenu: dock.contextMenu
                            
                            clip: false
                            z: 1 // Lower than left widget area
                        }

                        Rectangle {
                            anchors.left: dockApps.right
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            width: 1
                            height: parent.height * 0.6
                            color: Theme.outline
                            opacity: 0.3
                            visible: !SettingsData.dockCenterApps && SettingsData.dockWidgetsEnabled
                        }



                        DockWidgets {
                            id: expandedLeftWidgets
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            height: parent.height - 8
                            widgetList: SettingsData.dockLeftWidgetsModel
                            side: "left"
                            visible: SettingsData.dockExpandToScreen && SettingsData.dockWidgetsEnabled
                            z: 2
                        }

                        Rectangle {
                            anchors.left: expandedLeftWidgets.right
                            anchors.leftMargin: 4
                            anchors.verticalCenter: parent.verticalCenter
                            width: 1
                            height: parent.height * 0.6
                            color: Theme.outline
                            opacity: 0.3
                            visible: SettingsData.dockExpandToScreen && SettingsData.dockWidgetsEnabled
                        }

                        DockWidgets {
                            id: expandedRightWidgets
                            anchors.right: parent.right
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            height: parent.height - 8
                            widgetList: SettingsData.dockRightWidgetsModel
                            side: "right"
                            visible: SettingsData.dockExpandToScreen && SettingsData.dockWidgetsEnabled
                            z: 2
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
                
                minimizedWindow: null
                visible: minimizedWindow !== null
                
                y: -height - 16
                x: hoveredButton ? hoveredButton.mapToItem(dockContainer, hoveredButton.width / 2, 0).x - width / 2 : 0
            }
        }
    }
}
