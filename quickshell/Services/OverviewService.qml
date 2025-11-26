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

    property var allWindows: []
    
    function getAllWindowsByScreen() {
        if (!CompositorService.isHyprland) {
            return {}
        }
        
        const windowsByScreen = {}
        const sortedToplevels = CompositorService.sortedToplevels || []
        const hyprlandToplevels = Array.from(Hyprland.toplevels?.values || [])
        
        
        sortedToplevels.forEach((toplevel, index) => {
            const hyprToplevel = hyprlandToplevels.find(ht => ht.wayland === toplevel)
            
            let monitorName = "unknown"
            let workspaceId = -1
            
            if (hyprToplevel) {
                if (hyprToplevel.lastIpcObject && hyprToplevel.lastIpcObject.monitor) {
                    monitorName = String(hyprToplevel.lastIpcObject.monitor)
                }
                
                if (monitorName === "unknown" && hyprToplevel.monitor) {
                    if (typeof hyprToplevel.monitor === "string") {
                        monitorName = hyprToplevel.monitor
                    } else if (hyprToplevel.monitor.name) {
                        monitorName = String(hyprToplevel.monitor.name)
                    }
                }
                
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
            
            if (monitorName === "unknown" && workspaceId !== -1 && Hyprland.workspaces) {
                const workspaces = Array.from(Hyprland.workspaces.values || [])
                const workspace = workspaces.find(ws => ws.id === workspaceId)
                if (workspace) {
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
            
            if (monitorName === "unknown" && workspaceId !== -1 && Hyprland.workspaces) {
                const workspaces = Array.from(Hyprland.workspaces.values || [])
                const workspace = workspaces.find(ws => ws.id === workspaceId)
                if (workspace) {
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
            
            if (!windowsByScreen[monitorName]) {
                windowsByScreen[monitorName] = []
            }
            
            let windowAddress = toplevel.address || ""
            if (!windowAddress && hyprToplevel) {
                windowAddress = hyprToplevel.address || ""
            }
            if (windowAddress && typeof windowAddress !== "string") {
                windowAddress = String(windowAddress)
            }
            
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
    
    function getWindowsForScreen(screenName) {
        const allWindows = getAllWindowsByScreen()
        return allWindows[screenName] || []
    }
    
    function getAllWindowsFlat() {
        const windowsByScreen = getAllWindowsByScreen()
        const allWindows = []
        
        const screenNames = Object.keys(windowsByScreen).sort()
        
        let globalIndex = 0
        screenNames.forEach(screenName => {
            const windows = windowsByScreen[screenName] || []
            windows.forEach(window => {
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
    
    property int currentWorkspace: {
        if (CompositorService.isHyprland) {
            return Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1
        }
        return 1
    }
    
    property var currentWorkspaceWindows: {
        if (!CompositorService.isHyprland) {
            return []
        }
        
        const windows = []
        const toplevels = CompositorService.sortedToplevels || []
        const hyprlandToplevels = Array.from(Hyprland.toplevels?.values || [])
        
        toplevels.forEach(toplevel => {
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
    
    property var screenshotCache: new Map()
    signal screenshotsUpdated()
    
    function captureAllScreenshots() {
        if (!CompositorService.isHyprland) {
            return
        }
        
        const allWindows = getAllWindowsFlat()
        
        if (allWindows.length === 0) {
            return
        }
        
        let cacheDir = StandardPaths.writableLocation(StandardPaths.CacheLocation).toString()
        if (cacheDir.startsWith("file://")) {
            cacheDir = cacheDir.replace("file://", "")
        }
        cacheDir = cacheDir + "/quickshell/window_previews"
        Quickshell.execDetached(["mkdir", "-p", cacheDir])
        
        const hyprlandToplevels = Array.from(Hyprland.toplevels?.values || [])
        
        let capturedCount = 0
        
        allWindows.forEach(window => {
            if (!window || !window.toplevel) {
                return
            }
            
            const cacheKey = window.address || window.toplevel.address || ""
            if (!cacheKey) {
                return
            }
            
            if (screenshotCache.has(cacheKey)) {
                const cached = screenshotCache.get(cacheKey)
                if (Quickshell.fileExists(cached)) {
                    return
                }
            }
            
            const hyprToplevel = hyprlandToplevels.find(ht => ht.wayland === window.toplevel)
            if (!hyprToplevel) {
                return
            }
            
            if (!hyprToplevel.lastIpcObject) {
                return
            }
            
            const ipcObj = hyprToplevel.lastIpcObject
            
            let x = 0, y = 0, width = 0, height = 0
            
            if (ipcObj.at && Array.isArray(ipcObj.at) && ipcObj.at.length >= 2) {
                x = Math.round(ipcObj.at[0])
                y = Math.round(ipcObj.at[1])
            }
            
            if (ipcObj.size && Array.isArray(ipcObj.size) && ipcObj.size.length >= 2) {
                width = Math.round(ipcObj.size[0])
                height = Math.round(ipcObj.size[1])
            }
            
            if (width <= 0 || height <= 0) {
                return
            }
            
            const screenshotPath = `${cacheDir}/${cacheKey}.png`
            
            const geometry = `${x},${y} ${width}x${height}`
            Quickshell.execDetached(["grim", "-g", geometry, screenshotPath])
            
            screenshotCache.set(cacheKey, screenshotPath)
            capturedCount++
        })
        
        
        Qt.callLater(() => {
            screenshotsUpdated()
        })
    }
    
    function getWindowScreenshot(window) {
        if (!window || !window.toplevel) {
            return ""
        }
        
        const cacheKey = window.address || window.toplevel.address || ""
        if (cacheKey && screenshotCache.has(cacheKey)) {
            const cached = screenshotCache.get(cacheKey)
            if (Quickshell.fileExists(cached)) {
                return cached
            } else {
                screenshotCache.delete(cacheKey)
            }
        }
        
        return ""
    }
    
    function activateWindow(window) {
        if (!window) {
            return false
        }
        
        
        if (window.toplevel) {
            if (window.workspaceId && window.workspaceId !== root.currentWorkspace && CompositorService.isHyprland) {
                Hyprland.dispatch(`workspace ${window.workspaceId}`)
                Qt.callLater(() => {
                    if (window.toplevel) {
                        window.toplevel.activate()
                    }
                })
            } else {
                window.toplevel.activate()
            }
            return true
        }
        
        if (CompositorService.isHyprland) {
            let windowAddress = window.address || ""
            
            if (!windowAddress) {
                const hyprlandToplevels = Array.from(Hyprland.toplevels?.values || [])
                if (window.toplevel) {
                    const hyprToplevel = hyprlandToplevels.find(ht => ht.wayland === window.toplevel)
                    if (hyprToplevel) {
                        windowAddress = hyprToplevel.address || hyprToplevel.id || ""
                    }
                }
            }
            
            if (windowAddress) {
                let formattedAddress = String(windowAddress)
                if (!formattedAddress.startsWith('0x') && !formattedAddress.startsWith('address:')) {
                    if (/^[0-9a-fA-F]+$/.test(formattedAddress)) {
                        formattedAddress = `0x${formattedAddress}`
                    }
                }
                
                if (window.workspaceId && window.workspaceId !== root.currentWorkspace) {
                    Hyprland.dispatch(`workspace ${window.workspaceId}`)
                    Qt.callLater(() => {
                        Hyprland.dispatch(`focuswindow address:${formattedAddress}`)
                    })
                } else {
                    Hyprland.dispatch(`focuswindow address:${formattedAddress}`)
                }
                return true
            }
        }
        
        return false
    }
    
    signal windowsChanged()
    
    function refreshWindows() {
        const ws = root.currentWorkspace
        root.currentWorkspace = -1
        Qt.callLater(() => {
            root.currentWorkspace = ws
            windowsChanged()
        })
    }
    
    Connections {
        target: CompositorService.isHyprland ? Hyprland : null
        function onFocusedWorkspaceChanged() {
            root.refreshWindows()
        }
    }
    
    Connections {
        target: CompositorService.isHyprland ? Hyprland : null
        function onToplevelsChanged() {
            root.refreshWindows()
        }
    }
    
    Component.onCompleted: {
        refreshWindows()
    }
}

