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
            // Force time display update
        }
    }
    
    // Force update when format changes
    property int formatUpdateTrigger: 0
    Connections {
        target: SettingsData
        function onUse24HourClockChanged() {
            formatUpdateTrigger++
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

                        DarkIcon {
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
                                text: {
                                    root.formatUpdateTrigger // Force update when format changes
                                    const now = new Date()
                                    if (SettingsData.use24HourClock) {
                                        // Force 24-hour format with AM/PM
                                        const hours = now.getHours()
                                        const minutes = now.getMinutes()
                                        const period = hours >= 12 ? "PM" : "AM"
                                        return String(hours).padStart(2, '0') + ":" + String(minutes).padStart(2, '0') + " " + period + " " + now.toLocaleDateString(Qt.locale(), Locale.LongFormat)
                                    } else {
                                        // Use combined format string for 12-hour time
                                        const timeStr = now.toLocaleTimeString(Qt.locale(), "h:mm AP")
                                        const cleanedTime = timeStr.replace(/\./g, "").trim()
                                        return cleanedTime + " " + now.toLocaleDateString(Qt.locale(), Locale.LongFormat)
                                    }
                                }
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

            StyledRect {
                width: parent.width
                height: timeFormatSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: timeFormatSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "schedule"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingM
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: "Time Format"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Configure how time is displayed"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                            }
                        }
                    }

                    DarkToggle {
                        width: parent.width
                        text: "Use 24-hour time format"
                        checked: SettingsData.use24HourClock
                        onToggled: checked => {
                            SettingsData.setClockFormat(checked)
                        }
                    }

                    DarkToggle {
                        width: parent.width
                        text: "Stack Time Format"
                        description: "Display time in a vertical stacked format"
                        checked: SettingsData.clockStackedFormat
                        onToggled: checked => {
                            SettingsData.setClockStackedFormat(checked)
                        }
                    }

                    DarkToggle {
                        width: parent.width
                        text: "Bold Time Font"
                        description: "Make the time text bold"
                        checked: SettingsData.clockBoldFont
                        onToggled: checked => {
                            SettingsData.setClockBoldFont(checked)
                        }
                    }
                }
            }

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

                        DarkIcon {
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

                    DarkTextField {
                        id: timezoneSearchField
                        width: parent.width
                        placeholderText: "Search timezone (e.g., America, Europe, Asia)"
                        text: timezoneSearchText
                        onTextChanged: {
                            timezoneSearchText = text
                            updateFilteredTimezones()
                        }
                    }

                    DarkDropdown {
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

                    DarkToggle {
                        width: parent.width
                        text: "Network Time Synchronization"
                        description: "Automatically synchronize system time with internet time servers"
                        checked: TimeService.ntpEnabled
                        onToggled: checked => {
                            TimeService.setNTP(checked)
                        }
                    }
                    
                    StyledText {
                        text: "Status: " + (TimeService.systemClockSynchronized ? "Synchronized" : "Not synchronized") + " (" + TimeService.ntpServiceStatus + ")"
                        font.pixelSize: Theme.fontSizeSmall
                        color: TimeService.systemClockSynchronized ? Theme.success : Theme.surfaceVariantText
                        visible: TimeService.ntpServiceStatus && TimeService.ntpServiceStatus.length > 0
                        width: parent.width
                    }
                }
            }

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

                        DarkIcon {
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

                    DarkDropdown {
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

                    DarkDropdown {
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

                        DarkIcon {
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

                    DarkDropdown {
                        width: parent.width
                        height: 50
                        text: "Top Bar Format"
                        description: "Preview: " + (SettingsData.clockDateFormat ? new Date().toLocaleDateString(Qt.locale(), SettingsData.clockDateFormat) : new Date().toLocaleDateString(Qt.locale(), "ddd d"))
                        currentValue: {
                            if (!SettingsData.clockDateFormat || SettingsData.clockDateFormat.length === 0) {
                                return "System Default"
                            }
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

                    DarkDropdown {
                        width: parent.width
                        height: 50
                        text: "Lock Screen Format"
                        description: "Preview: " + (SettingsData.lockDateFormat ? new Date().toLocaleDateString(Qt.locale(), SettingsData.lockDateFormat) : new Date().toLocaleDateString(Qt.locale(), Locale.LongFormat))
                        currentValue: {
                            if (!SettingsData.lockDateFormat || SettingsData.lockDateFormat.length === 0) {
                                return "System Default"
                            }
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

                    DarkTextField {
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

                    DarkTextField {
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
