import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Widgets

PanelWindow {
    id: root

    property var modelData: null
    property var screen: modelData
    property real widgetWidth: SettingsData.desktopSystemMonitorWidth
    property real widgetHeight: SettingsData.desktopSystemMonitorHeight
    property bool alwaysVisible: SettingsData.desktopSystemMonitorEnabled
    property string position: SettingsData.desktopSystemMonitorPosition
    property real widgetOpacity: SettingsData.desktopSystemMonitorOpacity
    property var positioningBox: null
    
    // Dynamic sizing based on widget dimensions
    property real scaleFactor: Math.min(widgetWidth / 320, widgetHeight / 200)
    property real baseFontSize: 14
    property real scaledFontSize: baseFontSize * scaleFactor
    property real baseSpacing: 8
    property real scaledSpacing: baseSpacing * scaleFactor
    property real basePadding: 16
    property real scaledPadding: basePadding * scaleFactor
    
    // System data properties
    property real currentCpuTemperature: DgopService.cpuTemperature || 0
    property real currentGpuTemperature: (DgopService.availableGpus && DgopService.availableGpus.length > 0) ? (DgopService.availableGpus[0].temperature || -1) : -1
    property real currentGpuMemoryUsed: (DgopService.availableGpus && DgopService.availableGpus.length > 0) ? (DgopService.availableGpus[0].memoryUsedMB || 0) : 0
    property real currentGpuMemoryTotal: (DgopService.availableGpus && DgopService.availableGpus.length > 0) ? (DgopService.availableGpus[0].memoryTotalMB || 0) : 0
    property real currentCpuUsage: DgopService.cpuUsage || 0
    property real currentMemoryUsage: DgopService.memoryUsage || 0
    property real currentNetworkDownloadSpeed: DgopService.networkRxRate || 0
    property real currentNetworkUploadSpeed: DgopService.networkTxRate || 0

    implicitWidth: widgetWidth
    implicitHeight: widgetHeight
    visible: alwaysVisible

    WlrLayershell.layer: WlrLayershell.Background
    WlrLayershell.namespace: "quickshell:desktop:systemMonitor"
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    color: "transparent"

    // Position using anchors and margins like notifications
    anchors {
        left: position.includes("left") ? true : false
        right: position.includes("right") ? true : false
        top: position.includes("top") ? true : false
        bottom: position.includes("bottom") ? true : false
    }

    margins {
        left: position.includes("left") ? 20 : 0
        right: position.includes("right") ? 20 : 0
        top: position.includes("top") ? (SettingsData.topBarHeight + SettingsData.topBarSpacing + SettingsData.topBarBottomGap + 20) : 0
        bottom: position.includes("bottom") ? (SettingsData.dockExclusiveZone + SettingsData.dockBottomGap + 20) : 0
    }

    Component.onCompleted: {
        DgopService.addRef(["cpu", "memory", "gpu", "network"]);
        startNvmlMonitoring();
    }

    // Update data when services change
    Connections {
        target: DgopService
        function onCpuUsageChanged() {
            currentCpuUsage = DgopService.cpuUsage || 0;
        }
        function onMemoryUsageChanged() {
            currentMemoryUsage = DgopService.memoryUsage || 0;
        }
        function onNetworkRxRateChanged() {
            currentNetworkDownloadSpeed = DgopService.networkRxRate || 0;
        }
        function onNetworkTxRateChanged() {
            currentNetworkUploadSpeed = DgopService.networkTxRate || 0;
        }
        function onAvailableGpusChanged() {
            currentGpuTemperature = (DgopService.availableGpus && DgopService.availableGpus.length > 0) ? (DgopService.availableGpus[0].temperature || -1) : -1;
        }
    }

    // Update widget when settings change
    Connections {
        target: SettingsData
        function onDesktopSystemMonitorEnabledChanged() {
            alwaysVisible = SettingsData.desktopSystemMonitorEnabled;
        }
        function onDesktopSystemMonitorPositionChanged() {
            position = SettingsData.desktopSystemMonitorPosition;
        }
        function onDesktopSystemMonitorOpacityChanged() {
            widgetOpacity = SettingsData.desktopSystemMonitorOpacity;
        }
        function onDesktopSystemMonitorWidthChanged() {
            widgetWidth = SettingsData.desktopSystemMonitorWidth;
        }
        function onDesktopSystemMonitorHeightChanged() {
            widgetHeight = SettingsData.desktopSystemMonitorHeight;
        }
    }

    // Functions to get temperatures
    function getCpuTemperature() {
        return DgopService.cpuTemperature || 0;
    }

    function getGpuTemperature() {
        if (!DgopService.availableGpus || DgopService.availableGpus.length === 0) {
            return -1;
        }
        
        if (SettingsData.desktopGpuSelection === "auto") {
            const gpu = DgopService.availableGpus[0];
            return gpu.temperature !== undefined ? gpu.temperature : -1;
        }
        
        const options = SettingsData.getGpuDropdownOptions();
        const selectedIndex = options.indexOf(SettingsData.desktopGpuSelection);
        
        if (selectedIndex > 0 && selectedIndex <= DgopService.availableGpus.length) {
            const gpuIndex = selectedIndex - 1;
            const gpu = DgopService.availableGpus[gpuIndex];
            return gpu.temperature || -1;
        }
        
        return -1;
    }
    
    // Function to shorten CPU name
    function getShortCpuName() {
        const fullName = DgopService.cpuModel || "CPU";
        
        // Remove common prefixes and suffixes
        let shortName = fullName
            .replace(/^AMD\s+/i, "")  // Remove "AMD " prefix
            .replace(/^Intel\s+/i, "") // Remove "Intel " prefix
            .replace(/\s+Processor$/i, "") // Remove " Processor" suffix
            .replace(/\s+CPU$/i, "") // Remove " CPU" suffix
            .replace(/\s+@.*$/i, "") // Remove "@ 3.2GHz" type suffixes
            .replace(/\s+\d+-Core.*$/i, "") // Remove " 12-Core Processor" type suffixes
            .replace(/\s+\d+Core.*$/i, "") // Remove " 12Core Processor" type suffixes
            .replace(/\s+Core.*$/i, "") // Remove " Core Processor" type suffixes
            .trim();
        
        // If we removed everything, fall back to original
        if (!shortName) return fullName;
        
        return shortName;
    }
    
    // Function to shorten GPU name
    function getShortGpuName() {
        if (!DgopService.availableGpus || DgopService.availableGpus.length === 0) {
            return "GPU";
        }
        
        const fullName = DgopService.availableGpus[0].displayName || "GPU";
        
        // Remove common prefixes
        let shortName = fullName
            .replace(/^NVIDIA\s+GeForce\s+/i, "") // Remove "NVIDIA GeForce " prefix
            .replace(/^GeForce\s+/i, "") // Remove "GeForce " prefix (in case NVIDIA was already removed)
            .replace(/^AMD\s+Radeon\s+/i, "") // Remove "AMD Radeon " prefix
            .replace(/^Radeon\s+/i, "") // Remove "Radeon " prefix (in case AMD was already removed)
            .replace(/^Intel\s+Arc\s+/i, "") // Remove "Intel Arc " prefix
            .replace(/^Intel\s+UHD\s+/i, "") // Remove "Intel UHD " prefix
            .replace(/^Intel\s+HD\s+/i, "") // Remove "Intel HD " prefix
            .replace(/^NVIDIA\s+/i, "") // Remove "NVIDIA " prefix (fallback)
            .replace(/^AMD\s+/i, "") // Remove "AMD " prefix (fallback)
            .replace(/^Intel\s+/i, "") // Remove "Intel " prefix (fallback)
            .trim();
        
        // If we removed everything, fall back to original
        if (!shortName) return fullName;
        
        return shortName;
    }

    // Function to start NVML monitoring
    function startNvmlMonitoring() {
        nvmlGpuProcess.running = true;
    }

    Component.onDestruction: {
        DgopService.removeRef(["cpu", "memory", "gpu"]);
    }

    // NVML GPU temperature monitoring process
    Process {
        id: nvmlGpuProcess
        command: ["/home/matt/.config/quickshell/nvml_env/bin/python", "/home/matt/.config/quickshell/scripts/nvidia_gpu_temp.py"]
        running: false
        onExited: exitCode => {
            // Process completed
        }
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim()) {
                    try {
                        const data = JSON.parse(text.trim());
                        if (data.gpus && Array.isArray(data.gpus)) {
                            if (!DgopService.availableGpus || DgopService.availableGpus.length === 0) {
                                const gpuList = [];
                                for (const gpu of data.gpus) {
                                    gpuList.push({
                                        "driver": gpu.driver || "nvidia",
                                        "vendor": gpu.vendor || "NVIDIA",
                                        "displayName": gpu.displayName || gpu.name || "Unknown GPU",
                                        "fullName": gpu.fullName || gpu.name || "Unknown GPU",
                                        "pciId": gpu.pciId || "",
                                        "temperature": gpu.temperature || 0,
                                        "memoryUsed": gpu.memoryUsed || 0,
                                        "memoryTotal": gpu.memoryTotal || 0,
                                        "memoryUsedMB": gpu.memoryUsedMB || 0,
                                        "memoryTotalMB": gpu.memoryTotalMB || 0
                                    });
                                }
                                DgopService.availableGpus = gpuList;
                            } else {
                                const updatedGpus = DgopService.availableGpus.slice();
                                for (var i = 0; i < updatedGpus.length; i++) {
                                    const existingGpu = updatedGpus[i];
                                    let nvmlGpu = data.gpus.find(g => g.pciId === existingGpu.pciId);
                                    if (!nvmlGpu && i < data.gpus.length) {
                                        nvmlGpu = data.gpus[i];
                                    }
                                    if (nvmlGpu) {
                                        updatedGpus[i] = Object.assign({}, existingGpu, {
                                            "temperature": nvmlGpu.temperature || 0,
                                            "memoryUsed": nvmlGpu.memoryUsed || 0,
                                            "memoryTotal": nvmlGpu.memoryTotal || 0,
                                            "memoryUsedMB": nvmlGpu.memoryUsedMB || 0,
                                            "memoryTotalMB": nvmlGpu.memoryTotalMB || 0
                                        });
                                    }
                                }
                                DgopService.availableGpus = updatedGpus;
                            }
                        }
                    } catch (e) {
                        // Failed to parse JSON
                    }
                }
            }
        }
    }

    // Timer for regular NVML updates
    Timer {
        id: nvmlUpdateTimer
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            nvmlGpuProcess.running = true;
        }
    }

    // Main widget container - clean and professional like settings
    Rectangle {
        width: widgetWidth
        height: widgetHeight
        radius: Theme.cornerRadius * scaleFactor
        color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.85)
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.3)
        border.width: 1
        opacity: widgetOpacity

        // Subtle drop shadow
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 4
            radius: 12
            samples: 16
            color: Qt.rgba(0, 0, 0, 0.2)
            transparentBorder: true
        }

        // Clean content layout
        Column {
            anchors.fill: parent
            anchors.margins: scaledPadding
            spacing: scaledSpacing

            // Header
            Row {
                width: parent.width
                spacing: scaledSpacing
                
                DankIcon {
                    name: "computer"
                    size: 20 * scaleFactor
                    color: Theme.surfaceText
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                StyledText {
                    text: "System Monitor"
                    font.pixelSize: 16 * scaleFactor
                    color: "white"
                    font.weight: Font.Bold
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            
            // Clean metrics grid
            Grid {
                width: parent.width
                columns: 2
                spacing: scaledSpacing
                
                // CPU Section
                Rectangle {
                    width: (parent.width - parent.spacing) / 2
                    height: 60 * scaleFactor
                    radius: 8 * scaleFactor
                    color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                    border.width: 1
                    
                    Column {
                        anchors.fill: parent
                        anchors.margins: 8 * scaleFactor
                        spacing: 4 * scaleFactor
                        
                        // CPU Name at top
                        StyledText {
                            text: getShortCpuName()
                            font.pixelSize: 12 * scaleFactor
                            color: "white"
                            font.weight: Font.Medium
                            anchors.horizontalCenter: parent.horizontalCenter
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }
                        
                        // Spacer to push values to center
                        Item {
                            height: parent.height * 0.2
                        }
                        
                        // CPU Usage and Temperature
                        StyledText {
                            text: Math.round(currentCpuUsage) + "%    " + (currentCpuTemperature > 0 ? Math.round(currentCpuTemperature) + "°C" : "--°C")
                            font.pixelSize: 16 * scaleFactor
                            font.weight: Font.Bold
                            color: {
                                if (currentCpuTemperature > 80) return "#ff6b6b"
                                if (currentCpuTemperature > 65) return "#ffa726"
                                return "white"
                            }
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }

                // GPU Section
                Rectangle {
                    width: (parent.width - parent.spacing) / 2
                    height: 60 * scaleFactor
                    radius: 8 * scaleFactor
                    color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                    border.width: 1
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 4 * scaleFactor
                        
                        StyledText {
                            text: getShortGpuName()
                            font.pixelSize: 12 * scaleFactor
                            color: "white"
                            font.weight: Font.Medium
                            anchors.horizontalCenter: parent.horizontalCenter
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }
                        
                        StyledText {
                            text: {
                                if (currentGpuTemperature > 0) {
                                    return Math.round(currentGpuTemperature) + "°"
                                }
                                return "--°"
                            }
                            font.pixelSize: 18 * scaleFactor
                            font.weight: Font.Bold
                            color: {
                                if (currentGpuTemperature > 85) return "#ff6b6b"
                                if (currentGpuTemperature > 70) return "#ffa726"
                                return "white"
                            }
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        StyledText {
                            text: {
                                if (currentGpuMemoryTotal > 0) {
                                    const usedGB = (currentGpuMemoryUsed / 1024).toFixed(1)
                                    const totalGB = (currentGpuMemoryTotal / 1024).toFixed(1)
                                    return usedGB + "GB/" + totalGB + "GB"
                                }
                                return currentGpuTemperature > 0 ? "Active" : "Offline"
                            }
                            font.pixelSize: 10 * scaleFactor
                            color: currentGpuTemperature > 0 ? "white" : "#888888"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }

                // RAM Section
                Rectangle {
                    width: (parent.width - parent.spacing) / 2
                    height: 60 * scaleFactor
                    radius: 8 * scaleFactor
                    color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                    border.width: 1
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 4 * scaleFactor
                        
                        StyledText {
                            text: "RAM"
                            font.pixelSize: 12 * scaleFactor
                            color: "white"
                            font.weight: Font.Medium
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        StyledText {
                            text: {
                                const usedGB = (DgopService.usedMemoryMB || 0) / 1024
                                const totalGB = (DgopService.totalMemoryMB || 0) / 1024
                                return usedGB.toFixed(1) + "GB/" + totalGB.toFixed(0) + "GB"
                            }
                            font.pixelSize: 18 * scaleFactor
                            font.weight: Font.Bold
                            color: {
                                if (currentMemoryUsage > 90) return "#ff6b6b"
                                if (currentMemoryUsage > 75) return "#ffa726"
                                return "white"
                            }
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        // Memory Usage Bar
                        Rectangle {
                            width: parent.width - 16 * scaleFactor
                            height: 3 * scaleFactor
                            radius: 1.5 * scaleFactor
                            color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                            anchors.horizontalCenter: parent.horizontalCenter

                            Rectangle {
                                width: parent.width * (currentMemoryUsage / 100)
                                height: parent.height
                                radius: parent.radius
                                color: {
                                    if (currentMemoryUsage > 90) return "#ff6b6b"
                                    if (currentMemoryUsage > 75) return "#ffa726"
                                    return "white"
                                }
                            }
                        }
                    }
                }

                // Network Section
                Rectangle {
                    width: (parent.width - parent.spacing) / 2
                    height: 60 * scaleFactor
                    radius: 8 * scaleFactor
                    color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                    border.width: 1
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 4 * scaleFactor
                        
                        StyledText {
                            text: "Network"
                            font.pixelSize: 12 * scaleFactor
                            color: "white"
                            font.weight: Font.Medium
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        StyledText {
                            text: {
                                const downloadSpeed = currentNetworkDownloadSpeed || 0
                                if (downloadSpeed === 0) return "0 KB/s"
                                
                                if (downloadSpeed >= 1024 * 1024) {
                                    return (downloadSpeed / 1024 / 1024).toFixed(1) + " MB/s"
                                } else {
                                    return (downloadSpeed / 1024).toFixed(1) + " KB/s"
                                }
                            }
                            font.pixelSize: 16 * scaleFactor
                            font.weight: Font.Bold
                            color: "white"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        StyledText {
                            text: {
                                const uploadSpeed = currentNetworkUploadSpeed || 0
                                if (uploadSpeed === 0) return "↑0 KB/s"
                                
                                if (uploadSpeed >= 1024 * 1024) {
                                    return "↑" + (uploadSpeed / 1024 / 1024).toFixed(1) + " MB/s"
                                } else {
                                    return "↑" + (uploadSpeed / 1024).toFixed(1) + " KB/s"
                                }
                            }
                            font.pixelSize: 10 * scaleFactor
                            color: "#888888"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
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
                    // Widget is always visible, no need to show/hide
                }
            }
        }
    }
}
