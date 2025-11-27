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

    function getApplicationsLoader() {
        let current = root
        while (current) {
            if (current.applicationsLoader) {
                return current.applicationsLoader
            }
            current = current.parent
        }
        return null
    }

    function openApplications() {
        const loader = getApplicationsLoader()
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
        } else if (typeof applicationsLoader !== 'undefined') {
            applicationsLoader.active = true
            if (applicationsLoader.item) {
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

                applicationsLoader.item.setTriggerPosition(buttonScreenX, buttonScreenY, root.width, "center", currentScreen)
                applicationsLoader.item.show()
            }
        }
    }

    function toggleApplications() {
        const loader = getApplicationsLoader()
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
        } else if (typeof applicationsLoader !== 'undefined') {
            applicationsLoader.active = true
            if (applicationsLoader.item) {
                if (applicationsLoader.item.shouldBeVisible) {
                    applicationsLoader.item.close()
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

                    applicationsLoader.item.setTriggerPosition(buttonScreenX, buttonScreenY, root.width, "center", currentScreen)
                    applicationsLoader.item.show()
                }
            }
        }
    }

    width: appsIcon.implicitWidth + horizontalPadding * 2
    height: widgetHeight
    radius: Theme.cornerRadius
    color: {
        const baseColor = appsMouseArea.containsMouse ? Theme.widgetBaseHoverColor : Theme.widgetBaseBackgroundColor;
        return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, baseColor.a * Theme.widgetTransparency);
    }

    DarkIcon {
        id: appsIcon

        anchors.centerIn: parent
        name: "apps"
        size: Theme.iconSize - 6
        color: {
            const loader = root.getApplicationsLoader()
            const isVisible = loader && loader.item && loader.item.shouldBeVisible
            return isVisible ? Theme.primary : Theme.surfaceText
        }
    }

    MouseArea {
        id: appsMouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton
        onClicked: {
            root.toggleApplications()
        }
    }
}







