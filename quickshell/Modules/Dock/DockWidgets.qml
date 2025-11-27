import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Services.Notifications
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.Common
import qs.Modules
import qs.Modules.TopBar
import qs.Services
import qs.Widgets

Row {
    id: root

    property var widgetList: []
    property string side: "left" // "left", "right", "farLeft", or "farRight"

    spacing: Theme.spacingS
    clip: false // Ensure widgets aren't clipped

    readonly property real widgetHeight: SettingsData.dockIconSize
    
    readonly property bool isFarSide: side === "farLeft" || side === "farRight"
    readonly property real farSideOpacity: 0.8
    readonly property real farSideScale: 0.9
    
    function calculateWidgetPosition(position, triggerWidth, triggerHeight) {
        const screen = root.screen || Screen
        const screenWidth = screen.width
        const screenHeight = screen.height
        
        const dockHeight = 80 // Approximate dock height
        const dockGap = -16 // Dock bottom gap
        const availableHeight = screenHeight - dockHeight - dockGap - 20 // Extra margin
        
        const isExpandMode = SettingsData.dockExpandToScreen
        
        switch (position) {
            case "top-left":
                return { x: 20, y: 20, section: "left" }
            case "top-right":
                return { x: screenWidth - triggerWidth, y: 20, section: "right" }
            case "bottom-left":
                if (isExpandMode) {
                    return { x: 8, y: availableHeight - triggerHeight, section: "left" }
                } else {
                    return { x: 20, y: availableHeight - triggerHeight, section: "left" }
                }
            case "bottom-right":
                if (isExpandMode) {
                    return { x: screenWidth - triggerWidth - 8, y: availableHeight - triggerHeight, section: "right" }
                } else {
                    return { x: screenWidth - triggerWidth, y: availableHeight - triggerHeight, section: "right" }
                }
            case "center":
                if (isExpandMode) {
                    return { x: 8, y: (availableHeight - triggerHeight) / 2, section: "left" }
                } else {
                    return { x: (screenWidth - triggerWidth) / 2, y: (availableHeight - triggerHeight) / 2, section: "center" }
                }
            default:
                if (isExpandMode) {
                    return { x: screenWidth - triggerWidth - 8, y: availableHeight - triggerHeight, section: "right" }
                } else {
                    return { x: screenWidth - triggerWidth, y: availableHeight - triggerHeight, section: "right" }
                }
        }
    }

    Component { id: clockComponent; Clock { } }
    Component { id: weatherComponent; Weather { } }
    Component { id: batteryComponent; Battery { } }
    Component { id: musicComponent; Media { } }
    Component { 
        id: launcherButtonComponent
        Rectangle {
            readonly property real horizontalPadding: Math.max(Theme.spacingXS, Theme.spacingS * (root.widgetHeight / 30))
            width: Math.max(40, launcherIcon.width + horizontalPadding * 2) // Ensure minimum width
            height: root.widgetHeight
            radius: Theme.cornerRadius
            z: 1000 // Ensure the entire button is on top
            color: {
                const baseColor = launcherArea.containsMouse ? Theme.widgetBaseHoverColor : Theme.widgetBaseBackgroundColor
                return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, baseColor.a * Theme.widgetTransparency)
            }
            
            Component.onCompleted: {
            }
            
            

            SystemLogo {
                visible: SettingsData.useOSLogo && !SettingsData.useCustomLauncherImage
                anchors.centerIn: parent
                width: SettingsData.launcherLogoSize > 0 ? SettingsData.launcherLogoSize - 3 : (root.widgetHeight - 6)
                height: SettingsData.launcherLogoSize > 0 ? SettingsData.launcherLogoSize - 3 : (root.widgetHeight - 6)
                colorOverride: SettingsData.osLogoColorOverride !== "" ? SettingsData.osLogoColorOverride : Qt.rgba(SettingsData.launcherLogoRed, SettingsData.launcherLogoGreen, SettingsData.launcherLogoBlue, 1.0)
                brightnessOverride: SettingsData.osLogoBrightness
                contrastOverride: SettingsData.osLogoContrast

                layer.enabled: true
                layer.effect: DropShadow {
                    horizontalOffset: 0
                    verticalOffset: 2
                    radius: 8
                    samples: 16
                    color: Qt.rgba(0, 0, 0, SettingsData.launcherLogoDropShadowOpacity)
                    transparentBorder: true
                }
            }

            Item {
                visible: SettingsData.useCustomLauncherImage && SettingsData.customLauncherImagePath !== ""
                anchors.centerIn: parent
                width: SettingsData.launcherLogoSize > 0 ? SettingsData.launcherLogoSize - 6 : (root.widgetHeight - 8)
                height: SettingsData.launcherLogoSize > 0 ? SettingsData.launcherLogoSize - 6 : (root.widgetHeight - 8)

                Image {
                    id: customImage
                    anchors.fill: parent
                    source: SettingsData.customLauncherImagePath
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true

                    layer.enabled: SettingsData.launcherLogoRed !== 1.0 || SettingsData.launcherLogoGreen !== 1.0 || SettingsData.launcherLogoBlue !== 1.0
                    layer.effect: ColorOverlay {
                        color: Qt.rgba(SettingsData.launcherLogoRed, SettingsData.launcherLogoGreen, SettingsData.launcherLogoBlue, 0.8)
                    }
                }

                layer.enabled: true
                layer.effect: DropShadow {
                    horizontalOffset: 0
                    verticalOffset: 2
                    radius: 8
                    samples: 16
                    color: Qt.rgba(0, 0, 0, SettingsData.launcherLogoDropShadowOpacity)
                    transparentBorder: true
                }
            }

            DarkIcon {
                id: launcherIcon
                visible: !SettingsData.useOSLogo && !SettingsData.useCustomLauncherImage
                anchors.centerIn: parent
                name: "apps"
                size: SettingsData.launcherLogoSize > 0 ? SettingsData.launcherLogoSize - 6 : Math.min(Theme.iconSize, root.widgetHeight - 8)
                color: Qt.rgba(SettingsData.launcherLogoRed, SettingsData.launcherLogoGreen, SettingsData.launcherLogoBlue, 1.0)

                layer.enabled: true
                layer.effect: DropShadow {
                    horizontalOffset: 0
                    verticalOffset: 2
                    radius: 8
                    samples: 16
                    color: Qt.rgba(0, 0, 0, SettingsData.launcherLogoDropShadowOpacity)
                    transparentBorder: true
                }
            }

            MouseArea {
                id: launcherArea
                anchors.fill: parent
                anchors.margins: 0 // Ensure no margins
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton
                z: 2000 // Very high z-index to ensure it's on top
                propagateComposedEvents: false // Prevent event propagation
                enabled: true // Explicitly enable the mouse area
                
                preventStealing: true
                
                Rectangle {
                    anchors.fill: parent
                    color: launcherArea.containsMouse ? "rgba(255, 0, 0, 0.3)" : "rgba(255, 0, 0, 0.1)"
                    border.color: "red"
                    border.width: 2
                    radius: parent.parent.radius
                    z: 1000 // Ensure it's on top
                    visible: false // Hide debug visual
                }
                
                Component.onCompleted: {
                }
                
                onEntered: {
                }
                
                onExited: {
                }
                
                onPressed: (mouse) => {
                    mouse.accepted = true
                }
                
                onReleased: {
                }
                
                onClicked: {
                    try {
                        let current = root
                        while (current) {
                        if (current.appDrawerLoader) {
                            current.appDrawerLoader.active = true
                            if (current.appDrawerLoader.item) {
                                const position = root.calculateWidgetPosition(SettingsData.appDrawerPosition, 400, 600)
                                const screen = root.screen || Screen
                                
                                if (current.appDrawerLoader.item.setTriggerPosition) {
                                    current.appDrawerLoader.item.setTriggerPosition(position.x, position.y, 0, position.section, screen)
                                }
                                current.appDrawerLoader.item.show()
                            }
                            return
                        }
                            current = current.parent
                        }
                        
                        if (typeof appDrawerLoader !== 'undefined') {
                            appDrawerLoader.active = true
                            if (appDrawerLoader.item) {
                                const position = root.calculateWidgetPosition(SettingsData.appDrawerPosition, 400, 600)
                                const screen = root.screen || Screen
                                
                                if (appDrawerLoader.item.setTriggerPosition) {
                                    appDrawerLoader.item.setTriggerPosition(position.x, position.y, 0, position.section, screen)
                                }
                                appDrawerLoader.item.show()
                            }
                        }
                    } catch (e) {
                    }
                }
                
                onPressAndHold: {
                }
            }
        }
    }
    Component { 
        id: clipboardComponent
        Rectangle {
            readonly property real horizontalPadding: Math.max(Theme.spacingXS, Theme.spacingS * (root.widgetHeight / 30))
            width: clipboardIcon.width + horizontalPadding * 2
            height: root.widgetHeight
            radius: Theme.cornerRadius
            color: {
                const baseColor = clipboardArea.containsMouse ? Theme.widgetBaseHoverColor : Theme.widgetBaseBackgroundColor
                return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, baseColor.a * Theme.widgetTransparency)
            }

            DarkIcon {
                id: clipboardIcon
                anchors.centerIn: parent
                name: "content_paste"
                size: Theme.iconSize
                color: Theme.surfaceText
            }

            MouseArea {
                id: clipboardArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                }
            }
        }
    }
    Component { id: cpuUsageComponent; CpuMonitor { } }
    Component { id: memUsageComponent; RamMonitor { } }
    Component { id: cpuTempComponent; CpuTemperature { } }
    Component { id: gpuTempComponent; GpuTemperature { } }
    Component { 
        id: systemTrayComponent
        SystemTrayBar { 
            parentScreen: root.screen
            parentWindow: root.Window.window
            isAtBottom: true
            isVertical: false
            axis: null
        }
    }
    Component { id: privacyIndicatorComponent; PrivacyIndicator { } }
    Component { 
        id: controlCenterButtonComponent
        ControlCenterButton {
            section: "left"
            popupTarget: {
                let current = root
                while (current) {
                    if (current.controlCenterLoader) {
                        current.controlCenterLoader.active = true
                        return current.controlCenterLoader.item
                    }
                    current = current.parent
                }
                return null
            }
            parentScreen: root.screen
            onClicked: {
                let current = root
                while (current) {
                    if (current.controlCenterLoader) {
                        current.controlCenterLoader.active = true
                        if (current.controlCenterLoader.item) {
                            const position = root.calculateWidgetPosition(SettingsData.controlCenterPosition, 300, 400)
                            const screen = root.screen || Screen
                            
                            current.controlCenterLoader.item.setTriggerPosition(position.x, position.y, 0, position.section, screen)
                            current.controlCenterLoader.item.toggle()
                        }
                        return
                    }
                    current = current.parent
                }
                
                if (typeof controlCenterLoader !== 'undefined') {
                    controlCenterLoader.active = true
                    if (controlCenterLoader.item) {
                        const position = root.calculateWidgetPosition(SettingsData.controlCenterPosition, 300, 400)
                        const screen = root.screen || Screen
                        
                        controlCenterLoader.item.setTriggerPosition(position.x, position.y, 0, position.section, screen)
                        controlCenterLoader.item.toggle()
                    }
                }
            }
        }
    }
    Component { id: workspaceSwitcherComponent; WorkspaceSwitcher { } }
    Component { id: notificationButtonComponent; NotificationCenterButton { } }
    Component { id: vpnComponent; Vpn { } }
    Component { id: idleInhibitorComponent; IdleInhibitor { } }
    Component { 
        id: spacerComponent
        Item {
            width: (widgetData && widgetData.size) ? widgetData.size : 20
            height: root.widgetHeight
        }
    }
    Component { 
        id: separatorComponent
        Rectangle {
            width: 2
            height: root.widgetHeight - 8
            color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.3)
            radius: 1
        }
    }
    Component { id: networkSpeedMonitorComponent; NetworkMonitor { } }
    Component { id: keyboardLayoutNameComponent; KeyboardLayoutName { } }
    Component { id: notepadButtonComponent; NotepadButton { } }
    Component { id: colorPickerComponent; ColorPicker { } }
    Component { id: systemUpdateComponent; SystemUpdate { } }
    Component {
        id: darkDashComponent
        DockDarkDash {
            parentScreen: root.screen
        }
    }
    Component {
        id: applicationsComponent
        DockApplications {
            parentScreen: root.screen
        }
    }
    Component { 
        id: settingsButtonComponent
        Rectangle {
            readonly property real horizontalPadding: Math.max(Theme.spacingXS, Theme.spacingS * (root.widgetHeight / 30))
            width: 40
            height: root.widgetHeight
            radius: Theme.cornerRadius
            color: settingsArea.containsMouse ? Theme.widgetBaseHoverColor : "transparent"
            
            MouseArea {
                id: settingsArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    settingsModal.show()
                }
            }

            DarkIcon {
                anchors.centerIn: parent
                name: "settings"
                size: Theme.iconSize
                color: Theme.surfaceText
            }
        }
    }

    readonly property var componentMap: ({
                                             "clock": clockComponent,
                                             "weather": weatherComponent,
                                             "battery": batteryComponent,
                                             "music": musicComponent,
                                             "launcherButton": launcherButtonComponent,
                                             "darkDash": darkDashComponent,
                                             "applications": applicationsComponent,
                                             "clipboard": clipboardComponent,
                                             "cpuUsage": cpuUsageComponent,
                                             "memUsage": memUsageComponent,
                                             "cpuTemp": cpuTempComponent,
                                             "gpuTemp": gpuTempComponent,
                                             "systemTray": systemTrayComponent,
                                             "privacyIndicator": privacyIndicatorComponent,
                                             "controlCenterButton": controlCenterButtonComponent,
                                             "workspaceSwitcher": workspaceSwitcherComponent,
                                             "notificationButton": notificationButtonComponent,
                                             "vpn": vpnComponent,
                                             "idleInhibitor": idleInhibitorComponent,
                                             "spacer": spacerComponent,
                                             "separator": separatorComponent,
                                             "network_speed_monitor": networkSpeedMonitorComponent,
                                             "keyboard_layout_name": keyboardLayoutNameComponent,
                                             "notepadButton": notepadButtonComponent,
                                             "colorPicker": colorPickerComponent,
                                             "systemUpdate": systemUpdateComponent,
                                             "settingsButton": settingsButtonComponent
                                         })

    function getWidgetComponent(widgetId) {
        return componentMap[widgetId] || null
    }
    
    function getWidgetVisible(widgetId) {
        return true
    }
    
    function getWidgetEnabled(enabled) {
        return enabled !== false
    }

    

    Repeater {
        model: root.widgetList
        
        Component.onCompleted: {
        }

        Loader {
            property string widgetId: model.widgetId
            property var widgetData: model
            property int spacerSize: model.size || 20

            anchors.verticalCenter: parent ? parent.verticalCenter : undefined
            
            active: root.getWidgetVisible(widgetId) && (widgetId !== "music" || MprisController.activePlayer !== null)
            sourceComponent: root.getWidgetComponent(widgetId)
            
            Component.onCompleted: {
            }
            opacity: {
                const enabled = root.getWidgetEnabled(model.enabled)
                const farSideOpacity = root.isFarSide ? root.farSideOpacity : 1.0
                return enabled ? farSideOpacity : 0
            }
            scale: root.isFarSide ? root.farSideScale : 1.0
            asynchronous: false
            
            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }
            
            Behavior on scale {
                NumberAnimation { duration: 200 }
            }

            onLoaded: {
                if (!item) {
                    return
                }
                if (widgetId === "spacer") {
                    item.spacerSize = Qt.binding(() => model.size || 20)
                }
                
                if (root.isFarSide && item) {
                    item.opacity = root.farSideOpacity
                    item.scale = root.farSideScale
                }
            }
            
            onActiveChanged: {
                if (active) {
                    Qt.callLater(() => {
                        if (item) {
                            item.visible = true
                        }
                    })
                }
            }
        }
    }
}
