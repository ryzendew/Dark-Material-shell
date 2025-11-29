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
    readonly property real horizontalPadding: SettingsData.topBarNoBackground ? 2 : Theme.spacingS

    signal clockClicked

    readonly property string verticalFormattedText: {
        if (!systemClock?.date) return ""
        var parts = []
        
        var timeFormat = SettingsData.use24HourClock ? "HH:mm" : "h:mm"
        parts.push(systemClock.date.toLocaleTimeString(Qt.locale(), timeFormat))
        
        if (!SettingsData.use24HourClock) {
            var period = systemClock.date.toLocaleTimeString(Qt.locale(), "AP")
            if (period) {
                parts.push(period.toUpperCase().replace(/\./g, ""))
            }
        }
        
        if (!SettingsData.clockCompactMode) {
            var dayName = systemClock.date.toLocaleDateString(Qt.locale(), "ddd")
            var dayNum = systemClock.date.toLocaleDateString(Qt.locale(), "d")
            parts.push(dayName)
            parts.push(dayNum)
        }
        
        return parts.join(" ")
    }
    
    readonly property var verticalTextParts: verticalFormattedText.split(" ").filter(part => part !== "")

    width: isBarVertical ? widgetHeight : (clockRow.implicitWidth + horizontalPadding * 2 + 2)
    height: isBarVertical ? (clockColumn.implicitHeight + horizontalPadding * 2) : widgetHeight
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
        visible: !isBarVertical
        anchors.centerIn: parent
        spacing: Theme.spacingS

        StyledText {
            text: {
                if (SettingsData.use24HourClock) {
                    return systemClock?.date?.toLocaleTimeString(Qt.locale(), "HH:mm")
                } else {
                    const timePart = systemClock?.date?.toLocaleTimeString(Qt.locale(), "h:mm")
                    const period = systemClock?.date?.toLocaleTimeString(Qt.locale(), "AP")
                    return timePart + " " + (period ? period.toUpperCase().replace(/\./g, "") : "")
                }
            }
            font.pixelSize: Theme.fontSizeMedium - 1
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
        visible: isBarVertical
        anchors.centerIn: parent
        spacing: Theme.spacingXS

        Repeater {
            model: root.verticalTextParts
            delegate: StyledText {
                text: modelData
                font.pixelSize: Theme.fontSizeSmall
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

    MouseArea {
        id: clockMouseArea

        anchors.fill: parent
        hoverEnabled: true
    }

}
