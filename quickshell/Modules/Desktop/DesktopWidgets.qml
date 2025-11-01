import QtQuick
import qs.Modules.Desktop

Item {
    id: root

    property var modelData: null
    property string screenName: modelData ? modelData.name : ""

    // Desktop widget settings - controlled by SettingsData
    property bool showCpuTemp: SettingsData.desktopWidgetsEnabled && SettingsData.desktopCpuTempEnabled
    property bool showGpuTemp: SettingsData.desktopWidgetsEnabled && SettingsData.desktopGpuTempEnabled
    property bool showSystemMonitor: SettingsData.desktopWidgetsEnabled && SettingsData.desktopSystemMonitorEnabled
    property bool showClock: SettingsData.desktopWidgetsEnabled && SettingsData.desktopClockEnabled
    property bool showTerminal: SettingsData.desktopWidgetsEnabled && SettingsData.desktopTerminalEnabled

    // Position mapping function
    function getPositionAnchors(position) {
        switch(position) {
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

    // CPU Temperature Widget
    DesktopCpuTemp {
        id: cpuTempWidget
        visible: root.showCpuTemp
        alwaysVisible: root.showCpuTemp
        screen: root.modelData
    }

    // GPU Temperature Widget
    DesktopGpuTemp {
        id: gpuTempWidget
        visible: root.showGpuTemp
        alwaysVisible: root.showGpuTemp
        screen: root.modelData
    }

    // System Monitor Widget
    DesktopSystemMonitor {
        id: systemMonitorWidget
        visible: root.showSystemMonitor
        alwaysVisible: root.showSystemMonitor
        screen: root.modelData
    }

    // Desktop Clock Widget
    DesktopClock {
        id: clockWidget
        visible: root.showClock
        alwaysVisible: root.showClock
        screen: root.modelData
    }

    // Desktop Terminal Widget
    DesktopTerminal {
        id: terminalWidget
        visible: root.showTerminal
        alwaysVisible: root.showTerminal
        screen: root.modelData
    }

    // Function to toggle widgets
    function toggleCpuTemp() {
        showCpuTemp = !showCpuTemp
    }

    function toggleGpuTemp() {
        showGpuTemp = !showGpuTemp
    }

    function toggleSystemMonitor() {
        showSystemMonitor = !showSystemMonitor
    }

    function toggleClock() {
        showClock = !showClock
    }

    function toggleTerminal() {
        showTerminal = !showTerminal
    }

    // Function to show all widgets
    function showAllWidgets() {
        showCpuTemp = true
        showGpuTemp = true
        showSystemMonitor = true
        showClock = true
        showTerminal = true
    }

    // Function to hide all widgets
    function hideAllWidgets() {
        showCpuTemp = false
        showGpuTemp = false
        showSystemMonitor = false
        showClock = false
        showTerminal = false
    }
}
