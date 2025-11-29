import QtQuick
import qs.Common
import qs.Modules.Settings

Item {
    id: root

    property int currentIndex: 0
    property var parentModal: null

    Component.onCompleted: {
        
        Qt.callLater(function() {
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
                running = false
                refreshAllSettings()
            } else {
            }
        }
    }

    function refreshAllSettings() {
        
        if (typeof ColorPaletteService !== 'undefined') {
            ColorPaletteService.updateAvailableThemes()
        }
        
        if (typeof SettingsData !== 'undefined') {
            SettingsData.loadSettings()
        }
        
        if (typeof Theme !== 'undefined') {
            Theme.generateSystemThemesFromCurrentTheme()
        }
        
    }

    function forceInitialize() {
        settingsInitTimer.running = true
    }

    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: getContentMargin()
        anchors.rightMargin: getContentMargin()
        anchors.bottomMargin: getContentMargin()
        anchors.topMargin: 0
        color: "transparent"
        clip: true
        
        function getContentMargin() {
            const screenWidth = Screen.width
            if (screenWidth >= 1920) return Theme.spacingXL
            if (screenWidth >= 1280) return Theme.spacingL
            return Theme.spacingM
        }

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
            id: desktopWidgetsLoader

            anchors.fill: parent
            active: root.currentIndex === 5
            visible: active
            asynchronous: true

            sourceComponent: DesktopWidgetsTab {
            }

        }

        Loader {
            id: positioningLoader

            anchors.fill: parent
            active: root.currentIndex === 6
            visible: active
            asynchronous: true

            sourceComponent: PositioningTab {
            }

        }

        Loader {
            id: launcherLoader

            anchors.fill: parent
            active: root.currentIndex === 7
            visible: active
            asynchronous: true

            sourceComponent: LauncherTab {
            }

        }

        Loader {
            id: defaultAppsLoader

            anchors.fill: parent
            active: root.currentIndex === 8
            visible: active
            asynchronous: true

            sourceComponent: DefaultAppsTab {
            }

        }

        Loader {
            id: displaysLoader

            anchors.fill: parent
            active: root.currentIndex === 9
            visible: active
            asynchronous: true

            sourceComponent: DisplaysTab {
            }

        }

        Loader {
            id: soundLoader

            anchors.fill: parent
            active: root.currentIndex === 10
            visible: active
            asynchronous: true

            sourceComponent: SoundTab {
            }

        }

        Loader {
            id: networkLoader

            anchors.fill: parent
            active: root.currentIndex === 11
            visible: active
            asynchronous: true

            sourceComponent: NetworkTab {
                parentModal: root.parentModal
            }

        }

        Loader {
            id: keyboardLangLoader

            anchors.fill: parent
            active: root.currentIndex === 12
            visible: active
            asynchronous: true

            sourceComponent: KeyboardLangTab {
            }

        }

        Loader {
            id: timeLoader

            anchors.fill: parent
            active: root.currentIndex === 13
            visible: active
            asynchronous: true

            sourceComponent: TimeTab {
            }

        }

        Loader {
            id: powerLoader

            anchors.fill: parent
            active: root.currentIndex === 14
            visible: active
            asynchronous: true

            sourceComponent: PowerTab {
            }

        }

        Loader {
            id: aboutLoader

            anchors.fill: parent
            active: root.currentIndex === 15
            visible: active
            asynchronous: true

            sourceComponent: AboutTab {
            }

        }

        Loader {
            id: weatherLoader

            anchors.fill: parent
            active: root.currentIndex === 16
            visible: active
            asynchronous: true

            sourceComponent: WeatherTab {
            }

        }

        Loader {
            id: keybindsLoader

            anchors.fill: parent
            active: root.currentIndex === 17
            visible: active
            asynchronous: true

            source: "../../Modules/Settings/KeybindsTab.qml"

        }

    }

}
