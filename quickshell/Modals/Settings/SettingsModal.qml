import QtQuick
import QtQuick.Effects
import Quickshell.Io
import qs.Common
import qs.Modals.Common
import qs.Modals.FileBrowser
import qs.Modules.Settings
import qs.Services
import qs.Widgets

DarkModal {
    id: settingsModal

    property Component settingsContent
    property alias profileBrowser: profileBrowser
    
    showBackground: true

    signal closingModal()

    function show() {
        open();
        Qt.callLater(function() {
            if (settingsContent && settingsContent.forceInitialize) {
                settingsContent.forceInitialize()
            }
        })
    }

    function hide() {
        close();
    }

    function toggle() {
        if (shouldBeVisible) {
            hide();
        } else {
            show();
        }
    }

    objectName: "settingsModal"
    positioning: "center"
    width: 1236
    height: 990
    visible: false
    onBackgroundClicked: () => {
        return hide();
    }
    content: settingsContent

    IpcHandler {
        function open(): string {
            settingsModal.show();
            return "SETTINGS_OPEN_SUCCESS";
        }

        function close(): string {
            settingsModal.hide();
            return "SETTINGS_CLOSE_SUCCESS";
        }

        function toggle(): string {
            settingsModal.toggle();
            return "SETTINGS_TOGGLE_SUCCESS";
        }

        target: "settings"
    }


    IpcHandler {
        function browse(type: string) {
            if (type === "wallpaper") {
                wallpaperBrowser.allowStacking = false;
                wallpaperBrowser.open();
            } else if (type === "profile") {
                profileBrowser.allowStacking = false;
                profileBrowser.open();
            }
        }

        target: "file"
    }

    FileBrowserModal {
        id: profileBrowser

        allowStacking: true
        browserTitle: "Select Profile Image"
        browserIcon: "person"
        browserType: "profile"
        fileExtensions: ["*.jpg", "*.jpeg", "*.png", "*.bmp", "*.gif", "*.webp"]
        onFileSelected: (path) => {
            PortalService.setProfileImage(path);
            close();
        }
        onDialogClosed: () => {
            if (settingsModal) {
                settingsModal.allowFocusOverride = false;
                settingsModal.shouldHaveFocus = Qt.binding(() => {
                    return settingsModal.shouldBeVisible;
                });
            }
            allowStacking = true;
        }
    }

    FileBrowserModal {
        id: wallpaperBrowser

        allowStacking: true
        browserTitle: "Select Wallpaper"
        browserIcon: "wallpaper"
        browserType: "wallpaper"
        fileExtensions: ["*.jpg", "*.jpeg", "*.png", "*.bmp", "*.gif", "*.webp"]
        
        onOpened: {
        }
        
        onFileSelected: (path) => {
            SessionData.setWallpaper(path);
            close();
        }
        
        onDialogClosed: () => {
            allowStacking = true;
        }
    }

    settingsContent: Component {
        Item {
            anchors.fill: parent
            focus: true
            clip: true

            Column {
                anchors.fill: parent
                anchors.leftMargin: Theme.spacingL
                anchors.rightMargin: Theme.spacingL
                anchors.topMargin: Theme.spacingM
                anchors.bottomMargin: Theme.spacingL
                spacing: 0
                clip: true

                Item {
                    width: parent.width
                    height: 35

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "settings"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Settings"
                            font.pixelSize: Theme.fontSizeXLarge
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                            anchors.verticalCenter: parent.verticalCenter
                        }

                    }

                    DarkActionButton {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        circular: false
                        iconName: "close"
                        iconSize: Theme.iconSize - 4
                        iconColor: Theme.surfaceText
                        onClicked: () => {
                            return settingsModal.hide();
                        }
                    }

                }

                Row {
                    width: parent.width
                    height: parent.height - 35
                    spacing: 0
                    clip: true

                    SettingsSidebar {
                        id: sidebar

                        parentModal: settingsModal
                        onCurrentIndexChanged: {
                            if (contentLoader.item) {
                                contentLoader.item.currentIndex = currentIndex
                            }
                        }
                    }

                    Loader {
                        id: contentLoader
                        width: parent.width - sidebar.width
                        height: parent.height
                        source: "SettingsContent.qml"
                        onLoaded: {
                            item.parentModal = settingsModal
                            item.currentIndex = sidebar.currentIndex
                        }
                    }

                }

            }

        }

    }

}
