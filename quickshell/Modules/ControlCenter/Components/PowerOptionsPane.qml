import QtQuick
import Qt5Compat.GraphicalEffects
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: root

    property bool expanded: false

    signal powerActionRequested(string action, string title, string message)

    implicitHeight: expanded ? 60 : 0
    height: implicitHeight
    clip: true

    Rectangle {
        width: parent.width
        height: 60
        radius: Theme.cornerRadius
        color: Qt.rgba(Theme.surfaceVariant.r,
                       Theme.surfaceVariant.g,
                       Theme.surfaceVariant.b,
                       Theme.getContentBackgroundAlpha() * SettingsData.controlCenterWidgetBackgroundOpacity)
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                              Theme.outline.b, 0.08)
        border.width: root.expanded ? 1 : 0
        opacity: root.expanded ? 1 : 0
        clip: true

        // Drop shadow
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 2
            radius: 8
            samples: 16
            color: Qt.rgba(0, 0, 0, SettingsData.controlCenterDropShadowOpacity)
            transparentBorder: true
        }

        Row {
            anchors.centerIn: parent
            spacing: SessionService.hibernateSupported ? Theme.spacingS : Theme.spacingL
            visible: root.expanded

            PowerButton {
                width: SessionService.hibernateSupported ? 85 : 100
                iconName: "logout"
                text: "Logout"
                onPressed: root.powerActionRequested("logout", "Logout", "Are you sure you want to logout?")
            }

            PowerButton {
                width: SessionService.hibernateSupported ? 85 : 100
                iconName: "restart_alt"
                text: "Restart"
                onPressed: root.powerActionRequested("reboot", "Restart", "Are you sure you want to restart?")
            }

            PowerButton {
                width: SessionService.hibernateSupported ? 85 : 100
                iconName: "bedtime"
                text: "Suspend"
                onPressed: root.powerActionRequested("suspend", "Suspend", "Are you sure you want to suspend?")
            }

            PowerButton {
                width: SessionService.hibernateSupported ? 85 : 100
                iconName: "ac_unit"
                text: "Hibernate"
                visible: SessionService.hibernateSupported
                onPressed: root.powerActionRequested("hibernate", "Hibernate", "Are you sure you want to hibernate?")
            }

            PowerButton {
                width: SessionService.hibernateSupported ? 85 : 100
                iconName: "power_settings_new"
                text: "Shutdown"
                onPressed: root.powerActionRequested("poweroff", "Shutdown", "Are you sure you want to shutdown?")
            }
        }
    }
}