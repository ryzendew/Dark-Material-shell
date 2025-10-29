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
    
    showBackground: true

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
    positioning: "custom"
    width: {
        // Check if custom width is set, otherwise use auto sizing
        if (SettingsData.settingsWindowWidth && SettingsData.settingsWindowWidth > 0) {
            return SettingsData.settingsWindowWidth
        }
        const screenWidth = Screen.width
        if (screenWidth >= 3840) return 2560 // 4K -> 1440p
        if (screenWidth >= 2560) return 1920 // 1440p -> 1080p  
        if (screenWidth >= 1920) return 1280 // 1080p -> 720p
        return 800 // 720p or lower -> 800x600
    }
    height: {
        // Check if custom height is set, otherwise use auto sizing
        if (SettingsData.settingsWindowHeight && SettingsData.settingsWindowHeight > 0) {
            return SettingsData.settingsWindowHeight
        }
        const screenHeight = Screen.height
        if (screenHeight >= 2160) return 1710 // 4K -> 1710px
        if (screenHeight >= 1440) return 1325 // 1440p -> 1325px
        if (screenHeight >= 1080) return 950 // 1080p -> 950px
        return 760 // 720p or lower -> 760px
    }
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

    function getDefaultWidth() {
        const screenWidth = Screen.width
        if (screenWidth >= 3840) return 2560 // 4K -> 1440p
        if (screenWidth >= 2560) return 1920 // 1440p -> 1080p  
        if (screenWidth >= 1920) return 1280 // 1080p -> 720p
        return 800 // 720p or lower -> 800x600
    }

    function getDefaultHeight() {
        const screenHeight = Screen.height
        if (screenHeight >= 2160) return 1710 // 4K -> 1710px
        if (screenHeight >= 1440) return 1325 // 1440p -> 1325px
        if (screenHeight >= 1080) return 950 // 1080p -> 950px
        return 760 // 720p or lower -> 760px
    }

    IpcHandler {
        function browse(type: string) {
            // console.log("SettingsModal: IPC browse called with type:", type)
            if (type === "wallpaper") {
                // console.log("SettingsModal: Opening wallpaper browser...")
                wallpaperBrowser.allowStacking = false;
                wallpaperBrowser.open();
                // console.log("SettingsModal: Wallpaper browser open() called")
            } else if (type === "profile") {
                // console.log("SettingsModal: Opening profile browser...")
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
            // console.log("SettingsModal: Wallpaper browser opened successfully")
        }
        
        onFileSelected: (path) => {
            // console.log("SettingsModal: Wallpaper selected:", path)
            SessionData.setWallpaper(path);
            close();
        }
        
        onDialogClosed: () => {
            // console.log("SettingsModal: Wallpaper browser closed")
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
