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
        // Check daemon status first, then start if needed
        Qt.callLater(() => {
            checkDaemonStatus()
            Qt.callLater(() => {
                if (SessionData.useAwwwBackend && awwwAvailable) {
                    if (!daemonRunning) {
                        console.log("AwwwService: Starting daemon on initialization")
                        startDaemon()
                        // Give daemon time to start, then verify
                        Qt.callLater(() => {
                            checkDaemonStatus()
                        })
                    } else {
                        console.log("AwwwService: Daemon already running")
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
                console.warn("AwwwService: Failed to start daemon, exit code:", exitCode)
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
                // If daemon just started, verify it's responding
                if (daemonRunning && !wasRunning) {
                    // Give it a moment to fully initialize
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
                console.error("AwwwService: Failed to set wallpaper, exit code:", exitCode)
                console.error("AwwwService: Command was:", command.join(" "))
                console.error("AwwwService: stderr:", stderr.text)
            } else {
                console.log("AwwwService: Wallpaper set successfully")
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (text && text.trim()) {
                    console.warn("AwwwService stderr:", text.trim())
                }
            }
        }
    }

    Process {
        id: wallpaperClearProcess
        running: false
        onExited: exitCode => {
            if (exitCode !== 0) {
                console.warn("AwwwService: Failed to clear wallpaper, exit code:", exitCode)
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
        
        // Check if already running first
        checkDaemonStatus()
        Qt.callLater(() => {
            if (!daemonRunning) {
                // Start daemon in background (it will run as a daemon)
                daemonStartProcess.running = true
                // Give it a moment to start, then verify
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
            console.warn("AwwwService: Cannot set wallpaper - awww not available")
            return
        }

        if (!imagePath || imagePath === "" || imagePath.startsWith("#")) {
            clearWallpaper(screenName)
            return
        }

        // Ensure daemon is running before setting wallpaper
        if (!daemonRunning) {
            console.warn("AwwwService: Daemon not running, attempting to start...")
            startDaemon()
            // Wait a bit for daemon to start, then retry
            Qt.callLater(() => {
                checkDaemonStatus()
                Qt.callLater(() => {
                    if (daemonRunning) {
                        setWallpaper(screenName, imagePath)
                    } else {
                        console.error("AwwwService: Failed to start daemon, cannot set wallpaper")
                    }
                })
            })
            return
        }

        // Remove file:// prefix if present
        var cleanPath = imagePath.toString().replace(/^file:\/\//, "")
        
        // Build command with transition FPS if set
        var fps = SessionData.wallpaperTransitionFps || 30
        var command = ["swww", "img"]
        
        // Add transition FPS option
        if (fps > 0) {
            command.push("--transition-fps", fps.toString())
        }
        
        // Use screen name if provided, otherwise set for all outputs
        // swww img [OPTIONS] <IMAGE>
        // --outputs takes comma-separated list, but single output name works too
        // When screenName is empty, don't use --outputs flag (sets for all outputs)
        if (screenName && screenName !== "") {
            command.push("--outputs", screenName, cleanPath)
            console.log("AwwwService: Setting wallpaper for specific screen:", screenName, "path:", cleanPath, "FPS:", fps)
        } else {
            command.push(cleanPath)
            console.log("AwwwService: Setting wallpaper for all screens, path:", cleanPath, "FPS:", fps)
        }
        
        wallpaperSetProcess.command = command
        wallpaperSetProcess.running = true
    }

    function clearWallpaper(screenName) {
        if (!awwwAvailable) {
            return
        }

        // Ensure daemon is running
        if (!daemonRunning) {
            startDaemon()
            return
        }

        // Clear with black color (format: rrggbb, no # prefix, no alpha needed)
        // swww clear [OPTIONS] [COLOR]
        // When screenName is empty, don't use --outputs flag (clears all outputs)
        if (screenName && screenName !== "") {
            wallpaperClearProcess.command = ["swww", "clear", "--outputs", screenName, "000000"]
            console.log("AwwwService: Clearing wallpaper for specific screen:", screenName)
        } else {
            wallpaperClearProcess.command = ["swww", "clear", "000000"]
            console.log("AwwwService: Clearing wallpaper for all screens")
        }
        
        wallpaperClearProcess.running = true
    }

    function setWallpaperColor(screenName, color) {
        if (!awwwAvailable) {
            console.warn("AwwwService: Cannot set color - awww not available")
            return
        }

        // Ensure daemon is running
        if (!daemonRunning) {
            console.warn("AwwwService: Daemon not running, attempting to start...")
            startDaemon()
            Qt.callLater(() => {
                checkDaemonStatus()
                Qt.callLater(() => {
                    if (daemonRunning) {
                        setWallpaperColor(screenName, color)
                    } else {
                        console.error("AwwwService: Failed to start daemon, cannot set color")
                    }
                })
            })
            return
        }

        // Convert hex color to rrggbb format (remove # if present, remove alpha if present)
        // swww expects rrggbb format (6 hex digits, no alpha)
        var hexColor = color.toString().replace(/^#/, "")
        // Remove alpha channel if present (last 2 hex digits)
        if (hexColor.length === 8) {
            hexColor = hexColor.substring(0, 6)
        }
        
        // swww clear [OPTIONS] [COLOR]
        // When screenName is empty, don't use --outputs flag (sets for all outputs)
        if (screenName && screenName !== "") {
            wallpaperSetProcess.command = ["swww", "clear", "--outputs", screenName, hexColor]
            console.log("AwwwService: Setting color for specific screen:", screenName, "color:", hexColor)
        } else {
            wallpaperSetProcess.command = ["swww", "clear", hexColor]
            console.log("AwwwService: Setting color for all screens, color:", hexColor)
        }
        
        wallpaperSetProcess.running = true
    }
}

