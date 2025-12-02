import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import qs.Common
import qs.Widgets

Rectangle {
    id: root

    property bool compactMode: false
    property string section: "center"
    property var popupTarget: null
    property var parentScreen: null
    property real barHeight: 48
    property real widgetHeight: 30
    readonly property bool isBarVertical: SettingsData.topBarPosition === "left" || SettingsData.topBarPosition === "right"
    readonly property bool useStackedFormat: SettingsData.clockStackedFormat
    readonly property real horizontalPadding: SettingsData.topBarNoBackground ? 2 : Theme.spacingS

    signal clockClicked

    readonly property var verticalTextParts: {
        root.formatUpdateTrigger // Reference to force update
        if (!systemClock?.date) return []
        
        var parts = []
        
        // First line: Day name and day number (e.g., "Mon 1")
        if (!SettingsData.clockCompactMode) {
            var dayName = systemClock.date.toLocaleDateString(Qt.locale(), "ddd")
            var dayNum = systemClock.date.toLocaleDateString(Qt.locale(), "d")
            parts.push(dayName + " " + dayNum)
        }
        
        // Second line: Time with AM/PM (e.g., "11:29 PM")
        var use24Hour = SettingsData.use24HourClock
        var timeStr = ""
        if (use24Hour) {
            // Force 24-hour format with AM/PM
            const hours = systemClock.date.getHours()
            const minutes = systemClock.date.getMinutes()
            const period = hours >= 12 ? "PM" : "AM"
            timeStr = String(hours).padStart(2, '0') + ":" + String(minutes).padStart(2, '0') + " " + period
        } else {
            // Use combined format string for 12-hour time
            const formatted = systemClock.date.toLocaleTimeString(Qt.locale(), "h:mm AP")
            timeStr = formatted.replace(/\./g, "").trim()
        }
        parts.push(timeStr)
        
        return parts
    }

    width: isBarVertical && !useStackedFormat ? widgetHeight : (isBarVertical && useStackedFormat ? (clockColumn.implicitHeight + horizontalPadding * 2) : (useStackedFormat ? Math.max(widgetHeight, clockColumn.implicitWidth + horizontalPadding * 2 + 2) : (clockRow.implicitWidth + horizontalPadding * 2 + 2)))
    height: isBarVertical && !useStackedFormat ? (clockRow.implicitWidth + horizontalPadding * 2 + 2) : (isBarVertical && useStackedFormat ? (clockColumn.implicitWidth + horizontalPadding * 2 + 2) : (useStackedFormat ? (clockColumn.implicitHeight + horizontalPadding * 2) : widgetHeight))
    radius: SettingsData.topBarNoBackground ? 0 : Theme.cornerRadius
    color: {
        if (SettingsData.topBarNoBackground) {
            return "transparent";
        }

        const baseColor = clockMouseArea.containsMouse ? Theme.widgetBaseHoverColor : Theme.widgetBaseBackgroundColor;
        return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, baseColor.a * Theme.widgetTransparency);
    }

    Row {
        id: clockRow
        visible: !useStackedFormat
        anchors.centerIn: parent
        spacing: Theme.spacingS
        rotation: isBarVertical ? (SettingsData.topBarPosition === "left" ? 90 : -90) : 0

        StyledText {
            id: clockTimeText
            text: {
                // Force re-evaluation when use24HourClock changes
                root.formatUpdateTrigger // Reference to force update
                const use24Hour = SettingsData.use24HourClock
                if (!systemClock?.date) return ""
                
                if (use24Hour) {
                    // Force 24-hour format with AM/PM
                    const date = systemClock.date
                    const hours = date.getHours() // Returns 0-23
                    const minutes = date.getMinutes() // Returns 0-59
                    // Format as HH:mm with AM/PM
                    const period = hours >= 12 ? "PM" : "AM"
                    return String(hours).padStart(2, '0') + ":" + String(minutes).padStart(2, '0') + " " + period
                } else {
                    // Use combined format string for 12-hour time
                    const formatted = systemClock.date.toLocaleTimeString(Qt.locale(), "h:mm AP")
                    // Clean up the format - remove dots and ensure proper spacing
                    return formatted.replace(/\./g, "").trim()
                }
            }
            font.pixelSize: Theme.fontSizeMedium - 1
            font.weight: SettingsData.clockBoldFont ? Font.Bold : Font.Normal
            color: Theme.surfaceText
            anchors.verticalCenter: parent.verticalCenter
            
            layer.enabled: true
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 1
                radius: 4
                samples: 16
                color: Qt.rgba(0, 0, 0, SettingsData.topBarDropShadowOpacity)
                transparentBorder: true
            }
        }

        StyledText {
            text: "•"
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.outlineButton
            anchors.verticalCenter: parent.verticalCenter
            visible: !SettingsData.clockCompactMode
            
            layer.enabled: true
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 1
                radius: 4
                samples: 16
                color: Qt.rgba(0, 0, 0, SettingsData.topBarDropShadowOpacity)
                transparentBorder: true
            }
        }

        StyledText {
            text: {
                if (SettingsData.clockDateFormat && SettingsData.clockDateFormat.length > 0) {
                    return systemClock?.date?.toLocaleDateString(Qt.locale(), SettingsData.clockDateFormat)
                }

                return systemClock?.date?.toLocaleDateString(Qt.locale(), "ddd d")
            }
            font.pixelSize: Theme.fontSizeMedium - 1
            font.weight: SettingsData.clockBoldFont ? Font.Bold : Font.Normal
            color: Theme.surfaceText
            anchors.verticalCenter: parent.verticalCenter
            visible: !SettingsData.clockCompactMode
            
            layer.enabled: true
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 1
                radius: 4
                samples: 16
                color: Qt.rgba(0, 0, 0, SettingsData.topBarDropShadowOpacity)
                transparentBorder: true
            }
        }
    }
    
    Column {
        id: clockColumn
        visible: useStackedFormat
        anchors.centerIn: parent
        spacing: Theme.spacingXS
        width: implicitWidth

        Repeater {
            model: root.verticalTextParts
            delegate: StyledText {
                text: modelData
                font.pixelSize: Theme.fontSizeSmall
                font.weight: SettingsData.clockBoldFont ? Font.Bold : Font.Normal
                color: Theme.surfaceText
                anchors.horizontalCenter: parent.horizontalCenter
                visible: text !== ""
                
                layer.enabled: true
                layer.effect: DropShadow {
                    horizontalOffset: 0
                    verticalOffset: 1
                    radius: 4
                    samples: 16
                    color: Qt.rgba(0, 0, 0, SettingsData.topBarDropShadowOpacity)
                    transparentBorder: true
                }
            }
        }
    }

    SystemClock {
        id: systemClock
        precision: SystemClock.Seconds
    }
    
    // Property to force re-evaluation when format changes
    property int formatUpdateTrigger: 0
    
    // Force update when clock format changes
    Connections {
        target: SettingsData
        function onUse24HourClockChanged() {
            formatUpdateTrigger++
        }
        function onWidgetDataChanged() {
            formatUpdateTrigger++
        }
    }

    MouseArea {
        id: clockMouseArea

        anchors.fill: parent
        hoverEnabled: true
    }

}
