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
    
    property string powerButtonAction: "poweroff" // poweroff, reboot, suspend, hibernate, ignore, kexec, halt
    property string sleepButtonAction: "suspend" // suspend, hibernate, ignore
    property string hibernateButtonAction: "hibernate" // hibernate, suspend, ignore
    
    property bool lidSwitchAvailable: false
    property string lidCloseAction: "suspend" // suspend, hibernate, lock, ignore, poweroff, reboot, kexec, halt
    property string lidCloseExternalPowerAction: "suspend" // suspend, hibernate, lock, ignore, poweroff, reboot, kexec, halt
    
    property int idleSleepTimeout: 0 // 0 = disabled
    property int idleSleepTimeoutOnBattery: 0
    property int idleHibernateTimeout: 0
    property int idleHibernateTimeoutOnBattery: 0
    
    property int screenDimTimeout: 600 // 10 minutes default
    property int screenDimTimeoutOnBattery: 300 // 5 minutes default
    property int screenOffTimeout: 1200 // 20 minutes default
    property int screenOffTimeoutOnBattery: 600 // 10 minutes default
    
    property int lowBatteryThreshold: 20 // percentage
    property int criticalBatteryThreshold: 5 // percentage
    property string lowBatteryAction: "suspend" // suspend, hibernate, ignore, poweroff, reboot, kexec, halt
    property string criticalBatteryAction: "hibernate" // suspend, hibernate, ignore, poweroff, reboot, kexec, halt
    
    property string powerProfile: "balanced" // performance, balanced, power-saver
    property var availableProfiles: []
    
    property bool wakeOnLAN: false
    
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
        root.wakeOnLAN = enabled
    }

    Component.onCompleted: {
        detectElogindProcess.running = true
        detectHibernateProcess.running = true
        detectPowerProfilesProcess.running = true
        refreshStatus()
    }

    Process {
        id: detectElogindProcess
        running: false
        command: ["sh", "-c", "ps -eo comm= | grep -E '^(elogind|elogind-daemon)$'"]
        
        onExited: exitCode => {
            root.isElogind = (exitCode === 0)
        }
    }

    Process {
        id: detectHibernateProcess
        running: false
        command: ["grep", "-q", "disk", "/sys/power/state"]
        
        onExited: exitCode => {
            root.hibernateSupported = (exitCode === 0)
        }
    }

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

    Process {
        id: statusProcess
        running: false
        command: []
    }
}
