import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Widgets
import qs.Modules.DarkDash

PanelWindow {
    id: root

    property var modelData: null
    property var screen: modelData
    property real widgetWidth: SettingsData.desktopDarkDashWidth
    property real widgetHeight: SettingsData.desktopDarkDashHeight
    property bool alwaysVisible: SettingsData.desktopWidgetsEnabled && SettingsData.desktopDarkDashEnabled
    property string position: SettingsData.desktopDarkDashPosition || "top-right"
    property var positioningBox: null
    property int currentTabIndex: 0

    implicitWidth: widgetWidth
    implicitHeight: widgetHeight
    visible: alwaysVisible

    WlrLayershell.layer: WlrLayershell.Background
    WlrLayershell.namespace: "quickshell:dock:blur"
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    color: "transparent"

    anchors {
        left: position.includes("left") ? true : false
        right: position.includes("right") ? true : false
        top: position.includes("top") ? true : false
        bottom: position.includes("bottom") ? true : false
    }

    readonly property bool isBarVertical: SettingsData.topBarPosition === "left" || SettingsData.topBarPosition === "right"
    readonly property real barExclusiveSize: SettingsData.topBarVisible && !SettingsData.topBarFloat ? (SettingsData.topBarHeight + SettingsData.topBarSpacing + (SettingsData.topBarGothCornersEnabled ? Theme.cornerRadius : 0)) : 0
    
    margins {
        left: {
            var base = position.includes("left") ? 20 : 0
            if (SettingsData.topBarPosition === "left" && !SettingsData.topBarFloat) {
                return base + barExclusiveSize
            }
            return base
        }
        right: {
            var base = position.includes("right") ? 20 : 0
            if (SettingsData.topBarPosition === "right" && !SettingsData.topBarFloat) {
                return base + barExclusiveSize
            }
            return base
        }
        top: {
            var base = position.includes("top") ? (SettingsData.topBarHeight + SettingsData.topBarSpacing + SettingsData.topBarBottomGap + 20) : 0
            if (SettingsData.topBarPosition === "top" && !SettingsData.topBarFloat) {
                return base
            }
            return position.includes("top") ? 20 : 0
        }
        bottom: {
            var base = position.includes("bottom") ? (SettingsData.dockExclusiveZone + SettingsData.dockBottomGap + 20) : 0
            if (SettingsData.topBarPosition === "bottom" && !SettingsData.topBarFloat) {
                return base + barExclusiveSize
            }
            return base
        }
    }

    Rectangle {
        id: mainContainer
        width: widgetWidth
        height: widgetHeight
        radius: Theme.cornerRadius
        opacity: SettingsData.desktopDarkDashTransparency
        color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, SettingsData.desktopDarkDashContentBackgroundOpacity)
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, SettingsData.desktopDarkDashBorderOpacity)
        border.width: SettingsData.desktopDarkDashBorderThickness

        layer.enabled: SettingsData.desktopDarkDashDropShadowOpacity > 0
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 4
            radius: 12
            samples: 16
            color: Qt.rgba(0, 0, 0, SettingsData.desktopDarkDashDropShadowOpacity)
            transparentBorder: true
        }

        Rectangle {
            id: animatedTintRect
            anchors.fill: parent
            color: Qt.rgba(Theme.surfaceTint.r, Theme.surfaceTint.g, Theme.surfaceTint.b, 1.0)
            radius: parent.radius
            opacity: SettingsData.desktopDarkDashAnimatedTintOpacity
            visible: SettingsData.desktopDarkDashAnimatedTintOpacity > 0

            SequentialAnimation on opacity {
                running: root.alwaysVisible && SettingsData.desktopDarkDashAnimatedTintOpacity > 0
                loops: Animation.Infinite

                NumberAnimation {
                    to: Math.min(1.0, SettingsData.desktopDarkDashAnimatedTintOpacity * 2)
                    duration: Theme.extraLongDuration
                    easing.type: Theme.standardEasing
                }

                NumberAnimation {
                    to: Math.max(0.0, SettingsData.desktopDarkDashAnimatedTintOpacity * 0.5)
                    duration: Theme.extraLongDuration
                    easing.type: Theme.standardEasing
                }
            }
        }

        Column {
            id: contentColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Theme.spacingM
            spacing: Theme.spacingS

            DarkTabBar {
                id: tabBar

                width: parent.width
                height: 48
                currentIndex: root.currentTabIndex
                spacing: Theme.spacingS
                equalWidthTabs: true
                opacity: SettingsData.desktopDarkDashTabBarOpacity

                model: {
                    let tabs = [
                        { icon: "dashboard", text: "Overview" },
                        { icon: "music_note", text: "Media" }
                    ]
                    
                    if (SettingsData.weatherEnabled) {
                        tabs.push({ icon: "wb_sunny", text: "Weather" })
                    }
                    
                    tabs.push({ icon: "settings", text: "Settings", isAction: true })
                    return tabs
                }

                onTabClicked: function(index) {
                    root.currentTabIndex = index
                }

                onActionTriggered: function(index) {
                    let settingsIndex = SettingsData.weatherEnabled ? 3 : 2
                    if (index === settingsIndex) {
                        settingsModal.show()
                    }
                }
            }

            Item {
                width: parent.width
                height: Theme.spacingXS
            }

            StackLayout {
                id: pages
                width: parent.width
                height: {
                    if (currentIndex === 0) return overviewTab.implicitHeight
                    if (currentIndex === 1) return mediaTab.implicitHeight
                    if (SettingsData.weatherEnabled && currentIndex === 2) return weatherTab.implicitHeight
                    return overviewTab.implicitHeight
                }
                implicitHeight: {
                    if (currentIndex === 0) return overviewTab.implicitHeight
                    if (currentIndex === 1) return mediaTab.implicitHeight
                    if (SettingsData.weatherEnabled && currentIndex === 2) return weatherTab.implicitHeight
                    return overviewTab.implicitHeight
                }
                currentIndex: root.currentTabIndex

                OverviewTab {
                    id: overviewTab
                    width: pages.width

                    onSwitchToWeatherTab: {
                        if (SettingsData.weatherEnabled) {
                            tabBar.currentIndex = 2
                            tabBar.tabClicked(2)
                        }
                    }

                    onSwitchToMediaTab: {
                        tabBar.currentIndex = 1
                        tabBar.tabClicked(1)
                    }
                }

                MediaPlayerTab {
                    id: mediaTab
                }

                WeatherTab {
                    id: weatherTab
                    visible: SettingsData.weatherEnabled && root.currentTabIndex === 2
                }
            }
        }
    }
}

