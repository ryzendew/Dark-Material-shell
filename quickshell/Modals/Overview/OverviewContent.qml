import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Modals.Overview
import qs.Services
import qs.Widgets

Item {
    id: root
    
    property var parentModal: null
    property string screenName: ""
    
    anchors.fill: parent
    
    // Get windows for this screen (reactive) - but include global index
    property var screenWindows: {
        if (!screenName) {
            return []
        }
        
        // Get all windows globally first (for numbering)
        const allWindowsGlobal = OverviewService.getAllWindowsFlat()
        const allWindows = OverviewService.getAllWindowsByScreen()
        const allKeys = Object.keys(allWindows)
        
        // Try exact match first
        let windows = allWindows[screenName] || []
        
        // If no match, try case-insensitive matching
        if (windows.length === 0) {
            const screenLower = screenName.toLowerCase()
            const matchingKey = allKeys.find(key => {
                return key.toLowerCase() === screenLower
            })
            if (matchingKey) {
                windows = allWindows[matchingKey] || []
            }
        }
        
        // If still no match, try partial matching
        if (windows.length === 0) {
            const matchingKey = allKeys.find(key => {
                const keyLower = key.toLowerCase()
                const screenLower = screenName.toLowerCase()
                return keyLower.includes(screenLower) || screenLower.includes(keyLower) ||
                       key === screenName || screenName === key
            })
            if (matchingKey) {
                windows = allWindows[matchingKey] || []
            }
        }
        
        // Last resort: if screenName contains a monitor identifier
        if (windows.length === 0 && screenName.includes("-")) {
            const parts = screenName.split("-")
            if (parts.length >= 2) {
                const identifier = parts[parts.length - 1]
                const matchingKey = allKeys.find(key => {
                    return key.includes(identifier) || key.includes(screenName)
                })
                if (matchingKey) {
                    windows = allWindows[matchingKey] || []
                }
            }
        }
        
        // Add global index to each window
        const globalWindowMap = {}
        allWindowsGlobal.forEach((gw, idx) => {
            if (gw.toplevel) {
                globalWindowMap["toplevel:" + gw.toplevel] = gw
            }
            if (gw.address) {
                globalWindowMap["address:" + gw.address + ":" + gw.monitorName] = gw
            }
            if (gw.appId && gw.title) {
                globalWindowMap["app:" + gw.appId + ":" + gw.title + ":" + gw.monitorName] = gw
            }
        })
        
        return windows.map((window, localIndex) => {
            let globalWindow = null
            
            if (window.toplevel) {
                globalWindow = globalWindowMap["toplevel:" + window.toplevel]
            }
            
            if (!globalWindow && window.address) {
                globalWindow = globalWindowMap["address:" + window.address + ":" + window.monitorName]
            }
            
            if (!globalWindow && window.appId && window.title) {
                globalWindow = globalWindowMap["app:" + window.appId + ":" + window.title + ":" + window.monitorName]
            }
            
            if (!globalWindow) {
                globalWindow = allWindowsGlobal.find(gw => 
                    (gw.toplevel === window.toplevel) ||
                    (gw.address === window.address && gw.monitorName === window.monitorName) ||
                    (gw.appId === window.appId && gw.title === window.title && gw.monitorName === window.monitorName)
                )
            }
            
            let finalGlobalIndex = -1
            if (globalWindow) {
                finalGlobalIndex = globalWindow.globalIndex
            } else {
                let countBefore = 0
                const screenNames = Object.keys(OverviewService.getAllWindowsByScreen()).sort()
                for (let i = 0; i < screenNames.length; i++) {
                    if (screenNames[i] < window.monitorName) {
                        const prevScreenWindows = OverviewService.getAllWindowsByScreen()[screenNames[i]] || []
                        countBefore += prevScreenWindows.length
                    } else if (screenNames[i] === window.monitorName) {
                        const sameScreenWindows = OverviewService.getAllWindowsByScreen()[screenNames[i]] || []
                        for (let j = 0; j < sameScreenWindows.length; j++) {
                            if (sameScreenWindows[j].toplevel === window.toplevel) {
                                break
                            }
                            countBefore++
                        }
                        break
                    }
                }
                finalGlobalIndex = countBefore
            }
            
            return {
                toplevel: window.toplevel,
                appId: window.appId,
                title: window.title,
                address: window.address,
                isActive: window.isActive,
                workspaceId: window.workspaceId,
                monitorName: window.monitorName,
                index: window.index,
                globalIndex: finalGlobalIndex
            }
        })
    }
    
    // Get all windows globally (for number key handling)
    property var allWindowsGlobal: OverviewService.getAllWindowsFlat()
    
    // Top bar height
    readonly property real topBarHeight: Theme.barHeight || 40
    readonly property real topMargin: topBarHeight + Theme.spacingXL
    
    FocusScope {
        id: focusScope
        
        anchors.fill: parent
        focus: true
        
        Component.onCompleted: {
            Qt.callLater(() => {
                focusScope.forceActiveFocus()
            })
        }
        
        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Escape) {
                if (parentModal) {
                    parentModal.hide()
                }
                event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if (windowGrid.selectedIndex >= 0 && windowGrid.selectedIndex < screenWindows.length) {
                    const window = screenWindows[windowGrid.selectedIndex]
                    if (window) {
                        OverviewService.activateWindow(window)
                        if (parentModal) {
                            parentModal.hide()
                        }
                    }
                }
                event.accepted = true
            } else if (event.key === Qt.Key_Left) {
                if (windowGrid.selectedIndex > 0) {
                    windowGrid.selectedIndex--
                    windowGrid.ensureVisible(windowGrid.selectedIndex)
                }
                event.accepted = true
            } else if (event.key === Qt.Key_Right) {
                if (windowGrid.selectedIndex < windowGrid.count - 1) {
                    windowGrid.selectedIndex++
                    windowGrid.ensureVisible(windowGrid.selectedIndex)
                }
                event.accepted = true
            } else if (event.key === Qt.Key_Up) {
                const cols = Math.max(1, Math.floor(windowGrid.width / (windowCardWidth + windowGrid.spacing)))
                if (cols > 0 && windowGrid.selectedIndex - cols >= 0) {
                    windowGrid.selectedIndex -= cols
                }
                event.accepted = true
            } else if (event.key === Qt.Key_Down) {
                const cols = Math.max(1, Math.floor(windowGrid.width / (windowCardWidth + windowGrid.spacing)))
                if (cols > 0 && windowGrid.selectedIndex + cols < screenWindows.length) {
                    windowGrid.selectedIndex += cols
                }
                event.accepted = true
            } else if (event.key >= Qt.Key_1 && event.key <= Qt.Key_9) {
                const num = event.key - Qt.Key_1 + 1
                const allWindows = allWindowsGlobal
                if (num <= allWindows.length && allWindows.length > 0) {
                    const window = allWindows[num - 1]
                    if (window) {
                        OverviewService.activateWindow(window)
                        Quickshell.execDetached(["qs", "ipc", "call", "overview", "close"])
                    }
                }
                event.accepted = true
            } else if (event.key === Qt.Key_0) {
                const allWindows = allWindowsGlobal
                if (allWindows.length >= 10) {
                    const window = allWindows[9]
                    if (window) {
                        OverviewService.activateWindow(window)
                        Quickshell.execDetached(["qs", "ipc", "call", "overview", "close"])
                    }
                }
                event.accepted = true
            }
        }
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 0
            
            // Top search bar
            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: root.topMargin
                Layout.leftMargin: Theme.spacingXL
                Layout.rightMargin: Theme.spacingXL
                Layout.preferredHeight: 64
                radius: 32
                color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.95)
                border.width: 0
                
                Row {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.spacingXL
                    anchors.rightMargin: Theme.spacingXL
                    spacing: Theme.spacingM
                    
                    DarkIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        size: 24
                        name: "search"
                        color: Theme.surfaceText
                    }
                    
                    TextField {
                        id: searchInput
                        Layout.fillWidth: true
                        anchors.verticalCenter: parent.verticalCenter
                        placeholderText: "Search applications..."
                        font.pixelSize: Theme.fontSizeLarge
                        color: Theme.surfaceText
                        background: Rectangle { color: "transparent" }
                        selectByMouse: true
                    }
                    
                    DarkIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        size: 24
                        name: "close"
                        color: Theme.surfaceText
                        visible: searchInput.text.length > 0
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: searchInput.text = ""
                        }
                    }
                }
            }
            
            // Main content area
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: Theme.spacingXL
                Layout.leftMargin: Theme.spacingXL
                Layout.rightMargin: Theme.spacingXL
                Layout.bottomMargin: Theme.spacingXL
                spacing: Theme.spacingXL
                
                // Left sidebar - Workspaces
                Rectangle {
                    Layout.preferredWidth: 320
                    Layout.fillHeight: true
                    radius: Theme.cornerRadius * 1.5
                    color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.6)
                    border.width: 1
                    border.color: Theme.outlineMedium
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.spacingL
                        spacing: Theme.spacingM
                        
                        StyledText {
                            Layout.fillWidth: true
                            text: "Workspaces"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Bold
                            color: Theme.surfaceText
                        }
                        
                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            
                            Column {
                                width: parent.width
                                spacing: Theme.spacingM
                                
                                Repeater {
                                    model: 10
                                    
                                    Rectangle {
                                        width: parent.width
                                        height: 80
                                        radius: Theme.cornerRadius
                                        color: index === 0 ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.15) : 
                                              Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                                        border.width: index === 0 ? 2 : 1
                                        border.color: index === 0 ? Theme.primary : Theme.outlineMedium
                                        
                                        Row {
                                            anchors.fill: parent
                                            anchors.margins: Theme.spacingM
                                            spacing: Theme.spacingM
                                            
                                            Rectangle {
                                                width: 48
                                                height: 48
                                                radius: Theme.cornerRadius * 0.5
                                                color: index === 0 ? Theme.primary : Theme.surfaceContainer
                                                anchors.verticalCenter: parent.verticalCenter
                                                
                                                StyledText {
                                                    anchors.centerIn: parent
                                                    text: String(index + 1)
                                                    font.pixelSize: Theme.fontSizeLarge
                                                    font.weight: Font.Bold
                                                    color: index === 0 ? Theme.onPrimary : Theme.surfaceText
                                                }
                                            }
                                            
                                            Column {
                                                anchors.verticalCenter: parent.verticalCenter
                                                width: parent.width - 48 - Theme.spacingM
                                                
                                                StyledText {
                                                    width: parent.width
                                                    text: "Workspace " + String(index + 1)
                                                    font.pixelSize: Theme.fontSizeMedium
                                                    font.weight: index === 0 ? Font.Bold : Font.Normal
                                                    color: index === 0 ? Theme.primary : Theme.surfaceText
                                                    elide: Text.ElideRight
                                                }
                                                
                                                StyledText {
                                                    width: parent.width
                                                    text: {
                                                        const wsWindows = screenWindows.filter(w => w.workspaceId === (index + 1) || (!w.workspaceId && index === 0))
                                                        return String(wsWindows.length) + " windows"
                                                    }
                                                    font.pixelSize: Theme.fontSizeSmall
                                                    color: Theme.surfaceTextMedium
                                                }
                                            }
                                        }
                                        
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (CompositorService.isHyprland) {
                                                    Hyprland.dispatch("workspace", index + 1)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Center - Window grid
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: Theme.cornerRadius * 1.5
                    color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.7)
                    border.width: 2
                    border.color: Theme.primary
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.spacingL
                        spacing: Theme.spacingM
                        
                        StyledText {
                            Layout.fillWidth: true
                            text: "Windows"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Bold
                            color: Theme.primary
                        }
                        
                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            
                            GridView {
                                id: windowGrid
                                
                                property int selectedIndex: 0
                                readonly property real windowCardWidth: 280
                                readonly property real windowCardHeight: 200
                                
                                model: screenWindows
                                
                                function ensureVisible(index) {
                                    if (index >= 0 && index < count) {
                                        positionViewAtIndex(index, GridView.Contain)
                                    }
                                }
                                
                                cellWidth: windowCardWidth + Theme.spacingL
                                cellHeight: windowCardHeight + Theme.spacingL
                                
                                clip: true
                                
                                delegate: Rectangle {
                                    id: windowCard
                                    
                                    property bool isSelected: windowGrid.selectedIndex === index
                                    property var windowData: modelData
                                    
                                    width: windowGrid.windowCardWidth
                                    height: windowGrid.windowCardHeight
                                    radius: Theme.cornerRadius * 1.5
                                    color: isSelected ? Theme.primaryContainer : Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.85)
                                    border.width: isSelected ? 3 : 1
                                    border.color: isSelected ? Theme.primary : Theme.outlineMedium
                                    
                                    scale: mouseArea.containsMouse ? 1.03 : 1.0
                                    Behavior on scale {
                                        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                                    }
                                    
                                    Column {
                                        anchors.fill: parent
                                        anchors.margins: Theme.spacingM
                                        spacing: Theme.spacingS
                                        
                                        // Window preview area
                                        Rectangle {
                                            width: parent.width
                                            height: parent.height - 60
                                            radius: Theme.cornerRadius
                                            color: Theme.surfaceVariant
                                            clip: true
                                            
                                            // Window screenshot (if available)
                                            Image {
                                                id: windowScreenshot
                                                anchors.fill: parent
                                                fillMode: Image.PreserveAspectCrop
                                                source: {
                                                    if (!windowData) return ""
                                                    const screenshotPath = OverviewService.getWindowScreenshot(windowData)
                                                    return screenshotPath || ""
                                                }
                                                visible: status === Image.Ready && source !== ""
                                                asynchronous: true
                                                
                                                property int retryCount: 0
                                                Connections {
                                                    target: OverviewService
                                                    function onScreenshotsUpdated() {
                                                        if (windowData) {
                                                            const newPath = OverviewService.getWindowScreenshot(windowData)
                                                            if (newPath && newPath !== windowScreenshot.source) {
                                                                windowScreenshot.source = newPath
                                                            }
                                                        }
                                                    }
                                                    function onWindowsChanged() {
                                                        if (windowData) {
                                                            const newPath = OverviewService.getWindowScreenshot(windowData)
                                                            if (newPath && newPath !== windowScreenshot.source) {
                                                                windowScreenshot.source = newPath
                                                            }
                                                        }
                                                    }
                                                }
                                                Timer {
                                                    interval: 500
                                                    running: windowData && !windowScreenshot.source && windowScreenshot.retryCount < 10
                                                    repeat: true
                                                    onTriggered: {
                                                        windowScreenshot.retryCount++
                                                        const path = OverviewService.getWindowScreenshot(windowData)
                                                        if (path) {
                                                            windowScreenshot.source = path
                                                            stop()
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            // App icon as fallback
                                            Image {
                                                id: appIcon
                                                anchors.centerIn: parent
                                                width: 64
                                                height: 64
                                                fillMode: Image.PreserveAspectFit
                                                source: windowData ? OverviewService.getAppIcon(windowData.appId) : ""
                                                visible: (windowScreenshot.status !== Image.Ready || !windowScreenshot.source) && status === Image.Ready && source !== ""
                                            }
                                            
                                            DarkIcon {
                                                anchors.centerIn: parent
                                                size: 64
                                                name: "window"
                                                color: Theme.surfaceText
                                                visible: (windowScreenshot.status !== Image.Ready || !windowScreenshot.source) && 
                                                         (appIcon.status !== Image.Ready || appIcon.source === "")
                                            }
                                            
                                            // Number badge (1-10)
                                            Rectangle {
                                                anchors {
                                                    top: parent.top
                                                    right: parent.right
                                                    topMargin: Theme.spacingS
                                                    rightMargin: Theme.spacingS
                                                }
                                                width: 32
                                                height: 32
                                                radius: 16
                                                color: Theme.primary
                                                visible: {
                                                    if (!windowData) return false
                                                    const globalIndex = windowData.globalIndex
                                                    return globalIndex !== undefined && globalIndex >= 0 && globalIndex < 10
                                                }
                                                
                                                StyledText {
                                                    anchors.centerIn: parent
                                                    text: {
                                                        if (!windowData || windowData.globalIndex === undefined || windowData.globalIndex < 0) {
                                                            return ""
                                                        }
                                                        const globalNum = windowData.globalIndex + 1
                                                        return globalNum === 10 ? "0" : String(globalNum)
                                                    }
                                                    font.pixelSize: Theme.fontSizeMedium
                                                    font.weight: Font.Bold
                                                    color: Theme.onPrimary
                                                }
                                            }
                                            
                                            // Active indicator
                                            Rectangle {
                                                anchors {
                                                    left: parent.left
                                                    top: parent.top
                                                    bottom: parent.bottom
                                                }
                                                width: 4
                                                color: Theme.primary
                                                visible: windowData && windowData.isActive
                                            }
                                        }
                                        
                                        // Window title
                                        StyledText {
                                            width: parent.width
                                            text: windowData ? windowData.title : ""
                                            font.pixelSize: Theme.fontSizeSmall
                                            font.weight: (windowData && windowData.isActive) ? Font.Medium : Font.Normal
                                            color: isSelected ? Theme.onPrimaryContainer : Theme.surfaceText
                                            elide: Text.ElideRight
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                    }
                                    
                                    MouseArea {
                                        id: mouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        
                                        onClicked: {
                                            windowGrid.selectedIndex = index
                                            if (windowData) {
                                                OverviewService.activateWindow(windowData)
                                                if (parentModal) {
                                                    parentModal.hide()
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                // Empty state
                                Item {
                                    anchors.centerIn: parent
                                    width: 400
                                    height: 300
                                    visible: windowGrid.count === 0
                                    
                                    Column {
                                        anchors.centerIn: parent
                                        spacing: Theme.spacingL
                                        
                                        DarkIcon {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            size: 96
                                            name: "window"
                                            color: Theme.surfaceTextAlpha
                                        }
                                        
                                        StyledText {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: "No windows on this screen"
                                            font.pixelSize: Theme.fontSizeLarge
                                            color: Theme.surfaceTextMedium
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    Component.onCompleted: {
        if (windowGrid.count > 0) {
            windowGrid.selectedIndex = 0
        }
    }
    
    onScreenWindowsChanged: {
        if (windowGrid.count > 0 && windowGrid.selectedIndex >= windowGrid.count) {
            windowGrid.selectedIndex = 0
        }
    }
    
    Connections {
        target: OverviewService
        function onWindowsChanged() {
            const current = screenWindows
            screenWindows = []
            Qt.callLater(() => {
                const allWindows = OverviewService.getAllWindowsByScreen()
                let windows = allWindows[screenName] || []
                
                if (windows.length === 0) {
                    const matchingKey = Object.keys(allWindows).find(key => {
                        return key.includes(screenName) || screenName.includes(key)
                    })
                    if (matchingKey) {
                        windows = allWindows[matchingKey] || []
                    }
                }
                
                screenWindows = windows
                
                if (windowGrid.count > 0) {
                    windowGrid.selectedIndex = 0
                } else {
                    windowGrid.selectedIndex = -1
                }
            })
        }
    }
    
    onScreenNameChanged: {
        const current = screenWindows
        screenWindows = []
        Qt.callLater(() => {
            const allWindows = OverviewService.getAllWindowsByScreen()
            let windows = allWindows[screenName] || []
            
            if (windows.length === 0) {
                const matchingKey = Object.keys(allWindows).find(key => {
                    return key.includes(screenName) || screenName.includes(key)
                })
                if (matchingKey) {
                    windows = allWindows[matchingKey] || []
                }
            }
            
            screenWindows = windows
            if (windowGrid.count > 0) {
                windowGrid.selectedIndex = 0
            }
        })
    }
}
