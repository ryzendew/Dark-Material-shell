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

    function getApplicationsLoader() {
        let current = root
        while (current) {
            if (current.applicationsLoader) {
                return current.applicationsLoader
            }
            current = current.parent
        }
        return null
    }

    function openApplications() {
        const loader = getApplicationsLoader()
        if (loader) {
            loader.active = true
            if (loader.item) {
                const globalPos = appsMouseArea.mapToGlobal(0, 0)
                const currentScreen = parentScreen || Screen
                const screenX = currentScreen.x || 0
                const leftX = globalPos.x - screenX
                loader.item.setTriggerPosition(leftX, barHeight + Theme.spacingXS, width, "center", currentScreen)
                loader.item.show()
            }
        } else if (typeof applicationsLoader !== 'undefined') {
            applicationsLoader.active = true
            if (applicationsLoader.item) {
                const globalPos = appsMouseArea.mapToGlobal(0, 0)
                const currentScreen = parentScreen || Screen
                const screenX = currentScreen.x || 0
                const leftX = globalPos.x - screenX
                applicationsLoader.item.setTriggerPosition(leftX, barHeight + Theme.spacingXS, width, "center", currentScreen)
                applicationsLoader.item.show()
            }
        }
    }

    function toggleApplications() {
        const loader = getApplicationsLoader()
        if (loader) {
            loader.active = true
            if (loader.item) {
                if (loader.item.shouldBeVisible) {
                    loader.item.close()
                } else {
                    const globalPos = appsMouseArea.mapToGlobal(0, 0)
                    const currentScreen = parentScreen || Screen
                    const screenX = currentScreen.x || 0
                    const leftX = globalPos.x - screenX
                    loader.item.setTriggerPosition(leftX, barHeight + Theme.spacingXS, width, "center", currentScreen)
                    loader.item.show()
                }
            }
        } else if (typeof applicationsLoader !== 'undefined') {
            applicationsLoader.active = true
            if (applicationsLoader.item) {
                if (applicationsLoader.item.shouldBeVisible) {
                    applicationsLoader.item.close()
                } else {
                    const globalPos = appsMouseArea.mapToGlobal(0, 0)
                    const currentScreen = parentScreen || Screen
                    const screenX = currentScreen.x || 0
                    const leftX = globalPos.x - screenX
                    applicationsLoader.item.setTriggerPosition(leftX, barHeight + Theme.spacingXS, width, "center", currentScreen)
                    applicationsLoader.item.show()
                }
            }
        }
    }

    width: appsIcon.implicitWidth + horizontalPadding * 2
    height: widgetHeight
    radius: SettingsData.topBarNoBackground ? 0 : Theme.cornerRadius
    color: {
        if (SettingsData.topBarNoBackground) {
            return "transparent";
        }

        const baseColor = appsMouseArea.containsMouse ? Theme.widgetBaseHoverColor : Theme.widgetBaseBackgroundColor;
        return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, baseColor.a * Theme.widgetTransparency);
    }

    DarkIcon {
        id: appsIcon

        anchors.centerIn: parent
        name: "apps"
        size: Theme.iconSize - 6
        color: {
            const loader = root.getApplicationsLoader()
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
        id: appsMouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton
        onClicked: {
            root.toggleApplications()
        }
    }
}







