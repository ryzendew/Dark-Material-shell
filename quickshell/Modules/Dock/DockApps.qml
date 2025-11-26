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

        SessionData.setPinnedApps(currentPinned)
    }

    function updateAllDropTargets() {
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
            return
        }
        
        
        for (var i = 0; i < listView.count; i++) {
            var item = listView.itemAtIndex(i)
            if (item) {
                item.isDropTarget = false
            }
        }
        
        var targetIndex = draggingButton.targetIndex
        var originalIndex = draggingButton.originalIndex
        
        
        if (targetIndex >= 0 && targetIndex < listView.count && targetIndex !== originalIndex) {
            var targetItem = listView.itemAtIndex(targetIndex)
            if (targetItem) {
                targetItem.isDropTarget = true
            } else {
            }
        } else {
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

                function normalizeAppId(appId) {
                    if (!appId) return ""
                    var normalized = appId.toString()
                    if (normalized.endsWith(".desktop")) {
                        normalized = normalized.substring(0, normalized.length - 8)
                    }
                    return normalized.toLowerCase()
                }
                
                function isPinnedApp(appId, pinnedApps) {
                    if (!appId || !pinnedApps || pinnedApps.length === 0) return false
                    const normalizedAppId = normalizeAppId(appId)
                    for (var i = 0; i < pinnedApps.length; i++) {
                        const normalizedPinned = normalizeAppId(pinnedApps[i])
                        if (normalizedAppId === normalizedPinned) return true
                    }
                    return false
                }
                
                function findMatchingPinnedAppId(appId, pinnedApps) {
                    if (!appId || !pinnedApps || pinnedApps.length === 0) return null
                    const normalizedAppId = normalizeAppId(appId)
                    for (var i = 0; i < pinnedApps.length; i++) {
                        const normalizedPinned = normalizeAppId(pinnedApps[i])
                        if (normalizedAppId === normalizedPinned) return pinnedApps[i]
                    }
                    return null
                }

                function updateModel() {
                    clear()

                    const items = []
                    const pinnedApps = [...(SessionData.pinnedApps || [])]
                    const sortedToplevels = CompositorService.sortedToplevels

                    if (SettingsData.dockGroupApps) {
                        const groupedApps = {}
                        const unpinnedRunningApps = new Set()
                        const appIdToPinnedId = {}
                        
                        sortedToplevels.forEach((toplevel, index) => {
                            const appId = toplevel.appId || "unknown"
                            const matchingPinnedId = findMatchingPinnedAppId(appId, pinnedApps)
                            const effectiveAppId = matchingPinnedId || normalizeAppId(appId)
                            
                            if (!groupedApps[effectiveAppId]) {
                                groupedApps[effectiveAppId] = {
                                    isPinned: !!matchingPinnedId,
                                    windows: [],
                                    actualAppId: appId, // Store the actual appId from toplevel
                                    pinnedAppId: matchingPinnedId // Store the pinned appId for reference
                                }
                                if (matchingPinnedId) {
                                    appIdToPinnedId[effectiveAppId] = matchingPinnedId
                                }
                            } else {
                                if (matchingPinnedId && !groupedApps[effectiveAppId].pinnedAppId) {
                                    groupedApps[effectiveAppId].pinnedAppId = matchingPinnedId
                                    groupedApps[effectiveAppId].isPinned = true
                                }
                            }
                            
                            const title = toplevel.title || "(Unnamed)"
                            const truncatedTitle = title.length > 50 ? title.substring(0, 47) + "..." : title
                            const uniqueId = toplevel.title + "|" + (toplevel.appId || "") + "|" + index
                            
                            groupedApps[effectiveAppId].windows.push({
                                toplevel: toplevel,
                                title: title,
                                truncatedTitle: truncatedTitle,
                                uniqueId: uniqueId,
                                index: index
                            })
                            
                            if (!matchingPinnedId) {
                                unpinnedRunningApps.add(effectiveAppId)
                            }
                        })
                        
                        const pinnedAppMap = {}
                        pinnedApps.forEach(pinnedAppId => {
                            let matchedApp = null
                            let matchedKey = null
                            for (const key in groupedApps) {
                                const app = groupedApps[key]
                                if (findMatchingPinnedAppId(key, [pinnedAppId])) {
                                    matchedApp = app
                                    matchedKey = key
                                    break
                                }
                            }
                            
                            if (!matchedApp) {
                                for (const key in groupedApps) {
                                    const app = groupedApps[key]
                                    for (var i = 0; i < app.windows.length; i++) {
                                        const windowAppId = app.windows[i].toplevel.appId || "unknown"
                                        if (findMatchingPinnedAppId(windowAppId, [pinnedAppId])) {
                                            matchedApp = app
                                            matchedKey = key
                                            break
                                        }
                                    }
                                    if (matchedApp) break
                                }
                            }
                            
                            const app = matchedApp
                            const isGrouped = app && app.windows.length > 1
                            
                            items.push({
                                "type": isGrouped ? "grouped" : (app && app.windows && app.windows.length > 0 ? "window" : "pinned"),
                                "appId": pinnedAppId || "",
                                "windowId": isGrouped ? -1 : (app && app.windows && app.windows.length > 0 ? app.windows[0].index : -1),
                                "windowTitle": isGrouped ? "" : (app && app.windows && app.windows.length > 0 ? app.windows[0].truncatedTitle : ""),
                                "workspaceId": -1,
                                "isPinned": true,
                                "isRunning": !!(app && app.windows && app.windows.length > 0),
                                "isFocused": false,
                                "isGrouped": !!isGrouped,
                                "windowCount": app && app.windows ? app.windows.length : 0,
                                "windows": app && app.windows ? app.windows : [],
                                "uniqueId": isGrouped ? pinnedAppId + "_group" : (app && app.windows && app.windows.length > 0 ? app.windows[0].uniqueId : pinnedAppId + "_pinned")
                            })
                            
                            if (matchedKey) {
                                pinnedAppMap[matchedKey] = true
                            }
                        })
                        
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
                        
                        unpinnedRunningApps.forEach(appId => {
                            if (pinnedAppMap[appId]) return
                            
                            const app = groupedApps[appId]
                            if (!app) return
                            
                            const isGrouped = app.windows.length > 1
                            
                            items.push({
                                "type": isGrouped ? "grouped" : "window",
                                "appId": app.actualAppId || appId || "",
                                "windowId": isGrouped ? -1 : (app.windows && app.windows[0] ? app.windows[0].index : -1),
                                "windowTitle": isGrouped ? "" : (app.windows && app.windows[0] ? app.windows[0].truncatedTitle : ""),
                                "workspaceId": -1,
                                "isPinned": false,
                                "isRunning": true,
                                "isFocused": false,
                                "isGrouped": !!isGrouped,
                                "windowCount": app.windows ? app.windows.length : 0,
                                "windows": app.windows || [],
                                "uniqueId": isGrouped ? (app.actualAppId || appId) + "_group" : (app.windows && app.windows[0] ? app.windows[0].uniqueId : (app.actualAppId || appId) + "_window")
                            })
                        })
                        
                        root.pinnedAppCount = pinnedApps.length
                    } else {
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

                Rectangle {
                    anchors.fill: parent
                    radius: Theme.cornerRadius
                    color: Qt.rgba(0, 1, 0, 0.2) // Green background
                    border.width: 3
                    border.color: "#00ff00" // Bright green border
                    visible: isDropTarget
                    z: 5
                    
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -3
                        radius: parent.radius + 3
                        color: "transparent"
                        border.width: 2
                        border.color: Qt.rgba(0, 1, 0, 0.6)
                    }
                    
                    SequentialAnimation on opacity {
                        running: isDropTarget
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.6; duration: 500; easing.type: Easing.InOutQuad }
                        NumberAnimation { to: 1.0; duration: 500; easing.type: Easing.InOutQuad }
                    }
                    
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

                    showWindowTitle: model.type === "window"
                    windowTitle: model.windowTitle || ""
                }
                
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
