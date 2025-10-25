import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Common
import qs.Modules.AppDrawer
import qs.Services
import qs.Widgets

DankPopout {
    id: appDrawerPopout

    property string triggerSection: "left"
    property var triggerScreen: null

    WlrLayershell.namespace: "quickshell:appDrawerPopout:blur"

    // Setting to Exclusive, so virtual keyboards can send input to app drawer
    WlrLayershell.keyboardFocus: shouldBeVisible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None 

    function show() {
        open()
    }

    function setTriggerPosition(x, y, width, section, screen) {
        triggerX = x
        triggerY = y
        triggerWidth = width
        triggerSection = section
        triggerScreen = screen
    }

    popupWidth: 800
    popupHeight: 800
    triggerX: Theme.spacingL
    triggerY: Theme.barHeight - 4 + SettingsData.topBarSpacing + Theme.spacingXS
    triggerWidth: 40
    positioning: "center"
    screen: triggerScreen

    onShouldBeVisibleChanged: {
        if (shouldBeVisible) {
            appLauncher.searchQuery = ""
            appLauncher.selectedIndex = 0
            appLauncher.setCategory("All")
            Qt.callLater(() => {
                             if (contentLoader.item && contentLoader.item.searchField) {
                                 contentLoader.item.searchField.text = ""
                                 contentLoader.item.searchField.forceActiveFocus()
                             }
                         })
        }
    }

    AppLauncher {
        id: appLauncher

        viewMode: "list"
        gridColumns: 4
        onAppLaunched: appDrawerPopout.close()
        onViewModeSelected: function (mode) {
            SettingsData.setAppLauncherViewMode(mode)
        }
    }

    // Function to get app data from app ID
    function getAppDataFromId(appId) {
        if (!appId) {
            console.log("getAppDataFromId: appId is null/undefined")
            return null
        }
        
        // Use the same approach as the dock - DesktopEntries.heuristicLookup
        const desktopEntry = DesktopEntries.heuristicLookup(appId)
        if (desktopEntry) {
            console.log("getAppDataFromId: Found app", appId, "->", desktopEntry.name)
            return {
                name: desktopEntry.name || "",
                exec: desktopEntry.execString || desktopEntry.exec || "",
                icon: desktopEntry.icon || "application-x-executable",
                comment: desktopEntry.comment || "",
                categories: desktopEntry.categories || [],
                desktopEntry: desktopEntry
            }
        }
        console.log("getAppDataFromId: No desktop entry found for", appId)
        return null
    }

    content: Component {
        Rectangle {
            id: launcherPanel

            property alias searchField: searchField

            color: Theme.popupBackground()
            radius: Theme.cornerRadius
            antialiasing: true
            smooth: true
            clip: true // Ensure all content is clipped to panel bounds

            // Multi-layer border effect
            Repeater {
                model: [{
                        "margin": -3,
                        "color": Qt.rgba(0, 0, 0, 0.05),
                        "z": -3
                    }, {
                        "margin": -2,
                        "color": Qt.rgba(0, 0, 0, 0.08),
                        "z": -2
                    }, {
                        "margin": 0,
                        "color": Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12),
                        "z": -1
                    }]
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: modelData.margin
                    color: "transparent"
                    radius: parent.radius + Math.abs(modelData.margin)
                    border.color: modelData.color
                    border.width: 1
                    z: modelData.z
                }
            }

            Item {
                id: keyHandler

                anchors.fill: parent
                focus: true
                readonly property var keyMappings: {
                    const mappings = {}
                    mappings[Qt.Key_Escape] = () => appDrawerPopout.close()
                    mappings[Qt.Key_Down] = () => appLauncher.selectNext()
                    mappings[Qt.Key_Up] = () => appLauncher.selectPrevious()
                    mappings[Qt.Key_Return] = () => appLauncher.launchSelected()
                    mappings[Qt.Key_Enter] = () => appLauncher.launchSelected()

                    if (appLauncher.viewMode === "grid") {
                        mappings[Qt.Key_Right] = () => appLauncher.selectNextInRow()
                        mappings[Qt.Key_Left] = () => appLauncher.selectPreviousInRow()
                    }

                    return mappings
                }

                Keys.onPressed: function (event) {
                    if (keyMappings[event.key]) {
                        keyMappings[event.key]()
                        event.accepted = true
                        return
                    }

                    if (!searchField.activeFocus && event.text && /[a-zA-Z0-9\s]/.test(event.text)) {
                        searchField.forceActiveFocus()
                        searchField.insertText(event.text)
                        event.accepted = true
                    }
                }

                Row {
                    anchors.fill: parent
                    anchors.margins: 0
                    spacing: 0
                    clip: true // Ensure row content is clipped to bounds

                    // Left Panel - Pinned Apps & Power Controls
                    Rectangle {
                        width: parent.width * 0.4 + 2
                        height: parent.height
                        color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.05)
                        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.1)
                        border.width: 1
                        clip: true // Ensure all content is clipped to panel bounds

                        Column {
                            anchors.fill: parent
                            anchors.margins: Theme.spacingL
                            spacing: Theme.spacingL
                            clip: true // Ensure column content is clipped

                            // Pinned Apps Section
                            Column {
                                id: pinnedAppsColumn
                                width: parent.width
                                spacing: Theme.spacingM
                                clip: true // Ensure content is clipped to section bounds

                                StyledText {
                                    text: "Pinned"
                                    font.pixelSize: Theme.fontSizeLarge + 2
                                    font.weight: Font.Bold
                                    color: Theme.surfaceText
                                }

                                // Pinned Apps Grid (3x5 = 15 apps)
                                Grid {
                                    width: parent.width
                                    columns: 3
                                    rowSpacing: Theme.spacingM / 2
                                    columnSpacing: Theme.spacingM / 2
                                    clip: true // Ensure grid content is clipped

                                    Repeater {
                                        model: Math.min(15, SessionData.startMenuPinnedApps.length)
                                        
                                        Rectangle {
                                            width: (parent.width - Theme.spacingM * 2) / 3
                                            height: 100
                                            radius: Theme.cornerRadius
                                            color: pinnedMouseArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"
                                            border.color: pinnedMouseArea.containsMouse ? Theme.primary : "transparent"
                                            border.width: 1

                                            property var appData: getAppDataFromId(SessionData.startMenuPinnedApps[index])

                                            Column {
                                                anchors.centerIn: parent
                                                spacing: Theme.spacingXS

                                                Item {
                                                    width: 64
                                                    height: 64
                                                    anchors.horizontalCenter: parent.horizontalCenter

                                                    Image {
                                                        id: pinnedIconImg
                                                        anchors.centerIn: parent
                                                        width: 64
                                                        height: 64
                                                        sourceSize.width: 64
                                                        sourceSize.height: 64
                                                        fillMode: Image.PreserveAspectFit
                                                        source: Quickshell.iconPath(parent.parent.parent.appData?.icon || "", true)
                                                        smooth: true
                                                        asynchronous: true
                                                        visible: status === Image.Ready
                                                    }

                                                    Rectangle {
                                                        anchors.fill: parent
                                                        visible: !pinnedIconImg.visible
                                                        color: Theme.surfaceLight
                                                        radius: Theme.cornerRadius
                                                        border.width: 1
                                                        border.color: Theme.primarySelected

                                                        StyledText {
                                                            anchors.centerIn: parent
                                                            text: (parent.parent.parent.appData?.name && parent.parent.parent.appData.name.length > 0) ? parent.parent.parent.appData.name.charAt(0).toUpperCase() : "A"
                                                            font.pixelSize: 16
                                                            color: Theme.primary
                                                            font.weight: Font.Bold
                                                        }
                                                    }
                                                }

                                                StyledText {
                                                    width: parent.width
                                                    text: parent.parent.parent.appData?.name || ""
                                                    font.pixelSize: Theme.fontSizeSmall
                                                    color: Theme.surfaceText
                                                    font.weight: Font.Medium
                                                    elide: Text.ElideRight
                                                    horizontalAlignment: Text.AlignHCenter
                                                    maximumLineCount: 1
                                                }
                                            }

                                            MouseArea {
                                                id: pinnedMouseArea
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                                onClicked: {
                                                    if (mouse.button === Qt.LeftButton) {
                                                        if (parent.appData) {
                                                            appLauncher.launchApp(parent.appData)
                                                        }
                                                    } else if (mouse.button === Qt.RightButton) {
                                                        pinnedContextMenu.show(mouse.x, mouse.y, parent.appData)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // Recent Documents Section
                            Column {
                                width: parent.width
                                spacing: Theme.spacingM
                                visible: false // Hide for now as we don't have recent documents

                                StyledText {
                                    text: "Recent >"
                                    font.pixelSize: Theme.fontSizeLarge + 2
                                    font.weight: Font.Bold
                                    color: Theme.surfaceText
                                }

                                // Recent documents would go here
                            }

                            // Spacer to push power controls to bottom
                            Item {
                                width: parent.width
                                height: parent.height - pinnedAppsColumn.height - powerControlsColumn.height - Theme.spacingL * 2
                            }

                            // Power Controls Section
                            Column {
                                id: powerControlsColumn
                                width: parent.width
                                spacing: Theme.spacingM
                                clip: true // Ensure content is clipped to section bounds

                                // User Profile and System Controls
                    Row {
                        width: parent.width
                                    height: 60
                                    spacing: Theme.spacingM

                                    // User Profile
                                    Row {
                                        spacing: Theme.spacingS

                                        // Profile Picture
                                        Item {
                                            width: 40
                                            height: 40

                                            // Profile Image with circular mask
                                            Rectangle {
                                                id: profileImageContainer
                                                anchors.fill: parent
                                                radius: 20
                                                color: "transparent"
                                                clip: true

                                                Image {
                                                    id: profileImage
                                                    anchors.fill: parent
                                                    source: {
                                                        if (PortalService.profileImage === "")
                                                            return ""
                                                        
                                                        if (PortalService.profileImage.startsWith("/"))
                                                            return "file://" + PortalService.profileImage
                                                        
                                                        return PortalService.profileImage
                                                    }
                                                    smooth: true
                                                    asynchronous: true
                                                    mipmap: true
                                                    cache: true
                                                    visible: status === Image.Ready
                                                    fillMode: Image.PreserveAspectCrop
                                                }
                                            }

                                            // Fallback circle with initial
                                            Rectangle {
                                                anchors.fill: parent
                                                radius: 20
                                                color: Theme.primary
                                                visible: !profileImage.visible

                        StyledText {
                                                    anchors.centerIn: parent
                                                    text: (UserInfoService.username.length > 0) ? UserInfoService.username.charAt(0).toUpperCase() : "U"
                                                    font.pixelSize: 18
                                                    color: "white"
                                                    font.weight: Font.Bold
                                                }
                                            }
                                        }

                                        Column {
                                            spacing: 2

                                            StyledText {
                                                text: UserInfoService.fullName || UserInfoService.username || "User"
                                                font.pixelSize: Theme.fontSizeMedium
                                                color: Theme.surfaceText
                                                font.weight: Font.Medium
                                            }
                                        }
                                    }

                                    // Spacer to push system controls to the right
                                    Item {
                                        width: parent.width - 200 // Adjust as needed
                                        height: 1
                                    }

                                    // System Controls
                                    Row {
                                        spacing: Theme.spacingS

                                        // Folder, Settings buttons
                                        Repeater {
                                            model: [
                                                {icon: "folder", tooltip: "Files"},
                                                {icon: "settings", tooltip: "Settings"}
                                            ]

                                            Rectangle {
                                                width: 36
                                                height: 36
                                                radius: 6
                                                color: sysArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: {
                                                        switch(modelData.icon) {
                                                            case "folder": return "folder"
                                                            case "settings": return "settings"
                                                            default: return "settings"
                                                        }
                                                    }
                                                    font.family: "Material Symbols Outlined"
                                                    font.pixelSize: 20
                                                    color: Theme.surfaceText
                                                }

                                                MouseArea {
                                                    id: sysArea
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    onClicked: {
                                                        if (modelData.icon === "settings") {
                                                            // Open settings modal
                                                            settingsModal.show()
                                                        } else if (modelData.icon === "folder") {
                                                            // Open Nautilus file manager
                                                            Quickshell.execDetached(["nautilus"])
                                                        }
                                                        appDrawerPopout.close()
                                                    }
                                                }

                                                // Tooltip
                                                Rectangle {
                                                    anchors.bottom: parent.top
                                                    anchors.bottomMargin: 8
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                    width: tooltipText.width + 12
                                                    height: tooltipText.height + 8
                                                    color: Qt.rgba(0, 0, 0, 0.8)
                                                    radius: 4
                                                    visible: sysArea.containsMouse

                                                    Text {
                                                        id: tooltipText
                                                        anchors.centerIn: parent
                                                        text: modelData.tooltip
                                                        color: "white"
                                                        font.pixelSize: 10
                                                    }
                                                }

                                                Behavior on color {
                                                    ColorAnimation {
                                                        duration: 150
                                                        easing.type: Easing.OutQuad
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                // Power buttons row
                                Row {
                                    width: parent.width
                                    spacing: Theme.spacingS

                                    // Idle Inhibitor Button
                                    Rectangle {
                                        id: idleInhibitorButton
                                        width: 36
                                        height: 36
                                        radius: 6
                                        property bool isInhibiting: false
                                        color: idleArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"
                                        border.color: idleInhibitorButton.isInhibiting ? Theme.primary : (idleArea.containsMouse ? Theme.outline : "transparent")
                                        border.width: idleInhibitorButton.isInhibiting ? 2 : (idleArea.containsMouse ? 1 : 0)

                                        Text {
                                            anchors.centerIn: parent
                                            text: idleInhibitorButton.isInhibiting ? "coffee" : "bedtime"
                                            font.family: "Material Symbols Outlined"
                                            font.pixelSize: 20
                                            color: Theme.surfaceText
                                        }

                                        MouseArea {
                                            id: idleArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: {
                                                if (idleInhibitorButton.isInhibiting) {
                                                    startHypridle.startDetached()
                                                    idleInhibitorButton.isInhibiting = false
                                                } else {
                                                    killHypridle.startDetached()
                                                    idleInhibitorButton.isInhibiting = true
                                                }
                                            }
                                        }

                                        Process {
                                            id: killHypridle
                                            command: ["pkill", "hypridle"]
                                        }

                                        Process {
                                            id: startHypridle
                                            command: ["hypridle"]
                                        }

                                        Component.onCompleted: {
                                            killHypridle.startDetached()
                                            idleInhibitorButton.isInhibiting = true
                                        }
                                    }

                                    // Night Light Button
                                    Rectangle {
                                        id: nightLightButton
                                        width: 36
                                        height: 36
                                        radius: 6
                                        color: nightArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"
                                        border.color: enabled ? Theme.primary : (nightArea.containsMouse ? Theme.outline : "transparent")
                                        border.width: enabled ? 2 : (nightArea.containsMouse ? 1 : 0)
                                        property bool enabled: false

                                        Text {
                                            anchors.centerIn: parent
                                            text: "nightlight"
                                            font.family: "Material Symbols Outlined"
                                            font.pixelSize: 20
                                            color: Theme.surfaceText
                                        }

                                        MouseArea {
                                            id: nightArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: {
                                                nightLightButton.enabled = !nightLightButton.enabled
                                                if (enabled) {
                                                    nightLightOn.startDetached()
                                                } else {
                                                    nightLightOff.startDetached()
                                                }
                                            }
                                        }

                                        Process {
                                            id: nightLightOn
                                            command: ["gammastep"]
                                        }

                                        Process {
                                            id: nightLightOff
                                            command: ["pkill", "gammastep"]
                                        }
                                    }

                                    // System buttons
                                    Repeater {
                                        model: [
                                            {icon: "refresh", tooltip: "Reload", command: ["pkill", "-f", "quickshell"], action: "reload"},
                                            {icon: "lock", tooltip: "Lock", command: ["hyprlock"]},
                                            {icon: "logout", tooltip: "Logout", command: ["hyprctl", "dispatch", "exit"]},
                                            {icon: "restart_alt", tooltip: "Restart", command: ["systemctl", "reboot"]},
                                            {icon: "power_settings_new", tooltip: "Shutdown", command: ["systemctl", "poweroff"]}
                                        ]

                                        Rectangle {
                                            width: 36
                                            height: 36
                                            radius: 6
                                            color: sysArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"

                                            Text {
                                                anchors.centerIn: parent
                                                text: {
                                                    switch(modelData.icon) {
                                                        case "refresh": return "refresh"
                                                        case "lock": return "lock"
                                                        case "logout": return "logout"
                                                        case "restart_alt": return "restart_alt"
                                                        case "power_settings_new": return "power_settings_new"
                                                        default: return "settings"
                                                    }
                                                }
                                                font.family: "Material Symbols Outlined"
                                                font.pixelSize: 20
                                                color: Theme.surfaceText
                                            }

                                            MouseArea {
                                                id: sysArea
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                onClicked: {
                                                    if (modelData.action === "reload") {
                                                        Quickshell.reload(true)
                                                    } else {
                                                        Quickshell.execDetached(modelData.command)
                                                    }
                                                    appDrawerPopout.close()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Right Panel - All Apps
                    Rectangle {
                        width: parent.width * 0.6
                        height: parent.height
                        color: "transparent"
                        clip: true // Ensure all content is clipped to panel bounds

                        Column {
                            anchors.fill: parent
                            anchors.margins: Theme.spacingL
                            spacing: Theme.spacingL
                            clip: true // Ensure column content is clipped

                            // Header
                            Row {
                                width: parent.width
                                height: 40

                                StyledText {
                                    text: "All Apps"
                            font.pixelSize: Theme.fontSizeLarge + 4
                            font.weight: Font.Bold
                            color: Theme.surfaceText
                                    anchors.verticalCenter: parent.verticalCenter
                        }

                        Item {
                            width: parent.width - 200
                            height: 1
                        }

                                // Hamburger menu icon
                                Rectangle {
                                    width: 36
                                    height: 36
                                    radius: 6
                                    color: hamburgerArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"
                            anchors.verticalCenter: parent.verticalCenter


                                    MouseArea {
                                        id: hamburgerArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: {
                                            // Toggle view mode or show options
                                            appLauncher.setViewMode(appLauncher.viewMode === "grid" ? "list" : "grid")
                                        }
                                    }
                                }
                            }

                            // Search Bar
                    DankTextField {
                        id: searchField

                        width: parent.width
                                height: 40
                        cornerRadius: Theme.cornerRadius
                                backgroundColor: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                        normalBorderColor: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.3)
                        focusedBorderColor: Theme.primary
                        leftIconName: "search"
                        leftIconSize: Theme.iconSize
                        leftIconColor: Theme.surfaceVariantText
                        leftIconFocusedColor: Theme.primary
                        showClearButton: true
                                font.pixelSize: Theme.fontSizeMedium
                        enabled: appDrawerPopout.shouldBeVisible
                        ignoreLeftRightKeys: true
                        keyForwardTargets: [keyHandler]
                                placeholderText: "Type here to search"
                        onTextEdited: {
                            appLauncher.searchQuery = text
                        }
                        Keys.onPressed: function (event) {
                            if (event.key === Qt.Key_Escape) {
                                appDrawerPopout.close()
                                event.accepted = true
                                return
                            }

                            const isEnterKey = [Qt.Key_Return, Qt.Key_Enter].includes(event.key)
                            const hasText = text.length > 0

                            if (isEnterKey && hasText) {
                                if (appLauncher.keyboardNavigationActive && appLauncher.model.count > 0) {
                                    appLauncher.launchSelected()
                                } else if (appLauncher.model.count > 0) {
                                    appLauncher.launchApp(appLauncher.model.get(0))
                                }
                                event.accepted = true
                                return
                            }

                            const navigationKeys = [Qt.Key_Down, Qt.Key_Up, Qt.Key_Left, Qt.Key_Right]
                            const isNavigationKey = navigationKeys.includes(event.key)
                            const isEmptyEnter = isEnterKey && !hasText

                            event.accepted = !(isNavigationKey || isEmptyEnter)
                        }

                        Connections {
                            function onShouldBeVisibleChanged() {
                                if (!appDrawerPopout.shouldBeVisible) {
                                    searchField.focus = false
                                }
                            }
                            target: appDrawerPopout
                        }
                    }


                            // All Apps List
                            Rectangle {
                                width: parent.width
                                height: parent.height - 80 // Adjust based on header and search
                                radius: Theme.cornerRadius
                                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.05)
                                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.1)
                                border.width: 1
                                clip: true // Ensure content is clipped to container bounds

                                DankListView {
                                    id: appList

                                    property int itemHeight: 60
                                    property int iconSize: 48
                                    property bool showDescription: false
                                    property int itemSpacing: 2
                                    property bool hoverUpdatesSelection: false
                                    property bool keyboardNavigationActive: appLauncher.keyboardNavigationActive

                                    signal keyboardNavigationReset
                                    signal itemClicked(int index, var modelData)
                                    signal itemRightClicked(int index, var modelData, real mouseX, real mouseY)

                                    function ensureVisible(index) {
                                        if (index < 0 || index >= count)
                                            return

                                        var itemY = index * (itemHeight + itemSpacing)
                                        var itemBottom = itemY + itemHeight
                                        if (itemY < contentY)
                                            contentY = itemY
                                        else if (itemBottom > contentY + height)
                                            contentY = itemBottom - height
                                    }

                                    anchors.fill: parent
                                    anchors.margins: Theme.spacingS
                                    clip: true // Ensure list content is clipped to bounds
                                    model: appLauncher.model
                                    currentIndex: appLauncher.selectedIndex
                                    spacing: itemSpacing
                                    focus: true
                                    interactive: true
                                    cacheBuffer: Math.max(0, Math.min(height * 2, 1000))
                                    reuseItems: true

                            onCurrentIndexChanged: {
                                if (keyboardNavigationActive)
                                    ensureVisible(currentIndex)
                            }

                            onItemClicked: function (index, modelData) {
                                appLauncher.launchApp(modelData)
                            }
                            onItemRightClicked: function (index, modelData, mouseX, mouseY) {
                                contextMenu.show(mouseX, mouseY, modelData)
                            }
                            onKeyboardNavigationReset: {
                                appLauncher.keyboardNavigationActive = false
                            }

                            delegate: Rectangle {
                                    width: ListView.view.width
                                    height: appList.itemHeight
                                radius: Theme.cornerRadius
                                    color: ListView.isCurrentItem ? Theme.primaryPressed : listMouseArea.containsMouse ? Theme.primaryHoverLight : "transparent"
                                    border.color: ListView.isCurrentItem ? Theme.primarySelected : "transparent"
                                    border.width: ListView.isCurrentItem ? 2 : 0

                                    Row {
                                        anchors.fill: parent
                                        anchors.margins: Theme.spacingM
                                        spacing: Theme.spacingM

                                        Item {
                                            width: appList.iconSize
                                            height: appList.iconSize
                                            anchors.verticalCenter: parent.verticalCenter

                                            Image {
                                                id: listIconImg
                                                anchors.centerIn: parent
                                                width: 48
                                                height: 48
                                                sourceSize.width: 48
                                                sourceSize.height: 48
                                                fillMode: Image.PreserveAspectFit
                                                source: Quickshell.iconPath(model.icon, true)
                                                smooth: true
                                                asynchronous: true
                                                visible: status === Image.Ready
                                            }

                                            Rectangle {
                                                anchors.fill: parent
                                                visible: !listIconImg.visible
                                                color: Theme.surfaceLight
                                                radius: Theme.cornerRadius
                                                border.width: 1
                                                border.color: Theme.primarySelected

                                                StyledText {
                                                    anchors.centerIn: parent
                                                    text: (model.name && model.name.length > 0) ? model.name.charAt(0).toUpperCase() : "A"
                                                    font.pixelSize: 16
                                                    color: Theme.primary
                                                    font.weight: Font.Bold
                                                }
                                            }
                                        }

                                        Column {
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: parent.width - appList.iconSize - Theme.spacingM
                                            spacing: 2

                                            StyledText {
                                                width: parent.width
                                                text: model.name || ""
                                                font.pixelSize: Theme.fontSizeMedium
                                                color: Theme.surfaceText
                                                font.weight: Font.Medium
                                                elide: Text.ElideRight
                                            }

                                            StyledText {
                                                width: parent.width
                                                text: model.comment || ""
                                                font.pixelSize: Theme.fontSizeSmall
                                                color: Theme.surfaceVariantText
                                                font.weight: Font.Normal
                                                elide: Text.ElideRight
                                                visible: model.comment && model.comment.length > 0
                                            }
                                        }
                                    }

                                MouseArea {
                                        id: listMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                                    z: 10
                                    onEntered: {
                                            if (appList.hoverUpdatesSelection && !appList.keyboardNavigationActive)
                                                appList.currentIndex = index
                                    }
                                    onPositionChanged: {
                                            appList.keyboardNavigationReset()
                                    }
                                    onClicked: mouse => {
                                                   if (mouse.button === Qt.LeftButton) {
                                                appList.itemClicked(index, model)
                                                   } else if (mouse.button === Qt.RightButton) {
                                                       var panelPos = mapToItem(contextMenu.parent, mouse.x, mouse.y)
                                                appList.itemRightClicked(index, model, panelPos.x, panelPos.y)
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
        }
    }

    Rectangle {
        id: contextMenu

        property var currentApp: null
        property bool menuVisible: false

        readonly property string appId: (currentApp && currentApp.desktopEntry) ? (currentApp.desktopEntry.id || currentApp.desktopEntry.execString || "") : ""
        readonly property bool isPinned: appId && SessionData.isPinnedApp(appId)
        readonly property bool isStartMenuPinned: appId && SessionData.isStartMenuPinnedApp(appId)

        function show(x, y, app) {
            currentApp = app

            const menuWidth = 180
            const menuHeight = menuColumn.implicitHeight + Theme.spacingS * 2

            let finalX = x + 8
            let finalY = y + 8

            if (finalX + menuWidth > appDrawerPopout.popupWidth) {
                finalX = x - menuWidth - 8
            }

            if (finalY + menuHeight > appDrawerPopout.popupHeight) {
                finalY = y - menuHeight - 8
            }

            finalX = Math.max(8, Math.min(finalX, appDrawerPopout.popupWidth - menuWidth - 8))
            finalY = Math.max(8, Math.min(finalY, appDrawerPopout.popupHeight - menuHeight - 8))

            contextMenu.x = finalX
            contextMenu.y = finalY
            contextMenu.visible = true
            contextMenu.menuVisible = true
        }

        function close() {
            contextMenu.menuVisible = false
            Qt.callLater(() => {
                             contextMenu.visible = false
                         })
        }

        visible: false
        width: 180
        height: menuColumn.implicitHeight + Theme.spacingS * 2
        radius: Theme.cornerRadius
        color: Theme.popupBackground()
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
        border.width: 1
        z: 1000
        opacity: menuVisible ? 1 : 0
        scale: menuVisible ? 1 : 0.85

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

            anchors.fill: parent
            anchors.margins: Theme.spacingS
            spacing: 1

            Rectangle {
                width: parent.width
                height: 32
                radius: Theme.cornerRadius
                color: pinMouseArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.spacingS
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.spacingS

                    DankIcon {
                        name: contextMenu.isPinned ? "keep_off" : "push_pin"
                        size: Theme.iconSize - 2
                        color: Theme.surfaceText
                        opacity: 0.7
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    StyledText {
                        text: contextMenu.isPinned ? "Unpin from Dock" : "Pin to Dock"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceText
                        font.weight: Font.Normal
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: pinMouseArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (!contextMenu.currentApp || !contextMenu.currentApp.desktopEntry) {
                            return
                        }

                        if (contextMenu.isPinned) {
                            SessionData.removePinnedApp(contextMenu.appId)
                        } else {
                            SessionData.addPinnedApp(contextMenu.appId)
                        }
                        contextMenu.close()
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 32
                radius: Theme.cornerRadius
                color: startMenuPinMouseArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.spacingS
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.spacingS

                    DankIcon {
                        name: contextMenu.isStartMenuPinned ? "keep_off" : "push_pin"
                        size: Theme.iconSize - 2
                        color: Theme.surfaceText
                        opacity: 0.7
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    StyledText {
                        text: contextMenu.isStartMenuPinned ? "Unpin from Start Menu" : "Pin to Start Menu"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceText
                        font.weight: Font.Normal
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: startMenuPinMouseArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (!contextMenu.currentApp || !contextMenu.currentApp.desktopEntry) {
                            return
                        }

                        if (contextMenu.isStartMenuPinned) {
                            SessionData.removeStartMenuPinnedApp(contextMenu.appId)
                        } else {
                            SessionData.addStartMenuPinnedApp(contextMenu.appId)
                        }
                        contextMenu.close()
                    }
                }
            }

            Rectangle {
                width: parent.width - Theme.spacingS * 2
                height: 5
                anchors.horizontalCenter: parent.horizontalCenter
                color: "transparent"

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width
                    height: 1
                    color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                }
            }

            Rectangle {
                width: parent.width
                height: 32
                radius: Theme.cornerRadius
                color: launchMouseArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.spacingS
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.spacingS

                    DankIcon {
                        name: "launch"
                        size: Theme.iconSize - 2
                        color: Theme.surfaceText
                        opacity: 0.7
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    StyledText {
                        text: "Launch"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceText
                        font.weight: Font.Normal
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: launchMouseArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (contextMenu.currentApp)
                            appLauncher.launchApp(contextMenu.currentApp)

                        contextMenu.close()
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
        visible: contextMenu.visible
        z: 999
        onClicked: {
            contextMenu.close()
        }

        MouseArea {
            x: contextMenu.x
            y: contextMenu.y
            width: contextMenu.width
            height: contextMenu.height
            onClicked: {

                // Prevent closing when clicking on the menu itself
            }
        }
    }

    // Context menu for pinned apps
    Rectangle {
        id: pinnedContextMenu

        property var currentApp: null
        property bool menuVisible: false

        readonly property string appId: (currentApp && currentApp.desktopEntry) ? (currentApp.desktopEntry.id || currentApp.desktopEntry.execString || "") : ""

        function show(x, y, app) {
            currentApp = app

            const menuWidth = 180
            const menuHeight = pinnedMenuColumn.implicitHeight + Theme.spacingS * 2

            let finalX = x + 8
            let finalY = y + 8

            if (finalX + menuWidth > appDrawerPopout.popupWidth) {
                finalX = x - menuWidth - 8
            }

            if (finalY + menuHeight > appDrawerPopout.popupHeight) {
                finalY = y - menuHeight - 8
            }

            finalX = Math.max(8, Math.min(finalX, appDrawerPopout.popupWidth - menuWidth - 8))
            finalY = Math.max(8, Math.min(finalY, appDrawerPopout.popupHeight - menuHeight - 8))

            pinnedContextMenu.x = finalX
            pinnedContextMenu.y = finalY
            pinnedContextMenu.visible = true
            pinnedContextMenu.menuVisible = true
        }

        function close() {
            pinnedContextMenu.menuVisible = false
            Qt.callLater(() => {
                             pinnedContextMenu.visible = false
                         })
        }

        visible: false
        width: 180
        height: pinnedMenuColumn.implicitHeight + Theme.spacingS * 2
        radius: Theme.cornerRadius
        color: Theme.popupBackground()
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
        border.width: 1
        z: 1000
        opacity: menuVisible ? 1 : 0
        scale: menuVisible ? 1 : 0.85

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: Theme.popupBackground()
            border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
            border.width: 1
        }

        Column {
            id: pinnedMenuColumn
            anchors.fill: parent
            anchors.margins: Theme.spacingS
            spacing: 2

            Rectangle {
                width: parent.width
                height: 32
                radius: Theme.cornerRadius
                color: launchPinnedMouseArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.spacingS
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.spacingS

                    DankIcon {
                        name: "launch"
                        size: Theme.iconSize - 2
                        color: Theme.surfaceText
                        opacity: 0.7
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    StyledText {
                        text: "Launch"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceText
                        font.weight: Font.Normal
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: launchPinnedMouseArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (pinnedContextMenu.currentApp)
                            appLauncher.launchApp(pinnedContextMenu.currentApp)

                        pinnedContextMenu.close()
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 32
                radius: Theme.cornerRadius
                color: unpinMouseArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.spacingS
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.spacingS

                    DankIcon {
                        name: "keep_off"
                        size: Theme.iconSize - 2
                        color: Theme.surfaceText
                        opacity: 0.7
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    StyledText {
                        text: "Unpin from Start Menu"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceText
                        font.weight: Font.Normal
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: unpinMouseArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (pinnedContextMenu.currentApp && pinnedContextMenu.appId) {
                            SessionData.removeStartMenuPinnedApp(pinnedContextMenu.appId)
                        }
                        pinnedContextMenu.close()
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
        visible: pinnedContextMenu.visible
        z: 999
        onClicked: {
            pinnedContextMenu.close()
        }

        MouseArea {
            x: pinnedContextMenu.x
            y: pinnedContextMenu.y
            width: pinnedContextMenu.width
            height: pinnedContextMenu.height
            onClicked: {
                // Prevent closing when clicking on the menu itself
            }
        }
    }
}
