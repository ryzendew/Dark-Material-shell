import QtQuick
import Qt5Compat.GraphicalEffects
import qs.Common
import qs.Widgets

Rectangle {
    id: root

    property bool hasUnread: false
    property bool isActive: false
    property string section: "right"
    property var popupTarget: null
    property var parentScreen: null
    property real widgetHeight: 30
    property real barHeight: 48
    readonly property bool isBarVertical: SettingsData.topBarPosition === "left" || SettingsData.topBarPosition === "right"
    readonly property real horizontalPadding: SettingsData.topBarNoBackground ? 0 : Math.max(Theme.spacingXS, Theme.spacingS * (widgetHeight / 30))

    signal clicked()

    width: isBarVertical ? widgetHeight : (notificationIcon.width + horizontalPadding * 2)
    height: isBarVertical ? (notificationIcon.width + horizontalPadding * 2) : widgetHeight
    radius: SettingsData.topBarNoBackground ? 0 : Theme.cornerRadius
    color: {
        if (SettingsData.topBarNoBackground) {
            return "transparent";
        }

        const baseColor = notificationArea.containsMouse ? Theme.widgetBaseHoverColor : Theme.widgetBaseBackgroundColor;
        return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, baseColor.a * Theme.widgetTransparency);
    }

    DarkIcon {
        id: notificationIcon

        anchors.centerIn: parent
        name: SessionData.doNotDisturb ? "notifications_off" : "notifications"
        size: Theme.iconSize - 6
        color: SessionData.doNotDisturb ? Theme.error : (notificationArea.containsMouse || root.isActive ? Theme.primary : Theme.surfaceText)
        
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

    Rectangle {
        width: 8
        height: 8
        radius: 4
        color: Theme.error
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: SettingsData.topBarNoBackground ? 0 : 6
        anchors.topMargin: SettingsData.topBarNoBackground ? 0 : 6
        visible: root.hasUnread
    }

    MouseArea {
        id: notificationArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed: {
            if (popupTarget && popupTarget.setTriggerPosition) {
                const globalPos = mapToGlobal(0, 0);
                const currentScreen = parentScreen || Screen;
                const screenX = currentScreen.x || 0;
                const screenY = currentScreen.y || 0;
                const relativeX = globalPos.x - screenX;
                const relativeY = globalPos.y - screenY;
                
                let triggerX, triggerY;
                if (isBarVertical) {
                    if (SettingsData.topBarPosition === "left") {
                        triggerX = relativeX + width + Theme.spacingXS;
                        triggerY = relativeY;
                    } else {
                        triggerX = relativeX - Theme.spacingXS;
                        triggerY = relativeY;
                    }
                } else {
                    triggerX = relativeX;
                    if (SettingsData.topBarPosition === "top") {
                        triggerY = relativeY + height + Theme.spacingXS;
                    } else {
                        triggerY = relativeY - Theme.spacingXS;
                    }
                }
                
                popupTarget.setTriggerPosition(triggerX, triggerY, isBarVertical ? height : width, section, currentScreen);
            }
            root.clicked();
        }
    }


}
