import QtQuick
import QtQuick.Controls
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: root

    property real widgetHeight: 40

    width: volumeRow.implicitWidth + 16
    height: widgetHeight

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.3)
        radius: Theme.cornerRadius
        border.width: 1
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)

        Row {
            id: volumeRow
            anchors.centerIn: parent
            spacing: 6

            DankIcon {
                name: getVolumeIcon()
                size: 16
                color: Theme.primary
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: AudioService.volume ? Math.round(AudioService.volume) + "%" : "--%"
                font.pixelSize: 12
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    function getVolumeIcon() {
        if (!AudioService.volume) return "volume_off"
        
        const volume = AudioService.volume
        if (volume === 0) return "volume_off"
        if (volume < 33) return "volume_mute"
        if (volume < 66) return "volume_down"
        return "volume_up"
    }
}







