import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.ControlCenter.Widgets

Item {
    id: soundTab

    property bool showOutputs: true
    property bool showInputs: true

    DarkFlickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: contentColumn.implicitHeight

        Column {
            id: contentColumn
            width: parent.width
            spacing: Theme.spacingM


            StyledRect {
                width: parent.width
                height: outputColumn.implicitHeight + (Theme.spacingL || 16) * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.20)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
                border.width: 1
                visible: showOutputs

                Column {
                    id: outputColumn
                    anchors.fill: parent
                    anchors.margins: (Theme.spacingL || 16)
                    spacing: (Theme.spacingS || 8)

                    Row {
                        width: parent.width
                        spacing: (Theme.spacingS || 8)
                        StyledText { text: "Output Applications"; font.pixelSize: (Theme.fontSizeL || 18); font.weight: Font.Medium; color: Theme.surfaceText }
                        Item { width: 1; height: 1 }
                        StyledText { text: `${(ApplicationAudioService.applicationStreams||[]).length} active`; font.pixelSize: (Theme.fontSizeS || 12); color: Theme.surfaceText }
                    }

                    Column {
                        width: parent.width
                        spacing: (Theme.spacingXS || 4)

                        Repeater {
                            model: ApplicationAudioService.applicationStreams || []
                            delegate: Loader {
                                width: parent.width
                                sourceComponent: applicationVolumeControlRow
                                asynchronous: false
                                property var node: modelData
                                property bool isInput: false
                                height: item ? item.height : 56
                                onLoaded: { if (item) { item.node = node; item.isInput = isInput } }
                            }
                        }

                        Repeater {
                            model: ApplicationAudioService.applicationStreams || []
                            delegate: Loader {
                                width: parent.width
                                sourceComponent: applicationRoutingSection
                                property var node: modelData
                                property bool isInput: false
                                height: item ? item.height : ((Theme.iconSize || 24) + (Theme.spacingL || 16) * 2)
                                onLoaded: { if (item) { item.node = node; item.isInput = isInput } }
                            }
                        }
                    }

                        StyledText {
                            text: "No applications with audio output"
                            font.pixelSize: (Theme.fontSizeS || 12)
                            color: Theme.surfaceText
                            visible: (ApplicationAudioService.applicationStreams || []).length === 0
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                }
            }

            StyledRect {
                width: parent.width
                height: inputColumn.implicitHeight + (Theme.spacingL || 16) * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.20)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
                border.width: 1
                visible: showInputs

                Column {
                    id: inputColumn
                    anchors.fill: parent
                    anchors.margins: (Theme.spacingL || 16)
                    spacing: (Theme.spacingS || 8)

                    Row {
                        width: parent.width
                        spacing: (Theme.spacingS || 8)
                        StyledText { text: "Input Applications"; font.pixelSize: (Theme.fontSizeL || 18); font.weight: Font.Medium; color: Theme.surfaceText }
                        Item { width: 1; height: 1 }
                        StyledText { text: `${(ApplicationAudioService.applicationInputStreams||[]).length} active`; font.pixelSize: (Theme.fontSizeS || 12); color: Theme.surfaceText }
                    }

                    Column {
                        width: parent.width
                        spacing: (Theme.spacingXS || 4)

                        Repeater {
                            model: ApplicationAudioService.applicationInputStreams || []
                            delegate: Loader {
                                width: parent.width
                                sourceComponent: applicationVolumeControlRow
                                asynchronous: false
                                property var node: modelData
                                property bool isInput: true
                                height: item ? item.height : 56
                                onLoaded: { if (item) { item.node = node; item.isInput = isInput } }
                            }
                        }

                        Repeater {
                            model: ApplicationAudioService.applicationInputStreams || []
                            delegate: Loader {
                                width: parent.width
                                sourceComponent: applicationRoutingSection
                                property var node: modelData
                                property bool isInput: true
                                height: item ? item.height : ((Theme.iconSize || 24) + (Theme.spacingL || 16) * 2)
                                onLoaded: { if (item) { item.node = node; item.isInput = isInput } }
                            }
                        }
                    }

                    StyledText {
                        text: "No applications with audio input"
                        font.pixelSize: (Theme.fontSizeS || 12)
                        color: Theme.surfaceText
                        visible: (ApplicationAudioService.applicationInputStreams || []).length === 0
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: outputDevicesCol.implicitHeight + (Theme.spacingL || 16) * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.20)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
                border.width: 1

                Column {
                    id: outputDevicesCol
                    anchors.fill: parent
                    anchors.margins: (Theme.spacingL || 16)
                    spacing: (Theme.spacingS || 8)

                    Row { width: parent.width; spacing: (Theme.spacingS || 8)
                        StyledText { text: "Output Devices"; font.pixelSize: (Theme.fontSizeL || 18); font.weight: Font.Medium; color: Theme.surfaceText }
                        Item { width: 1; height: 1 }
                        StyledText { text: `${(ApplicationAudioService.outputDevices||[]).length} devices`; font.pixelSize: (Theme.fontSizeS || 12); color: Theme.surfaceText }
                    }

                    Column { width: parent.width; spacing: (Theme.spacingXS || 4)
                        Repeater {
                            model: ApplicationAudioService.outputDevices || []
                            delegate: Loader {
                                width: parent.width
                                sourceComponent: deviceVolumeRow
                                property var node: modelData
                                property bool isInput: false
                                height: item ? item.height : 56
                                onLoaded: { if (item) { item.node = node; item.isInput = isInput } }
                            }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: inputDevicesCol.implicitHeight + (Theme.spacingL || 16) * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.20)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
                border.width: 1

                Column {
                    id: inputDevicesCol
                    anchors.fill: parent
                    anchors.margins: (Theme.spacingL || 16)
                    spacing: (Theme.spacingS || 8)

                    Row { width: parent.width; spacing: (Theme.spacingS || 8)
                        StyledText { text: "Input Devices"; font.pixelSize: (Theme.fontSizeL || 18); font.weight: Font.Medium; color: Theme.surfaceText }
                        Item { width: 1; height: 1 }
                        StyledText { text: `${(ApplicationAudioService.inputDevices||[]).length} devices`; font.pixelSize: (Theme.fontSizeS || 12); color: Theme.surfaceText }
                    }

                    Column { width: parent.width; spacing: (Theme.spacingXS || 4)
                        Repeater {
                            model: ApplicationAudioService.inputDevices || []
                            delegate: Loader {
                                width: parent.width
                                sourceComponent: deviceVolumeRow
                                property var node: modelData
                                property bool isInput: true
                                height: item ? item.height : 56
                                onLoaded: { if (item) { item.node = node; item.isInput = isInput } }
                            }
                        }
                    }
                }
            }

            StyledText {
                text: "No applications with audio"
                font.pixelSize: (Theme.fontSizeS || 12)
                color: Theme.onSurfaceVariant
                anchors.horizontalCenter: parent.horizontalCenter
                visible: (ApplicationAudioService.applicationStreams || []).length === 0 && (ApplicationAudioService.applicationInputStreams || []).length === 0
            }
        }
    }

    Component {
        id: applicationVolumeControlRow

        Rectangle {
            id: rowRoot

            property var node: null
            property bool isInput: false

            height: 68
            radius: Theme.cornerRadius
            color: mouseArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.06) : Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.16)
            border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
            border.width: 1

            PwObjectTracker { objects: rowRoot.node ? [rowRoot.node] : [] }

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
                    width: parent.width - volumeSliderRow.width - Theme.spacingM
                    spacing: Theme.spacingXS
                    anchors.verticalCenter: parent.verticalCenter

                    StyledText {
                        text: rowRoot.node ? (rowRoot.node.name || "Unknown") : "Unknown"
                        font.pixelSize: Theme.fontSizeM
                        font.weight: Font.Medium
                        color: Theme.surfaceText
                        elide: Text.ElideRight
                        width: parent.width
                    }

                    StyledText {
                        text: rowRoot.isInput ? "Input" : "Output"
                        font.pixelSize: Theme.fontSizeS
                        color: Theme.surfaceVariantText
                    }
                }

                Row {
                    id: volumeSliderRow
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
                                if (rowRoot.node && rowRoot.node.audio) {
                                    rowRoot.node.audio.muted = !rowRoot.node.audio.muted
                                }
                            }
                        }

                        DarkIcon {
                            anchors.centerIn: parent
                            name: {
                                if (!rowRoot.node || !rowRoot.node.audio) return rowRoot.isInput ? "mic_off" : "volume_off"
                                const volume = rowRoot.node.audio.volume
                                const muted = rowRoot.node.audio.muted
                                if (rowRoot.isInput) {
                                    return (muted || volume === 0.0) ? "mic_off" : "mic"
                                } else {
                                    if (muted || volume === 0.0) return "volume_off"
                                    if (volume <= 0.33) return "volume_down"
                                    if (volume <= 0.66) return "volume_up"
                                    return "volume_up"
                                }
                            }
                            size: Theme.iconSize
                            color: rowRoot.node && rowRoot.node.audio && !rowRoot.node.audio.muted && rowRoot.node.audio.volume > 0 ? Theme.primary : Theme.surfaceText
                        }
                    }

                    DarkSlider {
                        readonly property real actualVolumePercent: rowRoot.node && rowRoot.node.audio ? Math.round(rowRoot.node.audio.volume * 100) : 0

                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - (Theme.iconSize + Theme.spacingS * 2) - Theme.spacingS
                        enabled: rowRoot.node !== null && rowRoot.node.audio !== null
                        minimum: 0
                        maximum: 100
                        value: rowRoot.node && rowRoot.node.audio ? Math.min(100, Math.round(rowRoot.node.audio.volume * 100)) : 0
                        showValue: true
                        unit: "%"
                        valueOverride: actualVolumePercent
                        onSliderValueChanged: function(newValue) {
                            if (rowRoot.node && rowRoot.node.audio) {
                                rowRoot.node.audio.volume = newValue / 100.0
                                if (newValue > 0 && rowRoot.node.audio.muted) {
                                    rowRoot.node.audio.muted = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: applicationRoutingSection

        Rectangle {
            property var node: null
            property bool isInput: false
            height: (Theme.iconSize || 24) + (Theme.spacingL || 16) * 2
            visible: false
        }
    }

    Component {
        id: deviceVolumeRow

        Rectangle {
            property var node: null
            property bool isInput: false
            height: 56
            visible: false
        }
    }
}
