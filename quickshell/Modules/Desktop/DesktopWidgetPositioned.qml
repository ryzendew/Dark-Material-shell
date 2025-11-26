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
    property var positioningBox: null

    implicitWidth: widgetWidth
    implicitHeight: widgetHeight
    visible: alwaysVisible

    WlrLayershell.layer: WlrLayershell.Background
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    color: "transparent"


    margins {
        left: position.includes("left") ? 20 : (position.includes("center") ? 0 : -1)
        right: position.includes("right") ? 20 : (position.includes("center") ? 0 : -1)
        top: position.includes("top") ? 20 : (position.includes("middle") ? 0 : -1)
        bottom: position.includes("bottom") ? 20 : (position.includes("middle") ? 0 : -1)
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

        Text {
            anchors.centerIn: parent
            text: "POSITIONED WIDGET\n" + position
            color: "white"
            font.pixelSize: 12
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
