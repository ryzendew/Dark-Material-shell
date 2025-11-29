import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Modals
import qs.Modals.FileBrowser
import qs.Services
import qs.Widgets

Item {
    id: windowSizingTab

    property var parentModal: null

    Component.onCompleted: {
        if (parentModal) {
            parentModal.positioning = "custom"
            const x = SettingsData.settingsWindowX >= 0 ? SettingsData.settingsWindowX : getDefaultX()
            const y = SettingsData.settingsWindowY >= 0 ? SettingsData.settingsWindowY : getDefaultY()
            parentModal.customPosition = Qt.point(x, y)
        }
    }

    DarkFlickable {
        anchors.fill: parent
        anchors.topMargin: getTopMargin()
        clip: true
        contentHeight: mainColumn.height
        contentWidth: width
        
        function getTopMargin() {
            const screenHeight = Screen.height
            if (screenHeight >= 1080) return Theme.spacingM
            if (screenHeight >= 720) return Theme.spacingS
            return Theme.spacingXS
        }

        Column {
            id: mainColumn

            width: parent.width
            spacing: getColumnSpacing()
            
            function getColumnSpacing() {
                const screenHeight = Screen.height
                if (screenHeight >= 1080) return Theme.spacingL
                if (screenHeight >= 720) return Theme.spacingM
                return Theme.spacingS
            }

            StyledRect {
                width: parent.width
                height: windowSizeSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: windowSizeSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "aspect_ratio"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Window Size"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    StyledText {
                        text: "Customize the settings window dimensions"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        wrapMode: Text.WordWrap
                        width: parent.width
                        horizontalAlignment: Text.AlignLeft
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Window Width"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DarkSlider {
                            width: parent.width
                            height: Theme.scaledHeight(24)
                            value: SettingsData.settingsWindowWidth > 0 ? SettingsData.settingsWindowWidth : getDefaultWidth()
                            minimum: getMinWidth()
                            maximum: Math.min(Screen.width - 40, 3000)
                            unit: "px"
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                SettingsData.setSettingsWindowWidth(newValue)
                                if (parentModal) {
                                    parentModal.width = newValue
                                }
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Window Height"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DarkSlider {
                            width: parent.width
                            height: Theme.scaledHeight(24)
                            value: SettingsData.settingsWindowHeight > 0 ? SettingsData.settingsWindowHeight : getDefaultHeight()
                            minimum: getMinHeight()
                            maximum: Math.min(Screen.height - 40, 2000)
                            unit: "px"
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                SettingsData.setSettingsWindowHeight(newValue)
                                if (parentModal) {
                                    parentModal.height = newValue
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.outline
                        opacity: 0.2
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Preset Sizes"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacingS

                            Rectangle {
                                width: (parent.width - Theme.spacingS * 2) / 3
                                height: Theme.scaledHeight(32)
                                radius: Theme.cornerRadius
                                color: presetMouseArea1.containsMouse ? Theme.surfaceVariant : Theme.surfaceContainer
                                border.color: Theme.outline
                                border.width: 1

                                StyledText {
                                    text: "Small"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceText
                                    anchors.centerIn: parent
                                }

                                MouseArea {
                                    id: presetMouseArea1
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        const width = getSmallPresetWidth()
                                        const height = getSmallPresetHeight()
                                        SettingsData.setSettingsWindowWidth(width)
                                        SettingsData.setSettingsWindowHeight(height)
                                        if (parentModal) {
                                            parentModal.width = width
                                            parentModal.height = height
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                width: (parent.width - Theme.spacingS * 2) / 3
                                height: Theme.scaledHeight(32)
                                radius: Theme.cornerRadius
                                color: presetMouseArea2.containsMouse ? Theme.surfaceVariant : Theme.surfaceContainer
                                border.color: Theme.outline
                                border.width: 1

                                StyledText {
                                    text: "Medium"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceText
                                    anchors.centerIn: parent
                                }

                                MouseArea {
                                    id: presetMouseArea2
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        const width = getMediumPresetWidth()
                                        const height = getMediumPresetHeight()
                                        SettingsData.setSettingsWindowWidth(width)
                                        SettingsData.setSettingsWindowHeight(height)
                                        if (parentModal) {
                                            parentModal.width = width
                                            parentModal.height = height
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                width: (parent.width - Theme.spacingS * 2) / 3
                                height: Theme.scaledHeight(32)
                                radius: Theme.cornerRadius
                                color: presetMouseArea3.containsMouse ? Theme.surfaceVariant : Theme.surfaceContainer
                                border.color: Theme.outline
                                border.width: 1

                                StyledText {
                                    text: "Large"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceText
                                    anchors.centerIn: parent
                                }

                                MouseArea {
                                    id: presetMouseArea3
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        const width = getLargePresetWidth()
                                        const height = getLargePresetHeight()
                                        SettingsData.setSettingsWindowWidth(width)
                                        SettingsData.setSettingsWindowHeight(height)
                                        if (parentModal) {
                                            parentModal.width = width
                                            parentModal.height = height
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.outline
                        opacity: 0.2
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Auto Size (Recommended)"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        Rectangle {
                            width: parent.width
                            height: Theme.scaledHeight(32)
                            radius: Theme.cornerRadius
                            color: autoSizeMouseArea.containsMouse ? Theme.surfaceVariant : Theme.surfaceContainer
                            border.color: Theme.outline
                            border.width: 1

                            StyledText {
                                text: "Reset to Auto Size"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                id: autoSizeMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    SettingsData.setSettingsWindowWidth(0) // 0 means auto
                                    SettingsData.setSettingsWindowHeight(0) // 0 means auto
                                    if (parentModal) {
                                        parentModal.width = getDefaultWidth()
                                        parentModal.height = getDefaultHeight()
                                    }
                                }
                            }
                        }

                        StyledText {
                            text: "Auto sizing adjusts the window based on your screen resolution"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: windowPositionSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: windowPositionSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "open_with"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Window Position"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    StyledText {
                        text: "Choose from preset positions for the settings window"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        wrapMode: Text.WordWrap
                        width: parent.width
                        horizontalAlignment: Text.AlignLeft
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Position Presets"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacingS

                            Rectangle {
                                width: (parent.width - Theme.spacingS * 2) / 3
                                height: Theme.scaledHeight(32)
                                radius: Theme.cornerRadius
                                color: presetPosMouseArea1.containsMouse ? Theme.surfaceVariant : Theme.surfaceContainer
                                border.color: Theme.outline
                                border.width: 1

                                StyledText {
                                    text: "Top-Left"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceText
                                    anchors.centerIn: parent
                                }

                                MouseArea {
                                    id: presetPosMouseArea1
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        const x = 50
                                        const y = 50 + Theme.barHeight + Theme.spacingS // Account for top bar
                                        SettingsData.setSettingsWindowX(x)
                                        SettingsData.setSettingsWindowY(y)
                                        if (parentModal) {
                                            parentModal.positioning = "custom"
                                            parentModal.customPosition = Qt.point(x, y)
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                width: (parent.width - Theme.spacingS * 2) / 3
                                height: Theme.scaledHeight(32)
                                radius: Theme.cornerRadius
                                color: presetPosMouseArea2.containsMouse ? Theme.surfaceVariant : Theme.surfaceContainer
                                border.color: Theme.outline
                                border.width: 1

                                StyledText {
                                    text: "Top-Center"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceText
                                    anchors.centerIn: parent
                                }

                                MouseArea {
                                    id: presetPosMouseArea2
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        const x = Math.max(0, (Screen.width - (parentModal ? parentModal.width : getDefaultWidth())) / 2)
                                        const y = 50 + Theme.barHeight + Theme.spacingS // Account for top bar
                                        SettingsData.setSettingsWindowX(x)
                                        SettingsData.setSettingsWindowY(y)
                                        if (parentModal) {
                                            parentModal.positioning = "custom"
                                            parentModal.customPosition = Qt.point(x, y)
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                width: (parent.width - Theme.spacingS * 2) / 3
                                height: Theme.scaledHeight(32)
                                radius: Theme.cornerRadius
                                color: presetPosMouseArea6.containsMouse ? Theme.surfaceVariant : Theme.surfaceContainer
                                border.color: Theme.outline
                                border.width: 1

                                StyledText {
                                    text: "Top-Right"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceText
                                    anchors.centerIn: parent
                                }

                                MouseArea {
                                    id: presetPosMouseArea6
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        const x = Math.max(0, Screen.width - (parentModal ? parentModal.width : getDefaultWidth()) - 50)
                                        const y = 50 + Theme.barHeight + Theme.spacingS // Account for top bar
                                        SettingsData.setSettingsWindowX(x)
                                        SettingsData.setSettingsWindowY(y)
                                        if (parentModal) {
                                            parentModal.positioning = "custom"
                                            parentModal.customPosition = Qt.point(x, y)
                                        }
                                    }
                                }
                            }
                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacingS
                            topPadding: -4

                            Rectangle {
                                width: (parent.width - Theme.spacingS * 2) / 3
                                height: Theme.scaledHeight(32)
                                radius: Theme.cornerRadius
                                color: presetPosMouseArea3.containsMouse ? Theme.surfaceVariant : Theme.surfaceContainer
                                border.color: Theme.outline
                                border.width: 1

                                StyledText {
                                    text: "Bottom-Left"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceText
                                    anchors.centerIn: parent
                                }

                                MouseArea {
                                    id: presetPosMouseArea3
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        const x = 50
                                        const y = Math.max(0, Screen.height - (parentModal ? parentModal.height : getDefaultHeight()) - 50 - Theme.barHeight - Theme.spacingS) // Account for dock
                                        SettingsData.setSettingsWindowX(x)
                                        SettingsData.setSettingsWindowY(y)
                                        if (parentModal) {
                                            parentModal.positioning = "custom"
                                            parentModal.customPosition = Qt.point(x, y)
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                width: (parent.width - Theme.spacingS * 2) / 3
                                height: Theme.scaledHeight(32)
                                radius: Theme.cornerRadius
                                color: presetPosMouseArea4.containsMouse ? Theme.surfaceVariant : Theme.surfaceContainer
                                border.color: Theme.outline
                                border.width: 1

                                StyledText {
                                    text: "Bottom-Center"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceText
                                    anchors.centerIn: parent
                                }

                                MouseArea {
                                    id: presetPosMouseArea4
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        const x = Math.max(0, (Screen.width - (parentModal ? parentModal.width : getDefaultWidth())) / 2)
                                        const y = Math.max(0, Screen.height - (parentModal ? parentModal.height : getDefaultHeight()) - 50 - Theme.barHeight - Theme.spacingS) // Account for dock
                                        SettingsData.setSettingsWindowX(x)
                                        SettingsData.setSettingsWindowY(y)
                                        if (parentModal) {
                                            parentModal.positioning = "custom"
                                            parentModal.customPosition = Qt.point(x, y)
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                width: (parent.width - Theme.spacingS * 2) / 3
                                height: Theme.scaledHeight(32)
                                radius: Theme.cornerRadius
                                color: presetPosMouseArea5.containsMouse ? Theme.surfaceVariant : Theme.surfaceContainer
                                border.color: Theme.outline
                                border.width: 1

                                StyledText {
                                    text: "Bottom-Right"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceText
                                    anchors.centerIn: parent
                                }

                                MouseArea {
                                    id: presetPosMouseArea5
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        const x = Math.max(0, Screen.width - (parentModal ? parentModal.width : getDefaultWidth()) - 50)
                                        const y = Math.max(0, Screen.height - (parentModal ? parentModal.height : getDefaultHeight()) - 50 - Theme.barHeight - Theme.spacingS) // Account for dock
                                        SettingsData.setSettingsWindowX(x)
                                        SettingsData.setSettingsWindowY(y)
                                        if (parentModal) {
                                            parentModal.positioning = "custom"
                                            parentModal.customPosition = Qt.point(x, y)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.outline
                        opacity: 0.2
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Auto Position (Recommended)"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        Rectangle {
                            width: parent.width
                            height: Theme.scaledHeight(32)
                            radius: Theme.cornerRadius
                            color: autoPosMouseArea.containsMouse ? Theme.surfaceVariant : Theme.surfaceContainer
                            border.color: Theme.outline
                            border.width: 1

                            StyledText {
                                text: "Reset to Auto Position"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                id: autoPosMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    SettingsData.setSettingsWindowX(-1) // -1 means auto
                                    SettingsData.setSettingsWindowY(-1) // -1 means auto
                                    if (parentModal) {
                                        parentModal.positioning = "custom"
                                        parentModal.customPosition = Qt.point(getDefaultX(), getDefaultY())
                                    }
                                }
                            }
                        }

                        StyledText {
                            text: "Auto positioning centers the window on your screen"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: screenInfoSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: screenInfoSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "monitor"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Screen Information"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: "Screen Resolution:"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                            }

                            StyledText {
                                text: Screen.width + " × " + Screen.height
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                            }
                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: "Current Window Size:"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                            }

                            StyledText {
                                text: (parentModal ? parentModal.width : getDefaultWidth()) + " × " + (parentModal ? parentModal.height : getDefaultHeight())
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                            }
                        }
                    }
                }
            }
        }
    }

    function getDefaultWidth() {
        const screenWidth = Screen.width

        let baseWidth
        if (screenWidth >= 3840) baseWidth = 2560 // 4K -> 1440p
        else if (screenWidth >= 2560) baseWidth = 1920 // 1440p -> 1080p  
        else if (screenWidth >= 1920) baseWidth = 1280 // 1080p -> 720p
        else baseWidth = 800 // 720p or lower -> 800x600

        let scale = 1.0
        if (typeof Theme !== "undefined" && Theme.getWindowScaleFactor !== undefined) {
            scale = Theme.getWindowScaleFactor()
        }

        const scaledWidth = baseWidth * scale
        return Math.max(600, Math.min(scaledWidth, screenWidth - 40))
    }

    function getDefaultHeight() {
        const screenHeight = Screen.height

        let baseHeight
        if (screenHeight >= 2160) baseHeight = 1710 // 4K -> 1710px
        else if (screenHeight >= 1440) baseHeight = 1325 // 1440p -> 1325px
        else if (screenHeight >= 1080) baseHeight = 950 // 1080p -> 950px
        else baseHeight = 760 // 720p or lower -> 760px

        let scale = 1.0
        if (typeof Theme !== "undefined" && Theme.getWindowScaleFactor !== undefined) {
            scale = Theme.getWindowScaleFactor()
        }

        const scaledHeight = baseHeight * scale
        return Math.max(500, Math.min(scaledHeight, screenHeight - 20))
    }

    function getDefaultX() {
        const width = getDefaultWidth()
        return Math.max(0, (Screen.width - width) / 2)
    }

    function getDefaultY() {
        const height = getDefaultHeight()
        return Math.max(0, (Screen.height - height) / 2)
    }
    
    function getMinWidth() {
        const screenWidth = Screen.width
        if (screenWidth >= 1920) return 600
        if (screenWidth >= 1280) return 500
        return Math.max(400, screenWidth * 0.7)
    }
    
    function getMinHeight() {
        const screenHeight = Screen.height
        if (screenHeight >= 1080) return 400
        if (screenHeight >= 720) return 350
        return Math.max(300, screenHeight * 0.6)
    }
    
    function getSmallPresetWidth() {
        const screenWidth = Screen.width
        if (screenWidth >= 1920) return 800
        if (screenWidth >= 1280) return Math.max(600, screenWidth * 0.6)
        return Math.max(400, screenWidth * 0.85)
    }
    
    function getSmallPresetHeight() {
        const screenHeight = Screen.height
        if (screenHeight >= 1080) return 600
        if (screenHeight >= 720) return Math.max(450, screenHeight * 0.65)
        return Math.max(350, screenHeight * 0.8)
    }
    
    function getMediumPresetWidth() {
        const screenWidth = Screen.width
        if (screenWidth >= 1920) return 1280
        if (screenWidth >= 1280) return Math.max(900, screenWidth * 0.75)
        return Math.max(500, screenWidth * 0.9)
    }
    
    function getMediumPresetHeight() {
        const screenHeight = Screen.height
        if (screenHeight >= 1080) return 950
        if (screenHeight >= 720) return Math.max(650, screenHeight * 0.85)
        return Math.max(450, screenHeight * 0.9)
    }
    
    function getLargePresetWidth() {
        const screenWidth = Screen.width
        if (screenWidth >= 1920) return 1920
        if (screenWidth >= 1280) return Math.min(screenWidth - 40, 1600)
        return Math.min(screenWidth - 20, 1200)
    }
    
    function getLargePresetHeight() {
        const screenHeight = Screen.height
        if (screenHeight >= 1080) return 1325
        if (screenHeight >= 720) return Math.min(screenHeight - 40, 1000)
        return Math.min(screenHeight - 20, 700)
    }
}

