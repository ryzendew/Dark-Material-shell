import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: root

    property bool showInputs: true
    property bool showOutputs: true

    implicitHeight: mainColumn.implicitHeight
    width: parent.width

    Connections {
        target: typeof ApplicationAudioService !== "undefined" ? ApplicationAudioService : null
        function onStreamsChanged() {
            outputStreamsRepeater.model = ApplicationAudioService.applicationStreams || []
            inputStreamsRepeater.model = ApplicationAudioService.applicationInputStreams || []
        }
        function onApplicationVolumeChanged() {
            outputStreamsRepeater.model = ApplicationAudioService.applicationStreams || []
        }
    }

    Connections {
        target: typeof Pipewire !== "undefined" && Pipewire.nodes ? Pipewire.nodes : null
        function onValuesChanged() {
            Qt.callLater(() => {
                outputStreamsRepeater.model = ApplicationAudioService.applicationStreams || []
                inputStreamsRepeater.model = ApplicationAudioService.applicationInputStreams || []
            })
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            outputStreamsRepeater.model = ApplicationAudioService.applicationStreams || []
            inputStreamsRepeater.model = ApplicationAudioService.applicationInputStreams || []
        }
    }

    Column {
        id: mainColumn
        width: parent.width
        spacing: Theme.spacingL

        // Output Applications Section
        StyledRect {
            width: parent.width
            height: outputSection.implicitHeight + Theme.spacingL * 2
            radius: Theme.cornerRadius
            color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
            border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
            border.width: 1
            visible: root.showOutputs

            Column {
                id: outputSection
                anchors.fill: parent
                anchors.margins: Theme.spacingL
                spacing: Theme.spacingM

                Row {
                    width: parent.width
                    spacing: Theme.spacingM

                    DarkIcon {
                        name: "volume_up"
                        size: Theme.iconSize
                        color: Theme.primary
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    StyledText {
                        text: "Output Applications"
                        font.pixelSize: Theme.fontSizeLarge
                        font.weight: Font.Medium
                        color: Theme.surfaceText
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Repeater {
                    id: outputStreamsRepeater
                    model: ApplicationAudioService.applicationStreams || []

                    delegate: StyledRect {
                        required property var modelData

                        width: parent.width
                        height: appRow.implicitHeight + deviceRow.implicitHeight + Theme.spacingM * 2
                        radius: Theme.cornerRadius
                        color: mouseArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.08) : Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.2)
                        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
                        border.width: 1

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                if (!modelData || !modelData.audio) return
                                if (ApplicationAudioService.isNodeReadyForVolumeControl && ApplicationAudioService.isNodeReadyForVolumeControl(modelData)) {
                                    ApplicationAudioService.toggleApplicationMute(modelData)
                                }
                            }
                        }

                        Column {
                            anchors.fill: parent
                            anchors.margins: Theme.spacingM
                            spacing: Theme.spacingS

                            Row {
                                id: appRow
                                width: parent.width
                                spacing: Theme.spacingM

                                DarkIcon {
                                    id: appIcon
                                    name: ApplicationAudioService.getApplicationIcon(modelData)
                                    size: Theme.iconSize
                                    color: modelData && modelData.audio && !modelData.audio.muted && modelData.audio.volume > 0 ? Theme.primary : Theme.surfaceText
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - appIcon.width - volumeSlider.width - Theme.spacingM * 3
                                    spacing: Theme.spacingXS

                                    StyledText {
                                        text: ApplicationAudioService.getApplicationName(modelData)
                                        font.pixelSize: Theme.fontSizeMedium
                                        color: Theme.surfaceText
                                        elide: Text.ElideRight
                                        width: parent.width
                                    }

                                    StyledText {
                                        text: {
                                            const device = ApplicationAudioService.getCurrentOutputDevice(modelData)
                                            return device ? (device.description || device.name || "Default") : "Default"
                                        }
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                        elide: Text.ElideRight
                                        width: parent.width
                                    }
                                }

                                DarkSlider {
                                    id: volumeSlider
                                    width: 140
                                    height: 32
                                    enabled: ApplicationAudioService.isNodeReadyForVolumeControl ? ApplicationAudioService.isNodeReadyForVolumeControl(modelData) : (modelData && modelData.audio && modelData.ready === true)
                                    minimum: 0
                                    maximum: 100
                                    value: {
                                        if (!modelData || !modelData.audio) return 0
                                        const vol = modelData.audio.volume
                                        return typeof vol === "number" && !isNaN(vol) ? Math.round(vol * 100) : 0
                                    }
                                    showValue: true
                                    unit: "%"
                                    anchors.verticalCenter: parent.verticalCenter

                                    onSliderValueChanged: function(newValue) {
                                        if (modelData && modelData.audio && ApplicationAudioService.isNodeReadyForVolumeControl && ApplicationAudioService.isNodeReadyForVolumeControl(modelData)) {
                                            ApplicationAudioService.setApplicationVolume(modelData, newValue)
                                        }
                                    }
                                }
                            }

                            Row {
                                id: deviceRow
                                width: parent.width
                                spacing: Theme.spacingS
                                visible: (ApplicationAudioService.outputDevices || []).length > 1

                                StyledText {
                                    text: "Output Device:"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 110
                                }

                                DarkDropdown {
                                    width: parent.width - 110 - Theme.spacingS
                                    text: "Select Output Device"
                                    options: {
                                        const devices = ApplicationAudioService.outputDevices || []
                                        return devices.map(device => device.description || device.name || "Unknown Device")
                                    }
                                    currentValue: {
                                        const currentDevice = ApplicationAudioService.getCurrentOutputDevice(modelData)
                                        return currentDevice ? (currentDevice.description || currentDevice.name || "Default") : "Default"
                                    }
                                    onValueChanged: function(selectedValue) {
                                        const devices = ApplicationAudioService.outputDevices || []
                                        const selectedDevice = devices.find(device => (device.description || device.name) === selectedValue)
                                        if (selectedDevice && modelData) {
                                            ApplicationAudioService.routeStreamToOutput(modelData, selectedDevice)
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            width: 4
                            height: parent.height
                            radius: 2
                            color: modelData && modelData.audio && modelData.audio.muted ? Theme.error : "transparent"
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.leftMargin: 2
                        }
                    }
                }

                StyledText {
                    text: "No applications with audio output"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    visible: (ApplicationAudioService.applicationStreams || []).length === 0
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }

        // Input Applications Section
        StyledRect {
            width: parent.width
            height: inputSection.implicitHeight + Theme.spacingL * 2
            radius: Theme.cornerRadius
            color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
            border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
            border.width: 1
            visible: root.showInputs

            Column {
                id: inputSection
                anchors.fill: parent
                anchors.margins: Theme.spacingL
                spacing: Theme.spacingM

                Row {
                    width: parent.width
                    spacing: Theme.spacingM

                    DarkIcon {
                        name: "mic"
                        size: Theme.iconSize
                        color: Theme.primary
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    StyledText {
                        text: "Input Applications"
                        font.pixelSize: Theme.fontSizeLarge
                        font.weight: Font.Medium
                        color: Theme.surfaceText
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Repeater {
                    id: inputStreamsRepeater
                    model: ApplicationAudioService.applicationInputStreams || []

                    delegate: StyledRect {
                        required property var modelData

                        width: parent.width
                        height: appRow.implicitHeight + deviceRow.implicitHeight + Theme.spacingM * 2
                        radius: Theme.cornerRadius
                        color: mouseArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.08) : Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.2)
                        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
                        border.width: 1

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                if (!modelData || !modelData.audio) return
                                if (ApplicationAudioService.isNodeReadyForVolumeControl && ApplicationAudioService.isNodeReadyForVolumeControl(modelData)) {
                                    ApplicationAudioService.toggleApplicationInputMute(modelData)
                                }
                            }
                        }

                        Column {
                            anchors.fill: parent
                            anchors.margins: Theme.spacingM
                            spacing: Theme.spacingS

                            Row {
                                id: appRow
                                width: parent.width
                                spacing: Theme.spacingM

                                DarkIcon {
                                    id: appIcon
                                    name: ApplicationAudioService.getApplicationIcon(modelData)
                                    size: Theme.iconSize
                                    color: modelData && modelData.audio && !modelData.audio.muted && modelData.audio.volume > 0 ? Theme.primary : Theme.surfaceText
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - appIcon.width - volumeSlider.width - Theme.spacingM * 3
                                    spacing: Theme.spacingXS

                                    StyledText {
                                        text: ApplicationAudioService.getApplicationName(modelData)
                                        font.pixelSize: Theme.fontSizeMedium
                                        color: Theme.surfaceText
                                        elide: Text.ElideRight
                                        width: parent.width
                                    }

                                    StyledText {
                                        text: {
                                            const device = ApplicationAudioService.getCurrentInputDevice(modelData)
                                            return device ? (device.description || device.name || "Default") : "Default"
                                        }
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                        elide: Text.ElideRight
                                        width: parent.width
                                    }
                                }

                                DarkSlider {
                                    id: volumeSlider
                                    width: 140
                                    height: 32
                                    enabled: ApplicationAudioService.isNodeReadyForVolumeControl ? ApplicationAudioService.isNodeReadyForVolumeControl(modelData) : (modelData && modelData.audio && modelData.ready === true)
                                    minimum: 0
                                    maximum: 100
                                    value: {
                                        if (!modelData || !modelData.audio) return 0
                                        const vol = modelData.audio.volume
                                        return typeof vol === "number" && !isNaN(vol) ? Math.round(vol * 100) : 0
                                    }
                                    showValue: true
                                    unit: "%"
                                    anchors.verticalCenter: parent.verticalCenter

                                    onSliderValueChanged: function(newValue) {
                                        if (modelData && modelData.audio && ApplicationAudioService.isNodeReadyForVolumeControl && ApplicationAudioService.isNodeReadyForVolumeControl(modelData)) {
                                            ApplicationAudioService.setApplicationInputVolume(modelData, newValue)
                                        }
                                    }
                                }
                            }

                            Row {
                                id: deviceRow
                                width: parent.width
                                spacing: Theme.spacingS
                                visible: (ApplicationAudioService.inputDevices || []).length > 1

                                StyledText {
                                    text: "Input Device:"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 110
                                }

                                DarkDropdown {
                                    width: parent.width - 110 - Theme.spacingS
                                    text: "Select Input Device"
                                    options: {
                                        const devices = ApplicationAudioService.inputDevices || []
                                        return devices.map(device => device.description || device.name || "Unknown Device")
                                    }
                                    currentValue: {
                                        const currentDevice = ApplicationAudioService.getCurrentInputDevice(modelData)
                                        return currentDevice ? (currentDevice.description || currentDevice.name || "Default") : "Default"
                                    }
                                    onValueChanged: function(selectedValue) {
                                        const devices = ApplicationAudioService.inputDevices || []
                                        const selectedDevice = devices.find(device => (device.description || device.name) === selectedValue)
                                        if (selectedDevice && modelData) {
                                            ApplicationAudioService.routeStreamToInput(modelData, selectedDevice)
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            width: 4
                            height: parent.height
                            radius: 2
                            color: modelData && modelData.audio && modelData.audio.muted ? Theme.error : "transparent"
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.leftMargin: 2
                        }
                    }
                }

                StyledText {
                    text: "No applications with audio input"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    visible: (ApplicationAudioService.applicationInputStreams || []).length === 0
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}
