import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Common

PanelWindow {
    id: root

    property string tooltipText: ""
    property real targetX: 0
    property real targetY: 0
    property var targetScreen: null
    property bool isBarVertical: false
    property string barPosition: "top"

    function showTooltip(text, x, y, screen, vertical, position) {
        tooltipText = text;
        targetScreen = screen;
        isBarVertical = vertical || false;
        barPosition = position || "top";
        const screenX = screen ? screen.x : 0;
        targetX = x - screenX;
        targetY = y;
        visible = true;
    }

    function hideTooltip() {
        visible = false;
    }

    screen: targetScreen
    implicitWidth: isBarVertical ? Math.min(300, Math.max(120, textContent.implicitHeight + Theme.spacingS * 2)) : Math.min(300, Math.max(120, textContent.implicitWidth + Theme.spacingM * 2))
    implicitHeight: isBarVertical ? Math.min(300, Math.max(120, textContent.implicitWidth + Theme.spacingM * 2)) : (textContent.implicitHeight + Theme.spacingS * 2)
    color: "transparent"
    visible: false
    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.exclusiveZone: -1

    anchors {
        top: true
        left: true
    }

    margins {
        left: isBarVertical ? Math.round(targetX) : Math.round(targetX - implicitWidth / 2)
        top: isBarVertical ? Math.round(targetY - implicitHeight / 2) : Math.round(targetY)
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.surfaceContainerHigh
        radius: Theme.cornerRadius
        border.width: 1
        border.color: Theme.outlineMedium
        rotation: isBarVertical ? (barPosition === "left" ? 90 : -90) : 0

        Text {
            id: textContent

            anchors.centerIn: parent
            rotation: isBarVertical ? (barPosition === "left" ? -90 : 90) : 0
            text: root.tooltipText
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.surfaceText
            wrapMode: Text.NoWrap
            maximumLineCount: 1
            elide: Text.ElideRight
            width: isBarVertical ? (parent.height - Theme.spacingM * 2) : (parent.width - Theme.spacingM * 2)
        }

    }

}
