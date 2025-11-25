import QtQuick
import Qt5Compat.GraphicalEffects
import qs.Common
import qs.Widgets

DarkOSD {
    id: root

    property var screen: null
    property real widgetWidth: 180
    property real widgetHeight: 80
    property bool alwaysVisible: true

    osdWidth: widgetWidth
    osdHeight: widgetHeight
    enableMouseInteraction: true
    autoHideInterval: 0

    // Position based on individual widget settings
    property var positionAnchors: {
        switch(SettingsData.desktopClockPosition) {
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

    Component.onCompleted: {
        show();
    }

    content: Rectangle {
        width: widgetWidth
        height: widgetHeight
        radius: Theme.cornerRadius
        color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.9)
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.3)
        border.width: 1

        // Position based on settings
        anchors.left: positionAnchors.horizontal === "left" ? parent.left : undefined
        anchors.horizontalCenter: positionAnchors.horizontal === "center" ? parent.horizontalCenter : undefined
        anchors.right: positionAnchors.horizontal === "right" ? parent.right : undefined
        anchors.top: positionAnchors.vertical === "top" ? parent.top : undefined
        anchors.verticalCenter: positionAnchors.vertical === "center" ? parent.verticalCenter : undefined
        anchors.bottom: positionAnchors.vertical === "bottom" ? parent.bottom : undefined

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
            spacing: Theme.spacingXS

            StyledText {
                text: {
                    const now = new Date()
                    const format = SettingsData.use24HourClock ? "HH:mm" : "h:mm AP"
                    return now.toLocaleTimeString(Qt.locale(), format)
                }
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.surfaceText
                font.weight: Font.Bold
                anchors.horizontalCenter: parent.horizontalCenter

                // Drop shadow
                layer.enabled: true
                layer.effect: DropShadow {
                    horizontalOffset: 0
                    verticalOffset: 2
                    radius: 4
                    samples: 16
                    color: Qt.rgba(0, 0, 0, 0.2)
                    transparentBorder: true
                }
            }

            StyledText {
                text: {
                    const now = new Date()
                    if (SettingsData.clockDateFormat && SettingsData.clockDateFormat.length > 0) {
                        return now.toLocaleDateString(Qt.locale(), SettingsData.clockDateFormat)
                    }
                    return now.toLocaleDateString(Qt.locale(), "dddd, MMMM d")
                }
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceTextMedium
                font.weight: Font.Medium
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
                    show();
                }
            }
        }
    }

}
