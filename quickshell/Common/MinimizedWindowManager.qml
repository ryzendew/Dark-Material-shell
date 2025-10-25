import QtQuick
import Quickshell.Wayland
import qs.Common

QtObject {
    id: root
    
    // Store minimized windows with their previews
    property var minimizedWindows: []
    property var windowPreviews: new Map()
    
    // Add a window to minimized state
    function minimizeWindow(toplevel) {
        if (!toplevel) return
        
        // Check if already minimized
        const existingIndex = minimizedWindows.findIndex(w => w.toplevel === toplevel)
        if (existingIndex !== -1) return
        
        // Capture window preview before minimizing
        const preview = captureWindowPreview(toplevel)
        
        // Add to minimized list
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
        
        // Actually minimize the window
        toplevel.minimized = true
        
        // console.log("Minimized window:", minimizedWindow.title, "Total minimized:", minimizedWindows.length)
        minimizedWindowsListChanged()
    }
    
    // Restore a minimized window
    function restoreWindow(toplevel) {
        if (!toplevel) return
        
        const index = minimizedWindows.findIndex(w => w.toplevel === toplevel)
        if (index === -1) return
        
        // Remove from minimized list
        minimizedWindows.splice(index, 1)
        windowPreviews.delete(toplevel)
        
        // Restore the window
        toplevel.minimized = false
        toplevel.activate()
        
        // console.log("Restored window:", toplevel.title, "Remaining minimized:", minimizedWindows.length)
        minimizedWindowsListChanged()
    }
    
    // Check if a window is minimized
    function isMinimized(toplevel) {
        return minimizedWindows.some(w => w.toplevel === toplevel)
    }
    
    // Get minimized window by toplevel
    function getMinimizedWindow(toplevel) {
        return minimizedWindows.find(w => w.toplevel === toplevel)
    }
    
    // Capture window preview (placeholder - will be enhanced)
    function captureWindowPreview(toplevel) {
        // For now, return a placeholder
        // In a real implementation, this would capture the actual window content
        return {
            width: 200,
            height: 150,
            data: null, // Would contain actual image data
            timestamp: Date.now()
        }
    }
    
    // Update preview for a window
    function updateWindowPreview(toplevel) {
        if (!isMinimized(toplevel)) return
        
        const preview = captureWindowPreview(toplevel)
        const minimizedWindow = getMinimizedWindow(toplevel)
        if (minimizedWindow) {
            minimizedWindow.preview = preview
            windowPreviews.set(toplevel, preview)
        }
    }
    
    // Clear all minimized windows
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
    
    // Signal when minimized windows change
    signal minimizedWindowsListChanged()
}

