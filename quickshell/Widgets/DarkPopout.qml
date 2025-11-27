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
        property real calculatedX: {
            var baseX
            if (positioning === "center") {
                baseX = triggerX + (triggerWidth / 2) - (popupWidth / 2)
            } else if (positioning === "left") {
                baseX = triggerX
            } else if (positioning === "right") {
                baseX = triggerX + triggerWidth - popupWidth
            } else {
                baseX = triggerX
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
            
            return Math.max(Theme.spacingM, Math.min(screenWidth - popupWidth - Theme.spacingM, baseX + xOffset))
        }
        property real calculatedY: {
            var baseY = triggerY
            
            var yOffset = 0
            if (root.objectName === "appDrawerPopout") {
                yOffset = SettingsData.startMenuYOffset * (screenHeight - popupHeight) / 2
            } else if (root.objectName === "controlCenterPopout") {
                yOffset = SettingsData.controlCenterYOffset * (screenHeight - popupHeight) / 2
            } else if (root.objectName === "darkDashPopout") {
                if (triggerY > screenHeight * 0.5) {
                    baseY = triggerY - popupHeight + 30
                }
                yOffset = SettingsData.darkDashYOffset * (screenHeight - popupHeight) / 2
            } else if (root.objectName === "applicationsPopout") {
                if (triggerY > screenHeight * 0.5) {
                    baseY = triggerY - popupHeight + 30
                }
                yOffset = SettingsData.applicationsYOffset * (screenHeight - popupHeight) / 2
            }
            
            return Math.max(Theme.spacingM, Math.min(screenHeight - popupHeight - Theme.spacingM, baseY + yOffset))
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
