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
        try {
            const freqFile = Quickshell.readFile("/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq")
            if (freqFile) {
                const freq = parseInt(freqFile.trim())
                const newFreq = freq / 1000.0 // Convert from kHz to GHz
                if (newFreq !== currentFrequency && newFreq > 0) {
                    currentFrequency = newFreq
                    frequencyChanged()
                }
            }
        } catch (e) {
        }

        try {
            const govFile = Quickshell.readFile("/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor")
            if (govFile) {
                const newGov = govFile.trim()
                if (newGov !== governor) {
                    governor = newGov
                }
            }
        } catch (e) {
        }

        try {
            const maxFreqFile = Quickshell.readFile("/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq")
            if (maxFreqFile) {
                const freq = parseInt(maxFreqFile.trim())
                const newMaxFreq = freq / 1000.0 // Convert from kHz to GHz
                if (newMaxFreq !== maxFrequency && newMaxFreq > 0) {
                    maxFrequency = newMaxFreq
                }
            }
        } catch (e) {
        }
    }

    Component.onCompleted: {
        updateCpuInfo()
    }

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