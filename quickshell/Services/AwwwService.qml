pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common

Singleton {
    id: root

    property bool daemonRunning: false
    property bool awwwAvailable: false

    Component.onCompleted: {
        checkAwwwAvailable()

        Qt.callLater(() => {
            checkDaemonStatus()
            Qt.callLater(() => {
                if (SessionData.useAwwwBackend && awwwAvailable) {
                    if (!daemonRunning) {
                        startDaemon()

                        Qt.callLater(() => {
                            checkDaemonStatus()
                        })
                    } else {
                    }
                }
            })
        })
    }

    Connections {
        target: SessionData
        function onUseAwwwBackendChanged() {
            if (SessionData.useAwwwBackend) {
                startDaemon()
            } else {
                stopDaemon()
            }
        }
    }

    Process {
        id: awwwCheckProcess
        command: ["sh", "-c", "command -v swww >/dev/null 2>&1 && echo 'available' || echo 'not_available'"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                awwwAvailable = text.trim() === "available"
            }
        }
    }

    Process {
        id: daemonStartProcess
        command: ["swww-daemon"]
        running: false
        onExited: exitCode => {
            if (exitCode === 0) {
                daemonRunning = true
            } else {
                daemonRunning = false
            }
        }
    }

    Process {
        id: daemonCheckProcess
        command: ["sh", "-c", "pgrep -x swww-daemon >/dev/null 2>&1 && echo 'running' || echo 'not_running'"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var wasRunning = daemonRunning
                daemonRunning = text.trim() === "running"

                if (daemonRunning && !wasRunning) {

                    Qt.callLater(() => {
                        checkDaemonStatus()
                    })
                }
            }
        }
    }

    Process {
        id: wallpaperSetProcess
        running: false
        onExited: exitCode => {
            if (exitCode !== 0) {
            } else {
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (text && text.trim()) {
                }
            }
        }
    }

    Process {
        id: wallpaperClearProcess
        running: false
        onExited: exitCode => {
            if (exitCode !== 0) {
            }
        }
    }

    function checkAwwwAvailable() {
        awwwCheckProcess.running = true
    }

    function checkDaemonStatus() {
        daemonCheckProcess.running = true
    }

    function startDaemon() {
        if (!awwwAvailable) {
            checkAwwwAvailable()
            return
        }
        

        checkDaemonStatus()
        Qt.callLater(() => {
            if (!daemonRunning) {

                daemonStartProcess.running = true

                Qt.callLater(() => {
                    checkDaemonStatus()
                })
            }
        })
    }

    function stopDaemon() {
        if (daemonRunning) {
            Quickshell.execDetached(["swww", "kill"])
            daemonRunning = false
        }
    }

    function setWallpaper(screenName, imagePath) {
        if (!awwwAvailable) {
            return
        }

        if (!imagePath || imagePath === "" || imagePath.startsWith("#")) {
            clearWallpaper(screenName)
            return
        }


        if (!daemonRunning) {
            startDaemon()

            Qt.callLater(() => {
                checkDaemonStatus()
                Qt.callLater(() => {
                    if (daemonRunning) {
                        setWallpaper(screenName, imagePath)
                    } else {
                    }
                })
            })
            return
        }


        var cleanPath = imagePath.toString().replace(/^file:\/\//, "")
        

        var fps = SessionData.wallpaperTransitionFps || 30
        var command = ["swww", "img"]
        

        if (fps > 0) {
            command.push("--transition-fps", fps.toString())
        }
        




        if (screenName && screenName !== "") {
            command.push("--outputs", screenName, cleanPath)
        } else {
            command.push(cleanPath)
        }
        
        wallpaperSetProcess.command = command
        wallpaperSetProcess.running = true
    }

    function clearWallpaper(screenName) {
        if (!awwwAvailable) {
            return
        }


        if (!daemonRunning) {
            startDaemon()
            return
        }




        if (screenName && screenName !== "") {
            wallpaperClearProcess.command = ["swww", "clear", "--outputs", screenName, "000000"]
        } else {
            wallpaperClearProcess.command = ["swww", "clear", "000000"]
        }
        
        wallpaperClearProcess.running = true
    }

    function setWallpaperColor(screenName, color) {
        if (!awwwAvailable) {
            return
        }


        if (!daemonRunning) {
            startDaemon()
            Qt.callLater(() => {
                checkDaemonStatus()
                Qt.callLater(() => {
                    if (daemonRunning) {
                        setWallpaperColor(screenName, color)
                    } else {
                    }
                })
            })
            return
        }



        var hexColor = color.toString().replace(/^#/, "")

        if (hexColor.length === 8) {
            hexColor = hexColor.substring(0, 6)
        }
        


        if (screenName && screenName !== "") {
            wallpaperSetProcess.command = ["swww", "clear", "--outputs", screenName, hexColor]
        } else {
            wallpaperSetProcess.command = ["swww", "clear", hexColor]
        }
        
        wallpaperSetProcess.running = true
    }
}

