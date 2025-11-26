import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Widgets
import qs.Services

Item {
    id: powerTab

    function formatTime(seconds) {
        if (seconds <= 0) return "Never"
        const hours = Math.floor(seconds / 3600)
        const minutes = Math.floor((seconds % 3600) / 60)
        if (hours > 0) {
            return hours + "h " + minutes + "m"
        }
        return minutes + "m"
    }

    function secondsFromTimeString(timeStr) {
        if (!timeStr || timeStr === "Never") return 0
        const parts = timeStr.split(" ")
        let total = 0
        for (let i = 0; i < parts.length; i++) {
            if (parts[i].endsWith("h")) {
                total += parseInt(parts[i]) * 3600
            } else if (parts[i].endsWith("m")) {
                total += parseInt(parts[i]) * 60
            }
        }
        return total
    }

    Component.onCompleted: {
        PowerService.refreshStatus()
    }

    Connections {
        target: PowerService
        function onLastErrorChanged() {
            if (PowerService.lastError && PowerService.lastError.length > 0) {
            }
        }
    }

    DarkFlickable {
        anchors.fill: parent
        anchors.topMargin: Theme.spacingL
        clip: true
        contentHeight: mainColumn.height
        contentWidth: width

        Column {
            id: mainColumn

            width: parent.width
            spacing: Theme.spacingXL

            StyledRect {
                width: parent.width
                height: batterySection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1
                visible: BatteryService.batteryAvailable

                Column {
                    id: batterySection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: BatteryService.getBatteryIcon()
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingM
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: "Battery Status"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: BatteryService.batteryLevel + "% - " + BatteryService.batteryStatus
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.surfaceVariantText
                            }

                            StyledText {
                                text: "Time remaining: " + BatteryService.formatTimeRemaining()
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                visible: BatteryService.formatTimeRemaining() !== "Unknown"
                            }

                            StyledText {
                                text: "Health: " + BatteryService.batteryHealth
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                visible: BatteryService.batteryHealth !== "N/A"
                            }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: profilesSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1
                visible: PowerService.hasPowerProfiles

                Column {
                    id: profilesSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "tune"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Power Profile"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    StyledText {
                        text: "Choose a power profile to balance performance and energy consumption"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }

                    DarkDropdown {
                        width: parent.width
                        height: 50
                        text: "Power Profile"
                        description: "Current: " + (PowerService.powerProfile || "balanced")
                        currentValue: PowerService.powerProfile || "balanced"
                        options: PowerService.availableProfiles.length > 0 ? PowerService.availableProfiles : ["performance", "balanced", "power-saver"]
                        onValueChanged: value => {
                            if (value && value !== PowerService.powerProfile) {
                                PowerService.setPowerProfile(value)
                            }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: buttonActionsSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: buttonActionsSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "power_settings_new"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Button Actions"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    StyledText {
                        text: "Configure what happens when you press hardware buttons"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }

                    DarkDropdown {
                        width: parent.width
                        height: 50
                        text: "Power Button"
                        description: "Action when power button is pressed"
                        currentValue: PowerService.powerButtonAction || "poweroff"
                        options: ["poweroff", "reboot", "suspend", "hibernate", "ignore", "kexec", "halt"]
                        onValueChanged: value => {
                            if (value && value !== PowerService.powerButtonAction) {
                                PowerService.setPowerButtonAction(value)
                            }
                        }
                    }

                    DarkDropdown {
                        width: parent.width
                        height: 50
                        text: "Sleep Button"
                        description: "Action when sleep button is pressed"
                        currentValue: PowerService.sleepButtonAction || "suspend"
                        options: ["suspend", "hibernate", "ignore"]
                        onValueChanged: value => {
                            if (value && value !== PowerService.sleepButtonAction) {
                                PowerService.setSleepButtonAction(value)
                            }
                        }
                    }

                    DarkDropdown {
                        width: parent.width
                        height: 50
                        text: "Hibernate Button"
                        description: "Action when hibernate button is pressed"
                        currentValue: PowerService.hibernateButtonAction || "hibernate"
                        options: ["hibernate", "suspend", "ignore"]
                        visible: PowerService.hibernateSupported
                        onValueChanged: value => {
                            if (value && value !== PowerService.hibernateButtonAction) {
                                PowerService.setHibernateButtonAction(value)
                            }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: lidActionsSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1
                visible: PowerService.lidSwitchAvailable

                Column {
                    id: lidActionsSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "laptop"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Lid Close Actions"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    StyledText {
                        text: "Configure what happens when you close the laptop lid"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }

                    DarkDropdown {
                        width: parent.width
                        height: 50
                        text: "When Lid is Closed (On Battery)"
                        description: "Action when lid is closed while on battery"
                        currentValue: PowerService.lidCloseAction || "suspend"
                        options: ["suspend", "hibernate", "lock", "ignore", "poweroff", "reboot", "kexec", "halt"]
                        onValueChanged: value => {
                            if (value && value !== PowerService.lidCloseAction) {
                                PowerService.setLidCloseAction(value)
                            }
                        }
                    }

                    DarkDropdown {
                        width: parent.width
                        height: 50
                        text: "When Lid is Closed (Plugged In)"
                        description: "Action when lid is closed while plugged in"
                        currentValue: PowerService.lidCloseExternalPowerAction || "suspend"
                        options: ["suspend", "hibernate", "lock", "ignore", "poweroff", "reboot", "kexec", "halt"]
                        onValueChanged: value => {
                            if (value && value !== PowerService.lidCloseExternalPowerAction) {
                                PowerService.setLidCloseExternalPowerAction(value)
                            }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: sleepTimersSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: sleepTimersSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "bedtime"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Sleep & Hibernate Timers"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    StyledText {
                        text: "Automatically suspend or hibernate the system after inactivity"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        Column {
                            width: parent.width / 2 - Theme.spacingM / 2
                            spacing: Theme.spacingXS

                            StyledText {
                                text: "Suspend After"
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.surfaceText
                            }

                            DarkDropdown {
                                width: parent.width
                                height: 50
                                text: "Select Time"
                                description: formatTime(PowerService.idleSleepTimeout)
                                currentValue: formatTime(PowerService.idleSleepTimeout)
                                options: ["Never", "5m", "10m", "15m", "30m", "1h", "2h", "3h", "6h"]
                                onValueChanged: value => {
                                    const seconds = secondsFromTimeString(value)
                                    PowerService.setIdleSleepTimeout(seconds)
                                }
                            }
                        }

                        Column {
                            width: parent.width / 2 - Theme.spacingM / 2
                            spacing: Theme.spacingXS

                            StyledText {
                                text: "Hibernate After"
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.surfaceText
                            }

                            DarkDropdown {
                                width: parent.width
                                height: 50
                                text: "Select Time"
                                description: formatTime(PowerService.idleHibernateTimeout)
                                currentValue: formatTime(PowerService.idleHibernateTimeout)
                                options: ["Never", "15m", "30m", "1h", "2h", "3h", "6h", "12h"]
                                visible: PowerService.hibernateSupported
                                onValueChanged: value => {
                                    const seconds = secondsFromTimeString(value)
                                    PowerService.setIdleHibernateTimeout(seconds)
                                }
                            }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: displayTimersSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: displayTimersSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "desktop_windows"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Display Timers"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    StyledText {
                        text: "Configure when the screen dims and turns off"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        Column {
                            width: parent.width / 2 - Theme.spacingM / 2
                            spacing: Theme.spacingXS

                            StyledText {
                                text: "Screen Dim After"
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.surfaceText
                            }

                            DarkDropdown {
                                width: parent.width
                                height: 50
                                text: "Select Time"
                                description: formatTime(PowerService.screenDimTimeout)
                                currentValue: formatTime(PowerService.screenDimTimeout)
                                options: ["Never", "1m", "2m", "5m", "10m", "15m", "30m", "1h"]
                                onValueChanged: value => {
                                    const seconds = secondsFromTimeString(value)
                                    PowerService.setScreenDimTimeout(seconds)
                                }
                            }
                        }

                        Column {
                            width: parent.width / 2 - Theme.spacingM / 2
                            spacing: Theme.spacingXS

                            StyledText {
                                text: "Screen Off After"
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.surfaceText
                            }

                            DarkDropdown {
                                width: parent.width
                                height: 50
                                text: "Select Time"
                                description: formatTime(PowerService.screenOffTimeout)
                                currentValue: formatTime(PowerService.screenOffTimeout)
                                options: ["Never", "5m", "10m", "15m", "20m", "30m", "1h", "2h"]
                                onValueChanged: value => {
                                    const seconds = secondsFromTimeString(value)
                                    PowerService.setScreenOffTimeout(seconds)
                                }
                            }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: batterySettingsSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1
                visible: BatteryService.batteryAvailable

                Column {
                    id: batterySettingsSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "battery_charging_full"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Battery Settings"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    StyledText {
                        text: "Configure actions when battery levels are low"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        Column {
                            width: parent.width / 2 - Theme.spacingM / 2
                            spacing: Theme.spacingXS

                            StyledText {
                                text: "Low Battery Threshold"
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.surfaceText
                            }

                            DarkSlider {
                                id: lowBatterySlider
                                width: parent.width
                                minimum: 5
                                maximum: 30
                                value: Math.round(PowerService.lowBatteryThreshold / 5) * 5
                                onSliderValueChanged: newValue => {
                                    const steppedValue = Math.round(newValue / 5) * 5
                                    PowerService.lowBatteryThreshold = steppedValue
                                }
                            }

                            StyledText {
                                text: PowerService.lowBatteryThreshold + "%"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                            }
                        }

                        Column {
                            width: parent.width / 2 - Theme.spacingM / 2
                            spacing: Theme.spacingXS

                            StyledText {
                                text: "Critical Battery Threshold"
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.surfaceText
                            }

                            DarkSlider {
                                width: parent.width
                                minimum: 1
                                maximum: 10
                                value: PowerService.criticalBatteryThreshold
                                onSliderValueChanged: newValue => {
                                    PowerService.criticalBatteryThreshold = newValue
                                }
                            }

                            StyledText {
                                text: PowerService.criticalBatteryThreshold + "%"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                            }
                        }
                    }

                    DarkDropdown {
                        width: parent.width
                        height: 50
                        text: "Low Battery Action"
                        description: "Action when battery reaches low threshold"
                        currentValue: PowerService.lowBatteryAction || "suspend"
                        options: ["suspend", "hibernate", "ignore", "poweroff", "reboot", "kexec", "halt"]
                        onValueChanged: value => {
                            if (value && value !== PowerService.lowBatteryAction) {
                                PowerService.lowBatteryAction = value
                            }
                        }
                    }

                    DarkDropdown {
                        width: parent.width
                        height: 50
                        text: "Critical Battery Action"
                        description: "Action when battery reaches critical threshold"
                        currentValue: PowerService.criticalBatteryAction || "hibernate"
                        options: ["suspend", "hibernate", "ignore", "poweroff", "reboot", "kexec", "halt"]
                        onValueChanged: value => {
                            if (value && value !== PowerService.criticalBatteryAction) {
                                PowerService.criticalBatteryAction = value
                            }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: errorSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r,
                               Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.2)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.1)
                border.width: 1
                visible: PowerService.lastError && PowerService.lastError.length > 0

                Column {
                    id: errorSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingM
                    spacing: Theme.spacingXS

                    StyledText {
                        text: "Error: " + PowerService.lastError
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.error
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                }
            }
        }
    }
}


