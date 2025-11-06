import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Widgets
import qs.Services

Item {
    id: timeTab

    property var filteredTimezones: []
    property string timezoneSearchText: ""

    Component.onCompleted: {
        TimeService.refreshStatus()
        TimeService.listTimezones()
        // Initialize filtered list
        filteredTimezones = TimeService.availableTimezones
    }

    Connections {
        target: TimeService
        function onAvailableTimezonesChanged() {
            updateFilteredTimezones()
        }
        function onCurrentTimezoneChanged() {
            SettingsData.setSystemTimezone(TimeService.currentTimezone)
        }
    }

    function updateFilteredTimezones() {
        if (!timezoneSearchText || timezoneSearchText.length === 0) {
            filteredTimezones = TimeService.availableTimezones
        } else {
            const search = timezoneSearchText.toLowerCase()
            filteredTimezones = TimeService.availableTimezones.filter(tz => {
                return tz.toLowerCase().includes(search)
            })
        }
    }

    Timer {
        id: timeRefreshTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            // Refresh time display every second
        }
    }

    DankFlickable {
        anchors.fill: parent
        anchors.topMargin: Theme.spacingL
        clip: true
        contentHeight: mainColumn.height
        contentWidth: width

        Column {
            id: mainColumn

            width: parent.width
            spacing: Theme.spacingXL

            // Current Time Display
            StyledRect {
                width: parent.width
                height: currentTimeSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: currentTimeSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "access_time"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingM
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: "Current Time"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: TimeService.localTime || new Date().toLocaleString(Qt.locale(), Locale.LongFormat)
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.surfaceVariantText
                            }

                            StyledText {
                                text: "UTC: " + (TimeService.universalTime || "")
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                visible: TimeService.universalTime && TimeService.universalTime.length > 0
                            }
                        }
                    }
                }
            }

            // Timezone Section
            StyledRect {
                width: parent.width
                height: timezoneSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: timezoneSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "public"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingM
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: "Timezone"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Select your system timezone"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                            }
                        }
                    }

                    DankTextField {
                        id: timezoneSearchField
                        width: parent.width
                        placeholderText: "Search timezone (e.g., America, Europe, Asia)"
                        text: timezoneSearchText
                        onTextChanged: {
                            timezoneSearchText = text
                            updateFilteredTimezones()
                        }
                    }

                    DankDropdown {
                        width: parent.width
                        height: 50
                        text: "Select Timezone"
                        description: "Current: " + (TimeService.currentTimezone || "Loading...")
                        currentValue: TimeService.currentTimezone || ""
                        enableFuzzySearch: true
                        options: filteredTimezones.length > 0 ? filteredTimezones : (TimeService.availableTimezones.length > 0 ? TimeService.availableTimezones : ["Loading timezones..."])
                        onValueChanged: value => {
                            if (value && value !== TimeService.currentTimezone && value !== "Loading timezones...") {
                                TimeService.setTimezone(value)
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: timezoneInfo.implicitHeight + Theme.spacingM * 2
                        radius: Theme.cornerRadius
                        color: Qt.rgba(Theme.surfaceVariant.r,
                                       Theme.surfaceVariant.g,
                                       Theme.surfaceVariant.b, 0.2)
                        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                              Theme.outline.b, 0.1)
                        border.width: 1
                        visible: TimeService.lastError && TimeService.lastError.length > 0

                        Column {
                            id: timezoneInfo

                            anchors.fill: parent
                            anchors.margins: Theme.spacingM
                            spacing: Theme.spacingXS

                            StyledText {
                                text: "Error: " + TimeService.lastError
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.error
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }
                    }
                }
            }

            // NTP Synchronization Section
            StyledRect {
                width: parent.width
                height: ntpSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: ntpSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "sync"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingM
                                   - ntpToggle.width - Theme.spacingM
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: "Network Time Synchronization"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Automatically synchronize system time with internet time servers"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }

                            StyledText {
                                text: "Status: " + (TimeService.systemClockSynchronized ? "Synchronized" : "Not synchronized") + " (" + TimeService.ntpServiceStatus + ")"
                                font.pixelSize: Theme.fontSizeSmall
                                color: TimeService.systemClockSynchronized ? Theme.success : Theme.surfaceVariantText
                                visible: TimeService.ntpServiceStatus && TimeService.ntpServiceStatus.length > 0
                            }
                        }

                        DankToggle {
                            id: ntpToggle

                            anchors.verticalCenter: parent.verticalCenter
                            checked: TimeService.ntpEnabled
                            onToggled: checked => {
                                TimeService.setNTP(checked)
                            }
                        }
                    }
                }
            }

            // Calendar Settings Section
            StyledRect {
                width: parent.width
                height: calendarSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: calendarSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "event"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Calendar Settings"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    DankDropdown {
                        width: parent.width
                        height: 50
                        text: "First Day of Week"
                        description: "Choose which day starts the week"
                        currentValue: {
                            const days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
                            return days[SettingsData.firstDayOfWeek] || "Monday"
                        }
                        options: ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
                        onValueChanged: value => {
                            const days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
                            const index = days.indexOf(value)
                            if (index >= 0) {
                                SettingsData.setFirstDayOfWeek(index)
                            }
                        }
                    }

                    DankDropdown {
                        width: parent.width
                        height: 50
                        text: "Week Numbering"
                        description: "How weeks are numbered in calendars"
                        currentValue: SettingsData.weekNumbering || "ISO"
                        options: ["ISO", "US", "None"]
                        onValueChanged: value => {
                            SettingsData.setWeekNumbering(value)
                        }
                    }
                }
            }

            // Time Format
            StyledRect {
                width: parent.width
                height: timeSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: timeSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "schedule"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingM
                                   - toggle.width - Theme.spacingM
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: "24-Hour Format"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Use 24-hour time format instead of 12-hour AM/PM"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }

                        DankToggle {
                            id: toggle

                            anchors.verticalCenter: parent.verticalCenter
                            checked: SettingsData.use24HourClock
                            onToggled: checked => {
                                           return SettingsData.setClockFormat(
                                               checked)
                                       }
                        }
                    }
                }
            }

            // Date Format Section
            StyledRect {
                width: parent.width
                height: dateSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: dateSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "calendar_today"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Date Format"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    DankDropdown {
                        width: parent.width
                        height: 50
                        text: "Top Bar Format"
                        description: "Preview: " + (SettingsData.clockDateFormat ? new Date().toLocaleDateString(Qt.locale(), SettingsData.clockDateFormat) : new Date().toLocaleDateString(Qt.locale(), "ddd d"))
                        currentValue: {
                            if (!SettingsData.clockDateFormat || SettingsData.clockDateFormat.length === 0) {
                                return "System Default"
                            }
                            // Find matching preset or show "Custom"
                            const presets = [{
                                                 "format": "ddd d",
                                                 "label": "Day Date"
                                             }, {
                                                 "format": "ddd MMM d",
                                                 "label": "Day Month Date"
                                             }, {
                                                 "format": "MMM d",
                                                 "label": "Month Date"
                                             }, {
                                                 "format": "M/d",
                                                 "label": "Numeric (M/D)"
                                             }, {
                                                 "format": "d/M",
                                                 "label": "Numeric (D/M)"
                                             }, {
                                                 "format": "ddd d MMM yyyy",
                                                 "label": "Full with Year"
                                             }, {
                                                 "format": "yyyy-MM-dd",
                                                 "label": "ISO Date"
                                             }, {
                                                 "format": "dddd, MMMM d",
                                                 "label": "Full Day & Month"
                                             }]
                            const match = presets.find(p => {
                                                           return p.format
                                                           === SettingsData.clockDateFormat
                                                       })
                            return match ? match.label : "Custom: " + SettingsData.clockDateFormat
                        }
                        options: ["System Default", "Day Date", "Day Month Date", "Month Date", "Numeric (M/D)", "Numeric (D/M)", "Full with Year", "ISO Date", "Full Day & Month", "Custom..."]
                        onValueChanged: value => {
                                            const formatMap = {
                                                "System Default": "",
                                                "Day Date": "ddd d",
                                                "Day Month Date": "ddd MMM d",
                                                "Month Date": "MMM d",
                                                "Numeric (M/D)": "M/d",
                                                "Numeric (D/M)": "d/M",
                                                "Full with Year": "ddd d MMM yyyy",
                                                "ISO Date": "yyyy-MM-dd",
                                                "Full Day & Month": "dddd, MMMM d"
                                            }
                                            if (value === "Custom...") {
                                                customFormatInput.visible = true
                                            } else {
                                                customFormatInput.visible = false
                                                SettingsData.setClockDateFormat(
                                                    formatMap[value])
                                            }
                                        }
                    }

                    DankDropdown {
                        width: parent.width
                        height: 50
                        text: "Lock Screen Format"
                        description: "Preview: " + (SettingsData.lockDateFormat ? new Date().toLocaleDateString(Qt.locale(), SettingsData.lockDateFormat) : new Date().toLocaleDateString(Qt.locale(), Locale.LongFormat))
                        currentValue: {
                            if (!SettingsData.lockDateFormat || SettingsData.lockDateFormat.length === 0) {
                                return "System Default"
                            }
                            // Find matching preset or show "Custom"
                            const presets = [{
                                                 "format": "ddd d",
                                                 "label": "Day Date"
                                             }, {
                                                 "format": "ddd MMM d",
                                                 "label": "Day Month Date"
                                             }, {
                                                 "format": "MMM d",
                                                 "label": "Month Date"
                                             }, {
                                                 "format": "M/d",
                                                 "label": "Numeric (M/D)"
                                             }, {
                                                 "format": "d/M",
                                                 "label": "Numeric (D/M)"
                                             }, {
                                                 "format": "ddd d MMM yyyy",
                                                 "label": "Full with Year"
                                             }, {
                                                 "format": "yyyy-MM-dd",
                                                 "label": "ISO Date"
                                             }, {
                                                 "format": "dddd, MMMM d",
                                                 "label": "Full Day & Month"
                                             }]
                            const match = presets.find(p => {
                                                           return p.format
                                                           === SettingsData.lockDateFormat
                                                       })
                            return match ? match.label : "Custom: " + SettingsData.lockDateFormat
                        }
                        options: ["System Default", "Day Date", "Day Month Date", "Month Date", "Numeric (M/D)", "Numeric (D/M)", "Full with Year", "ISO Date", "Full Day & Month", "Custom..."]
                        onValueChanged: value => {
                                            const formatMap = {
                                                "System Default": "",
                                                "Day Date": "ddd d",
                                                "Day Month Date": "ddd MMM d",
                                                "Month Date": "MMM d",
                                                "Numeric (M/D)": "M/d",
                                                "Numeric (D/M)": "d/M",
                                                "Full with Year": "ddd d MMM yyyy",
                                                "ISO Date": "yyyy-MM-dd",
                                                "Full Day & Month": "dddd, MMMM d"
                                            }
                                            if (value === "Custom...") {
                                                customLockFormatInput.visible = true
                                            } else {
                                                customLockFormatInput.visible = false
                                                SettingsData.setLockDateFormat(
                                                    formatMap[value])
                                            }
                                        }
                    }

                    DankTextField {
                        id: customFormatInput

                        width: parent.width
                        visible: false
                        placeholderText: "Enter custom top bar format (e.g., ddd MMM d)"
                        text: SettingsData.clockDateFormat
                        onTextChanged: {
                            if (visible && text)
                                SettingsData.setClockDateFormat(text)
                        }
                    }

                    DankTextField {
                        id: customLockFormatInput

                        width: parent.width
                        visible: false
                        placeholderText: "Enter custom lock screen format (e.g., dddd, MMMM d)"
                        text: SettingsData.lockDateFormat
                        onTextChanged: {
                            if (visible && text)
                                SettingsData.setLockDateFormat(text)
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: formatHelp.implicitHeight + Theme.spacingM * 2
                        radius: Theme.cornerRadius
                        color: Qt.rgba(Theme.surfaceVariant.r,
                                       Theme.surfaceVariant.g,
                                       Theme.surfaceVariant.b, 0.2)
                        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                              Theme.outline.b, 0.1)
                        border.width: 1

                        Column {
                            id: formatHelp

                            anchors.fill: parent
                            anchors.margins: Theme.spacingM
                            spacing: Theme.spacingXS

                            StyledText {
                                text: "Format Legend"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.primary
                                font.weight: Font.Medium
                            }

                            Row {
                                width: parent.width
                                spacing: Theme.spacingL

                                Column {
                                    width: (parent.width - Theme.spacingL) / 2
                                    spacing: 2

                                    StyledText {
                                        text: "• d - Day (1-31)"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }

                                    StyledText {
                                        text: "• dd - Day (01-31)"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }

                                    StyledText {
                                        text: "• ddd - Day name (Mon)"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }

                                    StyledText {
                                        text: "• dddd - Day name (Monday)"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }

                                    StyledText {
                                        text: "• M - Month (1-12)"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }
                                }

                                Column {
                                    width: (parent.width - Theme.spacingL) / 2
                                    spacing: 2

                                    StyledText {
                                        text: "• MM - Month (01-12)"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }

                                    StyledText {
                                        text: "• MMM - Month (Jan)"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }

                                    StyledText {
                                        text: "• MMMM - Month (January)"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }

                                    StyledText {
                                        text: "• yy - Year (24)"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }

                                    StyledText {
                                        text: "• yyyy - Year (2024)"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
