import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import qs.Common
import qs.Services
import qs.Widgets

Rectangle {
    id: root

    property bool showPercentage: true
    property bool showIcon: true
    property var toggleProcessList
    property string section: "right"
    property var popupTarget: null
    property var parentScreen: null
    property real barHeight: 48
    property real widgetHeight: 30
    readonly property bool isBarVertical: SettingsData.topBarPosition === "left" || SettingsData.topBarPosition === "right"
    readonly property real horizontalPadding: SettingsData.topBarNoBackground ? 0 : Math.max(Theme.spacingXS, Theme.spacingS * (widgetHeight / 30))

    width: isBarVertical ? widgetHeight : (ramContent.implicitWidth + horizontalPadding * 2)
    height: isBarVertical ? (ramContent.implicitHeight + horizontalPadding * 2) : widgetHeight
    radius: SettingsData.topBarNoBackground ? 0 : Theme.cornerRadius
    color: {
        if (SettingsData.topBarNoBackground) {
            return "transparent";
        }

        const baseColor = ramArea.containsMouse ? Theme.widgetBaseHoverColor : Theme.widgetBaseBackgroundColor;
        return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, baseColor.a * Theme.widgetTransparency);
    }
    Component.onCompleted: {
        DgopService.addRef(["memory"]);
    }
    Component.onDestruction: {
        DgopService.removeRef(["memory"]);
    }

    MouseArea {
        id: ramArea

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
            DgopService.setSortBy("memory");
            if (root.toggleProcessList) {
                root.toggleProcessList();
            }

        }
    }

    Row {
        id: ramContent

        anchors.centerIn: parent
        spacing: 3

        DarkIcon {
            name: "developer_board"
            size: Theme.iconSize - 8
            color: {
                if (DgopService.memoryUsage > 90) {
                    return Theme.tempDanger;
                }

                if (DgopService.memoryUsage > 75) {
                    return Theme.tempWarning;
                }

                return Theme.surfaceText;
            }
            anchors.verticalCenter: parent.verticalCenter
            
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

        StyledText {
            text: {
                if (DgopService.memoryUsage === undefined || DgopService.memoryUsage === null || DgopService.memoryUsage === 0) {
                    return "--%";
                }

                return DgopService.memoryUsage.toFixed(0) + "%";
            }
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Font.Medium
            color: Theme.surfaceText
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignLeft
            elide: Text.ElideNone
            
            layer.enabled: true
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 1
                radius: 4
                samples: 16
                color: Qt.rgba(0, 0, 0, SettingsData.topBarDropShadowOpacity)
                transparentBorder: true
            }

            StyledTextMetrics {
                id: ramBaseline
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Medium
                text: "100%"
            }

            width: Math.max(ramBaseline.width, paintedWidth)

            Behavior on width {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }
        }

    }

}
