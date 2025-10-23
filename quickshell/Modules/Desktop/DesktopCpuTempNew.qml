import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services
import qs.Widgets

PanelWindow {
    id: root

    property var screen: null
    property real widgetWidth: 120
    property real widgetHeight: 60
    property bool alwaysVisible: true
    property string position: "top-left"

    implicitWidth: widgetWidth
    implicitHeight: widgetHeight
    visible: alwaysVisible

    WlrLayershell.layer: WlrLayershell.Background
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    color: "transparent"

    // Position based on settings
    property var positionAnchors: {
        switch(position) {
            case "top-left": return { horizontal: "left", vertical: "top" }
            case "top-center": return { horizontal: "center", vertical: "top" }
            case "top-right": return { horizontal: "right", vertical: "top" }
            case "middle-left": return { horizontal: "left", vertical: "center" }
            case "middle-center": return { horizontal: "center", vertical: "center" }
            case "middle-right": return { horizontal: "right", vertical: "center" }
            case "bottom-left": return { horizontal: "left", vertical: "bottom" }
            case "bottom-center": return { horizontal: "center", vertical: "bottom" }
            case "bottom-right": return { horizontal: "right", vertical: "bottom" }
            default: return { horizontal: "left", vertical: "top" }
        }
    }

    WlrLayershell.anchors: WlrLayershell.TopAnchor

    margins {
        left: positionAnchors.horizontal === "left" ? 20 : 0
        right: positionAnchors.horizontal === "right" ? 20 : 0
        top: positionAnchors.vertical === "top" ? 20 : 0
        bottom: positionAnchors.vertical === "bottom" ? 20 : 0
    }

    Component.onCompleted: {
        console.log("DesktopCpuTempNew: Component.onCompleted");
        console.log("DesktopCpuTempNew: position =", position);
        console.log("DesktopCpuTempNew: positionAnchors =", positionAnchors);
        console.log("DesktopCpuTempNew: WlrLayershell.anchors =", WlrLayershell.anchors);
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

        // Drop shadow
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

            DankIcon {
                name: "memory"
                size: Theme.iconSize - 4
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

                // Drop shadow
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
                    font.pixelSize: Theme.fontSizeSmall - 2
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
                    font.pixelSize: Theme.fontSizeMedium
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

                    // Drop shadow
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

        // Make the widget draggable
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.SizeAllCursor
            onPressed: {
                if (alwaysVisible) {
                    // Widget is always visible, no need to show/hide
                }
            }
        }
    }

    // Auto-refresh when temperature changes
    Connections {
        target: DgopService
        function onCpuTemperatureChanged() {
            // Widget is always visible, no need to show/hide
        }
    }
}
