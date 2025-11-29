import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell.Services.UPower
import qs.Common
import qs.Services
import qs.Widgets

Rectangle {
    id: battery

    property bool batteryPopupVisible: false
    property string section: "right"
    property var popupTarget: null
    property var parentScreen: null
    property real widgetHeight: 30
    property real barHeight: 48
    readonly property bool isBarVertical: SettingsData.topBarPosition === "left" || SettingsData.topBarPosition === "right"
    readonly property real horizontalPadding: SettingsData.topBarNoBackground ? 0 : Math.max(Theme.spacingXS, Theme.spacingS * (widgetHeight / 30))

    signal toggleBatteryPopup()

    width: isBarVertical ? widgetHeight : (batteryContentRow.implicitWidth + horizontalPadding * 2)
    height: isBarVertical ? (batteryContentColumn.implicitHeight + horizontalPadding * 2) : widgetHeight
    radius: SettingsData.topBarNoBackground ? 0 : Theme.cornerRadius
    color: {
        if (SettingsData.topBarNoBackground) {
            return "transparent";
        }

        const baseColor = batteryArea.containsMouse ? Theme.widgetBaseHoverColor : Theme.widgetBaseBackgroundColor;
        return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, baseColor.a * Theme.widgetTransparency);
    }
    visible: true

    Row {
        id: batteryContentRow
        visible: !isBarVertical
        anchors.centerIn: parent
        spacing: SettingsData.topBarNoBackground ? 1 : 2

        DarkIcon {
            name: BatteryService.getBatteryIcon()
            size: Theme.iconSize - 6
            color: {
                if (!BatteryService.batteryAvailable) {
                    return Theme.surfaceText;
                }

                if (BatteryService.isLowBattery && !BatteryService.isCharging) {
                    return Theme.error;
                }

                if (BatteryService.isCharging || BatteryService.isPluggedIn) {
                    return Theme.primary;
                }

                return Theme.surfaceText;
            }
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
            text: `${BatteryService.batteryLevel}%`
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Font.Medium
            color: Theme.surfaceText
            anchors.verticalCenter: parent.verticalCenter
            visible: BatteryService.batteryAvailable
            
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
        id: batteryContentColumn
        visible: isBarVertical
        anchors.centerIn: parent
        spacing: SettingsData.topBarNoBackground ? 1 : 2

        DarkIcon {
            name: BatteryService.getBatteryIcon()
            size: Theme.iconSize - 6
            color: {
                if (!BatteryService.batteryAvailable) {
                    return Theme.surfaceText;
                }

                if (BatteryService.isLowBattery && !BatteryService.isCharging) {
                    return Theme.error;
                }

                if (BatteryService.isCharging || BatteryService.isPluggedIn) {
                    return Theme.primary;
                }

                return Theme.surfaceText;
            }
            anchors.horizontalCenter: parent.horizontalCenter
            
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

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 0
            visible: BatteryService.batteryAvailable
            
            Repeater {
                model: {
                    const levelStr = BatteryService.batteryLevel.toString()
                    const chars = ['%']
                    for (let i = 0; i < levelStr.length; i++) {
                        chars.push(levelStr[i])
                    }
                    return chars
                }
                
                StyledText {
                    text: modelData
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.Medium
                    color: Theme.surfaceText
                    anchors.horizontalCenter: parent.horizontalCenter
                    
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
    }

    MouseArea {
        id: batteryArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed: {
            if (popupTarget && popupTarget.setTriggerPosition) {
                const globalPos = mapToGlobal(0, 0);
                const currentScreen = parentScreen || Screen;
                const screenX = currentScreen.x || 0;
                const screenY = currentScreen.y || 0;
                const relativeX = globalPos.x - screenX;
                const relativeY = globalPos.y - screenY;
                
                let triggerX, triggerY;
                if (isBarVertical) {
                    if (SettingsData.topBarPosition === "left") {
                        triggerX = relativeX + width + Theme.spacingXS;
                        triggerY = relativeY;
                    } else {
                        triggerX = relativeX - Theme.spacingXS;
                        triggerY = relativeY;
                    }
                } else {
                    triggerX = relativeX;
                    if (SettingsData.topBarPosition === "top") {
                        triggerY = relativeY + height + Theme.spacingXS;
                    } else {
                        triggerY = relativeY - Theme.spacingXS;
                    }
                }
                
                popupTarget.setTriggerPosition(triggerX, triggerY, isBarVertical ? height : width, section, currentScreen);
            }
            toggleBatteryPopup();
        }
    }

    Rectangle {
        id: batteryTooltip

        width: isBarVertical ? (tooltipText.contentHeight + Theme.spacingS * 2) : Math.max(120, tooltipText.contentWidth + Theme.spacingM * 2)
        height: isBarVertical ? Math.max(120, tooltipText.contentWidth + Theme.spacingM * 2) : (tooltipText.contentHeight + Theme.spacingS * 2)
        radius: Theme.cornerRadius
        color: Theme.widgetBaseBackgroundColor
        border.color: Theme.surfaceVariantAlpha
        border.width: 1
        visible: batteryArea.containsMouse && !batteryPopupVisible
        anchors.bottom: isBarVertical ? undefined : (SettingsData.topBarPosition === "top" ? parent.top : undefined)
        anchors.top: isBarVertical ? undefined : (SettingsData.topBarPosition === "bottom" ? parent.bottom : undefined)
        anchors.bottomMargin: isBarVertical ? undefined : (SettingsData.topBarPosition === "top" ? Theme.spacingS : undefined)
        anchors.topMargin: isBarVertical ? undefined : (SettingsData.topBarPosition === "bottom" ? Theme.spacingS : undefined)
        anchors.horizontalCenter: isBarVertical ? undefined : parent.horizontalCenter
        anchors.right: isBarVertical && SettingsData.topBarPosition === "left" ? parent.left : undefined
        anchors.left: isBarVertical && SettingsData.topBarPosition === "right" ? parent.right : undefined
        anchors.verticalCenter: isBarVertical ? parent.verticalCenter : undefined
        anchors.rightMargin: isBarVertical ? Theme.spacingS : undefined
        anchors.leftMargin: isBarVertical ? Theme.spacingS : undefined
        rotation: isBarVertical ? (SettingsData.topBarPosition === "left" ? 90 : -90) : 0
        opacity: batteryArea.containsMouse ? 1 : 0
        
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 2
            radius: 6
            samples: 16
            color: Qt.rgba(0, 0, 0, SettingsData.topBarDropShadowOpacity * 0.8)
            transparentBorder: true
        }

        Column {
            anchors.centerIn: parent
            spacing: 2
            rotation: isBarVertical ? (SettingsData.topBarPosition === "left" ? -90 : 90) : 0

            StyledText {
                id: tooltipText

                text: {
                    if (!BatteryService.batteryAvailable) {
                        if (typeof PowerProfiles === "undefined") {
                            return "Power Management";
                        }

                        switch (PowerProfiles.profile) {
                        case PowerProfile.PowerSaver:
                            return "Power Profile: Power Saver";
                        case PowerProfile.Performance:
                            return "Power Profile: Performance";
                        default:
                            return "Power Profile: Balanced";
                        }
                    }
                    const status = BatteryService.batteryStatus;
                    const level = `${BatteryService.batteryLevel}%`;
                    const time = BatteryService.formatTimeRemaining();
                    if (time !== "Unknown") {
                        return `${status} • ${level} • ${time}`;
                    } else {
                        return `${status} • ${level}`;
                    }
                }
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceText
                horizontalAlignment: Text.AlignHCenter
            }

        }

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.shortDuration
                easing.type: Theme.standardEasing
            }

        }

    }


}
