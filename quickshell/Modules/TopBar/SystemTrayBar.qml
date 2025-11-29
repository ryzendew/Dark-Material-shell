import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Common
import qs.Widgets

Item {
    id: root

    property bool isVertical: axis?.isVertical ?? false
    readonly property bool isBarVertical: SettingsData.topBarPosition === "left" || SettingsData.topBarPosition === "right"
    property var axis: null
    property var parentWindow: null
    property var parentScreen: null
    property real widgetHeight: 30
    property real widgetThickness: 30
    property real barThickness: 48
    property bool isAtBottom: false
    readonly property real horizontalPadding: SettingsData.topBarNoBackground ? 2 : Theme.spacingS
    readonly property var hiddenTrayIds: {
        const envValue = Quickshell.env("DMS_HIDE_TRAYIDS") || ""
        return envValue ? envValue.split(",").map(id => id.trim().toLowerCase()) : []
    }
    readonly property var visibleTrayItems: {
        if (!hiddenTrayIds.length) {
            return SystemTray.items.values
        }
        return SystemTray.items.values.filter(item => {
            const itemId = item?.id || ""
            return !hiddenTrayIds.includes(itemId.toLowerCase())
        })
    }
    readonly property int calculatedSize: visibleTrayItems.length > 0 ? visibleTrayItems.length * 24 + horizontalPadding * 2 : 0
    readonly property real visualWidth: (isVertical || isBarVertical) ? widgetThickness : calculatedSize
    readonly property real visualHeight: (isVertical || isBarVertical) ? calculatedSize : widgetThickness

    width: (isVertical || isBarVertical) ? barThickness : visualWidth
    height: (isVertical || isBarVertical) ? visualHeight : (isAtBottom ? barThickness : widgetHeight)
    visible: visibleTrayItems.length > 0

    Rectangle {
        id: visualBackground
        width: root.visualWidth
        height: root.visualHeight
        anchors.centerIn: parent
    radius: SettingsData.topBarNoBackground ? 0 : Theme.cornerRadius
    color: {
            if (visibleTrayItems.length === 0) {
            return "transparent";
        }
        if (SettingsData.topBarNoBackground) {
            return "transparent";
        }
        const baseColor = Theme.widgetBaseBackgroundColor;
        return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, baseColor.a * Theme.widgetTransparency);
    }
    }

    Loader {
        id: layoutLoader
        anchors.centerIn: parent
        sourceComponent: (root.isVertical || root.isBarVertical) ? columnComp : rowComp
    }

    Component {
        id: rowComp
        Row {
        spacing: 0
        Repeater {
                model: root.visibleTrayItems
            delegate: Item {
                    id: delegateRoot
                property var trayItem: modelData
                property string iconSource: {
                    let icon = trayItem && trayItem.icon;
                    if (typeof icon === 'string' || icon instanceof String) {
                            if (icon === "") {
                                return "";
                            }
                        if (icon.includes("?path=")) {
                            const split = icon.split("?path=");
                            if (split.length !== 2) {
                                return icon;
                            }
                            const name = split[0];
                            const path = split[1];
                                let fileName = name.substring(name.lastIndexOf("/") + 1);
                                if (fileName.startsWith("dropboxstatus")) {
                                    fileName = `hicolor/16x16/status/${fileName}`;
                                }
                            return `file://${path}/${fileName}`;
                        }
                            if (icon.startsWith("/") && !icon.startsWith("file://")) {
                                return `file://${icon}`;
                        }
                        return icon;
                    }
                    return "";
                }

                width: 24
                    height: root.isAtBottom ? root.barThickness : root.widgetHeight

                Rectangle {
                        id: visualContent
                        width: 24
                        height: 24
                        anchors.centerIn: parent
                    radius: Theme.cornerRadius
                    color: trayItemArea.containsMouse ? Theme.primaryHover : "transparent"

                        Item {
                            anchors.centerIn: parent
                            width: 16
                            height: 16
                            layer.enabled: SettingsData.systemIconTinting
                            
                            IconImage {
                                anchors.centerIn: parent
                                width: 16
                                height: 16
                                source: delegateRoot.iconSource
                                asynchronous: true
                                smooth: true
                                mipmap: true
                            }
                            
                            layer.effect: MultiEffect {
                                colorization: SettingsData.systemIconTinting ? SettingsData.iconTintIntensity : 0
                                colorizationColor: Theme.primary
                            }
                        }
                    }

                    MouseArea {
                        id: trayItemArea
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: (mouse) => {
                            console.log("[Systray] Mouse clicked - button:", mouse.button === Qt.LeftButton ? "Left" : mouse.button === Qt.RightButton ? "Right" : "Other")
                            if (!delegateRoot.trayItem) {
                                console.log("[Systray] ERROR: trayItem is null!")
                                return;
                            }
                            console.log("[Systray] trayItem exists, id:", delegateRoot.trayItem.id || "unknown")
                            if (mouse.button === Qt.LeftButton && !delegateRoot.trayItem.onlyMenu) {
                                console.log("[Systray] Left click - activating tray item")
                                delegateRoot.trayItem.activate();
                                return;
                            }
                            if (mouse.button === Qt.RightButton) {
                                console.log("[Systray] Right click detected")
                                const hasMenu = delegateRoot.trayItem.menu || delegateRoot.trayItem.hasMenu
                                console.log("[Systray] Menu check - menu:", !!delegateRoot.trayItem.menu, "hasMenu:", !!delegateRoot.trayItem.hasMenu, "hasMenu (combined):", hasMenu)
                                if (delegateRoot.trayItem && hasMenu) {
                                    console.log("[Systray] Menu available, isAtBottom:", root.isAtBottom)
                                    if (root.isAtBottom) {
                                        console.log("[Systray] Using showForTrayItem (bottom bar)")
                                        root.showForTrayItem(delegateRoot.trayItem, visualContent, parentScreen, root.isAtBottom, root.isVertical, root.axis);
                                    } else {
                                        console.log("[Systray] Top bar - checking QsMenuAnchor path")
                                        if (delegateRoot.trayItem.menu && parentWindow) {
                                            console.log("[Systray] Using QsMenuAnchor path")
                                            const globalPos = visualContent.mapToGlobal(visualContent.width / 2, visualContent.height / 2);
                                            const currentScreen = parentScreen || Screen;
                                            const screenX = currentScreen.x || 0;
                                            const relativeX = globalPos.x - screenX;
                                            console.log("[Systray] Global pos:", globalPos, "screenX:", screenX, "relativeX:", relativeX)
                                            menuAnchor.menu = delegateRoot.trayItem.menu;
                                            menuAnchor.anchor.window = parentWindow;
                                            const barHeight = parentWindow ? parentWindow.effectiveBarHeight : 30;
                                            menuAnchor.anchor.rect = Qt.rect(relativeX, barHeight + SettingsData.topBarSpacing, parent.width, 1);
                                            console.log("[Systray] Opening QsMenuAnchor with rect:", menuAnchor.anchor.rect)
                                            menuAnchor.open();
                                            console.log("[Systray] QsMenuAnchor.open() called")
                                        } else if (delegateRoot.trayItem.hasMenu) {
                                            console.log("[Systray] Fallback to showForTrayItem (hasMenu but no menu object or no parentWindow)")
                                            console.log("[Systray] parentWindow:", !!parentWindow, "hasMenu:", delegateRoot.trayItem.hasMenu)
                                            root.showForTrayItem(delegateRoot.trayItem, visualContent, parentScreen, root.isAtBottom, root.isVertical, root.axis);
                                        } else {
                                            console.log("[Systray] ERROR: No menu path available!")
                                        }
                                    }
                                } else {
                                    console.log("[Systray] No menu available for this tray item")
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: columnComp
        Column {
            spacing: 0
            Repeater {
                model: root.visibleTrayItems
                delegate: Item {
                    id: delegateRoot
                    property var trayItem: modelData
                    property string iconSource: {
                        let icon = trayItem && trayItem.icon;
                        if (typeof icon === 'string' || icon instanceof String) {
                            if (icon === "") {
                                return "";
                            }
                            if (icon.includes("?path=")) {
                                const split = icon.split("?path=");
                                if (split.length !== 2) {
                                    return icon;
                                }
                                const name = split[0];
                                const path = split[1];
                                let fileName = name.substring(name.lastIndexOf("/") + 1);
                                if (fileName.startsWith("dropboxstatus")) {
                                    fileName = `hicolor/16x16/status/${fileName}`;
                                }
                                return `file://${path}/${fileName}`;
                            }
                            if (icon.startsWith("/") && !icon.startsWith("file://")) {
                                return `file://${icon}`;
                            }
                            return icon;
                        }
                        return "";
                    }

                    width: root.isAtBottom ? root.barThickness : root.widgetHeight
                    height: 24

                    Rectangle {
                        id: visualContent
                        width: 24
                        height: 24
                        anchors.centerIn: parent
                        radius: Theme.cornerRadius
                        color: trayItemArea.containsMouse ? Theme.primaryHover : "transparent"

                        Item {
                            anchors.centerIn: parent
                            width: 16
                            height: 16
                            layer.enabled: SettingsData.systemIconTinting
                            
                            IconImage {
                                anchors.centerIn: parent
                                width: 16
                                height: 16
                                source: delegateRoot.iconSource
                                asynchronous: true
                                smooth: true
                                mipmap: true
                            }
                            
                            layer.effect: MultiEffect {
                                colorization: SettingsData.systemIconTinting ? SettingsData.iconTintIntensity : 0
                                colorizationColor: Theme.primary
                            }
                        }
                    }

                MouseArea {
                    id: trayItemArea
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: (mouse) => {
                            console.log("[Systray-Column] Mouse clicked - button:", mouse.button === Qt.LeftButton ? "Left" : mouse.button === Qt.RightButton ? "Right" : "Other")
                            if (!delegateRoot.trayItem) {
                                console.log("[Systray-Column] ERROR: trayItem is null!")
                            return;
                        }
                            console.log("[Systray-Column] trayItem exists, id:", delegateRoot.trayItem.id || "unknown")
                            if (mouse.button === Qt.LeftButton && !delegateRoot.trayItem.onlyMenu) {
                                console.log("[Systray-Column] Left click - activating tray item")
                                delegateRoot.trayItem.activate();
                            return;
                        }
                            if (mouse.button === Qt.RightButton) {
                                console.log("[Systray-Column] Right click detected")
                                const hasMenu = delegateRoot.trayItem.menu || delegateRoot.trayItem.hasMenu
                                console.log("[Systray-Column] Menu check - menu:", !!delegateRoot.trayItem.menu, "hasMenu:", !!delegateRoot.trayItem.hasMenu, "hasMenu (combined):", hasMenu)
                                if (delegateRoot.trayItem && hasMenu) {
                                    console.log("[Systray-Column] Menu available, isAtBottom:", root.isAtBottom)
                                    if (root.isAtBottom) {
                                        console.log("[Systray-Column] Using showForTrayItem (bottom bar)")
                                        root.showForTrayItem(delegateRoot.trayItem, visualContent, parentScreen, root.isAtBottom, root.isVertical, root.axis);
                                    } else {
                                        console.log("[Systray-Column] Top bar - checking QsMenuAnchor path")
                                        if (delegateRoot.trayItem.menu && parentWindow) {
                                            console.log("[Systray-Column] Using QsMenuAnchor path")
                                            const globalPos = visualContent.mapToGlobal(visualContent.width / 2, visualContent.height / 2);
                                            const currentScreen = parentScreen || Screen;
                                            const screenX = currentScreen.x || 0;
                                            const relativeX = globalPos.x - screenX;
                                            console.log("[Systray-Column] Global pos:", globalPos, "screenX:", screenX, "relativeX:", relativeX)
                                            menuAnchor.menu = delegateRoot.trayItem.menu;
                                            menuAnchor.anchor.window = parentWindow;
                                            const barHeight = parentWindow ? parentWindow.effectiveBarHeight : 30;
                                            menuAnchor.anchor.rect = Qt.rect(relativeX, barHeight + SettingsData.topBarSpacing, parent.width, 1);
                                            console.log("[Systray-Column] Opening QsMenuAnchor with rect:", menuAnchor.anchor.rect)
                                            menuAnchor.open();
                                            console.log("[Systray-Column] QsMenuAnchor.open() called")
                                        } else if (delegateRoot.trayItem.hasMenu) {
                                            console.log("[Systray-Column] Fallback to showForTrayItem (hasMenu but no menu object or no parentWindow)")
                                            console.log("[Systray-Column] parentWindow:", !!parentWindow, "hasMenu:", delegateRoot.trayItem.hasMenu)
                                            root.showForTrayItem(delegateRoot.trayItem, visualContent, parentScreen, root.isAtBottom, root.isVertical, root.axis);
                                        } else {
                                            console.log("[Systray-Column] ERROR: No menu path available!")
                                        }
                                    }
                                } else {
                                    console.log("[Systray-Column] No menu available for this tray item")
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: trayMenuComponent
        Rectangle {
            id: menuRoot
            property var trayItem: null
            property var anchorItem: null
            property var parentScreen: null
            property bool isAtBottom: false
            property bool isVertical: false
            property var axis: null
            property bool showMenu: false
            property var menuHandle: null

            ListModel {
                id: entryStack
            }

            function topEntry() {
                return entryStack.count ? entryStack.get(entryStack.count - 1).handle : null
            }

            function showForTrayItem(item, anchor, screen, atBottom, vertical, axisObj) {
                console.log("[Systray-Menu] showForTrayItem called in menu component")
                console.log("[Systray-Menu] Parameters - item:", !!item, "anchor:", !!anchor, "screen:", !!screen, "atBottom:", atBottom, "vertical:", vertical)
                trayItem = item
                anchorItem = anchor
                parentScreen = screen
                isAtBottom = atBottom
                isVertical = vertical
                axis = axisObj
                menuHandle = item?.menu
                console.log("[Systray-Menu] menuHandle:", !!menuHandle, "hasMenu:", item?.hasMenu)

                if (parentScreen) {
                    console.log("[Systray-Menu] Setting screen for menuWindow")
                    for (var i = 0; i < Quickshell.screens.length; i++) {
                        const s = Quickshell.screens[i]
                        if (s === parentScreen) {
                            menuWindow.screen = s
                            console.log("[Systray-Menu] Screen set to index:", i)
                            break
                        }
                    }
                } else {
                    console.log("[Systray-Menu] No parentScreen provided")
                }
                showMenu = true
                console.log("[Systray-Menu] showMenu set to true, menuWindow.visible should be:", menuWindow.visible)
            }

            function close() {
                console.log("[Systray-Menu] close() called")
                showMenu = false
                console.log("[Systray-Menu] showMenu set to false, menuWindow.visible should be:", menuWindow.visible)
            }

            function showSubMenu(entry) {
                if (!entry || !entry.hasChildren) return;
                entryStack.append({ handle: entry });
                const h = entry.menu || entry;
                if (h && typeof h.updateLayout === "function") h.updateLayout();
                submenuHydrator.menu = h;
                submenuHydrator.open();
                Qt.callLater(() => submenuHydrator.close());
            }

            function goBack() {
                if (!entryStack.count) return;
                entryStack.remove(entryStack.count - 1);
            }

            width: 0
            height: 0
            color: "transparent"

            PanelWindow {
                id: menuWindow
                visible: {
                    const result = menuRoot.showMenu && (menuRoot.trayItem?.hasMenu ?? false)
                    console.log("[Systray-Menu] menuWindow.visible binding - showMenu:", menuRoot.showMenu, "hasMenu:", menuRoot.trayItem?.hasMenu ?? false, "result:", result)
                    return result
                }
                WlrLayershell.namespace: "quickshell:dock:blur"
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

                property point anchorPos: Qt.point(screen.width / 2, screen.height / 2)

                onVisibleChanged: {
                    console.log("[Systray-Menu] menuWindow.visible changed to:", visible)
                    if (visible) {
                        console.log("[Systray-Menu] Menu visible, updating position")
                        updatePosition()
                    }
                }

                function updatePosition() {
                    console.log("[Systray-Menu] updatePosition() called")
                    if (!menuRoot.anchorItem || !menuRoot.trayItem) {
                        console.log("[Systray-Menu] ERROR: Missing anchorItem or trayItem, using center position")
                        anchorPos = Qt.point(screen.width / 2, screen.height / 2)
                        return
                    }

                    const globalPos = menuRoot.anchorItem.mapToGlobal(0, 0)
                    const screenX = screen.x || 0
                    const screenY = screen.y || 0
                    const relativeX = globalPos.x - screenX
                    const relativeY = globalPos.y - screenY
                    console.log("[Systray-Menu] Position calculation - globalPos:", globalPos, "screen:", {x: screenX, y: screenY}, "relative:", {x: relativeX, y: relativeY})
                    const widgetThickness = Math.max(20, 26 + SettingsData.darkBarInnerPadding * 0.6)
                    const effectiveBarThickness = Math.max(widgetThickness + SettingsData.darkBarInnerPadding + 4, Theme.barHeight - 4 - (8 - SettingsData.darkBarInnerPadding))
                    console.log("[Systray-Menu] Bar calculations - widgetThickness:", widgetThickness, "effectiveBarThickness:", effectiveBarThickness)

                    if (menuRoot.isVertical) {
                        console.log("[Systray-Menu] Vertical layout")
                        const edge = menuRoot.axis?.edge
                        let targetX
                        if (edge === "left") {
                            targetX = effectiveBarThickness + SettingsData.darkBarSpacing + Theme.popupDistance
                        } else {
                            const popupX = effectiveBarThickness + SettingsData.darkBarSpacing + Theme.popupDistance
                            targetX = screen.width - popupX
                        }
                        anchorPos = Qt.point(targetX, relativeY + menuRoot.anchorItem.height / 2)
                        console.log("[Systray-Menu] Vertical anchorPos:", anchorPos)
                    } else {
                        console.log("[Systray-Menu] Horizontal layout, isAtBottom:", menuRoot.isAtBottom)
                        let targetY
                        if (menuRoot.isAtBottom) {
                            targetY = relativeY
                            console.log("[Systray-Menu] Bottom bar - targetY:", targetY, "relativeY:", relativeY)
                        } else {
                            targetY = relativeY + menuRoot.anchorItem.height + SettingsData.darkBarSpacing + Theme.popupDistance
                            console.log("[Systray-Menu] Top bar - targetY:", targetY, "relativeY:", relativeY)
                        }
                        anchorPos = Qt.point(relativeX + menuRoot.anchorItem.width / 2, targetY)
                        console.log("[Systray-Menu] Horizontal anchorPos:", anchorPos)
                    }
                }

                Rectangle {
                    id: menuContainer
                    width: Math.min(500, Math.max(250, menuColumn.implicitWidth + Theme.spacingS * 2))
                    height: Math.max(40, menuColumn.implicitHeight + Theme.spacingS * 2)

                    x: {
                        if (menuRoot.isVertical) {
                            const edge = menuRoot.axis?.edge
                            if (edge === "left") {
                                const targetX = menuWindow.anchorPos.x
                                return Math.min(menuWindow.screen.width - width - 10, targetX)
                            } else {
                                const targetX = menuWindow.anchorPos.x - width
                                return Math.max(10, targetX)
                            }
                        } else {
                            const left = 10
                            const right = menuWindow.width - width - 10
                            const want = menuWindow.anchorPos.x - width / 2
                            return Math.max(left, Math.min(right, want))
                        }
                    }

                    y: {
                        if (menuRoot.isVertical) {
                            const top = 10
                            const bottom = menuWindow.height - height - 10
                            const want = menuWindow.anchorPos.y - height / 2
                            return Math.max(top, Math.min(bottom, want))
                        } else {
                            if (menuRoot.isAtBottom) {
                                const menuHeight = menuContainer.height
                                const spacing = Theme.spacingS
                                
                                const bottomBarSize = typeof SettingsData !== "undefined" && SettingsData.topBarPosition === "bottom" && !SettingsData.topBarFloat && SettingsData.topBarVisible ? 
                                    (SettingsData.topBarHeight + SettingsData.topBarSpacing + (SettingsData.topBarGothCornersEnabled ? Theme.cornerRadius : 0)) : 0
                                
                                const maxMenuBottom = menuWindow.screen.height - bottomBarSize - spacing
                                const maxMenuTop = maxMenuBottom - menuHeight
                                
                                let targetY = menuWindow.anchorPos.y - menuHeight - spacing
                                
                                const minY = 10
                                
                                const topBarSize = typeof SettingsData !== "undefined" && SettingsData.topBarPosition === "top" && !SettingsData.topBarFloat && SettingsData.topBarVisible ? 
                                    (SettingsData.topBarHeight + SettingsData.topBarSpacing + (SettingsData.topBarGothCornersEnabled ? Theme.cornerRadius : 0)) : 0
                                
                                const clampedForBar = Math.min(maxMenuTop, targetY)
                                return Math.max(minY + topBarSize, clampedForBar)
                            } else {
                                const targetY = menuWindow.anchorPos.y
                                const bottomBarSize = typeof SettingsData !== "undefined" && SettingsData.topBarPosition === "bottom" && !SettingsData.topBarFloat && SettingsData.topBarVisible ? 
                                    (SettingsData.topBarHeight + SettingsData.topBarSpacing + (SettingsData.topBarGothCornersEnabled ? Theme.cornerRadius : 0)) : 0
                                const maxY = menuWindow.screen.height - height - 10 - bottomBarSize
                                return Math.min(maxY, targetY)
                            }
                        }
                    }

                    color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.8)
                    radius: 12
                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                    border.width: 1
                    opacity: menuRoot.showMenu ? 1 : 0
                    scale: menuRoot.showMenu ? 1 : 0.85

                    Rectangle {
                        anchors.fill: parent
                        anchors.topMargin: 4
                        anchors.leftMargin: 2
                        anchors.rightMargin: -2
                        anchors.bottomMargin: -4
                        radius: parent.radius
                        color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.4)
                        z: parent.z - 1
                    }

                    QsMenuAnchor {
                        id: submenuHydrator
                        anchor.window: menuWindow
                    }

                    QsMenuOpener {
                        id: rootOpener
                        menu: menuRoot.menuHandle
                    }

                    QsMenuOpener {
                        id: subOpener
                        menu: {
                            const e = menuRoot.topEntry();
                            return e ? (e.menu || e) : null;
                        }
                    }

                    Column {
                        id: menuColumn
                        width: parent.width - Theme.spacingS * 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: Theme.spacingS
                        spacing: 1

                        Rectangle {
                            visible: entryStack.count > 0
                            width: parent.width
                            height: 28
                            radius: Theme.cornerRadius
                            color: backArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"

                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: Theme.spacingS
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: Theme.spacingXS

                                DarkIcon {
                                    name: "arrow_back"
                                    size: 16
                                    color: Theme.surfaceText
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                StyledText {
                                    text: I18n.tr("Back")
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceText
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: backArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: menuRoot.goBack()
                            }
                        }

                        Rectangle {
                            visible: entryStack.count > 0
                            width: parent.width
                            height: 1
                            color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                        }

                        Repeater {
                            model: entryStack.count ? (subOpener.children ? subOpener.children : (menuRoot.topEntry()?.children || [])) : rootOpener.children

                            Rectangle {
                                property var menuEntry: modelData
                                width: menuColumn.width
                                height: menuEntry?.isSeparator ? 1 : 28
                                radius: menuEntry?.isSeparator ? 0 : Theme.cornerRadius
                                color: {
                                    if (menuEntry?.isSeparator) {
                                        return Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                                    }
                                    return itemArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"
                                }

                                MouseArea {
                                    id: itemArea
                                    anchors.fill: parent
                                    enabled: !menuEntry?.isSeparator && (menuEntry?.enabled !== false)
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (!menuEntry || menuEntry.isSeparator) return;
                                        if (menuEntry.hasChildren) {
                                            menuRoot.showSubMenu(menuEntry);
                                        } else {
                                            if (typeof menuEntry.activate === "function") {
                                                menuEntry.activate();
                                            } else if (typeof menuEntry.triggered === "function") {
                                                menuEntry.triggered();
                                            }
                                            Qt.createQmlObject('import QtQuick; Timer { interval: 80; running: true; repeat: false; onTriggered: menuRoot.close() }', menuRoot);
                                        }
                                    }
                                }

                                Row {
                                    anchors.left: parent.left
                                    anchors.leftMargin: Theme.spacingS
                                    anchors.right: parent.right
                                    anchors.rightMargin: Theme.spacingS
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: Theme.spacingXS
                                    visible: !menuEntry?.isSeparator

                                    Rectangle {
                                        width: 16
                                        height: 16
                                        anchors.verticalCenter: parent.verticalCenter
                                        visible: menuEntry?.buttonType !== undefined && menuEntry.buttonType !== 0
                                        radius: menuEntry?.buttonType === 2 ? 8 : 2
                                        border.width: 1
                                        border.color: Theme.outline
                                        color: "transparent"

                                        Rectangle {
                                            anchors.centerIn: parent
                                            width: parent.width - 6
                                            height: parent.height - 6
                                            radius: parent.radius - 3
                                            color: Theme.primary
                                            visible: menuEntry?.checkState === 2
                                        }

                                        DarkIcon {
                                            anchors.centerIn: parent
                                            name: "check"
                                            size: 10
                                            color: Theme.primaryText
                                            visible: menuEntry?.buttonType === 1 && menuEntry?.checkState === 2
                                        }
                                    }

                                    Item {
                                        width: 16
                                        height: 16
                                        anchors.verticalCenter: parent.verticalCenter
                                        visible: menuEntry?.icon && menuEntry.icon !== ""

                                        Image {
                                            anchors.fill: parent
                                            source: menuEntry?.icon || ""
                                            sourceSize.width: 16
                                            sourceSize.height: 16
                                            fillMode: Image.PreserveAspectFit
                                            smooth: true
                                        }
                                    }

                                    StyledText {
                                        text: menuEntry?.text || ""
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: (menuEntry?.enabled !== false) ? Theme.surfaceText : Theme.surfaceTextMedium
                                        elide: Text.ElideRight
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: Math.max(150, parent.width - 64)
                                        wrapMode: Text.NoWrap
                                    }

                                    Item {
                                        width: 16
                                        height: 16
                                        anchors.verticalCenter: parent.verticalCenter

                                        DarkIcon {
                                            anchors.centerIn: parent
                                            name: "chevron_right"
                                            size: 14
                                            color: Theme.surfaceText
                                            visible: menuEntry?.hasChildren ?? false
                                        }
                                    }
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
                    onClicked: menuRoot.close()
                }
            }
        }
    }

    property var currentTrayMenu: null

    QsMenuAnchor {
        id: menuAnchor
    }

    function showForTrayItem(item, anchor, screen, atBottom, vertical, axisObj) {
        console.log("[Systray] showForTrayItem called in root")
        console.log("[Systray] Parameters - item:", !!item, "item.id:", item?.id || "unknown", "anchor:", !!anchor, "screen:", !!screen, "atBottom:", atBottom, "vertical:", vertical)
        if (currentTrayMenu) {
            console.log("[Systray] Destroying existing menu")
            currentTrayMenu.destroy()
        }
        console.log("[Systray] Creating new menu component")
        currentTrayMenu = trayMenuComponent.createObject(null)
        if (currentTrayMenu) {
            console.log("[Systray] Menu component created, calling showForTrayItem on it")
            currentTrayMenu.showForTrayItem(item, anchor, screen, atBottom ?? false, vertical ?? false, axisObj)
        } else {
            console.log("[Systray] ERROR: Failed to create menu component!")
        }
    }
}
