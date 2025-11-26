pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string currentTimezone: ""
    property bool ntpEnabled: true
    property bool systemClockSynchronized: false
    property string ntpServiceStatus: "unknown"
    property string localTime: ""
    property string universalTime: ""
    property string rtcTime: ""
    property bool rtcInLocalTZ: false
    property var availableTimezones: []
    property bool isLoading: false
    property string lastError: ""

    function refreshStatus() {
        if (statusProcess.running) return
        statusProcess.running = true
    }

    function listTimezones() {
        if (timezoneListProcess.running) return
        timezoneListProcess.running = true
    }

    function setTimezone(timezone) {
        if (!timezone || timezone.length === 0) return
        setTimezoneProcess.command = ["timedatectl", "set-timezone", timezone]
        setTimezoneProcess.running = true
    }

    function setNTP(enabled) {
        setNTPProcess.command = ["timedatectl", "set-ntp", enabled ? "true" : "false"]
        setNTPProcess.running = true
    }

    function setTime(dateTime) {
        const timeStr = Qt.formatDateTime(dateTime, "yyyy-MM-dd HH:mm:ss")
        setTimeProcess.command = ["timedatectl", "set-time", timeStr]
        setTimeProcess.running = true
    }

    function setLocalRTC(enabled) {
        setLocalRTCProcess.command = ["timedatectl", "set-local-rtc", enabled ? "true" : "false"]
        setLocalRTCProcess.running = true
    }

    Component.onCompleted: {
        refreshStatus()
        listTimezones()
    }

    Process {
        id: statusProcess
        running: false
        command: ["timedatectl", "status", "--no-pager"]
        
        onExited: exitCode => {
            if (exitCode !== 0) {
                root.lastError = "Failed to get time status"
                return
            }
            root.lastError = ""
        }

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split('\n')
                for (let line of lines) {
                    line = line.trim()
                    if (line.startsWith('Time zone:')) {
                        const match = line.match(/Time zone:\s+(.+?)\s*\(/)
                        if (match) {
                            root.currentTimezone = match[1].trim()
                        }
                    } else if (line.startsWith('System clock synchronized:')) {
                        root.systemClockSynchronized = line.includes('yes')
                    } else if (line.startsWith('NTP service:')) {
                        const match = line.match(/NTP service:\s+(.+)/)
                        if (match) {
                            root.ntpServiceStatus = match[1].trim()
                            root.ntpEnabled = root.ntpServiceStatus === 'active'
                        }
                    } else if (line.startsWith('Local time:')) {
                        const match = line.match(/Local time:\s+(.+)/)
                        if (match) {
                            root.localTime = match[1].trim()
                        }
                    } else if (line.startsWith('Universal time:')) {
                        const match = line.match(/Universal time:\s+(.+)/)
                        if (match) {
                            root.universalTime = match[1].trim()
                        }
                    } else if (line.startsWith('RTC time:')) {
                        const match = line.match(/RTC time:\s+(.+)/)
                        if (match) {
                            root.rtcTime = match[1].trim()
                        }
                    } else if (line.startsWith('RTC in local TZ:')) {
                        root.rtcInLocalTZ = line.includes('yes')
                    }
                }
            }
        }
    }

    Process {
        id: timezoneListProcess
        running: false
        command: ["timedatectl", "list-timezones"]
        
        onExited: exitCode => {
            if (exitCode !== 0) {
                root.lastError = "Failed to list timezones"
                return
            }
        }

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split('\n').filter(line => line.trim().length > 0)
                root.availableTimezones = lines.sort()
                root.lastError = ""
            }
        }
    }

    Process {
        id: setTimezoneProcess
        running: false
        command: []
        
        onExited: exitCode => {
            if (exitCode === 0) {
                root.lastError = ""
                Qt.callLater(() => refreshStatus())
            } else {
                root.lastError = "Failed to set timezone (exit code: " + exitCode + ")"
            }
        }
    }

    Process {
        id: setNTPProcess
        running: false
        command: []
        
        onExited: exitCode => {
            if (exitCode === 0) {
                root.lastError = ""
                Qt.callLater(() => refreshStatus())
            } else {
                root.lastError = "Failed to set NTP (exit code: " + exitCode + ")"
            }
        }
    }

    Process {
        id: setTimeProcess
        running: false
        command: []
        
        onExited: exitCode => {
            if (exitCode === 0) {
                root.lastError = ""
                Qt.callLater(() => refreshStatus())
            } else {
                root.lastError = "Failed to set time (exit code: " + exitCode + ")"
            }
        }
    }

    Process {
        id: setLocalRTCProcess
        running: false
        command: []
        
        onExited: exitCode => {
            if (exitCode === 0) {
                root.lastError = ""
                Qt.callLater(() => refreshStatus())
            } else {
                root.lastError = "Failed to set RTC mode (exit code: " + exitCode + ")"
            }
        }
    }
}




