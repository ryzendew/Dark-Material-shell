pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var availableLayouts: []
    property var availableVariants: []
    property string currentLayout: ""
    property string currentVariant: ""
    property var activeLayouts: [] // Array of {layout: "", variant: ""}
    property var availableLocales: []
    property string currentLocale: ""
    property string currentLanguage: ""
    property string currentRegion: ""
    property bool isLoading: false
    property string lastError: ""

    function refreshStatus() {
        if (statusProcess.running) return
        statusProcess.running = true
    }

    function listLayouts() {
        if (layoutListProcess.running) return
        layoutListProcess.running = true
    }

    function listVariants(layout) {
        if (!layout || layout.length === 0) {
            availableVariants = []
            return
        }
        variantListProcess.command = ["localectl", "list-x11-keymap-variants", layout]
        variantListProcess.running = true
    }

    function listLocales() {
        if (localeListProcess.running) return
        localeListProcess.running = true
    }

    function setLayout(layout, variant) {
        if (!layout || layout.length === 0) return
        var cmd = ["localectl", "set-x11-keymap", layout]
        if (variant && variant.length > 0) {
            cmd.push(variant)
        }
        setLayoutProcess.command = cmd
        setLayoutProcess.running = true
        
        // Also apply immediately using setxkbmap for current session
        var xkbCmd = ["setxkbmap", layout]
        if (variant && variant.length > 0) {
            xkbCmd.push("-variant", variant)
        }
        immediateLayoutProcess.command = xkbCmd
        immediateLayoutProcess.running = true
    }

    function setLocale(locale) {
        if (!locale || locale.length === 0) return
        setLocaleProcess.command = ["localectl", "set-locale", locale]
        setLocaleProcess.running = true
    }

    function addLayout(layout, variant) {
        // Add a layout to the active layouts list
        var layouts = activeLayouts.slice()
        layouts.push({
            layout: layout || "",
            variant: variant || ""
        })
        activeLayouts = layouts
        applyLayouts()
    }

    function removeLayout(index) {
        var layouts = activeLayouts.slice()
        if (index >= 0 && index < layouts.length) {
            layouts.splice(index, 1)
            activeLayouts = layouts
            applyLayouts()
        }
    }

    function applyLayouts() {
        // Apply all active layouts using setxkbmap
        if (activeLayouts.length === 0) return
        
        var cmd = ["setxkbmap"]
        var layouts = []
        var variants = []
        
        for (var i = 0; i < activeLayouts.length; i++) {
            var item = activeLayouts[i]
            layouts.push(item.layout || "us")
            if (item.variant && item.variant.length > 0) {
                variants.push(item.variant)
            } else {
                variants.push("")
            }
        }
        
        cmd.push("-layout", layouts.join(","))
        if (variants.some(v => v.length > 0)) {
            cmd.push("-variant", variants.join(","))
        }
        
        applyLayoutsProcess.command = cmd
        applyLayoutsProcess.running = true
    }

    Component.onCompleted: {
        refreshStatus()
        listLayouts()
        listLocales()
    }

    // Process to get current keyboard status
    Process {
        id: statusProcess
        running: false
        command: ["localectl", "status", "--no-pager"]

        onExited: exitCode => {
            if (exitCode !== 0) {
                root.lastError = "Failed to get keyboard status"
                return
            }
            root.lastError = ""
        }

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split('\n')
                for (let line of lines) {
                    line = line.trim()
                    if (line.startsWith('System Locale:')) {
                        const match = line.match(/System Locale:\s+(.+)/)
                        if (match) {
                            root.currentLocale = match[1].trim()
                            // Parse locale to get language and region
                            const parts = root.currentLocale.split('.')
                            if (parts.length > 0) {
                                const langParts = parts[0].split('_')
                                root.currentLanguage = langParts[0] || ""
                                root.currentRegion = langParts[1] || ""
                            }
                        }
                    } else if (line.startsWith('X11 Layout:')) {
                        const match = line.match(/X11 Layout:\s+(.+)/)
                        if (match) {
                            root.currentLayout = match[1].trim()
                        }
                    } else if (line.startsWith('X11 Variant:')) {
                        const match = line.match(/X11 Variant:\s+(.+)/)
                        if (match) {
                            root.currentVariant = match[1].trim()
                        }
                    } else if (line.startsWith('X11 Model:')) {
                        // Model info if needed
                    }
                }
            }
        }
    }

    // Process to list available keyboard layouts
    Process {
        id: layoutListProcess
        running: false
        command: ["localectl", "list-x11-keymap-layouts"]

        onExited: exitCode => {
            if (exitCode !== 0) {
                root.lastError = "Failed to list keyboard layouts"
                return
            }
        }

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split('\n').filter(line => line.trim().length > 0)
                root.availableLayouts = lines.sort()
                root.lastError = ""
            }
        }
    }

    // Process to list variants for a layout
    Process {
        id: variantListProcess
        running: false
        command: []

        onExited: exitCode => {
            if (exitCode === 0) {
                root.lastError = ""
            } else {
                root.lastError = "Failed to list variants"
            }
        }

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split('\n').filter(line => line.trim().length > 0)
                root.availableVariants = lines.sort()
                root.lastError = ""
            }
        }
    }

    // Process to list available locales
    Process {
        id: localeListProcess
        running: false
        command: ["localectl", "list-locales"]

        onExited: exitCode => {
            if (exitCode !== 0) {
                root.lastError = "Failed to list locales"
                return
            }
        }

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split('\n').filter(line => line.trim().length > 0)
                root.availableLocales = lines.sort()
                root.lastError = ""
            }
        }
    }

    // Process to set keyboard layout
    Process {
        id: setLayoutProcess
        running: false
        command: []

        onExited: exitCode => {
            if (exitCode === 0) {
                root.lastError = ""
                // Refresh status after setting layout
                Qt.callLater(() => refreshStatus())
            } else {
                root.lastError = "Failed to set keyboard layout (exit code: " + exitCode + ")"
            }
        }
    }

    // Process to set locale
    Process {
        id: setLocaleProcess
        running: false
        command: []

        onExited: exitCode => {
            if (exitCode === 0) {
                root.lastError = ""
                // Refresh status after setting locale
                Qt.callLater(() => refreshStatus())
            } else {
                root.lastError = "Failed to set locale (exit code: " + exitCode + ")"
            }
        }
    }

    // Process to apply layouts using setxkbmap
    Process {
        id: applyLayoutsProcess
        running: false
        command: []

        onExited: exitCode => {
            if (exitCode === 0) {
                root.lastError = ""
                // Refresh status after applying layouts
                Qt.callLater(() => refreshStatus())
            } else {
                root.lastError = "Failed to apply keyboard layouts (exit code: " + exitCode + ")"
            }
        }
    }

    // Process to immediately apply layout using setxkbmap (for current session)
    Process {
        id: immediateLayoutProcess
        running: false
        command: []

        onExited: exitCode => {
            if (exitCode === 0) {
                root.lastError = ""
            } else {
                // Don't set error for immediate application failures, just log
                console.warn("Failed to immediately apply keyboard layout (exit code: " + exitCode + ")")
            }
        }
    }
}

