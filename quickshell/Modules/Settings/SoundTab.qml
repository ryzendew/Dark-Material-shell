import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: soundTab

    DarkFlickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: contentColumn.implicitHeight

        Column {
            id: contentColumn
            width: parent.width
            spacing: Theme.spacingL

            // Application Volume Mixer
            Loader {
                width: parent.width
                source: "EnhancedVolumeMixer.qml"
                onLoaded: {
                    if (item) {
                        item.showInputs = true
                        item.showOutputs = true
                    }
                }
            }

            // Default Output Device Section
            StyledRect {
                width: parent.width
                height: outputSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.20)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
                border.width: 1

                Column {
                    id: outputSection
                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    StyledText {
                        text: "Default Output Device"
                        font.pixelSize: Theme.fontSizeLarge
                        font.weight: Font.Medium
                        color: Theme.surfaceText
                    }

                    Loader {
                        width: parent.width
                        source: "../../Modules/ControlCenter/Widgets/AudioSliderRow.qml"
                    }
                }
            }

            // Output Devices List
            StyledRect {
                width: parent.width
                height: outputDevicesSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.20)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
                border.width: 1

                Column {
                    id: outputDevicesSection
                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    StyledText {
                        text: "Output Devices"
                        font.pixelSize: Theme.fontSizeLarge
                        font.weight: Font.Medium
                        color: Theme.surfaceText
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        Repeater {
                            model: Pipewire.nodes?.values ? Pipewire.nodes.values.filter(node => {
                                return node && node.ready && node.audio && node.isSink && !node.isStream
                            }) : []

                            delegate: Rectangle {
                                required property var modelData
                                required property int index

                                width: parent.width
                                height: 50
                                radius: Theme.cornerRadius
                                color: deviceMouseArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.08) : Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, index % 2 === 0 ? 0.3 : 0.2)
                                border.color: modelData === AudioService.sink ? Theme.primary : Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
                                border.width: modelData === AudioService.sink ? 2 : 1

                                Row {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.leftMargin: Theme.spacingM
                                    spacing: Theme.spacingS

                                    DarkIcon {
                                        name: {
                                            if (modelData.name.includes("bluez"))
                                                return "headset"
                                            else if (modelData.name.includes("hdmi"))
                                                return "tv"
                                            else if (modelData.name.includes("usb"))
                                                return "headset"
                                            else
                                                return "speaker"
                                        }
                                        size: Theme.iconSize - 4
                                        color: modelData === AudioService.sink ? Theme.primary : Theme.surfaceText
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.parent.width - parent.parent.anchors.leftMargin - parent.spacing - Theme.iconSize - Theme.spacingM

                                        StyledText {
                                            text: AudioService.displayName(modelData)
                                            font.pixelSize: Theme.fontSizeMedium
                                            color: Theme.surfaceText
                                            font.weight: modelData === AudioService.sink ? Font.Medium : Font.Normal
                                            elide: Text.ElideRight
                                            width: parent.width
                                        }

                                        StyledText {
                                            text: modelData === AudioService.sink ? "Active" : "Available"
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Theme.surfaceVariantText
                                            elide: Text.ElideRight
                                            width: parent.width
                                        }
                                    }
                                }

                                MouseArea {
                                    id: deviceMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (modelData) {
                                            Pipewire.preferredDefaultAudioSink = modelData
                                        }
                                    }
                                }
                            }
                        }

                        StyledText {
                            text: "No output devices available"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            anchors.horizontalCenter: parent.horizontalCenter
                            visible: !Pipewire.nodes || !Pipewire.nodes.values || Pipewire.nodes.values.filter(node => {
                                return node && node.ready && node.audio && node.isSink && !node.isStream
                            }).length === 0
                        }
                    }
                }
            }

            // Default Input Device Section
            StyledRect {
                width: parent.width
                height: inputSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.20)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
                border.width: 1

                Column {
                    id: inputSection
                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    StyledText {
                        text: "Default Input Device"
                        font.pixelSize: Theme.fontSizeLarge
                        font.weight: Font.Medium
                        color: Theme.surfaceText
                    }

                    Loader {
                        width: parent.width
                        source: "../../Modules/ControlCenter/Widgets/InputAudioSliderRow.qml"
                    }
                }
            }

            // Input Devices List
            StyledRect {
                width: parent.width
                height: inputDevicesSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.20)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
                border.width: 1

                Column {
                    id: inputDevicesSection
                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    StyledText {
                        text: "Input Devices"
                        font.pixelSize: Theme.fontSizeLarge
                        font.weight: Font.Medium
                        color: Theme.surfaceText
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        Repeater {
                            model: Pipewire.nodes?.values ? Pipewire.nodes.values.filter(node => {
                                return node && node.ready && node.audio && !node.isSink && !node.isStream
                            }) : []

                            delegate: Rectangle {
                                required property var modelData
                                required property int index

                                width: parent.width
                                height: 50
                                radius: Theme.cornerRadius
                                color: deviceMouseArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.08) : Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, index % 2 === 0 ? 0.3 : 0.2)
                                border.color: modelData === AudioService.source ? Theme.primary : Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
                                border.width: modelData === AudioService.source ? 2 : 1

                                Row {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.leftMargin: Theme.spacingM
                                    spacing: Theme.spacingS

                                    DarkIcon {
                                        name: {
                                            if (modelData.name.includes("bluez"))
                                                return "headset"
                                            else if (modelData.name.includes("usb"))
                                                return "headset"
                                            else
                                                return "mic"
                                        }
                                        size: Theme.iconSize - 4
                                        color: modelData === AudioService.source ? Theme.primary : Theme.surfaceText
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.parent.width - parent.parent.anchors.leftMargin - parent.spacing - Theme.iconSize - Theme.spacingM

                                        StyledText {
                                            text: AudioService.displayName(modelData)
                                            font.pixelSize: Theme.fontSizeMedium
                                            color: Theme.surfaceText
                                            font.weight: modelData === AudioService.source ? Font.Medium : Font.Normal
                                            elide: Text.ElideRight
                                            width: parent.width
                                        }

                                        StyledText {
                                            text: modelData === AudioService.source ? "Active" : "Available"
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Theme.surfaceVariantText
                                            elide: Text.ElideRight
                                            width: parent.width
                                        }
                                    }
                                }

                                MouseArea {
                                    id: deviceMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (modelData) {
                                            Pipewire.preferredDefaultAudioSource = modelData
                                        }
                                    }
                                }
                            }
                        }

                        StyledText {
                            text: "No input devices available"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            anchors.horizontalCenter: parent.horizontalCenter
                            visible: !Pipewire.nodes || !Pipewire.nodes.values || Pipewire.nodes.values.filter(node => {
                                return node && node.ready && node.audio && !node.isSink && !node.isStream
                            }).length === 0
                        }
                    }
                }
            }

        }
    }
}
