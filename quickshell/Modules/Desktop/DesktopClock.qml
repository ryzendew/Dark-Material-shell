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
        color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, SettingsData.desktopClockOpacity)
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, SettingsData.desktopWidgetBorderOpacity)
        border.width: SettingsData.desktopWidgetBorderThickness

        anchors.left: positionAnchors.horizontal === "left" ? parent.left : undefined
        anchors.horizontalCenter: positionAnchors.horizontal === "center" ? parent.horizontalCenter : undefined
        anchors.right: positionAnchors.horizontal === "right" ? parent.right : undefined
        anchors.top: positionAnchors.vertical === "top" ? parent.top : undefined
        anchors.verticalCenter: positionAnchors.vertical === "center" ? parent.verticalCenter : undefined
        anchors.bottom: positionAnchors.vertical === "bottom" ? parent.bottom : undefined

        layer.enabled: SettingsData.desktopWidgetDropShadowOpacity > 0
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 4
            radius: 12
            samples: 16
            color: Qt.rgba(0, 0, 0, SettingsData.desktopWidgetDropShadowOpacity)
            transparentBorder: true
        }

        Column {
            anchors.centerIn: parent
            spacing: Theme.spacingXS

            StyledText {
                text: {
                    const now = new Date()
                    if (SettingsData.use24HourClock) {
                        // Force 24-hour format with AM/PM
                        const hours = now.getHours()
                        const minutes = now.getMinutes()
                        const period = hours >= 12 ? "PM" : "AM"
                        return String(hours).padStart(2, '0') + ":" + String(minutes).padStart(2, '0') + " " + period
                    } else {
                        const formatted = now.toLocaleTimeString(Qt.locale(), "h:mm AP")
                        return formatted.replace(/\./g, "").trim()
                    }
                }
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.surfaceText
                font.weight: Font.Bold
                anchors.horizontalCenter: parent.horizontalCenter

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
