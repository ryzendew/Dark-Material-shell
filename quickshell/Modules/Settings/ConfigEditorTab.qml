import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Widgets
import qs.Modules.Settings

Item {
    id: root

    property int currentSubTabIndex: 0

    Column {
        anchors.fill: parent
        spacing: Theme.spacingM

        DarkTabBar {
            id: subTabBar
            width: parent.width
            height: 48
            currentIndex: root.currentSubTabIndex
            spacing: Theme.spacingS
            equalWidthTabs: true

            model: [
                { icon: "keyboard", text: "Keybinds" },
                { icon: "play_arrow", text: "Execs" },
                { icon: "settings", text: "General" },
                { icon: "rule", text: "Rules" },
                { icon: "eco", text: "Env" },
                { icon: "palette", text: "Colors" }
            ]

            onTabClicked: function(index) {
                root.currentSubTabIndex = index
            }
        }

        StackLayout {
            id: subTabStack
            width: parent.width
            height: parent.height - subTabBar.height - Theme.spacingM
            currentIndex: root.currentSubTabIndex

            Loader {
                id: keybindsLoader
                width: parent.width
                height: parent.height
                active: root.currentSubTabIndex === 0
                visible: active
                asynchronous: true
                sourceComponent: KeybindsTab {
                }
                onLoaded: {
                    if (item) {
                        item.width = Qt.binding(() => keybindsLoader.width)
                        item.height = Qt.binding(() => keybindsLoader.height)
                    }
                }
            }

            Loader {
                id: execsLoader
                width: parent.width
                height: parent.height
                active: root.currentSubTabIndex === 1
                visible: active
                asynchronous: true
                sourceComponent: ExecsTab {
                }
                onLoaded: {
                    if (item) {
                        item.width = Qt.binding(() => execsLoader.width)
                        item.height = Qt.binding(() => execsLoader.height)
                    }
                }
            }

            Loader {
                id: generalLoader
                width: parent.width
                height: parent.height
                active: root.currentSubTabIndex === 2
                visible: active
                asynchronous: true
                sourceComponent: GeneralTab {
                }
                onLoaded: {
                    if (item) {
                        item.width = Qt.binding(() => generalLoader.width)
                        item.height = Qt.binding(() => generalLoader.height)
                    }
                }
            }

            Loader {
                id: rulesLoader
                width: parent.width
                height: parent.height
                active: root.currentSubTabIndex === 3
                visible: active
                asynchronous: true
                sourceComponent: RulesTab {
                }
                onLoaded: {
                    if (item) {
                        item.width = Qt.binding(() => rulesLoader.width)
                        item.height = Qt.binding(() => rulesLoader.height)
                    }
                }
            }

            Loader {
                id: envLoader
                width: parent.width
                height: parent.height
                active: root.currentSubTabIndex === 4
                visible: active
                asynchronous: true
                sourceComponent: EnvTab {
                }
                onLoaded: {
                    if (item) {
                        item.width = Qt.binding(() => envLoader.width)
                        item.height = Qt.binding(() => envLoader.height)
                    }
                }
            }

            Loader {
                id: colorsLoader
                width: parent.width
                height: parent.height
                active: root.currentSubTabIndex === 5
                visible: active
                asynchronous: true
                sourceComponent: ColorsTab {
                }
                onLoaded: {
                    if (item) {
                        item.width = Qt.binding(() => colorsLoader.width)
                        item.height = Qt.binding(() => colorsLoader.height)
                    }
                }
            }
        }
    }
}

