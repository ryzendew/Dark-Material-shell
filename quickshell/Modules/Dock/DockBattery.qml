import QtQuick
import QtQuick.Controls
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: root

    property real widgetHeight: 40

    width: batteryRow.implicitWidth + 16
    height: widgetHeight

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.3)
        radius: Theme.cornerRadius
        border.width: 1
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)

        Row {
            id: batteryRow
            anchors.centerIn: parent
            spacing: 6

            DarkIcon {
                name: getBatteryIcon()
                size: 16
                color: getBatteryColor()
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: BatteryService.chargePercent ? Math.round(BatteryService.chargePercent) + "%" : "--%"
                font.pixelSize: 12
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    function getBatteryIcon() {
        if (!BatteryService.chargePercent) return "battery_unknown"
        
        const percent = BatteryService.chargePercent
        if (BatteryService.charging) {
            if (percent < 25) return "battery_charging_20"
            if (percent < 50) return "battery_charging_30"
            if (percent < 75) return "battery_charging_50"
            if (percent < 90) return "battery_charging_60"
            return "battery_charging_full"
        } else {
            if (percent < 25) return "battery_alert"
            if (percent < 50) return "battery_1_bar"
            if (percent < 75) return "battery_2_bar"
            if (percent < 90) return "battery_4_bar"
            return "battery_full"
        }
    }

    function getBatteryColor() {
        if (!BatteryService.chargePercent) return Theme.surfaceText
        
        const percent = BatteryService.chargePercent
        if (BatteryService.charging) return Theme.primary
        if (percent < 20) return Theme.error
        if (percent < 50) return Theme.warning
        return Theme.surfaceText
    }
}







