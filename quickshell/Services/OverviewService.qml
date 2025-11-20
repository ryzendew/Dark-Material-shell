pragma Singleton

pragma ComponentBehavior: Bound

import QtQuick
import QtCore
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.Services

Singleton {
    id: root

    // All windows from all workspaces and monitors
    property var allWindows: []
    
    // Get all windows grouped by monitor/screen
    // Uses the same approach as the dock - processes ALL windows from sortedToplevels
    function getAllWindowsByScreen() {
        if (!CompositorService.isHyprland) {
            return {}
        }
        
        const windowsByScreen = {}
        // Use sortedToplevels directly like the dock does - it contains ALL windows
        const sortedToplevels = CompositorService.sortedToplevels || []
        const hyprlandToplevels = Array.from(Hyprland.toplevels?.values || [])
        
        
        // Process each toplevel exactly like the dock does - include ALL windows
        sortedToplevels.forEach((toplevel, index) => {
            // Always include the window - don't skip if we can't find hyprToplevel
            const hyprToplevel = hyprlandToplevels.find(ht => ht.wayland === toplevel)
            
            // Get monitor name - try multiple sources
            let monitorName = "unknown"
            let workspaceId = -1
            
            if (hyprToplevel) {
                // Get monitor from hyprToplevel - try all possible sources
                // Method 1: lastIpcObject.monitor (most reliable - this is what Hyprland IPC uses)
                if (hyprToplevel.lastIpcObject && hyprToplevel.lastIpcObject.monitor) {
                    monitorName = String(hyprToplevel.lastIpcObject.monitor)
                }
                
                // Method 2: Direct monitor property
                if (monitorName === "unknown" && hyprToplevel.monitor) {
                    if (typeof hyprToplevel.monitor === "string") {
                        monitorName = hyprToplevel.monitor
                    } else if (hyprToplevel.monitor.name) {
                        monitorName = String(hyprToplevel.monitor.name)
                    }
                }
                
                // Method 3: Workspace monitor (via lastIpcObject first)
                if (monitorName === "unknown" && hyprToplevel.workspace) {
                    if (hyprToplevel.workspace.lastIpcObject && hyprToplevel.workspace.lastIpcObject.monitor) {
                        monitorName = String(hyprToplevel.workspace.lastIpcObject.monitor)
                    } else if (hyprToplevel.workspace.monitor) {
                        if (typeof hyprToplevel.workspace.monitor === "string") {
                            monitorName = hyprToplevel.workspace.monitor
                        } else if (hyprToplevel.workspace.monitor.name) {
                            monitorName = String(hyprToplevel.workspace.monitor.name)
                        }
                    }
                }
                
                workspaceId = hyprToplevel.workspace ? hyprToplevel.workspace.id : -1
            }
            
            // If still unknown, try to get from workspace that contains this window
            if (monitorName === "unknown" && workspaceId !== -1 && Hyprland.workspaces) {
                const workspaces = Array.from(Hyprland.workspaces.values || [])
                const workspace = workspaces.find(ws => ws.id === workspaceId)
                if (workspace) {
                    // Try workspace lastIpcObject first
                    if (workspace.lastIpcObject && workspace.lastIpcObject.monitor) {
                        monitorName = String(workspace.lastIpcObject.monitor)
                    } else if (workspace.monitor) {
                        if (typeof workspace.monitor === "string") {
                            monitorName = workspace.monitor
                        } else if (workspace.monitor.name) {
                            monitorName = String(workspace.monitor.name)
                        }
                    }
                }
            }
            
            // If monitor is still unknown, try to find it from workspace
            if (monitorName === "unknown" && workspaceId !== -1 && Hyprland.workspaces) {
                const workspaces = Array.from(Hyprland.workspaces.values || [])
                const workspace = workspaces.find(ws => ws.id === workspaceId)
                if (workspace) {
                    // Try all methods again on the workspace
                    if (workspace.lastIpcObject && workspace.lastIpcObject.monitor) {
                        monitorName = String(workspace.lastIpcObject.monitor)
                    } else if (workspace.monitor) {
                        if (typeof workspace.monitor === "string") {
                            monitorName = workspace.monitor
                        } else if (workspace.monitor.name) {
                            monitorName = String(workspace.monitor.name)
                        }
                    }
                }
            }
            
            // Always add the window, even if monitor is unknown
            if (!windowsByScreen[monitorName]) {
                windowsByScreen[monitorName] = []
            }
            
            // Get window address - try multiple sources
            let windowAddress = toplevel.address || ""
            if (!windowAddress && hyprToplevel) {
                windowAddress = hyprToplevel.address || ""
            }
            // Convert to string if it's a number
            if (windowAddress && typeof windowAddress !== "string") {
                windowAddress = String(windowAddress)
            }
            
            // Create window data - always include, even without full info
            const windowData = {
                toplevel: toplevel,
                appId: toplevel.appId || "unknown",
                title: toplevel.title || "(Unnamed)",
                address: windowAddress,
                isActive: toplevel.activated || false,
                workspaceId: workspaceId,
                monitorName: monitorName,
                index: index
            }
            
            windowsByScreen[monitorName].push(windowData)
        })
        
        
        return windowsByScreen
    }
    
    // Get windows for a specific screen
    function getWindowsForScreen(screenName) {
        const allWindows = getAllWindowsByScreen()
        return allWindows[screenName] || []
    }
    
    // Get all windows in a single flat list with global numbering
    // Windows are ordered by screen (DP-1, DP-2, DP-3, etc.) then by their order on that screen
    function getAllWindowsFlat() {
        const windowsByScreen = getAllWindowsByScreen()
        const allWindows = []
        
        // Get all screen names and sort them
        const screenNames = Object.keys(windowsByScreen).sort()
        
        // Add windows from each screen in order
        let globalIndex = 0
        screenNames.forEach(screenName => {
            const windows = windowsByScreen[screenName] || []
            windows.forEach(window => {
                // Add global index to window data (QML doesn't support spread operator)
                const windowWithGlobalIndex = {
                    toplevel: window.toplevel,
                    appId: window.appId,
                    title: window.title,
                    address: window.address,
                    isActive: window.isActive,
                    workspaceId: window.workspaceId,
                    monitorName: window.monitorName,
                    index: window.index,
                    globalIndex: globalIndex
                }
                allWindows.push(windowWithGlobalIndex)
                globalIndex++
            })
        })
        
        return allWindows
    }
    
    // Current workspace ID
    property int currentWorkspace: {
        if (CompositorService.isHyprland) {
            return Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1
        }
        return 1
    }
    
    // Windows for current workspace (legacy - kept for compatibility)
    property var currentWorkspaceWindows: {
        if (!CompositorService.isHyprland) {
            return []
        }
        
        const windows = []
        const toplevels = CompositorService.sortedToplevels || []
        const hyprlandToplevels = Array.from(Hyprland.toplevels?.values || [])
        
        toplevels.forEach(toplevel => {
            // Find corresponding Hyprland toplevel to get workspace
            const hyprToplevel = hyprlandToplevels.find(ht => ht.wayland === toplevel)
            if (hyprToplevel && hyprToplevel.workspace) {
                const workspaceId = hyprToplevel.workspace.id
                if (workspaceId === root.currentWorkspace) {
                    windows.push({
                        toplevel: toplevel,
                        appId: toplevel.appId || "unknown",
                        title: toplevel.title || "(Unnamed)",
                        address: toplevel.address || "",
                        isActive: toplevel.activated || false,
                        workspaceId: workspaceId
                    })
                }
            }
        })
        
        return windows
    }
    
    // Get app icon path
    function getAppIcon(appId) {
        if (!appId || appId === "unknown") {
            return ""
        }
        const desktopEntry = DesktopEntries.heuristicLookup(appId)
        if (desktopEntry && desktopEntry.icon) {
            return Quickshell.iconPath(desktopEntry.icon, true)
        }
        return ""
    }
    
    // Cache for window screenshots
    property var screenshotCache: new Map()
    signal screenshotsUpdated()
    
    // Pre-capture screenshots for all windows when overview opens
    function captureAllScreenshots() {
        if (!CompositorService.isHyprland) {
            console.log("OverviewService: Not Hyprland, skipping screenshots")
            return
        }
        
        const allWindows = getAllWindowsFlat()
        console.log("OverviewService: captureAllScreenshots - found", allWindows.length, "windows")
        
        if (allWindows.length === 0) {
            return
        }
        
        const cacheDir = StandardPaths.writableLocation(StandardPaths.CacheLocation) + "/quickshell/window_previews"
        console.log("OverviewService: Cache directory:", cacheDir)
        // Create directory - use execDetached (it should work fine)
        Quickshell.execDetached(["mkdir", "-p", cacheDir])
        
        const hyprlandToplevels = Array.from(Hyprland.toplevels?.values || [])
        console.log("OverviewService: Found", hyprlandToplevels.length, "Hyprland toplevels")
        
        let capturedCount = 0
        
        allWindows.forEach(window => {
            if (!window || !window.toplevel) {
                return
            }
            
            const cacheKey = window.address || window.toplevel.address || ""
            if (!cacheKey) {
                console.log("OverviewService: No address for window", window.title)
                return
            }
            
            // Skip if already cached and file exists
            if (screenshotCache.has(cacheKey)) {
                const cached = screenshotCache.get(cacheKey)
                if (Quickshell.fileExists(cached)) {
                    return
                }
            }
            
            const hyprToplevel = hyprlandToplevels.find(ht => ht.wayland === window.toplevel)
            if (!hyprToplevel) {
                console.log("OverviewService: No Hyprland toplevel found for", window.title)
                return
            }
            
            if (!hyprToplevel.lastIpcObject) {
                console.log("OverviewService: No lastIpcObject for", window.title)
                return
            }
            
            const ipcObj = hyprToplevel.lastIpcObject
            
            // Get window position and size
            let x = 0, y = 0, width = 0, height = 0
            
            if (ipcObj.at && Array.isArray(ipcObj.at) && ipcObj.at.length >= 2) {
                x = Math.round(ipcObj.at[0])
                y = Math.round(ipcObj.at[1])
            }
            
            if (ipcObj.size && Array.isArray(ipcObj.size) && ipcObj.size.length >= 2) {
                width = Math.round(ipcObj.size[0])
                height = Math.round(ipcObj.size[1])
            }
            
            // If no valid geometry, skip
            if (width <= 0 || height <= 0) {
                console.log("OverviewService: Invalid geometry for", window.title, "x:", x, "y:", y, "w:", width, "h:", height)
                return
            }
            
            // Generate screenshot path
            const screenshotPath = `${cacheDir}/${cacheKey}.png`
            
            // Capture window using grim with geometry
            const geometry = `${x},${y} ${width}x${height}`
            console.log("OverviewService: Capturing screenshot for", window.title, "geometry:", geometry, "path:", screenshotPath)
            Quickshell.execDetached(["grim", "-g", geometry, screenshotPath])
            
            // Cache the path
            screenshotCache.set(cacheKey, screenshotPath)
            capturedCount++
        })
        
        console.log("OverviewService: Initiated", capturedCount, "screenshot captures")
        
        // Signal that screenshots are being captured (they'll be ready shortly)
        Qt.callLater(() => {
            screenshotsUpdated()
        })
    }
    
    // Get window screenshot path - returns cached path if available
    function getWindowScreenshot(window) {
        if (!window || !window.toplevel) {
            return ""
        }
        
        // Check cache first
        const cacheKey = window.address || window.toplevel.address || ""
        if (cacheKey && screenshotCache.has(cacheKey)) {
            const cached = screenshotCache.get(cacheKey)
            // Check if file exists
            if (Quickshell.fileExists(cached)) {
                return "file://" + cached
            } else {
                screenshotCache.delete(cacheKey)
            }
        }
        
        // If not in cache, return empty (will be captured by captureAllScreenshots)
        return ""
    }
    
    // Activate a window - try multiple methods
    function activateWindow(window) {
        if (!window) {
            console.log("OverviewService: activateWindow - no window provided")
            return false
        }
        
        console.log("OverviewService: activateWindow called for:", window.title || window.appId)
        console.log("  - has toplevel:", !!window.toplevel)
        console.log("  - address:", window.address)
        console.log("  - workspaceId:", window.workspaceId)
        console.log("  - currentWorkspace:", root.currentWorkspace)
        
        // Method 1: Use toplevel.activate() if available (most reliable)
        if (window.toplevel) {
            // If window is on different workspace, switch workspace first
            if (window.workspaceId && window.workspaceId !== root.currentWorkspace && CompositorService.isHyprland) {
                console.log("OverviewService: Switching to workspace", window.workspaceId, "then activating window")
                Hyprland.dispatch(`workspace ${window.workspaceId}`)
                // Wait a bit for workspace switch, then activate
                Qt.callLater(() => {
                    if (window.toplevel) {
                        console.log("OverviewService: Activating toplevel after workspace switch")
                        window.toplevel.activate()
                    }
                })
            } else {
                // Same workspace, just activate
                console.log("OverviewService: Activating toplevel directly")
                window.toplevel.activate()
            }
            return true
        }
        
        // Method 2: Use Hyprland dispatch with address (fallback)
        if (CompositorService.isHyprland) {
            let windowAddress = window.address || ""
            
            // Try to get address from Hyprland toplevel
            if (!windowAddress) {
                const hyprlandToplevels = Array.from(Hyprland.toplevels?.values || [])
                // Try to find by matching wayland toplevel if we have it
                if (window.toplevel) {
                    const hyprToplevel = hyprlandToplevels.find(ht => ht.wayland === window.toplevel)
                    if (hyprToplevel) {
                        windowAddress = hyprToplevel.address || hyprToplevel.id || ""
                    }
                }
            }
            
            if (windowAddress) {
                let formattedAddress = String(windowAddress)
                // Format address - add 0x prefix if needed
                if (!formattedAddress.startsWith('0x') && !formattedAddress.startsWith('address:')) {
                    if (/^[0-9a-fA-F]+$/.test(formattedAddress)) {
                        formattedAddress = `0x${formattedAddress}`
                    }
                }
                
                // If window is on different workspace, switch workspace first
                if (window.workspaceId && window.workspaceId !== root.currentWorkspace) {
                    console.log("OverviewService: Switching to workspace", window.workspaceId, "then focusing window", formattedAddress)
                    Hyprland.dispatch(`workspace ${window.workspaceId}`)
                    Qt.callLater(() => {
                        Hyprland.dispatch(`focuswindow address:${formattedAddress}`)
                    })
                } else {
                    console.log("OverviewService: Focusing window address:", formattedAddress)
                    Hyprland.dispatch(`focuswindow address:${formattedAddress}`)
                }
                return true
            }
        }
        
        console.warn("OverviewService: Cannot activate window - no toplevel or address")
        console.warn("Window object:", window)
        return false
    }
    
    // Signal when windows change
    signal windowsChanged()
    
    // Refresh window list
    function refreshWindows() {
        // Force property update
        const ws = root.currentWorkspace
        root.currentWorkspace = -1
        Qt.callLater(() => {
            root.currentWorkspace = ws
            windowsChanged()
        })
    }
    
    // Listen to workspace changes
    Connections {
        target: CompositorService.isHyprland ? Hyprland : null
        function onFocusedWorkspaceChanged() {
            root.refreshWindows()
        }
    }
    
    // Listen to window changes
    Connections {
        target: CompositorService.isHyprland ? Hyprland : null
        function onToplevelsChanged() {
            root.refreshWindows()
        }
    }
    
    // Initial refresh
    Component.onCompleted: {
        refreshWindows()
    }
}

