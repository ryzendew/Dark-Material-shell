pragma Singleton

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common

Singleton {
    id: root

    property var availableUpdates: []
    property bool isChecking: false
    property bool hasError: false
    property string errorMessage: ""
    property string pkgManager: ""
    property string distribution: ""
    property bool distributionSupported: false

    readonly property list<string> supportedDistributions: ["arch", "cachyos", "manjaro", "endeavouros"]
    readonly property int updateCount: availableUpdates.length
    readonly property bool helperAvailable: pkgManager !== "" && distributionSupported

    Process {
        id: distributionDetection
        command: ["sh", "-c", "cat /etc/os-release | grep '^ID=' | cut -d'=' -f2 | tr -d '\"'"]
        running: true

        onExited: (exitCode) => {
            if (exitCode === 0) {
                distribution = stdout.text.trim().toLowerCase()
                distributionSupported = supportedDistributions.includes(distribution)

                if (distributionSupported) {
                    helperDetection.running = true
                } else {
                }
            } else {
            }
        }

        stdout: StdioCollector {}
    }

    Process {
        id: helperDetection
        command: ["sh", "-c", "which paru || which yay"]

        onExited: (exitCode) => {
            if (exitCode === 0) {
                const helperPath = stdout.text.trim()
                var detectedHelper = helperPath.split('/').pop()
                
                if (SettingsData.aurHelper && SettingsData.aurHelper !== "") {
                    pkgManager = SettingsData.aurHelper
                } else {
                    pkgManager = detectedHelper
                }
                checkForUpdates()
            } else {
                if (SettingsData.aurHelper && SettingsData.aurHelper !== "") {
                    pkgManager = SettingsData.aurHelper
                    checkForUpdates()
                } else {
                }
            }
        }

        stdout: StdioCollector {}
    }
    
    Connections {
        target: SettingsData
        function onAurHelperChanged() {
            if (SettingsData.aurHelper && SettingsData.aurHelper !== "") {
                pkgManager = SettingsData.aurHelper
                if (distributionSupported) {
                    checkForUpdates()
                }
            }
        }
    }

    Process {
        id: updateChecker

        onExited: (exitCode) => {
            isChecking = false
            if (exitCode === 0 || exitCode === 1) {
                parseUpdates(stdout.text)
                hasError = false
                errorMessage = ""
            } else {
                hasError = true
                errorMessage = "Failed to check for updates"
            }
        }

        stdout: StdioCollector {}
    }

    Process {
        id: updater
        onExited: (exitCode) => {
            checkForUpdates()
        }
    }

    function checkForUpdates() {
        if (!distributionSupported || !pkgManager || isChecking) return

        isChecking = true
        hasError = false
        updateChecker.command = [pkgManager, "-Qu"]
        updateChecker.running = true
    }

    function parseUpdates(output) {
        const lines = output.trim().split('\n').filter(line => line.trim())
        const updates = []

        for (const line of lines) {
            const match = line.match(/^(\S+)\s+([^\s]+)\s+->\s+([^\s]+)$/)
            if (match) {
                updates.push({
                    name: match[1],
                    currentVersion: match[2],
                    newVersion: match[3],
                    description: `${match[1]} ${match[2]} → ${match[3]}`
                })
            }
        }

        availableUpdates = updates
    }

    function runUpdates() {
        if (!distributionSupported || !pkgManager || updateCount === 0) return

        const terminal = (SettingsData.terminalEmulator && SettingsData.terminalEmulator !== "") 
            ? SettingsData.terminalEmulator 
            : (Quickshell.env("TERMINAL") || "xterm")
        const updateCommand = `${pkgManager} -Syu && echo "Updates complete! Press Enter to close..." && read`

        updater.command = [terminal, "-e", "sh", "-c", updateCommand]
        updater.running = true
    }

    Timer {
        interval: 30 * 60 * 1000
        repeat: true
        running: distributionSupported && pkgManager
        onTriggered: checkForUpdates()
    }
}