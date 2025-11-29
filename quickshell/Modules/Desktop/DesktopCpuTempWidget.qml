import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services
import qs.Widgets

PanelWindow {
    id: root

    property var modelData: null
    property var screen: modelData
    property real widgetWidth: SettingsData.desktopWidgetWidth
    property real widgetHeight: SettingsData.desktopWidgetHeight
    property bool alwaysVisible: true
    property string position: "top-left"
    property var positioningBox: null

    implicitWidth: widgetWidth
    implicitHeight: widgetHeight
    visible: alwaysVisible

    WlrLayershell.layer: WlrLayershell.Background
    WlrLayershell.namespace: "quickshell:dock:blur"
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    color: "transparent"


    anchors {
        left: position.includes("left") ? true : false
        right: position.includes("right") ? true : false
        top: position.includes("top") ? true : false
        bottom: position.includes("bottom") ? true : false
    }

    readonly property bool isBarVertical: SettingsData.topBarPosition === "left" || SettingsData.topBarPosition === "right"
    readonly property real barExclusiveSize: SettingsData.topBarVisible && !SettingsData.topBarFloat ? (SettingsData.topBarHeight + SettingsData.topBarSpacing + (SettingsData.topBarGothCornersEnabled ? Theme.cornerRadius : 0)) : 0
    
    margins {
        left: {
            var base = position.includes("left") ? 20 : 0
            if (SettingsData.topBarPosition === "left" && !SettingsData.topBarFloat) {
                return base + barExclusiveSize
            }
            return base
        }
        right: {
            var base = position.includes("right") ? 20 : 0
            if (SettingsData.topBarPosition === "right" && !SettingsData.topBarFloat) {
                return base + barExclusiveSize
            }
            return base
        }
        top: {
            var base = position.includes("top") ? (SettingsData.topBarHeight + SettingsData.topBarSpacing + SettingsData.topBarBottomGap + 20) : 0
            if (SettingsData.topBarPosition === "top" && !SettingsData.topBarFloat) {
                return base
            }
            return position.includes("top") ? 20 : 0
        }
        bottom: {
            var base = position.includes("bottom") ? (SettingsData.dockExclusiveZone + SettingsData.dockBottomGap + 20) : 0
            if (SettingsData.topBarPosition === "bottom" && !SettingsData.topBarFloat) {
                return base + barExclusiveSize
            }
            return base
        }
    }

    Component.onCompleted: {
        DgopService.addRef(["cpu"]);
    }
    
    Component.onDestruction: {
        DgopService.removeRef(["cpu"]);
    }

    Rectangle {
        width: widgetWidth
        height: widgetHeight
        radius: Theme.cornerRadius
        color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.9)
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.3)
        border.width: 1

        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 4
            radius: 12
            samples: 16
            color: Qt.rgba(0, 0, 0, 0.3)
            transparentBorder: true
        }

        Row {
            anchors.centerIn: parent
            spacing: Theme.spacingS

            DarkIcon {
                name: "memory"
                size: SettingsData.desktopWidgetIconSize
                color: {
                    if (DgopService.cpuTemperature > 85) {
                        return Theme.tempDanger;
                    }
                    if (DgopService.cpuTemperature > 69) {
                        return Theme.tempWarning;
                    }
                    return Theme.surfaceText;
                }
                anchors.verticalCenter: parent.verticalCenter

                layer.enabled: true
                layer.effect: DropShadow {
                    horizontalOffset: 0
                    verticalOffset: 1
                    radius: 3
                    samples: 16
                    color: Qt.rgba(0, 0, 0, 0.2)
                    transparentBorder: true
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                StyledText {
                    text: "CPU"
                    font.pixelSize: SettingsData.desktopWidgetFontSize - 2
                    color: Theme.surfaceTextMedium
                    font.weight: Font.Medium
                }

                StyledText {
                    text: {
                        if (DgopService.cpuTemperature === undefined || DgopService.cpuTemperature === null || DgopService.cpuTemperature < 0) {
                            return "--°";
                        }
                        return Math.round(DgopService.cpuTemperature) + "°";
                    }
                    font.pixelSize: SettingsData.desktopWidgetFontSize + 2
                    font.weight: Font.Bold
                    color: {
                        if (DgopService.cpuTemperature > 85) {
                            return Theme.tempDanger;
                        }
                        if (DgopService.cpuTemperature > 69) {
                            return Theme.tempWarning;
                        }
                        return Theme.surfaceText;
                    }

                    layer.enabled: true
                    layer.effect: DropShadow {
                        horizontalOffset: 0
                        verticalOffset: 1
                        radius: 3
                        samples: 16
                        color: Qt.rgba(0, 0, 0, 0.2)
                        transparentBorder: true
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.SizeAllCursor
            onPressed: {
                if (alwaysVisible) {
                }
            }
        }
    }
}
