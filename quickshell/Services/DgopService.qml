pragma Singleton

pragma ComponentBehavior: Bound

import QtQuick
import QtCore
import Quickshell
import Quickshell.Io
import qs.Common

Singleton {
    id: root

    property int refCount: 0
    property int updateInterval: refCount > 0 ? 3000 : 30000
    property bool isUpdating: false
    property bool dgopAvailable: false
    property bool nvmlAvailable: false

    property var moduleRefCounts: ({})
    property var enabledModules: []
    property var gpuPciIds: []
    property var gpuPciIdRefCounts: ({})
    property int processLimit: 20
    property string processSort: "cpu"
    property bool noCpu: false

    property string cpuCursor: ""
    property string procCursor: ""
    property int cpuSampleCount: 0
    property int processSampleCount: 0

    property real cpuUsage: 0
    property real cpuFrequency: 0
    property real cpuTemperature: 0
    property int cpuCores: 1
    property string cpuModel: ""
    property var perCoreCpuUsage: []

    property real memoryUsage: 0
    property real totalMemoryMB: 0
    property real usedMemoryMB: 0
    property real freeMemoryMB: 0
    property real availableMemoryMB: 0
    property int totalMemoryKB: 0
    property int usedMemoryKB: 0
    property int totalSwapKB: 0
    property int usedSwapKB: 0

    property real networkRxRate: 0
    property real networkTxRate: 0
    property var lastNetworkStats: null
    property var networkInterfaces: []

    property real diskReadRate: 0
    property real diskWriteRate: 0
    property var lastDiskStats: null
    property var diskMounts: []
    property var diskDevices: []

    property var processes: []
    property var allProcesses: []
    property string currentSort: "cpu"
    property var availableGpus: []

    property string kernelVersion: ""
    property string distribution: ""
    property string hostname: ""
    property string architecture: ""
    property string loadAverage: ""
    property int processCount: 0
    property int threadCount: 0
    property string bootTime: ""
    property string motherboard: ""
    property string biosVersion: ""

    property int historySize: 60
    property var cpuHistory: []
    property var memoryHistory: []
    property var networkHistory: ({
                                      "rx": [],
                                      "tx": []
                                  })
    property var diskHistory: ({
                                   "read": [],
                                   "write": []
                               })

    function addRef(modules = null) {
        refCount++
        let modulesChanged = false

        if (modules) {
            const modulesToAdd = Array.isArray(modules) ? modules : [modules]
            for (const module of modulesToAdd) {
                const currentCount = moduleRefCounts[module] || 0
                moduleRefCounts[module] = currentCount + 1

                if (enabledModules.indexOf(module) === -1) {
                    enabledModules.push(module)
                    modulesChanged = true
                }
            }
        }

        if (modulesChanged || refCount === 1) {
            enabledModules = enabledModules.slice() // Force property change
            moduleRefCounts = Object.assign({}, moduleRefCounts) // Force property change
            updateAllStats()
        } else if (gpuPciIds.length > 0 && refCount > 0) {
            updateAllStats()
        }
    }

    function removeRef(modules = null) {
        refCount = Math.max(0, refCount - 1)
        let modulesChanged = false

        if (modules) {
            const modulesToRemove = Array.isArray(modules) ? modules : [modules]
            for (const module of modulesToRemove) {
                const currentCount = moduleRefCounts[module] || 0
                if (currentCount > 1) {
                    moduleRefCounts[module] = currentCount - 1
                } else if (currentCount === 1) {
                    delete moduleRefCounts[module]
                    const index = enabledModules.indexOf(module)
                    if (index > -1) {
                        enabledModules.splice(index, 1)
                        modulesChanged = true
                    }
                }
            }
        }

        if (modulesChanged) {
            enabledModules = enabledModules.slice() // Force property change
            moduleRefCounts = Object.assign({}, moduleRefCounts) // Force property change

            if (!enabledModules.includes("cpu")) {
                cpuCursor = ""
                cpuSampleCount = 0
            }
            if (!enabledModules.includes("processes")) {
                procCursor = ""
                processSampleCount = 0
            }
        }
    }

    function setGpuPciIds(pciIds) {
        gpuPciIds = Array.isArray(pciIds) ? pciIds : []
    }

    function addGpuPciId(pciId) {
        const currentCount = gpuPciIdRefCounts[pciId] || 0
        gpuPciIdRefCounts[pciId] = currentCount + 1

        if (!gpuPciIds.includes(pciId)) {
            gpuPciIds = gpuPciIds.concat([pciId])
        }

        gpuPciIdRefCounts = Object.assign({}, gpuPciIdRefCounts)
    }

    function removeGpuPciId(pciId) {
        const currentCount = gpuPciIdRefCounts[pciId] || 0
        if (currentCount > 1) {
            gpuPciIdRefCounts[pciId] = currentCount - 1
        } else if (currentCount === 1) {
            delete gpuPciIdRefCounts[pciId]
            const index = gpuPciIds.indexOf(pciId)
            if (index > -1) {
                gpuPciIds = gpuPciIds.slice()
                gpuPciIds.splice(index, 1)
            }

            if (availableGpus && availableGpus.length > 0) {
                const updatedGpus = availableGpus.slice()
                for (var i = 0; i < updatedGpus.length; i++) {
                    if (updatedGpus[i].pciId === pciId) {
                        updatedGpus[i] = Object.assign({}, updatedGpus[i], {
                                                           "temperature": 0
                                                       })
                    }
                }
                availableGpus = updatedGpus
            }

        }

        gpuPciIdRefCounts = Object.assign({}, gpuPciIdRefCounts)
    }

    function setProcessOptions(limit = 20, sort = "cpu", disableCpu = false) {
        processLimit = limit
        processSort = sort
        noCpu = disableCpu
    }

    function updateAllStats() {
        if (dgopAvailable && refCount > 0 && enabledModules.length > 0) {
            isUpdating = true
            dgopProcess.running = true
        } else if (!dgopAvailable && refCount > 0 && enabledModules.length > 0) {
            isUpdating = true
            updateStatsFallback()
        } else {
            isUpdating = false
        }
    }
    
    function updateStatsFallback() {
        if (enabledModules.includes("cpu") || enabledModules.includes("all")) {
            fallbackCpuProcess.running = true
            fallbackCpuFreqProcess.running = true
            fallbackCpuTempProcess.running = true
        }
        if (enabledModules.includes("memory") || enabledModules.includes("all")) {
            fallbackMemoryProcess.running = true
        }
        if (enabledModules.includes("network") || enabledModules.includes("all")) {
            fallbackNetworkProcess.running = true
        }
        if (enabledModules.includes("gpu") || enabledModules.includes("all")) {
            if (availableGpus.length === 0) {
                initializeFallbackGpu()
            }
            fallbackGpuTempProcess.running = true
        }
    }
    
    function initializeFallbackGpu() {
        if (availableGpus.length === 0) {
            fallbackGpuInitProcess.running = true
            fallbackGpuNameProcess.running = true
        }
    }

    function initializeGpuMetadata() {
        if (!dgopAvailable)
            return
        gpuInitProcess.running = true
    }

    function initializeGpuMetadataWithNVML() {
        if (!nvmlAvailable)
            return
        nvmlGpuProcess.running = true
    }

    function buildDgopCommand() {
        const cmd = ["dgop", "meta", "--json"]

        if (enabledModules.length === 0) {
            return []
        }

        const finalModules = []
        for (const module of enabledModules) {
            if (module === "gpu" && gpuPciIds.length > 0) {
                finalModules.push("gpu-temp")
            } else if (module !== "gpu") {
                finalModules.push(module)
            }
        }

        if (gpuPciIds.length > 0 && finalModules.indexOf("gpu-temp") === -1) {
            finalModules.push("gpu-temp")
        }

        if (enabledModules.indexOf("all") !== -1) {
            cmd.push("--modules", "all")
        } else if (finalModules.length > 0) {
            const moduleList = finalModules.join(",")
            cmd.push("--modules", moduleList)
        } else {
            return []
        }

        if ((enabledModules.includes("cpu") || enabledModules.includes("all")) && cpuCursor) {
            cmd.push("--cpu-cursor", cpuCursor)
        }
        if ((enabledModules.includes("processes") || enabledModules.includes("all")) && procCursor) {
            cmd.push("--proc-cursor", procCursor)
        }

        if (gpuPciIds.length > 0) {
            cmd.push("--gpu-pci-ids", gpuPciIds.join(","))
        }

        if (enabledModules.indexOf("processes") !== -1 || enabledModules.indexOf("all") !== -1) {
            cmd.push("--limit", "100") // Get more data for client sorting
            cmd.push("--sort", "cpu") // Always get CPU sorted data
            if (noCpu) {
                cmd.push("--no-cpu")
            }
        }

        return cmd
    }

    function parseData(data) {
        if (data.cpu) {
            const cpu = data.cpu
            cpuSampleCount++

            cpuUsage = cpu.usage || 0
            cpuFrequency = cpu.frequency || 0
            cpuTemperature = cpu.temperature || 0
            cpuCores = cpu.count || 1
            cpuModel = cpu.model || ""
            perCoreCpuUsage = cpu.coreUsage || []
            addToHistory(cpuHistory, cpuUsage)

            if (cpu.cursor) {
                cpuCursor = cpu.cursor
            }
        }

        if (data.memory) {
            const mem = data.memory
            const totalKB = mem.total || 0
            const availableKB = mem.available || 0
            const freeKB = mem.free || 0

            totalMemoryMB = totalKB / 1024
            availableMemoryMB = availableKB / 1024
            freeMemoryMB = freeKB / 1024
            usedMemoryMB = totalMemoryMB - availableMemoryMB
            memoryUsage = totalKB > 0 ? ((totalKB - availableKB) / totalKB) * 100 : 0

            totalMemoryKB = totalKB
            usedMemoryKB = totalKB - availableKB
            totalSwapKB = mem.swaptotal || 0
            usedSwapKB = (mem.swaptotal || 0) - (mem.swapfree || 0)

            addToHistory(memoryHistory, memoryUsage)
        }

        if (data.network && Array.isArray(data.network)) {
            networkInterfaces = data.network

            let totalRx = 0
            let totalTx = 0
            for (const iface of data.network) {
                totalRx += iface.rx || 0
                totalTx += iface.tx || 0
            }

            if (lastNetworkStats) {
                const timeDiff = updateInterval / 1000
                const rxDiff = totalRx - lastNetworkStats.rx
                const txDiff = totalTx - lastNetworkStats.tx
                networkRxRate = Math.max(0, rxDiff / timeDiff)
                networkTxRate = Math.max(0, txDiff / timeDiff)
                addToHistory(networkHistory.rx, networkRxRate / 1024)
                addToHistory(networkHistory.tx, networkTxRate / 1024)
            }
            lastNetworkStats = {
                "rx": totalRx,
                "tx": totalTx
            }
        }

        if (data.disk && Array.isArray(data.disk)) {
            diskDevices = data.disk

            let totalRead = 0
            let totalWrite = 0
            for (const disk of data.disk) {
                totalRead += (disk.read || 0) * 512
                totalWrite += (disk.write || 0) * 512
            }

            if (lastDiskStats) {
                const timeDiff = updateInterval / 1000
                const readDiff = totalRead - lastDiskStats.read
                const writeDiff = totalWrite - lastDiskStats.write
                diskReadRate = Math.max(0, readDiff / timeDiff)
                diskWriteRate = Math.max(0, writeDiff / timeDiff)
                addToHistory(diskHistory.read, diskReadRate / (1024 * 1024))
                addToHistory(diskHistory.write, diskWriteRate / (1024 * 1024))
            }
            lastDiskStats = {
                "read": totalRead,
                "write": totalWrite
            }
        }

        if (data.diskmounts) {
            diskMounts = data.diskmounts || []
        }

        if (data.processes && Array.isArray(data.processes)) {
            const newProcesses = []
            processSampleCount++

            for (const proc of data.processes) {
                const cpuUsage = processSampleCount >= 2 ? (proc.cpu || 0) : 0

                newProcesses.push({
                                      "pid": proc.pid || 0,
                                      "ppid": proc.ppid || 0,
                                      "cpu": cpuUsage,
                                      "memoryPercent": proc.memoryPercent || proc.pssPercent || 0,
                                      "memoryKB": proc.memoryKB || proc.pssKB || 0,
                                      "command": proc.command || "",
                                      "fullCommand": proc.fullCommand || "",
                                      "displayName": (proc.command && proc.command.length > 15) ? proc.command.substring(0, 15) + "..." : (proc.command || "")
                                  })
            }
            allProcesses = newProcesses
            applySorting()

            if (data.cursor) {
                procCursor = data.cursor
            }
        }

        const gpuData = (data.gpu && data.gpu.gpus) || data.gpus
        if (gpuData && Array.isArray(gpuData)) {
            if (gpuPciIds.length > 0 && availableGpus && availableGpus.length > 0) {
                const updatedGpus = availableGpus.slice()
                for (var i = 0; i < updatedGpus.length; i++) {
                    const existingGpu = updatedGpus[i]
                    const tempGpu = gpuData.find(g => g.pciId === existingGpu.pciId)
                    if (tempGpu && gpuPciIds.includes(existingGpu.pciId)) {
                        updatedGpus[i] = Object.assign({}, existingGpu, {
                                                           "temperature": tempGpu.temperature || 0
                                                       })
                    }
                }
                availableGpus = updatedGpus
            } else {
                const gpuList = []
                for (const gpu of gpuData) {
                    let displayName = gpu.displayName || gpu.name || "Unknown GPU"
                    let fullName = gpu.fullName || gpu.name || "Unknown GPU"

                    gpuList.push({
                                     "driver": gpu.driver || "",
                                     "vendor": gpu.vendor || "",
                                     "displayName": displayName,
                                     "fullName": fullName,
                                     "pciId": gpu.pciId || "",
                                     "temperature": gpu.temperature || 0
                                 })
                }
                availableGpus = gpuList
            }
        }

        if (data.system) {
            const sys = data.system
            loadAverage = sys.loadavg || ""
            processCount = sys.processes || 0
            threadCount = sys.threads || 0
            bootTime = sys.boottime || ""
        }

        if (data.hardware) {
            const hw = data.hardware
            hostname = hw.hostname || ""
            kernelVersion = hw.kernel || ""
            distribution = hw.distro || ""
            architecture = hw.arch || ""
            motherboard = (hw.bios && hw.bios.motherboard) || ""
            biosVersion = (hw.bios && hw.bios.version) || ""
        }

        isUpdating = false
    }

    function addToHistory(array, value) {
        array.push(value)
        if (array.length > historySize) {
            array.shift()
        }
    }

    function getProcessIcon(command) {
        const cmd = command.toLowerCase()
        if (cmd.includes("firefox") || cmd.includes("chrome") || cmd.includes("browser") || cmd.includes("chromium")) {
            return "web"
        }
        if (cmd.includes("code") || cmd.includes("editor") || cmd.includes("vim")) {
            return "code"
        }
        if (cmd.includes("terminal") || cmd.includes("bash") || cmd.includes("zsh")) {
            return "terminal"
        }
        if (cmd.includes("music") || cmd.includes("audio") || cmd.includes("spotify")) {
            return "music_note"
        }
        if (cmd.includes("video") || cmd.includes("vlc") || cmd.includes("mpv")) {
            return "play_circle"
        }
        if (cmd.includes("systemd") || cmd.includes("elogind") || cmd.includes("kernel") || cmd.includes("kthread") || cmd.includes("kworker")) {
            return "settings"
        }
        return "memory"
    }

    function formatCpuUsage(cpu) {
        return (cpu || 0).toFixed(1) + "%"
    }

    function formatMemoryUsage(memoryKB) {
        const mem = memoryKB || 0
        if (mem < 1024) {
            return mem.toFixed(0) + " KB"
        } else if (mem < 1024 * 1024) {
            return (mem / 1024).toFixed(1) + " MB"
        } else {
            return (mem / (1024 * 1024)).toFixed(1) + " GB"
        }
    }

    function formatSystemMemory(memoryKB) {
        const mem = memoryKB || 0
        if (mem === 0) {
            return "--"
        }
        if (mem < 1024 * 1024) {
            return (mem / 1024).toFixed(0) + " MB"
        } else {
            return (mem / (1024 * 1024)).toFixed(1) + " GB"
        }
    }

    function killProcess(pid) {
        if (pid > 0) {
            Quickshell.execDetached("kill", [pid.toString()])
        }
    }

    function setSortBy(newSortBy) {
        if (newSortBy !== currentSort) {
            currentSort = newSortBy
            applySorting()
        }
    }

    function applySorting() {
        if (!allProcesses || allProcesses.length === 0) {
            return
        }

        const sorted = allProcesses.slice()
        sorted.sort((a, b) => {
                        let valueA, valueB

                        switch (currentSort) {
                            case "cpu":
                            valueA = a.cpu || 0
                            valueB = b.cpu || 0
                            return valueB - valueA
                            case "memory":
                            valueA = a.memoryKB || 0
                            valueB = b.memoryKB || 0
                            return valueB - valueA
                            case "name":
                            valueA = (a.command || "").toLowerCase()
                            valueB = (b.command || "").toLowerCase()
                            return valueA.localeCompare(valueB)
                            case "pid":
                            valueA = a.pid || 0
                            valueB = b.pid || 0
                            return valueA - valueB
                            default:
                            return 0
                        }
                    })

        processes = sorted.slice(0, processLimit)
    }

    Timer {
        id: updateTimer
        interval: root.updateInterval
        running: root.dgopAvailable && root.refCount > 0 && root.enabledModules.length > 0
        repeat: true
        triggeredOnStart: true
        onTriggered: root.updateAllStats()
    }

    Timer {
        id: nvmlUpdateTimer
        interval: 2000  // Update every 2 seconds for GPU temperature
        running: root.nvmlAvailable && root.refCount > 0 && root.enabledModules.includes("gpu")
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (availableGpus && availableGpus.length > 0) {
                nvmlGpuProcess.running = true
            }
        }
    }

    Process {
        id: dgopProcess
        command: root.buildDgopCommand()
        running: false
        onCommandChanged: {

        }
        onExited: exitCode => {
            if (exitCode !== 0) {
                isUpdating = false
            }
        }
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim()) {
                    try {
                        const data = JSON.parse(text.trim())
                        parseData(data)
                    } catch (e) {
                        isUpdating = false
                    }
                }
            }
        }
    }

    Process {
        id: gpuInitProcess
        command: ["dgop", "gpu", "--json"]
        running: false
        onExited: exitCode => {
            if (exitCode !== 0) {
            }
        }
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim()) {
                    try {
                        const data = JSON.parse(text.trim())
                        parseData(data)
                    } catch (e) {
                    }
                }
            }
        }
    }

    Process {
        id: dgopCheckProcess
        command: ["which", "dgop"]
        running: false
        onExited: exitCode => {
            dgopAvailable = (exitCode === 0)
            if (dgopAvailable) {
                initializeGpuMetadata()
                if (SessionData.enabledGpuPciIds && SessionData.enabledGpuPciIds.length > 0) {
                    for (const pciId of SessionData.enabledGpuPciIds) {
                        addGpuPciId(pciId)
                    }
                    if (refCount > 0 && enabledModules.length > 0) {
                        updateAllStats()
                    }
                }
            } else {
                initializeFallbackGpu()
                fallbackCpuInfoProcess.running = true
                if (refCount > 0 && (enabledModules.includes("memory") || enabledModules.includes("all"))) {
                    fallbackMemoryProcess.running = true
                }
                if (refCount > 0 && enabledModules.length > 0) {
                    updateAllStats()
                }
            }
        }
    }

    readonly property string configDir: Paths.strip(StandardPaths.writableLocation(StandardPaths.ConfigLocation))
    readonly property string nvmlPythonPath: "python3"
    readonly property string nvmlScriptPath: configDir + "/quickshell/scripts/nvidia_gpu_temp.py"

    Process {
        id: nvmlCheckProcess
        command: [nvmlPythonPath, "-c", "import pynvml; print('NVML available')"]
        running: false
        onExited: exitCode => {
            nvmlAvailable = (exitCode === 0)
            if (nvmlAvailable) {
                if (!dgopAvailable) {
                    initializeGpuMetadataWithNVML()
                }
            } else {
            }
        }
    }

    Process {
        id: nvmlGpuProcess
        command: [nvmlPythonPath, nvmlScriptPath]
        running: false
        onExited: exitCode => {
            if (exitCode !== 0) {
            }
        }
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim()) {
                    try {
                        const data = JSON.parse(text.trim())
                        if (data.gpus && Array.isArray(data.gpus)) {
                            if (availableGpus && availableGpus.length > 0) {
                                const updatedGpus = availableGpus.slice()
                                for (var i = 0; i < updatedGpus.length; i++) {
                                    const existingGpu = updatedGpus[i]
                                    const nvmlGpu = data.gpus.find(g => g.pciId === existingGpu.pciId)
                                    if (nvmlGpu) {
                                        updatedGpus[i] = Object.assign({}, existingGpu, {
                                            "temperature": nvmlGpu.temperature || 0
                                        })
                                    }
                                }
                                availableGpus = updatedGpus
                            } else {
                                const gpuList = []
                                for (const gpu of data.gpus) {
                                    gpuList.push({
                                        "driver": gpu.driver || "nvidia",
                                        "vendor": gpu.vendor || "NVIDIA",
                                        "displayName": gpu.displayName || gpu.name || "Unknown GPU",
                                        "fullName": gpu.fullName || gpu.name || "Unknown GPU",
                                        "pciId": gpu.pciId || "",
                                        "temperature": gpu.temperature || 0
                                    })
                                }
                                availableGpus = gpuList
                                
                                for (const gpu of data.gpus) {
                                    if (gpu.pciId) {
                                        addGpuPciId(gpu.pciId)
                                    }
                                }
                            }
                        } else if (data.error) {
                        }
                    } catch (e) {
                    }
                }
            }
        }
    }

    Process {
        id: osReleaseProcess
        command: ["cat", "/etc/os-release"]
        running: false
        onExited: exitCode => {
            if (exitCode !== 0) {
            }
        }
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim()) {
                    try {
                        const lines = text.trim().split('\n')
                        let prettyName = ""
                        let name = ""

                        for (const line of lines) {
                            const trimmedLine = line.trim()
                            if (trimmedLine.startsWith('PRETTY_NAME=')) {
                                prettyName = trimmedLine.substring(12).replace(/^["']|["']$/g, '')
                            } else if (trimmedLine.startsWith('NAME=')) {
                                name = trimmedLine.substring(5).replace(/^["']|["']$/g, '')
                            }
                        }

                        const distroName = prettyName || name || "Linux"
                        distribution = distroName
                    } catch (e) {
                        distribution = "Linux"
                    }
                }
            }
        }
    }

    Process {
        id: fallbackCpuProcess
        command: ["sh", "-c", "head -n 1 /proc/stat"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const parts = text.trim().split(/\s+/)
                    if (parts.length >= 8) {
                        const user = parseInt(parts[1])
                        const nice = parseInt(parts[2])
                        const system = parseInt(parts[3])
                        const idle = parseInt(parts[4])
                        const iowait = parseInt(parts[5] || 0)
                        const irq = parseInt(parts[6] || 0)
                        const softirq = parseInt(parts[7] || 0)
                        const total = user + nice + system + idle + iowait + irq + softirq
                        const used = user + nice + system + irq + softirq
                        
                        if (root.lastCpuStats) {
                            const totalDiff = total - root.lastCpuStats.total
                            const usedDiff = used - root.lastCpuStats.used
                            if (totalDiff > 0) {
                                root.cpuUsage = (usedDiff / totalDiff) * 100
                                addToHistory(root.cpuHistory, root.cpuUsage)
                            }
                        }
                        root.lastCpuStats = { total: total, used: used }
                    }
                } catch (e) {
                }
            }
        }
    }
    
    property var lastCpuStats: null
    
    Process {
        id: fallbackCpuFreqProcess
        command: ["sh", "-c", "cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2>/dev/null || echo 0"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const freq = parseInt(text.trim())
                    if (freq > 0) {
                        root.cpuFrequency = freq / 1000000.0 // Convert from kHz to GHz
                    }
                } catch (e) {
                }
            }
        }
    }
    
    Process {
        id: fallbackMemoryProcess
        command: ["sh", "-c", "free -k | grep -E '^Mem|^Swap'"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const rawText = text.trim()
                    if (!rawText || rawText.length === 0) {
                        fallbackMemoryProcessAlt.running = true
                        return
                    }
                    
                    const lines = rawText.split('\n')
                    let memTotal = 0
                    let memUsed = 0
                    let memFree = 0
                    let memAvailable = 0
                    let swapTotal = 0
                    let swapFree = 0
                    
                    for (const line of lines) {
                        if (!line || line.trim().length === 0) continue
                        
                        const parts = line.trim().split(/\s+/)
                        
                        if (parts[0] === "Mem:") {
                            if (parts.length >= 7) {
                                memTotal = parseInt(parts[1]) || 0
                                memUsed = parseInt(parts[2]) || 0
                                memFree = parseInt(parts[3]) || 0
                                memAvailable = parseInt(parts[6]) || memFree
                            } else if (parts.length >= 4) {
                                memTotal = parseInt(parts[1]) || 0
                                memUsed = parseInt(parts[2]) || 0
                                memFree = parseInt(parts[3]) || 0
                                memAvailable = memFree
                            }
                        } else if (parts[0] === "Swap:") {
                            if (parts.length >= 4) {
                                swapTotal = parseInt(parts[1]) || 0
                                const swapUsed = parseInt(parts[2]) || 0
                                swapFree = parseInt(parts[3]) || (swapTotal - swapUsed)
                            }
                        }
                    }
                    
                    if (memTotal === 0) {
                        fallbackMemoryProcessAlt.running = true
                        return
                    }
                    
                    const memUsagePercent = memTotal > 0 ? (memUsed / memTotal) * 100 : 0
                    
                    const totalMB = memTotal / 1024
                    const usedMB = memUsed / 1024
                    const availableMB = (memAvailable || memFree) / 1024
                    const freeMB = memFree / 1024
                    
                    root.totalMemoryKB = memTotal
                    root.availableMemoryKB = memAvailable || memFree
                    root.usedMemoryKB = memUsed
                    root.totalMemoryMB = totalMB
                    root.availableMemoryMB = availableMB
                    root.usedMemoryMB = usedMB
                    root.freeMemoryMB = freeMB
                    root.memoryUsage = memUsagePercent
                    root.totalSwapKB = swapTotal
                    root.usedSwapKB = swapTotal - swapFree
                    
                    addToHistory(root.memoryHistory, root.memoryUsage)
                } catch (e) {
                    fallbackMemoryProcessAlt.running = true
                }
            }
        }
    }
    
    Process {
        id: fallbackMemoryProcessAlt
        command: ["sh", "-c", "cat /proc/meminfo | grep -E '^(MemTotal|MemAvailable|MemFree|SwapTotal|SwapFree):'"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const rawText = text.trim()
                    if (!rawText || rawText.length === 0) {
                        return
                    }
                    
                    const lines = rawText.split('\n')
                    let memTotal = 0
                    let memAvailable = 0
                    let memFree = 0
                    let swapTotal = 0
                    let swapFree = 0
                    
                    for (const line of lines) {
                        if (!line || line.trim().length === 0) continue
                        
                        const parts = line.trim().split(/\s+/)
                        let value = 0
                        
                        for (let i = 1; i < parts.length; i++) {
                            const parsed = parseInt(parts[i])
                            if (!isNaN(parsed) && parsed > 0) {
                                value = parsed
                                break
                            }
                        }
                        
                        if (value > 0) {
                            if (line.startsWith("MemTotal:")) {
                                memTotal = value
                            } else if (line.startsWith("MemAvailable:")) {
                                memAvailable = value
                            } else if (line.startsWith("MemFree:")) {
                                memFree = value
                            } else if (line.startsWith("SwapTotal:")) {
                                swapTotal = value
                            } else if (line.startsWith("SwapFree:")) {
                                swapFree = value
                            }
                        }
                    }
                    
                    if (memTotal === 0) {
                        return
                    }
                    
                    const usedMem = memTotal - (memAvailable || memFree)
                    const memUsagePercent = memTotal > 0 ? (usedMem / memTotal) * 100 : 0
                    
                    const totalMB = memTotal / 1024
                    const usedMB = usedMem / 1024
                    const availableMB = (memAvailable || memFree) / 1024
                    const freeMB = memFree / 1024
                    
                    root.totalMemoryKB = memTotal
                    root.availableMemoryKB = memAvailable || memFree
                    root.usedMemoryKB = usedMem
                    root.totalMemoryMB = totalMB
                    root.availableMemoryMB = availableMB
                    root.usedMemoryMB = usedMB
                    root.freeMemoryMB = freeMB
                    root.memoryUsage = memUsagePercent
                    root.totalSwapKB = swapTotal
                    root.usedSwapKB = swapTotal - swapFree
                    
                    addToHistory(root.memoryHistory, root.memoryUsage)
                } catch (e) {
                }
            }
        }
    }
    
    Process {
        id: fallbackNetworkProcess
        command: ["sh", "-c", "cat /proc/net/dev | grep -E '^\\s*(eth|en|wlan|wl|wlp)'"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const lines = text.trim().split('\n')
                    let totalRx = 0
                    let totalTx = 0
                    
                    for (const line of lines) {
                        const parts = line.trim().split(/\s+/)
                        if (parts.length >= 10) {
                            totalRx += parseInt(parts[1])
                            totalTx += parseInt(parts[9])
                        }
                    }
                    
                    if (root.lastNetworkStats) {
                        const timeDiff = root.updateInterval / 1000
                        const rxDiff = totalRx - root.lastNetworkStats.rx
                        const txDiff = totalTx - root.lastNetworkStats.tx
                        root.networkRxRate = (rxDiff / timeDiff) || 0
                        root.networkTxRate = (txDiff / timeDiff) || 0
                    }
                    root.lastNetworkStats = { rx: totalRx, tx: totalTx }
                } catch (e) {
                }
            }
        }
    }
    
    Process {
        id: fallbackCpuTempProcess
        command: ["sh", "-c", "for zone in /sys/class/thermal/thermal_zone*/temp /sys/devices/platform/coretemp.*/hwmon/hwmon*/temp*_input /sys/devices/system/cpu/cpu*/thermal_throttle/temp /sys/devices/pci*/hwmon/hwmon*/temp*_input; do [ -f \"$zone\" ] && echo \"$(cat $zone 2>/dev/null)\"; done | grep -v '^$' | grep -v '^0$' | sort -rn | head -1"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const tempText = text.trim()
                    if (tempText && tempText.length > 0) {
                        const temp = parseInt(tempText)
                        if (temp > 0) {
                            if (temp > 1000 && temp < 200000) {
                                root.cpuTemperature = temp / 1000.0
                            } else if (temp > 0 && temp < 200) {
                                root.cpuTemperature = temp
                            }
                            if (root.cpuTemperature > 0) {
                            } else {
                                fallbackSensorsProcess.running = true
                            }
                        } else {
                            fallbackSensorsProcess.running = true
                        }
                    } else {
                        fallbackSensorsProcess.running = true
                    }
                } catch (e) {
                    fallbackSensorsProcess.running = true
                }
            }
        }
    }
    
    Process {
        id: fallbackSensorsProcess
        command: ["sh", "-c", "sensors 2>/dev/null | grep -E '^Tctl:|^Tdie:|^Package id 0:|^CPU Temperature:' | head -1 | grep -oE '[0-9]+\\.[0-9]+' | head -1"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const tempText = text.trim()
                    if (tempText && tempText.length > 0) {
                        const temp = parseFloat(tempText)
                        if (temp > 0 && temp < 200) {
                            root.cpuTemperature = temp
                        } else {
                            fallbackCpuTempAltProcess.running = true
                        }
                    } else {
                        fallbackCpuTempAltProcess.running = true
                    }
                } catch (e) {
                    fallbackCpuTempAltProcess.running = true
                }
            }
        }
    }
    
    Process {
        id: fallbackCpuTempAltProcess
        command: ["sh", "-c", "sensors 2>/dev/null | grep -A 5 -E 'k10temp|coretemp' | grep -E '^Core 0|^Package id 0|^temp1:' | head -1 | grep -oE '[0-9]+\\.[0-9]+' | head -1"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const tempText = text.trim()
                    if (tempText && tempText.length > 0) {
                        const temp = parseFloat(tempText)
                        if (temp > 0 && temp < 200) {
                            root.cpuTemperature = temp
                        }
                    }
                } catch (e) {
                }
            }
        }
    }
    
    Process {
        id: fallbackGpuTempProcess
        command: ["sh", "-c", "for card in /sys/class/drm/card*/device/hwmon/hwmon*/temp*_input; do [ -f \"$card\" ] && cat \"$card\" 2>/dev/null; done | grep -v '^$' | sort -rn | head -1"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const tempText = text.trim()
                    if (tempText && tempText.length > 0) {
                        const temp = parseInt(tempText)
                        if (temp > 0 && temp < 200000) { // Sanity check
                            const tempC = temp / 1000.0
                            if (root.availableGpus.length > 0) {
                                const updatedGpus = root.availableGpus.slice()
                                updatedGpus[0].temperature = tempC
                                root.availableGpus = updatedGpus
                            } else {
                                root.availableGpus = [{
                                    name: "GPU",
                                    temperature: tempC,
                                    memoryUsedMB: 0,
                                    memoryTotalMB: 0
                                }]
                            }
                        } else {
                            fallbackGpuSensorsProcess.running = true
                        }
                    } else {
                        fallbackGpuSensorsProcess.running = true
                    }
                } catch (e) {
                    fallbackGpuSensorsProcess.running = true
                }
            }
        }
    }
    
    Process {
        id: fallbackGpuSensorsProcess
        command: ["sh", "-c", "sensors 2>/dev/null | grep -iE 'gpu|nvidia|amd|radeon' | grep -oE '[0-9]+\\.[0-9]+°C' | head -1 | grep -oE '[0-9]+\\.[0-9]+'"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const temp = parseFloat(text.trim())
                    if (temp > 0 && root.availableGpus.length > 0) {
                        const updatedGpus = root.availableGpus.slice()
                        updatedGpus[0].temperature = temp
                        root.availableGpus = updatedGpus
                    } else if (temp > 0 && root.availableGpus.length === 0) {
                        root.availableGpus = [{
                            name: "GPU",
                            temperature: temp,
                            memoryUsedMB: 0,
                            memoryTotalMB: 0
                        }]
                    }
                } catch (e) {
                }
            }
        }
    }
    
    Process {
        id: fallbackGpuInitProcess
        command: ["sh", "-c", "ls -d /sys/class/drm/card[0-9]* 2>/dev/null | grep -v '-' | wc -l"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const gpuCount = parseInt(text.trim())
                    if (gpuCount > 0 && root.availableGpus.length === 0) {
                        const gpus = []
                        for (let i = 0; i < gpuCount; i++) {
                            gpus.push({
                                name: "GPU " + (i + 1),
                                temperature: 0,
                                memoryUsedMB: 0,
                                memoryTotalMB: 0
                            })
                        }
                        root.availableGpus = gpus
                    }
                } catch (e) {
                }
            }
        }
    }
    
    Process {
        id: fallbackGpuNameProcess
        command: ["sh", "-c", "for card in /sys/class/drm/card[0-9]*/device/vendor /sys/class/drm/card[0-9]*/device/uevent; do [ -f \"$card\" ] && echo \"$card: $(cat $card 2>/dev/null | head -1)\"; done | head -3"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                } catch (e) {
                }
            }
        }
    }
    
    Process {
        id: fallbackCpuInfoProcess
        command: ["sh", "-c", "cat /proc/cpuinfo"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const lines = text.trim().split('\n')
                    let processorCount = 0
                    for (const line of lines) {
                        if (line.includes("model name") && !root.cpuModel) {
                            const match = line.match(/model name\s*:\s*(.+)/i)
                            if (match) {
                                root.cpuModel = match[1].trim()
                            }
                        } else if (line.includes("cpu cores") && root.cpuCores === 1) {
                            const match = line.match(/cpu cores\s*:\s*(\d+)/i)
                            if (match) {
                                root.cpuCores = parseInt(match[1])
                            }
                        } else if (line.startsWith("processor")) {
                            processorCount++
                        }
                    }
                    if (root.cpuCores === 1 && processorCount > 0) {
                        root.cpuCores = processorCount
                    }
                } catch (e) {
                }
            }
        }
    }
    
    Timer {
        id: fallbackUpdateTimer
        interval: root.updateInterval
        running: !root.dgopAvailable && root.refCount > 0 && root.enabledModules.length > 0
        repeat: true
        triggeredOnStart: true
        onTriggered: root.updateStatsFallback()
    }

    Component.onCompleted: {
        dgopCheckProcess.running = true
        nvmlCheckProcess.running = true
        osReleaseProcess.running = true
    }
}
