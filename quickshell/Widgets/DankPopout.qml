import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import qs.Common

PanelWindow {
    id: root

    WlrLayershell.namespace: "quickshell:popout"

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
        closeTimer.stop()
        shouldBeVisible = true
        visible = true
        opened()
    }

    function close() {
        shouldBeVisible = false
        closeTimer.restart()
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
            if (!shouldBeVisible) {
                visible = false
                popoutClosed()
            }
        }
    }

    color: "transparent"
    WlrLayershell.layer: WlrLayershell.Top // if set to overlay -> virtual keyboards can be stuck under popup
    WlrLayershell.exclusiveZone: -1

    // WlrLayershell.keyboardFocus should be set to Exclusive,
    // if popup contains input fields and does NOT create new popups/modals
    // with input fields.
    // With OnDemand virtual keyboards can't send input to popup
    // If set to Exclusive AND this popup creates other popups, that also have
    // input fields -> they can't get keyboard focus, because the parent popup
    // already took the lock
    WlrLayershell.keyboardFocus: shouldBeVisible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None 

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    MouseArea {
        anchors.fill: parent
        enabled: shouldBeVisible
        onClicked: mouse => {
                       var localPos = mapToItem(contentContainer, mouse.x, mouse.y)
                       if (localPos.x < 0 || localPos.x > contentContainer.width || localPos.y < 0 || localPos.y > contentContainer.height) {
                           backgroundClicked()
                           close()
                       }
                   }
    }

    Item {
        id: contentContainer

        readonly property real screenWidth: root.screen ? root.screen.width : 1920
        readonly property real screenHeight: root.screen ? root.screen.height : 1080
        readonly property real calculatedX: {
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
            
            // Apply offset based on popout type
            var xOffset = 0
            if (root.objectName === "appDrawerPopout") {
                xOffset = SettingsData.startMenuXOffset * (screenWidth - popupWidth) / 2
            } else if (root.objectName === "controlCenterPopout") {
                xOffset = SettingsData.controlCenterXOffset * (screenWidth - popupWidth) / 2
            }
            
            return Math.max(Theme.spacingM, Math.min(screenWidth - popupWidth - Theme.spacingM, baseX + xOffset))
        }
        readonly property real calculatedY: {
            var baseY = triggerY
            
            // Apply offset based on popout type
            var yOffset = 0
            if (root.objectName === "appDrawerPopout") {
                yOffset = SettingsData.startMenuYOffset * (screenHeight - popupHeight) / 2
            } else if (root.objectName === "controlCenterPopout") {
                yOffset = SettingsData.controlCenterYOffset * (screenHeight - popupHeight) / 2
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

        // Background with transparency
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, SettingsData.popupTransparency)
            radius: Theme.cornerRadius
            border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
            border.width: 1
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
