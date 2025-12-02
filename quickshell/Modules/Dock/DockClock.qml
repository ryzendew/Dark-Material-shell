import QtQuick
import QtQuick.Controls
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: root

    property real widgetHeight: 40

    width: clockText.implicitWidth + 16
    height: widgetHeight

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.3)
        radius: Theme.cornerRadius
        border.width: 1
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)

        Row {
            anchors.centerIn: parent
            spacing: 6

            DarkIcon {
                name: "schedule"
                size: 16
                color: Theme.primary
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                id: clockText
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
                font.pixelSize: 12
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            const now = new Date()
            if (SettingsData.use24HourClock) {
                // Force 24-hour format with AM/PM
                const hours = now.getHours()
                const minutes = now.getMinutes()
                const period = hours >= 12 ? "PM" : "AM"
                clockText.text = String(hours).padStart(2, '0') + ":" + String(minutes).padStart(2, '0') + " " + period
            } else {
                const formatted = now.toLocaleTimeString(Qt.locale(), "h:mm AP")
                clockText.text = formatted.replace(/\./g, "").trim()
            }
        }
    }
}
