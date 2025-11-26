import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Common
import qs.Services

Item {
    id: root
    property string sid: Quickshell.env("XDG_SESSION_ID") || "self"
    property string sessionPath: ""

    function activate() {
        loader.activeAsync = true
    }

    Component.onCompleted: {
        getSessionPath.running = true
    }

    Component.onDestruction: {
        lockStateMonitor.running = false
    }

    Connections {
        target: IdleService
        function onLockRequested() {
            activate()
        }
    }

    Process {
        id: getSessionPath
        command: ["gdbus", "call", "--system", "--dest", "org.freedesktop.login1", "--object-path", "/org/freedesktop/login1", "--method", "org.freedesktop.login1.Manager.GetSession", sid]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                const match = text.match(/objectpath '([^']+)'/)
                if (match) {
                    root.sessionPath = match[1]
                    checkCurrentLockState.running = true
                    lockStateMonitor.running = true
                } else {
                }
            }
        }

        onExited: (exitCode, exitStatus) => {
                      if (exitCode !== 0) {
                      }
                  }
    }

    Process {
        id: checkCurrentLockState
        command: root.sessionPath ? ["gdbus", "call", "--system", "--dest", "org.freedesktop.login1", "--object-path", root.sessionPath, "--method", "org.freedesktop.DBus.Properties.Get", "org.freedesktop.login1.Session", "LockedHint"] : []
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                if (text.includes("true")) {
                    loader.activeAsync = true
                }
            }
        }

        onExited: (exitCode, exitStatus) => {
                      if (exitCode !== 0) {
                      }
                  }
    }

    Process {
        id: lockStateMonitor
        command: root.sessionPath ? ["gdbus", "monitor", "--system", "--dest", "org.freedesktop.login1"] : []
        running: false

        stdout: SplitParser {
            splitMarker: "\n"

            onRead: line => {
                        if (line.includes(root.sessionPath)) {
                            if (line.includes("org.freedesktop.login1.Session.Lock")) {
                                loader.activeAsync = true
                                return
                            }
                            if (line.includes("org.freedesktop.login1.Session.Unlock")) {
                                loader.active = false
                                return
                            }
                            if (line.includes("LockedHint") && line.includes("true")) {
                                loader.activeAsync = true
                                return
                            }
                            if (line.includes("LockedHint") && line.includes("false")) {
                                loader.active = false
                                return
                            }
                        }
                        if (line.includes("PrepareForSleep") && 
                            line.includes("true") &&
                            SessionData.lockBeforeSuspend) {
                            loader.activeAsync = true
                        }
                    }
        }

        onExited: (exitCode, exitStatus) => {
                      if (exitCode !== 0) {
                      }
                  }
    }

    LazyLoader {
        id: loader

        WlSessionLock {
            id: sessionLock

            property bool unlocked: false
            property string sharedPasswordBuffer: ""

            locked: true

            onLockedChanged: {
                if (!locked) {
                    loader.active = false
                }
            }

            LockSurface {
                id: lockSurface
                lock: sessionLock
                sharedPasswordBuffer: sessionLock.sharedPasswordBuffer
                onPasswordChanged: newPassword => {
                                       sessionLock.sharedPasswordBuffer = newPassword
                                   }
            }
        }
    }

    LockScreenDemo {
        id: demoWindow
    }

    IpcHandler {
        target: "lock"

        function lock() {
            loader.activeAsync = true
        }

        function demo() {
            demoWindow.showDemo()
        }

        function isLocked(): bool {
            return loader.active
        }
    }
}
