pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: hdrService

    property bool hdrEnabled: false
    property bool isChecking: false

    function checkHdrState() {
        isChecking = true
        checkProcess.running = true
    }

    function toggleHdr() {
        toggleProcess.running = true
    }

    Process {
        id: checkProcess
        command: ["grep", "-q", "cm\\s*=\\s*hdr", "/home/matt/.config/hypr/monitors.conf"]
        onExited: {
            isChecking = false
            // Exit code 0 means HDR was found, non-zero means it wasn't
            hdrEnabled = (exitCode === 0)
        }
    }

    Process {
        id: toggleProcess
        command: ["python", "/home/matt/.config/hypr/hyprhdr.py"]
        onExited: {
            if (exitCode === 0) {
                // Recheck state after toggle
                checkHdrState()
            }
        }
    }

    Component.onCompleted: {
        checkHdrState()
    }
}
