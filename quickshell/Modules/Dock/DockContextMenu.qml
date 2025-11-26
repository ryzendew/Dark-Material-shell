import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Hyprland
import qs.Common
import qs.Services
import qs.Widgets

PanelWindow {
    id: root

    WlrLayershell.namespace: "quickshell:dock:blur"

    property bool showContextMenu: false
    property var appData: null
    property var anchorItem: null
    property real dockVisibleHeight: 40
    property int margin: 10
    property bool workspaceOptionsVisible: false

    function showForButton(button, data, dockHeight) {
        if (showContextMenu && anchorItem === button) {
            close()
            return
        }

        anchorItem = button
        appData = data
        dockVisibleHeight = dockHeight || 40
        root.workspaceOptionsVisible = false // Reset workspace options visibility

        const dockWindow = button.Window.window
        if (dockWindow) {
            for (var i = 0; i < Quickshell.screens.length; i++) {
                const s = Quickshell.screens[i]
                if (dockWindow.x >= s.x && dockWindow.x < s.x + s.width) {
                    root.screen = s
                    break
                }
            }
        }

        showContextMenu = true
    }
    function close() {
        showContextMenu = false
    }

    function getToplevelObject() {
        
        if (!appData || (appData.type !== "window" && appData.type !== "pinned")) {
            return null
        }
        
        if (appData.type === "pinned" && appData.windows && appData.windows.length > 0) {
            for (var i = 0; i < appData.windows.length; i++) {
                if (appData.windows[i].toplevel && appData.windows[i].toplevel.activated) {
                    return appData.windows[i].toplevel
                }
            }
            return appData.windows[0].toplevel
        }
        
        const sortedToplevels = CompositorService.sortedToplevels
        
        if (!sortedToplevels) {
            return null
        }
        if (appData.windowId !== undefined && appData.windowId !== null && appData.windowId >= 0) {
            if (appData.windowId < sortedToplevels.length) {
                return sortedToplevels[appData.windowId]
            } else {
            }
        }
        return null
    }

    screen: Quickshell.screens[0]

    visible: showContextMenu
    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    color: "transparent"
    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    property point anchorPos: Qt.point(screen.width / 2, screen.height - 100)

    onAnchorItemChanged: updatePosition()
    onVisibleChanged: {
        if (visible) {
            updatePosition()
        }
    }

    function updatePosition() {
        if (!anchorItem) {
            anchorPos = Qt.point(screen.width / 2, screen.height - 100)
            return
        }

        const dockWindow = anchorItem.Window.window
        if (!dockWindow) {
            anchorPos = Qt.point(screen.width / 2, screen.height - 100)
            return
        }

        const buttonPosInDock = anchorItem.mapToItem(dockWindow.contentItem, 0, 0)
        let actualDockHeight = root.dockVisibleHeight

        function findDockBackground(item) {
            if (item.objectName === "dockBackground") {
                return item
            }
            for (var i = 0; i < item.children.length; i++) {
                const found = findDockBackground(item.children[i])
                if (found) {
                    return found
                }
            }
            return null
        }

        const dockBackground = findDockBackground(dockWindow.contentItem)
        if (dockBackground) {
            actualDockHeight = dockBackground.height
        }

        const dockBottomMargin = 16
        const buttonScreenY = root.screen.height - actualDockHeight - dockBottomMargin - 20

        const dockContentWidth = dockWindow.width
        const screenWidth = root.screen.width
        const dockLeftMargin = Math.round((screenWidth - dockContentWidth) / 2)
        const buttonScreenX = dockLeftMargin + buttonPosInDock.x + anchorItem.width / 2

        anchorPos = Qt.point(buttonScreenX, buttonScreenY)
    }

    Rectangle {
        id: menuContainer

        width: Math.min(400, Math.max(200, menuColumn.implicitWidth + Theme.spacingS * 2))
        height: Math.max(60, menuColumn.implicitHeight + Theme.spacingS * 2)

        x: {
            const left = 10
            const right = root.width - width - 10
            const want = root.anchorPos.x - width / 2
            return Math.max(left, Math.min(right, want))
        }
        y: Math.max(10, root.anchorPos.y - height + 30)
        color: Theme.popupBackground()
        radius: Theme.cornerRadius
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
        border.width: 1
        opacity: showContextMenu ? 1 : 0
        scale: showContextMenu ? 1 : 0.85

        Rectangle {
            anchors.fill: parent
            anchors.topMargin: 4
            anchors.leftMargin: 2
            anchors.rightMargin: -2
            anchors.bottomMargin: -4
            radius: parent.radius
            color: Qt.rgba(0, 0, 0, 0.15)
            z: parent.z - 1
        }

        Column {
            id: menuColumn
            width: parent.width - Theme.spacingS * 2
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: Theme.spacingS
            spacing: 1

            Rectangle {
                width: parent.width
                height: 28
                radius: Theme.cornerRadius
                color: pinArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"

                StyledText {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.spacingS
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.spacingS
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.appData && root.appData.isPinned ? "Unpin from Dock" : "Pin to Dock"
                    font.pixelSize: Theme.fontSizeSmall
                    color: "white"
                    font.weight: Font.Normal
                    elide: Text.ElideRight
                    wrapMode: Text.NoWrap
                }

                MouseArea {
                    id: pinArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (!root.appData) {
                            return
                        }
                        if (root.appData.isPinned) {
                            SessionData.removePinnedApp(root.appData.appId)
                        } else {
                            SessionData.addPinnedApp(root.appData.appId)
                        }
                        root.close()
                    }
                }
            }

            Rectangle {
                visible: root.appData && root.appData.type === "window"
                width: parent.width
                height: 1
                color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
            }

            Repeater {
                visible: root.appData && ((root.appData.type === "grouped" && root.appData.windows && root.appData.windows.length > 0) || 
                                         (root.appData.type === "pinned" && root.appData.isRunning && root.appData.windows && root.appData.windows.length > 1))
                model: root.appData && root.appData.windows && root.appData.windows.length > 0 ? root.appData.windows : []
                
                Rectangle {
                    width: parent.width
                    height: 28
                    radius: Theme.cornerRadius
                    color: windowArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"

                    StyledText {
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.spacingS
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.spacingS
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData ? modelData.truncatedTitle : ""
                        font.pixelSize: Theme.fontSizeSmall
                        color: "white"
                        font.weight: Font.Normal
                        elide: Text.ElideRight
                        wrapMode: Text.NoWrap
                    }

                    MouseArea {
                        id: windowArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (modelData && modelData.toplevel) {
                                modelData.toplevel.activate()
                            }
                            root.close()
                        }
                    }
                }
            }

            Rectangle {
                visible: root.appData && (root.appData.type === "window" || root.appData.type === "pinned")
                width: parent.width
                height: 1
                color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
            }

            Rectangle {
                visible: root.appData && (root.appData.type === "window" || root.appData.type === "pinned")
                width: parent.width
                height: 28
                radius: Theme.cornerRadius
                color: newWindowArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"

                StyledText {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.spacingS
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.spacingS
                    anchors.verticalCenter: parent.verticalCenter
                    text: "New Window"
                    font.pixelSize: Theme.fontSizeSmall
                    color: "white"
                    font.weight: Font.Normal
                    elide: Text.ElideRight
                    wrapMode: Text.NoWrap
                }

                MouseArea {
                    id: newWindowArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.appData && root.appData.appId) {
                            const desktopEntry = DesktopEntries.heuristicLookup(root.appData.appId)
                            if (desktopEntry) {
                                AppUsageHistoryData.addAppUsage({
                                    "id": root.appData.appId,
                                    "name": desktopEntry.name || root.appData.appId,
                                    "icon": desktopEntry.icon || "",
                                    "exec": desktopEntry.exec || "",
                                    "comment": desktopEntry.comment || ""
                                })
                                SessionService.launchDesktopEntry(desktopEntry)
                            }
                        }
                        root.close()
                    }
                }
            }

            Rectangle {
                visible: root.appData && (root.appData.type === "window" || root.appData.type === "pinned")
                width: parent.width
                height: 1
                color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
            }

            Rectangle {
                visible: root.appData && (root.appData.type === "window" || root.appData.type === "pinned")
                width: parent.width
                height: 28
                radius: Theme.cornerRadius
                color: workspaceToggleArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"

                StyledText {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.spacingS
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.spacingS
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Move to Workspace"
                    font.pixelSize: Theme.fontSizeSmall
                    color: "white"
                    font.weight: Font.Normal
                    elide: Text.ElideRight
                    wrapMode: Text.NoWrap
                }

                MouseArea {
                    id: workspaceToggleArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.workspaceOptionsVisible = !root.workspaceOptionsVisible
                    }
                }
            }

            Repeater {
                visible: root.appData && (root.appData.type === "window" || root.appData.type === "pinned") && root.workspaceOptionsVisible
                model: SettingsData.maxWorkspaces
                
                Rectangle {
                    width: parent.width
                    height: 24
                    radius: Theme.cornerRadius
                    color: workspaceItemArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"

                    StyledText {
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.spacingS
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.spacingS
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Workspace " + (index + 1)
                        font.pixelSize: Theme.fontSizeSmall
                        color: "white"
                        font.weight: Font.Normal
                        elide: Text.ElideRight
                        wrapMode: Text.NoWrap
                    }

                    MouseArea {
                        id: workspaceItemArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            
                            if (root.appData) {
                                const toplevel = root.getToplevelObject()
                                
                                if (toplevel) {
                                    const workspaceId = index + 1
                                    
                                    if (CompositorService.isHyprland) {
                                        const hyprlandToplevels = Array.from(Hyprland.toplevels?.values || [])
                                        
                                        const hyprToplevel = hyprlandToplevels.find(ht => ht.wayland === toplevel)
                                        
                                        if (hyprToplevel) {
                                            const windowAddress = hyprToplevel.address || hyprToplevel.id
                                            
                                            if (windowAddress) {
                                                const formattedAddress = windowAddress.toString().startsWith('0x') ? windowAddress : `0x${windowAddress}`
                                                const command = `movetoworkspace ${workspaceId},address:${formattedAddress}`
                                                Hyprland.dispatch(command)
                                            } else {
                                            }
                                        } else {
                                        }
                                    } else if (CompositorService.isNiri) {
                                        toplevel.workspace = workspaceId
                                    } else {
                                    }
                                } else {
                                }
                            } else {
                            }
                            root.close()
                        }
                    }
                }
            }

            Rectangle {
                visible: root.appData && (root.appData.type === "window" || root.appData.type === "pinned")
                width: parent.width
                height: 1
                color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
            }

            Rectangle {
                visible: root.appData && (root.appData.type === "window" || root.appData.type === "pinned")
                width: parent.width
                height: 28
                radius: Theme.cornerRadius
                color: minimizeArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"

                StyledText {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.spacingS
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.spacingS
                    anchors.verticalCenter: parent.verticalCenter
                    text: {
                        if (!root.appData) return "Minimize Window"
                        const toplevel = getToplevelObject()
                        if (!toplevel) return "Minimize Window"
                        return "Minimize Window"
                    }
                    font.pixelSize: Theme.fontSizeSmall
                    color: "white"
                    font.weight: Font.Normal
                    elide: Text.ElideRight
                    wrapMode: Text.NoWrap
                }

                MouseArea {
                    id: minimizeArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.appData) {
                            const toplevel = getToplevelObject()
                            if (toplevel) {
                            }
                        }
                        root.close()
                    }
                }

                function getToplevelObject() {
                    if (!root.appData || (root.appData.type !== "window" && root.appData.type !== "pinned")) {
                        return null
                    }
                    
                    if (root.appData.type === "pinned" && root.appData.windows && root.appData.windows.length > 0) {
                        for (var i = 0; i < root.appData.windows.length; i++) {
                            if (root.appData.windows[i].toplevel && root.appData.windows[i].toplevel.activated) {
                                return root.appData.windows[i].toplevel
                            }
                        }
                        return root.appData.windows[0].toplevel
                    }
                    
                    const sortedToplevels = CompositorService.sortedToplevels
                    if (!sortedToplevels) {
                        return null
                    }
                    if (root.appData.windowId !== undefined && root.appData.windowId !== null && root.appData.windowId >= 0) {
                        if (root.appData.windowId < sortedToplevels.length) {
                            return sortedToplevels[root.appData.windowId]
                        }
                    }
                    return null
                }
            }

            Rectangle {
                visible: root.appData && (root.appData.type === "window" || root.appData.type === "pinned")
                width: parent.width
                height: 1
                color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
            }

            Rectangle {
                visible: root.appData && (root.appData.type === "window" || root.appData.type === "pinned")
                width: parent.width
                height: 28
                radius: Theme.cornerRadius
                color: closeArea.containsMouse ? Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.12) : "transparent"

                StyledText {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.spacingS
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.spacingS
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Close Window"
                    font.pixelSize: Theme.fontSizeSmall
                    color: "white"
                    font.weight: Font.Normal
                    elide: Text.ElideRight
                    wrapMode: Text.NoWrap
                }

                MouseArea {
                    id: closeArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.appData) {
                            const toplevel = getToplevelObject()
                            if (toplevel) {
                                toplevel.close()
                            }
                        }
                        root.close()
                    }
                    
                    function getToplevelObject() {
                        if (!root.appData || (root.appData.type !== "window" && root.appData.type !== "pinned")) {
                            return null
                        }
                        
                        if (root.appData.type === "pinned" && root.appData.windows && root.appData.windows.length > 0) {
                            for (var i = 0; i < root.appData.windows.length; i++) {
                                if (root.appData.windows[i].toplevel && root.appData.windows[i].toplevel.activated) {
                                    return root.appData.windows[i].toplevel
                                }
                            }
                            return root.appData.windows[0].toplevel
                        }
                        
                        const sortedToplevels = CompositorService.sortedToplevels
                        if (!sortedToplevels) {
                            return null
                        }
                        if (root.appData.windowId !== undefined && root.appData.windowId !== null && root.appData.windowId >= 0) {
                            if (root.appData.windowId < sortedToplevels.length) {
                                return sortedToplevels[root.appData.windowId]
                            }
                        }
                        return null
                    }
                }
            }

            Rectangle {
                visible: root.appData && ((root.appData.type === "grouped" && root.appData.windows && root.appData.windows.length > 1) ||
                                         (root.appData.type === "pinned" && root.appData.isRunning && root.appData.windows && root.appData.windows.length > 1))
                width: parent.width
                height: 28
                radius: Theme.cornerRadius
                color: minimizeAllArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"

                StyledText {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.spacingS
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.spacingS
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Minimize All Windows"
                    font.pixelSize: Theme.fontSizeSmall
                    color: "white"
                    font.weight: Font.Normal
                    elide: Text.ElideRight
                    wrapMode: Text.NoWrap
                }

                MouseArea {
                    id: minimizeAllArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.appData && root.appData.windows) {
                            for (var i = 0; i < root.appData.windows.length; i++) {
                                if (root.appData.windows[i].toplevel) {
                                }
                            }
                        }
                        root.close()
                    }
                }
            }

            Rectangle {
                visible: root.appData && ((root.appData.type === "grouped" && root.appData.windows && root.appData.windows.length > 1) ||
                                         (root.appData.type === "pinned" && root.appData.isRunning && root.appData.windows && root.appData.windows.length > 1))
                width: parent.width
                height: 28
                radius: Theme.cornerRadius
                color: closeAllArea.containsMouse ? Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.12) : "transparent"

                StyledText {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.spacingS
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.spacingS
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Close All Windows"
                    font.pixelSize: Theme.fontSizeSmall
                    color: "white"
                    font.weight: Font.Normal
                    elide: Text.ElideRight
                    wrapMode: Text.NoWrap
                }

                MouseArea {
                    id: closeAllArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.appData && root.appData.windows) {
                            for (var i = 0; i < root.appData.windows.length; i++) {
                                if (root.appData.windows[i].toplevel) {
                                    root.appData.windows[i].toplevel.close()
                                }
                            }
                        }
                        root.close()
                    }
                }
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.mediumDuration
                easing.type: Theme.emphasizedEasing
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: Theme.mediumDuration
                easing.type: Theme.emphasizedEasing
            }
        }
    }


    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: {
            root.close()
        }
    }
}
