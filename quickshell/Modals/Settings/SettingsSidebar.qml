import QtQuick
import qs.Common
import qs.Modals.Settings
import qs.Widgets

Rectangle {
    id: sidebarContainer

    property int currentIndex: 0
    property var parentModal: null
    readonly property var sidebarItems: [{
        "text": "Personalization",
        "icon": "person"
    }, {
        "text": "Theme & Colors",
        "icon": "palette"
    }, {
        "text": "Dock",
        "icon": "dock_to_bottom"
    }, {
        "text": "Top Bar",
        "icon": "toolbar"
    }, {
        "text": "Widgets",
        "icon": "widgets"
    }, {
        "text": "Desktop Widgets",
        "icon": "widgets"
    }, {
        "text": "Positioning",
        "icon": "open_with"
    }, {
        "text": "Launcher",
        "icon": "apps"
    }, {
        "text": "Default Apps",
        "icon": "apps"
    }, {
        "text": "Displays",
        "icon": "monitor"
    }, {
        "text": "Sound",
        "icon": "volume_up"
    }, {
        "text": "Network",
        "icon": "wifi"
    }, {
        "text": "Bluetooth",
        "icon": "bluetooth"
    }, {
        "text": "Keyboard & Language",
        "icon": "keyboard"
    }, {
        "text": "Time & Date",
        "icon": "schedule"
    }, {
        "text": "Power",
        "icon": "power_settings_new"
    }, {
        "text": "About",
        "icon": "info"
    }, {
        "text": "Weather",
        "icon": "cloud"
    }, {
        "text": "Keybinds",
        "icon": "keyboard"
    }]

    width: getSidebarWidth()
    height: parent.height
    color: Theme.surfaceContainer
    radius: Math.max(Theme.cornerRadius, 16)
    clip: true

    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.1)
    border.width: 1
    
    function getSidebarWidth() {
        const screenWidth = Screen.width
        if (screenWidth >= 3840) return 280
        if (screenWidth >= 2560) return 260
        if (screenWidth >= 1920) return 240
        if (screenWidth >= 1280) return 220
        return Math.max(180, Math.min(220, screenWidth * 0.25))
    }

    DarkFlickable {
        id: sidebarFlickable
        anchors.fill: parent
        anchors.leftMargin: getSidebarMargin()
        anchors.rightMargin: getSidebarMargin()
        anchors.bottomMargin: getSidebarMargin()
        anchors.topMargin: getSidebarTopMargin()
        contentHeight: sidebarColumn.height
        contentWidth: width
        clip: true
        
        function getSidebarMargin() {
            const screenHeight = Screen.height
            if (screenHeight >= 1080) return Theme.spacingM
            if (screenHeight >= 720) return Theme.spacingS
            return Theme.spacingXS
        }
        
        function getSidebarTopMargin() {
            const screenHeight = Screen.height
            if (screenHeight >= 1080) return Theme.spacingL
            if (screenHeight >= 720) return Theme.spacingM
            return Theme.spacingS
        }

        Column {
            id: sidebarColumn
            width: parent.width
            spacing: getTabSpacing()
            
            function getTabSpacing() {
                const screenHeight = Screen.height
                if (screenHeight >= 1080) return Theme.spacingXS
                if (screenHeight >= 720) return 3
                return 2
            }

        ProfileSection {
                id: profileSection
            parentModal: sidebarContainer.parentModal
        }

        Rectangle {
                width: parent.width
            height: 1
            color: Theme.outline
                opacity: 0.15
                anchors.horizontalCenter: parent.horizontalCenter
        }

        Item {
            width: parent.width
                height: getSpacerHeight()
                
                function getSpacerHeight() {
                    const screenHeight = Screen.height
                    if (screenHeight >= 1080) return Theme.spacingM
                    if (screenHeight >= 720) return Theme.spacingS
                    return Theme.spacingXS
                }
        }

        Repeater {
            id: sidebarRepeater

            model: sidebarContainer.sidebarItems

            Rectangle {
                property bool isActive: sidebarContainer.currentIndex === index

                    width: parent.width
                    height: getTabHeight()
                    radius: Theme.cornerRadius
                    color: {
                        if (isActive) return Theme.primaryContainer
                        if (tabMouseArea.containsMouse) return Theme.surfaceHover
                        return "transparent"
                    }
                    
                    Rectangle {
                    anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: 3
                        height: parent.height * 0.6
                        radius: 1.5
                        color: Theme.primary
                        visible: isActive
                        opacity: isActive ? 1 : 0
                        
                        Behavior on opacity {
                            NumberAnimation { duration: Theme.shortDuration; easing.type: Theme.standardEasing }
                        }
                    }

                    function getTabHeight() {
                        const screenHeight = Screen.height
                        if (screenHeight >= 2160) return 44
                        if (screenHeight >= 1440) return 42
                        if (screenHeight >= 1080) return 40
                        if (screenHeight >= 720) return 36
                        return 32
                    }

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: getLeftMargin()
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: getRowSpacing()
                        
                        function getLeftMargin() {
                            const screenHeight = Screen.height
                            if (screenHeight >= 1080) return Theme.spacingL
                            if (screenHeight >= 720) return Theme.spacingM
                            return Theme.spacingS
                        }
                        
                        function getRowSpacing() {
                            const screenHeight = Screen.height
                            if (screenHeight >= 1080) return Theme.spacingM
                            if (screenHeight >= 720) return Theme.spacingS
                            return Theme.spacingXS
                        }

                        DarkIcon {
                            name: modelData.icon || ""
                            size: getIconSize()
                            color: {
                                if (parent.parent.isActive) {
                                    return Theme.primaryContainerText || Theme.primary
                                }
                                return Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.8)
                            }
                            anchors.verticalCenter: parent.verticalCenter
                            
                            function getIconSize() {
                                const screenHeight = Screen.height
                                if (screenHeight >= 1080) return Theme.iconSize
                                if (screenHeight >= 720) return Theme.iconSize - 2
                                return Theme.iconSize - 4
                            }
                    }

                    StyledText {
                        text: modelData.text || ""
                            font.pixelSize: getFontSize()
                            color: {
                                if (parent.parent.isActive) {
                                    return Theme.primaryContainerText || Theme.primary
                                }
                                return Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.9)
                            }
                        font.weight: parent.parent.isActive ? Font.Medium : Font.Normal
                        anchors.verticalCenter: parent.verticalCenter
                            elide: Text.ElideRight
                            width: Math.max(0, parent.parent.width - parent.getLeftMargin() * 2 - parent.getRowSpacing() - (parent.children[0] ? parent.children[0].width : 0))
                            
                            function getFontSize() {
                                const screenHeight = Screen.height
                                if (screenHeight >= 1080) return Theme.fontSizeMedium + 2
                                if (screenHeight >= 720) return Theme.fontSizeSmall + 2
                                return Theme.fontSizeSmall
                            }
                    }

                }

                MouseArea {
                    id: tabMouseArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: () => {
                        sidebarContainer.currentIndex = index;
                    }
                }

                Behavior on color {
                    ColorAnimation {
                            duration: Theme.mediumDuration
                            easing.type: Theme.standardEasing
                        }
                    }
                    
                    Behavior on opacity {
                        NumberAnimation {
                        duration: Theme.shortDuration
                        easing.type: Theme.standardEasing
                        }
                    }

                }

            }

        }

    }

}
