import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import qs.Common

PanelWindow {
    id: root

    WlrLayershell.namespace: (root.objectName === "darkDashPopout" || root.objectName === "applicationsPopout") ? "quickshell:dock:blur" : "quickshell:popout"

    property alias content: contentLoader.sourceComponent
    property alias contentLoader: contentLoader
    property real popupWidth: 400
    property real popupHeight: 300
    property real triggerX: 0
    property real triggerY: 0
    property real triggerWidth: 40
    property string positioning: "center"
    property int animationDuration: Theme.mediumDuration
    property var animationEasing: Theme.emphasizedEasing
    property bool shouldBeVisible: false
    
    readonly property bool isBarVertical: typeof SettingsData !== "undefined" && (SettingsData.topBarPosition === "left" || SettingsData.topBarPosition === "right")
    readonly property bool isBarAtBottom: typeof SettingsData !== "undefined" && SettingsData.topBarPosition === "bottom"

    signal opened
    signal popoutClosed
    signal backgroundClicked

    function open() {
        console.warn("[DarkPopout] open() called")
        console.warn("[DarkPopout] Stopping closeTimer")
        closeTimer.stop()
        console.warn("[DarkPopout] Setting shouldBeVisible to true")
        shouldBeVisible = true
        console.warn("[DarkPopout] Setting visible to true")
        visible = true
        console.warn("[DarkPopout] Emitting opened signal")
        opened()
        console.warn("[DarkPopout] open() completed - shouldBeVisible:", shouldBeVisible, "visible:", visible)
    }

    function close() {
        console.warn("[DarkPopout] close() called")
        console.warn("[DarkPopout] Setting shouldBeVisible to false")
        shouldBeVisible = false
        console.warn("[DarkPopout] Restarting closeTimer")
        closeTimer.restart()
        console.warn("[DarkPopout] close() completed - shouldBeVisible:", shouldBeVisible, "visible:", visible)
    }

    function toggle() {
        if (shouldBeVisible)
            close()
        else
            open()
    }

    Timer {
        id: closeTimer
        interval: animationDuration + 50
        onTriggered: {
            console.warn("[DarkPopout] closeTimer triggered, shouldBeVisible:", shouldBeVisible)
            if (!shouldBeVisible) {
                console.warn("[DarkPopout] Setting visible to false")
                visible = false
                console.warn("[DarkPopout] Emitting popoutClosed signal")
                popoutClosed()
            } else {
                console.warn("[DarkPopout] Timer triggered but shouldBeVisible is true, not closing")
            }
        }
    }

    color: "transparent"
    WlrLayershell.layer: WlrLayershell.Top
    WlrLayershell.exclusiveZone: shouldBeVisible ? -1 : 0

    WlrLayershell.keyboardFocus: shouldBeVisible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None 

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    visible: shouldBeVisible

    MouseArea {
        anchors.fill: parent
        enabled: shouldBeVisible && visible
        z: shouldBeVisible ? -1 : -2
        propagateComposedEvents: true
        onClicked: mouse => {
                       if (!shouldBeVisible) {
                           mouse.accepted = false
                           return
                       }
                       var localPos = mapToItem(contentContainer, mouse.x, mouse.y)
                       if (localPos.x < 0 || localPos.x > contentContainer.width || localPos.y < 0 || localPos.y > contentContainer.height) {
                           backgroundClicked()
                           close()
                           mouse.accepted = true
                       } else {
                           mouse.accepted = false
                       }
                   }
    }

    Item {
        id: contentContainer
        z: 10

        readonly property real screenWidth: root.screen ? root.screen.width : 1920
        readonly property real screenHeight: root.screen ? root.screen.height : 1080
        readonly property real barExclusiveSize: typeof SettingsData !== "undefined" && SettingsData.topBarVisible && !SettingsData.topBarFloat ? (SettingsData.topBarHeight + SettingsData.topBarSpacing + (SettingsData.topBarGothCornersEnabled ? Theme.cornerRadius : 0)) : 0
        
        property real calculatedX: {
            var positionSetting = ""
            if (root.objectName === "appDrawerPopout") {
                positionSetting = SettingsData.appDrawerPosition
            } else if (root.objectName === "controlCenterPopout") {
                positionSetting = SettingsData.controlCenterPosition
            }
            
            var baseX
            if (positionSetting === "follow-trigger" || positionSetting === "") {
                if (positioning === "center") {
                    baseX = triggerX + (triggerWidth / 2) - (popupWidth / 2)
                } else if (positioning === "left") {
                    baseX = triggerX
                } else if (positioning === "right") {
                    baseX = triggerX + triggerWidth - popupWidth
                } else {
                    baseX = triggerX
                }
            } else {
                if (positionSetting.includes("left")) {
                    baseX = Theme.spacingL
                } else if (positionSetting.includes("right")) {
                    baseX = screenWidth - popupWidth - Theme.spacingL
                } else {
                    baseX = (screenWidth - popupWidth) / 2
                }
            }
            
            var xOffset = 0
            if (root.objectName === "appDrawerPopout") {
                xOffset = SettingsData.startMenuXOffset * (screenWidth - popupWidth) / 2
            } else if (root.objectName === "controlCenterPopout") {
                xOffset = SettingsData.controlCenterXOffset * (screenWidth - popupWidth) / 2
            } else if (root.objectName === "darkDashPopout") {
                xOffset = SettingsData.darkDashXOffset * (screenWidth - popupWidth) / 2
            } else if (root.objectName === "applicationsPopout") {
                xOffset = SettingsData.applicationsXOffset * (screenWidth - popupWidth) / 2
            }
            
            var minX = Theme.spacingM
            var maxX = screenWidth - popupWidth - Theme.spacingM
            
            if (typeof SettingsData !== "undefined") {
                if (SettingsData.topBarPosition === "left" && !SettingsData.topBarFloat) {
                    minX = barExclusiveSize + Theme.spacingM
                } else if (SettingsData.topBarPosition === "right" && !SettingsData.topBarFloat) {
                    maxX = screenWidth - popupWidth - barExclusiveSize - Theme.spacingM
                }
            }
            
            return Math.max(minX, Math.min(maxX, baseX + xOffset))
        }
        property real calculatedY: {
            var _ = triggerY
            var __ = triggerScreen
            
            var actualScreenHeight = triggerScreen ? triggerScreen.height : (root.screen ? root.screen.height : screenHeight)
            
            var positionSetting = ""
            if (root.objectName === "appDrawerPopout") {
                positionSetting = SettingsData.appDrawerPosition
            } else if (root.objectName === "controlCenterPopout") {
                positionSetting = SettingsData.controlCenterPosition
            }
            
            var baseY
            var yOffset = 0
            
            if (positionSetting === "follow-trigger" || positionSetting === "") {
                if (triggerY === 0 && triggerScreen === null) {
                    return Theme.spacingM
                }
                
                var barPosition = typeof SettingsData !== "undefined" ? SettingsData.topBarPosition : "top"
                
                if (root.objectName === "appDrawerPopout" || root.objectName === "controlCenterPopout") {
                    if (barPosition === "bottom" && !isBarVertical) {
                        baseY = triggerY - popupHeight - Theme.spacingS
                    } else if (barPosition === "top" && !isBarVertical) {
                        baseY = triggerY + Theme.spacingS
                    } else {
                        baseY = triggerY
                    }
                    
                    if (root.objectName === "appDrawerPopout") {
                        yOffset = SettingsData.startMenuYOffset * (actualScreenHeight - popupHeight) / 2
                    } else {
                        yOffset = SettingsData.controlCenterYOffset * (actualScreenHeight - popupHeight) / 2
                    }
                } else if (root.objectName === "darkDashPopout") {
                    if (shouldPositionAbove) {
                        baseY = triggerY - popupHeight + 30
                    } else {
                        baseY = triggerY + Theme.spacingS
                    }
                    yOffset = SettingsData.darkDashYOffset * (actualScreenHeight - popupHeight) / 2
                } else if (root.objectName === "applicationsPopout") {
                    if (shouldPositionAbove) {
                        baseY = triggerY - popupHeight + 30
                    } else {
                        baseY = triggerY + Theme.spacingS
                    }
                    yOffset = SettingsData.applicationsYOffset * (actualScreenHeight - popupHeight) / 2
                }
            } else {
                if (positionSetting.includes("top")) {
                    baseY = Theme.spacingL
                    if (typeof SettingsData !== "undefined" && SettingsData.topBarPosition === "top" && !SettingsData.topBarFloat && SettingsData.topBarVisible) {
                        var topBarSize = SettingsData.topBarHeight + SettingsData.topBarSpacing + (SettingsData.topBarGothCornersEnabled ? Theme.cornerRadius : 0)
                        baseY = topBarSize + Theme.spacingL
                    }
                } else if (positionSetting.includes("bottom")) {
                    baseY = actualScreenHeight - popupHeight - Theme.spacingL
                    if (typeof SettingsData !== "undefined" && SettingsData.topBarPosition === "bottom" && !SettingsData.topBarFloat && SettingsData.topBarVisible) {
                        var bottomBarSize = SettingsData.topBarHeight + SettingsData.topBarSpacing + (SettingsData.topBarGothCornersEnabled ? Theme.cornerRadius : 0)
                        baseY = actualScreenHeight - popupHeight - bottomBarSize - Theme.spacingL
                    }
                } else {
                    baseY = (actualScreenHeight - popupHeight) / 2
                }
                
                if (root.objectName === "appDrawerPopout") {
                    yOffset = SettingsData.startMenuYOffset * (actualScreenHeight - popupHeight) / 2
                } else if (root.objectName === "controlCenterPopout") {
                    yOffset = SettingsData.controlCenterYOffset * (actualScreenHeight - popupHeight) / 2
                }
            }
            
            var finalY = baseY + yOffset
            
            var minY = Theme.spacingM
            var maxY = actualScreenHeight - popupHeight - Theme.spacingM
            
            if (typeof SettingsData !== "undefined" && SettingsData.topBarPosition === "bottom" && !SettingsData.topBarFloat && SettingsData.topBarVisible) {
                var bottomBarExclusiveSize = SettingsData.topBarHeight + SettingsData.topBarSpacing + (SettingsData.topBarGothCornersEnabled ? Theme.cornerRadius : 0)
                maxY = actualScreenHeight - popupHeight - bottomBarExclusiveSize - Theme.spacingM
                
                if ((root.objectName === "appDrawerPopout" || root.objectName === "controlCenterPopout") && finalY > maxY) {
                    finalY = maxY
                }
            }
            
            if (typeof SettingsData !== "undefined" && SettingsData.topBarPosition === "top" && !SettingsData.topBarFloat && SettingsData.topBarVisible) {
                var topBarExclusiveSize = SettingsData.topBarHeight + SettingsData.topBarSpacing + (SettingsData.topBarGothCornersEnabled ? Theme.cornerRadius : 0)
                minY = topBarExclusiveSize + Theme.spacingM
            }
            
            var clampedY = Math.max(minY, Math.min(maxY, finalY))
            
            return clampedY
        }

        width: popupWidth
        height: popupHeight
        x: calculatedX
        y: calculatedY
        opacity: shouldBeVisible ? 1 : 0
        scale: shouldBeVisible ? 1 : 0.9

        Behavior on opacity {
            NumberAnimation {
                duration: animationDuration
                easing.type: animationEasing
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: animationDuration
                easing.type: animationEasing
            }
        }

        Rectangle {
            id: backgroundRect
            anchors.fill: parent
            color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, root.objectName === "darkDashPopout" ? SettingsData.darkDashTransparency : SettingsData.popupTransparency)
            radius: Theme.cornerRadius
            border.color: root.objectName === "darkDashPopout" && SettingsData.darkDashBorderThickness > 0 ? Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, SettingsData.darkDashBorderOpacity) : (root.objectName === "darkDashPopout" ? "transparent" : Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2))
            border.width: root.objectName === "darkDashPopout" ? SettingsData.darkDashBorderThickness : 1

            layer.enabled: root.objectName === "darkDashPopout" && SettingsData.darkDashDropShadowOpacity > 0
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 4
                radius: 12
                samples: 24
                color: Qt.rgba(0, 0, 0, SettingsData.darkDashDropShadowOpacity)
                transparentBorder: true
            }
        }

        Loader {
            id: contentLoader
            anchors.fill: parent
            active: root.visible
            asynchronous: false
        }

        Item {
            anchors.fill: parent
            focus: true
            Keys.onPressed: event => {
                                if (event.key === Qt.Key_Escape) {
                                    close()
                                    event.accepted = true
                                }
                            }
            Component.onCompleted: forceActiveFocus()
            onVisibleChanged: if (visible)
                                  forceActiveFocus()
        }
    }
}
