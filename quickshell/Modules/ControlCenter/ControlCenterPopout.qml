import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Common
import qs.Modules.ControlCenter
import qs.Modules.ControlCenter.Widgets
import qs.Modules.ControlCenter.Details
import qs.Modules.TopBar
import qs.Services
import qs.Widgets
import qs.Modules.ControlCenter.Components
import qs.Modules.ControlCenter.Models
import "./utils/state.js" as StateUtils

DarkPopout {
    id: root
    objectName: "controlCenterPopout"

    WlrLayershell.namespace: "quickshell:controlCenter:blur"

    property string expandedSection: ""
    property bool powerOptionsExpanded: false
    property string triggerSection: "right"
    property var triggerScreen: null
    property bool editMode: false
    property int expandedWidgetIndex: -1

    signal powerActionRequested(string action, string title, string message)
    signal lockRequested

    readonly property color _containerBg: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, Theme.getContentBackgroundAlpha() * 0.60)

    function setTriggerPosition(x, y, width, section, screen) {
        StateUtils.setTriggerPosition(root, x, y, width, section, screen)
    }

    function openWithSection(section) {
        StateUtils.openWithSection(root, section)
    }

    function toggleSection(section) {
        StateUtils.toggleSection(root, section)
    }

    readonly property bool isBarVertical: SettingsData.topBarPosition === "left" || SettingsData.topBarPosition === "right"
    
    popupWidth: 550
    popupHeight: Math.min((triggerScreen?.height ?? 1080) - 100, contentLoader.item && contentLoader.item.implicitHeight > 0 ? contentLoader.item.implicitHeight + 20 : 400)
    triggerX: {
        const screenWidth = triggerScreen?.width ?? 1920
        if (isBarVertical) {
            if (SettingsData.topBarPosition === "left") {
                return Theme.barHeight + SettingsData.topBarSpacing + Theme.spacingXS
            } else {
                return screenWidth - Theme.barHeight - SettingsData.topBarSpacing - Theme.spacingXS - 550
            }
        } else {
            return screenWidth - 600 - Theme.spacingL
        }
    }
    property real triggerY: 0
    triggerWidth: 80
    positioning: "center"
    screen: triggerScreen
    shouldBeVisible: false
    visible: shouldBeVisible

    onShouldBeVisibleChanged: {
        if (shouldBeVisible) {
            Qt.callLater(() => {
                NetworkService.autoRefreshEnabled = NetworkService.wifiEnabled
                if (UserInfoService)
                    UserInfoService.getUptime()
            })
        } else {
            Qt.callLater(() => {
                NetworkService.autoRefreshEnabled = false
                if (BluetoothService.adapter && BluetoothService.adapter.discovering)
                    BluetoothService.adapter.discovering = false
                editMode = false
            })
        }
    }

    WidgetModel {
        id: widgetModel
    }

    content: Component {
        Rectangle {
            id: controlContent

            implicitHeight: mainColumn.implicitHeight + Theme.spacingM
            property alias bluetoothCodecSelector: bluetoothCodecSelector

            color: {
                const transparency = SettingsData.controlCenterTransparency || 0.85
                const surface = Theme.surfaceContainer || Qt.rgba(0.1, 0.1, 0.1, 1)
                return Qt.rgba(surface.r, surface.g, surface.b, transparency)
            }
            radius: Theme.cornerRadius
            border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                  Theme.outline.b, SettingsData.controlCenterBorderOpacity || 0.30)
            border.width: SettingsData.controlCenterBorderThickness || 1
            antialiasing: true
            smooth: true

            Column {
                id: mainColumn
                width: parent.width - Theme.spacingL * 2
                x: Theme.spacingL
                y: Theme.spacingL
                spacing: Theme.spacingS

                HeaderPane {
                    id: headerPane
                    width: parent.width
                    powerOptionsExpanded: root.powerOptionsExpanded
                    editMode: root.editMode
                    onPowerOptionsExpandedChanged: root.powerOptionsExpanded = powerOptionsExpanded
                    onEditModeToggled: root.editMode = !root.editMode
                    onPowerActionRequested: (action, title, message) => root.powerActionRequested(action, title, message)
                    onLockRequested: {
                        root.close()
                        root.lockRequested()
                    }
                }

                PowerOptionsPane {
                    id: powerOptionsPane
                    width: parent.width
                    expanded: root.powerOptionsExpanded
                    onPowerActionRequested: (action, title, message) => {
                        root.powerOptionsExpanded = false
                        root.close()
                        root.powerActionRequested(action, title, message)
                    }
                }

                WidgetGrid {
                    id: widgetGrid
                    width: parent.width
                    editMode: root.editMode
                    expandedSection: root.expandedSection
                    expandedWidgetIndex: root.expandedWidgetIndex
                    model: widgetModel
                    onExpandClicked: (widgetData, globalIndex) => {
                        root.expandedWidgetIndex = globalIndex
                        root.toggleSection(widgetData.id)
                    }
                    onRemoveWidget: (index) => widgetModel.removeWidget(index)
                    onMoveWidget: (fromIndex, toIndex) => widgetModel.moveWidget(fromIndex, toIndex)
                    onToggleWidgetSize: (index) => widgetModel.toggleWidgetSize(index)
                }

                EditControls {
                    width: parent.width
                    visible: editMode
                    availableWidgets: {
                        const existingIds = (SettingsData.controlCenterWidgets || []).map(w => w.id)
                        return widgetModel.baseWidgetDefinitions.filter(w => !existingIds.includes(w.id))
                    }
                    onAddWidget: (widgetId) => widgetModel.addWidget(widgetId)
                    onResetToDefault: () => widgetModel.resetToDefault()
                    onClearAll: () => widgetModel.clearAll()
                }
            }

            BluetoothCodecSelector {
                id: bluetoothCodecSelector
                anchors.fill: parent
                z: 10000
            }
        }
    }

    Component {
        id: networkDetailComponent
        NetworkDetail {}
    }

    Component {
        id: bluetoothDetailComponent
        BluetoothDetail {
            id: bluetoothDetail
            onShowCodecSelector: function(device) {
                if (contentLoader.item && contentLoader.item.bluetoothCodecSelector) {
                    contentLoader.item.bluetoothCodecSelector.show(device)
                    contentLoader.item.bluetoothCodecSelector.codecSelected.connect(function(deviceAddress, codecName) {
                        bluetoothDetail.updateDeviceCodecDisplay(deviceAddress, codecName)
                    })
                }
            }
        }
    }

    Component {
        id: audioOutputDetailComponent
        AudioOutputDetail {}
    }

    Component {
        id: audioInputDetailComponent
        AudioInputDetail {}
    }

    Component {
        id: batteryDetailComponent
        BatteryDetail {}
    }
}