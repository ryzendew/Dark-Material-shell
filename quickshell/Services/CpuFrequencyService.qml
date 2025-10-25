pragma Singleton

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property real currentFrequency: 0.0
    property real maxFrequency: 0.0
    property string governor: ""
    property bool isChanging: false

    signal frequencyChanged()

    Timer {
        id: frequencyTimer
        interval: 2000 // Update every 2 seconds
        running: true
        repeat: true
        onTriggered: {
            updateCpuInfo()
        }
    }

    function updateCpuInfo() {
        // Try to read CPU frequency directly from file
        try {
            const freqFile = Quickshell.readFile("/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq")
            if (freqFile) {
                const freq = parseInt(freqFile.trim())
                const newFreq = freq / 1000.0 // Convert from kHz to GHz
                if (newFreq !== currentFrequency && newFreq > 0) {
                    currentFrequency = newFreq
                    frequencyChanged()
                    // console.log("CpuFrequencyService: Updated frequency to", newFreq, "GHz")
                }
            }
        } catch (e) {
            // console.log("CpuFrequencyService: Could not read CPU frequency file:", e)
        }

        // Try to read CPU governor
        try {
            const govFile = Quickshell.readFile("/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor")
            if (govFile) {
                const newGov = govFile.trim()
                if (newGov !== governor) {
                    governor = newGov
                    // console.log("CpuFrequencyService: Updated governor to", newGov)
                }
            }
        } catch (e) {
            // console.log("CpuFrequencyService: Could not read CPU governor file:", e)
        }

        // Try to read max frequency
        try {
            const maxFreqFile = Quickshell.readFile("/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq")
            if (maxFreqFile) {
                const freq = parseInt(maxFreqFile.trim())
                const newMaxFreq = freq / 1000.0 // Convert from kHz to GHz
                if (newMaxFreq !== maxFrequency && newMaxFreq > 0) {
                    maxFrequency = newMaxFreq
                    // console.log("CpuFrequencyService: Updated max frequency to", newMaxFreq, "GHz")
                }
            }
        } catch (e) {
            // console.log("CpuFrequencyService: Could not read max CPU frequency file:", e)
        }
    }

    Component.onCompleted: {
        // console.log("CpuFrequencyService: Component completed, starting frequency monitoring")
        // Get initial values
        updateCpuInfo()
    }

    // IPC handler for external queries
    IpcHandler {
        target: "cpufreq"

        function getfreq(): string {
            return currentFrequency.toFixed(2)
        }

        function getgovernor(): string {
            return governor
        }

        function getmaxfreq(): string {
            return maxFrequency.toFixed(2)
        }
    }
}