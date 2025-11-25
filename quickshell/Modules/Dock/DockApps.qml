import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: root

    property var contextMenu: null
    property bool requestDockShow: false
    property int pinnedAppCount: 0

    implicitWidth: listView.width
    implicitHeight: listView.height

    function movePinnedApp(fromIndex, toIndex) {
        if (fromIndex === toIndex) {
            return
        }

        const currentPinned = [...(SessionData.pinnedApps || [])]
        if (fromIndex < 0 || fromIndex >= currentPinned.length || toIndex < 0 || toIndex >= currentPinned.length) {
            return
        }

        const movedApp = currentPinned.splice(fromIndex, 1)[0]
        currentPinned.splice(toIndex, 0, movedApp)

        // Update with animation - the ListView will handle the move animation
        SessionData.setPinnedApps(currentPinned)
    }

    function updateAllDropTargets() {
        // Find the dragging button
        var draggingButton = null
        var draggingIndex = -1
        for (var i = 0; i < listView.count; i++) {
            var item = listView.itemAtIndex(i)
            if (item && item.dockButton && item.dockButton.dragging) {
                draggingButton = item.dockButton
                draggingIndex = i
                break
            }
        }
        
        if (!draggingButton) {
            // console.log("No dragging button found")
            return
        }
        
        // console.log("Dragging button found, targetIndex:", draggingButton.targetIndex, "originalIndex:", draggingButton.originalIndex)
        
        // Clear all drop targets first
        for (var i = 0; i < listView.count; i++) {
            var item = listView.itemAtIndex(i)
            if (item) {
                item.isDropTarget = false
            }
        }
        
        // Set drop target based on dragging button's target index
        var targetIndex = draggingButton.targetIndex
        var originalIndex = draggingButton.originalIndex
        
        // console.log("Target index:", targetIndex, "original index:", originalIndex)
        
        if (targetIndex >= 0 && targetIndex < listView.count && targetIndex !== originalIndex) {
            // Show green glow on the icon that will be replaced
            var targetItem = listView.itemAtIndex(targetIndex)
            if (targetItem) {
                targetItem.isDropTarget = true
                // console.log("Set drop target at index:", targetIndex)
            } else {
                // console.log("No target item found at index:", targetIndex)
            }
        } else {
            // console.log("Invalid target index or same as original:", targetIndex)
        }
    }
    
    function clearAllDropTargets() {
        for (var i = 0; i < listView.count; i++) {
            var item = listView.itemAtIndex(i)
            if (item) {
                item.isDropTarget = false
            }
        }
    }

    ListView {
        id: listView
        orientation: ListView.Horizontal
        spacing: SettingsData.dockIconSpacing
        anchors.centerIn: parent
        height: SettingsData.dockIconSize
        width: contentWidth
        interactive: false
        
        // Add move transition for smooth animations
        move: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: 300
                easing.type: Easing.OutCubic
            }
        }
        
        moveDisplaced: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        model: ListModel {
                id: dockModel

                Component.onCompleted: updateModel()

                function updateModel() {
                    clear()

                    const items = []
                    const pinnedApps = [...(SessionData.pinnedApps || [])]
                    const sortedToplevels = CompositorService.sortedToplevels

                    if (SettingsData.dockGroupApps) {
                        // Grouping enabled - handle pinned apps with running windows
                        const groupedApps = {}
                        const unpinnedRunningApps = new Set()
                        
                        // First, collect all running windows by appId
                        sortedToplevels.forEach((toplevel, index) => {
                            const appId = toplevel.appId || "unknown"
                            if (!groupedApps[appId]) {
                                groupedApps[appId] = {
                                    isPinned: pinnedApps.includes(appId),
                                    windows: []
                                }
                            }
                            
                            const title = toplevel.title || "(Unnamed)"
                            const truncatedTitle = title.length > 50 ? title.substring(0, 47) + "..." : title
                            const uniqueId = toplevel.title + "|" + (toplevel.appId || "") + "|" + index
                            
                            groupedApps[appId].windows.push({
                                toplevel: toplevel,
                                title: title,
                                truncatedTitle: truncatedTitle,
                                uniqueId: uniqueId,
                                index: index
                            })
                            
                            if (!pinnedApps.includes(appId)) {
                                unpinnedRunningApps.add(appId)
                            }
                        })
                        
                        // Add pinned apps (with or without running windows)
                        pinnedApps.forEach(appId => {
                            const app = groupedApps[appId]
                            const isGrouped = app && app.windows.length > 1
                            
                            items.push({
                                "type": isGrouped ? "grouped" : (app && app.windows && app.windows.length > 0 ? "window" : "pinned"),
                                "appId": appId || "",
                                "windowId": isGrouped ? -1 : (app && app.windows && app.windows.length > 0 ? app.windows[0].index : -1),
                                "windowTitle": isGrouped ? "" : (app && app.windows && app.windows.length > 0 ? app.windows[0].truncatedTitle : ""),
                                "workspaceId": -1,
                                "isPinned": true,
                                "isRunning": !!(app && app.windows && app.windows.length > 0),
                                "isFocused": false,
                                "isGrouped": !!isGrouped,
                                "windowCount": app && app.windows ? app.windows.length : 0,
                                "windows": app && app.windows ? app.windows : [],
                                "uniqueId": isGrouped ? appId + "_group" : (app && app.windows && app.windows.length > 0 ? app.windows[0].uniqueId : appId + "_pinned")
                            })
                        })
                        
                        // Add separator if we have both pinned and unpinned apps
                        if (pinnedApps.length > 0 && unpinnedRunningApps.size > 0) {
                            items.push({
                                "type": "separator",
                                "appId": "__SEPARATOR__",
                                "windowId": -1,
                                "windowTitle": "",
                                "workspaceId": -1,
                                "isPinned": false,
                                "isRunning": false,
                                "isFocused": false,
                                "isGrouped": false,
                                "windowCount": 0,
                                "windows": [],
                                "uniqueId": "__SEPARATOR__"
                            })
                        }
                        
                        // Add unpinned running apps
                        unpinnedRunningApps.forEach(appId => {
                            const app = groupedApps[appId]
                            const isGrouped = app.windows.length > 1
                            
                            items.push({
                                "type": isGrouped ? "grouped" : "window",
                                "appId": appId || "",
                                "windowId": isGrouped ? -1 : (app.windows && app.windows[0] ? app.windows[0].index : -1),
                                "windowTitle": isGrouped ? "" : (app.windows && app.windows[0] ? app.windows[0].truncatedTitle : ""),
                                "workspaceId": -1,
                                "isPinned": false,
                                "isRunning": true,
                                "isFocused": false,
                                "isGrouped": !!isGrouped,
                                "windowCount": app.windows ? app.windows.length : 0,
                                "windows": app.windows || [],
                                "uniqueId": isGrouped ? appId + "_group" : (app.windows && app.windows[0] ? app.windows[0].uniqueId : appId + "_window")
                            })
                        })
                        
                        root.pinnedAppCount = pinnedApps.length
                    } else {
                        // Original behavior - no grouping
                        pinnedApps.forEach(appId => {
                            items.push({
                                "type": "pinned",
                                "appId": appId || "",
                                "windowId": -1,
                                "windowTitle": "",
                                "workspaceId": -1,
                                "isPinned": true,
                                "isRunning": false,
                                "isFocused": false,
                                "isGrouped": false,
                                "windowCount": 0,
                                "windows": [],
                                "uniqueId": (appId || "") + "_pinned"
                            })
                        })

                        root.pinnedAppCount = pinnedApps.length

                        if (pinnedApps.length > 0 && sortedToplevels.length > 0) {
                            items.push({
                                "type": "separator",
                                "appId": "__SEPARATOR__",
                                "windowId": -1,
                                "windowTitle": "",
                                "workspaceId": -1,
                                "isPinned": false,
                                "isRunning": false,
                                "isFocused": false,
                                "isGrouped": false,
                                "windowCount": 0,
                                "windows": [],
                                "uniqueId": "__SEPARATOR__"
                            })
                        }

                        sortedToplevels.forEach((toplevel, index) => {
                            const title = toplevel.title || "(Unnamed)"
                            const truncatedTitle = title.length > 50 ? title.substring(0, 47) + "..." : title
                            const uniqueId = toplevel.title + "|" + (toplevel.appId || "") + "|" + index
                            const isMinimized = false

                            items.push({
                                "type": "window",
                                "appId": toplevel.appId || "",
                                "windowId": index,
                                "windowTitle": truncatedTitle || "",
                                "workspaceId": -1,
                                "isPinned": false,
                                "isRunning": true,
                                "isFocused": false,
                                "isGrouped": false,
                                "isMinimized": isMinimized,
                                "windowCount": 1,
                                "windows": [],
                                "uniqueId": uniqueId || ""
                            })
                        })
                    }

                    items.forEach(item => append(item))
                }
            }

        delegate: Item {
                id: delegateItem
                property alias dockButton: button
                property bool isDropTarget: false

                width: model.type === "separator" ? 16 : SettingsData.dockIconSize
                height: SettingsData.dockIconSize

                // Drop target indicator - shows green glow on the icon being replaced
                Rectangle {
                    anchors.fill: parent
                    radius: Theme.cornerRadius
                    color: Qt.rgba(0, 1, 0, 0.2) // Green background
                    border.width: 3
                    border.color: "#00ff00" // Bright green border
                    visible: isDropTarget
                    z: 5
                    
                    // Glow effect
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -3
                        radius: parent.radius + 3
                        color: "transparent"
                        border.width: 2
                        border.color: Qt.rgba(0, 1, 0, 0.6)
                    }
                    
                    // Pulsing animation
                    SequentialAnimation on opacity {
                        running: isDropTarget
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.6; duration: 500; easing.type: Easing.InOutQuad }
                        NumberAnimation { to: 1.0; duration: 500; easing.type: Easing.InOutQuad }
                    }
                    
                    // Scale animation
                    scale: isDropTarget ? 1.05 : 1.0
                    Behavior on scale {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                Rectangle {
                    visible: model.type === "separator"
                    width: 2
                    height: 20
                    color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.3)
                    radius: 1
                    anchors.centerIn: parent
                }

                DockAppButton {
                    id: button
                    visible: model.type !== "separator"
                    anchors.centerIn: parent

                    width: SettingsData.dockIconSize
                    height: SettingsData.dockIconSize

                    appData: model
                    contextMenu: root.contextMenu
                    dockApps: root
                    index: model.index

                    // Override tooltip for windows to show window title
                    showWindowTitle: model.type === "window"
                    windowTitle: model.windowTitle || ""
                }
                
                // Update drop target based on any button's dragging state
                Connections {
                    target: button
                    function onDraggingChanged() {
                        if (button && button.dragging) {
                            root.updateAllDropTargets()
                        } else {
                            root.clearAllDropTargets()
                        }
                    }
                    
                    function onTargetIndexChanged() {
                        if (button && button.dragging) {
                            root.updateAllDropTargets()
                        }
                    }
                }
            }
        }

    Connections {
        target: CompositorService
        function onSortedToplevelsChanged() {
            dockModel.updateModel()
        }
    }

    Connections {
        target: SessionData
        function onPinnedAppsChanged() {
            dockModel.updateModel()
        }
    }

    Connections {
        target: SettingsData
        function onDockGroupAppsChanged() {
            dockModel.updateModel()
        }
    }
    
}
