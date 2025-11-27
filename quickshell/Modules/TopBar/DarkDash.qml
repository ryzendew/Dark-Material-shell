import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import qs.Common
import qs.Widgets

Rectangle {
    id: root

    property string section: "center"
    property var parentScreen: null
    property real barHeight: 48
    property real widgetHeight: 30
    readonly property real horizontalPadding: SettingsData.topBarNoBackground ? 2 : Theme.spacingS

    function getDarkDashLoader() {
        let current = root
        while (current) {
            if (current.darkDashLoader) {
                return current.darkDashLoader
            }
            current = current.parent
        }
        return null
    }

    function openDarkDash() {
        const loader = getDarkDashLoader()
        if (loader) {
            loader.active = true
            if (loader.item) {
                const globalPos = dashMouseArea.mapToGlobal(0, 0)
                const currentScreen = parentScreen || Screen
                const screenX = currentScreen.x || 0
                const leftX = globalPos.x - screenX
                loader.item.setTriggerPosition(leftX, barHeight + Theme.spacingXS, width, "center", currentScreen)
                loader.item.show()
            }
        } else if (typeof darkDashLoader !== 'undefined') {
            darkDashLoader.active = true
            if (darkDashLoader.item) {
                const globalPos = dashMouseArea.mapToGlobal(0, 0)
                const currentScreen = parentScreen || Screen
                const screenX = currentScreen.x || 0
                const leftX = globalPos.x - screenX
                darkDashLoader.item.setTriggerPosition(leftX, barHeight + Theme.spacingXS, width, "center", currentScreen)
                darkDashLoader.item.show()
            }
        }
    }

    function toggleDarkDash() {
        const loader = getDarkDashLoader()
        if (loader) {
            loader.active = true
            if (loader.item) {
                if (loader.item.shouldBeVisible) {
                    loader.item.close()
                } else {
                    const globalPos = dashMouseArea.mapToGlobal(0, 0)
                    const currentScreen = parentScreen || Screen
                    const screenX = currentScreen.x || 0
                    const leftX = globalPos.x - screenX
                    loader.item.setTriggerPosition(leftX, barHeight + Theme.spacingXS, width, "center", currentScreen)
                    loader.item.show()
                }
            }
        } else if (typeof darkDashLoader !== 'undefined') {
            darkDashLoader.active = true
            if (darkDashLoader.item) {
                if (darkDashLoader.item.shouldBeVisible) {
                    darkDashLoader.item.close()
                } else {
                    const globalPos = dashMouseArea.mapToGlobal(0, 0)
                    const currentScreen = parentScreen || Screen
                    const screenX = currentScreen.x || 0
                    const leftX = globalPos.x - screenX
                    darkDashLoader.item.setTriggerPosition(leftX, barHeight + Theme.spacingXS, width, "center", currentScreen)
                    darkDashLoader.item.show()
                }
            }
        }
    }

    width: dashIcon.implicitWidth + horizontalPadding * 2
    height: widgetHeight
    radius: SettingsData.topBarNoBackground ? 0 : Theme.cornerRadius
    color: {
        if (SettingsData.topBarNoBackground) {
            return "transparent";
        }

        const baseColor = dashMouseArea.containsMouse ? Theme.widgetBaseHoverColor : Theme.widgetBaseBackgroundColor;
        return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, baseColor.a * Theme.widgetTransparency);
    }

    DarkIcon {
        id: dashIcon

        anchors.centerIn: parent
        name: "dashboard"
        size: Theme.iconSize - 6
        color: {
            const loader = root.getDarkDashLoader()
            const isVisible = loader && loader.item && loader.item.shouldBeVisible
            return isVisible ? Theme.primary : Theme.surfaceText
        }
        
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 1
            radius: 4
            samples: 16
            color: Qt.rgba(0, 0, 0, SettingsData.topBarDropShadowOpacity)
            transparentBorder: true
        }
    }

    MouseArea {
        id: dashMouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton
        onEntered: {
            hoverTimer.start()
        }
        onExited: {
            hoverTimer.stop()
        }
        onClicked: {
            hoverTimer.stop()
            root.toggleDarkDash()
        }
    }

    Timer {
        id: hoverTimer
        interval: 2000
        onTriggered: {
            root.openDarkDash()
        }
    }
}

