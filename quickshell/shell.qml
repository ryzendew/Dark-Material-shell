//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Hyprland
import qs.Common
import qs.Modals
import qs.Modals.Clipboard
import qs.Modals.Common
import qs.Modals.Settings
import qs.Modals.Spotlight
import qs.Modules
import qs.Modules.AppDrawer
import qs.Modules.DankDash
import qs.Modules.ControlCenter
import qs.Modules.Dock
import qs.Modules.Lock
import qs.Modules.Notifications.Center
import qs.Widgets
import "./Modules/Notepad"
import qs.Modules.Notifications.Popup
import qs.Modules.OSD
import qs.Modules.ProcessList
import qs.Modules.Settings
import qs.Modules.TopBar
import qs.Modules.Desktop
import qs.Services

ShellRoot {
    id: root

    Component.onCompleted: {
        PortalService.init()
        // Initialize DisplayService night mode functionality
        DisplayService.nightModeEnabled
        // Initialize WallpaperCyclingService
        WallpaperCyclingService.cyclingActive
        // Initialize ColorPaletteService
        ColorPaletteService.extractedColors
    }

    // Force refresh entire shell when custom theme is created
    Connections {
        target: ColorPaletteService
        function onCustomThemeCreated(themeData) {
            // Force refresh all UI components
            Qt.callLater(() => {
                // The visibility toggles in TopBar and Dock should handle the refresh
            })
        }
    }

    WallpaperBackground {}


    // Desktop Widgets
    Variants {
        model: SettingsData.getFilteredScreens("desktopWidgets")

        delegate: Item {
            property var modelData: item
            property string screenName: modelData ? modelData.name : ""


            // Desktop widget settings - controlled by SettingsData
            property bool showCpuTemp: SettingsData.desktopWidgetsEnabled && SettingsData.desktopCpuTempEnabled
            property bool showGpuTemp: SettingsData.desktopWidgetsEnabled && SettingsData.desktopGpuTempEnabled
            property bool showSystemMonitor: SettingsData.desktopWidgetsEnabled && SettingsData.desktopSystemMonitorEnabled
            property bool showClock: SettingsData.desktopWidgetsEnabled && SettingsData.desktopClockEnabled
            property bool showWeather: SettingsData.desktopWidgetsEnabled && SettingsData.desktopWeatherEnabled
            property bool showTerminal: SettingsData.desktopWidgetsEnabled && SettingsData.desktopTerminalEnabled

            // Desktop positioning system
            DesktopPositioning {
                id: positioning
                screen: modelData
            }



            // CPU Temperature Widget
            Loader {
                id: cpuTempLoader
                visible: parent.showCpuTemp
                source: "Modules/Desktop/DesktopCpuTempWidget.qml"
                onLoaded: {
                    item.alwaysVisible = parent.showCpuTemp
                    item.screen = parent.modelData
                    item.position = SettingsData.desktopCpuTempPosition
                    item.positioningBox = positioning.getPositionBox(SettingsData.desktopCpuTempPosition)
                }
            }

            // GPU Temperature Widget
            Loader {
                id: gpuTempLoader
                visible: parent.showGpuTemp
                source: "Modules/Desktop/DesktopGpuTempWidget.qml"
                onLoaded: {
                    item.alwaysVisible = parent.showGpuTemp
                    item.screen = parent.modelData
                    item.position = SettingsData.desktopGpuTempPosition
                    item.positioningBox = positioning.getPositionBox(SettingsData.desktopGpuTempPosition)
                }
            }

            // System Monitor Widget
            Loader {
                id: systemMonitorLoader
                visible: parent.showSystemMonitor
                source: "Modules/Desktop/DesktopSystemMonitorWidget.qml"
                onLoaded: {
                    item.alwaysVisible = parent.showSystemMonitor
                    item.screen = parent.modelData
                    item.position = SettingsData.desktopSystemMonitorPosition
                    item.positioningBox = positioning.getPositionBox(SettingsData.desktopSystemMonitorPosition)
                }
            }

            // Desktop Clock Widget
            Loader {
                id: clockLoader
                visible: parent.showClock
                source: "Modules/Desktop/DesktopClockWidget.qml"
                onLoaded: {
                    item.alwaysVisible = parent.showClock
                    item.screen = parent.modelData
                    item.position = SettingsData.desktopClockPosition
                    item.positioningBox = positioning.getPositionBox(SettingsData.desktopClockPosition)
                }
            }

            // Desktop Weather Widget
            Loader {
                id: weatherLoader
                visible: parent.showWeather
                source: "Modules/Desktop/DesktopWeatherWidget.qml"
                onLoaded: {
                    item.screen = parent.modelData
                    item.position = SettingsData.desktopWeatherPosition
                    item.positioningBox = positioning.getPositionBox(SettingsData.desktopWeatherPosition)
                }
            }

            // Desktop Terminal Widget
            Loader {
                id: terminalLoader
                visible: parent.showTerminal
                source: "Modules/Desktop/DesktopTerminalWidget.qml"
                onLoaded: {
                    item.alwaysVisible = parent.showTerminal
                    item.screen = parent.modelData
                    item.position = SettingsData.desktopTerminalPosition
                    item.positioningBox = positioning.getPositionBox(SettingsData.desktopTerminalPosition)
                }
            }
        }
    }

    Lock {
        id: lock

        anchors.fill: parent
    }

    // TopBar enabled
    Variants {
        model: SettingsData.getFilteredScreens("topBar")

        delegate: TopBar {
            modelData: item
            notepadVariants: notepadSlideoutVariants
            onColorPickerRequested: colorPickerModal.show()
        }
    }

    // Simple Bar disabled
    // Variants {
    //     model: SettingsData.getFilteredScreens("topBar")

    //     delegate: Bar {
    //         modelData: item
    //     }
    // }

    Variants {
        model: SettingsData.getFilteredScreens("dock")
        
        Component.onCompleted: {
            // Dock variants completed
        }

        delegate: Dock {
            modelData: item
            contextMenu: dockContextMenuLoader.item ? dockContextMenuLoader.item : null
            Component.onCompleted: {
                dockContextMenuLoader.active = true
            }
        }
    }

    Loader {
        id: dankDashPopoutLoader

        active: false
        asynchronous: true

        sourceComponent: Component {
            DankDashPopout {
                id: dankDashPopout
            }
        }
    }

    LazyLoader {
        id: dockContextMenuLoader

        active: false

        DockContextMenu {
            id: dockContextMenu
        }
    }

    LazyLoader {
        id: notificationCenterLoader

        active: false

        NotificationCenterPopout {
            id: notificationCenter
        }
    }

    Variants {
        model: SettingsData.getFilteredScreens("notifications")

        delegate: NotificationPopupManager {
            modelData: item
        }
    }

    LazyLoader {
        id: controlCenterLoader

        active: false

        ControlCenterPopout {
            id: controlCenterPopout

            onPowerActionRequested: (action, title, message) => {
                                        powerConfirmModalLoader.active = true
                                        if (powerConfirmModalLoader.item) {
                                            powerConfirmModalLoader.item.confirmButtonColor = action === "poweroff" ? Theme.error : action === "reboot" ? Theme.warning : Theme.primary
                                            powerConfirmModalLoader.item.show(title, message, function () {
                                                switch (action) {
                                                case "logout":
                                                    SessionService.logout()
                                                    break
                                                case "suspend":
                                                    SessionService.suspend()
                                                    break
                                                case "reboot":
                                                    SessionService.reboot()
                                                    break
                                                case "poweroff":
                                                    SessionService.poweroff()
                                                    break
                                                }
                                            }, function () {})
                                        }
                                    }
            onLockRequested: {
                lock.activate()
            }
        }
    }

    LazyLoader {
        id: wifiPasswordModalLoader

        active: false

        WifiPasswordModal {
            id: wifiPasswordModal
        }
    }

    LazyLoader {
        id: networkInfoModalLoader

        active: false

        NetworkInfoModal {
            id: networkInfoModal
        }
    }

    LazyLoader {
        id: batteryPopoutLoader

        active: false

        BatteryPopout {
            id: batteryPopout
        }
    }

    LazyLoader {
        id: vpnPopoutLoader

        active: false

        VpnPopout {
            id: vpnPopout
        }
    }

    LazyLoader {
        id: powerMenuLoader

        active: false

        PowerMenu {
            id: powerMenu

            onPowerActionRequested: (action, title, message) => {
                                        powerConfirmModalLoader.active = true
                                        if (powerConfirmModalLoader.item) {
                                            powerConfirmModalLoader.item.confirmButtonColor = action === "poweroff" ? Theme.error : action === "reboot" ? Theme.warning : Theme.primary
                                            powerConfirmModalLoader.item.show(title, message, function () {
                                                switch (action) {
                                                case "logout":
                                                    SessionService.logout()
                                                    break
                                                case "suspend":
                                                    SessionService.suspend()
                                                    break
                                                case "hibernate":
                                                    SessionService.hibernate()
                                                    break
                                                case "reboot":
                                                    SessionService.reboot()
                                                    break
                                                case "poweroff":
                                                    SessionService.poweroff()
                                                    break
                                                }
                                            }, function () {})
                                        }
                                    }
        }
    }

    LazyLoader {
        id: powerConfirmModalLoader

        active: false

        ConfirmModal {
            id: powerConfirmModal
        }
    }

    LazyLoader {
        id: processListPopoutLoader

        active: false

        ProcessListPopout {
            id: processListPopout
        }
    }

    SettingsModal {
        id: settingsModal
    }

    LazyLoader {
        id: appDrawerLoader

        active: false

        AppDrawerPopout {
            id: appDrawerPopout
        }
    }

    SpotlightModal {
        id: spotlightModal
    }

    ClipboardHistoryModal {
        id: clipboardHistoryModalPopup
    }

    NotificationModal {
        id: notificationModal
    }
    ColorPickerModal {
        id: colorPickerModal
    }

    LazyLoader {
        id: processListModalLoader

        active: false

        ProcessListModal {
            id: processListModal
        }
    }

    LazyLoader {
        id: systemUpdateLoader

        active: false

        SystemUpdatePopout {
            id: systemUpdatePopout
        }
    }

    Variants {
        id: notepadSlideoutVariants
        model: SettingsData.getFilteredScreens("notepad")

        delegate: DankSlideout {
            id: notepadSlideout
            modelData: item
            title: qsTr("Notepad")
            slideoutWidth: 480
            expandable: true
            expandedWidthValue: 960
            customTransparency: SettingsData.notepadTransparencyOverride

            content: Component {
                Notepad {
                    onHideRequested: {
                        notepadSlideout.hide()
                    }
                }
            }

            function toggle() {
                if (isVisible) {
                    hide()
                } else {
                    show()
                }
            }
        }
    }

    LazyLoader {
        id: powerMenuModalLoader

        active: false

        PowerMenuModal {
            id: powerMenuModal

            onPowerActionRequested: (action, title, message) => {
                                        powerConfirmModalLoader.active = true
                                        if (powerConfirmModalLoader.item) {
                                            powerConfirmModalLoader.item.confirmButtonColor = action === "poweroff" ? Theme.error : action === "reboot" ? Theme.warning : Theme.primary
                                            powerConfirmModalLoader.item.show(title, message, function () {
                                                switch (action) {
                                                case "logout":
                                                    SessionService.logout()
                                                    break
                                                case "suspend":
                                                    SessionService.suspend()
                                                    break
                                                case "reboot":
                                                    SessionService.reboot()
                                                    break
                                                case "poweroff":
                                                    SessionService.poweroff()
                                                    break
                                                }
                                            }, function () {})
                                        }
                                    }
        }
    }

    IpcHandler {
        function open() {
            powerMenuModalLoader.active = true
            if (powerMenuModalLoader.item)
                powerMenuModalLoader.item.open()

            return "POWERMENU_OPEN_SUCCESS"
        }

        function close() {
            if (powerMenuModalLoader.item)
                powerMenuModalLoader.item.close()

            return "POWERMENU_CLOSE_SUCCESS"
        }

        function toggle() {
            powerMenuModalLoader.active = true
            if (powerMenuModalLoader.item)
                powerMenuModalLoader.item.toggle()

            return "POWERMENU_TOGGLE_SUCCESS"
        }

        target: "powermenu"
    }

    IpcHandler {
        function open(): string {
            processListModalLoader.active = true
            if (processListModalLoader.item)
                processListModalLoader.item.show()

            return "PROCESSLIST_OPEN_SUCCESS"
        }

        function close(): string {
            if (processListModalLoader.item)
                processListModalLoader.item.hide()

            return "PROCESSLIST_CLOSE_SUCCESS"
        }

        function toggle(): string {
            processListModalLoader.active = true
            if (processListModalLoader.item)
                processListModalLoader.item.toggle()

            return "PROCESSLIST_TOGGLE_SUCCESS"
        }

        target: "processlist"
    }

    IpcHandler {
        function open(tab: string): string {
            dankDashPopoutLoader.active = true
            if (dankDashPopoutLoader.item) {
                switch (tab.toLowerCase()) {
                case "media":
                    dankDashPopoutLoader.item.currentTabIndex = 1
                    break
                case "weather":
                    dankDashPopoutLoader.item.currentTabIndex = SettingsData.weatherEnabled ? 2 : 0
                    break
                default:
                    dankDashPopoutLoader.item.currentTabIndex = 0
                    break
                }
                dankDashPopoutLoader.item.setTriggerPosition(Screen.width / 2, Theme.barHeight + Theme.spacingS, 100, "center", Screen)
                dankDashPopoutLoader.item.dashVisible = true
                return "DASH_OPEN_SUCCESS"
            }
            return "DASH_OPEN_FAILED"
        }

        function close(): string {
            if (dankDashPopoutLoader.item) {
                dankDashPopoutLoader.item.dashVisible = false
                return "DASH_CLOSE_SUCCESS"
            }
            return "DASH_CLOSE_FAILED"
        }

        function toggle(tab: string): string {
            dankDashPopoutLoader.active = true
            if (dankDashPopoutLoader.item) {
                if (dankDashPopoutLoader.item.dashVisible) {
                    dankDashPopoutLoader.item.dashVisible = false
                } else {
                    switch (tab.toLowerCase()) {
                    case "media":
                        dankDashPopoutLoader.item.currentTabIndex = 1
                        break
                    case "weather":
                        dankDashPopoutLoader.item.currentTabIndex = SettingsData.weatherEnabled ? 2 : 0
                        break
                    default:
                        dankDashPopoutLoader.item.currentTabIndex = 0
                        break
                    }
                    dankDashPopoutLoader.item.setTriggerPosition(Screen.width / 2, Theme.barHeight + Theme.spacingS, 100, "center", Screen)
                    dankDashPopoutLoader.item.dashVisible = true
                }
                return "DASH_TOGGLE_SUCCESS"
            }
            return "DASH_TOGGLE_FAILED"
        }

        target: "dash"
    }

    IpcHandler {
        function getFocusedScreenName() {
            if (CompositorService.isHyprland && Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.monitor) {
                return Hyprland.focusedWorkspace.monitor.name
            }
            if (CompositorService.isNiri && NiriService.currentOutput) {
                return NiriService.currentOutput
            }
            return ""
        }

        function getActiveNotepadInstance() {
            if (notepadSlideoutVariants.instances.length === 0) {
                return null
            }

            if (notepadSlideoutVariants.instances.length === 1) {
                return notepadSlideoutVariants.instances[0]
            }

            var focusedScreen = getFocusedScreenName()
            if (focusedScreen && notepadSlideoutVariants.instances.length > 0) {
                for (var i = 0; i < notepadSlideoutVariants.instances.length; i++) {
                    var slideout = notepadSlideoutVariants.instances[i]
                    if (slideout.modelData && slideout.modelData.name === focusedScreen) {
                        return slideout
                    }
                }
            }

            for (var i = 0; i < notepadSlideoutVariants.instances.length; i++) {
                var slideout = notepadSlideoutVariants.instances[i]
                if (slideout.isVisible) {
                    return slideout
                }
            }

            return notepadSlideoutVariants.instances[0]
        }

        function open(): string {
            var instance = getActiveNotepadInstance()
            if (instance) {
                instance.show()
                return "NOTEPAD_OPEN_SUCCESS"
            }
            return "NOTEPAD_OPEN_FAILED"
        }

        function close(): string {
            var instance = getActiveNotepadInstance()
            if (instance) {
                instance.hide()
                return "NOTEPAD_CLOSE_SUCCESS"
            }
            return "NOTEPAD_CLOSE_FAILED"
        }

        function toggle(): string {
            var instance = getActiveNotepadInstance()
            if (instance) {
                instance.toggle()
                return "NOTEPAD_TOGGLE_SUCCESS"
            }
            return "NOTEPAD_TOGGLE_FAILED"
        }

        target: "notepad"
    }

    IpcHandler {
        function open(): string {
            appDrawerLoader.active = true
            if (appDrawerLoader.item) {
                appDrawerLoader.item.show()
                return "APPDRAWER_OPEN_SUCCESS"
            }
            return "APPDRAWER_OPEN_FAILED"
        }

        function close(): string {
            if (appDrawerLoader.item) {
                appDrawerLoader.item.close()
                return "APPDRAWER_CLOSE_SUCCESS"
            }
            return "APPDRAWER_CLOSE_FAILED"
        }

        function toggle(): string {
            appDrawerLoader.active = true
            if (appDrawerLoader.item) {
                if (appDrawerLoader.item.shouldBeVisible) {
                    appDrawerLoader.item.close()
                    return "APPDRAWER_CLOSE_SUCCESS"
                } else {
                    appDrawerLoader.item.show()
                    return "APPDRAWER_OPEN_SUCCESS"
                }
            }
            return "APPDRAWER_TOGGLE_FAILED"
        }

        target: "appDrawerPopout"
    }

    Variants {
        model: SettingsData.getFilteredScreens("toast")

        delegate: Toast {
            modelData: item
            visible: ToastService.toastVisible
        }
    }

    Variants {
        model: SettingsData.getFilteredScreens("osd")

        delegate: VolumeOSD {
            modelData: item
        }
    }

    Variants {
        model: SettingsData.getFilteredScreens("osd")

        delegate: MicMuteOSD {
            modelData: item
        }
    }

    Variants {
        model: SettingsData.getFilteredScreens("osd")

        delegate: BrightnessOSD {
            modelData: item
        }
    }

    Variants {
        model: SettingsData.getFilteredScreens("osd")

        delegate: IdleInhibitorOSD {
            modelData: item
        }
    }
}
