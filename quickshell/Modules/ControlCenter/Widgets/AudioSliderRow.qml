import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Services.Pipewire
import qs.Common
import qs.Services
import qs.Widgets

Row {
    id: root

    property var defaultSink: AudioService.sink
    property color sliderTrackColor: "transparent"

    height: 40
    spacing: 0

    Rectangle {
        width: Theme.iconSize + Theme.spacingS * 2
        height: Theme.iconSize + Theme.spacingS * 2
        anchors.verticalCenter: parent.verticalCenter
        radius: (Theme.iconSize + Theme.spacingS * 2) / 2
        color: iconArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"

        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 2
            radius: 6
            samples: 16
            color: Qt.rgba(0, 0, 0, SettingsData.controlCenterDropShadowOpacity * 0.8)
            transparentBorder: true
        }

        Behavior on color {
            ColorAnimation { duration: Theme.shortDuration }
        }

        MouseArea {
            id: iconArea
            anchors.fill: parent
            visible: defaultSink !== null
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (defaultSink) {
                    defaultSink.audio.muted = !defaultSink.audio.muted
                }
            }
        }

        DarkIcon {
            anchors.centerIn: parent
            name: {
                if (!defaultSink) return "volume_off"

                let volume = defaultSink.audio.volume
                let muted = defaultSink.audio.muted

                if (muted || volume === 0.0) return "volume_off"
                if (volume <= 0.33) return "volume_down"
                if (volume <= 0.66) return "volume_up"
                return "volume_up"
            }
            size: Theme.iconSize
            color: defaultSink && !defaultSink.audio.muted && defaultSink.audio.volume > 0 ? Theme.primary : Theme.surfaceText
        }
    }

    DarkSlider {
        readonly property real actualVolumePercent: defaultSink ? Math.round(defaultSink.audio.volume * 100) : 0

        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - (Theme.iconSize + Theme.spacingS * 2)
        enabled: defaultSink !== null
        minimum: 0
        maximum: 100
        value: defaultSink ? Math.min(100, Math.round(defaultSink.audio.volume * 100)) : 0
        showValue: true
        unit: "%"
        valueOverride: actualVolumePercent
        thumbOutlineColor: Theme.surfaceContainer
        trackColor: {
            if (root.sliderTrackColor.a > 0) {
                return root.sliderTrackColor
            }
            const alpha = Theme.getContentBackgroundAlpha() * 0.60
            return Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, alpha)
        }
        onSliderValueChanged: function(newValue) {
            if (defaultSink) {
                defaultSink.audio.volume = newValue / 100.0
                if (newValue > 0 && defaultSink.audio.muted) {
                    defaultSink.audio.muted = false
                }
            }
        }
    }
}