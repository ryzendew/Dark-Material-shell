import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.DarkDash.Overview

Item {
    id: root

    implicitWidth: 700
    implicitHeight: 410
    width: parent ? (parent.width > 0 ? parent.width : implicitWidth) : implicitWidth
    height: implicitHeight

    Component.onCompleted: {
        console.log("OverviewTab created - parent:", parent, "width:", width, "implicitWidth:", implicitWidth)
    }

    signal switchToWeatherTab()
    signal switchToMediaTab()

    Item {
        id: innerContainer
        anchors.fill: parent
        width: root.width
        height: root.height
        
        Component.onCompleted: {
            console.log("OverviewTab innerContainer - root.width:", root.width, "root.height:", root.height)
        }

        ClockCard {
            x: 0
            y: 0
            width: Math.max(0, innerContainer.width * 0.2 - Theme.spacingM * 2)
            height: 180
        }

        WeatherOverviewCard {
            id: weatherCard
            x: SettingsData.weatherEnabled ? Math.max(0, innerContainer.width * 0.2 - Theme.spacingM) : 0
            y: 0
            width: SettingsData.weatherEnabled ? Math.max(150, innerContainer.width * 0.3) : 0
            height: 100
            visible: SettingsData.weatherEnabled

            Component.onCompleted: {
                console.log("WeatherOverviewCard created:")
                console.log("  - weatherEnabled:", SettingsData.weatherEnabled)
                console.log("  - innerContainer.width:", innerContainer.width)
                console.log("  - root.width:", root.width)
                console.log("  - calculated width:", width)
                console.log("  - x position:", x)
                console.log("  - visible:", visible)
                if (typeof WeatherService !== "undefined") {
                    console.log("  - WeatherService.weather.available:", WeatherService.weather.available)
                    console.log("  - WeatherService.weather.temp:", WeatherService.weather.temp)
                } else {
                    console.log("  - WeatherService is undefined!")
                }
            }

            onWidthChanged: {
                if (width > 0) {
                    console.log("WeatherOverviewCard width changed to:", width, "visible:", visible)
                }
            }

            onClicked: root.switchToWeatherTab()
        }

        UserInfoCard {
            x: SettingsData.weatherEnabled ? innerContainer.width * 0.5 : innerContainer.width * 0.2 - Theme.spacingM
            y: 0
            width: SettingsData.weatherEnabled ? innerContainer.width * 0.5 : innerContainer.width * 0.8
            height: 100
        }

        SystemMonitorCard {
            x: 0
            y: 180 + Theme.spacingM
            width: innerContainer.width * 0.2 - Theme.spacingM * 2
            height: 220
        }

        CalendarOverviewCard {
            x: innerContainer.width * 0.2 - Theme.spacingM
            y: 100 + Theme.spacingM
            width: innerContainer.width * 0.6
            height: 300
        }

        MediaOverviewCard {
            x: innerContainer.width * 0.8
            y: 100 + Theme.spacingM
            width: innerContainer.width * 0.2
            height: 300

            onClicked: root.switchToMediaTab()
        }
    }
}