import QtQuick
import Qt5Compat.GraphicalEffects
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: root

    property bool isActive: false
    property string section: "left"
    property var popupTarget: null
    property var parentScreen: null
    property real widgetHeight: 30
    property real barHeight: 48
    readonly property real horizontalPadding: SettingsData.topBarNoBackground ? 0 : Math.max(Theme.spacingXS, Theme.spacingS * (widgetHeight / 30))

    signal clicked()

    width: Math.max(SettingsData.launcherLogoSize, 16) + horizontalPadding * 2
    height: widgetHeight

    MouseArea {
        id: launcherArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton
        onPressed: {
            if (popupTarget && popupTarget.setTriggerPosition) {
                const globalPos = mapToGlobal(0, 0);
                const currentScreen = parentScreen || Screen;
                const screenX = currentScreen.x || 0;
                const relativeX = globalPos.x - screenX;
                popupTarget.setTriggerPosition(relativeX, barHeight + Theme.spacingXS, width, section, currentScreen);
            }
            root.clicked();
        }
    }

    Rectangle {
        id: launcherContent

        anchors.fill: parent
        radius: SettingsData.topBarNoBackground ? 0 : Theme.cornerRadius
        color: {
            if (SettingsData.topBarNoBackground) {
                return "transparent";
            }

            const baseColor = launcherArea.containsMouse ? Theme.widgetBaseHoverColor : Theme.widgetBaseBackgroundColor;
            return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, baseColor.a * Theme.widgetTransparency);
        }

        SystemLogo {
            visible: SettingsData.useOSLogo && !SettingsData.useCustomLauncherImage
            anchors.centerIn: parent
            width: SettingsData.launcherLogoSize > 0 ? SettingsData.launcherLogoSize - 3 : 0
            height: SettingsData.launcherLogoSize > 0 ? SettingsData.launcherLogoSize - 3 : 0
            colorOverride: SettingsData.osLogoColorOverride !== "" ? SettingsData.osLogoColorOverride : Qt.rgba(SettingsData.launcherLogoRed, SettingsData.launcherLogoGreen, SettingsData.launcherLogoBlue, 1.0)
            brightnessOverride: SettingsData.osLogoBrightness
            contrastOverride: SettingsData.osLogoContrast

            // Drop shadow
            layer.enabled: true
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 2
                radius: 8
                samples: 16
                color: Qt.rgba(0, 0, 0, SettingsData.launcherLogoDropShadowOpacity)
                transparentBorder: true
            }
        }

        Item {
            visible: SettingsData.useCustomLauncherImage && SettingsData.customLauncherImagePath !== ""
            anchors.centerIn: parent
            width: SettingsData.launcherLogoSize > 0 ? SettingsData.launcherLogoSize - 6 : 0
            height: SettingsData.launcherLogoSize > 0 ? SettingsData.launcherLogoSize - 6 : 0

            Image {
                id: customImage
                anchors.fill: parent
                source: SettingsData.customLauncherImagePath
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true

                // Color overlay for custom images
                layer.enabled: SettingsData.launcherLogoRed !== 1.0 || SettingsData.launcherLogoGreen !== 1.0 || SettingsData.launcherLogoBlue !== 1.0
                layer.effect: ColorOverlay {
                    color: Qt.rgba(SettingsData.launcherLogoRed, SettingsData.launcherLogoGreen, SettingsData.launcherLogoBlue, 0.8)
                }
            }

            // Drop shadow for custom images
            layer.enabled: true
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 2
                radius: 8
                samples: 16
                color: Qt.rgba(0, 0, 0, SettingsData.launcherLogoDropShadowOpacity)
                transparentBorder: true
            }
        }

        DankIcon {
            visible: !SettingsData.useOSLogo && !SettingsData.useCustomLauncherImage
            anchors.centerIn: parent
            name: "apps"
            size: SettingsData.launcherLogoSize > 0 ? SettingsData.launcherLogoSize - 6 : 0
            color: Qt.rgba(SettingsData.launcherLogoRed, SettingsData.launcherLogoGreen, SettingsData.launcherLogoBlue, 1.0)

            // Drop shadow
            layer.enabled: true
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 2
                radius: 8
                samples: 16
                color: Qt.rgba(0, 0, 0, SettingsData.launcherLogoDropShadowOpacity)
                transparentBorder: true
            }
        }
    }
}
