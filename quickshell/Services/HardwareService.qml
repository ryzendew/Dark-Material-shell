pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string cpuModel: ""
    property int cpuCores: 0
    property int cpuThreads: 0
    property string cpuArchitecture: ""
    property string cpuFrequency: ""
    property string totalMemory: ""
    property string availableMemory: ""
    property string usedMemory: ""
    property string gpuModel: ""
    property string gpuDriver: ""
    property string diskTotal: ""
    property string diskUsed: ""
    property string diskAvailable: ""
    property string diskUsagePercent: ""
    property string hostname: ""
    property string kernelVersion: ""
    property string osName: ""
    property bool isLoading: false
    property string lastError: ""

    function refreshAll() {
        refreshCPU()
        refreshMemory()
        refreshGPU()
        refreshDisk()
        refreshSystem()
    }

    function refreshCPU() {
        if (cpuProcess.running) return
        cpuProcess.running = true
    }

    function refreshMemory() {
        if (memoryProcess.running) return
        memoryProcess.running = true
    }

    function refreshGPU() {
        if (gpuProcess.running) return
        gpuProcess.running = true
    }

    function refreshDisk() {
        if (diskProcess.running) return
        diskProcess.running = true
    }

    function refreshSystem() {
        if (systemProcess.running) return
        systemProcess.running = true
    }

    function formatBytes(bytes) {
        if (bytes === 0) return "0 B"
        const k = 1024
        const sizes = ["B", "KB", "MB", "GB", "TB"]
        const i = Math.floor(Math.log(bytes) / Math.log(k))
        const value = bytes / Math.pow(k, i)
        if (i >= 3) {
            return value.toFixed(2) + " " + sizes[i]
        }
        return Math.round(value * 100) / 100 + " " + sizes[i]
    }

    Component.onCompleted: {
        refreshAll()
    }

    Process {
        id: cpuProcess
        running: false
        command: ["lscpu"]

        onExited: exitCode => {
            if (exitCode !== 0) {
                root.lastError = "Failed to get CPU information"
                return
            }
            root.lastError = ""
        }

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split('\n')
                for (let line of lines) {
                    line = line.trim()
                    if (line.startsWith('Model name:')) {
                        const match = line.match(/Model name:\s+(.+)/)
                        if (match) {
                            root.cpuModel = match[1].trim()
                        }
                    } else if (line.startsWith('CPU(s):')) {
                        const match = line.match(/CPU\(s\):\s+(\d+)/)
                        if (match) {
                            root.cpuThreads = parseInt(match[1])
                        }
                    } else if (line.startsWith('Core(s) per socket:')) {
                        const match = line.match(/Core\(s\) per socket:\s+(\d+)/)
                        if (match) {
                            const coresPerSocket = parseInt(match[1])
                            const socketsMatch = text.match(/Socket\(s\):\s+(\d+)/)
                            const sockets = socketsMatch ? parseInt(socketsMatch[1]) : 1
                            root.cpuCores = coresPerSocket * sockets
                        }
                    } else if (line.startsWith('Architecture:')) {
                        const match = line.match(/Architecture:\s+(.+)/)
                        if (match) {
                            root.cpuArchitecture = match[1].trim()
                        }
                    } else if (line.startsWith('CPU max MHz:') || line.startsWith('CPU MHz:')) {
                        const match = line.match(/CPU\s+(?:max\s+)?MHz:\s+([\d.]+)/)
                        if (match) {
                            const mhz = parseFloat(match[1])
                            root.cpuFrequency = (mhz / 1000).toFixed(2) + " GHz"
                        }
                    }
                }
            }
        }
    }

    Process {
        id: memoryProcess
        running: false
        command: ["free", "-b"]

        onExited: exitCode => {
            if (exitCode !== 0) {
                root.lastError = "Failed to get memory information"
                return
            }
            root.lastError = ""
        }

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split('\n')
                for (let line of lines) {
                    line = line.trim()
                    if (line.startsWith('Mem:')) {
                        const parts = line.split(/\s+/)
                        if (parts.length >= 4) {
                            const total = parseInt(parts[1])
                            const used = parseInt(parts[2])
                            const available = parseInt(parts[6] || parts[3])
                            root.totalMemory = root.formatBytes(total)
                            root.usedMemory = root.formatBytes(used)
                            root.availableMemory = root.formatBytes(available)
                        }
                    }
                }
            }
        }
    }

    Process {
        id: gpuProcess
        running: false
        command: ["sh", "-c", "lspci | grep -i vga || lspci | grep -i 3d || lspci | grep -i display || echo 'No GPU found'"]

        onExited: exitCode => {
        }

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split('\n').filter(line => line.trim().length > 0)
                if (lines.length > 0) {
                    const gpuLine = lines[0]
                    
                    if (gpuLine.toLowerCase().includes('nvidia')) {
                        nvidiaModelProcess.running = true
                        nvidiaDriverProcess.running = true
                    } else if (gpuLine.toLowerCase().includes('amd') || gpuLine.toLowerCase().includes('radeon')) {
                        amdModelProcess.running = true
                        amdDriverProcess.running = true
                    } else if (gpuLine.toLowerCase().includes('intel')) {
                        intelModelProcess.running = true
                        intelDriverProcess.running = true
                    } else {
                        const match = gpuLine.match(/:\s+(.+?)(?:\s+\[|$)/)
                        if (match) {
                            root.gpuModel = match[1].trim()
                        } else {
                            root.gpuModel = gpuLine.replace(/^\d+:\d+\.\d+\s+/, "").trim()
                        }
                    }
                } else {
                    root.gpuModel = "Unknown"
                }
            }
        }
    }

    Process {
        id: nvidiaModelProcess
        running: false
        command: ["nvidia-smi", "--query-gpu=name", "--format=csv,noheader"]

        stdout: StdioCollector {
            onStreamFinished: {
                const model = text.trim()
                if (model && model.length > 0) {
                    root.gpuModel = model
                }
            }
        }
    }

    Process {
        id: amdModelProcess
        running: false
        command: ["sh", "-c", "lspci -nn | grep -i 'vga\\|3d\\|display' | head -1 | sed 's/.*: //' | sed 's/ \\[.*//' | sed 's/^[^:]*: //'"]

        stdout: StdioCollector {
            onStreamFinished: {
                let model = text.trim()
                if (model && model.length > 0 && model !== "No GPU found") {
                    model = model.replace(/\[.*?\]/g, "").trim()
                    model = model.replace(/^(AMD|Advanced Micro Devices|ATI Technologies|ATI)\s+/i, "").trim()
                    root.gpuModel = model
                }
            }
        }
    }

    Process {
        id: intelModelProcess
        running: false
        command: ["sh", "-c", "lspci -nn | grep -i 'vga\\|3d\\|display' | head -1 | sed 's/.*: //' | sed 's/ \\[.*//' | sed 's/^[^:]*: //'"]

        stdout: StdioCollector {
            onStreamFinished: {
                let model = text.trim()
                if (model && model.length > 0 && model !== "No GPU found") {
                    model = model.replace(/\[.*?\]/g, "").trim()
                    model = model.replace(/^(Intel Corporation|Intel)\s+/i, "").trim()
                    root.gpuModel = model
                }
            }
        }
    }

    Process {
        id: nvidiaDriverProcess
        running: false
        command: ["nvidia-smi", "--query-gpu=driver_version", "--format=csv,noheader"]

        stdout: StdioCollector {
            onStreamFinished: {
                const driver = text.trim()
                if (driver && driver.length > 0) {
                    root.gpuDriver = "NVIDIA " + driver
                }
            }
        }
    }

    Process {
        id: amdDriverProcess
        running: false
        command: ["sh", "-c", "glxinfo -B 2>/dev/null || echo ''"]

        stdout: StdioCollector {
            onStreamFinished: {
                if (!text || text.trim().length === 0) return
                const lines = text.split('\n')
                for (let line of lines) {
                    if (line.includes('OpenGL renderer') || line.includes('Device')) {
                        const match = line.match(/:\s+(.+)/)
                        if (match) {
                            root.gpuDriver = match[1].trim()
                            break
                        }
                    }
                }
            }
        }
    }

    Process {
        id: intelDriverProcess
        running: false
        command: ["sh", "-c", "glxinfo -B 2>/dev/null || echo ''"]

        stdout: StdioCollector {
            onStreamFinished: {
                if (!text || text.trim().length === 0) return
                const lines = text.split('\n')
                for (let line of lines) {
                    if (line.includes('OpenGL renderer') || line.includes('Device')) {
                        const match = line.match(/:\s+(.+)/)
                        if (match) {
                            root.gpuDriver = match[1].trim()
                            break
                        }
                    }
                }
            }
        }
    }

    Process {
        id: diskProcess
        running: false
        command: ["df", "-h", "/"]

        onExited: exitCode => {
            if (exitCode !== 0) {
                root.lastError = "Failed to get disk information"
                return
            }
            root.lastError = ""
        }

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split('\n')
                if (lines.length > 1) {
                    const parts = lines[1].split(/\s+/)
                    if (parts.length >= 5) {
                        root.diskTotal = parts[1]
                        root.diskUsed = parts[2]
                        root.diskAvailable = parts[3]
                        root.diskUsagePercent = parts[4]
                    }
                }
            }
        }
    }

    Process {
        id: systemProcess
        running: false
        command: ["uname", "-a"]

        onExited: exitCode => {
            if (exitCode !== 0) {
                root.lastError = "Failed to get system information"
                return
            }
            root.lastError = ""
        }

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(/\s+/)
                if (parts.length >= 3) {
                    root.hostname = parts[1]
                    root.kernelVersion = parts[2]
                }
                
                osNameProcess.running = true
            }
        }
    }

    Process {
        id: osNameProcess
        running: false
        command: ["sh", "-c", "cat /etc/os-release | grep '^NAME=' | cut -d'=' -f2 | tr -d '\"' || echo 'Linux'"]

        stdout: StdioCollector {
            onStreamFinished: {
                root.osName = text.trim() || "Linux"
            }
        }
    }
}

