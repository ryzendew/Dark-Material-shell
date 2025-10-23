import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets

DankOSD {
    id: root

    property var screen: null
    property real widgetWidth: 300
    property real widgetHeight: 150
    property bool alwaysVisible: true

    osdWidth: widgetWidth
    osdHeight: widgetHeight
    enableMouseInteraction: true
    autoHideInterval: 0

    // Position based on individual widget settings
    property var positionAnchors: {
        switch(SettingsData.desktopCpuTempPosition) {
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

    Component.onCompleted: {
        DgopService.addRef(["cpu"]);
        console.log("DesktopCpuTemp: Component completed")
        console.log("DesktopCpuTemp: CpuFrequencyService available:", typeof CpuFrequencyService !== 'undefined')
        console.log("DesktopCpuTemp: PerformanceService available:", typeof PerformanceService !== 'undefined')
        if (typeof CpuFrequencyService !== 'undefined') {
            console.log("DesktopCpuTemp: Initial CPU frequency:", CpuFrequencyService.currentFrequency)
        }
        if (typeof PerformanceService !== 'undefined') {
            console.log("DesktopCpuTemp: Initial performance mode:", PerformanceService.currentMode)
        }
        show();
    }
    
    Component.onDestruction: {
        DgopService.removeRef(["cpu"]);
    }

    content: Rectangle {
        width: widgetWidth
        height: widgetHeight
        radius: Theme.cornerRadius
        color: Qt.rgba(1, 0, 0, 0.9) // Bright red for testing
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.3)
        border.width: 1

        Component.onCompleted: {
            console.log("DesktopCpuTemp content: Component.onCompleted");
            console.log("DesktopCpuTemp content: width =", width);
            console.log("DesktopCpuTemp content: height =", height);
            console.log("DesktopCpuTemp content: x =", x);
            console.log("DesktopCpuTemp content: y =", y);
        }

        // Position at top-left for testing
        x: 50
        y: 50

        // Drop shadow
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 4
            radius: 12
            samples: 16
            color: Qt.rgba(0, 0, 0, 0.3)
            transparentBorder: true
        }

        Row {
            anchors.centerIn: parent
            spacing: Theme.spacingS

            DankIcon {
                name: "memory"
                size: Theme.iconSize - 4
                color: {
                    if (DgopService.cpuTemperature > 85) {
                        return Theme.tempDanger;
                    }
                    if (DgopService.cpuTemperature > 69) {
                        return Theme.tempWarning;
                    }
                    return Theme.surfaceText;
                }
                anchors.verticalCenter: parent.verticalCenter

                // Drop shadow
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
                    text: "CPU"
                    font.pixelSize: Theme.fontSizeSmall - 2
                    color: Theme.surfaceTextMedium
                    font.weight: Font.Medium
                }

                StyledText {
                    text: {
                        if (DgopService.cpuTemperature === undefined || DgopService.cpuTemperature === null || DgopService.cpuTemperature < 0) {
                            return "--°";
                        }
                        return Math.round(DgopService.cpuTemperature) + "°";
                    }
                    font.pixelSize: Theme.fontSizeMedium
                    font.weight: Font.Bold
                    color: {
                        if (DgopService.cpuTemperature > 85) {
                            return Theme.tempDanger;
                        }
                        if (DgopService.cpuTemperature > 69) {
                            return Theme.tempWarning;
                        }
                        return Theme.surfaceText;
                    }

                    // Drop shadow
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

                StyledText {
                    text: {
                        try {
                            if (typeof CpuFrequencyService !== 'undefined' && CpuFrequencyService.currentFrequency > 0) {
                                return CpuFrequencyService.currentFrequency.toFixed(1) + "GHz";
                            }
                        } catch (e) {
                            console.log("DesktopCpuTemp: Error accessing CpuFrequencyService:", e)
                        }
                        return "--GHz";
                    }
                    font.pixelSize: Theme.fontSizeSmall - 1
                    font.weight: Font.Medium
                    color: {
                        try {
                            if (typeof PerformanceService !== 'undefined') {
                                switch(PerformanceService.currentMode) {
                                    case "performance": return "#F44336"; // Red
                                    case "balanced": return "#FF9800"; // Orange
                                    case "power-saver": return "#4CAF50"; // Green
                                    default: return Theme.surfaceTextMedium;
                                }
                            }
                        } catch (e) {
                            console.log("DesktopCpuTemp: Error accessing PerformanceService:", e)
                        }
                        return Theme.surfaceTextMedium;
                    }

                    // Drop shadow
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

                StyledText {
                    text: {
                        try {
                            if (typeof PerformanceService !== 'undefined') {
                                return PerformanceService.getCurrentModeInfo().name;
                            }
                        } catch (e) {
                            console.log("DesktopCpuTemp: Error accessing PerformanceService:", e)
                        }
                        return "Unknown";
                    }
                    font.pixelSize: Theme.fontSizeSmall - 3
                    font.weight: Font.Normal
                    color: {
                        try {
                            if (typeof PerformanceService !== 'undefined') {
                                switch(PerformanceService.currentMode) {
                                    case "performance": return "#8BC34A"; // Bright Green
                                    case "balanced": return "#FFC107"; // Bright Yellow
                                    case "power-saver": return "#00BCD4"; // Bright Cyan
                                    default: return Theme.surfaceTextMedium;
                                }
                            }
                        } catch (e) {
                            console.log("DesktopCpuTemp: Error accessing PerformanceService:", e)
                        }
                        return Theme.surfaceTextMedium;
                    }

                    // Drop shadow
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

        // Make the widget draggable
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

    // Auto-refresh when temperature changes
    Connections {
        target: DgopService
        function onCpuTemperatureChanged() {
            if (alwaysVisible) {
                show();
            }
        }
    }
}
