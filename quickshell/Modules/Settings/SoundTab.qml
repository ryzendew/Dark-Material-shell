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

            // Header removed per request

            // Output applications
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

                        // Device routing sections for outputs
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

            // Input applications
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

                        // Device routing sections for inputs
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

            // Output Devices
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

            // Input Devices
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

            // No applications at all
            StyledText {
                text: "No applications with audio"
                font.pixelSize: (Theme.fontSizeS || 12)
                color: Theme.onSurfaceVariant
                anchors.horizontalCenter: parent.horizontalCenter
                visible: (ApplicationAudioService.applicationStreams || []).length === 0 && (ApplicationAudioService.applicationInputStreams || []).length === 0
            }
        }
    }

    // Application volume row styled like other settings lists
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
            MouseArea { id: mouseArea; anchors.fill: parent; hoverEnabled: true; onClicked: { /* no-op */ } }

            Row {
                anchors.fill: parent
                anchors.margins: (Theme.spacingM || 12)
                spacing: (Theme.spacingM || 12)

                CachingImage {
                    id: appIcon
                    width: (Theme.iconSize || 24)
                    height: (Theme.iconSize || 24)
                    maxCacheSize: (Theme.iconSize || 24)
                    source: {
                        const n = rowRoot.node
                        const props = n && n.properties ? n.properties : {}
                        const hintName = props["application.name"] || props["node.name"] || n?.name || ""
                        if (hintName && hintName !== "") {
                            const apps = AppSearchService.searchApplications(hintName)
                            if (apps && apps.length > 0 && apps[0].icon) {
                                return Quickshell.iconPath(apps[0].icon, true)
                            }
                        }
                        const pwIcon = ApplicationAudioService.getApplicationIconName(rowRoot.node)
                        return pwIcon && pwIcon !== "" ? `image://icon/${pwIcon}` : ""
                    }
                    fillMode: Image.PreserveAspectFit
                    visible: source !== ""
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    // Reserve space for device/app name so it doesn't collapse
                    width: 300
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    StyledText {
                        text: ApplicationAudioService.getApplicationName(rowRoot.node)
                        font.pixelSize: (Theme.fontSizeM || 16)
                        font.weight: Font.Medium
                        color: Theme.surfaceText
                        elide: Text.ElideRight
                        width: parent.width
                    }

                    StyledText {
                        text: isInput ? "Input" : "Output"
                        font.pixelSize: (Theme.fontSizeS || 12)
                        color: Theme.surfaceText
                        width: parent.width
                    }
                }

                // Controls row fills remaining width to the right
                Row {
                    id: appControlsRow
                    spacing: (Theme.spacingS || 8)
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.max(160,
                                     parent.width - appIcon.width - 300 - (Theme.spacingM || 12) * 3)

                    StyledText {
                        id: pctLabel
                        text: `${rowRoot.node && rowRoot.node.audio ? Math.round(rowRoot.node.audio.volume * 100) : 0}%`
                        font.pixelSize: (Theme.fontSizeS || 12)
                        color: Theme.surfaceText
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    DarkSlider {
                        id: slider
                        width: Math.max(80, appControlsRow.width - pctLabel.implicitWidth - 40 - (Theme.spacingS || 8) * 2)
                        enabled: rowRoot.node && rowRoot.node.audio
                        minimum: 0
                        maximum: 100
                        value: rowRoot.node && rowRoot.node.audio ? Math.round(rowRoot.node.audio.volume * 100) : 0
                        showValue: true
                        unit: "%"
                        thumbOutlineColor: Theme.surfaceContainer
                        trackColor: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, (Theme.getContentBackgroundAlpha ? Theme.getContentBackgroundAlpha() : 1) * 0.50)
                        anchors.verticalCenter: parent.verticalCenter
                        onSliderValueChanged: function(newValue) {
                            if (rowRoot.node && rowRoot.node.audio) {
                                rowRoot.node.audio.volume = Math.max(0, Math.min(100, newValue)) / 100
                            }
                        }
                    }

                    DarkActionButton {
                        buttonSize: 32
                        iconName: rowRoot.node && rowRoot.node.audio && rowRoot.node.audio.muted ? "volume_off" : (rowRoot.isInput ? "mic" : "volume_up")
                        iconSize: 18
                        iconColor: rowRoot.node && rowRoot.node.audio && rowRoot.node.audio.muted ? Theme.error : Theme.outline
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: { if (rowRoot.node && rowRoot.node.audio) { rowRoot.node.audio.muted = !rowRoot.node.audio.muted } }
                    }
                }
            }

            // routing UI moved to a separate section below the app row
        }
    }

    // Device volume row (similar layout but labeled as device)
    Component {
        id: deviceVolumeRow

        Rectangle {
            id: devRow

            property var node: null
            property bool isInput: false

            height: 65
            radius: Theme.cornerRadius
            color: mouseArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.06) : Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.16)
            border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
            border.width: 1

            PwObjectTracker { objects: devRow.node ? [devRow.node] : [] }
            MouseArea { id: mouseArea; anchors.fill: parent; hoverEnabled: true }

            Row {
                anchors.fill: parent
                anchors.margins: (Theme.spacingM || 12)
                spacing: (Theme.spacingM || 12)

                DarkIcon {
                    name: isInput ? "mic" : "volume_up"
                    size: (Theme.iconSize || 24)
                    color: Theme.surfaceText
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    width: 300
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    StyledText {
                        text: node && node.description ? node.description : (node && node.name ? node.name : "Audio Device")
                        font.pixelSize: (Theme.fontSizeM || 16)
                        font.weight: Font.Medium
                        color: Theme.surfaceText
                        elide: Text.ElideRight
                        width: parent.width
                    }

                    StyledText {
                        text: isInput ? "Input Device" : "Output Device"
                        font.pixelSize: (Theme.fontSizeS || 12)
                        color: Theme.surfaceVariantText
                        width: parent.width
                    }
                }

                Row {
                    id: devControlsRow
                    spacing: (Theme.spacingS || 8)
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.max(200,
                                     parent.width - (Theme.iconSize || 24) - 300 - (Theme.spacingM || 12) * 3)

                    StyledText {
                        text: `${devRow.node && devRow.node.audio ? Math.round(devRow.node.audio.volume * 100) : 0}%`
                        font.pixelSize: (Theme.fontSizeS || 12)
                        color: Theme.surfaceVariantText
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    DarkSlider {
                        width: Math.max(120, devControlsRow.width - 40 - (Theme.spacingS || 8) * 2 - (parent.children[0].implicitWidth || 36))
                        enabled: devRow.node && devRow.node.audio
                        minimum: 0
                        maximum: 100
                        value: devRow.node && devRow.node.audio ? Math.round(devRow.node.audio.volume * 100) : 0
                        showValue: true
                        unit: "%"
                        thumbOutlineColor: Theme.surfaceContainer
                        trackColor: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, (Theme.getContentBackgroundAlpha ? Theme.getContentBackgroundAlpha() : 1) * 0.50)
                        anchors.verticalCenter: parent.verticalCenter
                        onSliderValueChanged: function(newValue) {
                            if (devRow.node && devRow.node.audio) {
                                devRow.node.audio.volume = Math.max(0, Math.min(100, newValue)) / 100
                            }
                        }
                    }

                    DarkActionButton {
                        buttonSize: 32
                        iconName: devRow.node && devRow.node.audio && devRow.node.audio.muted ? "volume_off" : (devRow.isInput ? "mic" : "volume_up")
                        iconSize: 18
                        iconColor: devRow.node && devRow.node.audio && devRow.node.audio.muted ? Theme.error : Theme.outline
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: { if (devRow.node && devRow.node.audio) { devRow.node.audio.muted = !devRow.node.audio.muted } }
                    }
                }
            }
        }
    }

    // Per-application routing section shown as its own category card
    Component {
        id: applicationRoutingSection

        StyledRect {
            id: routeCard
            width: parent ? parent.width : 0
            height: routeRow.implicitHeight + (Theme.spacingL || 16) * 2
            radius: Theme.cornerRadius
            color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.20)
            border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
            border.width: 1

            property var node
            property bool isInput

            Row {
                id: routeRow
                anchors.fill: parent
                anchors.margins: (Theme.spacingL || 16)
                spacing: (Theme.spacingM || 12)

                CachingImage {
                    id: routeIcon
                    width: (Theme.iconSize || 24)
                    height: (Theme.iconSize || 24)
                    maxCacheSize: (Theme.iconSize || 24)
                    source: {
                        const n = routeCard.node
                        const props = n && n.properties ? n.properties : {}
                        const hintName = props["application.name"] || props["node.name"] || n?.name || ""
                        if (hintName && hintName !== "") {
                            const apps = AppSearchService.searchApplications(hintName)
                            if (apps && apps.length > 0 && apps[0].icon) {
                                return Quickshell.iconPath(apps[0].icon, true)
                            }
                        }
                        const pwIcon = ApplicationAudioService.getApplicationIconName(routeCard.node)
                        return pwIcon && pwIcon !== "" ? `image://icon/${pwIcon}` : ""
                    }
                    fillMode: Image.PreserveAspectFit
                    visible: source !== ""
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    width: 300
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    StyledText {
                        text: ApplicationAudioService.getApplicationName(routeCard.node)
                        font.pixelSize: (Theme.fontSizeM || 16)
                        font.weight: Font.Medium
                        color: Theme.surfaceText
                        elide: Text.ElideRight
                        width: parent.width
                    }

                    StyledText {
                        text: routeCard.isInput ? "Route input to device" : "Route output to device"
                        font.pixelSize: (Theme.fontSizeS || 12)
                        color: Theme.surfaceText
                        width: parent.width
                    }
                }

                Item { width: 1; height: 1 }

                DarkDropdown {
                    id: routeDropdown
                    width: 320
                    height: 44
                    text: routeCard.isInput ? "Input" : "Output"
                    description: ""
                    property var optionIds: (routeCard.isInput ? (ApplicationAudioService.inputDevices||[]) : (ApplicationAudioService.outputDevices||[])).map(d => d.id)
                    options: (routeCard.isInput ? (ApplicationAudioService.inputDevices||[]) : (ApplicationAudioService.outputDevices||[])).map(d => d.description || d.name || d.id)
                    currentValue: {
                        const appKey = (routeCard.node?.properties?.["application.name"]) || routeCard.node?.name || ""
                        const savedId = SettingsData.getAudioRoute(appKey, routeCard.isInput)
                        const ids = routeDropdown.optionIds
                        if (savedId) {
                            const idxSaved = ids.indexOf(savedId)
                            if (idxSaved >= 0) return routeDropdown.options[idxSaved]
                        }
                        const curId = (routeCard.node && (routeCard.node.audio?.deviceId || routeCard.node.audio?.target?.id || routeCard.node.audio?.device?.id || routeCard.node.deviceId)) || ""
                        const idx2 = curId ? ids.indexOf(curId) : -1
                        if (idx2 >= 0) return routeDropdown.options[idx2]
                        return routeDropdown.options[0] || ""
                    }
                    onValueChanged: function(value) {
                        const devs = routeCard.isInput ? (ApplicationAudioService.inputDevices||[]) : (ApplicationAudioService.outputDevices||[])
                        const idx = options.indexOf(value)
                        const dev = idx >= 0 ? devs[idx] : null
                        if (!dev || !routeCard.node) return
                        try {
                            if (routeCard.node.audio && routeCard.node.audio.setDevice) {
                                routeCard.node.audio.setDevice(dev)
                            } else if (routeCard.node.setDevice) {
                                routeCard.node.setDevice(dev)
                            } else if (routeCard.node.audio) {
                                routeCard.node.audio.target = dev
                            }
                            const appKey = (routeCard.node?.properties?.["application.name"]) || routeCard.node?.name || ""
                            if (appKey) SettingsData.setAudioRoute(appKey, routeDropdown.optionIds[idx], routeCard.isInput)
                        } catch (e) {
                            // ignore backend that doesn't support routing
                        }
                    }
                }
            }
        }
    }
}



