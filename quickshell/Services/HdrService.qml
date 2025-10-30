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
        onExited: (code, status) => {
            isChecking = false
            hdrEnabled = (code === 0)
        }
    }

    Process {
        id: toggleProcess
        command: ["python", "/home/matt/.config/hypr/hyprhdr.py"]
        onExited: (code, status) => {
            if (code === 0) {
                checkHdrState()
            }
        }
    }

    Component.onCompleted: {
        checkHdrState()
    }
}
