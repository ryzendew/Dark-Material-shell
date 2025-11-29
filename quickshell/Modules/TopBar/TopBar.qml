import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Services.Notifications
import Quickshell.Services.SystemTray
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Common
import qs.Modules
import qs.Modules.TopBar
import qs.Services
import qs.Widgets

PanelWindow {
    id: root

    WlrLayershell.namespace: "quickshell:bar:blur"
    WlrLayershell.layer: WlrLayershell.Top
    WlrLayershell.exclusionMode: root.shouldBeExclusive ? ExclusionMode.Auto : ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    margins {
        top: (barPosition === "top" || barIsVertical) ? SettingsData.topBarTopMargin : 0
        bottom: barIsVertical ? 0 : (barPosition === "bottom" ? SettingsData.topBarTopMargin : 0)
        left: (barPosition === "left" || !barIsVertical) ? SettingsData.topBarLeftMargin : 0
        right: (barPosition === "right" || !barIsVertical) ? SettingsData.topBarRightMargin : 0
    }

    property var modelData
    property var notepadVariants: null
    property bool gothCornersEnabled: SettingsData.topBarGothCornersEnabled
    property real wingtipsRadius: Theme.cornerRadius
    readonly property real _wingR: Math.max(0, wingtipsRadius)
    readonly property color _bgColor: {
        var baseColor = Theme.surfaceContainer
        return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, topBarCore.backgroundTransparency)
    }
    readonly property color _tintColor: {
        var baseColor = Theme.surfaceTint
        return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, 0.04 * topBarCore.backgroundTransparency)
    }

    signal colorPickerRequested()

    function getNotepadInstanceForScreen() {
        if (!notepadVariants || !notepadVariants.instances) return null

        for (var i = 0; i < notepadVariants.instances.length; i++) {
            var slideout = notepadVariants.instances[i]
            if (slideout.modelData && slideout.modelData.name === root.screen?.name) {
                return slideout
            }
        }
        return null
    }

    function getDarkDashWidget() {
        var sections = [topBarContent.leftSection, topBarContent.centerSection, topBarContent.rightSection]
        for (var s = 0; s < sections.length; s++) {
            var section = sections[s]
            if (!section) continue
            var repeater = section.children[0]
            if (repeater && repeater.count !== undefined) {
                for (var i = 0; i < repeater.count; i++) {
                    var loader = repeater.itemAt(i)
                    if (loader && loader.widgetId === "darkDash" && loader.item) {
                        return loader.item
                    }
                }
            }
        }
        return null
    }
    property string screenName: modelData.name
    readonly property int notificationCount: NotificationService.notifications.length
    readonly property real effectiveBarHeight: SettingsData.topBarHeight
    readonly property real widgetHeight: Math.max(20, 26 + SettingsData.topBarInnerPadding * 0.6)
    
    readonly property string barPosition: SettingsData.topBarPosition || "top"
    readonly property bool barIsVertical: barPosition === "left" || barPosition === "right"

    screen: modelData
    color: "transparent"
    implicitWidth: barIsVertical ? (effectiveBarHeight + SettingsData.topBarSpacing + (SettingsData.topBarGothCornersEnabled ? _wingR : 0)) : 0
    implicitHeight: barIsVertical ? 0 : (effectiveBarHeight + SettingsData.topBarSpacing + (SettingsData.topBarGothCornersEnabled ? _wingR : 0))
    
    Component.onCompleted: {
        const fonts = Qt.fontFamilies()
        if (fonts.indexOf("Material Symbols Rounded") === -1) {
            ToastService.showError("Please install Material Symbols Rounded and Restart your Shell. See README.md for instructions")
        }

        SettingsData.forceTopBarLayoutRefresh.connect(() => {
                                                          Qt.callLater(() => {
                                                                           leftSection.visible = false
                                                                           leftSectionVertical.visible = false
                                                                           centerSection.visible = false
                                                                           centerSectionVertical.visible = false
                                                                           rightSection.visible = false
                                                                           rightSectionVertical.visible = false
                                                                           Qt.callLater(() => {
                                                                                            leftSection.visible = !barIsVertical
                                                                                            leftSectionVertical.visible = barIsVertical
                                                                                            centerSection.visible = !barIsVertical
                                                                                            centerSectionVertical.visible = barIsVertical
                                                                                            rightSection.visible = !barIsVertical
                                                                                            rightSectionVertical.visible = barIsVertical
                                                                                        })
                                                                       })
                                                      })

        updateGpuTempConfig()
        Qt.callLater(() => Qt.callLater(forceWidgetRefresh))
    }
    
    Connections {
        target: SettingsData
        function onTopBarPositionChanged() {
            Qt.callLater(() => {
                leftSection.visible = !barIsVertical
                leftSectionVertical.visible = barIsVertical
                centerSection.visible = !barIsVertical
                centerSectionVertical.visible = barIsVertical
                rightSection.visible = !barIsVertical
                rightSectionVertical.visible = barIsVertical
            })
        }
    }

    function forceWidgetRefresh() {
        const sections = [leftSection, leftSectionVertical, centerSection, centerSectionVertical, rightSection, rightSectionVertical]
        sections.forEach(section => section && (section.visible = false))
        Qt.callLater(() => {
            leftSection.visible = !barIsVertical
            leftSectionVertical.visible = barIsVertical
            centerSection.visible = !barIsVertical
            centerSectionVertical.visible = barIsVertical
            rightSection.visible = !barIsVertical
            rightSectionVertical.visible = barIsVertical
        })
    }

    function updateGpuTempConfig() {
        const allWidgets = [...(SettingsData.topBarLeftWidgets || []), ...(SettingsData.topBarCenterWidgets || []), ...(SettingsData.topBarRightWidgets || [])]

        const hasGpuTempWidget = allWidgets.some(widget => {
                                                     const widgetId = typeof widget === "string" ? widget : widget.id
                                                     const widgetEnabled = typeof widget === "string" ? true : (widget.enabled !== false)
                                                     return widgetId === "gpuTemp" && widgetEnabled
                                                 })

        DgopService.gpuTempEnabled = hasGpuTempWidget || SessionData.nvidiaGpuTempEnabled || SessionData.nonNvidiaGpuTempEnabled
        DgopService.nvidiaGpuTempEnabled = hasGpuTempWidget || SessionData.nvidiaGpuTempEnabled
        DgopService.nonNvidiaGpuTempEnabled = hasGpuTempWidget || SessionData.nonNvidiaGpuTempEnabled
    }

    Connections {
        function onTopBarLeftWidgetsChanged() {
            root.updateGpuTempConfig()
        }

        function onTopBarCenterWidgetsChanged() {
            root.updateGpuTempConfig()
        }

        function onTopBarRightWidgetsChanged() {
            root.updateGpuTempConfig()
        }

        target: SettingsData
    }

    Connections {
        function onNvidiaGpuTempEnabledChanged() {
            root.updateGpuTempConfig()
        }

        function onNonNvidiaGpuTempEnabledChanged() {
            root.updateGpuTempConfig()
        }

        target: SessionData
    }

    Connections {
        target: root.screen
        function onGeometryChanged() {
            if (centerSection?.width > 0) {
                Qt.callLater(centerSection.updateLayout)
            }
        }
    }

    Connections {
        target: Theme
        function onColorUpdateTriggerChanged() {
        }
    }

    anchors {
        top: barPosition === "top" || barIsVertical
        bottom: barPosition === "bottom" || barIsVertical
        left: barPosition === "left" || !barIsVertical
        right: barPosition === "right" || !barIsVertical
    }

    readonly property bool shouldBeExclusive: {
        if (!SettingsData.topBarVisible) {
            return false
        }
        if (SettingsData.topBarFloat && barPosition === "top") {
            return false
        }
        if (barPosition === "top" && SettingsData.topBarAutoHide) {
            return false
        }
        if (barIsVertical || barPosition === "bottom") {
            return true
        }
        return !SettingsData.topBarFloat
    }

    Item {
        id: inputMask
        anchors {
            top: barPosition === "top" || barIsVertical ? parent.top : undefined
            bottom: barPosition === "bottom" || barIsVertical ? parent.bottom : undefined
            left: barPosition === "left" || !barIsVertical ? parent.left : undefined
            right: barPosition === "right" || !barIsVertical ? parent.right : undefined
        }
        width: barIsVertical ? inputMaskSize : undefined
        height: !barIsVertical ? inputMaskSize : undefined
        
        readonly property real inputMaskSize: (SettingsData.topBarAutoHide && topBarCore && !topBarCore.reveal) ? 8 : ((CompositorService.isNiri && NiriService.inOverview && SettingsData.topBarOpenOnOverview) ? (root.effectiveBarHeight + SettingsData.topBarSpacing) : (SettingsData.topBarVisible ? (root.effectiveBarHeight + SettingsData.topBarSpacing) : 0))
    }

    mask: Region {
        item: inputMask
    }


    Item {
        id: topBarCore
        anchors.fill: parent
        property bool autoHide: SettingsData.topBarAutoHide
        property bool revealSticky: false
        property real backgroundTransparency: SettingsData.topBarTransparency

        Timer {
            id: revealHold
            interval: 250
            repeat: false
            onTriggered: topBarCore.revealSticky = false
        }

        property bool reveal: {
            if (CompositorService.isNiri && NiriService.inOverview) {
                return SettingsData.topBarOpenOnOverview
            }
            return SettingsData.topBarVisible && (!autoHide || topBarMouseArea.containsMouse || hasActivePopout || revealSticky)
        }

        property var notepadInstance: null
        property bool notepadInstanceVisible: notepadInstance?.isVisible ?? false
        
        readonly property bool hasActivePopout: {
            const loaders = [{
                                 "loader": appDrawerLoader,
                                 "prop": "shouldBeVisible"
                             }, {
                                 "loader": darkDashLoader,
                                 "prop": "shouldBeVisible"
                             }, {
                                 "loader": processListPopoutLoader,
                                 "prop": "shouldBeVisible"
                             }, {
                                 "loader": notificationCenterLoader,
                                 "prop": "shouldBeVisible"
                             }, {
                                 "loader": batteryPopoutLoader,
                                 "prop": "shouldBeVisible"
                             }, {
                                 "loader": vpnPopoutLoader,
                                 "prop": "shouldBeVisible"
                             }, {
                                 "loader": controlCenterLoader,
                                 "prop": "shouldBeVisible"
                             }, {
                                 "loader": clipboardHistoryModalPopup,
                                 "prop": "visible"
                             }, {
                                 "loader": systemUpdateLoader,
                                 "prop": "shouldBeVisible"
                             }]
            return notepadInstanceVisible || loaders.some(item => {
                if (item.loader) {
                    return item.loader?.item?.[item.prop]
                }
                return false
            })
        }

        Component.onCompleted: {
            notepadInstance = root.getNotepadInstanceForScreen()
        }


        Connections {
            target: topBarMouseArea
            function onContainsMouseChanged() {
                if (topBarMouseArea.containsMouse) {
                    topBarCore.revealSticky = true
                    revealHold.stop()
                } else {
                    if (topBarCore.autoHide && !topBarCore.hasActivePopout) {
                        revealHold.restart()
                    }
                }
            }
        }

        onHasActivePopoutChanged: {
            if (!hasActivePopout && autoHide && !topBarMouseArea.containsMouse) {
                revealSticky = true
                revealHold.restart()
            }
        }

        MouseArea {
            id: topBarMouseArea
            anchors {
                top: barPosition === "top" || barIsVertical ? parent.top : undefined
                bottom: barPosition === "bottom" || barIsVertical ? parent.bottom : undefined
                left: barPosition === "left" || !barIsVertical ? parent.left : undefined
                right: barPosition === "right" || !barIsVertical ? parent.right : undefined
            }
            width: barIsVertical ? (root.effectiveBarHeight + SettingsData.topBarSpacing) : undefined
            height: !barIsVertical ? (root.effectiveBarHeight + SettingsData.topBarSpacing) : undefined
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            enabled: true

            Item {
                id: topBarContainer
                anchors.fill: parent

                transform: Translate {
                    id: topBarSlide
                    x: barIsVertical ? Math.round(topBarCore.reveal ? 0 : (barPosition === "left" ? -(root.effectiveBarHeight + SettingsData.topBarSpacing) : (root.effectiveBarHeight + SettingsData.topBarSpacing))) : 0
                    y: !barIsVertical ? Math.round(topBarCore.reveal ? 0 : (barPosition === "top" ? -(root.effectiveBarHeight + SettingsData.topBarSpacing) : (root.effectiveBarHeight + SettingsData.topBarSpacing))) : 0

                    Behavior on x {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on y {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                Item {
                    anchors.fill: parent
                    anchors.leftMargin: SettingsData.topBarLeftMargin
                    anchors.rightMargin: SettingsData.topBarRightMargin
                    
                    Rectangle {
                        anchors.fill: parent
                        color: root._bgColor
                        radius: SettingsData.topBarSquareCorners ? 0 : (SettingsData.topBarRoundedCorners ? SettingsData.topBarCornerRadius : 0)
                    }
                    
                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        radius: SettingsData.topBarSquareCorners ? 0 : (SettingsData.topBarRoundedCorners ? SettingsData.topBarCornerRadius : 0)
                        border.width: SettingsData.topBarBorderEnabled ? SettingsData.topBarBorderWidth : 0
                        border.color: SettingsData.topBarBorderEnabled ? Qt.rgba(SettingsData.topBarBorderRed, SettingsData.topBarBorderGreen, SettingsData.topBarBorderBlue, SettingsData.topBarBorderAlpha) : "transparent"
                    }
                    
                    Rectangle {
                        anchors.left: (barPosition === "top" || barPosition === "bottom") ? parent.left : (barPosition === "left" ? parent.left : undefined)
                        anchors.right: (barPosition === "top" || barPosition === "bottom") ? parent.right : (barPosition === "right" ? parent.right : undefined)
                        anchors.top: (barPosition === "top" || barPosition === "bottom") ? parent.top : undefined
                        width: barIsVertical && SettingsData.topBarBorderEnabled && SettingsData.topBarBorderTop ? SettingsData.topBarBorderWidth : 0
                        height: !barIsVertical && SettingsData.topBarBorderEnabled && SettingsData.topBarBorderTop ? SettingsData.topBarBorderWidth : 0
                        color: SettingsData.topBarBorderEnabled && SettingsData.topBarBorderTop ? Qt.rgba(SettingsData.topBarBorderRed, SettingsData.topBarBorderGreen, SettingsData.topBarBorderBlue, SettingsData.topBarBorderAlpha) : "transparent"
                    }
                    
                    Rectangle {
                        anchors.left: (barPosition === "top" || barPosition === "bottom") ? parent.left : undefined
                        anchors.top: barIsVertical ? parent.top : ((barPosition === "top" || barPosition === "bottom") ? parent.top : undefined)
                        anchors.bottom: barIsVertical ? parent.bottom : ((barPosition === "top" || barPosition === "bottom") ? parent.bottom : undefined)
                        width: (barPosition === "top" || barPosition === "bottom") && SettingsData.topBarBorderEnabled && SettingsData.topBarBorderLeft ? SettingsData.topBarBorderWidth : 0
                        height: barIsVertical && SettingsData.topBarBorderEnabled && SettingsData.topBarBorderLeft ? SettingsData.topBarBorderWidth : 0
                        color: SettingsData.topBarBorderEnabled && SettingsData.topBarBorderLeft ? Qt.rgba(SettingsData.topBarBorderRed, SettingsData.topBarBorderGreen, SettingsData.topBarBorderBlue, SettingsData.topBarBorderAlpha) : "transparent"
                    }
                    
                    Rectangle {
                        anchors.right: (barPosition === "top" || barPosition === "bottom") ? parent.right : undefined
                        anchors.top: barIsVertical ? parent.top : ((barPosition === "top" || barPosition === "bottom") ? parent.top : undefined)
                        anchors.bottom: barIsVertical ? parent.bottom : ((barPosition === "top" || barPosition === "bottom") ? parent.bottom : undefined)
                        width: (barPosition === "top" || barPosition === "bottom") && SettingsData.topBarBorderEnabled && SettingsData.topBarBorderRight ? SettingsData.topBarBorderWidth : 0
                        height: barIsVertical && SettingsData.topBarBorderEnabled && SettingsData.topBarBorderRight ? SettingsData.topBarBorderWidth : 0
                        color: SettingsData.topBarBorderEnabled && SettingsData.topBarBorderRight ? Qt.rgba(SettingsData.topBarBorderRed, SettingsData.topBarBorderGreen, SettingsData.topBarBorderBlue, SettingsData.topBarBorderAlpha) : "transparent"
                    }
                    
                    Rectangle {
                        anchors.left: (barPosition === "top" || barPosition === "bottom") ? parent.left : (barPosition === "right" ? parent.left : undefined)
                        anchors.right: (barPosition === "top" || barPosition === "bottom") ? parent.right : (barPosition === "left" ? parent.right : undefined)
                        anchors.bottom: (barPosition === "top" || barPosition === "bottom") ? parent.bottom : undefined
                        anchors.leftMargin: (barPosition === "top" || barPosition === "bottom") ? SettingsData.topBarBorderBottomLeftInset : 0
                        anchors.rightMargin: (barPosition === "top" || barPosition === "bottom") ? SettingsData.topBarBorderBottomRightInset : 0
                        width: barIsVertical && SettingsData.topBarBorderEnabled && SettingsData.topBarBorderBottom ? SettingsData.topBarBorderWidth : (barIsVertical && SettingsData.topBarBorderEnabled ? 0 : (barIsVertical ? 1 : 0))
                        height: !barIsVertical && SettingsData.topBarBorderEnabled && SettingsData.topBarBorderBottom ? SettingsData.topBarBorderWidth : (!barIsVertical && SettingsData.topBarBorderEnabled ? 0 : (!barIsVertical ? 1 : 0))
                        color: SettingsData.topBarBorderEnabled && SettingsData.topBarBorderBottom ? Qt.rgba(SettingsData.topBarBorderRed, SettingsData.topBarBorderGreen, SettingsData.topBarBorderBlue, SettingsData.topBarBorderAlpha) : Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.3 * root._bgColor.a)
                    }
                    
                    Item {
                        id: topBarContent
                        anchors.fill: parent
                        anchors.leftMargin: barIsVertical ? (SettingsData.topBarInnerPadding / 2) : Math.max(Theme.spacingXS, SettingsData.topBarInnerPadding * 0.8)
                        anchors.rightMargin: barIsVertical ? (SettingsData.topBarInnerPadding / 2) : Math.max(Theme.spacingXS, SettingsData.topBarInnerPadding * 0.8)
                        anchors.topMargin: barIsVertical ? Math.max(Theme.spacingXS, SettingsData.topBarInnerPadding * 0.8) : (SettingsData.topBarInnerPadding / 2)
                        anchors.bottomMargin: barIsVertical ? Math.max(Theme.spacingXS, SettingsData.topBarInnerPadding * 0.8) : (SettingsData.topBarInnerPadding / 2)
                        clip: true

                    readonly property int availableWidth: barIsVertical ? height : width
                    readonly property int availableHeight: barIsVertical ? width : height
                        readonly property int launcherButtonWidth: 40
                        readonly property int workspaceSwitcherWidth: 120
                        readonly property int focusedAppMaxWidth: 456
                        readonly property int estimatedLeftSectionWidth: launcherButtonWidth + workspaceSwitcherWidth + focusedAppMaxWidth + (Theme.spacingXS * 2)
                        readonly property int rightSectionWidth: rightSection.width
                        readonly property int clockWidth: 120
                        readonly property int mediaMaxWidth: 280
                        readonly property int weatherWidth: 80
                        readonly property bool validLayout: availableWidth > 100 && estimatedLeftSectionWidth > 0 && rightSectionWidth > 0
                        readonly property int clockLeftEdge: (availableWidth - clockWidth) / 2
                        readonly property int clockRightEdge: clockLeftEdge + clockWidth
                        readonly property int leftSectionRightEdge: estimatedLeftSectionWidth
                        readonly property int mediaLeftEdge: clockLeftEdge - mediaMaxWidth - Theme.spacingS
                        readonly property int rightSectionLeftEdge: availableWidth - rightSectionWidth
                        readonly property int leftToClockGap: Math.max(0, clockLeftEdge - leftSectionRightEdge)
                        readonly property int leftToMediaGap: mediaMaxWidth > 0 ? Math.max(0, mediaLeftEdge - leftSectionRightEdge) : leftToClockGap
                        readonly property int mediaToClockGap: mediaMaxWidth > 0 ? Theme.spacingS : 0
                        readonly property int clockToRightGap: validLayout ? Math.max(0, rightSectionLeftEdge - clockRightEdge) : 1000
                        readonly property bool spacingTight: validLayout && (leftToMediaGap < 150 || clockToRightGap < 100)
                        readonly property bool overlapping: validLayout && (leftToMediaGap < 100 || clockToRightGap < 50)

                        function getWidgetEnabled(enabled) {
                            return enabled !== false
                        }

                        function getWidgetSection(parentItem) {
                            if (!parentItem?.parent) {
                                return "left"
                            }
                            if (parentItem.parent === leftSection) {
                                return "left"
                            }
                            if (parentItem.parent === rightSection) {
                                return "right"
                            }
                            if (parentItem.parent === centerSection) {
                                return "center"
                            }
                            return "left"
                        }

                        readonly property var widgetVisibility: ({
                                                                     "cpuUsage": DgopService.dgopAvailable,
                                                                     "memUsage": DgopService.dgopAvailable,
                                                                     "cpuTemp": DgopService.dgopAvailable,
                                                                     "gpuTemp": DgopService.dgopAvailable,
                                                                     "network_speed_monitor": DgopService.dgopAvailable
                                                                 })

                        function getWidgetVisible(widgetId) {
                            return widgetVisibility[widgetId] ?? true
                        }

                        readonly property var componentMap: ({
                                                                 "launcherButton": launcherButtonComponent,
                                                                 "workspaceSwitcher": workspaceSwitcherComponent,
                                                                 "focusedWindow": focusedWindowComponent,
                                                                 "runningApps": runningAppsComponent,
                                                                 "clock": clockComponent,
                                                                 "music": mediaComponent,
                                                                 "weather": weatherComponent,
                                                                 "darkDash": darkDashComponent,
                                                                 "applications": applicationsComponent,
                                                                 "systemTray": systemTrayComponent,
                                                                 "privacyIndicator": privacyIndicatorComponent,
                                                                 "clipboard": clipboardComponent,
                                                                 "cpuUsage": cpuUsageComponent,
                                                                 "memUsage": memUsageComponent,
                                                                 "cpuTemp": cpuTempComponent,
                                                                 "gpuTemp": gpuTempComponent,
                                                                 "notificationButton": notificationButtonComponent,
                                                                 "battery": batteryComponent,
                                                                 "controlCenterButton": controlCenterButtonComponent,
                                                                 "idleInhibitor": idleInhibitorComponent,
                                                                 "spacer": spacerComponent,
                                                                 "separator": separatorComponent,
                                                                 "network_speed_monitor": networkComponent,
                                                                 "keyboard_layout_name": keyboardLayoutNameComponent,
                                                                 "vpn": vpnComponent,
                                                                 "notepadButton": notepadButtonComponent,
                                                                 "colorPicker": colorPickerComponent,
                                                                 "systemUpdate": systemUpdateComponent
                                                             })

                        function getWidgetComponent(widgetId) {
                            return componentMap[widgetId] || null
                        }

                        Row {
                            id: leftSection
                            visible: !barIsVertical
                            height: parent.height
                            spacing: SettingsData.topBarNoBackground ? 2 : Theme.spacingXS
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter

                            Repeater {
                                model: SettingsData.topBarLeftWidgetsModel

                                Loader {
                                    property string widgetId: model.widgetId
                                    property var widgetData: model
                                    property int spacerSize: model.size || 20

                                    anchors.verticalCenter: parent ? parent.verticalCenter : undefined
                                    active: leftSection.visible && topBarContent.getWidgetVisible(model.widgetId) && (model.widgetId !== "music" || MprisController.activePlayer !== null)
                                    sourceComponent: topBarContent.getWidgetComponent(model.widgetId)
                                    opacity: topBarContent.getWidgetEnabled(model.enabled) ? 1 : 0
                                    asynchronous: false
                                }
                            }
                        }
                        
                        Column {
                            id: leftSectionVertical
                            visible: barIsVertical
                            width: parent.width
                            spacing: SettingsData.topBarNoBackground ? 2 : Theme.spacingXS
                            anchors.top: parent.top
                            anchors.horizontalCenter: parent.horizontalCenter

                            Repeater {
                                model: SettingsData.topBarLeftWidgetsModel

                                Loader {
                                    property string widgetId: model.widgetId
                                    property var widgetData: model
                                    property int spacerSize: model.size || 20

                                    anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
                                    active: leftSectionVertical.visible && topBarContent.getWidgetVisible(model.widgetId) && (model.widgetId !== "music" || MprisController.activePlayer !== null)
                                    sourceComponent: topBarContent.getWidgetComponent(model.widgetId)
                                    opacity: topBarContent.getWidgetEnabled(model.enabled) ? 1 : 0
                                    asynchronous: false
                                }
                            }
                        }

                        Item {
                            id: centerSection
                            visible: !barIsVertical
                            property var centerWidgets: []
                            property int totalWidgets: 0
                            property real totalWidth: 0
                            property real spacing: SettingsData.topBarNoBackground ? 2 : Theme.spacingXS
                            
                            width: childrenRect.width
                            height: parent.height
                            anchors.centerIn: parent

                            function updateLayout() {
                                if (width <= 0 || height <= 0 || !visible) {
                                    Qt.callLater(updateLayout)
                                    return
                                }

                                centerWidgets = []
                                totalWidgets = 0
                                totalWidth = 0

                                let configuredWidgets = 0
                                for (var i = 0; i < centerRepeater.count; i++) {
                                    const item = centerRepeater.itemAt(i)
                                    if (item && topBarContent.getWidgetVisible(item.widgetId)) {
                                        configuredWidgets++
                                        if (item.active && item.item) {
                                            centerWidgets.push(item.item)
                                            totalWidgets++
                                            totalWidth += item.item.width
                                        }
                                    }
                                }

                                if (totalWidgets > 1) {
                                    totalWidth += spacing * (totalWidgets - 1)
                                }
                                positionWidgets(configuredWidgets)
                            }

                            function positionWidgets(configuredWidgets) {
                                if (totalWidgets === 0 || width <= 0) {
                                    return
                                }

                                const parentCenterX = width / 2
                                const isOdd = configuredWidgets % 2 === 1

                                centerWidgets.forEach(widget => widget.anchors.horizontalCenter = undefined)

                                if (isOdd) {
                                    const middleIndex = Math.floor(configuredWidgets / 2)
                                    let currentActiveIndex = 0
                                    let middleWidget = null

                                    for (var i = 0; i < centerRepeater.count; i++) {
                                        const item = centerRepeater.itemAt(i)
                                        if (item && topBarContent.getWidgetVisible(item.widgetId)) {
                                            if (currentActiveIndex === middleIndex && item.active && item.item) {
                                                middleWidget = item.item
                                                break
                                            }
                                            currentActiveIndex++
                                        }
                                    }

                                    if (middleWidget) {
                                        middleWidget.x = parentCenterX - (middleWidget.width / 2)

                                        let leftWidgets = []
                                        let rightWidgets = []
                                        let foundMiddle = false

                                        for (var i = 0; i < centerWidgets.length; i++) {
                                            if (centerWidgets[i] === middleWidget) {
                                                foundMiddle = true
                                                continue
                                            }
                                            if (!foundMiddle) {
                                                leftWidgets.push(centerWidgets[i])
                                            } else {
                                                rightWidgets.push(centerWidgets[i])
                                            }
                                        }

                                        let currentX = middleWidget.x
                                        for (var i = leftWidgets.length - 1; i >= 0; i--) {
                                            currentX -= (spacing + leftWidgets[i].width)
                                            leftWidgets[i].x = currentX
                                        }

                                        currentX = middleWidget.x + middleWidget.width
                                        for (var i = 0; i < rightWidgets.length; i++) {
                                            currentX += spacing
                                            rightWidgets[i].x = currentX
                                            currentX += rightWidgets[i].width
                                        }
                                    }
                                } else {
                                    let configuredLeftIndex = (configuredWidgets / 2) - 1
                                    let configuredRightIndex = configuredWidgets / 2
                                    const halfSpacing = spacing / 2

                                    let leftWidget = null
                                    let rightWidget = null
                                    let leftWidgets = []
                                    let rightWidgets = []

                                    let currentConfigIndex = 0
                                    for (var i = 0; i < centerRepeater.count; i++) {
                                        const item = centerRepeater.itemAt(i)
                                        if (item && topBarContent.getWidgetVisible(item.widgetId)) {
                                            if (item.active && item.item) {
                                                if (currentConfigIndex < configuredLeftIndex) {
                                                    leftWidgets.push(item.item)
                                                } else if (currentConfigIndex === configuredLeftIndex) {
                                                    leftWidget = item.item
                                                } else if (currentConfigIndex === configuredRightIndex) {
                                                    rightWidget = item.item
                                                } else {
                                                    rightWidgets.push(item.item)
                                                }
                                            }
                                            currentConfigIndex++
                                        }
                                    }

                                    if (leftWidget && rightWidget) {
                                        leftWidget.x = parentCenterX - halfSpacing - leftWidget.width
                                        rightWidget.x = parentCenterX + halfSpacing

                                        let currentX = leftWidget.x
                                        for (var i = leftWidgets.length - 1; i >= 0; i--) {
                                            currentX -= (spacing + leftWidgets[i].width)
                                            leftWidgets[i].x = currentX
                                        }

                                        currentX = rightWidget.x + rightWidget.width
                                        for (var i = 0; i < rightWidgets.length; i++) {
                                            currentX += spacing
                                            rightWidgets[i].x = currentX
                                            currentX += rightWidgets[i].width
                                        }
                                    } else if (leftWidget && !rightWidget) {
                                        leftWidget.x = parentCenterX - halfSpacing - leftWidget.width

                                        let currentX = leftWidget.x
                                        for (var i = leftWidgets.length - 1; i >= 0; i--) {
                                            currentX -= (spacing + leftWidgets[i].width)
                                            leftWidgets[i].x = currentX
                                        }

                                        currentX = leftWidget.x + leftWidget.width + spacing
                                        for (var i = 0; i < rightWidgets.length; i++) {
                                            currentX += spacing
                                            rightWidgets[i].x = currentX
                                            currentX += rightWidgets[i].width
                                        }
                                    } else if (!leftWidget && rightWidget) {
                                        rightWidget.x = parentCenterX + halfSpacing

                                        let currentX = rightWidget.x - spacing
                                        for (var i = leftWidgets.length - 1; i >= 0; i--) {
                                            currentX -= leftWidgets[i].width
                                            leftWidgets[i].x = currentX
                                            currentX -= spacing
                                        }

                                        currentX = rightWidget.x + rightWidget.width
                                        for (var i = 0; i < rightWidgets.length; i++) {
                                            currentX += spacing
                                            rightWidgets[i].x = currentX
                                            currentX += rightWidgets[i].width
                                        }
                                    } else if (totalWidgets === 1 && centerWidgets[0]) {
                                        centerWidgets[0].x = parentCenterX - (centerWidgets[0].width / 2)
                                    }
                                }
                            }

                            Component.onCompleted: {
                                Qt.callLater(() => {
                                                 Qt.callLater(updateLayout)
                                             })
                            }

                            onWidthChanged: {
                                if (width > 0) {
                                    Qt.callLater(updateLayout)
                                }
                            }

                            onVisibleChanged: {
                                if (visible && width > 0) {
                                    Qt.callLater(updateLayout)
                                }
                            }

                            Repeater {
                                id: centerRepeater

                                model: SettingsData.topBarCenterWidgetsModel

                                Loader {
                                    property string widgetId: model.widgetId
                                    property var widgetData: model
                                    property int spacerSize: model.size || 20

                                    anchors.verticalCenter: parent ? parent.verticalCenter : undefined
                                    active: centerSection.visible && topBarContent.getWidgetVisible(model.widgetId) && (model.widgetId !== "music" || MprisController.activePlayer !== null)
                                    sourceComponent: topBarContent.getWidgetComponent(model.widgetId)
                                    opacity: topBarContent.getWidgetEnabled(model.enabled) ? 1 : 0
                                    asynchronous: false

                                    onLoaded: {
                                        if (!item) {
                                            return
                                        }
                                        item.onWidthChanged.connect(centerSection.updateLayout)
                                        if (model.widgetId === "spacer") {
                                            item.spacerSize = Qt.binding(() => model.size || 20)
                                        }
                                        Qt.callLater(centerSection.updateLayout)
                                    }
                                    onActiveChanged: {
                                        Qt.callLater(centerSection.updateLayout)
                                    }
                                }
                            }

                            Connections {
                                function onCountChanged() {
                                    Qt.callLater(centerSection.updateLayout)
                                }

                                target: SettingsData.topBarCenterWidgetsModel
                            }
                        }
                        
                        Item {
                            id: centerSectionVertical
                            visible: barIsVertical
                            width: parent.width
                            height: childrenRect.height
                            anchors.centerIn: parent
                            
                            Column {
                                anchors.centerIn: parent
                                spacing: SettingsData.topBarNoBackground ? 2 : Theme.spacingXS
                                
                                Repeater {
                                    model: SettingsData.topBarCenterWidgetsModel

                                    Loader {
                                        property string widgetId: model.widgetId
                                        property var widgetData: model
                                        property int spacerSize: model.size || 20

                                        anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
                                        active: centerSectionVertical.visible && topBarContent.getWidgetVisible(model.widgetId) && (model.widgetId !== "music" || MprisController.activePlayer !== null)
                                        sourceComponent: topBarContent.getWidgetComponent(model.widgetId)
                                        opacity: topBarContent.getWidgetEnabled(model.enabled) ? 1 : 0
                                        asynchronous: false
                                    }
                                }
                            }
                        }

                        Row {
                            id: rightSection
                            visible: !barIsVertical
                            height: parent.height
                            spacing: SettingsData.topBarNoBackground ? 2 : Theme.spacingXS
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter

                            Repeater {
                                model: SettingsData.topBarRightWidgetsModel

                                Loader {
                                    property string widgetId: model.widgetId
                                    property var widgetData: model
                                    property int spacerSize: model.size || 20

                                    anchors.verticalCenter: parent ? parent.verticalCenter : undefined
                                    active: rightSection.visible && topBarContent.getWidgetVisible(model.widgetId) && (model.widgetId !== "music" || MprisController.activePlayer !== null)
                                    sourceComponent: topBarContent.getWidgetComponent(model.widgetId)
                                    opacity: topBarContent.getWidgetEnabled(model.enabled) ? 1 : 0
                                    asynchronous: false
                                }
                            }
                        }
                        
                        Column {
                            id: rightSectionVertical
                            visible: barIsVertical
                            width: parent.width
                            spacing: SettingsData.topBarNoBackground ? 2 : Theme.spacingXS
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter

                            Repeater {
                                model: SettingsData.topBarRightWidgetsModel

                                Loader {
                                    property string widgetId: model.widgetId
                                    property var widgetData: model
                                    property int spacerSize: model.size || 20

                                    anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
                                    active: rightSectionVertical.visible && topBarContent.getWidgetVisible(model.widgetId) && (model.widgetId !== "music" || MprisController.activePlayer !== null)
                                    sourceComponent: topBarContent.getWidgetComponent(model.widgetId)
                                    opacity: topBarContent.getWidgetEnabled(model.enabled) ? 1 : 0
                                    asynchronous: false
                                }
                            }
                        }

                        Component {
                            id: clipboardComponent

                            Rectangle {
                                readonly property real horizontalPadding: SettingsData.topBarNoBackground ? 0 : Math.max(Theme.spacingXS, Theme.spacingS * (root.widgetHeight / 30))
                                width: clipboardIcon.width + horizontalPadding * 2
                                height: root.widgetHeight
                                radius: SettingsData.topBarNoBackground ? 0 : Theme.cornerRadius
                                color: {
                                    if (SettingsData.topBarNoBackground) {
                                        return "transparent"
                                    }
                                    const baseColor = clipboardArea.containsMouse ? Theme.widgetBaseHoverColor : Theme.widgetBaseBackgroundColor
                                    return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, baseColor.a * Theme.widgetTransparency)
                                }

                                DarkIcon {
                                    id: clipboardIcon
                                    anchors.centerIn: parent
                                    name: "content_paste"
                                    size: Theme.iconSize - 10
                                    color: Theme.surfaceText
                                }

                                MouseArea {
                                    id: clipboardArea

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        clipboardHistoryModalPopup.toggle()
                                    }
                                }

                            }
                        }

                        Component {
                            id: launcherButtonComponent

                            LauncherButton {
                                isActive: false
                                widgetHeight: root.widgetHeight
                                barHeight: root.effectiveBarHeight
                                section: topBarContent.getWidgetSection(parent)
                                popupTarget: appDrawerLoader.item
                                parentScreen: root.screen
                                onClicked: {
                                    appDrawerLoader.active = true
                                    appDrawerLoader.item?.toggle()
                                }
                            }
                        }

                        Component {
                            id: workspaceSwitcherComponent

                            WorkspaceSwitcher {
                                screenName: root.screenName
                                widgetHeight: root.widgetHeight
                            }
                        }

                        Component {
                            id: focusedWindowComponent

                            FocusedApp {
                                availableWidth: topBarContent.leftToMediaGap
                                widgetHeight: root.widgetHeight
                            }
                        }

                        Component {
                            id: runningAppsComponent

                            RunningApps {
                                widgetHeight: root.widgetHeight
                                section: topBarContent.getWidgetSection(parent)
                                parentScreen: root.screen
                                topBar: topBarContent
                            }
                        }

                        Component {
                            id: clockComponent

                            Clock {
                                compactMode: topBarContent.overlapping
                                barHeight: root.effectiveBarHeight
                                widgetHeight: root.widgetHeight
                                section: topBarContent.getWidgetSection(parent) || "center"
                                parentScreen: root.screen
                            }
                        }

                        Component {
                            id: mediaComponent

                            Media {
                                compactMode: topBarContent.spacingTight || topBarContent.overlapping
                                barHeight: root.effectiveBarHeight
                                widgetHeight: root.widgetHeight
                                section: topBarContent.getWidgetSection(parent) || "center"
                                parentScreen: root.screen
                            }
                        }

                        Component {
                            id: weatherComponent

                            Weather {
                                barHeight: root.effectiveBarHeight
                                widgetHeight: root.widgetHeight
                                section: topBarContent.getWidgetSection(parent) || "center"
                                parentScreen: root.screen
                            }
                        }

                        Component {
                            id: darkDashComponent

                            DarkDash {
                                barHeight: root.effectiveBarHeight
                                widgetHeight: root.widgetHeight
                                section: topBarContent.getWidgetSection(parent) || "center"
                                parentScreen: root.screen
                            }
                        }

                        Component {
                            id: applicationsComponent

                            Applications {
                                barHeight: root.effectiveBarHeight
                                widgetHeight: root.widgetHeight
                                section: topBarContent.getWidgetSection(parent) || "center"
                                parentScreen: root.screen
                            }
                        }

                        Component {
                            id: systemTrayComponent

                            SystemTrayBar {
                                parentWindow: root
                                parentScreen: root.screen
                                widgetHeight: root.widgetHeight
                                visible: SettingsData.getFilteredScreens("systemTray").includes(root.screen)
                            }
                        }

                        Component {
                            id: privacyIndicatorComponent

                            PrivacyIndicator {
                                widgetHeight: root.widgetHeight
                                section: topBarContent.getWidgetSection(parent) || "right"
                                parentScreen: root.screen
                            }
                        }

                        Component {
                            id: cpuUsageComponent

                            CpuMonitor {
                                barHeight: root.effectiveBarHeight
                                widgetHeight: root.widgetHeight
                                section: topBarContent.getWidgetSection(parent) || "right"
                                popupTarget: {
                                    processListPopoutLoader.active = true
                                    return processListPopoutLoader.item
                                }
                                parentScreen: root.screen
                                toggleProcessList: () => {
                                                       processListPopoutLoader.active = true
                                                       return processListPopoutLoader.item?.toggle()
                                                   }
                            }
                        }

                        Component {
                            id: memUsageComponent

                            RamMonitor {
                                barHeight: root.effectiveBarHeight
                                widgetHeight: root.widgetHeight
                                section: topBarContent.getWidgetSection(parent) || "right"
                                popupTarget: {
                                    processListPopoutLoader.active = true
                                    return processListPopoutLoader.item
                                }
                                parentScreen: root.screen
                                toggleProcessList: () => {
                                                       processListPopoutLoader.active = true
                                                       return processListPopoutLoader.item?.toggle()
                                                   }
                            }
                        }

                        Component {
                            id: cpuTempComponent

                            CpuTemperature {
                                barHeight: root.effectiveBarHeight
                                widgetHeight: root.widgetHeight
                                section: topBarContent.getWidgetSection(parent) || "right"
                                popupTarget: {
                                    processListPopoutLoader.active = true
                                    return processListPopoutLoader.item
                                }
                                parentScreen: root.screen
                                toggleProcessList: () => {
                                                       processListPopoutLoader.active = true
                                                       return processListPopoutLoader.item?.toggle()
                                                   }
                            }
                        }

                        Component {
                            id: gpuTempComponent

                            GpuTemperature {
                                barHeight: root.effectiveBarHeight
                                widgetHeight: root.widgetHeight
                                section: topBarContent.getWidgetSection(parent) || "right"
                                popupTarget: {
                                    processListPopoutLoader.active = true
                                    return processListPopoutLoader.item
                                }
                                parentScreen: root.screen
                                widgetData: parent.widgetData
                                toggleProcessList: () => {
                                                       processListPopoutLoader.active = true
                                                       return processListPopoutLoader.item?.toggle()
                                                   }
                            }
                        }

                        Component {
                            id: networkComponent

                            NetworkMonitor {}
                        }

                        Component {
                            id: notificationButtonComponent

                            NotificationCenterButton {
                                hasUnread: root.notificationCount > 0
                                isActive: notificationCenterLoader.item ? notificationCenterLoader.item.shouldBeVisible : false
                                widgetHeight: root.widgetHeight
                                barHeight: root.effectiveBarHeight
                                section: topBarContent.getWidgetSection(parent) || "right"
                                popupTarget: {
                                    notificationCenterLoader.active = true
                                    return notificationCenterLoader.item
                                }
                                parentScreen: root.screen
                                onClicked: {
                                    notificationCenterLoader.active = true
                                    notificationCenterLoader.item?.toggle()
                                }
                            }
                        }

                        Component {
                            id: batteryComponent

                            Battery {
                                batteryPopupVisible: batteryPopoutLoader.item ? batteryPopoutLoader.item.shouldBeVisible : false
                                widgetHeight: root.widgetHeight
                                barHeight: root.effectiveBarHeight
                                section: topBarContent.getWidgetSection(parent) || "right"
                                popupTarget: {
                                    batteryPopoutLoader.active = true
                                    return batteryPopoutLoader.item
                                }
                                parentScreen: root.screen
                                onToggleBatteryPopup: {
                                    batteryPopoutLoader.active = true
                                    batteryPopoutLoader.item?.toggle()
                                }
                            }
                        }

                        Component {
                            id: vpnComponent

                            Vpn {
                                widgetHeight: root.widgetHeight
                                barHeight: root.effectiveBarHeight
                                section: topBarContent.getWidgetSection(parent) || "right"
                                popupTarget: {
                                    vpnPopoutLoader.active = true
                                    return vpnPopoutLoader.item
                                }
                                parentScreen: root.screen
                                onToggleVpnPopup: {
                                    vpnPopoutLoader.active = true
                                    vpnPopoutLoader.item?.toggle()
                                }
                            }
                        }

                        Component {
                            id: controlCenterButtonComponent

                            ControlCenterButton {
                                isActive: controlCenterLoader.item ? controlCenterLoader.item.shouldBeVisible : false
                                widgetHeight: root.widgetHeight
                                barHeight: root.effectiveBarHeight
                                section: topBarContent.getWidgetSection(parent) || "right"
                                popupTarget: {
                                    controlCenterLoader.active = true
                                    return controlCenterLoader.item
                                }
                                parentScreen: root.screen
                                widgetData: parent.widgetData
                                onClicked: {
                                    controlCenterLoader.active = true
                                    if (!controlCenterLoader.item) {
                                        return
                                    }
                                    controlCenterLoader.item.triggerScreen = root.screen
                                    controlCenterLoader.item.toggle()
                                    if (controlCenterLoader.item.shouldBeVisible && NetworkService.wifiEnabled) {
                                        NetworkService.scanWifi()
                                    }
                                }
                            }
                        }

                        Component {
                            id: idleInhibitorComponent

                            IdleInhibitor {
                                widgetHeight: root.widgetHeight
                                section: topBarContent.getWidgetSection(parent) || "right"
                                parentScreen: root.screen
                            }
                        }

                        Component {
                            id: spacerComponent

                            Item {
                                width: parent.spacerSize || 20
                                height: root.widgetHeight

                                Rectangle {
                                    anchors.fill: parent
                                    color: "transparent"
                                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.1)
                                    border.width: 1
                                    radius: 2
                                    visible: false

                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onEntered: parent.visible = true
                                        onExited: parent.visible = false
                                    }
                                }
                            }
                        }

                        Component {
                            id: separatorComponent

                            Rectangle {
                                width: 1
                                height: root.widgetHeight * 0.67
                                color: Theme.outline
                                opacity: 0.3
                            }
                        }

                        Component {
                            id: keyboardLayoutNameComponent

                            KeyboardLayoutName {}
                        }

                        Component {
                            id: notepadButtonComponent

                            NotepadButton {
                                property var notepadInstance: topBarCore.notepadInstance
                                isActive: notepadInstance?.isVisible ?? false
                                widgetHeight: root.widgetHeight
                                barHeight: root.effectiveBarHeight
                                section: topBarContent.getWidgetSection(parent) || "right"
                                popupTarget: notepadInstance
                                parentScreen: root.screen
                                onClicked: {
                                    if (notepadInstance) {
                                        notepadInstance.toggle()
                                    }
                                }
                            }
                        }

                        Component {
                            id: colorPickerComponent

                            ColorPicker {
                                widgetHeight: root.widgetHeight
                                barHeight: root.effectiveBarHeight
                                section: topBarContent.getWidgetSection(parent) || "right"
                                parentScreen: root.screen
                                onColorPickerRequested: {
                                    root.colorPickerRequested()
                                }
                            }
                        }

                        Component {
                            id: systemUpdateComponent

                            SystemUpdate {
                                isActive: systemUpdateLoader.item ? systemUpdateLoader.item.shouldBeVisible : false
                                widgetHeight: root.widgetHeight
                                barHeight: root.effectiveBarHeight
                                section: topBarContent.getWidgetSection(parent) || "right"
                                popupTarget: {
                                    systemUpdateLoader.active = true
                                    return systemUpdateLoader.item
                                }
                                parentScreen: root.screen
                                onClicked: {
                                    systemUpdateLoader.active = true
                                    systemUpdateLoader.item?.toggle()
                                }
                            }
                        }
                    }
                }
                }
            }
        }


}
