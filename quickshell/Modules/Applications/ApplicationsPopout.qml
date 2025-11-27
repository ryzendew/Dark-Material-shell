import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services
import qs.Widgets

DarkPopout {
    id: root
    objectName: "applicationsPopout"

    property string triggerSection: "center"
    property var triggerScreen: null
    property string currentView: "tiled" // "tiled" or "list"
    property string currentSort: "category" // "category" or "alphabetical"
    property string searchQuery: ""
    property var expandedCategories: ({})
    property int _expandedCategoriesVersion: 0

    readonly property var macCategories: {
        return {
            "Utilities": ["Utility", "System", "Settings"],
            "Productivity and Finance": ["Office", "Finance", "TextEditor", "Development"],
            "Social": ["Network", "InstantMessaging"],
            "Creativity": ["Graphics", "AudioVideo", "Video", "Audio"],
            "Information and Reading": ["Documentation", "Viewer"],
            "Entertainment": ["Game", "Video", "Audio"],
            "Other": []
        }
    }

    readonly property int appsPerRow: 8
    readonly property int iconSize: 64
    readonly property int iconSpacing: Theme.spacingM

    function getCategoryForApp(app) {
        if (!app || !app.categories) return "Other"
        const appCats = app.categories
        for (const macCat in macCategories) {
            const linuxCats = macCategories[macCat]
            for (const linuxCat of linuxCats) {
                if (appCats.includes(linuxCat)) {
                    return macCat
                }
            }
        }
        return "Other"
    }

    function getCategorizedApps() {
        const categorized = {}
        let allApps = AppSearchService.applications || []
        
        if (searchQuery.length > 0) {
            allApps = AppSearchService.searchApplications(searchQuery)
        }
        
        for (const app of allApps) {
            const category = getCategoryForApp(app)
            if (!categorized[category]) {
                categorized[category] = []
            }
            categorized[category].push(app)
        }
        
        for (const cat in categorized) {
            categorized[cat].sort((a, b) => (a.name || "").localeCompare(b.name || ""))
        }
        
        return categorized
    }

    function getSuggestedApps() {
        const ranking = AppUsageHistoryData.appUsageRanking || {}
        const allApps = AppSearchService.applications || []
        const suggested = []
        
        for (const app of allApps) {
            const appId = app.id || app.desktopId || app.filename
            if (ranking[appId] && ranking[appId] > 0) {
                suggested.push({
                    app: app,
                    usage: ranking[appId]
                })
            }
        }
        
        suggested.sort((a, b) => b.usage - a.usage)
        return suggested.slice(0, appsPerRow).map(item => item.app)
    }

    function getVisibleApps(category, allApps) {
        if (!allApps || allApps.length === 0) {
            return []
        }
        const isExpanded = expandedCategories[category] || false
        if (isExpanded || allApps.length <= appsPerRow) {
            return allApps.slice()
        }
        return allApps.slice(0, appsPerRow)
    }

    function toggleCategory(category) {
        console.warn("[ApplicationsPopout] toggleCategory called for:", category)
        const newExpanded = {}
        for (const key in expandedCategories) {
            newExpanded[key] = expandedCategories[key]
        }
        const currentValue = expandedCategories[category] || false
        newExpanded[category] = !currentValue
        console.warn("[ApplicationsPopout] Setting expandedCategories for", category, "to", newExpanded[category])
        expandedCategories = newExpanded
        _expandedCategoriesVersion++
        console.warn("[ApplicationsPopout] _expandedCategoriesVersion is now:", _expandedCategoriesVersion)
    }

    function launchApp(app) {
        if (!app) return
        SessionService.launchDesktopEntry(app)
        AppUsageHistoryData.addAppUsage(app)
        root.close()
    }

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

    popupWidth: 635
    popupHeight: contentLoader.item ? contentLoader.item.implicitHeight : 600
    triggerX: Screen.width / 2
    triggerY: Theme.barHeight + Theme.spacingM
    triggerWidth: 80
    positioning: "center"
    screen: triggerScreen

    onBackgroundClicked: {
        close()
    }

    onShouldBeVisibleChanged: {
        if (shouldBeVisible) {
            searchQuery = ""
            expandedCategories = {}
            Qt.callLater(() => {
                if (contentLoader.item && contentLoader.item.searchInput) {
                    contentLoader.item.searchInput.text = ""
                    contentLoader.item.searchInput.forceActiveFocus()
                }
            })
        }
    }

    content: Component {
        Item {
            id: mainContainer

            implicitHeight: contentColumn.height + Theme.spacingM * 2
            focus: true

            Component.onCompleted: {
                if (root.shouldBeVisible) {
                    forceActiveFocus()
                }
            }

            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Escape) {
                    root.close()
                    event.accepted = true
                }
            }

            Connections {
                function onShouldBeVisibleChanged() {
                    if (root.shouldBeVisible) {
                        Qt.callLater(function() {
                            mainContainer.forceActiveFocus()
                        })
                    }
                }
                target: root
            }

            Column {
                id: contentColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Theme.spacingL
                spacing: Theme.spacingM

                RowLayout {
                    width: parent.width
                    spacing: Theme.spacingM

                    StyledText {
                        text: "Applications"
                        font.pixelSize: Theme.fontSizeLarge + 4
                        font.weight: Font.Medium
                        color: Theme.surfaceText
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        id: searchField
                        width: 300
                        height: 36
                        radius: Theme.cornerRadius
                        color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                        border.width: 1
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

                        TextInput {
                            id: searchInput
                            anchors.fill: parent
                            anchors.margins: Theme.spacingS
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            focus: true
                            horizontalAlignment: Text.AlignHCenter
                            
                            onTextChanged: {
                                root.searchQuery = text
                            }
                        }

                        StyledText {
                            anchors.fill: parent
                            anchors.margins: Theme.spacingS
                            text: "Search applications..."
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            visible: searchInput.text === ""
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Row {
                        id: viewToggle
                        spacing: Theme.spacingXS
                        Layout.alignment: Qt.AlignVCenter

                        Rectangle {
                            width: 36
                            height: 36
                            radius: Theme.cornerRadius
                            color: root.currentView === "tiled" ? Theme.primary : Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                            border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                            border.width: 1

                            DarkIcon {
                                anchors.centerIn: parent
                                name: "grid_view"
                                size: 18
                                color: root.currentView === "tiled" ? Theme.primaryText : Theme.surfaceText
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: root.currentView = "tiled"
                            }
                        }

                        Rectangle {
                            width: 36
                            height: 36
                            radius: Theme.cornerRadius
                            color: root.currentView === "list" ? Theme.primary : Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                            border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                            border.width: 1

                            DarkIcon {
                                anchors.centerIn: parent
                                name: "view_list"
                                size: 18
                                color: root.currentView === "list" ? Theme.primaryText : Theme.surfaceText
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: root.currentView = "list"
                            }
                        }
                    }
                }

                Item {
                    width: parent.width
                    height: Theme.spacingM
                }

                Flickable {
                    width: parent.width
                    height: 500
                    clip: true
                    contentHeight: appsContent.height
                    boundsBehavior: Flickable.StopAtBounds
                    flickableDirection: Flickable.VerticalFlick
                    interactive: contentHeight > height

                    Column {
                        id: appsContent
                        width: parent.width
                        spacing: Theme.spacingXL

                        Loader {
                            width: parent.width
                            active: root.searchQuery.length === 0 && root.currentView === "tiled"
                            sourceComponent: Component {
                                Column {
                                    width: parent.width
                                    spacing: Theme.spacingM

                                    StyledText {
                                        text: "Suggested"
                                        font.pixelSize: Theme.fontSizeMedium + 2
                                        font.weight: Font.Medium
                                        color: Theme.surfaceText
                                    }

                                    Row {
                                        width: parent.width
                                        spacing: root.iconSpacing

                                        Repeater {
                                            model: root.getSuggestedApps()

                                            Column {
                                                spacing: Theme.spacingXS
                                                width: root.iconSize

                                                Rectangle {
                                                    width: root.iconSize
                                                    height: root.iconSize
                                                    radius: Theme.cornerRadius
                                                    color: suggestedAppArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"
                                                    border.color: suggestedAppArea.containsMouse ? Theme.primary : "transparent"
                                                    border.width: 1

                                                    Item {
                                                        anchors.fill: parent
                                                        anchors.margins: 4
                                                        layer.enabled: SettingsData.systemIconTinting

                                                        Image {
                                                            anchors.fill: parent
                                                            sourceSize.width: parent.width
                                                            sourceSize.height: parent.height
                                                            fillMode: Image.PreserveAspectFit
                                                            source: Quickshell.iconPath(modelData.icon || "application-x-executable", true)
                                                            smooth: true
                                                            asynchronous: true
                                                            visible: status === Image.Ready
                                                        }

                                                        layer.effect: MultiEffect {
                                                            colorization: SettingsData.systemIconTinting ? SettingsData.iconTintIntensity : 0
                                                            colorizationColor: Theme.primary
                                                        }

                                                        Rectangle {
                                                            anchors.fill: parent
                                                            visible: !parent.children[0].visible
                                                            color: Theme.surfaceLight
                                                            radius: Theme.cornerRadius
                                                            border.width: 1
                                                            border.color: Theme.primarySelected

                                                            StyledText {
                                                                anchors.centerIn: parent
                                                                text: (modelData.name && modelData.name.length > 0) ? modelData.name.charAt(0).toUpperCase() : "A"
                                                                font.pixelSize: parent.width * 0.4
                                                                color: Theme.primary
                                                                font.weight: Font.Bold
                                                            }
                                                        }
                                                    }

                                                    MouseArea {
                                                        id: suggestedAppArea
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: root.launchApp(modelData)
                                                    }
                                                }

                                                StyledText {
                                                    width: root.iconSize
                                                    text: modelData.name || "Unknown"
                                                    font.pixelSize: Theme.fontSizeSmall - 1
                                                    color: Theme.surfaceText
                                                    horizontalAlignment: Text.AlignHCenter
                                                    elide: Text.ElideRight
                                                    maximumLineCount: 2
                                                    wrapMode: Text.WordWrap
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Repeater {
                            model: Object.keys(root.getCategorizedApps()).sort()

                            Column {
                                id: categoryColumn
                                width: appsContent.width
                                spacing: Theme.spacingM
                                
                                property string categoryName: modelData
                                property var categoryApps: root.getCategorizedApps()[modelData] || []
                                property int _versionTrigger: root._expandedCategoriesVersion
                                property var visibleApps: root.getVisibleApps(categoryName, categoryApps)
                                
                                on_VersionTriggerChanged: {
                                    visibleApps = root.getVisibleApps(categoryName, categoryApps)
                                }

                                Row {
                                    width: parent.width
                                    spacing: Theme.spacingS

                                    StyledText {
                                        id: categoryLabel
                                        text: modelData
                                        font.pixelSize: Theme.fontSizeMedium + 2
                                        font.weight: Font.Medium
                                        color: Theme.surfaceText
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Item {
                                        width: parent.width - categoryLabel.width - showMoreButton.width - parent.spacing * 2
                                        height: 1
                                    }

                                    Rectangle {
                                        id: showMoreButton
                                        width: showMoreText.implicitWidth + Theme.spacingS * 2
                                        height: showMoreText.implicitHeight + Theme.spacingXS * 2
                                        radius: Theme.cornerRadius
                                        color: showMoreArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"
                                        visible: root.currentView === "tiled" && categoryApps.length > root.appsPerRow

                                        StyledText {
                                            id: showMoreText
                                            anchors.centerIn: parent
                                            text: (root.expandedCategories[categoryColumn.categoryName] || false) ? "Show Less" : "Show More"
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Theme.primary
                                        }

                                        MouseArea {
                                            id: showMoreArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                root.toggleCategory(categoryColumn.categoryName)
                                            }
                                        }
                                    }
                                }

                                Flickable {
                                    width: parent.width
                                    height: root.currentView === "tiled" ? root.iconSize + 40 : Math.min(400, categoryListContent.height)
                                    clip: true
                                    contentWidth: root.currentView === "tiled" ? categoryRow.width : width
                                    contentHeight: root.currentView === "tiled" ? height : categoryListContent.height
                                    flickableDirection: root.currentView === "tiled" ? Flickable.HorizontalFlick : Flickable.VerticalFlick
                                    boundsBehavior: Flickable.StopAtBounds
                                    interactive: root.currentView === "tiled" ? (categoryRow.width > width) : (categoryListContent.height > height)

                                    Row {
                                        id: categoryRow
                                        spacing: root.iconSpacing
                                        visible: root.currentView === "tiled"

                                        Repeater {
                                            model: categoryColumn.visibleApps

                                            Column {
                                                spacing: Theme.spacingXS
                                                width: root.iconSize

                                                Rectangle {
                                                    width: root.iconSize
                                                    height: root.iconSize
                                                    radius: Theme.cornerRadius
                                                    color: appArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"
                                                    border.color: appArea.containsMouse ? Theme.primary : "transparent"
                                                    border.width: 1

                                                    Item {
                                                        anchors.fill: parent
                                                        anchors.margins: 4
                                                        layer.enabled: SettingsData.systemIconTinting

                                                        Image {
                                                            anchors.fill: parent
                                                            sourceSize.width: parent.width
                                                            sourceSize.height: parent.height
                                                            fillMode: Image.PreserveAspectFit
                                                            source: Quickshell.iconPath(modelData.icon || "application-x-executable", true)
                                                            smooth: true
                                                            asynchronous: true
                                                            visible: status === Image.Ready
                                                        }

                                                        layer.effect: MultiEffect {
                                                            colorization: SettingsData.systemIconTinting ? SettingsData.iconTintIntensity : 0
                                                            colorizationColor: Theme.primary
                                                        }

                                                        Rectangle {
                                                            anchors.fill: parent
                                                            visible: !parent.children[0].visible
                                                            color: Theme.surfaceLight
                                                            radius: Theme.cornerRadius
                                                            border.width: 1
                                                            border.color: Theme.primarySelected

                                                            StyledText {
                                                                anchors.centerIn: parent
                                                                text: (modelData.name && modelData.name.length > 0) ? modelData.name.charAt(0).toUpperCase() : "A"
                                                                font.pixelSize: parent.width * 0.4
                                                                color: Theme.primary
                                                                font.weight: Font.Bold
                                                            }
                                                        }
                                                    }

                                                    MouseArea {
                                                        id: appArea
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: root.launchApp(modelData)
                                                    }
                                                }

                                                StyledText {
                                                    width: root.iconSize
                                                    text: modelData.name || "Unknown"
                                                    font.pixelSize: Theme.fontSizeSmall - 1
                                                    color: Theme.surfaceText
                                                    horizontalAlignment: Text.AlignHCenter
                                                    elide: Text.ElideRight
                                                    maximumLineCount: 2
                                                    wrapMode: Text.WordWrap
                                                }
                                            }
                                        }
                                    }

                                    Column {
                                        id: categoryListContent
                                        width: parent.width
                                        spacing: Theme.spacingXS
                                        visible: root.currentView === "list"

                                        Repeater {
                                            model: root.getCategorizedApps()[modelData] || []

                                            Rectangle {
                                                width: categoryListContent.width
                                                height: 56
                                                radius: Theme.cornerRadius
                                                color: listAppArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"
                                                border.color: listAppArea.containsMouse ? Theme.primary : "transparent"
                                                border.width: 1

                                                Row {
                                                    anchors.left: parent.left
                                                    anchors.right: parent.right
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    anchors.margins: Theme.spacingM
                                                    spacing: Theme.spacingM

                                                    Item {
                                                        width: 40
                                                        height: 40
                                                        layer.enabled: SettingsData.systemIconTinting

                                                        Image {
                                                            anchors.fill: parent
                                                            sourceSize.width: 40
                                                            sourceSize.height: 40
                                                            fillMode: Image.PreserveAspectFit
                                                            source: Quickshell.iconPath(modelData.icon || "application-x-executable", true)
                                                            smooth: true
                                                            asynchronous: true
                                                            visible: status === Image.Ready
                                                        }

                                                        layer.effect: MultiEffect {
                                                            colorization: SettingsData.systemIconTinting ? SettingsData.iconTintIntensity : 0
                                                            colorizationColor: Theme.primary
                                                        }

                                                        Rectangle {
                                                            anchors.fill: parent
                                                            visible: !parent.children[0].visible
                                                            color: Theme.surfaceLight
                                                            radius: Theme.cornerRadius
                                                            border.width: 1
                                                            border.color: Theme.primarySelected

                                                            StyledText {
                                                                anchors.centerIn: parent
                                                                text: (modelData.name && modelData.name.length > 0) ? modelData.name.charAt(0).toUpperCase() : "A"
                                                                font.pixelSize: 16
                                                                color: Theme.primary
                                                                font.weight: Font.Bold
                                                            }
                                                        }
                                                    }

                                                    Column {
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        width: parent.width - 40 - Theme.spacingM

                                                        StyledText {
                                                            text: modelData.name || "Unknown"
                                                            font.pixelSize: Theme.fontSizeSmall
                                                            color: Theme.surfaceText
                                                            elide: Text.ElideRight
                                                            width: parent.width
                                                        }

                                                        StyledText {
                                                            text: modelData.comment || ""
                                                            font.pixelSize: Theme.fontSizeSmall - 2
                                                            color: Theme.surfaceVariantText
                                                            elide: Text.ElideRight
                                                            width: parent.width
                                                            visible: modelData.comment && modelData.comment.length > 0
                                                        }
                                                    }
                                                }

                                                MouseArea {
                                                    id: listAppArea
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: root.launchApp(modelData)
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
}
