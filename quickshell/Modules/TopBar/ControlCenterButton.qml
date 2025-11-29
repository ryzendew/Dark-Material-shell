import QtQuick
import Qt5Compat.GraphicalEffects
import qs.Common
import qs.Services
import qs.Widgets

Rectangle {
    id: root

    property bool isActive: false
    property string section: "right"
    property var popupTarget: null
    property var parentScreen: null
    property var widgetData: null
    property bool showNetworkIcon: SettingsData.controlCenterShowNetworkIcon
    property bool showBluetoothIcon: SettingsData.controlCenterShowBluetoothIcon
    property bool showAudioIcon: SettingsData.controlCenterShowAudioIcon
    property bool showMicIcon: SettingsData.controlCenterShowMicIcon
    property real widgetHeight: 30
    property real barHeight: 48
    readonly property bool isBarVertical: SettingsData.topBarPosition === "left" || SettingsData.topBarPosition === "right"
    readonly property real horizontalPadding: SettingsData.topBarNoBackground ? 0 : Math.max(Theme.spacingXS, Theme.spacingS * (widgetHeight / 30))

    signal clicked()

    width: isBarVertical ? widgetHeight : (controlIndicatorsRow.implicitWidth + horizontalPadding * 2)
    height: isBarVertical ? (controlIndicatorsColumn.implicitHeight + horizontalPadding * 2) : widgetHeight
    radius: SettingsData.topBarNoBackground ? 0 : Theme.cornerRadius
    color: {
        if (SettingsData.topBarNoBackground) {
            return "transparent";
        }

        const baseColor = Theme.widgetBaseBackgroundColor;
        return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, baseColor.a * Theme.widgetTransparency);
    }

    Row {
        id: controlIndicatorsRow
        visible: !isBarVertical
        anchors.centerIn: parent
        spacing: Theme.spacingXS

        DarkIcon {
            id: networkIcon

            name: {
                if (NetworkService.wifiToggling) {
                    return "sync";
                }

                if (NetworkService.networkStatus === "ethernet") {
                    return "lan";
                }

                return NetworkService.wifiSignalIcon;
            }
            size: Theme.iconSize - 8
            color: {
                if (NetworkService.wifiToggling) {
                    return Theme.primary;
                }

                return NetworkService.networkStatus !== "disconnected" ? Theme.primary : Theme.outlineButton;
            }
            anchors.verticalCenter: parent.verticalCenter
            visible: root.showNetworkIcon
            
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

        DarkIcon {
            id: bluetoothIcon

            name: "bluetooth"
            size: Theme.iconSize - 8
            color: BluetoothService.enabled ? Theme.primary : Theme.outlineButton
            anchors.verticalCenter: parent.verticalCenter
            visible: root.showBluetoothIcon && BluetoothService.available && BluetoothService.enabled
            
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

        Rectangle {
            width: audioIcon.implicitWidth + 4
            height: audioIcon.implicitHeight + 4
            color: "transparent"
            anchors.verticalCenter: parent.verticalCenter
            visible: root.showAudioIcon

            DarkIcon {
                id: audioIcon

                name: {
                    if (AudioService.sink && AudioService.sink.audio) {
                        if (AudioService.sink.audio.muted || AudioService.sink.audio.volume === 0) {
                            return "volume_off";
                        } else if (AudioService.sink.audio.volume * 100 < 33) {
                            return "volume_down";
                        } else {
                            return "volume_up";
                        }
                    }
                    return "volume_up";
                }
                size: Theme.iconSize - 8
                color: Theme.surfaceText
                anchors.centerIn: parent
                
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

            MouseArea {
                id: audioWheelArea

                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.NoButton
                onWheel: function(wheelEvent) {
                    let delta = wheelEvent.angleDelta.y;
                    let currentVolume = (AudioService.sink && AudioService.sink.audio && AudioService.sink.audio.volume * 100) || 0;
                    let newVolume;
                    if (delta > 0) {
                        newVolume = Math.min(100, currentVolume + 5);
                    } else {
                        newVolume = Math.max(0, currentVolume - 5);
                    }
                    if (AudioService.sink && AudioService.sink.audio) {
                        AudioService.sink.audio.muted = false;
                        AudioService.sink.audio.volume = newVolume / 100;
                        AudioService.volumeChanged();
                    }
                    wheelEvent.accepted = true;
                }
            }

        }

        Rectangle {
            width: micIcon.implicitWidth + 4
            height: micIcon.implicitHeight + 4
            color: "transparent"
            anchors.verticalCenter: parent.verticalCenter
            visible: root.showMicIcon && PrivacyService.microphoneActive

            DarkIcon {
                id: micIcon

                name: {
                    if (AudioService.source && AudioService.source.audio) {
                        return AudioService.source.audio.muted ? "mic_off" : "mic";
                    }
                    return "mic";
                }
                size: Theme.iconSize - 8
                color: {
                    if (AudioService.source && AudioService.source.audio) {
                        return AudioService.source.audio.muted ? Theme.outlineButton : Theme.primary;
                    }
                    return Theme.primary;
                }
                anchors.centerIn: parent
                
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

            MouseArea {
                id: micClickArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (AudioService.source && AudioService.source.audio) {
                        AudioService.toggleMicMute();
                    }
                }
            }
        }

        DarkIcon {
            name: "settings"
            size: Theme.iconSize - 8
            color: controlCenterArea.containsMouse || root.isActive ? Theme.primary : Theme.surfaceText
            anchors.verticalCenter: parent.verticalCenter
            visible: !root.showNetworkIcon && !root.showBluetoothIcon && !root.showAudioIcon && (!root.showMicIcon || !PrivacyService.microphoneActive)
            
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
        id: controlIndicatorsColumn
        visible: isBarVertical
        anchors.centerIn: parent
        spacing: Theme.spacingXS

        DarkIcon {
            id: networkIconVertical

            name: {
                if (NetworkService.wifiToggling) {
                    return "sync";
                }

                if (NetworkService.networkStatus === "ethernet") {
                    return "lan";
                }

                return NetworkService.wifiSignalIcon;
            }
            size: Theme.iconSize - 8
            color: {
                if (NetworkService.wifiToggling) {
                    return Theme.primary;
                }

                return NetworkService.networkStatus !== "disconnected" ? Theme.primary : Theme.outlineButton;
            }
            anchors.horizontalCenter: parent.horizontalCenter
            visible: root.showNetworkIcon
            
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

        DarkIcon {
            id: bluetoothIconVertical

            name: "bluetooth"
            size: Theme.iconSize - 8
            color: BluetoothService.enabled ? Theme.primary : Theme.outlineButton
            anchors.horizontalCenter: parent.horizontalCenter
            visible: root.showBluetoothIcon && BluetoothService.available && BluetoothService.enabled
            
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

        Rectangle {
            width: audioIconVertical.implicitWidth + 4
            height: audioIconVertical.implicitHeight + 4
            color: "transparent"
            anchors.horizontalCenter: parent.horizontalCenter
            visible: root.showAudioIcon

            DarkIcon {
                id: audioIconVertical

                name: {
                    if (AudioService.sink && AudioService.sink.audio) {
                        if (AudioService.sink.audio.muted || AudioService.sink.audio.volume === 0) {
                            return "volume_off";
                        } else if (AudioService.sink.audio.volume * 100 < 33) {
                            return "volume_down";
                        } else {
                            return "volume_up";
                        }
                    }
                    return "volume_up";
                }
                size: Theme.iconSize - 8
                color: Theme.surfaceText
                anchors.centerIn: parent
                
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

            MouseArea {
                id: audioWheelAreaVertical

                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.NoButton
                onWheel: function(wheelEvent) {
                    let delta = wheelEvent.angleDelta.y;
                    let currentVolume = (AudioService.sink && AudioService.sink.audio && AudioService.sink.audio.volume * 100) || 0;
                    let newVolume;
                    if (delta > 0) {
                        newVolume = Math.min(100, currentVolume + 5);
                    } else {
                        newVolume = Math.max(0, currentVolume - 5);
                    }
                    if (AudioService.sink && AudioService.sink.audio) {
                        AudioService.sink.audio.muted = false;
                        AudioService.sink.audio.volume = newVolume / 100;
                        AudioService.volumeChanged();
                    }
                    wheelEvent.accepted = true;
                }
            }
        }

        Rectangle {
            width: micIconVertical.implicitWidth + 4
            height: micIconVertical.implicitHeight + 4
            color: "transparent"
            anchors.horizontalCenter: parent.horizontalCenter
            visible: root.showMicIcon && PrivacyService.microphoneActive

            DarkIcon {
                id: micIconVertical

                name: {
                    if (AudioService.source && AudioService.source.audio) {
                        return AudioService.source.audio.muted ? "mic_off" : "mic";
                    }
                    return "mic";
                }
                size: Theme.iconSize - 8
                color: {
                    if (AudioService.source && AudioService.source.audio) {
                        return AudioService.source.audio.muted ? Theme.outlineButton : Theme.primary;
                    }
                    return Theme.primary;
                }
                anchors.centerIn: parent
                
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

            MouseArea {
                id: micClickAreaVertical

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (AudioService.source && AudioService.source.audio) {
                        AudioService.toggleMicMute();
                    }
                }
            }
        }

        DarkIcon {
            name: "settings"
            size: Theme.iconSize - 8
            color: controlCenterArea.containsMouse || root.isActive ? Theme.primary : Theme.surfaceText
            anchors.horizontalCenter: parent.horizontalCenter
            visible: !root.showNetworkIcon && !root.showBluetoothIcon && !root.showAudioIcon && (!root.showMicIcon || !PrivacyService.microphoneActive)
            
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

    MouseArea {
        id: controlCenterArea

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
            root.clicked();
        }
    }


}
