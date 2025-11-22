import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Modals.Common
import qs.Services
import qs.Widgets

DankModal {
    id: root

    property string connectionName: ""
    property string connectionUuid: ""
    property string connectionType: "" // wifi, ethernet, vpn, etc.
    
    // Connection settings
    property string currentIpv4Method: "auto"
    property string currentIpv4Address: ""
    property string currentIpv4Gateway: ""
    property string currentIpv6Method: "auto"
    property string currentIpv6Address: ""
    property string currentIpv6Gateway: ""
    property string currentDnsPrimary: ""
    property string currentDnsSecondary: ""
    property string currentMtu: ""
    property string currentMacAddress: ""
    
    property bool loading: true

    function show(connName, connUuid) {
        connectionName = connName || ""
        connectionUuid = connUuid || ""
        loading = true
        open()
        loadConnectionSettings()
    }

    shouldBeVisible: false
    width: 800
    height: 900
    positioning: "center"
    enableShadow: true
    
    onBackgroundClicked: () => {
        close()
    }

    content: Component {
        FocusScope {
            id: contentScope
            anchors.fill: parent
            focus: true
            
            Keys.onEscapePressed: event => {
                close()
                event.accepted = true
            }

            Column {
                anchors.fill: parent
                anchors.margins: Theme.spacingL
                spacing: Theme.spacingM

                // Header
                Row {
                    width: parent.width
                    spacing: Theme.spacingM

                    DankIcon {
                        name: "settings_ethernet"
                        size: Theme.iconSize
                        color: Theme.primary
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.spacingXS

                        StyledText {
                            text: "Edit Connection"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                        }

                        StyledText {
                            text: connectionName || "Unknown Connection"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            opacity: 0.7
                        }
                    }

                    Item { Layout.fillWidth: true }

                    DankActionButton {
                        iconName: "close"
                        iconSize: Theme.iconSize - 4
                        iconColor: Theme.surfaceText
                        onClicked: () => {
                            close()
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                }

                // Content
                DankFlickable {
                    width: parent.width
                    height: parent.height - 120
                    contentHeight: settingsColumn.implicitHeight
                    contentWidth: width
                    clip: true

                    Column {
                        id: settingsColumn
                        width: parent.width
                        spacing: Theme.spacingL

                        // Loading indicator
                        Rectangle {
                            width: parent.width
                            height: 200
                            color: "transparent"
                            visible: loading

                            Column {
                                anchors.centerIn: parent
                                spacing: Theme.spacingM

                                Item {
                                    width: 40
                                    height: 40
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    RotationAnimation on rotation {
                                        running: loading
                                        loops: Animation.Infinite
                                        duration: 1000
                                        from: 0
                                        to: 360
                                    }

                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 20
                                        color: Theme.primary
                                        opacity: 0.3
                                    }
                                }

                                StyledText {
                                    text: "Loading connection settings..."
                                    font.pixelSize: Theme.fontSizeMedium
                                    color: Theme.surfaceText
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }

                        // Settings sections (hidden while loading)
                        Column {
                            width: parent.width
                            spacing: Theme.spacingL
                            visible: !loading

                            // IPv4 Configuration
                            StyledRect {
                                width: parent.width
                                height: ipv4Column.implicitHeight + Theme.spacingL * 2
                                radius: Theme.cornerRadius
                                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                                border.width: 1

                                Column {
                                    id: ipv4Column
                                    anchors.fill: parent
                                    anchors.margins: Theme.spacingL
                                    spacing: Theme.spacingM

                                    StyledText {
                                        text: "IPv4 Configuration"
                                        font.pixelSize: Theme.fontSizeLarge
                                        font.weight: Font.Medium
                                        color: Theme.surfaceText
                                    }

                                    // IPv4 Method
                                    Row {
                                        width: parent.width
                                        spacing: Theme.spacingM

                                        StyledText {
                                            text: "Method:"
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Theme.surfaceText
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
                                                        color: {
                                                            const methods = ["auto", "manual", "link-local"]
                                                            return methods[index] === root.currentIpv4Method ? Theme.primary : "transparent"
                                                        }

                                                        StyledText {
                                                            anchors.centerIn: parent
                                                            text: modelData
                                                            font.pixelSize: Theme.fontSizeSmall
                                                            color: {
                                                                const methods = ["auto", "manual", "link-local"]
                                                                return methods[index] === root.currentIpv4Method ? Theme.onPrimary : Theme.surfaceText
                                                            }
                                                        }

                                                        MouseArea {
                                                            anchors.fill: parent
                                                            cursorShape: Qt.PointingHandCursor
                                                            onClicked: {
                                                                const methods = ["auto", "manual", "link-local"]
                                                                root.currentIpv4Method = methods[index]
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    // Static IP Settings
                                    Column {
                                        width: parent.width
                                        spacing: Theme.spacingS
                                        visible: root.currentIpv4Method === "manual"

                                        Row {
                                            width: parent.width
                                            spacing: Theme.spacingM

                                            StyledText {
                                                text: "IP Address:"
                                                font.pixelSize: Theme.fontSizeSmall
                                                color: Theme.surfaceText
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
                                                    id: editIpv4Address
                                                    anchors.fill: parent
                                                    anchors.margins: Theme.spacingS
                                                    font.pixelSize: Theme.fontSizeSmall
                                                    text: root.currentIpv4Address
                                                    placeholderText: "192.168.1.100/24"
                                                    background: Rectangle {
                                                        color: "transparent"
                                                    }
                                                }
                                            }
                                        }

                                        Row {
                                            width: parent.width
                                            spacing: Theme.spacingM

                                            StyledText {
                                                text: "Gateway:"
                                                font.pixelSize: Theme.fontSizeSmall
                                                color: Theme.surfaceText
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
                                                    id: editIpv4Gateway
                                                    anchors.fill: parent
                                                    anchors.margins: Theme.spacingS
                                                    font.pixelSize: Theme.fontSizeSmall
                                                    text: root.currentIpv4Gateway
                                                    placeholderText: "192.168.1.1"
                                                    background: Rectangle {
                                                        color: "transparent"
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // IPv6 Configuration
                            StyledRect {
                                width: parent.width
                                height: ipv6Column.implicitHeight + Theme.spacingL * 2
                                radius: Theme.cornerRadius
                                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                                border.width: 1

                                Column {
                                    id: ipv6Column
                                    anchors.fill: parent
                                    anchors.margins: Theme.spacingL
                                    spacing: Theme.spacingM

                                    StyledText {
                                        text: "IPv6 Configuration"
                                        font.pixelSize: Theme.fontSizeLarge
                                        font.weight: Font.Medium
                                        color: Theme.surfaceText
                                    }

                                    // IPv6 Method
                                    Row {
                                        width: parent.width
                                        spacing: Theme.spacingM

                                        StyledText {
                                            text: "Method:"
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Theme.surfaceText
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
                                                        color: {
                                                            const methods = ["auto", "manual", "ignore"]
                                                            return methods[index] === root.currentIpv6Method ? Theme.primary : "transparent"
                                                        }

                                                        StyledText {
                                                            anchors.centerIn: parent
                                                            text: modelData
                                                            font.pixelSize: Theme.fontSizeSmall
                                                            color: {
                                                                const methods = ["auto", "manual", "ignore"]
                                                                return methods[index] === root.currentIpv6Method ? Theme.onPrimary : Theme.surfaceText
                                                            }
                                                        }

                                                        MouseArea {
                                                            anchors.fill: parent
                                                            cursorShape: Qt.PointingHandCursor
                                                            onClicked: {
                                                                const methods = ["auto", "manual", "ignore"]
                                                                root.currentIpv6Method = methods[index]
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    // Static IPv6 Settings
                                    Column {
                                        width: parent.width
                                        spacing: Theme.spacingS
                                        visible: root.currentIpv6Method === "manual"

                                        Row {
                                            width: parent.width
                                            spacing: Theme.spacingM

                                            StyledText {
                                                text: "IPv6 Address:"
                                                font.pixelSize: Theme.fontSizeSmall
                                                color: Theme.surfaceText
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
                                                    id: editIpv6Address
                                                    anchors.fill: parent
                                                    anchors.margins: Theme.spacingS
                                                    font.pixelSize: Theme.fontSizeSmall
                                                    text: root.currentIpv6Address
                                                    placeholderText: "2001:db8::1/64"
                                                    background: Rectangle {
                                                        color: "transparent"
                                                    }
                                                }
                                            }
                                        }

                                        Row {
                                            width: parent.width
                                            spacing: Theme.spacingM

                                            StyledText {
                                                text: "Gateway:"
                                                font.pixelSize: Theme.fontSizeSmall
                                                color: Theme.surfaceText
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
                                                    id: editIpv6Gateway
                                                    anchors.fill: parent
                                                    anchors.margins: Theme.spacingS
                                                    font.pixelSize: Theme.fontSizeSmall
                                                    text: root.currentIpv6Gateway
                                                    placeholderText: "2001:db8::1"
                                                    background: Rectangle {
                                                        color: "transparent"
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // DNS Configuration
                            StyledRect {
                                width: parent.width
                                height: dnsEditColumn.implicitHeight + Theme.spacingL * 2
                                radius: Theme.cornerRadius
                                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                                border.width: 1

                                Column {
                                    id: dnsEditColumn
                                    anchors.fill: parent
                                    anchors.margins: Theme.spacingL
                                    spacing: Theme.spacingM

                                    StyledText {
                                        text: "DNS Configuration"
                                        font.pixelSize: Theme.fontSizeLarge
                                        font.weight: Font.Medium
                                        color: Theme.surfaceText
                                    }

                                    Row {
                                        width: parent.width
                                        spacing: Theme.spacingM

                                        StyledText {
                                            text: "Primary DNS:"
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Theme.surfaceText
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
                                                id: editDnsPrimary
                                                anchors.fill: parent
                                                anchors.margins: Theme.spacingS
                                                font.pixelSize: Theme.fontSizeSmall
                                                text: root.currentDnsPrimary
                                                placeholderText: "8.8.8.8"
                                                background: Rectangle {
                                                    color: "transparent"
                                                }
                                            }
                                        }
                                    }

                                    Row {
                                        width: parent.width
                                        spacing: Theme.spacingM

                                        StyledText {
                                            text: "Secondary DNS:"
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Theme.surfaceText
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
                                                id: editDnsSecondary
                                                anchors.fill: parent
                                                anchors.margins: Theme.spacingS
                                                font.pixelSize: Theme.fontSizeSmall
                                                text: root.currentDnsSecondary
                                                placeholderText: "8.8.4.4"
                                                background: Rectangle {
                                                    color: "transparent"
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // Advanced Settings
                            StyledRect {
                                width: parent.width
                                height: advancedEditColumn.implicitHeight + Theme.spacingL * 2
                                radius: Theme.cornerRadius
                                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                                border.width: 1

                                Column {
                                    id: advancedEditColumn
                                    anchors.fill: parent
                                    anchors.margins: Theme.spacingL
                                    spacing: Theme.spacingM

                                    StyledText {
                                        text: "Advanced Settings"
                                        font.pixelSize: Theme.fontSizeLarge
                                        font.weight: Font.Medium
                                        color: Theme.surfaceText
                                    }

                                    Row {
                                        width: parent.width
                                        spacing: Theme.spacingM

                                        StyledText {
                                            text: "MTU:"
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Theme.surfaceText
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
                                                id: editMtu
                                                anchors.fill: parent
                                                anchors.margins: Theme.spacingS
                                                font.pixelSize: Theme.fontSizeSmall
                                                text: root.currentMtu
                                                placeholderText: "1500"
                                                validator: IntValidator { bottom: 576; top: 9000 }
                                                background: Rectangle {
                                                    color: "transparent"
                                                }
                                            }
                                        }
                                    }

                                    Row {
                                        width: parent.width
                                        spacing: Theme.spacingM

                                        StyledText {
                                            text: "MAC Address:"
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Theme.surfaceText
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
                                                id: editMacAddress
                                                anchors.fill: parent
                                                anchors.margins: Theme.spacingS
                                                font.pixelSize: Theme.fontSizeSmall
                                                text: root.currentMacAddress
                                                placeholderText: "aa:bb:cc:dd:ee:ff"
                                                background: Rectangle {
                                                    color: "transparent"
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Footer buttons
                Row {
                    width: parent.width
                    spacing: Theme.spacingM
                    anchors.bottom: parent.bottom

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        width: 100
                        height: 36
                        radius: Theme.cornerRadius * 0.5
                        color: cancelMouseArea.containsMouse ? Theme.surfaceVariant : Theme.surfaceContainer

                        StyledText {
                            anchors.centerIn: parent
                            text: "Cancel"
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.surfaceText
                        }

                        MouseArea {
                            id: cancelMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                close()
                            }
                        }
                    }

                    Rectangle {
                        width: 100
                        height: 36
                        radius: Theme.cornerRadius * 0.5
                        color: saveMouseArea.containsMouse ? Theme.primaryContainer : Theme.primary

                        StyledText {
                            anchors.centerIn: parent
                            text: "Save"
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.onPrimary
                        }

                        MouseArea {
                            id: saveMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                saveConnectionSettings()
                            }
                        }
                    }
                }
            }
        }
    }

    // Load connection settings
    function loadConnectionSettings() {
        const connId = connectionUuid || connectionName
        if (!connId) {
            loading = false
            return
        }

        // Use -g all to get all properties, or use show without -g to get key:value format
        const cmd = connectionUuid ? ["nmcli", "connection", "show", "uuid", connId] : 
                                      ["nmcli", "connection", "show", "id", connId]
        
        loadSettingsProcess.command = lowPriorityCmd.concat(cmd)
        loadSettingsProcess.running = true
    }

    Process {
        id: loadSettingsProcess
        running: false
        command: []

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split('\n')
                const settings = {}
                
                lines.forEach(line => {
                    // Handle both "KEY: value" and "KEY = value" formats
                    let parts
                    if (line.includes(':')) {
                        parts = line.split(':')
                    } else if (line.includes('=')) {
                        parts = line.split('=')
                    } else {
                        return
                    }
                    
                    if (parts.length >= 2) {
                        const key = parts[0].trim()
                        const value = parts.slice(1).join(parts[0].includes(':') ? ':' : '=').trim()
                        settings[key] = value
                    }
                })

                // Parse IPv4 settings
                root.currentIpv4Method = settings["ipv4.method"] || settings["IP4.ADDRESS[1]"] ? "manual" : "auto"
                root.currentIpv4Address = settings["ipv4.addresses"] || settings["IP4.ADDRESS[1]"] || ""
                root.currentIpv4Gateway = settings["ipv4.gateway"] || settings["IP4.GATEWAY"] || ""

                // Parse IPv6 settings
                root.currentIpv6Method = settings["ipv6.method"] || settings["IP6.ADDRESS[1]"] ? "manual" : "auto"
                root.currentIpv6Address = settings["ipv6.addresses"] || settings["IP6.ADDRESS[1]"] || ""
                root.currentIpv6Gateway = settings["ipv6.gateway"] || settings["IP6.GATEWAY"] || ""

                // Parse DNS settings
                const dnsValue = settings["ipv4.dns"] || settings["IP4.DNS[1]"] || ""
                const dnsServers = dnsValue.split(/\s+/).filter(s => s)
                root.currentDnsPrimary = dnsServers[0] || ""
                root.currentDnsSecondary = dnsServers[1] || ""

                // Parse advanced settings
                root.currentMtu = settings["802-3-ethernet.mtu"] || settings["802-11-wireless.mtu"] || settings["GENERAL.MTU"] || ""
                root.currentMacAddress = settings["802-3-ethernet.cloned-mac-address"] || settings["802-11-wireless.cloned-mac-address"] || ""

                root.loading = false
            }
        }

        onExited: exitCode => {
            if (exitCode !== 0) {
                ToastService.showError("Failed to load connection settings")
                root.loading = false
            }
        }
    }

    // Save connection settings
    function saveConnectionSettings() {
        const connId = connectionUuid || connectionName
        if (!connId) {
            ToastService.showError("No connection specified")
            return
        }

        let cmd = ["nmcli", "connection", "modify", connId]

        // IPv4 settings
        cmd.push("ipv4.method", root.currentIpv4Method)
        if (root.currentIpv4Method === "manual") {
            if (editIpv4Address.text.trim()) {
                cmd.push("ipv4.addresses", editIpv4Address.text.trim())
            }
            if (editIpv4Gateway.text.trim()) {
                cmd.push("ipv4.gateway", editIpv4Gateway.text.trim())
            }
        }

        // IPv6 settings
        cmd.push("ipv6.method", root.currentIpv6Method)
        if (root.currentIpv6Method === "manual") {
            if (editIpv6Address.text.trim()) {
                cmd.push("ipv6.addresses", editIpv6Address.text.trim())
            }
            if (editIpv6Gateway.text.trim()) {
                cmd.push("ipv6.gateway", editIpv6Gateway.text.trim())
            }
        }

        // DNS settings
        const dnsServers = []
        if (editDnsPrimary.text.trim()) {
            dnsServers.push(editDnsPrimary.text.trim())
        }
        if (editDnsSecondary.text.trim()) {
            dnsServers.push(editDnsSecondary.text.trim())
        }
        cmd.push("ipv4.dns", dnsServers.join(" ") || "")

        // Advanced settings
        if (editMtu.text.trim()) {
            cmd.push("802-3-ethernet.mtu", editMtu.text.trim())
        }
        if (editMacAddress.text.trim()) {
            cmd.push("802-3-ethernet.cloned-mac-address", editMacAddress.text.trim())
        }

        saveSettingsProcess.command = lowPriorityCmd.concat(cmd)
        saveSettingsProcess.running = true
    }

    Process {
        id: saveSettingsProcess
        running: false
        command: []

        onExited: exitCode => {
            if (exitCode === 0) {
                ToastService.showInfo("Connection settings saved")
                close()
                // Refresh network state
                if (NetworkService) {
                    NetworkService.refreshNetworkState()
                }
            } else {
                ToastService.showError("Failed to save connection settings")
            }
        }
    }

    readonly property var lowPriorityCmd: ["nice", "-n", "19", "ionice", "-c3"]
}

