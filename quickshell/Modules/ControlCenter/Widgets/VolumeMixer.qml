import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.ControlCenter.Widgets

Rectangle {
    id: root

    property bool showInputs: true
    property bool showOutputs: true
    property bool compact: false

    height: compact ? 60 : Math.max(200, outputColumn.height + inputColumn.height + Theme.spacingM * 3)
    width: parent.width
    radius: Theme.cornerRadius
    color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, Theme.getContentBackgroundAlpha() * 0.30)
    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
    border.width: 1

    // Drop shadow
    layer.enabled: true
    layer.effect: DropShadow {
        horizontalOffset: 0
        verticalOffset: 1
        radius: 4
        samples: 16
        color: Qt.rgba(0, 0, 0, SettingsData.controlCenterDropShadowOpacity * 0.6)
        transparentBorder: true
    }

    Column {
        id: mainColumn
        anchors.fill: parent
        anchors.margins: Theme.spacingM
        spacing: Theme.spacingS

        // Header
        Row {
            width: parent.width
            spacing: Theme.spacingS

            DarkIcon {
                name: "volume_up"
                size: Theme.iconSize
                color: Theme.primary
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: "Volume Mixer"
                font.pixelSize: Theme.fontSizeL
                font.weight: Font.Medium
                color: Theme.onSurface
                anchors.verticalCenter: parent.verticalCenter
            }

            Item { width: 1; height: 1 } // Spacer

            // Toggle buttons for input/output visibility
            Row {
                spacing: Theme.spacingXS
                anchors.verticalCenter: parent.verticalCenter

                SmallToggleButton {
                    text: "Output"
                    isActive: root.showOutputs
                    onClicked: root.showOutputs = !root.showOutputs
                }

                SmallToggleButton {
                    text: "Input"
                    isActive: root.showInputs
                    onClicked: root.showInputs = !root.showInputs
                }
            }
        }

        // Output applications
        Column {
            id: outputColumn
            width: parent.width
            visible: root.showOutputs && (ApplicationAudioService.applicationStreams || []).length > 0
            spacing: Theme.spacingXS

            StyledText {
                text: "Output Applications"
                font.pixelSize: Theme.fontSizeS
                font.weight: Font.Medium
                color: Theme.onSurfaceVariant
                visible: !compact
            }

            Repeater {
                model: ApplicationAudioService.applicationStreams || []

                delegate: Loader {
                    width: parent.width
                    sourceComponent: applicationVolumeControlComponent
                    property var node: modelData
                    property bool isInput: false
                    property bool compact: root.compact
                }
            }

            // No applications message
            StyledText {
                text: "No applications with audio output"
                font.pixelSize: Theme.fontSizeS
                color: Theme.onSurfaceVariant
                visible: (ApplicationAudioService.applicationStreams || []).length === 0
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        // Input applications
        Column {
            id: inputColumn
            width: parent.width
            visible: root.showInputs && (ApplicationAudioService.applicationInputStreams || []).length > 0
            spacing: Theme.spacingXS

            StyledText {
                text: "Input Applications"
                font.pixelSize: Theme.fontSizeS
                font.weight: Font.Medium
                color: Theme.onSurfaceVariant
                visible: !compact
            }

            Repeater {
                model: ApplicationAudioService.applicationInputStreams || []

                delegate: Loader {
                    width: parent.width
                    sourceComponent: applicationVolumeControlComponent
                    property var node: modelData
                    property bool isInput: true
                    property bool compact: root.compact
                }
            }

            // No applications message
            StyledText {
                text: "No applications with audio input"
                font.pixelSize: Theme.fontSizeS
                color: Theme.onSurfaceVariant
                visible: (ApplicationAudioService.applicationInputStreams || []).length === 0
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        // No applications at all
        StyledText {
            text: "No applications with audio"
            font.pixelSize: Theme.fontSizeS
            color: Theme.onSurfaceVariant
            anchors.horizontalCenter: parent.horizontalCenter
            visible: (ApplicationAudioService.applicationStreams || []).length === 0 && (ApplicationAudioService.applicationInputStreams || []).length === 0
        }
    }

    // Individual application volume control component
    Component {
        id: applicationVolumeControlComponent
        
        Rectangle {
            id: control

            required property var node
            required property bool isInput
            required property bool compact

            height: compact ? 40 : 50
            radius: Theme.cornerRadius
            color: mouseArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.08) : Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.2)
            border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
            border.width: 1

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    if (node && node.audio) {
                        if (isInput) {
                            ApplicationAudioService.toggleApplicationInputMute(node)
                        } else {
                            ApplicationAudioService.toggleApplicationMute(node)
                        }
                    }
                }
            }

            Row {
                anchors.fill: parent
                anchors.margins: Theme.spacingS
                spacing: Theme.spacingS

                // Application icon
                DarkIcon {
                    name: ApplicationAudioService.getApplicationIcon(node)
                    size: compact ? Theme.iconSizeS : Theme.iconSize
                    color: node && node.audio && !node.audio.muted && node.audio.volume > 0 ? Theme.primary : Theme.surfaceText
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Application name
                StyledText {
                    text: ApplicationAudioService.getApplicationName(node)
                    font.pixelSize: compact ? Theme.fontSizeS : Theme.fontSizeM
                    color: Theme.onSurface
                    elide: Text.ElideRight
                    width: Math.min(implicitWidth, parent.width - icon.width - slider.width - Theme.spacingS * 3)
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item { width: 1; height: 1 } // Spacer

                // Volume slider
                DarkSlider {
                    id: slider
                    width: compact ? 80 : 120
                    height: parent.height
                    enabled: node && node.audio
                    minimum: 0
                    maximum: 100
                    value: node && node.audio ? Math.round(node.audio.volume * 100) : 0
                    showValue: !compact
                    unit: "%"
                    thumbOutlineColor: Theme.surfaceContainer
                    trackColor: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, Theme.getContentBackgroundAlpha() * 0.60)
                    anchors.verticalCenter: parent.verticalCenter

                    onSliderValueChanged: function(newValue) {
                        if (node && node.audio) {
                            if (isInput) {
                                ApplicationAudioService.setApplicationInputVolume(node, newValue)
                            } else {
                                ApplicationAudioService.setApplicationVolume(node, newValue)
                            }
                        }
                    }
                }
            }

            // Mute indicator
            Rectangle {
                width: 4
                height: parent.height
                radius: 2
                color: node && node.audio && node.audio.muted ? Theme.error : "transparent"
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.leftMargin: 2
            }
        }
    }
}
