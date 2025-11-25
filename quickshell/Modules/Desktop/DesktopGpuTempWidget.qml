import QtQuick
import QtCore
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
    property real widgetWidth: SettingsData.desktopWidgetWidth
    property real widgetHeight: SettingsData.desktopWidgetHeight
    property bool alwaysVisible: true
    property string position: "top-center"
    property var positioningBox: null
    
    // Reactive property that updates when GPU data changes
    property real currentGpuTemperature: getSelectedGpuTemperature()

    implicitWidth: widgetWidth
    implicitHeight: widgetHeight
    visible: alwaysVisible

    WlrLayershell.layer: WlrLayershell.Background
    WlrLayershell.namespace: "quickshell:desktop:gpuTemp"
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
        DgopService.addRef(["gpu"]);
        startNvmlMonitoring();
    }

    // Update temperature when GPU data changes
    Connections {
        target: DgopService
        function onAvailableGpusChanged() {
            currentGpuTemperature = getSelectedGpuTemperature();
        }
    }

    // Update temperature when GPU selection changes
    Connections {
        target: SettingsData
        function onDesktopGpuSelectionChanged() {
            currentGpuTemperature = getSelectedGpuTemperature();
        }
    }

    // Function to start NVML monitoring
    function startNvmlMonitoring() {
        if (nvmlGpuProcess.running) {
            return;
        }
        nvmlGpuProcess.running = true;
    }

    // Function to get temperature for selected GPU
    function getSelectedGpuTemperature() {
        if (!DgopService.availableGpus || DgopService.availableGpus.length === 0) {
            return -1;
        }
        
        if (SettingsData.desktopGpuSelection === "auto") {
            // Return first available GPU temperature
            const gpu = DgopService.availableGpus[0];
            const temp = gpu.temperature !== undefined ? gpu.temperature : -1;
            return temp;
        }
        
        // Find GPU by matching the selection string with available GPUs
        const options = SettingsData.getGpuDropdownOptions();
        const selectedIndex = options.indexOf(SettingsData.desktopGpuSelection);
        
        if (selectedIndex > 0 && selectedIndex <= DgopService.availableGpus.length) {
            // selectedIndex - 1 because options[0] is "auto"
            const gpuIndex = selectedIndex - 1;
            const gpu = DgopService.availableGpus[gpuIndex];
            const temp = gpu.temperature || -1;
            return temp;
        }
        
        return -1;
    }
    
    Component.onDestruction: {
        DgopService.removeRef(["gpu"]);
    }

    readonly property string configDir: Paths.strip(StandardPaths.writableLocation(StandardPaths.ConfigLocation))
    readonly property string nvmlPythonPath: "python3"
    readonly property string nvmlScriptPath: configDir + "/quickshell/scripts/nvidia_gpu_temp.py"

    // NVML GPU temperature monitoring process
    Process {
        id: nvmlGpuProcess
        command: [nvmlPythonPath, nvmlScriptPath]
        running: false
        onExited: exitCode => {
            if (exitCode !== 0) {
                console.warn("DesktopGpuTempWidget: NVML GPU process failed with exit code:", exitCode);
            }
        }
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim()) {
                    try {
                        const data = JSON.parse(text.trim());
                        if (data.gpus && Array.isArray(data.gpus)) {
                            // If no GPUs are available yet, initialize them
                            if (!DgopService.availableGpus || DgopService.availableGpus.length === 0) {
                                const gpuList = [];
                                for (const gpu of data.gpus) {
                                    gpuList.push({
                                        "driver": gpu.driver || "nvidia",
                                        "vendor": gpu.vendor || "NVIDIA",
                                        "displayName": gpu.displayName || gpu.name || "Unknown GPU",
                                        "fullName": gpu.fullName || gpu.name || "Unknown GPU",
                                        "pciId": gpu.pciId || "",
                                        "temperature": gpu.temperature || 0
                                    });
                                }
                                DgopService.availableGpus = gpuList;
                            } else {
                                // Update existing GPU temperature data
                                const updatedGpus = DgopService.availableGpus.slice();
                                for (var i = 0; i < updatedGpus.length; i++) {
                                    const existingGpu = updatedGpus[i];
                                    // Try to find matching GPU by PCI ID or by index if PCI IDs don't match
                                    let nvmlGpu = data.gpus.find(g => g.pciId === existingGpu.pciId);
                                    if (!nvmlGpu && i < data.gpus.length) {
                                        // Fallback to index-based matching
                                        nvmlGpu = data.gpus[i];
                                    }
                                    if (nvmlGpu) {
                                        updatedGpus[i] = Object.assign({}, existingGpu, {
                                            "temperature": nvmlGpu.temperature || 0
                                        });
                                    }
                                }
                                DgopService.availableGpus = updatedGpus;
                            }
                        } else if (data.error) {
                            console.warn("DesktopGpuTempWidget: NVML error:", data.error);
                        }
                    } catch (e) {
                        console.warn("DesktopGpuTempWidget: Failed to parse NVML JSON:", e);
                    }
                }
            }
        }
    }

    // Timer for regular NVML updates
    Timer {
        id: nvmlUpdateTimer
        interval: 2000  // Update every 2 seconds
        running: true
        repeat: true
        onTriggered: {
            nvmlGpuProcess.running = true;
        }
    }

    Rectangle {
        width: widgetWidth
        height: widgetHeight
        radius: Theme.cornerRadius
        color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.9)
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.3)
        border.width: 1

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

            DarkIcon {
                name: "memory"
                size: SettingsData.desktopWidgetIconSize
                color: {
                    if (currentGpuTemperature > 85) {
                        return Theme.tempDanger;
                    }
                    if (currentGpuTemperature > 69) {
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
                    text: "GPU"
                    font.pixelSize: SettingsData.desktopWidgetFontSize - 2
                    color: Theme.surfaceTextMedium
                    font.weight: Font.Medium
                }

                StyledText {
                    text: {
                        if (currentGpuTemperature === undefined || currentGpuTemperature === null || currentGpuTemperature < 0) {
                            return "--°";
                        }
                        return Math.round(currentGpuTemperature) + "°";
                    }
                    font.pixelSize: SettingsData.desktopWidgetFontSize + 2
                    font.weight: Font.Bold
                    color: {
                        if (currentGpuTemperature > 85) {
                            return Theme.tempDanger;
                        }
                        if (currentGpuTemperature > 69) {
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
