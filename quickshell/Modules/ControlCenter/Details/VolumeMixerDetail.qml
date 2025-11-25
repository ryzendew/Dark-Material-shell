import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import qs.Common
import Qt5Compat.GraphicalEffects
import qs.Services
import qs.Widgets
import qs.Modules.ControlCenter.Widgets

Rectangle {
    id: root

    height: Math.max(400, contentColumn.height + Theme.spacingM * 2)
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
        id: contentColumn
        anchors.fill: parent
        anchors.margins: Theme.spacingM
        spacing: Theme.spacingM

        // Header
        Row {
            width: parent.width
            spacing: Theme.spacingS

            DarkIcon {
                name: "volume_up"
                size: Theme.iconSizeL
                color: Theme.primary
                anchors.verticalCenter: parent.verticalCenter
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.spacingXS

                StyledText {
                    text: "Volume Mixer"
                    font.pixelSize: Theme.fontSizeXL
                    font.weight: Font.Medium
                    color: Theme.onSurface
                }

                StyledText {
                    text: "Control audio for individual applications"
                    font.pixelSize: Theme.fontSizeS
                    color: Theme.onSurfaceVariant
                }
            }

            Item { width: 1; height: 1 } // Spacer

            // Control buttons
            Row {
                spacing: Theme.spacingS
                anchors.verticalCenter: parent.verticalCenter

                ToggleButton {
                    text: "Output"
                    isActive: showOutputs
                    onClicked: showOutputs = !showOutputs
                }

                ToggleButton {
                    text: "Input"
                    isActive: showInputs
                    onClicked: showInputs = !showInputs
                }

                ToggleButton {
                    text: "Debug"
                    isActive: false
                    onClicked: ApplicationAudioService.debugAllNodes()
                }

                // Tiny live counters to confirm PipeWire visibility
                StyledText {
                    text: `${ApplicationAudioService.totalNodeCount} nodes | ${(ApplicationAudioService.applicationStreams||[]).length} out | ${(ApplicationAudioService.applicationInputStreams||[]).length} in`
                    font.pixelSize: Theme.fontSizeS
                    color: Theme.onSurfaceVariant
                }
            }
        }

        // Output applications section
        Column {
            id: outputSection
            width: parent.width
            visible: showOutputs
            spacing: Theme.spacingS

            Row {
                width: parent.width
                spacing: Theme.spacingS

                StyledText {
                    text: "Output Applications"
                    font.pixelSize: Theme.fontSizeL
                    font.weight: Font.Medium
                    color: Theme.onSurface
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item { width: 1; height: 1 } // Spacer

                StyledText {
                    text: `${(ApplicationAudioService.applicationStreams || []).length} active`
                    font.pixelSize: Theme.fontSizeS
                    color: Theme.onSurfaceVariant
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
            }

            Repeater {
                model: ApplicationAudioService.applicationStreams || []

                delegate: Loader {
                    width: parent.width
                    sourceComponent: detailedApplicationVolumeControlComponent
                    property var node: modelData
                    property bool isInput: false
                }
            }

            // No applications message
            Rectangle {
                width: parent.width
                height: 60
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.1)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
                border.width: 1
                visible: (ApplicationAudioService.applicationStreams || []).length === 0

                StyledText {
                    text: "No applications with audio output"
                    font.pixelSize: Theme.fontSizeS
                    color: Theme.onSurfaceVariant
                    anchors.centerIn: parent
                }
            }
        }

        // Input applications section
        Column {
            id: inputSection
            width: parent.width
            visible: showInputs
            spacing: Theme.spacingS

            Row {
                width: parent.width
                spacing: Theme.spacingS

                StyledText {
                    text: "Input Applications"
                    font.pixelSize: Theme.fontSizeL
                    font.weight: Font.Medium
                    color: Theme.onSurface
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item { width: 1; height: 1 } // Spacer

                StyledText {
                    text: `${(ApplicationAudioService.applicationInputStreams || []).length} active`
                    font.pixelSize: Theme.fontSizeS
                    color: Theme.onSurfaceVariant
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
            }

            Repeater {
                model: ApplicationAudioService.applicationInputStreams || []

                delegate: Loader {
                    width: parent.width
                    sourceComponent: detailedApplicationVolumeControlComponent
                    property var node: modelData
                    property bool isInput: true
                }
            }

            // No applications message
            Rectangle {
                width: parent.width
                height: 60
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.1)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
                border.width: 1
                visible: (ApplicationAudioService.applicationInputStreams || []).length === 0

                StyledText {
                    text: "No applications with audio input"
                    font.pixelSize: Theme.fontSizeS
                    color: Theme.onSurfaceVariant
                    anchors.centerIn: parent
                }
            }
        }

        // No applications at all
        Rectangle {
            width: parent.width
            height: 80
            radius: Theme.cornerRadius
            color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.1)
            border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
            border.width: 1
            visible: (ApplicationAudioService.applicationStreams || []).length === 0 && (ApplicationAudioService.applicationInputStreams || []).length === 0

            Column {
                anchors.centerIn: parent
                spacing: Theme.spacingXS

                StyledText {
                    text: "No applications with audio"
                    font.pixelSize: Theme.fontSizeM
                    color: Theme.onSurfaceVariant
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                StyledText {
                    text: "Start an application that uses audio to see it here"
                    font.pixelSize: Theme.fontSizeS
                    color: Theme.onSurfaceVariant
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }

    property bool showOutputs: true
    property bool showInputs: true

    // Detailed application volume control component
    Component {
        id: detailedApplicationVolumeControlComponent
        
        Rectangle {
            id: control

            required property var node
            required property bool isInput

            height: 70
            radius: Theme.cornerRadius
            color: mouseArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.08) : Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.2)
            border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
            border.width: 1

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                // avoid toggling mute on entire row click to prevent event storms
                onClicked: { /* no-op */ }
            }

            Row {
                anchors.fill: parent
                anchors.margins: Theme.spacingM
                spacing: Theme.spacingM

                // Application icon
                DarkIcon {
                    name: ApplicationAudioService.getApplicationIcon(node)
                    size: Theme.iconSizeL
                    color: node && node.audio && !node.audio.muted && node.audio.volume > 0 ? Theme.primary : Theme.surfaceText
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Application info
                Column {
                    width: Math.min(implicitWidth, parent.width - icon.width - slider.width - Theme.spacingM * 3)
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.spacingXS

                    StyledText {
                        text: ApplicationAudioService.getApplicationName(node)
                        font.pixelSize: Theme.fontSizeM
                        font.weight: Font.Medium
                        color: Theme.onSurface
                        elide: Text.ElideRight
                        width: parent.width
                    }

                    StyledText {
                        text: isInput ? "Audio Input" : "Audio Output"
                        font.pixelSize: Theme.fontSizeS
                        color: Theme.onSurfaceVariant
                        width: parent.width
                    }
                }

                Item { width: 1; height: 1 } // Spacer

                // Volume controls
                Column {
                    width: 200
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.spacingXS

                    // Volume slider
                    DarkSlider {
                        id: slider
                        width: parent.width
                        enabled: node && node.audio
                        minimum: 0
                        maximum: 100
                        value: node && node.audio ? Math.round(node.audio.volume * 100) : 0
                        showValue: true
                        unit: "%"
                        thumbOutlineColor: Theme.surfaceContainer
                        trackColor: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, Theme.getContentBackgroundAlpha() * 0.60)

                        onSliderValueChanged: function(newValue) {
                            if (node && node.audio) {
                                node.audio.volume = Math.max(0, Math.min(100, newValue)) / 100
                            }
                        }
                    }

                    // Mute button
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: Theme.spacingXS

                        DarkActionButton {
                            buttonSize: 28
                            iconName: node && node.audio && node.audio.muted ? "volume_off" : (isInput ? "mic" : "volume_up")
                            iconSize: 16
                            iconColor: node && node.audio && node.audio.muted ? Theme.error : Theme.onSurfaceVariant
                            onClicked: {
                                if (node && node.audio) {
                                    node.audio.muted = !node.audio.muted
                                }
                            }
                        }

                        StyledText {
                            text: node && node.audio && node.audio.muted ? "Muted" : "Active"
                            font.pixelSize: Theme.fontSizeS
                            color: node && node.audio && node.audio.muted ? Theme.error : Theme.onSurfaceVariant
                            anchors.verticalCenter: parent.verticalCenter
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
