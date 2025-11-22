import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modals

Item {
    id: networkTab
    property var parentModal: null

    // DNS Configuration properties
    property bool dnsMethodAuto: true

    // IP Configuration properties
    property int ipv4MethodIndex: 0
    property int ipv6MethodIndex: 0

    // Proxy Configuration properties
    property int proxyMethodIndex: 0

    // Advanced Settings properties
    property int macAddressIndex: 0

    // Connection Edit Modal
    ConnectionEditModal {
        id: connectionEditModal
    }

    Component.onCompleted: {
        // Refresh network state when tab is opened
        if (NetworkService) {
            NetworkService.refreshNetworkState()
            if (NetworkService.wifiEnabled) {
                NetworkService.scanWifiNetworks()
            }
        }
    }

    DankFlickable {
        anchors.fill: parent
        anchors.topMargin: Theme.spacingL
        clip: true
        contentHeight: mainColumn.implicitHeight
        contentWidth: width

        Column {
            id: mainColumn
            width: parent.width
            spacing: Theme.spacingXL

            // WiFi Section
            StyledRect {
                width: parent.width
                height: wifiColumn.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: wifiColumn
                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    // Header
                    RowLayout {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "wifi"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "WiFi"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Item { Layout.fillWidth: true }

                        // WiFi Toggle
                        Rectangle {
                            width: 48
                            height: 28
                            radius: 14
                            color: NetworkService.wifiEnabled ? Theme.primary : Theme.surfaceVariant
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                width: 24
                                height: 24
                                radius: 12
                                color: "white"
                                anchors.verticalCenter: parent.verticalCenter
                                x: NetworkService.wifiEnabled ? 20 : 4

                                Behavior on x {
                                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    NetworkService.toggleWifiRadio()
                                }
                            }
                        }
                    }

                    // Current Connection Info
                    Rectangle {
                        width: parent.width
                        height: currentWifiInfo.visible ? currentWifiInfo.implicitHeight + Theme.spacingM * 2 : 0
                        radius: Theme.cornerRadius * 0.5
                        color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.5)
                        visible: NetworkService.wifiConnected && NetworkService.currentWifiSSID

                        Column {
                            id: currentWifiInfo
                            anchors.fill: parent
                            anchors.margins: Theme.spacingM
                            spacing: Theme.spacingS

                            Row {
                                width: parent.width
                                spacing: Theme.spacingS

                                StyledText {
                                    text: "Connected to:"
                                    font.pixelSize: Theme.fontSizeSmall
                                    opacity: 0.7
                                }

                                StyledText {
                                    text: NetworkService.currentWifiSSID || ""
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.weight: Font.Medium
                                    color: Theme.primary
                                }

                                StyledText {
                                    text: "Signal: " + NetworkService.wifiSignalStrength + "%"
                                    font.pixelSize: Theme.fontSizeSmall

                                }
                            }

                            Row {
                                width: parent.width
                                spacing: Theme.spacingM

                                StyledText {
                                    text: "IP: " + (NetworkService.wifiIP || "Not assigned")
                                    font.pixelSize: Theme.fontSizeSmall

                                }

                                Rectangle {
                                    width: 80
                                    height: 28
                                    radius: Theme.cornerRadius * 0.5
                                    color: Theme.errorContainer
                                    anchors.verticalCenter: parent.verticalCenter

                                    StyledText {
                                        anchors.centerIn: parent
                                        text: "Disconnect"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.onErrorContainer
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            NetworkService.disconnectWifi()
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Available Networks
                    Column {
                        width: parent.width
                        spacing: Theme.spacingS
                        visible: NetworkService.wifiEnabled

                        StyledText {
                            text: "Available Networks"
                            font.pixelSize: Theme.fontSizeMedium
                            font.weight: Font.Medium

                        }

                        Rectangle {
                            width: parent.width
                            height: 32
                            radius: Theme.cornerRadius * 0.5
                            color: Theme.primaryContainer
                            visible: NetworkService.isScanning

                            Row {
                                anchors.centerIn: parent
                                spacing: Theme.spacingS

                                Item {
                                    width: 16
                                    height: 16
                                    anchors.verticalCenter: parent.verticalCenter

                                    RotationAnimation on rotation {
                                        running: NetworkService.isScanning
                                        loops: Animation.Infinite
                                        duration: 1000
                                        from: 0
                                        to: 360
                                    }

                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 8
                                        color: Theme.onPrimaryContainer
                                        opacity: 0.3
                                    }
                                }

                                StyledText {
                                    text: "Scanning for networks..."
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.onPrimaryContainer
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }

                        // Network List
                        Column {
                            width: parent.width
                            spacing: Theme.spacingXS

                            Repeater {
                                model: NetworkService.wifiNetworks || []

                                Rectangle {
                                    width: parent.width
                                    height: 48
                                    radius: Theme.cornerRadius * 0.5
                                    color: networkMouseArea.containsMouse ? Theme.surfaceHover : Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.5)
                                    border.width: modelData.ssid === NetworkService.currentWifiSSID ? 2 : 0
                                    border.color: Theme.primary

                                    Row {
                                        anchors.fill: parent
                                        anchors.margins: Theme.spacingS
                                        spacing: Theme.spacingM

                                        // Security Icon
                                        DankIcon {
                                            name: modelData.secured ? "lock" : "lock_open"
                                            size: 20
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        // Network Info
                                        Column {
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: 2

                                            StyledText {
                                                text: modelData.ssid || "Unknown"
                                                font.pixelSize: Theme.fontSizeMedium
                                                font.weight: Font.Medium
                                            }

                                            Row {
                                                spacing: Theme.spacingXS

                                                // Signal Strength Bars
                                                Repeater {
                                                    model: 4
                                                    Rectangle {
                                                        width: 4
                                                        height: (index + 1) * 4
                                                        radius: 2
                                                        color: {
                                                            const strength = modelData.signal || 0
                                                            const threshold = (index + 1) * 25
                                                            return strength >= threshold ? Theme.primary : Theme.surfaceVariant
                                                        }
                                                        anchors.verticalCenter: parent.verticalCenter
                                                    }
                                                }

                                                StyledText {
                                                    text: modelData.signal ? modelData.signal + "%" : ""
                                                    font.pixelSize: Theme.fontSizeSmall
                                                    opacity: 0.7
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }
                                            }
                                        }

                                        // Connect Button
                                        Rectangle {
                                            width: 70
                                            height: 28
                                            radius: Theme.cornerRadius * 0.5
                                            color: modelData.ssid === NetworkService.currentWifiSSID ? Theme.primaryContainer : Theme.primary
                                            anchors.verticalCenter: parent.verticalCenter

                                            StyledText {
                                                anchors.centerIn: parent
                                                text: modelData.ssid === NetworkService.currentWifiSSID ? "Connected" : "Connect"
                                                font.pixelSize: Theme.fontSizeSmall
                                                color: modelData.ssid === NetworkService.currentWifiSSID ? Theme.onPrimaryContainer : Theme.onPrimary
                                            }

                                            MouseArea {
                                                id: networkMouseArea
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    if (modelData.ssid !== NetworkService.currentWifiSSID) {
                                                        // Trigger password dialog or connect if open
                                                        if (modelData.secured) {
                                                            // Show password dialog - need to access via shell or IPC
                                                            // For now, try to connect which will trigger password dialog
                                                            NetworkService.connectToWifi(modelData.ssid, "")
                                                        } else {
                                                            // Connect to open network
                                                            NetworkService.connectToWifi(modelData.ssid, "")
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            StyledText {
                                text: "No networks found"
                                font.pixelSize: Theme.fontSizeSmall
                                opacity: 0.5
                                anchors.horizontalCenter: parent.horizontalCenter
                                visible: !NetworkService.isScanning && (!NetworkService.wifiNetworks || NetworkService.wifiNetworks.length === 0)
                            }
                        }

                        // Refresh Button
                        Rectangle {
                            width: parent.width
                            height: 36
                            radius: Theme.cornerRadius * 0.5
                            color: refreshMouseArea.containsMouse ? Theme.surfaceHover : Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.5)

                            Row {
                                anchors.centerIn: parent
                                spacing: Theme.spacingS

                                DankIcon {
                                    name: "refresh"
                                    size: 18
                                    color: Theme.primary
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                StyledText {
                                    text: "Refresh"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.primary
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: refreshMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    NetworkService.scanWifiNetworks()
                                }
                            }
                        }
                    }

                    // Saved Networks
                    Column {
                        width: parent.width
                        spacing: Theme.spacingS
                        visible: NetworkService.wifiEnabled && NetworkService.savedWifiNetworks && NetworkService.savedWifiNetworks.length > 0

                        Item {
                            width: parent.width
                            height: Theme.spacingM
                        }

                        StyledText {
                            text: "Saved Networks"
                            font.pixelSize: Theme.fontSizeMedium
                            font.weight: Font.Medium

                        }

                        Column {
                            width: parent.width
                            spacing: Theme.spacingXS

                            Repeater {
                                model: NetworkService.savedWifiNetworks || []

                                Rectangle {
                                    width: parent.width
                                    height: 40
                                    radius: Theme.cornerRadius * 0.5
                                    color: savedNetworkMouseArea.containsMouse ? Theme.surfaceHover : Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.5)

                                    Row {
                                        anchors.fill: parent
                                        anchors.margins: Theme.spacingS
                                        spacing: Theme.spacingM

                                        DankIcon {
                                            name: "wifi"
                                            size: 18
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        StyledText {
                                            text: (typeof modelData === 'string' ? modelData : modelData.ssid) || "Unknown"
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Theme.surfaceText
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        Item { width: 1; height: 1 }

                                        Rectangle {
                                            width: 50
                                            height: 24
                                            radius: Theme.cornerRadius * 0.5
                                            color: Theme.primaryContainer
                                            anchors.verticalCenter: parent.verticalCenter

                                            StyledText {
                                                anchors.centerIn: parent
                                                text: "Edit"
                                                font.pixelSize: Theme.fontSizeSmall
                                                color: Theme.onPrimaryContainer
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    const ssid = typeof modelData === 'string' ? modelData : modelData.ssid
                                                    const connName = NetworkService.ssidToConnectionName[ssid] || ssid
                                                    connectionEditModal.show(connName, "")
                                                }
                                            }
                                        }

                                        Rectangle {
                                            width: 60
                                            height: 24
                                            radius: Theme.cornerRadius * 0.5
                                            color: Theme.errorContainer
                                            anchors.verticalCenter: parent.verticalCenter

                                            StyledText {
                                                anchors.centerIn: parent
                                                text: "Forget"
                                                font.pixelSize: Theme.fontSizeSmall
                                                color: Theme.onErrorContainer
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    const ssid = typeof modelData === 'string' ? modelData : modelData.ssid
                                                    NetworkService.forgetWifiNetwork(ssid)
                                                }
                                            }
                                        }
                                    }

                                    MouseArea {
                                        id: savedNetworkMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            // Connect to saved network
                                            const ssid = typeof modelData === 'string' ? modelData : modelData.ssid
                                            NetworkService.connectToWifi(ssid, "")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Ethernet Section (Placeholder for now)
            StyledRect {
                width: parent.width
                height: ethernetColumn.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: ethernetColumn
                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "cable"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Ethernet"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: ethernetInfo.visible ? ethernetInfo.implicitHeight + Theme.spacingM * 2 : 0
                        radius: Theme.cornerRadius * 0.5
                        color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.5)
                        visible: NetworkService.ethernetConnected

                        Column {
                            id: ethernetInfo
                            anchors.fill: parent
                            anchors.margins: Theme.spacingM
                            spacing: Theme.spacingS

                            Row {
                                width: parent.width
                                spacing: Theme.spacingM

                                StyledText {
                                    text: "Interface:"
                                    font.pixelSize: Theme.fontSizeSmall
                                    opacity: 0.7
                                }

                                StyledText {
                                    text: NetworkService.ethernetInterface || "Unknown"
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.weight: Font.Medium
                                    color: Theme.primary
                                }

                                StyledText {
                                    text: "IP: " + (NetworkService.ethernetIP || "Not assigned")
                                    font.pixelSize: Theme.fontSizeSmall

                                }
                            }

                            Row {
                                width: parent.width
                                spacing: Theme.spacingM
                                Item { width: 1; height: 1 }

                                Rectangle {
                                    width: 50
                                    height: 28
                                    radius: Theme.cornerRadius * 0.5
                                    color: Theme.primaryContainer
                                    anchors.verticalCenter: parent.verticalCenter

                                    StyledText {
                                        anchors.centerIn: parent
                                        text: "Edit"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.onPrimaryContainer
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (NetworkService.ethernetConnectionUuid) {
                                                connectionEditModal.show("", NetworkService.ethernetConnectionUuid)
                                            } else {
                                                // Try to find ethernet connection - use Process instead
                                                findEthernetConnection.running = true
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    width: 80
                                    height: 28
                                    radius: Theme.cornerRadius * 0.5
                                    color: Theme.errorContainer
                                    anchors.verticalCenter: parent.verticalCenter

                                    StyledText {
                                        anchors.centerIn: parent
                                        text: "Disconnect"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.onErrorContainer
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            NetworkService.toggleNetworkConnection("ethernet")
                                        }
                                    }
                                }
                            }
                        }
                    }

                    StyledText {
                        text: NetworkService.ethernetConnected ? "Ethernet connected" : "No ethernet connection"
                        font.pixelSize: Theme.fontSizeSmall
                        opacity: 0.7
                        visible: !NetworkService.ethernetConnected
                    }
                }
            }

            // VPN Section
            StyledRect {
                width: parent.width
                height: vpnColumn.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: vpnColumn
                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "vpn_key"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "VPN"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Item { width: 1; height: 1 }

                        // Add VPN Button
                        Rectangle {
                            width: 100
                            height: 32
                            radius: Theme.cornerRadius * 0.5
                            color: addVpnMouseArea.containsMouse ? Theme.primaryContainer : Theme.primary
                            anchors.verticalCenter: parent.verticalCenter

                            Row {
                                anchors.centerIn: parent
                                spacing: Theme.spacingXS

                                DankIcon {
                                    name: "add"
                                    size: 16
                                    color: Theme.onPrimary
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                StyledText {
                                    text: "Add VPN"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.onPrimary
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: addVpnMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    // TODO: Show VPN add dialog
                                    console.log("Add VPN clicked")
                                }
                            }
                        }
                    }

                    // Active VPN Connections
                    Column {
                        width: parent.width
                        spacing: Theme.spacingS
                        visible: VpnService && VpnService.activeConnections && VpnService.activeConnections.length > 0

                        StyledText {
                            text: "Active Connections"
                            font.pixelSize: Theme.fontSizeMedium
                            font.weight: Font.Medium

                        }

                        Repeater {
                            model: VpnService ? VpnService.activeConnections : []

                            Rectangle {
                                width: parent.width
                                height: 48
                                radius: Theme.cornerRadius * 0.5
                                color: Qt.rgba(Theme.primaryContainer.r, Theme.primaryContainer.g, Theme.primaryContainer.b, 0.5)
                                border.width: 2
                                border.color: Theme.primary

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: Theme.spacingS
                                    spacing: Theme.spacingM

                                    DankIcon {
                                        name: "vpn_key"
                                        size: 20
                                        color: Theme.primary
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 2

                                        StyledText {
                                            text: modelData.name || "Unknown"
                                            font.pixelSize: Theme.fontSizeMedium
                                            font.weight: Font.Medium

                                        }

                                        StyledText {
                                            text: "State: " + (modelData.state || "unknown")
                                            font.pixelSize: Theme.fontSizeSmall
                                            opacity: 0.7
                                        }
                                    }

                                    Rectangle {
                                        width: 80
                                        height: 28
                                        radius: Theme.cornerRadius * 0.5
                                        color: disconnectVpnMouseArea.containsMouse ? Theme.errorContainer : Theme.error
                                        anchors.verticalCenter: parent.verticalCenter

                                        StyledText {
                                            anchors.centerIn: parent
                                            text: "Disconnect"
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Theme.onError
                                        }

                                        MouseArea {
                                            id: disconnectVpnMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (VpnService) {
                                                    VpnService.disconnect(modelData.uuid || modelData.name)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // VPN Profiles List
                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "VPN Profiles"
                            font.pixelSize: Theme.fontSizeMedium
                            font.weight: Font.Medium

                        }

                        Column {
                            width: parent.width
                            spacing: Theme.spacingXS

                            Repeater {
                                model: VpnService ? VpnService.profiles : []

                                Rectangle {
                                    width: parent.width
                                    height: 48
                                    radius: Theme.cornerRadius * 0.5
                                    color: vpnProfileMouseArea.containsMouse ? Theme.surfaceHover : Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.5)
                                    border.width: VpnService && VpnService.isActiveUuid(modelData.uuid) ? 2 : 0
                                    border.color: Theme.primary

                                    Row {
                                        anchors.fill: parent
                                        anchors.margins: Theme.spacingS
                                        spacing: Theme.spacingM

                                        DankIcon {
                                            name: "vpn_key"
                                            size: 20
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        Column {
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: 2

                                            StyledText {
                                                text: modelData.name || "Unknown"
                                                font.pixelSize: Theme.fontSizeMedium
                                                font.weight: Font.Medium

                                            }

                                            Row {
                                                spacing: Theme.spacingXS

                                                StyledText {
                                                    text: modelData.type || "vpn"
                                                    font.pixelSize: Theme.fontSizeSmall
                                                    opacity: 0.7
                                                }

                                                StyledText {
                                                    text: modelData.serviceType ? " • " + modelData.serviceType : ""
                                                    font.pixelSize: Theme.fontSizeSmall
                                                    opacity: 0.7
                                                }
                                            }
                                        }

                                        Item { width: 1; height: 1 }

                                        Rectangle {
                                            width: 50
                                            height: 28
                                            radius: Theme.cornerRadius * 0.5
                                            color: Theme.primaryContainer
                                            anchors.verticalCenter: parent.verticalCenter

                                            StyledText {
                                                anchors.centerIn: parent
                                                text: "Edit"
                                                font.pixelSize: Theme.fontSizeSmall
                                                color: Theme.onPrimaryContainer
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    const modal = getConnectionEditModal()
                                                    if (modal) {
                                                        modal.show(modelData.name, modelData.uuid)
                                                    }
                                                }
                                            }
                                        }

                                        Rectangle {
                                            width: 70
                                            height: 28
                                            radius: Theme.cornerRadius * 0.5
                                            color: VpnService && VpnService.isActiveUuid(modelData.uuid) ? Theme.primaryContainer : Theme.primary
                                            anchors.verticalCenter: parent.verticalCenter

                                            StyledText {
                                                anchors.centerIn: parent
                                                text: VpnService && VpnService.isActiveUuid(modelData.uuid) ? "Connected" : "Connect"
                                                font.pixelSize: Theme.fontSizeSmall
                                                color: VpnService && VpnService.isActiveUuid(modelData.uuid) ? Theme.onPrimaryContainer : Theme.onPrimary
                                            }

                                            MouseArea {
                                                id: vpnProfileMouseArea
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    if (VpnService) {
                                                        if (VpnService.isActiveUuid(modelData.uuid)) {
                                                            VpnService.disconnect(modelData.uuid)
                                                        } else {
                                                            VpnService.connect(modelData.uuid)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            StyledText {
                                text: "No VPN profiles configured"
                                font.pixelSize: Theme.fontSizeSmall
                                opacity: 0.5
                                anchors.horizontalCenter: parent.horizontalCenter
                                visible: !VpnService || !VpnService.profiles || VpnService.profiles.length === 0
                            }
                        }
                    }
                }
            }

            // DNS Configuration Section
            StyledRect {
                width: parent.width
                height: dnsColumn.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: dnsColumn
                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "dns"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "DNS Configuration"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    // DNS Method Toggle
                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        StyledText {
                            text: "DNS Method:"
                            font.pixelSize: Theme.fontSizeMedium
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Rectangle {
                            width: 200
                            height: 32
                            radius: Theme.cornerRadius * 0.5
                            color: Theme.surfaceContainer
                            anchors.verticalCenter: parent.verticalCenter

                            Row {
                                anchors.fill: parent
                                anchors.margins: 2

                                Rectangle {
                                    width: parent.width / 2
                                    height: parent.height
                                    radius: Theme.cornerRadius * 0.5
                                    color: networkTab.dnsMethodAuto ? Theme.primary : "transparent"

                                    StyledText {
                                        anchors.centerIn: parent
                                        text: "Automatic"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: networkTab.dnsMethodAuto ? Theme.onPrimary : Theme.surfaceText
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            networkTab.dnsMethodAuto = true
                                            // TODO: Apply DNS method
                                        }
                                    }
                                }

                                Rectangle {
                                    width: parent.width / 2
                                    height: parent.height
                                    radius: Theme.cornerRadius * 0.5
                                    color: !networkTab.dnsMethodAuto ? Theme.primary : "transparent"

                                    StyledText {
                                        anchors.centerIn: parent
                                        text: "Manual"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: !networkTab.dnsMethodAuto ? Theme.onPrimary : Theme.surfaceText
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            networkTab.dnsMethodAuto = false
                                        }
                                    }
                                }
                            }
                        }

                        Item { width: 1; height: 1 }
                    }

                    // Manual DNS Servers
                    Column {
                        width: parent.width
                        spacing: Theme.spacingS
                        visible: !networkTab.dnsMethodAuto

                        StyledText {
                            text: "DNS Servers"
                            font.pixelSize: Theme.fontSizeMedium
                            font.weight: Font.Medium

                        }

                        // Primary DNS
                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: "Primary:"
                                font.pixelSize: Theme.fontSizeSmall
                                width: 80
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                width: parent.width - 80 - Theme.spacingM
                                height: 32
                                radius: Theme.cornerRadius * 0.5
                                color: Theme.surfaceContainer
                                border.width: 1
                                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                                anchors.verticalCenter: parent.verticalCenter

                                TextField {
                                    id: primaryDnsInput
                                    anchors.fill: parent
                                    anchors.margins: Theme.spacingS
                                    font.pixelSize: Theme.fontSizeSmall
                                    placeholderText: "8.8.8.8"
                                    background: Rectangle {
                                        color: "transparent"
                                    }

                        }

                        // Secondary DNS
                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: "Secondary:"
                                font.pixelSize: Theme.fontSizeSmall
                                width: 80
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                width: parent.width - 80 - Theme.spacingM
                                height: 32
                                radius: Theme.cornerRadius * 0.5
                                color: Theme.surfaceContainer
                                border.width: 1
                                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                                anchors.verticalCenter: parent.verticalCenter

                                TextField {
                                    id: secondaryDnsInput
                                    anchors.fill: parent
                                    anchors.margins: Theme.spacingS
                                    font.pixelSize: Theme.fontSizeSmall
                                    placeholderText: "8.8.4.4"
                                    background: Rectangle {
                                        color: "transparent"
                                    }

                        }

                        // DNS Presets
                        Row {
                            width: parent.width
                            spacing: Theme.spacingS

                            StyledText {
                                text: "Presets:"
                                font.pixelSize: Theme.fontSizeSmall
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Repeater {
                                model: [
                                    { name: "Cloudflare", primary: "1.1.1.1", secondary: "1.0.0.1" },
                                    { name: "Google", primary: "8.8.8.8", secondary: "8.8.4.4" },
                                    { name: "Quad9", primary: "9.9.9.9", secondary: "149.112.112.112" },
                                    { name: "OpenDNS", primary: "208.67.222.222", secondary: "208.67.220.220" }
                                ]

                                Rectangle {
                                    width: 80
                                    height: 28
                                    radius: Theme.cornerRadius * 0.5
                                    color: dnsPresetMouseArea.containsMouse ? Theme.primaryContainer : Theme.surfaceContainer
                                    anchors.verticalCenter: parent.verticalCenter

                                    StyledText {
                                        anchors.centerIn: parent
                                        text: modelData.name
                                        font.pixelSize: Theme.fontSizeSmall

                                    }

                                    MouseArea {
                                        id: dnsPresetMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            primaryDnsInput.text = modelData.primary
                                            secondaryDnsInput.text = modelData.secondary
                                            // TODO: Apply DNS settings
                                        }
                                    }
                                }
                            }
                        }

                        // Apply Button
                        Rectangle {
                            width: 100
                            height: 32
                            radius: Theme.cornerRadius * 0.5
                            color: applyDnsMouseArea.containsMouse ? Theme.primaryContainer : Theme.primary
                            anchors.right: parent.right

                            StyledText {
                                anchors.centerIn: parent
                                text: "Apply"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.onPrimary
                            }

                            MouseArea {
                                id: applyDnsMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (primaryDnsInput.text.trim()) {
                                        NetworkService.setDnsServers("", primaryDnsInput.text.trim(), secondaryDnsInput.text.trim())
                                    } else {
                                        // Reset to automatic
                                        const connectionName = NetworkService.networkStatus === "wifi" ? NetworkService.wifiConnectionUuid :
                                                               NetworkService.networkStatus === "ethernet" ? NetworkService.ethernetConnectionUuid : ""
                                        if (connectionName) {
                                            Quickshell.execDetached(["nmcli", "connection", "modify", connectionName, "ipv4.dns", "", "ipv4.dns-search", ""])
                                            ToastService.showInfo("DNS reset to automatic")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // IPv4/IPv6 Configuration Section
            StyledRect {
                width: parent.width
                height: ipConfigColumn.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: ipConfigColumn
                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "settings_ethernet"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "IP Configuration"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    // IPv4 Configuration
                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "IPv4"
                            font.pixelSize: Theme.fontSizeMedium
                            font.weight: Font.Medium

                        }

                        // IPv4 Method
                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: "Method:"
                                font.pixelSize: Theme.fontSizeSmall
                                width: 100
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                width: 200
                                height: 32
                                radius: Theme.cornerRadius * 0.5
                                color: Theme.surfaceContainer
                                anchors.verticalCenter: parent.verticalCenter

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 2

                                    Repeater {
                                        model: ["Automatic", "Manual", "Link-Local"]

                                        Rectangle {
                                            width: parent.width / 3
                                            height: parent.height
                                            radius: Theme.cornerRadius * 0.5
                                            color: networkTab.ipv4MethodIndex === index ? Theme.primary : "transparent"

                                            StyledText {
                                                anchors.centerIn: parent
                                                text: modelData
                                                font.pixelSize: Theme.fontSizeSmall
                                                color: networkTab.ipv4MethodIndex === index ? Theme.onPrimary : Theme.surfaceText
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    networkTab.ipv4MethodIndex = index
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Item { width: 1; height: 1 }
                        }

                        // Static IP Settings (when Manual selected)
                        Column {
                            width: parent.width
                            spacing: Theme.spacingS
                            visible: networkTab.ipv4MethodIndex === 1

                            Row {
                                width: parent.width
                                spacing: Theme.spacingM

                                StyledText {
                                    text: "IP Address:"
                                    font.pixelSize: Theme.fontSizeSmall
                                    width: 100
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Rectangle {
                                    width: parent.width - 100 - Theme.spacingM
                                    height: 32
                                    radius: Theme.cornerRadius * 0.5
                                    color: Theme.surfaceContainer
                                    border.width: 1
                                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                                    anchors.verticalCenter: parent.verticalCenter

                                    TextField {
                                        id: ipv4AddressInput
                                        anchors.fill: parent
                                        anchors.margins: Theme.spacingS
                                        font.pixelSize: Theme.fontSizeSmall
                                        placeholderText: "192.168.1.100/24"
                                        background: Rectangle {
                                            color: "transparent"
                                        }

                            }

                            Row {
                                width: parent.width
                                spacing: Theme.spacingM

                                StyledText {
                                    text: "Gateway:"
                                    font.pixelSize: Theme.fontSizeSmall
                                    width: 100
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Rectangle {
                                    width: parent.width - 100 - Theme.spacingM
                                    height: 32
                                    radius: Theme.cornerRadius * 0.5
                                    color: Theme.surfaceContainer
                                    border.width: 1
                                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                                    anchors.verticalCenter: parent.verticalCenter

                                    TextField {
                                        id: ipv4GatewayInput
                                        anchors.fill: parent
                                        anchors.margins: Theme.spacingS
                                        font.pixelSize: Theme.fontSizeSmall
                                        placeholderText: "192.168.1.1"
                                    background: Rectangle {
                                        color: "transparent"
                                    }

                            }

                            // Apply IPv4 Button
                            Rectangle {
                                width: 100
                                height: 32
                                radius: Theme.cornerRadius * 0.5
                                color: applyIpv4MouseArea.containsMouse ? Theme.primaryContainer : Theme.primary
                                anchors.right: parent.right

                                StyledText {
                                    anchors.centerIn: parent
                                    text: "Apply"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.onPrimary
                                }

                                MouseArea {
                                    id: applyIpv4MouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        const method = networkTab.ipv4MethodIndex === 0 ? "auto" :
                                                      networkTab.ipv4MethodIndex === 1 ? "manual" : "link-local"
                                        const address = networkTab.ipv4MethodIndex === 1 ? ipv4AddressInput.text.trim() : ""
                                        const gateway = networkTab.ipv4MethodIndex === 1 ? ipv4GatewayInput.text.trim() : ""
                                        NetworkService.setIpv4Config("", method, address, gateway)
                                    }
                                }
                            }
                        }
                    }

                    // IPv6 Configuration
                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        Item {
                            width: parent.width
                            height: Theme.spacingM
                        }

                        StyledText {
                            text: "IPv6"
                            font.pixelSize: Theme.fontSizeMedium
                            font.weight: Font.Medium

                        }

                        // IPv6 Method
                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: "Method:"
                                font.pixelSize: Theme.fontSizeSmall
                                width: 100
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                width: 200
                                height: 32
                                radius: Theme.cornerRadius * 0.5
                                color: Theme.surfaceContainer
                                anchors.verticalCenter: parent.verticalCenter

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 2

                                    Repeater {
                                        model: ["Automatic", "Manual", "Ignore"]

                                        Rectangle {
                                            width: parent.width / 3
                                            height: parent.height
                                            radius: Theme.cornerRadius * 0.5
                                            color: networkTab.ipv6MethodIndex === index ? Theme.primary : "transparent"

                                            StyledText {
                                                anchors.centerIn: parent
                                                text: modelData
                                                font.pixelSize: Theme.fontSizeSmall
                                                color: networkTab.ipv6MethodIndex === index ? Theme.onPrimary : Theme.surfaceText
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    networkTab.ipv6MethodIndex = index
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Item { width: 1; height: 1 }
                        }

                        // Static IPv6 Settings (when Manual selected)
                        Column {
                            width: parent.width
                            spacing: Theme.spacingS
                            visible: networkTab.ipv6MethodIndex === 1

                            Row {
                                width: parent.width
                                spacing: Theme.spacingM

                                StyledText {
                                    text: "IPv6 Address:"
                                    font.pixelSize: Theme.fontSizeSmall
                                    width: 100
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Rectangle {
                                    width: parent.width - 100 - Theme.spacingM
                                    height: 32
                                    radius: Theme.cornerRadius * 0.5
                                    color: Theme.surfaceContainer
                                    border.width: 1
                                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                                    anchors.verticalCenter: parent.verticalCenter

                                    TextField {
                                        id: ipv6AddressInput
                                        anchors.fill: parent
                                        anchors.margins: Theme.spacingS
                                        font.pixelSize: Theme.fontSizeSmall
                                        placeholderText: "2001:db8::1/64"
                                        background: Rectangle {
                                            color: "transparent"
                                        }

                            }

                            Row {
                                width: parent.width
                                spacing: Theme.spacingM

                                StyledText {
                                    text: "Gateway:"
                                    font.pixelSize: Theme.fontSizeSmall
                                    width: 100
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Rectangle {
                                    width: parent.width - 100 - Theme.spacingM
                                    height: 32
                                    radius: Theme.cornerRadius * 0.5
                                    color: Theme.surfaceContainer
                                    border.width: 1
                                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                                    anchors.verticalCenter: parent.verticalCenter

                                    TextField {
                                        id: ipv6GatewayInput
                                        anchors.fill: parent
                                        anchors.margins: Theme.spacingS
                                        font.pixelSize: Theme.fontSizeSmall
                                        placeholderText: "2001:db8::1"
                                        background: Rectangle {
                                            color: "transparent"
                                        }

                            }

                            // Apply IPv6 Button
                            Rectangle {
                                width: 100
                                height: 32
                                radius: Theme.cornerRadius * 0.5
                                color: applyIpv6MouseArea.containsMouse ? Theme.primaryContainer : Theme.primary
                                anchors.right: parent.right

                                StyledText {
                                    anchors.centerIn: parent
                                    text: "Apply"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.onPrimary
                                }

                                MouseArea {
                                    id: applyIpv6MouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        const method = networkTab.ipv6MethodIndex === 0 ? "auto" :
                                                      networkTab.ipv6MethodIndex === 1 ? "manual" : "ignore"
                                        const address = networkTab.ipv6MethodIndex === 1 ? ipv6AddressInput.text.trim() : ""
                                        const gateway = networkTab.ipv6MethodIndex === 1 ? ipv6GatewayInput.text.trim() : ""
                                        NetworkService.setIpv6Config("", method, address, gateway)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Proxy Configuration Section
            StyledRect {
                width: parent.width
                height: proxyColumn.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: proxyColumn
                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "settings_ethernet"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Proxy Configuration"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    // Proxy Method
                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        StyledText {
                            text: "Proxy Method:"
                            font.pixelSize: Theme.fontSizeMedium
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Rectangle {
                            width: 250
                            height: 32
                            radius: Theme.cornerRadius * 0.5
                            color: Theme.surfaceContainer
                            anchors.verticalCenter: parent.verticalCenter

                            Row {
                                anchors.fill: parent
                                anchors.margins: 2

                                Repeater {
                                    model: ["None", "Manual", "Automatic"]

                                    Rectangle {
                                        width: parent.width / 3
                                        height: parent.height
                                        radius: Theme.cornerRadius * 0.5
                                            color: networkTab.proxyMethodIndex === index ? Theme.primary : "transparent"

                                            StyledText {
                                                anchors.centerIn: parent
                                                text: modelData
                                                font.pixelSize: Theme.fontSizeSmall
                                                color: networkTab.proxyMethodIndex === index ? Theme.onPrimary : Theme.surfaceText
                                        }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    networkTab.proxyMethodIndex = index
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Item { width: 1; height: 1 }
                        }

                        // Manual Proxy Settings
                        Column {
                            width: parent.width
                            spacing: Theme.spacingS
                            visible: networkTab.proxyMethodIndex === 1

                        StyledText {
                            text: "Proxy Servers"
                            font.pixelSize: Theme.fontSizeMedium
                            font.weight: Font.Medium

                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: "HTTP Proxy:"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                width: 120
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                width: parent.width - 120 - Theme.spacingM
                                height: 32
                                radius: Theme.cornerRadius * 0.5
                                color: Theme.surfaceContainer
                                border.width: 1
                                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                                anchors.verticalCenter: parent.verticalCenter

                                TextField {
                                    id: httpProxyInput
                                    anchors.fill: parent
                                    anchors.margins: Theme.spacingS
                                    font.pixelSize: Theme.fontSizeSmall
                                    placeholderText: "proxy.example.com:8080"
                                    background: Rectangle {
                                        color: "transparent"
                                    }

                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: "HTTPS Proxy:"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                width: 120
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                width: parent.width - 120 - Theme.spacingM
                                height: 32
                                radius: Theme.cornerRadius * 0.5
                                color: Theme.surfaceContainer
                                border.width: 1
                                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                                anchors.verticalCenter: parent.verticalCenter

                                TextField {
                                    id: httpsProxyInput
                                    anchors.fill: parent
                                    anchors.margins: Theme.spacingS
                                    font.pixelSize: Theme.fontSizeSmall
                                    placeholderText: "proxy.example.com:8080"
                                    background: Rectangle {
                                        color: "transparent"
                                    }

                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: "FTP Proxy:"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                width: 120
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                width: parent.width - 120 - Theme.spacingM
                                height: 32
                                radius: Theme.cornerRadius * 0.5
                                color: Theme.surfaceContainer
                                border.width: 1
                                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                                anchors.verticalCenter: parent.verticalCenter

                                TextField {
                                    id: ftpProxyInput
                                    anchors.fill: parent
                                    anchors.margins: Theme.spacingS
                                    font.pixelSize: Theme.fontSizeSmall
                                    placeholderText: "proxy.example.com:8080"
                                    background: Rectangle {
                                        color: "transparent"
                                    }

                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: "SOCKS Proxy:"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                width: 120
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                width: parent.width - 120 - Theme.spacingM
                                height: 32
                                radius: Theme.cornerRadius * 0.5
                                color: Theme.surfaceContainer
                                border.width: 1
                                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                                anchors.verticalCenter: parent.verticalCenter

                                TextField {
                                    id: socksProxyInput
                                    anchors.fill: parent
                                    anchors.margins: Theme.spacingS
                                    font.pixelSize: Theme.fontSizeSmall
                                    placeholderText: "proxy.example.com:1080"
                                    background: Rectangle {
                                        color: "transparent"
                                    }

                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: "No Proxy For:"
                                font.pixelSize: Theme.fontSizeSmall
                                width: 120
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                width: parent.width - 120 - Theme.spacingM
                                height: 32
                                radius: Theme.cornerRadius * 0.5
                                color: Theme.surfaceContainer
                                border.width: 1
                                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                                anchors.verticalCenter: parent.verticalCenter

                                TextField {
                                    id: noProxyInput
                                    anchors.fill: parent
                                    anchors.margins: Theme.spacingS
                                    font.pixelSize: Theme.fontSizeSmall
                                    placeholderText: "localhost,127.0.0.1,*.local"
                                background: Rectangle {
                                    color: "transparent"
                                }

                        }
                    }

                    // Automatic Proxy Settings
                    Column {
                        width: parent.width
                        spacing: Theme.spacingS
                        visible: networkTab.proxyMethodIndex === 2

                        StyledText {
                            text: "Automatic Proxy Configuration"
                            font.pixelSize: Theme.fontSizeMedium
                            font.weight: Font.Medium

                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: "PAC URL:"
                                font.pixelSize: Theme.fontSizeSmall
                                width: 100
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                width: parent.width - 100 - Theme.spacingM
                                height: 32
                                radius: Theme.cornerRadius * 0.5
                                color: Theme.surfaceContainer
                                border.width: 1
                                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                                anchors.verticalCenter: parent.verticalCenter

                                TextField {
                                    id: pacUrlInput
                                    anchors.fill: parent
                                    anchors.margins: Theme.spacingS
                                    font.pixelSize: Theme.fontSizeSmall
                                    placeholderText: "http://proxy.example.com/proxy.pac"
                                background: Rectangle {
                                    color: "transparent"
                                }

                        }

                        // Apply Proxy Button
                        Rectangle {
                            width: 100
                            height: 32
                            radius: Theme.cornerRadius * 0.5
                            color: applyProxyMouseArea.containsMouse ? Theme.primaryContainer : Theme.primary
                            anchors.right: parent.right

                            StyledText {
                                anchors.centerIn: parent
                                text: "Apply"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.onPrimary
                            }

                            MouseArea {
                                id: applyProxyMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    const method = networkTab.proxyMethodIndex === 0 ? "none" :
                                                  networkTab.proxyMethodIndex === 1 ? "manual" : "auto"

                                    if (method === "manual") {
                                        NetworkService.setProxyConfig("", method,
                                            httpProxyInput.text.trim(),
                                            httpsProxyInput.text.trim(),
                                            ftpProxyInput.text.trim(),
                                            socksProxyInput.text.trim(),
                                            noProxyInput.text.trim())
                                    } else {
                                        NetworkService.setProxyConfig("", method, "", "", "", "", "")
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Advanced Settings Section
            StyledRect {
                width: parent.width
                height: advancedColumn.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: advancedColumn
                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "tune"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Advanced Settings"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    // MTU Configuration
                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: "MTU:"
                                font.pixelSize: Theme.fontSizeSmall
                                width: 100
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                width: 120
                                height: 32
                                radius: Theme.cornerRadius * 0.5
                                color: Theme.surfaceContainer
                                border.width: 1
                                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                                anchors.verticalCenter: parent.verticalCenter

                                TextField {
                                    id: mtuInput
                                    anchors.fill: parent
                                    anchors.margins: Theme.spacingS
                                    font.pixelSize: Theme.fontSizeSmall
                                    placeholderText: "1500"
                                    validator: IntValidator { bottom: 576; top: 9000 }
                                }
                            }

                            StyledText {
                                text: "(576-9000, default: 1500)"
                                font.pixelSize: Theme.fontSizeSmall
                                opacity: 0.7
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Item { width: 1; height: 1 }
                        }

                        // Apply MTU Button
                        Rectangle {
                            width: 100
                            height: 32
                            radius: Theme.cornerRadius * 0.5
                            color: applyMtuMouseArea.containsMouse ? Theme.primaryContainer : Theme.primary
                            anchors.right: parent.right

                            StyledText {
                                anchors.centerIn: parent
                                text: "Apply"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.onPrimary
                            }

                            MouseArea {
                                id: applyMtuMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (mtuInput.text.trim()) {
                                        const mtu = parseInt(mtuInput.text.trim())
                                        if (mtu >= 576 && mtu <= 9000) {
                                            NetworkService.setMtu("", mtu)
                                        } else {
                                            ToastService.showError("MTU must be between 576 and 9000")
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // MAC Address Configuration
                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        Item {
                            width: parent.width
                            height: Theme.spacingS
                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: "MAC Address:"
                                font.pixelSize: Theme.fontSizeSmall
                                width: 100
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                width: 200
                                height: 32
                                radius: Theme.cornerRadius * 0.5
                                color: Theme.surfaceContainer
                                anchors.verticalCenter: parent.verticalCenter

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 2

                                    Repeater {
                                        model: ["Default", "Cloned"]

                                        Rectangle {
                                            width: parent.width / 2
                                            height: parent.height
                                            radius: Theme.cornerRadius * 0.5
                                            color: networkTab.macAddressIndex === index ? Theme.primary : "transparent"

                                            StyledText {
                                                anchors.centerIn: parent
                                                text: modelData
                                                font.pixelSize: Theme.fontSizeSmall
                                                color: networkTab.macAddressIndex === index ? Theme.onPrimary : Theme.surfaceText
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    networkTab.macAddressIndex = index
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Item { width: 1; height: 1 }
                        }

                        // Cloned MAC Input
                        Row {
                            width: parent.width
                            spacing: Theme.spacingM
                            visible: networkTab.macAddressIndex === 1

                            StyledText {
                                text: "Cloned MAC:"
                                font.pixelSize: Theme.fontSizeSmall
                                width: 100
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                width: parent.width - 100 - Theme.spacingM
                                height: 32
                                radius: Theme.cornerRadius * 0.5
                                color: Theme.surfaceContainer
                                border.width: 1
                                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                                anchors.verticalCenter: parent.verticalCenter

                                TextField {
                                    id: clonedMacInput
                                    anchors.fill: parent
                                    anchors.margins: Theme.spacingS
                                    font.pixelSize: Theme.fontSizeSmall
                                    placeholderText: "aa:bb:cc:dd:ee:ff"
                                background: Rectangle {
                                    color: "transparent"
                                }

                        }

                        // Apply MAC Button
                        Rectangle {
                            width: 100
                            height: 32
                            radius: Theme.cornerRadius * 0.5
                            color: applyMacMouseArea.containsMouse ? Theme.primaryContainer : Theme.primary
                            anchors.right: parent.right

                            StyledText {
                                anchors.centerIn: parent
                                text: "Apply"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.onPrimary
                            }

                            MouseArea {
                                id: applyMacMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (networkTab.macAddressIndex === 0) {
                                        // Default MAC
                                        NetworkService.setClonedMac("", "")
                                    } else if (networkTab.macAddressIndex === 1 && clonedMacInput.text.trim()) {
                                        // Cloned MAC
                                        NetworkService.setClonedMac("", clonedMacInput.text.trim())
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Process to find ethernet connection for editing
    Process {
        id: findEthernetConnection
        running: false
        command: ["bash", "-c",
            "ETH_CONN=$(nmcli -t -f NAME,UUID connection show | grep ':802-3-ethernet$' | cut -d: -f1 | head -1); " +
            "ETH_UUID=$(nmcli -t -f NAME,UUID connection show | grep ':802-3-ethernet$' | cut -d: -f2 | head -1); " +
            "if [ -n \"$ETH_CONN\" ]; then echo \"$ETH_CONN:$ETH_UUID\"; fi"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(':')
                if (parts.length >= 2) {
                    connectionEditModal.show(parts[0], parts[1])
                }
            }
        }
    }
}

