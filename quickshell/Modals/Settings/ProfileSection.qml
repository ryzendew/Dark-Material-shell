import QtQuick
import QtQuick.Effects
import qs.Common
import qs.Services
import qs.Widgets

Rectangle {
    id: root

    property var parentModal: null

    width: parent.width
    height: getProfileHeight()
    radius: Theme.cornerRadius
    color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.1)
    border.width: 0
    
    function getProfileHeight() {
        const screenHeight = Screen.height
        if (screenHeight >= 2160) return 100
        if (screenHeight >= 1440) return 90 // 1440p
        if (screenHeight >= 1080) return 80 // 1080p - balanced
        if (screenHeight >= 720) return 70 // 720p - compact
        return 65 // Below 720p - minimal
    }

    Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: Theme.spacingL
        anchors.rightMargin: Theme.spacingL
        spacing: Theme.spacingM

        Item {
            id: profileImageContainer

            width: getProfileImageSize()
            height: getProfileImageSize()
            anchors.verticalCenter: parent.verticalCenter
            
            function getProfileImageSize() {
                const screenHeight = Screen.height
                if (screenHeight >= 2160) return 64
                if (screenHeight >= 1440) return 60
                if (screenHeight >= 1080) return 56
                if (screenHeight >= 720) return 52 // 720p
                return 48 // Below 720p
            }

            DarkCircularImage {
                id: profileImage

                anchors.fill: parent
                imageSource: {
                    if (PortalService.profileImage === "") {
                        return "";
                    }
                    if (PortalService.profileImage.startsWith("/")) {
                        return "file://" + PortalService.profileImage;
                    }
                    return PortalService.profileImage;
                }
                fallbackIcon: "person"
            }

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: Qt.rgba(0, 0, 0, 0.7)
                visible: profileMouseArea.containsMouse

                Row {
                    anchors.centerIn: parent
                    spacing: 4

                    Rectangle {
                        width: getButtonSize()
                        height: getButtonSize()
                        radius: getButtonSize() / 2
                        color: Qt.rgba(255, 255, 255, 0.9)
                        
                        function getButtonSize() {
                            const screenHeight = Screen.height
                            if (screenHeight >= 1080) return 28
                            if (screenHeight >= 720) return 24
                            return 20
                        }

                        DarkIcon {
                            anchors.centerIn: parent
                            name: "edit"
                            size: getIconSize()
                            color: "black"
                            
                            function getIconSize() {
                                const screenHeight = Screen.height
                                if (screenHeight >= 1080) return 16
                                if (screenHeight >= 720) return 14
                                return 12
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: () => {
                                if (root.parentModal) {
                                    root.parentModal.allowFocusOverride = true;
                                    root.parentModal.shouldHaveFocus = false;
                                    if (root.parentModal.profileBrowser) {
                                        root.parentModal.profileBrowser.open();
                                    }
                                }
                            }
                        }

                    }

                    Rectangle {
                        width: getButtonSize()
                        height: getButtonSize()
                        radius: getButtonSize() / 2
                        color: Qt.rgba(255, 255, 255, 0.9)
                        visible: profileImage.hasImage
                        
                        function getButtonSize() {
                            const screenHeight = Screen.height
                            if (screenHeight >= 1080) return 28
                            if (screenHeight >= 720) return 24
                            return 20
                        }

                        DarkIcon {
                            anchors.centerIn: parent
                            name: "close"
                            size: getIconSize()
                            color: "black"
                            
                            function getIconSize() {
                                const screenHeight = Screen.height
                                if (screenHeight >= 1080) return 16
                                if (screenHeight >= 720) return 14
                                return 12
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: () => {
                                return PortalService.setProfileImage("");
                            }
                        }

                    }

                }

            }

            MouseArea {
                id: profileMouseArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                propagateComposedEvents: true
                acceptedButtons: Qt.NoButton
            }

        }

        Column {
            width: getTextWidth()
            anchors.verticalCenter: parent.verticalCenter
            spacing: getTextSpacing()
            
            function getTextWidth() {
                const screenHeight = Screen.height
                if (screenHeight >= 1080) return 120
                if (screenHeight >= 720) return 100
                return 90
            }
            
            function getTextSpacing() {
                const screenHeight = Screen.height
                if (screenHeight >= 1080) return Theme.spacingXS
                return 3
            }

            StyledText {
                text: UserInfoService.fullName || "User"
                font.pixelSize: getFontSize()
                font.weight: Font.Medium
                color: Theme.surfaceText
                elide: Text.ElideRight
                width: parent.width
                
                function getFontSize() {
                    const screenHeight = Screen.height
                    if (screenHeight >= 1080) return Theme.fontSizeLarge
                    if (screenHeight >= 720) return Theme.fontSizeMedium
                    return Theme.fontSizeSmall
                }
            }

            StyledText {
                text: DgopService.distribution || "Linux"
                font.pixelSize: getFontSize()
                color: Theme.surfaceVariantText
                elide: Text.ElideRight
                width: parent.width
                
                function getFontSize() {
                    const screenHeight = Screen.height
                    if (screenHeight >= 1080) return Theme.fontSizeMedium
                    if (screenHeight >= 720) return Theme.fontSizeSmall
                    return Theme.fontSizeSmall
                }
            }

        }

    }

}
