import QtQuick
import QtQuick.Controls
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets

    Item {
        id: root

        property real widgetHeight: 40

        width: weatherRow.implicitWidth + 16
        height: widgetHeight

        Ref {
            service: WeatherService
        }

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.3)
            radius: Theme.cornerRadius
            border.width: 1
            border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)

            Row {
                id: weatherRow
                anchors.centerIn: parent
                spacing: 6

                DarkIcon {
                    name: WeatherService.getWeatherIcon(WeatherService.weather.wCode)
                    size: 16
                    color: Theme.primary
                    anchors.verticalCenter: parent.verticalCenter
                }

                StyledText {
                    text: {
                        const temp = SettingsData.useFahrenheit ? WeatherService.weather.tempF : WeatherService.weather.temp;
                        if (temp === undefined || temp === null) {
                            return "--°" + (SettingsData.useFahrenheit ? "F" : "C");
                        }
                        return temp + "°" + (SettingsData.useFahrenheit ? "F" : "C");
                    }
                    font.pixelSize: 12
                    color: Theme.surfaceText
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }







