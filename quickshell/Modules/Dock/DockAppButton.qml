import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: root

    clip: false
    property var appData
    property var contextMenu: null
    property var dockApps: null
    property int index: -1
    property bool longPressing: false
    property bool dragging: false
    property point dragStartPos: Qt.point(0, 0)
    property point dragOffset: Qt.point(0, 0)
    property int targetIndex: -1
    property int originalIndex: -1
    property bool showWindowTitle: false
    property string windowTitle: ""
    property bool isHovered: mouseArea.containsMouse && !dragging
    property bool showTooltip: mouseArea.containsMouse && !dragging
    property bool isMinimized: false
    property bool isWindowFocused: {
        if (!appData || appData.type !== "window") {
            return false
        }
        const toplevel = getToplevelObject()
        if (!toplevel) {
            return false
        }
        return toplevel.activated
    }
    property string tooltipText: {
        if (!appData) {
            return ""
        }

        if (appData.type === "window" && showWindowTitle) {
            const desktopEntry = DesktopEntries.heuristicLookup(appData.appId)
            const appName = desktopEntry && desktopEntry.name ? desktopEntry.name : appData.appId
            return appName + (windowTitle ? " • " + windowTitle : "")
        }

        if (appData.type === "grouped") {
            const desktopEntry = DesktopEntries.heuristicLookup(appData.appId)
            const appName = desktopEntry && desktopEntry.name ? desktopEntry.name : appData.appId
            return appName + " (" + appData.windowCount + " windows)"
        }

        if (appData.type === "pinned" && appData.isRunning && appData.windowCount > 1) {
            const desktopEntry = DesktopEntries.heuristicLookup(appData.appId)
            const appName = desktopEntry && desktopEntry.name ? desktopEntry.name : appData.appId
            return appName + " (" + appData.windowCount + " windows)"
        }

        if (!appData.appId) {
            return ""
        }

        const desktopEntry = DesktopEntries.heuristicLookup(appData.appId)
        return desktopEntry && desktopEntry.name ? desktopEntry.name : appData.appId
    }

    width: SettingsData.dockIconSize
    height: SettingsData.dockIconSize

    function getToplevelObject() {
        if (!appData || (appData.type !== "window" && appData.type !== "grouped" && appData.type !== "pinned")) {
            return null
        }

        if (appData.type === "grouped") {
            // For grouped apps, return the first window or the focused one
            if (appData.windows && appData.windows.length > 0) {
                // Try to find a focused window first
                for (var i = 0; i < appData.windows.length; i++) {
                    if (appData.windows[i].toplevel && appData.windows[i].toplevel.activated) {
                        return appData.windows[i].toplevel
                    }
                }
                // If no focused window, return the first one
                return appData.windows[0].toplevel
            }
            return null
        }

        if (appData.type === "pinned" && appData.windows && appData.windows.length > 0) {
            // Pinned app with running windows - return the focused or first window
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

        if (appData.uniqueId) {
            for (var i = 0; i < sortedToplevels.length; i++) {
                const toplevel = sortedToplevels[i]
                const checkId = toplevel.title + "|" + (toplevel.appId || "") + "|" + i
                if (checkId === appData.uniqueId) {
                    return toplevel
                }
            }
        }

        if (appData.windowId !== undefined && appData.windowId !== null && appData.windowId >= 0) {
            if (appData.windowId < sortedToplevels.length) {
                return sortedToplevels[appData.windowId]
            }
        }

        return null
    }

    onIsHoveredChanged: {
        if (isHovered) {
            exitAnimation.stop()
            if (!bounceAnimation.running)
                bounceAnimation.restart()
        } else {
            bounceAnimation.stop()
            exitAnimation.restart()
        }
    }

    SequentialAnimation {
        id: bounceAnimation

        running: false

        NumberAnimation {
            target: translateY
            property: "y"
            to: -10
            duration: Anims.durShort
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Anims.emphasizedAccel
        }

        NumberAnimation {
            target: translateY
            property: "y"
            to: -8
            duration: Anims.durShort
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Anims.emphasizedDecel
        }
    }

    NumberAnimation {
        id: exitAnimation

        running: false
        target: translateY
        property: "y"
        to: 0
        duration: Anims.durShort
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Anims.emphasizedDecel
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.cornerRadius
        color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3)
        border.width: 2
        border.color: Theme.primary
        visible: dragging
        z: -1
    }

    // Enhanced drag visual feedback
    Rectangle {
        id: dragIndicator
        anchors.fill: parent
        radius: Theme.cornerRadius
        color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.15)
        border.width: 3
        border.color: Theme.primary
        visible: dragging
        z: 10
        
        // Glow effect
        Rectangle {
            anchors.fill: parent
            anchors.margins: -3
            radius: parent.radius + 3
            color: "transparent"
            border.width: 2
            border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.4)
        }
        
        // Scale animation
        scale: dragging ? 1.15 : 1.0
        Behavior on scale {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
        
        // Opacity animation
        opacity: dragging ? 0.85 : 1.0
        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
        
        // Pulsing animation for the dragged item
        SequentialAnimation on opacity {
            running: dragging
            loops: Animation.Infinite
            NumberAnimation { to: 0.6; duration: 800; easing.type: Easing.InOutQuad }
            NumberAnimation { to: 0.85; duration: 800; easing.type: Easing.InOutQuad }
        }
    }

    Timer {
        id: longPressTimer

        interval: 500
        repeat: false
        onTriggered: {
            if (appData && appData.isPinned) {
                longPressing = true
                // console.log("Long press triggered for pinned app")
            }
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        anchors.bottomMargin: -20
        hoverEnabled: true
        cursorShape: longPressing ? Qt.DragMoveCursor : Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onPressed: mouse => {
                       if (mouse.button === Qt.LeftButton && appData && appData.isPinned) {
                           dragStartPos = Qt.point(mouse.x, mouse.y)
                           longPressTimer.start()
                       }
                   }
        onReleased: mouse => {
                        longPressTimer.stop()
                        if (longPressing) {
                            if (dragging && targetIndex >= 0 && targetIndex !== originalIndex && dockApps) {
                                dockApps.movePinnedApp(originalIndex, targetIndex)
                            }

                            longPressing = false
                            dragging = false
                            dragOffset = Qt.point(0, 0)
                            targetIndex = -1
                            originalIndex = -1
                        }
                    }
        onPositionChanged: mouse => {
                               if (longPressing && !dragging) {
                                   const distance = Math.sqrt(Math.pow(mouse.x - dragStartPos.x, 2) + Math.pow(mouse.y - dragStartPos.y, 2))
                                   if (distance > 5) {
                                       dragging = true
                                       targetIndex = index
                                       originalIndex = index
                                       // console.log("Started dragging, index:", index, "targetIndex:", targetIndex)
                                   }
                               }
                               if (dragging) {
                                   dragOffset = Qt.point(mouse.x - dragStartPos.x, mouse.y - dragStartPos.y)
                                   if (dockApps) {
                                       const threshold = SettingsData.dockIconSize * 0.6
                                       let newTargetIndex = targetIndex
                                       
                                       // Calculate new target based on drag direction
                                       if (dragOffset.x > threshold && targetIndex < dockApps.pinnedAppCount - 1) {
                                           newTargetIndex = targetIndex + 1
                                       } else if (dragOffset.x < -threshold && targetIndex > 0) {
                                           newTargetIndex = targetIndex - 1
                                       }
                                       
                                       if (newTargetIndex !== targetIndex) {
                                           targetIndex = newTargetIndex
                                           dragStartPos = Qt.point(mouse.x, mouse.y)
                                           // console.log("Target index changed to:", targetIndex, "dragOffset.x:", dragOffset.x)
                                       }
                                   }
                               }
                           }
        onClicked: mouse => {
                       if (!appData || longPressing) {
                           return
                       }

                       if (mouse.button === Qt.LeftButton) {
                           if (appData.type === "pinned") {
                               if (appData.isRunning && appData.windows && appData.windows.length > 0) {
                                   // Pinned app with running windows - activate the focused or first window
                                   const toplevel = getToplevelObject()
                                   if (toplevel) {
                                       toplevel.activate()
                                   }
                               } else {
                                   // Pinned app without running windows - launch new instance
                                   if (appData && appData.appId) {
                                       const desktopEntry = DesktopEntries.heuristicLookup(appData.appId)
                                       if (desktopEntry) {
                                           AppUsageHistoryData.addAppUsage({
                                                                               "id": appData.appId,
                                                                               "name": desktopEntry.name || appData.appId,
                                                                               "icon": desktopEntry.icon || "",
                                                                               "exec": desktopEntry.exec || "",
                                                                               "comment": desktopEntry.comment || ""
                                                                           })
                                       }
                                       SessionService.launchDesktopEntry(desktopEntry)
                                   }
                               }
                           } else if (appData.type === "window") {
                               const toplevel = getToplevelObject()
                               if (toplevel) {
                                   toplevel.activate()
                               }
                           } else if (appData.type === "grouped") {
                               // For grouped apps, cycle through windows or activate the focused one
                               const toplevel = getToplevelObject()
                               if (toplevel) {
                                   toplevel.activate()
                               }
                           }
                       } else if (mouse.button === Qt.MiddleButton) {
                           if (appData && appData.appId) {
                               const desktopEntry = DesktopEntries.heuristicLookup(appData.appId)
                               if (desktopEntry) {
                                   AppUsageHistoryData.addAppUsage({
                                                                       "id": appData.appId,
                                                                       "name": desktopEntry.name || appData.appId,
                                                                       "icon": desktopEntry.icon || "",
                                                                       "exec": desktopEntry.exec || "",
                                                                       "comment": desktopEntry.comment || ""
                                                                   })
                               }
                             SessionService.launchDesktopEntry(desktopEntry)
                           }
                       } else if (mouse.button === Qt.RightButton) {
                           if (contextMenu) {
                               contextMenu.showForButton(root, appData, 40)
                           }
                       } else if (mouse.button === Qt.MiddleButton) {
                           // Middle click to minimize/restore
                           if (appData.type === "window" || appData.type === "grouped") {
                               const toplevel = getToplevelObject()
                               if (toplevel) {
                                   toplevel.activate()
                               }
                           }
                       }
                   }
    }

    Image {
        id: iconImg

        anchors.centerIn: parent
        width: SettingsData.dockIconSize
        height: SettingsData.dockIconSize
        sourceSize.width: SettingsData.dockIconSize
        sourceSize.height: SettingsData.dockIconSize
        fillMode: Image.PreserveAspectFit
        source: {
            if (appData.appId === "__SEPARATOR__") {
                return ""
            }
            const moddedId = Paths.moddedAppId(appData.appId)
            if (moddedId.toLowerCase().includes("steam_app")) {
                return ""
            }
            const desktopEntry = DesktopEntries.heuristicLookup(moddedId)
            return desktopEntry && desktopEntry.icon ? Quickshell.iconPath(desktopEntry.icon, true) : ""
        }
        mipmap: true
        smooth: true
        asynchronous: true
        visible: status === Image.Ready

        // Drop shadow
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 2
            radius: 8
            samples: 16
            color: Qt.rgba(0, 0, 0, SettingsData.dockIconDropShadowOpacity)
            transparentBorder: true
        }
    }

    DankIcon {
        anchors.centerIn: parent
        size: SettingsData.dockIconSize
        name: "sports_esports"
        color: Theme.surfaceText
        visible: {
            if (!appData || !appData.appId || appData.appId === "__SEPARATOR__") {
                return false
            }
            const moddedId = Paths.moddedAppId(appData.appId)
            return moddedId.toLowerCase().includes("steam_app")
        }

        // Drop shadow
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 2
            radius: 8
            samples: 16
            color: Qt.rgba(0, 0, 0, SettingsData.dockIconDropShadowOpacity)
            transparentBorder: true
        }
    }

    Rectangle {
        width: SettingsData.dockIconSize
        height: SettingsData.dockIconSize
        anchors.centerIn: parent
        visible: iconImg.status !== Image.Ready
        color: Theme.surfaceLight
        radius: Theme.cornerRadius
        border.width: 1
        border.color: Theme.primarySelected

        Text {
            anchors.centerIn: parent
            text: {
                if (!appData || !appData.appId) {
                    return "?"
                }

                const desktopEntry = DesktopEntries.heuristicLookup(appData.appId)
                if (desktopEntry && desktopEntry.name) {
                    return desktopEntry.name.charAt(0).toUpperCase()
                }

                return appData.appId.charAt(0).toUpperCase()
            }
            font.pixelSize: 14
            color: Theme.primary
            font.weight: Font.Bold
        }
    }

    // Indicator for running/focused/minimized state
    Rectangle {
        anchors.horizontalCenter: iconImg.horizontalCenter
        anchors.top: iconImg.bottom
        anchors.topMargin: 2
        width: 6
        height: 6
        radius: 3
        visible: appData && (appData.isRunning || appData.type === "window")
        color: {
            if (!appData) {
                return "transparent"
            }

            if (isMinimized) {
                return Qt.rgba(1, 0.5, 0, 0.8) // Orange for minimized
            }

            if (isWindowFocused) {
                return Theme.primary
            }

            if (appData.isRunning || appData.type === "window") {
                return Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.6)
            }

            return "transparent"
        }
    }

    // Window count indicator for grouped apps and pinned apps with multiple windows
    Rectangle {
        visible: false // Disabled number badge
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: -4
        anchors.rightMargin: -4
        width: Math.max(16, countText.implicitWidth + 8)
        height: 16
        radius: 8
        color: Theme.primary
        border.width: 1
        border.color: Theme.surfaceContainer

        StyledText {
            id: countText
            anchors.centerIn: parent
            text: appData ? appData.windowCount.toString() : ""
            font.pixelSize: 10
            font.weight: Font.Bold
            color: Theme.onPrimary
        }
    }

    transform: Translate {
        id: translateY

        y: 0
    }
}
