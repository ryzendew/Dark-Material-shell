pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common

Singleton {
    id: root

    property bool cyclingActive: false
    property string cachedCyclingTime: SessionData.wallpaperCyclingTime
    property int cachedCyclingInterval: SessionData.wallpaperCyclingInterval
    property string lastTimeCheck: ""
    property var monitorTimers: ({})
    property var monitorLastTimeChecks: ({})
    property var monitorProcesses: ({})
    Component.onCompleted: {
        updateCyclingState()
    }

    Component {
        id: monitorTimerComponent
        Timer {
            property string targetScreen: ""
            running: false
            repeat: true
            onTriggered: {
                if (typeof WallpaperCyclingService !== "undefined" && targetScreen !== "") {
                    WallpaperCyclingService.cycleNextForMonitor(targetScreen)
                }
            }
        }
    }

    Component {
        id: monitorProcessComponent
        Process {
            property string targetScreenName: ""
            property string currentWallpaper: ""
            property bool goToPrevious: false
            running: false
            stdout: StdioCollector {
                onStreamFinished: {
                    if (text && text.trim()) {
                        const files = text.trim().split('\n').filter(file => file.length > 0)
                        if (files.length <= 1) return
                        const wallpaperList = files.sort()
                        const currentPath = currentWallpaper
                        let currentIndex = wallpaperList.findIndex(path => path === currentPath)
                        if (currentIndex === -1) currentIndex = 0
                        let targetIndex
                        if (goToPrevious) {
                            targetIndex = currentIndex === 0 ? wallpaperList.length - 1 : currentIndex - 1
                        } else {
                            targetIndex = (currentIndex + 1) % wallpaperList.length
                        }
                        const targetWallpaper = wallpaperList[targetIndex]
                        if (targetWallpaper && targetWallpaper !== currentPath) {
                            if (targetScreenName) {
                                SessionData.setMonitorWallpaper(targetScreenName, targetWallpaper)
                            } else {
                                SessionData.setWallpaper(targetWallpaper)
                            }
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: SessionData

        function onWallpaperCyclingEnabledChanged() {
            updateCyclingState()
        }

        function onWallpaperCyclingModeChanged() {
            updateCyclingState()
        }

        function onWallpaperCyclingIntervalChanged() {
            cachedCyclingInterval = SessionData.wallpaperCyclingInterval
            if (SessionData.wallpaperCyclingMode === "interval") {
                updateCyclingState()
            }
        }

        function onWallpaperCyclingTimeChanged() {
            cachedCyclingTime = SessionData.wallpaperCyclingTime
            if (SessionData.wallpaperCyclingMode === "time") {
                updateCyclingState()
            }
        }

        function onPerMonitorWallpaperChanged() {
            updateCyclingState()
        }

        function onMonitorCyclingSettingsChanged() {
            updateCyclingState()
        }
    }

    function updateCyclingState() {
        if (SessionData.perMonitorWallpaper) {
            stopCycling()
            updatePerMonitorCycling()
        } else if (SessionData.wallpaperCyclingEnabled && SessionData.wallpaperPath) {
            startCycling()
            stopAllMonitorCycling()
        } else {
            stopCycling()
            stopAllMonitorCycling()
        }
    }

    function updatePerMonitorCycling() {
        if (typeof Quickshell === "undefined") return

        var screens = Quickshell.screens
        for (var i = 0; i < screens.length; i++) {
            var screenName = screens[i].name
            var settings = SessionData.getMonitorCyclingSettings(screenName)
            var wallpaper = SessionData.getMonitorWallpaper(screenName)

            if (settings.enabled && wallpaper && !wallpaper.startsWith("#") && !wallpaper.startsWith("we:")) {
                startMonitorCycling(screenName, settings)
            } else {
                stopMonitorCycling(screenName)
            }
        }
    }

    function stopAllMonitorCycling() {
        var screenNames = Object.keys(monitorTimers)
        for (var i = 0; i < screenNames.length; i++) {
            stopMonitorCycling(screenNames[i])
        }
    }

    function startCycling() {
        if (SessionData.wallpaperCyclingMode === "interval") {
            intervalTimer.interval = cachedCyclingInterval * 1000
            intervalTimer.start()
            cyclingActive = true
        } else if (SessionData.wallpaperCyclingMode === "time") {
            cyclingActive = true
            checkTimeBasedCycling()
        }
    }

    function stopCycling() {
        intervalTimer.stop()
        cyclingActive = false
    }

    function startMonitorCycling(screenName, settings) {
        if (settings.mode === "interval") {
            var timer = monitorTimers[screenName]
            if (!timer && monitorTimerComponent && monitorTimerComponent.status === Component.Ready) {
                var newTimers = Object.assign({}, monitorTimers)
                newTimers[screenName] = monitorTimerComponent.createObject(root)
                newTimers[screenName].targetScreen = screenName
                monitorTimers = newTimers
                timer = monitorTimers[screenName]
            }
            if (timer) {
                timer.interval = settings.interval * 1000
                timer.start()
            }
        } else if (settings.mode === "time") {
            var newChecks = Object.assign({}, monitorLastTimeChecks)
            newChecks[screenName] = ""
            monitorLastTimeChecks = newChecks
        }
    }

    function stopMonitorCycling(screenName) {
        var timer = monitorTimers[screenName]
        if (timer) {
            timer.stop()
            timer.destroy()
            var newTimers = Object.assign({}, monitorTimers)
            delete newTimers[screenName]
            monitorTimers = newTimers
        }

        var process = monitorProcesses[screenName]
        if (process) {
            process.destroy()
            var newProcesses = Object.assign({}, monitorProcesses)
            delete newProcesses[screenName]
            monitorProcesses = newProcesses
        }

        var newChecks = Object.assign({}, monitorLastTimeChecks)
        delete newChecks[screenName]
        monitorLastTimeChecks = newChecks
    }

    function cycleToNextWallpaper(screenName, wallpaperPath) {
        const currentWallpaper = wallpaperPath || SessionData.wallpaperPath
        if (!currentWallpaper) return

        const wallpaperDir = currentWallpaper.substring(0, currentWallpaper.lastIndexOf('/'))

        if (screenName && monitorProcessComponent && monitorProcessComponent.status === Component.Ready) {
            var process = monitorProcesses[screenName]
            if (!process) {
                var newProcesses = Object.assign({}, monitorProcesses)
                newProcesses[screenName] = monitorProcessComponent.createObject(root)
                monitorProcesses = newProcesses
                process = monitorProcesses[screenName]
            }

            if (process) {
                process.targetScreenName = screenName
                process.currentWallpaper = currentWallpaper
                process.goToPrevious = false
                process.command = ["find", wallpaperDir, "-maxdepth", "1", "-type", "f", "(", "-iname", "*.jpg", "-o", "-iname", "*.jpeg", "-o", "-iname", "*.png", "-o", "-iname", "*.webp", "-o", "-iname", "*.gif", "-o", "-iname", "*.bmp", ")"]
                process.running = true
            }
        } else {
            cycleNextManually()
        }
    }

    function cycleNextManually() {
        cycleToNextWallpaper(null, null)
    }

    function cyclePrevManually() {
        const currentWallpaper = SessionData.wallpaperPath
        if (!currentWallpaper) return
        const wallpaperDir = currentWallpaper.substring(0, currentWallpaper.lastIndexOf('/'))
        const process = monitorProcessComponent.createObject(root)
        if (process) {
            process.targetScreenName = ""
            process.currentWallpaper = currentWallpaper
            process.goToPrevious = true
            process.command = ["find", wallpaperDir, "-maxdepth", "1", "-type", "f", "(", "-iname", "*.jpg", "-o", "-iname", "*.jpeg", "-o", "-iname", "*.png", "-o", "-iname", "*.webp", "-o", "-iname", "*.gif", "-o", "-iname", "*.bmp", ")"]
            process.running = true
        }
    }

    function cycleNextForMonitor(screenName) {
        const wallpaper = SessionData.getMonitorWallpaper(screenName)
        cycleToNextWallpaper(screenName, wallpaper)
    }

    function cyclePrevForMonitor(screenName) {
        const currentWallpaper = SessionData.getMonitorWallpaper(screenName)
        if (!currentWallpaper) return
        const wallpaperDir = currentWallpaper.substring(0, currentWallpaper.lastIndexOf('/'))
        if (monitorProcessComponent && monitorProcessComponent.status === Component.Ready) {
            var process = monitorProcesses[screenName]
            if (!process) {
                var newProcesses = Object.assign({}, monitorProcesses)
                newProcesses[screenName] = monitorProcessComponent.createObject(root)
                monitorProcesses = newProcesses
                process = monitorProcesses[screenName]
            }
            if (process) {
                process.targetScreenName = screenName
                process.currentWallpaper = currentWallpaper
                process.goToPrevious = true
                process.command = ["find", wallpaperDir, "-maxdepth", "1", "-type", "f", "(", "-iname", "*.jpg", "-o", "-iname", "*.jpeg", "-o", "-iname", "*.png", "-o", "-iname", "*.webp", "-o", "-iname", "*.gif", "-o", "-iname", "*.bmp", ")"]
                process.running = true
            }
        }
    }

    Timer {
        id: intervalTimer
        running: false
        repeat: true
        onTriggered: {
            cycleNextManually()
        }
    }

    Timer {
        id: timeCheckTimer
        interval: 60000
        running: cyclingActive && SessionData.wallpaperCyclingMode === "time"
        repeat: true
        onTriggered: {
            checkTimeBasedCycling()
        }
    }

    function checkTimeBasedCycling() {
        if (!SessionData.wallpaperCyclingEnabled || SessionData.wallpaperCyclingMode !== "time") return
        const currentTime = Qt.formatDateTime(new Date(), "HH:mm")
        if (currentTime === cachedCyclingTime && currentTime !== lastTimeCheck) {
            cycleNextManually()
            lastTimeCheck = currentTime
        }
        if (SessionData.perMonitorWallpaper) {
            var screens = Quickshell.screens
            for (var i = 0; i < screens.length; i++) {
                var screenName = screens[i].name
                var settings = SessionData.getMonitorCyclingSettings(screenName)
                if (settings.enabled && settings.mode === "time") {
                    var lastCheck = monitorLastTimeChecks[screenName] || ""
                    if (currentTime === settings.time && currentTime !== lastCheck) {
                        cycleNextForMonitor(screenName)
                        var newChecks = Object.assign({}, monitorLastTimeChecks)
                        newChecks[screenName] = currentTime
                        monitorLastTimeChecks = newChecks
                    }
                }
            }
        }
    }
}
