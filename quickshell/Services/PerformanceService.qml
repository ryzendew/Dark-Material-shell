pragma Singleton

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

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
        
        Qt.callLater(() => {
            isChanging = false
        })
    }

    function applyPowerSaverSettings() {
        
        Quickshell.execDetached(["sudo", "cpupower", "frequency-set", "-g", "powersave"])
        
        Quickshell.execDetached(["sudo", "cpupower", "frequency-set", "-u", "1.5GHz"])
        
        Quickshell.execDetached(["sudo", "sh", "-c", "echo 0 > /sys/devices/system/cpu/cpufreq/boost"])
        
        Quickshell.execDetached(["nvidia-smi", "-pl", "80"])
        
        Quickshell.execDetached(["systemctl", "--user", "set-property", "powertop", "CPUGovernor=powersave"])
    }

    function applyBalancedSettings() {
        
        Quickshell.execDetached(["sudo", "cpupower", "frequency-set", "-g", "ondemand"])
        
        Quickshell.execDetached(["sudo", "cpupower", "frequency-set", "-u", "3.0GHz"])
        
        Quickshell.execDetached(["sudo", "sh", "-c", "echo 1 > /sys/devices/system/cpu/cpufreq/boost"])
        
        Quickshell.execDetached(["nvidia-smi", "-pl", "150"])
        
        Quickshell.execDetached(["systemctl", "--user", "set-property", "powertop", "CPUGovernor=ondemand"])
    }

    function applyPerformanceSettings() {
        
        Quickshell.execDetached(["sudo", "cpupower", "frequency-set", "-g", "performance"])
        
        Quickshell.execDetached(["sudo", "cpupower", "frequency-set", "-u", "4.0GHz"])
        
        Quickshell.execDetached(["sudo", "sh", "-c", "echo 1 > /sys/devices/system/cpu/cpufreq/boost"])
        
        Quickshell.execDetached(["nvidia-smi", "-pl", "200"])
        
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
