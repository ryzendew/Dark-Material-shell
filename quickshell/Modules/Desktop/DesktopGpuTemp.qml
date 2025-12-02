import QtQuick
import Qt5Compat.GraphicalEffects
import qs.Common
import qs.Services
import qs.Widgets

DarkOSD {
    id: root

    property var screen: null
    property real widgetWidth: 120
    property real widgetHeight: 60
    property bool alwaysVisible: true
    property int selectedGpuIndex: 0

    osdWidth: widgetWidth
    osdHeight: widgetHeight
    enableMouseInteraction: true
    autoHideInterval: 0

    property var positionAnchors: {
        switch(SettingsData.desktopGpuTempPosition) {
            case "top-left": return { horizontal: "left", vertical: "top" }
            case "top-center": return { horizontal: "center", vertical: "top" }
            case "top-right": return { horizontal: "right", vertical: "top" }
            case "middle-left": return { horizontal: "left", vertical: "center" }
            case "middle-center": return { horizontal: "center", vertical: "center" }
            case "middle-right": return { horizontal: "right", vertical: "center" }
            case "bottom-left": return { horizontal: "left", vertical: "bottom" }
            case "bottom-center": return { horizontal: "center", vertical: "bottom" }
            case "bottom-right": return { horizontal: "right", vertical: "bottom" }
            default: return { horizontal: "left", vertical: "top" }
        }
    }

    property real displayTemp: {
        if (!DgopService.availableGpus || DgopService.availableGpus.length === 0) {
            return 0;
        }
        if (selectedGpuIndex >= 0 && selectedGpuIndex < DgopService.availableGpus.length) {
            return DgopService.availableGpus[selectedGpuIndex].temperature || 0;
        }
        return 0;
    }

    Component.onCompleted: {
        DgopService.addRef(["gpu"]);
        show();
    }
    
    Component.onDestruction: {
        DgopService.removeRef(["gpu"]);
    }

    content: Rectangle {
        width: widgetWidth
        height: widgetHeight
        radius: Theme.cornerRadius
        color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, SettingsData.desktopGpuTempOpacity)
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, SettingsData.desktopWidgetBorderOpacity)
        border.width: SettingsData.desktopWidgetBorderThickness

        anchors.left: positionAnchors.horizontal === "left" ? parent.left : undefined
        anchors.horizontalCenter: positionAnchors.horizontal === "center" ? parent.horizontalCenter : undefined
        anchors.right: positionAnchors.horizontal === "right" ? parent.right : undefined
        anchors.top: positionAnchors.vertical === "top" ? parent.top : undefined
        anchors.verticalCenter: positionAnchors.vertical === "center" ? parent.verticalCenter : undefined
        anchors.bottom: positionAnchors.vertical === "bottom" ? parent.bottom : undefined

        layer.enabled: SettingsData.desktopWidgetDropShadowOpacity > 0
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 4
            radius: 12
            samples: 16
            color: Qt.rgba(0, 0, 0, SettingsData.desktopWidgetDropShadowOpacity)
            transparentBorder: true
        }

        Row {
            anchors.centerIn: parent
            spacing: Theme.spacingS

            DarkIcon {
                name: "auto_awesome_mosaic"
                size: Theme.iconSize - 4
                color: {
                    if (root.displayTemp > 80) {
                        return Theme.tempDanger;
                    }
                    if (root.displayTemp > 65) {
                        return Theme.tempWarning;
                    }
                    return Theme.surfaceText;
                }
                anchors.verticalCenter: parent.verticalCenter

                layer.enabled: true
                layer.effect: DropShadow {
                    horizontalOffset: 0
                    verticalOffset: 1
                    radius: 3
                    samples: 16
                    color: Qt.rgba(0, 0, 0, 0.2)
                    transparentBorder: true
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                StyledText {
                    text: "GPU"
                    font.pixelSize: Theme.fontSizeSmall - 2
                    color: Theme.surfaceTextMedium
                    font.weight: Font.Medium
                }

                StyledText {
                    text: {
                        if (root.displayTemp === undefined || root.displayTemp === null || root.displayTemp === 0) {
                            return "--°";
                        }
                        return Math.round(root.displayTemp) + "°";
                    }
                    font.pixelSize: Theme.fontSizeMedium
                    font.weight: Font.Bold
                    color: {
                        if (root.displayTemp > 80) {
                            return Theme.tempDanger;
                        }
                        if (root.displayTemp > 65) {
                            return Theme.tempWarning;
                        }
                        return Theme.surfaceText;
                    }

                    layer.enabled: true
                    layer.effect: DropShadow {
                        horizontalOffset: 0
                        verticalOffset: 1
                        radius: 3
                        samples: 16
                        color: Qt.rgba(0, 0, 0, 0.2)
                        transparentBorder: true
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.SizeAllCursor
            onPressed: {
                if (alwaysVisible) {
                    show();
                }
            }
        }
    }

}
