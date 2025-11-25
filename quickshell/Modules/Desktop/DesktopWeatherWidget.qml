import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services
import qs.Widgets

PanelWindow {
    id: root

    property var modelData: null
    property var screen: modelData

    // Widget properties
    property real widgetWidth: SettingsData.desktopWeatherWidth || 600
    property real widgetHeight: SettingsData.desktopWeatherHeight || 300
    property real widgetOpacity: SettingsData.desktopWeatherOpacity
    property string position: SettingsData.desktopWeatherPosition
    property bool alwaysVisible: SettingsData.desktopWeatherEnabled
    property var positioningBox: null

    // Dynamic scaling
    property real scaleFactor: Math.min(widgetWidth / 100, widgetHeight / 450)
    property real baseFontSize: SettingsData.desktopWeatherFontSize
    property real scaledFontSize: baseFontSize * scaleFactor
    property real baseSpacing: SettingsData.desktopWeatherSpacing
    property real scaledSpacing: baseSpacing * scaleFactor
    property real basePadding: SettingsData.desktopWeatherPadding
    property real scaledPadding: basePadding * scaleFactor
    property real baseIconSize: SettingsData.desktopWeatherIconSize
    property real scaledIconSize: baseIconSize * scaleFactor
    WlrLayershell.layer: WlrLayershell.Background
    WlrLayershell.namespace: "quickshell:desktop:weather"
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    color: "transparent"

    implicitWidth: widgetWidth
    implicitHeight: widgetHeight
    visible: alwaysVisible

    // Position using anchors and margins like other desktop widgets
    anchors {
        left: position.includes("left") ? true : false
        right: position.includes("right") ? true : false
        top: position.includes("top") ? true : false
        bottom: position.includes("bottom") ? true : false
    }

    margins {
        left: position.includes("left") ? 20 : 0
        right: position.includes("right") ? 20 : 0
        top: position.includes("top") ? (SettingsData.topBarHeight + SettingsData.topBarSpacing + SettingsData.topBarBottomGap + 20) : 0
        bottom: position.includes("bottom") ? (SettingsData.dockExclusiveZone + SettingsData.dockBottomGap + 20) : 0
    }

    // Main container
    Rectangle {
        anchors.fill: parent
        radius: Theme.cornerRadius
        color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, widgetOpacity)
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
        border.width: 1


        // No weather data state
        Column {
            anchors.centerIn: parent
            spacing: scaledSpacing * 2
            visible: !WeatherService.weather.available || WeatherService.weather.temp === 0

            DarkIcon {
                name: "cloud_off"
                size: Theme.iconSize * 2 * scaleFactor
                color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.5)
                anchors.horizontalCenter: parent.horizontalCenter
            }

            StyledText {
                text: "No Weather Data Available"
                font.pixelSize: scaledFontSize * 1.5
                color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        // Weather data content
        Column {
            anchors.fill: parent
            anchors.margins: scaledPadding
            spacing: scaledSpacing
            visible: WeatherService.weather.available && WeatherService.weather.temp !== 0

            // Header with refresh button
            Item {
                width: parent.width
                height: 50 * scaleFactor

                DarkIcon {
                    id: refreshButton
                    name: "refresh"
                    size: (Theme.iconSize - 4) * scaleFactor
                    color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.4)
                    anchors.right: parent.right
                    anchors.top: parent.top

                    property bool isRefreshing: false
                    enabled: !isRefreshing

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                        onClicked: {
                            refreshButton.isRefreshing = true
                            WeatherService.forceRefresh()
                            refreshTimer.restart()
                        }
                        enabled: parent.enabled
                    }

                    Timer {
                        id: refreshTimer
                        interval: 2000
                        onTriggered: refreshButton.isRefreshing = false
                    }

                    NumberAnimation on rotation {
                        running: refreshButton.isRefreshing
                        from: 0
                        to: 360
                        duration: 1000
                        loops: Animation.Infinite
                    }
                }

                // Main weather info
                Row {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.leftMargin: 2
                    anchors.topMargin: 2
                    spacing: 8

                    DarkIcon {
                        id: weatherIcon
                        name: WeatherService.getWeatherIcon(WeatherService.weather.wCode)
                        size: scaledIconSize * 1.5
                        color: Theme.primary

                        layer.enabled: true
                        layer.effect: MultiEffect {
                            shadowEnabled: true
                            shadowHorizontalOffset: 0
                            shadowVerticalOffset: 4
                            shadowBlur: 0.8
                            shadowColor: Qt.rgba(0, 0, 0, 0.2)
                            shadowOpacity: 0.2
                        }
                    }

                    Row {
                        spacing: 2
                        anchors.verticalCenter: weatherIcon.verticalCenter

                        StyledText {
                            text: (SettingsData.useFahrenheit ? WeatherService.weather.tempF : WeatherService.weather.temp) + "°"
                            font.pixelSize: scaledFontSize * SettingsData.desktopWeatherCurrentTempSize
                            color: Theme.surfaceText
                            font.weight: Font.Light
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: SettingsData.useFahrenheit ? "F" : "C"
                            font.pixelSize: scaledFontSize * 1.2
                            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                            anchors.verticalCenter: parent.verticalCenter
                            
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (WeatherService.weather.available) {
                                        SettingsData.setTemperatureUnit(!SettingsData.useFahrenheit)
                                    }
                                }
                                enabled: WeatherService.weather.available
                            }
                        }
                    }
                }

                // City name on the right side
                StyledText {
                    text: WeatherService.weather.city || ""
                    font.pixelSize: scaledFontSize * SettingsData.desktopWeatherCitySize
                    color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                    visible: text.length > 0
                    anchors.right: refreshButton.left
                    anchors.top: parent.top
                    anchors.rightMargin: 4
                    anchors.topMargin: 2
                }
            }

            // Divider
            Rectangle {
                width: parent.width
                height: 1
                color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.1)
            }

            // Weather details grid
            GridLayout {
                width: parent.width
                height: 120 * scaleFactor
                columns: 3
                columnSpacing: scaledSpacing
                rowSpacing: scaledSpacing

                // Feels Like
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: Theme.cornerRadius * 0.5
                    color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)

                    Column {
                        anchors.centerIn: parent
                        spacing: scaledSpacing / 2

                        Rectangle {
                            width: 24 * scaleFactor
                            height: 24 * scaleFactor
                            radius: Theme.cornerRadius * 0.3
                            color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1)
                            anchors.horizontalCenter: parent.horizontalCenter

                            DarkIcon {
                                anchors.centerIn: parent
                                name: "device_thermostat"
                                size: (Theme.iconSize - 4) * scaleFactor
                                color: Theme.primary
                            }
                        }

                        StyledText {
                            text: "Feels Like"
                            font.pixelSize: scaledFontSize * 0.8
                            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        StyledText {
                            text: (SettingsData.useFahrenheit ? (WeatherService.weather.feelsLikeF || WeatherService.weather.tempF) : (WeatherService.weather.feelsLike || WeatherService.weather.temp)) + "°"
                            font.pixelSize: scaledFontSize
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }

                // Humidity
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: Theme.cornerRadius * 0.5
                    color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)

                    Column {
                        anchors.centerIn: parent
                        spacing: scaledSpacing / 2

                        Rectangle {
                            width: 24 * scaleFactor
                            height: 24 * scaleFactor
                            radius: Theme.cornerRadius * 0.3
                            color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1)
                            anchors.horizontalCenter: parent.horizontalCenter

                            DarkIcon {
                                anchors.centerIn: parent
                                name: "humidity_low"
                                size: (Theme.iconSize - 4) * scaleFactor
                                color: Theme.primary
                            }
                        }

                        StyledText {
                            text: "Humidity"
                            font.pixelSize: scaledFontSize * 0.8
                            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        StyledText {
                            text: WeatherService.weather.humidity ? WeatherService.weather.humidity + "%" : "--"
                            font.pixelSize: scaledFontSize
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }

                // Wind
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: Theme.cornerRadius * 0.5
                    color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)

                    Column {
                        anchors.centerIn: parent
                        spacing: scaledSpacing / 2

                        Rectangle {
                            width: 24 * scaleFactor
                            height: 24 * scaleFactor
                            radius: Theme.cornerRadius * 0.3
                            color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1)
                            anchors.horizontalCenter: parent.horizontalCenter

                            DarkIcon {
                                anchors.centerIn: parent
                                name: "air"
                                size: (Theme.iconSize - 4) * scaleFactor
                                color: Theme.primary
                            }
                        }

                        StyledText {
                            text: "Wind"
                            font.pixelSize: scaledFontSize * 0.8
                            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        StyledText {
                            text: WeatherService.weather.wind || "--"
                            font.pixelSize: scaledFontSize
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }

            // Divider
            Rectangle {
                width: parent.width
                height: 1
                color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.1)
            }

            // 7-Day Forecast
            Column {
                width: parent.width
                spacing: scaledSpacing

                StyledText {
                    text: "7-Day Forecast"
                    font.pixelSize: scaledFontSize * 1.2
                    color: Theme.surfaceText
                    font.weight: Font.Bold
                }

                Row {
                    width: parent.width
                    spacing: scaledSpacing

                    Repeater {
                        model: 7

                        Rectangle {
                            width: (parent.width - scaledSpacing * 6) / 7
                            height: childrenRect.height + scaledPadding
                            radius: Theme.cornerRadius * 0.5
                            
                            property var dayDate: {
                                const date = new Date()
                                date.setDate(date.getDate() + index)
                                return date
                            }
                            property bool isToday: index === 0
                            property var forecastData: {
                                if (WeatherService.weather.forecast && WeatherService.weather.forecast.length > index) {
                                    return WeatherService.weather.forecast[index]
                                }
                                return null
                            }

                            color: isToday ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1) : Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.1)
                            border.color: isToday ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3) : "transparent"
                            border.width: isToday ? 1 : 0

                            Column {
                                width: parent.width
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.margins: scaledPadding / 2
                                spacing: scaledSpacing / 2

                                StyledText {
                                    text: Qt.locale().dayName(dayDate.getDay(), Locale.ShortFormat)
                                    font.pixelSize: scaledFontSize * 1.2
                                    color: isToday ? Theme.primary : Theme.surfaceText
                                    font.weight: isToday ? Font.Medium : Font.Normal
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                DarkIcon {
                                    name: forecastData ? WeatherService.getWeatherIcon(forecastData.wCode || 0) : "cloud"
                                    size: Theme.iconSize * 1.5 * scaleFactor
                                    color: isToday ? Theme.primary : Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.8)
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                StyledText {
                                    text: forecastData ? (SettingsData.useFahrenheit ? (forecastData.tempMaxF || forecastData.tempMax) : (forecastData.tempMax || 0)) + "°/" + (SettingsData.useFahrenheit ? (forecastData.tempMinF || forecastData.tempMin) : (forecastData.tempMin || 0)) + "°" : "--/--"
                                    font.pixelSize: scaledFontSize * 1.0
                                    color: isToday ? Theme.primary : Theme.surfaceText
                                    font.weight: Font.Medium
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        // Initialize weather service
        WeatherService.addRef()
    }
    
    Component.onDestruction: {
        // Clean up weather service reference
        WeatherService.removeRef()
    }
}
