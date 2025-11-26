import QtQuick
import Quickshell.Wayland
import qs.Common

QtObject {
    id: root
    
    property var minimizedWindows: []
    property var windowPreviews: new Map()
    
    function minimizeWindow(toplevel) {
        if (!toplevel) return
        
        const existingIndex = minimizedWindows.findIndex(w => w.toplevel === toplevel)
        if (existingIndex !== -1) return
        
        const preview = captureWindowPreview(toplevel)
        
        const minimizedWindow = {
            toplevel: toplevel,
            appId: toplevel.appId || "unknown",
            title: toplevel.title || "(Unnamed)",
            preview: preview,
            minimizedAt: Date.now(),
            uniqueId: toplevel.title + "|" + (toplevel.appId || "") + "|" + Date.now()
        }
        
        minimizedWindows.push(minimizedWindow)
        windowPreviews.set(toplevel, preview)
        
        toplevel.minimized = true
        
        minimizedWindowsListChanged()
    }
    
    function restoreWindow(toplevel) {
        if (!toplevel) return
        
        const index = minimizedWindows.findIndex(w => w.toplevel === toplevel)
        if (index === -1) return
        
        minimizedWindows.splice(index, 1)
        windowPreviews.delete(toplevel)
        
        toplevel.minimized = false
        toplevel.activate()
        
        minimizedWindowsListChanged()
    }
    
    function isMinimized(toplevel) {
        return minimizedWindows.some(w => w.toplevel === toplevel)
    }
    
    function getMinimizedWindow(toplevel) {
        return minimizedWindows.find(w => w.toplevel === toplevel)
    }
    
    function captureWindowPreview(toplevel) {
        return {
            width: 200,
            height: 150,
            data: null, // Would contain actual image data
            timestamp: Date.now()
        }
    }
    
    function updateWindowPreview(toplevel) {
        if (!isMinimized(toplevel)) return
        
        const preview = captureWindowPreview(toplevel)
        const minimizedWindow = getMinimizedWindow(toplevel)
        if (minimizedWindow) {
            minimizedWindow.preview = preview
            windowPreviews.set(toplevel, preview)
        }
    }
    
    function clearAllMinimized() {
        minimizedWindows.forEach(w => {
            if (w.toplevel) {
                w.toplevel.minimized = false
            }
        })
        minimizedWindows = []
        windowPreviews.clear()
        minimizedWindowsListChanged()
    }
    
    signal minimizedWindowsListChanged()
}

