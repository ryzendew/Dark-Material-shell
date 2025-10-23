import QtQuick
import QtQuick.Effects
import Quickshell.Io
import qs.Common
import qs.Modals.Common
import qs.Modals.FileBrowser
import qs.Modules.Settings
import qs.Services
import qs.Widgets

DankModal {
    id: settingsModal

    property Component settingsContent
    property alias profileBrowser: profileBrowser

    signal closingModal()

    function show() {
        open();
        // Trigger settings initialization when modal opens
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
    width: 1920
    height: 1080
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
            console.log("SettingsModal: IPC browse called with type:", type)
            if (type === "wallpaper") {
                console.log("SettingsModal: Opening wallpaper browser...")
                wallpaperBrowser.allowStacking = false;
                wallpaperBrowser.open();
                console.log("SettingsModal: Wallpaper browser open() called")
            } else if (type === "profile") {
                console.log("SettingsModal: Opening profile browser...")
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
            console.log("SettingsModal: Wallpaper browser opened successfully")
        }
        
        onFileSelected: (path) => {
            console.log("SettingsModal: Wallpaper selected:", path)
            SessionData.setWallpaper(path);
            close();
        }
        
        onDialogClosed: () => {
            console.log("SettingsModal: Wallpaper browser closed")
            allowStacking = true;
        }
    }

    settingsContent: Component {
        Item {
            anchors.fill: parent
            focus: true

            Column {
                anchors.fill: parent
                anchors.leftMargin: Theme.spacingL
                anchors.rightMargin: Theme.spacingL
                anchors.topMargin: Theme.spacingM
                anchors.bottomMargin: Theme.spacingL
                spacing: 0

                Item {
                    width: parent.width
                    height: 35

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.spacingM

                        DankIcon {
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

                    DankActionButton {
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
