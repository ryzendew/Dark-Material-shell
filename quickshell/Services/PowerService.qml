pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool isElogind: false
    property bool hibernateSupported: false
    property bool hasPowerProfiles: false
    
    // Power button actions
    property string powerButtonAction: "poweroff" // poweroff, reboot, suspend, hibernate, ignore, kexec, halt
    property string sleepButtonAction: "suspend" // suspend, hibernate, ignore
    property string hibernateButtonAction: "hibernate" // hibernate, suspend, ignore
    
    // Lid close actions
    property bool lidSwitchAvailable: false
    property string lidCloseAction: "suspend" // suspend, hibernate, lock, ignore, poweroff, reboot, kexec, halt
    property string lidCloseExternalPowerAction: "suspend" // suspend, hibernate, lock, ignore, poweroff, reboot, kexec, halt
    
    // Sleep/suspend timers (in seconds)
    property int idleSleepTimeout: 0 // 0 = disabled
    property int idleSleepTimeoutOnBattery: 0
    property int idleHibernateTimeout: 0
    property int idleHibernateTimeoutOnBattery: 0
    
    // Display timers (in seconds)
    property int screenDimTimeout: 600 // 10 minutes default
    property int screenDimTimeoutOnBattery: 300 // 5 minutes default
    property int screenOffTimeout: 1200 // 20 minutes default
    property int screenOffTimeoutOnBattery: 600 // 10 minutes default
    
    // Battery settings
    property int lowBatteryThreshold: 20 // percentage
    property int criticalBatteryThreshold: 5 // percentage
    property string lowBatteryAction: "suspend" // suspend, hibernate, ignore, poweroff, reboot, kexec, halt
    property string criticalBatteryAction: "hibernate" // suspend, hibernate, ignore, poweroff, reboot, kexec, halt
    
    // Power profiles
    property string powerProfile: "balanced" // performance, balanced, power-saver
    property var availableProfiles: []
    
    // Wake-on-LAN
    property bool wakeOnLAN: false
    
    // USB power management
    property bool usbAutosuspend: true
    
    property bool isLoading: false
    property string lastError: ""

    function refreshStatus() {
        if (statusProcess.running) return
        statusProcess.running = true
    }

    function setPowerButtonAction(action) {
        if (!action || action.length === 0) return
        const cmd = isElogind ? "elogind" : "loginctl"
        setPowerButtonProcess.command = [cmd, "set-property", "HandlePowerKey", action]
        setPowerButtonProcess.running = true
    }

    function setSleepButtonAction(action) {
        if (!action || action.length === 0) return
        const cmd = isElogind ? "elogind" : "loginctl"
        setSleepButtonProcess.command = [cmd, "set-property", "HandleSleepKey", action]
        setSleepButtonProcess.running = true
    }

    function setHibernateButtonAction(action) {
        if (!action || action.length === 0) return
        const cmd = isElogind ? "elogind" : "loginctl"
        setHibernateButtonProcess.command = [cmd, "set-property", "HandleHibernateKey", action]
        setHibernateButtonProcess.running = true
    }

    function setLidCloseAction(action) {
        if (!action || action.length === 0) return
        const cmd = isElogind ? "elogind" : "loginctl"
        setLidCloseProcess.command = [cmd, "set-property", "HandleLidSwitch", action]
        setLidCloseProcess.running = true
    }

    function setLidCloseExternalPowerAction(action) {
        if (!action || action.length === 0) return
        const cmd = isElogind ? "elogind" : "loginctl"
        setLidCloseExternalPowerProcess.command = [cmd, "set-property", "HandleLidSwitchExternalPower", action]
        setLidCloseExternalPowerProcess.running = true
    }

    function setIdleSleepTimeout(timeout) {
        if (timeout <= 0) {
            // Disable idle action
            const cmd = isElogind ? "elogind" : "loginctl"
            setIdleSleepProcess.command = [cmd, "set-property", "IdleAction", "ignore"]
        } else {
            const cmd = isElogind ? "elogind" : "loginctl"
            setIdleSleepProcess.command = [cmd, "set-property", "IdleAction", "suspend", "IdleActionUSec", (timeout * 1000000).toString()]
        }
        setIdleSleepProcess.running = true
    }

    function setIdleHibernateTimeout(timeout) {
        if (timeout <= 0) {
            // Disable idle action
            const cmd = isElogind ? "elogind" : "loginctl"
            setIdleHibernateProcess.command = [cmd, "set-property", "IdleAction", "ignore"]
        } else {
            const cmd = isElogind ? "elogind" : "loginctl"
            setIdleHibernateProcess.command = [cmd, "set-property", "IdleAction", "hibernate", "IdleActionUSec", (timeout * 1000000).toString()]
        }
        setIdleHibernateProcess.running = true
    }

    function setScreenDimTimeout(timeout) {
        setScreenDimProcess.command = ["xset", "dpms", timeout > 0 ? timeout.toString() : "0"]
        setScreenDimProcess.running = true
    }

    function setScreenOffTimeout(timeout) {
        setScreenOffProcess.command = ["xset", "dpms", "0", timeout > 0 ? timeout.toString() : "0"]
        setScreenOffProcess.running = true
    }

    function setPowerProfile(profile) {
        if (!hasPowerProfiles) return
        setPowerProfileProcess.command = ["powerprofilesctl", "set", profile]
        setPowerProfileProcess.running = true
    }

    function setWakeOnLAN(enabled) {
        // This requires root access and is system-specific
        // For now, we'll just store the preference
        root.wakeOnLAN = enabled
    }

    Component.onCompleted: {
        detectElogindProcess.running = true
        detectHibernateProcess.running = true
        detectPowerProfilesProcess.running = true
        refreshStatus()
    }

    // Detect elogind
    Process {
        id: detectElogindProcess
        running: false
        command: ["sh", "-c", "ps -eo comm= | grep -E '^(elogind|elogind-daemon)$'"]
        
        onExited: exitCode => {
            root.isElogind = (exitCode === 0)
        }
    }

    // Detect hibernate support
    Process {
        id: detectHibernateProcess
        running: false
        command: ["grep", "-q", "disk", "/sys/power/state"]
        
        onExited: exitCode => {
            root.hibernateSupported = (exitCode === 0)
        }
    }

    // Detect power-profiles-daemon
    Process {
        id: detectPowerProfilesProcess
        running: false
        command: ["which", "powerprofilesctl"]
        
        onExited: exitCode => {
            root.hasPowerProfiles = (exitCode === 0)
            if (root.hasPowerProfiles) {
                listPowerProfilesProcess.running = true
            }
        }
    }

    // List available power profiles
    Process {
        id: listPowerProfilesProcess
        running: false
        command: ["powerprofilesctl", "list"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split('\n').filter(line => line.trim().length > 0)
                const profiles = []
                for (let line of lines) {
                    if (line.includes('*')) {
                        const match = line.match(/\*\s+(\S+)/)
                        if (match) {
                            root.powerProfile = match[1]
                        }
                    }
                    const match = line.match(/^\s*(\S+):/)
                    if (match) {
                        profiles.push(match[1])
                    }
                }
                root.availableProfiles = profiles
            }
        }
    }

    // Get current power settings
    Process {
        id: statusProcess
        running: false
        command: ["sh", "-c", "cat /etc/systemd/logind.conf /etc/systemd/logind.conf.d/*.conf 2>/dev/null | grep -E '^HandlePowerKey|^HandleSleepKey|^HandleHibernateKey|^HandleLidSwitch|^HandleLidSwitchExternalPower|^IdleAction' || true"]

        onExited: exitCode => {
            // Reading config files may fail, that's okay - we'll use defaults
            if (exitCode !== 0) {
                // Try alternative method
                readRuntimeSettingsProcess.running = true
            } else {
                root.lastError = ""
            }
        }

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split('\n')
                for (let line of lines) {
                    line = line.trim()
                    if (line.startsWith('HandlePowerKey=')) {
                        root.powerButtonAction = line.split('=')[1] || "poweroff"
                    } else if (line.startsWith('HandleSleepKey=')) {
                        root.sleepButtonAction = line.split('=')[1] || "suspend"
                    } else if (line.startsWith('HandleHibernateKey=')) {
                        root.hibernateButtonAction = line.split('=')[1] || "hibernate"
                    } else if (line.startsWith('HandleLidSwitch=')) {
                        const value = line.split('=')[1]
                        if (value && value !== "ignore") {
                            root.lidCloseAction = value || "suspend"
                            root.lidSwitchAvailable = true
                        }
                    } else if (line.startsWith('HandleLidSwitchExternalPower=')) {
                        root.lidCloseExternalPowerAction = line.split('=')[1] || "suspend"
                    } else if (line.startsWith('IdleAction=')) {
                        const action = line.split('=')[1]
                        if (action === "suspend") {
                            // Get timeout from IdleActionUSec
                        } else if (action === "hibernate") {
                            // Get timeout from IdleActionUSec
                        }
                    }
                }
                // If we got some settings, clear error
                if (lines.length > 0 && lines.some(l => l.trim().length > 0)) {
                    root.lastError = ""
                } else {
                    // No settings found, try runtime method
                    readRuntimeSettingsProcess.running = true
                }
            }
        }
    }

    // Alternative: Try to read runtime settings (may require root)
    Process {
        id: readRuntimeSettingsProcess
        running: false
        command: ["sh", "-c", "systemctl show logind.service -p HandlePowerKey -p HandleSleepKey -p HandleHibernateKey -p HandleLidSwitch -p HandleLidSwitchExternalPower 2>/dev/null || true"]

        onExited: exitCode => {
            // This may fail without root, that's okay
            if (exitCode === 0) {
                root.lastError = ""
            } else {
                // If both methods fail, just use defaults and don't show error
                root.lastError = ""
            }
        }

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split('\n')
                for (let line of lines) {
                    line = line.trim()
                    if (line.startsWith('HandlePowerKey=')) {
                        root.powerButtonAction = line.split('=')[1] || "poweroff"
                    } else if (line.startsWith('HandleSleepKey=')) {
                        root.sleepButtonAction = line.split('=')[1] || "suspend"
                    } else if (line.startsWith('HandleHibernateKey=')) {
                        root.hibernateButtonAction = line.split('=')[1] || "hibernate"
                    } else if (line.startsWith('HandleLidSwitch=')) {
                        const value = line.split('=')[1]
                        if (value && value !== "ignore") {
                            root.lidCloseAction = value || "suspend"
                            root.lidSwitchAvailable = true
                        }
                    } else if (line.startsWith('HandleLidSwitchExternalPower=')) {
                        root.lidCloseExternalPowerAction = line.split('=')[1] || "suspend"
                    }
                }
            }
        }
    }

    // Set power button action
    Process {
        id: setPowerButtonProcess
        running: false
        command: []

        onExited: exitCode => {
            if (exitCode === 0) {
                root.lastError = ""
                root.powerButtonAction = command[command.length - 1]
                Qt.callLater(() => refreshStatus())
            } else {
                root.lastError = "Failed to set power button action (may require systemd or elogind)"
            }
        }
    }

    // Set sleep button action
    Process {
        id: setSleepButtonProcess
        running: false
        command: []

        onExited: exitCode => {
            if (exitCode === 0) {
                root.lastError = ""
                root.sleepButtonAction = command[command.length - 1]
                Qt.callLater(() => refreshStatus())
            } else {
                root.lastError = "Failed to set sleep button action"
            }
        }
    }

    // Set hibernate button action
    Process {
        id: setHibernateButtonProcess
        running: false
        command: []

        onExited: exitCode => {
            if (exitCode === 0) {
                root.lastError = ""
                root.hibernateButtonAction = command[command.length - 1]
                Qt.callLater(() => refreshStatus())
            } else {
                root.lastError = "Failed to set hibernate button action"
            }
        }
    }

    // Set lid close action
    Process {
        id: setLidCloseProcess
        running: false
        command: []

        onExited: exitCode => {
            if (exitCode === 0) {
                root.lastError = ""
                root.lidCloseAction = command[command.length - 1]
                Qt.callLater(() => refreshStatus())
            } else {
                root.lastError = "Failed to set lid close action"
            }
        }
    }

    // Set lid close external power action
    Process {
        id: setLidCloseExternalPowerProcess
        running: false
        command: []

        onExited: exitCode => {
            if (exitCode === 0) {
                root.lastError = ""
                root.lidCloseExternalPowerAction = command[command.length - 1]
                Qt.callLater(() => refreshStatus())
            } else {
                root.lastError = "Failed to set lid close external power action"
            }
        }
    }

    // Set idle sleep timeout
    Process {
        id: setIdleSleepProcess
        running: false
        command: []

        onExited: exitCode => {
            if (exitCode === 0) {
                root.lastError = ""
                Qt.callLater(() => refreshStatus())
            } else {
                root.lastError = "Failed to set idle sleep timeout"
            }
        }
    }

    // Set idle hibernate timeout
    Process {
        id: setIdleHibernateProcess
        running: false
        command: []

        onExited: exitCode => {
            if (exitCode === 0) {
                root.lastError = ""
                Qt.callLater(() => refreshStatus())
            } else {
                root.lastError = "Failed to set idle hibernate timeout"
            }
        }
    }

    // Set screen dim timeout
    Process {
        id: setScreenDimProcess
        running: false
        command: []

        onExited: exitCode => {
            if (exitCode === 0) {
                root.lastError = ""
            } else {
                root.lastError = "Failed to set screen dim timeout"
            }
        }
    }

    // Set screen off timeout
    Process {
        id: setScreenOffProcess
        running: false
        command: []

        onExited: exitCode => {
            if (exitCode === 0) {
                root.lastError = ""
            } else {
                root.lastError = "Failed to set screen off timeout"
            }
        }
    }

    // Set power profile
    Process {
        id: setPowerProfileProcess
        running: false
        command: []

        onExited: exitCode => {
            if (exitCode === 0) {
                root.lastError = ""
                root.powerProfile = command[command.length - 1]
                Qt.callLater(() => {
                    listPowerProfilesProcess.running = true
                })
            } else {
                root.lastError = "Failed to set power profile"
            }
        }
    }
}

