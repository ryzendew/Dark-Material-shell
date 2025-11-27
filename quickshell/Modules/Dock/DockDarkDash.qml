import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import qs.Common
import qs.Widgets

Rectangle {
    id: root

    property real widgetHeight: 40
    property var parentScreen: null

    readonly property real horizontalPadding: Math.max(Theme.spacingXS, Theme.spacingS * (widgetHeight / 30))

    function getDarkDashLoader() {
        let current = root
        while (current) {
            if (current.darkDashLoader) {
                return current.darkDashLoader
            }
            current = current.parent
        }
        return null
    }

    function openDarkDash() {
        const loader = getDarkDashLoader()
        if (loader) {
            loader.active = true
            if (loader.item) {
                const dockWindow = root.Window.window
                if (!dockWindow) {
                    return
                }

                const currentScreen = parentScreen || Screen
                const screenWidth = currentScreen.width || 1920
                const screenHeight = currentScreen.height || 1080

                const buttonPosInDock = root.mapToItem(dockWindow.contentItem, 0, 0)
                
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
                const actualDockHeight = dockBackground ? dockBackground.height : 100

                const dockBottomMargin = 16
                const buttonScreenY = screenHeight - actualDockHeight - dockBottomMargin - 20

                const dockContentWidth = dockWindow.width
                const dockLeftMargin = Math.round((screenWidth - dockContentWidth) / 2)
                const buttonScreenX = dockLeftMargin + buttonPosInDock.x + root.width / 2

                loader.item.setTriggerPosition(buttonScreenX, buttonScreenY, root.width, "center", currentScreen)
                loader.item.show()
            }
        } else if (typeof darkDashLoader !== 'undefined') {
            darkDashLoader.active = true
            if (darkDashLoader.item) {
                const dockWindow = root.Window.window
                if (!dockWindow) {
                    return
                }

                const currentScreen = parentScreen || Screen
                const screenWidth = currentScreen.width || 1920
                const screenHeight = currentScreen.height || 1080

                const buttonPosInDock = root.mapToItem(dockWindow.contentItem, 0, 0)
                
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
                const actualDockHeight = dockBackground ? dockBackground.height : 100

                const dockBottomMargin = 16
                const buttonScreenY = screenHeight - actualDockHeight - dockBottomMargin - 20

                const dockContentWidth = dockWindow.width
                const dockLeftMargin = Math.round((screenWidth - dockContentWidth) / 2)
                const buttonScreenX = dockLeftMargin + buttonPosInDock.x + root.width / 2

                darkDashLoader.item.setTriggerPosition(buttonScreenX, buttonScreenY, root.width, "center", currentScreen)
                darkDashLoader.item.show()
            }
        }
    }

    function toggleDarkDash() {
        const loader = getDarkDashLoader()
        if (loader) {
            loader.active = true
            if (loader.item) {
                if (loader.item.shouldBeVisible) {
                    loader.item.close()
                } else {
                    const dockWindow = root.Window.window
                    if (!dockWindow) {
                        return
                    }

                    const currentScreen = parentScreen || Screen
                    const screenWidth = currentScreen.width || 1920
                    const screenHeight = currentScreen.height || 1080

                    const buttonPosInDock = root.mapToItem(dockWindow.contentItem, 0, 0)
                    
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
                    const actualDockHeight = dockBackground ? dockBackground.height : 100

                    const dockBottomMargin = 16
                    const buttonScreenY = screenHeight - actualDockHeight - dockBottomMargin - 20

                    const dockContentWidth = dockWindow.width
                    const dockLeftMargin = Math.round((screenWidth - dockContentWidth) / 2)
                    const buttonScreenX = dockLeftMargin + buttonPosInDock.x + root.width / 2

                    loader.item.setTriggerPosition(buttonScreenX, buttonScreenY, root.width, "center", currentScreen)
                    loader.item.show()
                }
            }
        } else if (typeof darkDashLoader !== 'undefined') {
            darkDashLoader.active = true
            if (darkDashLoader.item) {
                if (darkDashLoader.item.shouldBeVisible) {
                    darkDashLoader.item.close()
                } else {
                    const dockWindow = root.Window.window
                    if (!dockWindow) {
                        return
                    }

                    const currentScreen = parentScreen || Screen
                    const screenWidth = currentScreen.width || 1920
                    const screenHeight = currentScreen.height || 1080

                    const buttonPosInDock = root.mapToItem(dockWindow.contentItem, 0, 0)
                    
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
                    const actualDockHeight = dockBackground ? dockBackground.height : 100

                    const dockBottomMargin = 16
                    const buttonScreenY = screenHeight - actualDockHeight - dockBottomMargin - 20

                    const dockContentWidth = dockWindow.width
                    const dockLeftMargin = Math.round((screenWidth - dockContentWidth) / 2)
                    const buttonScreenX = dockLeftMargin + buttonPosInDock.x + root.width / 2

                    darkDashLoader.item.setTriggerPosition(buttonScreenX, buttonScreenY, root.width, "center", currentScreen)
                    darkDashLoader.item.show()
                }
            }
        }
    }

    width: dashIcon.implicitWidth + horizontalPadding * 2
    height: widgetHeight
    radius: Theme.cornerRadius
    color: {
        const baseColor = dashMouseArea.containsMouse ? Theme.widgetBaseHoverColor : Theme.widgetBaseBackgroundColor;
        return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, baseColor.a * Theme.widgetTransparency);
    }

    DarkIcon {
        id: dashIcon

        anchors.centerIn: parent
        name: "dashboard"
        size: Theme.iconSize - 6
        color: {
            const loader = root.getDarkDashLoader()
            const isVisible = loader && loader.item && loader.item.shouldBeVisible
            return isVisible ? Theme.primary : Theme.surfaceText
        }
    }

    MouseArea {
        id: dashMouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton
        onEntered: {
            hoverTimer.start()
        }
        onExited: {
            hoverTimer.stop()
        }
        onClicked: {
            hoverTimer.stop()
            root.toggleDarkDash()
        }
    }

    Timer {
        id: hoverTimer
        interval: 2000
        onTriggered: {
            root.openDarkDash()
        }
    }
}

