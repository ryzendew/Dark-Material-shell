import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Widgets

Item {
    id: weatherTab

    DarkFlickable {
        anchors.fill: parent
        anchors.topMargin: Theme.spacingL
        clip: true
        contentHeight: mainColumn.height
        contentWidth: width

        Column {
            id: mainColumn

            width: parent.width
            spacing: Theme.spacingXL

            StyledRect {
                width: parent.width
                height: enableWeatherSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: enableWeatherSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    DarkToggle {
                        width: parent.width
                        text: "Enable Weather"
                        description: "Show weather information in top bar and control center"
                        checked: SettingsData.weatherEnabled
                        onToggled: checked => {
                                       return SettingsData.setWeatherEnabled(
                                           checked)
                                   }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: temperatureSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1
                visible: SettingsData.weatherEnabled
                opacity: visible ? 1 : 0

                Column {
                    id: temperatureSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    DarkToggle {
                        width: parent.width
                        text: "Use Fahrenheit"
                        description: "Use Fahrenheit instead of Celsius for temperature"
                        checked: SettingsData.useFahrenheit
                        onToggled: checked => {
                                       return SettingsData.setTemperatureUnit(
                                           checked)
                                   }
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.mediumDuration
                        easing.type: Theme.emphasizedEasing
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: locationSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1
                visible: SettingsData.weatherEnabled
                opacity: visible ? 1 : 0

                Column {
                    id: locationSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    DarkToggle {
                        width: parent.width
                        text: "Auto Location"
                        description: "Automatically determine your location using your IP address"
                        checked: SettingsData.useAutoLocation
                        onToggled: checked => {
                                       return SettingsData.setAutoLocation(
                                           checked)
                                   }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingXS
                        visible: !SettingsData.useAutoLocation

                        Rectangle {
                            width: parent.width
                            height: 1
                            color: Theme.outline
                            opacity: 0.2
                        }

                        StyledText {
                            text: "Custom Location"
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        Row {
                                width: parent.width
                                spacing: Theme.spacingM

                                Column {
                                    width: (parent.width - Theme.spacingM) / 2
                                    spacing: Theme.spacingXS

                                    StyledText {
                                        text: "Latitude"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }

                                    DarkTextField {
                                        id: latitudeInput
                                        width: parent.width
                                        height: 48
                                        placeholderText: "40.7128"
                                        backgroundColor: Theme.surfaceVariant
                                        normalBorderColor: Theme.primarySelected
                                        focusedBorderColor: Theme.primary
                                        keyNavigationTab: longitudeInput

                                        Component.onCompleted: {
                                            if (SettingsData.weatherCoordinates) {
                                                const coords = SettingsData.weatherCoordinates.split(',')
                                                if (coords.length > 0) {
                                                    text = coords[0].trim()
                                                }
                                            }
                                        }

                                        Connections {
                                            target: SettingsData
                                            function onWeatherCoordinatesChanged() {
                                                if (SettingsData.weatherCoordinates) {
                                                    const coords = SettingsData.weatherCoordinates.split(',')
                                                    if (coords.length > 0) {
                                                        latitudeInput.text = coords[0].trim()
                                                    }
                                                }
                                            }
                                        }

                                        onTextEdited: {
                                            if (text && longitudeInput.text) {
                                                const coords = text + "," + longitudeInput.text
                                                SettingsData.weatherCoordinates = coords
                                                SettingsData.saveSettings()
                                            }
                                        }
                                    }
                                }

                                Column {
                                    width: (parent.width - Theme.spacingM) / 2
                                    spacing: Theme.spacingXS

                                    StyledText {
                                        text: "Longitude"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }

                                    DarkTextField {
                                        id: longitudeInput
                                        width: parent.width
                                        height: 48
                                        placeholderText: "-74.0060"
                                        backgroundColor: Theme.surfaceVariant
                                        normalBorderColor: Theme.primarySelected
                                        focusedBorderColor: Theme.primary
                                        keyNavigationTab: locationSearchInput
                                        keyNavigationBacktab: latitudeInput

                                        Component.onCompleted: {
                                            if (SettingsData.weatherCoordinates) {
                                                const coords = SettingsData.weatherCoordinates.split(',')
                                                if (coords.length > 1) {
                                                    text = coords[1].trim()
                                                }
                                            }
                                        }

                                        Connections {
                                            target: SettingsData
                                            function onWeatherCoordinatesChanged() {
                                                if (SettingsData.weatherCoordinates) {
                                                    const coords = SettingsData.weatherCoordinates.split(',')
                                                    if (coords.length > 1) {
                                                        longitudeInput.text = coords[1].trim()
                                                    }
                                                }
                                            }
                                        }

                                        onTextEdited: {
                                            if (text && latitudeInput.text) {
                                                const coords = latitudeInput.text + "," + text
                                                SettingsData.weatherCoordinates = coords
                                                SettingsData.saveSettings()
                                            }
                                        }
                                    }
                                }
                            }

                        Column {
                            width: parent.width
                            spacing: Theme.spacingXS

                            StyledText {
                                text: "Location Search"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                font.weight: Font.Medium
                            }

                            DarkLocationSearch {
                                id: locationSearchInput
                                width: parent.width
                                currentLocation: ""
                                placeholderText: "New York, NY"
                                keyNavigationBacktab: longitudeInput
                                onLocationSelected: (displayName, coordinates) => {
                                                        SettingsData.setWeatherLocation(displayName, coordinates)

                                                        const coords = coordinates.split(',')
                                                        if (coords.length >= 2) {
                                                            latitudeInput.text = coords[0].trim()
                                                            longitudeInput.text = coords[1].trim()
                                                        }
                                                    }
                            }
                        }
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.mediumDuration
                        easing.type: Theme.emphasizedEasing
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: desktopWeatherSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1
                visible: SettingsData.weatherEnabled
                opacity: visible ? 1 : 0

                Column {
                    id: desktopWeatherSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "widgets"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingM
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: "Desktop Weather Widget"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Customize all aspects of the desktop weather widget"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingXS

                        StyledText {
                            text: "Basic Size"
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: "Width"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                width: 80
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            DarkSlider {
                                width: parent.width - 80 - Theme.spacingM - 60
                                height: 40
                                minimum: 400
                                maximum: 1200
                                value: SettingsData.desktopWeatherWidth
                                onSliderValueChanged: {
                                    SettingsData.setDesktopWeatherWidth(value)
                                }
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            StyledText {
                                text: Math.round(SettingsData.desktopWeatherWidth) + "px"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                width: 60
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: "Height"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                width: 80
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            DarkSlider {
                                width: parent.width - 80 - Theme.spacingM - 60
                                height: 40
                                minimum: 300
                                maximum: 800
                                value: SettingsData.desktopWeatherHeight
                                onSliderValueChanged: {
                                    SettingsData.setDesktopWeatherHeight(value)
                                }
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            StyledText {
                                text: Math.round(SettingsData.desktopWeatherHeight) + "px"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                width: 60
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingXS

                        StyledText {
                            text: "Typography"
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: "Base Font"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                width: 80
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            DarkSlider {
                                width: parent.width - 80 - Theme.spacingM - 60
                                height: 40
                                minimum: 10
                                maximum: 40
                                value: SettingsData.desktopWeatherFontSize
                                onSliderValueChanged: {
                                    SettingsData.setDesktopWeatherFontSize(value)
                                }
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            StyledText {
                                text: Math.round(SettingsData.desktopWeatherFontSize) + "px"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                width: 60
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: "Temp Size"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                width: 80
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            DarkSlider {
                                width: parent.width - 80 - Theme.spacingM - 60
                                height: 40
                                minimum: 10
                                maximum: 40
                                value: Math.round(SettingsData.desktopWeatherCurrentTempSize * 10)
                                onSliderValueChanged: {
                                    SettingsData.setDesktopWeatherCurrentTempSize(value / 10)
                                }
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            StyledText {
                                text: SettingsData.desktopWeatherCurrentTempSize.toFixed(1) + "x"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                width: 60
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: "City Size"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                width: 80
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            DarkSlider {
                                width: parent.width - 80 - Theme.spacingM - 60
                                height: 40
                                minimum: 10
                                maximum: 40
                                value: Math.round(SettingsData.desktopWeatherCitySize * 10)
                                onSliderValueChanged: {
                                    SettingsData.setDesktopWeatherCitySize(value / 10)
                                }
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            StyledText {
                                text: SettingsData.desktopWeatherCitySize.toFixed(1) + "x"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                width: 60
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: "Details Size"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                width: 80
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            DarkSlider {
                                width: parent.width - 80 - Theme.spacingM - 60
                                height: 40
                                minimum: 5
                                maximum: 20
                                value: Math.round(SettingsData.desktopWeatherDetailsSize * 10)
                                onSliderValueChanged: {
                                    SettingsData.setDesktopWeatherDetailsSize(value / 10)
                                }
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            StyledText {
                                text: SettingsData.desktopWeatherDetailsSize.toFixed(1) + "x"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                width: 60
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: "Forecast Size"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                width: 80
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            DarkSlider {
                                width: parent.width - 80 - Theme.spacingM - 60
                                height: 40
                                minimum: 5
                                maximum: 20
                                value: Math.round(SettingsData.desktopWeatherForecastSize * 10)
                                onSliderValueChanged: {
                                    SettingsData.setDesktopWeatherForecastSize(value / 10)
                                }
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            StyledText {
                                text: SettingsData.desktopWeatherForecastSize.toFixed(1) + "x"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                width: 60
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingXS

                        StyledText {
                            text: "Layout"
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: "Icon Size"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                width: 80
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            DarkSlider {
                                width: parent.width - 80 - Theme.spacingM - 60
                                height: 40
                                minimum: 12
                                maximum: 48
                                value: SettingsData.desktopWeatherIconSize
                                onSliderValueChanged: {
                                    SettingsData.setDesktopWeatherIconSize(value)
                                }
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            StyledText {
                                text: Math.round(SettingsData.desktopWeatherIconSize) + "px"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                width: 60
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: "Spacing"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                width: 80
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            DarkSlider {
                                width: parent.width - 80 - Theme.spacingM - 60
                                height: 40
                                minimum: 4
                                maximum: 24
                                value: SettingsData.desktopWeatherSpacing
                                onSliderValueChanged: {
                                    SettingsData.setDesktopWeatherSpacing(value)
                                }
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            StyledText {
                                text: Math.round(SettingsData.desktopWeatherSpacing) + "px"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                width: 60
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: "Padding"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                width: 80
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            DarkSlider {
                                width: parent.width - 80 - Theme.spacingM - 60
                                height: 40
                                minimum: 8
                                maximum: 32
                                value: SettingsData.desktopWeatherPadding
                                onSliderValueChanged: {
                                    SettingsData.setDesktopWeatherPadding(value)
                                }
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            StyledText {
                                text: Math.round(SettingsData.desktopWeatherPadding) + "px"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                width: 60
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: "Radius"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                width: 80
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            DarkSlider {
                                width: parent.width - 80 - Theme.spacingM - 60
                                height: 40
                                minimum: 4
                                maximum: 24
                                value: SettingsData.desktopWeatherBorderRadius
                                onSliderValueChanged: {
                                    SettingsData.setDesktopWeatherBorderRadius(value)
                                }
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            StyledText {
                                text: Math.round(SettingsData.desktopWeatherBorderRadius) + "px"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                width: 60
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.mediumDuration
                        easing.type: Theme.emphasizedEasing
                    }
                }
            }
        }
    }
}
