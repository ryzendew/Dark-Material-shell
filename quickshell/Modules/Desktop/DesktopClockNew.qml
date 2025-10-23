import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services

PanelWindow {
    id: root

    property var screen: null
    property real widgetWidth: 120
    property real widgetHeight: 60
    property bool alwaysVisible: true
    property string position: "bottom-right"

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
            default: return { horizontal: "right", vertical: "bottom" }
        }
    }

    WlrLayershell.anchors: {
        if (positionAnchors.horizontal === "left" && positionAnchors.vertical === "top") return WlrLayershell.TopLeftAnchor
        if (positionAnchors.horizontal === "center" && positionAnchors.vertical === "top") return WlrLayershell.TopAnchor
        if (positionAnchors.horizontal === "right" && positionAnchors.vertical === "top") return WlrLayershell.TopRightAnchor
        if (positionAnchors.horizontal === "left" && positionAnchors.vertical === "center") return WlrLayershell.LeftAnchor
        if (positionAnchors.horizontal === "center" && positionAnchors.vertical === "center") return WlrLayershell.CenterAnchor
        if (positionAnchors.horizontal === "right" && positionAnchors.vertical === "center") return WlrLayershell.RightAnchor
        if (positionAnchors.horizontal === "left" && positionAnchors.vertical === "bottom") return WlrLayershell.BottomLeftAnchor
        if (positionAnchors.horizontal === "center" && positionAnchors.vertical === "bottom") return WlrLayershell.BottomAnchor
        if (positionAnchors.horizontal === "right" && positionAnchors.vertical === "bottom") return WlrLayershell.BottomRightAnchor
        return WlrLayershell.BottomRightAnchor
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

        Column {
            anchors.centerIn: parent
            spacing: 2

            StyledText {
                text: Qt.formatDateTime(new Date(), "h:mm AP")
                font.pixelSize: Theme.fontSizeMedium
                font.weight: Font.Bold
                color: Theme.surfaceText
                anchors.horizontalCenter: parent.horizontalCenter

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

            StyledText {
                text: Qt.formatDateTime(new Date(), "ddd d")
                font.pixelSize: Theme.fontSizeSmall - 2
                color: Theme.surfaceTextMedium
                anchors.horizontalCenter: parent.horizontalCenter

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

    // Update time every second
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            // Force update of time display
        }
    }
}





