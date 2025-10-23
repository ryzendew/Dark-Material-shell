pragma Singleton

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Performance modes
    readonly property var modes: [
        {
            "id": "power-saver",
            "name": "Powersave",
            "icon": "battery_saver",
            "color": "#00BCD4"
        },
        {
            "id": "balanced",
            "name": "Balanced",
            "icon": "balance",
            "color": "#FFC107"
        },
        {
            "id": "performance",
            "name": "Performance",
            "icon": "speed",
            "color": "#8BC34A"
        }
    ]

    property string currentMode: "balanced"
    property bool isChanging: false

    signal modeChanged(string newMode)

    function setMode(modeId) {
        if (isChanging) return
        
        isChanging = true
        currentMode = modeId
        
        console.log("PerformanceService: Setting mode to", modeId)
        
        // Apply power management settings based on mode
        switch(modeId) {
            case "power-saver":
                applyPowerSaverSettings()
                break
            case "balanced":
                applyBalancedSettings()
                break
            case "performance":
                applyPerformanceSettings()
                break
        }
        
        modeChanged(modeId)
        
        // Reset changing flag after a delay
        Qt.callLater(() => {
            isChanging = false
        })
    }

    function applyPowerSaverSettings() {
        console.log("PerformanceService: Applying power saver settings")
        
        // CPU governor to powersave
        Quickshell.execDetached(["sudo", "cpupower", "frequency-set", "-g", "powersave"])
        
        // Set CPU frequency limits (example values, adjust for your system)
        Quickshell.execDetached(["sudo", "cpupower", "frequency-set", "-u", "1.5GHz"])
        
        // Disable turbo boost
        Quickshell.execDetached(["sudo", "sh", "-c", "echo 0 > /sys/devices/system/cpu/cpufreq/boost"])
        
        // Set GPU power limit (if nvidia-smi is available)
        Quickshell.execDetached(["nvidia-smi", "-pl", "80"])
        
        // Set system power profile
        Quickshell.execDetached(["systemctl", "--user", "set-property", "powertop", "CPUGovernor=powersave"])
    }

    function applyBalancedSettings() {
        console.log("PerformanceService: Applying balanced settings")
        
        // CPU governor to ondemand
        Quickshell.execDetached(["sudo", "cpupower", "frequency-set", "-g", "ondemand"])
        
        // Remove CPU frequency limits
        Quickshell.execDetached(["sudo", "cpupower", "frequency-set", "-u", "3.0GHz"])
        
        // Enable turbo boost
        Quickshell.execDetached(["sudo", "sh", "-c", "echo 1 > /sys/devices/system/cpu/cpufreq/boost"])
        
        // Set GPU power limit to default
        Quickshell.execDetached(["nvidia-smi", "-pl", "150"])
        
        // Set system power profile
        Quickshell.execDetached(["systemctl", "--user", "set-property", "powertop", "CPUGovernor=ondemand"])
    }

    function applyPerformanceSettings() {
        console.log("PerformanceService: Applying performance settings")
        
        // CPU governor to performance
        Quickshell.execDetached(["sudo", "cpupower", "frequency-set", "-g", "performance"])
        
        // Remove CPU frequency limits
        Quickshell.execDetached(["sudo", "cpupower", "frequency-set", "-u", "4.0GHz"])
        
        // Enable turbo boost
        Quickshell.execDetached(["sudo", "sh", "-c", "echo 1 > /sys/devices/system/cpu/cpufreq/boost"])
        
        // Set GPU power limit to maximum
        Quickshell.execDetached(["nvidia-smi", "-pl", "200"])
        
        // Set system power profile
        Quickshell.execDetached(["systemctl", "--user", "set-property", "powertop", "CPUGovernor=performance"])
    }

    function getCurrentModeInfo() {
        for (var i = 0; i < modes.length; i++) {
            if (modes[i].id === currentMode) {
                return modes[i]
            }
        }
        return modes[1] // Return balanced as default
    }

    // IPC handler for external control
    IpcHandler {
        target: "performance"

        function setmode(mode: string): string {
            if (["power-saver", "balanced", "performance"].includes(mode)) {
                root.setMode(mode)
                return `Performance mode set to ${mode}`
            }
            return "Invalid mode. Use: power-saver, balanced, or performance"
        }

        function getmode(): string {
            return root.currentMode
        }

        function listmodes(): string {
            return JSON.stringify(root.modes)
        }
    }
}
