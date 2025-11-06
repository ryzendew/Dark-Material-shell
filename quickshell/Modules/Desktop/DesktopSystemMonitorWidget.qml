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
    property real widgetWidth: 512
    property real widgetHeight: 512
    property bool alwaysVisible: SettingsData.desktopSystemMonitorEnabled
    property string position: SettingsData.desktopSystemMonitorPosition
    property real widgetOpacity: SettingsData.desktopSystemMonitorOpacity
    property var positioningBox: null
    
    // Dynamic sizing based on widget dimensions
    property real scaleFactor: Math.min(widgetWidth / 512, widgetHeight / 512)
    property real baseFontSize: 16
    property real scaledFontSize: baseFontSize * scaleFactor
    property real baseSpacing: 16
    property real scaledSpacing: baseSpacing * scaleFactor
    property real basePadding: 20
    property real scaledPadding: basePadding * scaleFactor
    
    // Fixed height for 512x512 widget
    property real contentHeight: 512
    
    // System data properties
    property real currentCpuTemperature: DgopService.cpuTemperature || 0
    property real currentGpuTemperature: (DgopService.availableGpus && DgopService.availableGpus.length > 0) ? (DgopService.availableGpus[0].temperature || -1) : -1
    property real currentGpuMemoryUsed: (DgopService.availableGpus && DgopService.availableGpus.length > 0) ? (DgopService.availableGpus[0].memoryUsedMB || 0) : 0
    property real currentGpuMemoryTotal: (DgopService.availableGpus && DgopService.availableGpus.length > 0) ? (DgopService.availableGpus[0].memoryTotalMB || 0) : 0
    property real currentCpuUsage: DgopService.cpuUsage || 0
    property real currentMemoryUsage: DgopService.memoryUsage || 0
    property real currentNetworkDownloadSpeed: DgopService.networkRxRate || 0
    property real currentNetworkUploadSpeed: DgopService.networkTxRate || 0
    
    // Graph data arrays for historical data
    property var cpuUsageHistory: []
    property var memoryUsageHistory: []
    property var gpuMemoryHistory: []
    property var networkHistory: []
    property int maxHistoryPoints: 20

    implicitWidth: widgetWidth
    implicitHeight: contentHeight
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
        
        // Initialize graphs with some sample data
        for (var i = 0; i < 5; i++) {
            cpuUsageHistory.push(0);
            memoryUsageHistory.push(0);
            gpuMemoryHistory.push(0);
            networkHistory.push(0);
        }
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
            .replace(/\s+Radeon\s+Graphics.*$/i, "") // Remove " Radeon Graphics" and anything after
            .replace(/\s+Graphics.*$/i, "") // Remove " Graphics" and anything after
            .replace(/\s+with.*$/i, "") // Remove " with" and anything after
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
        
        const gpu = DgopService.availableGpus[0];
        const fullName = gpu.displayName || "GPU";
        
        // Check if this is a Radeon GPU that might be disabled in BIOS
        const isRadeon = /radeon/i.test(fullName) || /amd/i.test(fullName);
        
        // If it's a Radeon GPU, check if it's actually functional
        // Radeon GPUs disabled in BIOS typically show no temperature or very low values
        if (isRadeon) {
            const temperature = gpu.temperature || -1;
            const memoryTotal = gpu.memoryTotalMB || 0;
            
            // If temperature is -1 or 0 and no memory, likely disabled in BIOS
            if (temperature <= 0 && memoryTotal === 0) {
                return ""; // Return empty string to hide the GPU section
            }
        }
        
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
            .replace(/\s*\/\s*Max-Q.*$/i, "") // Remove "/ Max-Q" and anything after
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

    // Timer for graph data updates
    Timer {
        id: graphUpdateTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            // Update CPU usage history
            cpuUsageHistory.push(currentCpuUsage);
            if (cpuUsageHistory.length > maxHistoryPoints) {
                cpuUsageHistory.shift();
            }
            cpuUsageHistoryChanged();
            
            // Update memory usage history
            memoryUsageHistory.push(currentMemoryUsage);
            if (memoryUsageHistory.length > maxHistoryPoints) {
                memoryUsageHistory.shift();
            }
            memoryUsageHistoryChanged();
            
            // Update GPU memory history
            const gpuMemoryPercent = currentGpuMemoryTotal > 0 ? (currentGpuMemoryUsed / currentGpuMemoryTotal) * 100 : 0;
            gpuMemoryHistory.push(gpuMemoryPercent);
            if (gpuMemoryHistory.length > maxHistoryPoints) {
                gpuMemoryHistory.shift();
            }
            gpuMemoryHistoryChanged();
            
            // Update network history
            const totalNetworkSpeed = (currentNetworkDownloadSpeed + currentNetworkUploadSpeed) / (1024 * 1024); // Convert to MB/s
            networkHistory.push(totalNetworkSpeed);
            if (networkHistory.length > maxHistoryPoints) {
                networkHistory.shift();
            }
            networkHistoryChanged();
        }
    }

    // Main widget container - professional design
    Rectangle {
        width: widgetWidth
        height: contentHeight
        radius: Theme.cornerRadius
        color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, widgetOpacity)
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.3)
        border.width: 1
        opacity: widgetOpacity

        // Professional gradient background
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(Theme.surfaceContainerHigh.r, Theme.surfaceContainerHigh.g, Theme.surfaceContainerHigh.b, widgetOpacity - 0.05) }
            GradientStop { position: 1.0; color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, widgetOpacity) }
        }

        // Enhanced drop shadow
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 8
            radius: 24
            samples: 32
            color: Qt.rgba(0, 0, 0, 0.4)
            transparentBorder: true
        }

        // Clean content layout
        Column {
            anchors.fill: parent
            anchors.margins: scaledPadding
            spacing: scaledSpacing

            // Professional Header
            Rectangle {
                width: parent.width
                height: 40 * scaleFactor
                color: "transparent"
                
                Row {
                    anchors.centerIn: parent
                    spacing: 12 * scaleFactor
                    
                    Rectangle {
                        width: 4 * scaleFactor
                        height: 20 * scaleFactor
                        radius: Theme.cornerRadius * 0.2
                        color: Theme.primary
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                StyledText {
                        text: "SYSTEM MONITOR"
                        font.pixelSize: 14 * scaleFactor
                        color: Theme.surfaceText
                    font.weight: Font.Bold
                        font.letterSpacing: 1.2
                    anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
            
            // Clean metrics grid - 2x2 layout for 512x512
            Grid {
                width: parent.width
                height: parent.height - 60 * scaleFactor // Leave space for header
                columns: 2
                rows: 2
                spacing: 16 * scaleFactor
                
                // CPU Section - Professional Design
                Rectangle {
                    width: (parent.width - parent.spacing) / 2
                    height: (parent.height - parent.spacing) / 2
                    radius: Theme.cornerRadius * 0.6
                    color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                    border.width: 1
                    
                    // Subtle inner glow
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 1
                        radius: parent.radius - 1
                        color: "transparent"
                        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.1) 
                        border.width: 1
                    }
                    
                    Column {
                        id: cpuContent
                        anchors.fill: parent
                        anchors.margins: 12 * scaleFactor
                        spacing: 8 * scaleFactor
                        
                        // CPU Name at top
                        StyledText {
                            text: getShortCpuName()
                            font.pixelSize: 16 * scaleFactor
                            color: Theme.surfaceTextMedium
                            font.weight: Font.Bold
                            anchors.horizontalCenter: parent.horizontalCenter
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }
                        
                        // CPU Usage Graph
                        Rectangle {
                            width: parent.width
                            height: 100 * scaleFactor
                            radius: Theme.cornerRadius * 0.3
                            color: Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0.8)
                            border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                            border.width: 1
                            anchors.horizontalCenter: parent.horizontalCenter
                            
                            Canvas {
                                id: cpuGraph
                                anchors.fill: parent
                                anchors.margins: 2
                                
                                onPaint: {
                                    var ctx = getContext("2d");
                                    ctx.clearRect(0, 0, width, height);
                                    
                                    if (cpuUsageHistory.length < 2) return;
                                    
                                    ctx.strokeStyle = currentCpuUsage > 90 ? Theme.tempDanger : (currentCpuUsage > 70 ? Theme.tempWarning : Theme.primary);
                                    ctx.lineWidth = 2;
                                    ctx.beginPath();
                                    
                                    var stepX = width / (maxHistoryPoints - 1);
                                    var maxValue = 100;
                                    
                                    for (var i = 0; i < cpuUsageHistory.length; i++) {
                                        var x = i * stepX;
                                        var y = height - (cpuUsageHistory[i] / maxValue) * height;
                                        
                                        if (i === 0) {
                                            ctx.moveTo(x, y);
                                        } else {
                                            ctx.lineTo(x, y);
                                        }
                                    }
                                    
                                    ctx.stroke();
                                }
                                
                                onWidthChanged: requestPaint();
                                onHeightChanged: requestPaint();
                            }
                            
                            Connections {
                                target: root
                                function onCpuUsageHistoryChanged() {
                                    cpuGraph.requestPaint();
                                }
                            }
                        }
                        
                        // Spacer
                        Item {
                            height: 8 * scaleFactor
                        }
                        
                        // CPU Temperature and Usage side by side
                        Item {
                            width: parent.width - 16 * scaleFactor
                            height: 50 * scaleFactor
                            
                            // CPU Temperature (left)
                            Column {
                                spacing: 2 * scaleFactor
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                
                                StyledText {
                                    text: "TEMP"
                                    font.pixelSize: 8 * scaleFactor
                                    color: Theme.surfaceTextMedium
                                    font.weight: Font.Bold
                                    font.letterSpacing: 0.5
                                }
                                
                                StyledText {
                                    text: currentCpuTemperature > 0 ? Math.round(currentCpuTemperature) + "°C" : "--°C"
                                    font.pixelSize: 24 * scaleFactor
                                    font.weight: Font.Bold
                                    color: {
                                        if (currentCpuTemperature > 80) return Theme.tempDanger
                                        if (currentCpuTemperature > 65) return Theme.tempWarning
                                        return Theme.surfaceText
                                    }
                                }
                            }
                            
                            // CPU Usage (right)
                            Column {
                                spacing: 2 * scaleFactor
                                anchors.right: parent.right
                                anchors.rightMargin: -9 * scaleFactor
                                anchors.verticalCenter: parent.verticalCenter
                                
                                StyledText {
                                    text: "USAGE"
                                    font.pixelSize: 8 * scaleFactor
                                    color: Theme.surfaceTextMedium
                                    font.weight: Font.Bold
                                    font.letterSpacing: 0.5
                                    anchors.right: parent.right
                                }
                                
                                StyledText {
                                    text: Math.round(currentCpuUsage) + "%"
                                    font.pixelSize: 24 * scaleFactor
                                    font.weight: Font.Bold
                                    color: Theme.surfaceText
                                    anchors.right: parent.right
                                }
                            }
                        }
                    }
                }

                // GPU Section - Professional Design
                Rectangle {
                    width: (parent.width - parent.spacing) / 2
                    height: (parent.height - parent.spacing) / 2
                    radius: Theme.cornerRadius * 0.6
                    color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                    border.width: 1
                    visible: getShortGpuName() !== ""
                    
                    // Subtle inner glow
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 1
                        radius: parent.radius - 1
                        color: "transparent"
                        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.1)
                        border.width: 1
                    }
                    
                    Column {
                        id: gpuContent
                        anchors.fill: parent
                        anchors.margins: 12 * scaleFactor
                        spacing: 8 * scaleFactor
                        
                        // GPU Name at top
                        StyledText {
                            text: getShortGpuName()
                            font.pixelSize: 16 * scaleFactor
                            color: Theme.surfaceTextMedium
                            font.weight: Font.Bold
                            anchors.horizontalCenter: parent.horizontalCenter
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }
                        
                        // GPU Memory Graph
                        Rectangle {
                            width: parent.width
                            height: 100 * scaleFactor
                            radius: Theme.cornerRadius * 0.3
                            color: Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0.8)
                            border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                            border.width: 1
                            anchors.horizontalCenter: parent.horizontalCenter
                            
                            Canvas {
                                id: gpuGraph
                                anchors.fill: parent
                                anchors.margins: 2
                                
                                onPaint: {
                                    var ctx = getContext("2d");
                                    ctx.clearRect(0, 0, width, height);
                                    
                                    if (gpuMemoryHistory.length < 2) return;
                                    
                                    ctx.strokeStyle = Theme.secondary;
                                    ctx.lineWidth = 2;
                                    ctx.beginPath();
                                    
                                    var stepX = width / (maxHistoryPoints - 1);
                                    var maxValue = 100;
                                    
                                    for (var i = 0; i < gpuMemoryHistory.length; i++) {
                                        var x = i * stepX;
                                        var y = height - (gpuMemoryHistory[i] / maxValue) * height;
                                        
                                        if (i === 0) {
                                            ctx.moveTo(x, y);
                                        } else {
                                            ctx.lineTo(x, y);
                                        }
                                    }
                                    
                                    ctx.stroke();
                                }
                                
                                onWidthChanged: requestPaint();
                                onHeightChanged: requestPaint();
                            }
                            
                            Connections {
                                target: root
                                function onGpuMemoryHistoryChanged() {
                                    gpuGraph.requestPaint();
                                }
                            }
                        }
                        
                        // Spacer
                        Item {
                            height: 8 * scaleFactor
                        }
                        
                        // GPU Temperature and Memory side by side
                        Item {
                            width: parent.width - 16 * scaleFactor
                            height: 50 * scaleFactor
                            
                            // GPU Temperature (left)
                            Column {
                                spacing: 2 * scaleFactor
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                
                                StyledText {
                                    text: "TEMP"
                                    font.pixelSize: 8 * scaleFactor
                                    color: Theme.surfaceTextMedium
                                    font.weight: Font.Bold
                                    font.letterSpacing: 0.5
                                }
                                
                                StyledText {
                                    text: currentGpuTemperature > 0 ? Math.round(currentGpuTemperature) + "°C" : "--°C"
                                    font.pixelSize: 20 * scaleFactor
                                    font.weight: Font.Bold
                                    color: {
                                        if (currentGpuTemperature > 85) return Theme.tempDanger
                                        if (currentGpuTemperature > 70) return Theme.tempWarning
                                        return Theme.surfaceText
                                    }
                                }
                            }
                            
                            // GPU Memory (right)
                            Column {
                                spacing: 2 * scaleFactor
                                anchors.right: parent.right
                                anchors.rightMargin: -9 * scaleFactor
                                anchors.verticalCenter: parent.verticalCenter
                                
                                StyledText {
                                    text: "VRAM"
                                    font.pixelSize: 8 * scaleFactor
                                    color: Theme.surfaceTextMedium
                                    font.weight: Font.Bold
                                    font.letterSpacing: 0.5
                                    anchors.right: parent.right
                                }
                                
                                StyledText {
                                    text: {
                                        if (currentGpuMemoryUsed > 0) {
                                            const usedGB = (currentGpuMemoryUsed / 1024).toFixed(1)
                                            return usedGB + "GB"
                                        }
                                        return currentGpuTemperature > 0 ? "Active" : "Offline"
                                    }
                                    font.pixelSize: 20 * scaleFactor
                                    font.weight: Font.Bold
                                    color: currentGpuTemperature > 0 ? Theme.surfaceText : Theme.surfaceTextMedium
                                    anchors.right: parent.right
                                }
                            }
                        }
                    }
                }

                // RAM Section - Professional Design
                Rectangle {
                    width: (parent.width - parent.spacing) / 2
                    height: (parent.height - parent.spacing) / 2
                    radius: Theme.cornerRadius * 0.6
                    color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                    border.width: 1
                    
                    // Subtle inner glow
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 1
                        radius: parent.radius - 1
                        color: "transparent"
                        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.1)
                        border.width: 1
                    }
                    
                    Column {
                        id: ramContent
                        anchors.fill: parent
                        anchors.margins: 12 * scaleFactor
                        spacing: 8 * scaleFactor
                        
                        // RAM Name at top
                        StyledText {
                            text: "RAM"
                            font.pixelSize: 16 * scaleFactor
                            color: Theme.surfaceTextMedium
                            font.weight: Font.Bold
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        // RAM Usage Graph
                        Rectangle {
                            width: parent.width
                            height: 100 * scaleFactor
                            radius: Theme.cornerRadius * 0.3
                            color: Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0.8)
                            border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                            border.width: 1
                            anchors.horizontalCenter: parent.horizontalCenter
                            
                            Canvas {
                                id: ramGraph
                                anchors.fill: parent
                                anchors.margins: 2
                                
                                onPaint: {
                                    var ctx = getContext("2d");
                                    ctx.clearRect(0, 0, width, height);
                                    
                                    if (memoryUsageHistory.length < 2) return;
                                    
                                    ctx.strokeStyle = currentMemoryUsage > 90 ? Theme.tempDanger : (currentMemoryUsage > 75 ? Theme.tempWarning : Theme.primary);
                                    ctx.lineWidth = 2;
                                    ctx.beginPath();
                                    
                                    var stepX = width / (maxHistoryPoints - 1);
                                    var maxValue = 100;
                                    
                                    for (var i = 0; i < memoryUsageHistory.length; i++) {
                                        var x = i * stepX;
                                        var y = height - (memoryUsageHistory[i] / maxValue) * height;
                                        
                                        if (i === 0) {
                                            ctx.moveTo(x, y);
                                        } else {
                                            ctx.lineTo(x, y);
                                        }
                                    }
                                    
                                    ctx.stroke();
                                }
                                
                                onWidthChanged: requestPaint();
                                onHeightChanged: requestPaint();
                            }
                            
                            Connections {
                                target: root
                                function onMemoryUsageHistoryChanged() {
                                    ramGraph.requestPaint();
                                }
                            }
                        }
                        
                        // Spacer
                        Item {
                            height: 8 * scaleFactor
                        }
                        
                        // RAM Usage and Total side by side
                        Item {
                            width: parent.width - 16 * scaleFactor
                            height: 50 * scaleFactor
                            
                            // RAM Usage (left)
                            Column {
                                spacing: 2 * scaleFactor
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                
                                StyledText {
                                    text: "USAGE"
                                    font.pixelSize: 8 * scaleFactor
                                    color: Theme.surfaceTextMedium
                                    font.weight: Font.Bold
                                    font.letterSpacing: 0.5
                                }
                                
                                StyledText {
                                    text: Math.round(currentMemoryUsage) + "%"
                                    font.pixelSize: 24 * scaleFactor
                                    font.weight: Font.Bold
                                    color: {
                                        if (currentMemoryUsage > 90) return Theme.tempDanger
                                        if (currentMemoryUsage > 75) return Theme.tempWarning
                                        return Theme.surfaceText
                                    }
                                }
                            }
                            
                            // RAM Total (right)
                            Column {
                                spacing: 2 * scaleFactor
                                anchors.right: parent.right
                                anchors.rightMargin: -9 * scaleFactor
                                anchors.verticalCenter: parent.verticalCenter
                                
                                StyledText {
                                    text: "TOTAL"
                                    font.pixelSize: 8 * scaleFactor
                                    color: Theme.surfaceTextMedium
                                    font.weight: Font.Bold
                                    font.letterSpacing: 0.5
                                    anchors.right: parent.right
                                }
                                
                                StyledText {
                                    text: {
                                        const usedGB = (DgopService.usedMemoryMB || 0) / 1024
                                        return usedGB.toFixed(1) + "GB"
                                    }
                                    font.pixelSize: 20 * scaleFactor
                                    font.weight: Font.Bold
                                    color: Theme.surfaceText
                                    anchors.right: parent.right
                                }
                            }
                        }
                    }
                }

                // Network Section - Professional Design
                Rectangle {
                    width: (parent.width - parent.spacing) / 2
                    height: (parent.height - parent.spacing) / 2
                    radius: Theme.cornerRadius * 0.6
                    color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                    border.width: 1
                    
                    // Subtle inner glow
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 1
                        radius: parent.radius - 1
                        color: "transparent"
                        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.1)
                        border.width: 1
                    }
                    
                    Column {
                        id: networkContent
                        anchors.fill: parent
                        anchors.margins: 12 * scaleFactor
                        spacing: 8 * scaleFactor
                        
                        // Network Name at top
                        StyledText {
                            text: "NETWORK"
                            font.pixelSize: 16 * scaleFactor
                            color: Theme.surfaceTextMedium
                            font.weight: Font.Bold
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        // Network Activity Graph
                        Rectangle {
                            width: parent.width
                            height: 100 * scaleFactor
                            radius: Theme.cornerRadius * 0.3
                            color: Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0.8)
                            border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                            border.width: 1
                            anchors.horizontalCenter: parent.horizontalCenter
                            
                            Canvas {
                                id: networkGraph
                                anchors.fill: parent
                                anchors.margins: 2
                                
                                onPaint: {
                                    var ctx = getContext("2d");
                                    ctx.clearRect(0, 0, width, height);
                                    
                                    if (networkHistory.length < 2) return;
                                    
                                    ctx.strokeStyle = Theme.primary;
                                    ctx.lineWidth = 2;
                                    ctx.beginPath();
                                    
                                    var stepX = width / (maxHistoryPoints - 1);
                                    var maxValue = 10; // 10 MB/s max for visualization
                                    
                                    for (var i = 0; i < networkHistory.length; i++) {
                                        var x = i * stepX;
                                        var y = height - Math.min((networkHistory[i] / maxValue) * height, height);
                                        
                                        if (i === 0) {
                                            ctx.moveTo(x, y);
                                        } else {
                                            ctx.lineTo(x, y);
                                        }
                                    }
                                    
                                    ctx.stroke();
                                }
                                
                                onWidthChanged: requestPaint();
                                onHeightChanged: requestPaint();
                            }
                            
                            Connections {
                                target: root
                                function onNetworkHistoryChanged() {
                                    networkGraph.requestPaint();
                                }
                            }
                        }
                        
                        // Spacer
                        Item {
                            height: 8 * scaleFactor
                        }
                        
                        // Download and Upload side by side
                        Item {
                            width: parent.width - 16 * scaleFactor
                            height: 50 * scaleFactor
                            
                            // Download Speed (left)
                            Column {
                                spacing: 2 * scaleFactor
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                
                                StyledText {
                                    text: "DOWN"
                                    font.pixelSize: 8 * scaleFactor
                                    color: Theme.surfaceTextMedium
                                    font.weight: Font.Bold
                                    font.letterSpacing: 0.5
                                }
                                
                                Row {
                                    spacing: 2 * scaleFactor
                                    
                                    StyledText {
                                        text: {
                                            const downloadSpeed = currentNetworkDownloadSpeed || 0
                                            if (downloadSpeed === 0) return "0"
                                            
                                            if (downloadSpeed >= 1024 * 1024) {
                                                return (downloadSpeed / 1024 / 1024).toFixed(1)
                                            } else {
                                                return (downloadSpeed / 1024).toFixed(1)
                                            }
                                        }
                                        font.pixelSize: 20 * scaleFactor
                                        font.weight: Font.Bold
                                        color: Theme.surfaceText
                                    }
                                    
                                    StyledText {
                                        text: {
                                            const downloadSpeed = currentNetworkDownloadSpeed || 0
                                            if (downloadSpeed >= 1024 * 1024) {
                                                return "MB/s"
                                            } else {
                                                return "KB/s"
                                            }
                                        }
                                        font.pixelSize: 12 * scaleFactor
                                        font.weight: Font.Bold
                                        color: Theme.surfaceText
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                            
                            // Upload Speed (right)
                            Column {
                                spacing: 2 * scaleFactor
                                anchors.right: parent.right
                                anchors.rightMargin: -9 * scaleFactor
                                anchors.verticalCenter: parent.verticalCenter
                                
                                StyledText {
                                    text: "UP"
                                    font.pixelSize: 8 * scaleFactor
                                    color: Theme.surfaceTextMedium
                                    font.weight: Font.Bold
                                    font.letterSpacing: 0.5
                                    anchors.right: parent.right
                                }
                                
                                Row {
                                    spacing: 2 * scaleFactor
                                    anchors.right: parent.right
                                    
                                    StyledText {
                                        text: {
                                            const uploadSpeed = currentNetworkUploadSpeed || 0
                                            if (uploadSpeed === 0) return "0"
                                            
                                            if (uploadSpeed >= 1024 * 1024) {
                                                return (uploadSpeed / 1024 / 1024).toFixed(1)
                                            } else {
                                                return (uploadSpeed / 1024).toFixed(1)
                                            }
                                        }
                                        font.pixelSize: 20 * scaleFactor
                                        font.weight: Font.Bold
                                        color: Theme.surfaceText
                                    }
                                    
                                    StyledText {
                                        text: {
                                            const uploadSpeed = currentNetworkUploadSpeed || 0
                                            if (uploadSpeed >= 1024 * 1024) {
                                                return "MB/s"
                                            } else {
                                                return "KB/s"
                                            }
                                        }
                                        font.pixelSize: 12 * scaleFactor
                                        font.weight: Font.Bold
                                        color: Theme.surfaceText
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
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
