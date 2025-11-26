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

                StyledText {
                    text: `${ApplicationAudioService.totalNodeCount} nodes | ${(ApplicationAudioService.applicationStreams||[]).length} out | ${(ApplicationAudioService.applicationInputStreams||[]).length} in`
                    font.pixelSize: Theme.fontSizeS
                    color: Theme.onSurfaceVariant
                }
            }
        }

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
            }

            Row {
                anchors.fill: parent
                anchors.margins: Theme.spacingM
                spacing: Theme.spacingM

                Column {
                    width: parent.width - volumeSlider.width - Theme.spacingM
                    spacing: Theme.spacingXS
                    anchors.verticalCenter: parent.verticalCenter

                    StyledText {
                        text: node.name || "Unknown"
                        font.pixelSize: Theme.fontSizeM
                        font.weight: Font.Medium
                        color: Theme.onSurface
                        elide: Text.ElideRight
                        width: parent.width
                    }

                    StyledText {
                        text: isInput ? "Input" : "Output"
                        font.pixelSize: Theme.fontSizeS
                        color: Theme.onSurfaceVariant
                    }
                }

                Row {
                    id: volumeSlider
                    width: 200
                    spacing: Theme.spacingS
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        width: Theme.iconSize + Theme.spacingS * 2
                        height: Theme.iconSize + Theme.spacingS * 2
                        anchors.verticalCenter: parent.verticalCenter
                        radius: (Theme.iconSize + Theme.spacingS * 2) / 2
                        color: iconArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"

                        MouseArea {
                            id: iconArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (control.node && control.node.audio) {
                                    control.node.audio.muted = !control.node.audio.muted
                                }
                            }
                        }

                        DarkIcon {
                            anchors.centerIn: parent
                            name: {
                                if (!control.node || !control.node.audio) return control.isInput ? "mic_off" : "volume_off"
                                const volume = control.node.audio.volume
                                const muted = control.node.audio.muted
                                if (control.isInput) {
                                    return (muted || volume === 0.0) ? "mic_off" : "mic"
                                } else {
                                    if (muted || volume === 0.0) return "volume_off"
                                    if (volume <= 0.33) return "volume_down"
                                    if (volume <= 0.66) return "volume_up"
                                    return "volume_up"
                                }
                            }
                            size: Theme.iconSize
                            color: control.node && control.node.audio && !control.node.audio.muted && control.node.audio.volume > 0 ? Theme.primary : Theme.surfaceText
                        }
                    }

                    DarkSlider {
                        readonly property real actualVolumePercent: control.node && control.node.audio ? Math.round(control.node.audio.volume * 100) : 0

                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - (Theme.iconSize + Theme.spacingS * 2) - Theme.spacingS
                        enabled: control.node !== null && control.node.audio !== null
                        minimum: 0
                        maximum: 100
                        value: control.node && control.node.audio ? Math.min(100, Math.round(control.node.audio.volume * 100)) : 0
                        showValue: true
                        unit: "%"
                        valueOverride: actualVolumePercent
                        onSliderValueChanged: function(newValue) {
                            if (control.node && control.node.audio) {
                                control.node.audio.volume = newValue / 100.0
                                if (newValue > 0 && control.node.audio.muted) {
                                    control.node.audio.muted = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
