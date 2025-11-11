import QtQuick
import qs.Common
import qs.Modules.Settings

Item {
    id: root

    property int currentIndex: 0
    property var parentModal: null

    Component.onCompleted: {
        // Ensure settings are refreshed when the content is loaded
        // // console.log("SettingsContent loaded, refreshing settings...")
        
        // Force initialization of all services
        Qt.callLater(function() {
            // // console.log("SettingsContent: Delayed initialization starting...")
            refreshAllSettings()
        })
    }

    Timer {
        id: settingsInitTimer
        interval: 100
        repeat: true
        running: false
        
        onTriggered: {
            if (typeof ColorPaletteService !== 'undefined' && 
                typeof SettingsData !== 'undefined' && 
                typeof Theme !== 'undefined') {
                // // console.log("SettingsContent: All services available, initializing...")
                running = false
                refreshAllSettings()
            } else {
                // // console.log("SettingsContent: Waiting for services to be available...")
            }
        }
    }

    function refreshAllSettings() {
        // // console.log("SettingsContent: Refreshing all settings...")
        
        // Force refresh ColorPaletteService
        if (typeof ColorPaletteService !== 'undefined') {
            ColorPaletteService.updateAvailableThemes()
            // // console.log("SettingsContent: ColorPaletteService refreshed")
        }
        
        // Force refresh SettingsData
        if (typeof SettingsData !== 'undefined') {
            SettingsData.loadSettings()
            // // console.log("SettingsContent: SettingsData refreshed")
        }
        
        // Force refresh Theme
        if (typeof Theme !== 'undefined') {
            Theme.generateSystemThemesFromCurrentTheme()
            // // console.log("SettingsContent: Theme refreshed")
        }
        
        // // console.log("SettingsContent: All settings refreshed")
    }

    function forceInitialize() {
        // // console.log("SettingsContent: Force initialization requested")
        settingsInitTimer.running = true
    }

    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: 0
        anchors.rightMargin: Theme.spacingS
        anchors.bottomMargin: Theme.spacingM
        anchors.topMargin: 0
        color: "transparent"
        clip: true

        Loader {
            id: personalizationLoader

            anchors.fill: parent
            active: root.currentIndex === 0
            visible: active
            asynchronous: true

            sourceComponent: Component {
                PersonalizationTab {
                    parentModal: root.parentModal
                }

            }

        }

        Loader {
            id: themeColorsLoader

            anchors.fill: parent
            active: root.currentIndex === 1
            visible: active
            asynchronous: true

            sourceComponent: ThemeColorsTab {
            }

        }

        Loader {
            id: dockLoader

            anchors.fill: parent
            active: root.currentIndex === 2
            visible: active
            asynchronous: true

            sourceComponent: Component {
                DockTab {
                }
            }

            onLoaded: {
                // Ensure the dock tab is properly initialized when loaded
                if (item) {
                    item.forceActiveFocus()
                }
            }
        }

        Loader {
            id: topBarLoader

            anchors.fill: parent
            active: root.currentIndex === 3
            visible: active
            asynchronous: true

            sourceComponent: TopBarTab {
            }

        }

        Loader {
            id: widgetsLoader

            anchors.fill: parent
            active: root.currentIndex === 4
            visible: active
            asynchronous: true

            source: "../../Modules/Settings/WidgetTweaksTab.qml"

        }

        Loader {
            id: positioningLoader

            anchors.fill: parent
            active: root.currentIndex === 5
            visible: active
            asynchronous: true

            sourceComponent: PositioningTab {
            }

        }

        Loader {
            id: launcherLoader

            anchors.fill: parent
            active: root.currentIndex === 6
            visible: active
            asynchronous: true

            sourceComponent: LauncherTab {
            }

        }

        Loader {
            id: defaultAppsLoader

            anchors.fill: parent
            active: root.currentIndex === 7
            visible: active
            asynchronous: true

            sourceComponent: DefaultAppsTab {
            }

        }

        Loader {
            id: displaysLoader

            anchors.fill: parent
            active: root.currentIndex === 8
            visible: active
            asynchronous: true

            sourceComponent: DisplaysTab {
            }

        }

        Loader {
            id: soundLoader

            anchors.fill: parent
            active: root.currentIndex === 9
            visible: active
            asynchronous: true

            sourceComponent: SoundTab {
            }

        }

        Loader {
            id: keyboardLangLoader

            anchors.fill: parent
            active: root.currentIndex === 10
            visible: active
            asynchronous: true

            sourceComponent: KeyboardLangTab {
            }

        }

        Loader {
            id: timeLoader

            anchors.fill: parent
            active: root.currentIndex === 11
            visible: active
            asynchronous: true

            sourceComponent: TimeTab {
            }

        }

        Loader {
            id: powerLoader

            anchors.fill: parent
            active: root.currentIndex === 12
            visible: active
            asynchronous: true

            sourceComponent: PowerTab {
            }

        }

        Loader {
            id: aboutLoader

            anchors.fill: parent
            active: root.currentIndex === 13
            visible: active
            asynchronous: true

            sourceComponent: AboutTab {
            }

        }

        Loader {
            id: weatherLoader

            anchors.fill: parent
            active: root.currentIndex === 14
            visible: active
            asynchronous: true

            sourceComponent: WeatherTab {
            }

        }

    }

}
