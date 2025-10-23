import QtQuick
import QtQuick.Controls
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
    property string side: "left" // "left" or "right"

    spacing: Theme.spacingS

    readonly property real widgetHeight: SettingsData.dockIconSize

    // Define components for each widget type (using actual topbar widget names)
    Component { id: clockComponent; Clock { } }
    Component { id: weatherComponent; Weather { } }
    Component { id: batteryComponent; Battery { } }
    Component { id: musicComponent; Media { } }
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

            DankIcon {
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
                    // TODO: Implement clipboard functionality
                    console.log("Clipboard clicked")
                }
            }
        }
    }
    Component { id: cpuUsageComponent; CpuMonitor { } }
    Component { id: memUsageComponent; RamMonitor { } }
    Component { id: cpuTempComponent; CpuTemperature { } }
    Component { id: gpuTempComponent; GpuTemperature { } }
    Component { id: systemTrayComponent; SystemTrayBar { } }
    Component { id: privacyIndicatorComponent; PrivacyIndicator { } }
    Component { id: controlCenterButtonComponent; ControlCenterButton { } }
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

    readonly property var componentMap: ({
                                             "clock": clockComponent,
                                             "weather": weatherComponent,
                                             "battery": batteryComponent,
                                             "music": musicComponent,
                                             "clipboard": clipboardComponent,
                                             "cpuUsage": cpuUsageComponent,
                                             "memUsage": memUsageComponent,
                                             "cpuTemp": cpuTempComponent,
                                             "gpuTemp": gpuTempComponent,
                                             "systemTray": systemTrayComponent,
                                             "privacyIndicator": privacyIndicatorComponent,
                                             "controlCenterButton": controlCenterButtonComponent,
                                             "notificationButton": notificationButtonComponent,
                                             "vpn": vpnComponent,
                                             "idleInhibitor": idleInhibitorComponent,
                                             "spacer": spacerComponent,
                                             "separator": separatorComponent,
                                             "network_speed_monitor": networkSpeedMonitorComponent,
                                             "keyboard_layout_name": keyboardLayoutNameComponent,
                                             "notepadButton": notepadButtonComponent,
                                             "colorPicker": colorPickerComponent,
                                             "systemUpdate": systemUpdateComponent
                                         })

    function getWidgetComponent(widgetId) {
        return componentMap[widgetId] || null
    }

    Repeater {
        model: root.widgetList

        Loader {
            property string widgetId: model.widgetId || String(model) || ""
            property var widgetData: model
            property int spacerSize: model.size || 20

            anchors.verticalCenter: parent ? parent.verticalCenter : undefined
            active: true // All dock widgets are active when visible
            sourceComponent: root.getWidgetComponent(widgetId)
            asynchronous: false

            onLoaded: {
                if (!item) {
                    return
                }
                if (widgetId === "spacer") {
                    item.spacerSize = Qt.binding(() => model.size || 20)
                }
            }
        }
    }
}
