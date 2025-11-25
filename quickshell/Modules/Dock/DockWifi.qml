import QtQuick
import QtQuick.Controls
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: root

    property real widgetHeight: 40

    width: wifiRow.implicitWidth + 16
    height: widgetHeight

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.3)
        radius: Theme.cornerRadius
        border.width: 1
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)

        Row {
            id: wifiRow
            anchors.centerIn: parent
            spacing: 6

            DarkIcon {
                name: getWifiIcon()
                size: 16
                color: getWifiColor()
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: NetworkService.connectedSSID || "Disconnected"
                font.pixelSize: 12
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
                elide: Text.ElideRight
                maximumLineCount: 1
            }
        }
    }

    function getWifiIcon() {
        if (!NetworkService.connected) return "wifi_off"
        if (!NetworkService.connectedSSID) return "wifi_off"
        
        const strength = NetworkService.signalStrength || 0
        if (strength < 25) return "wifi_1_bar"
        if (strength < 50) return "wifi_2_bar"
        if (strength < 75) return "wifi_3_bar"
        return "wifi_4_bar"
    }

    function getWifiColor() {
        if (!NetworkService.connected) return Theme.error
        return Theme.primary
    }
}







