import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell.Widgets
import qs.Common
import qs.Widgets
import qs.Modals.FileBrowser
import qs.Services

Item {
    id: recentAppsTab

    Component.onCompleted: {
        if (SettingsData.launcherLogoAutoSync) {
            SettingsData.syncLauncherLogoWithWallpaper()
        }
    }

    Connections {
        target: Theme
        function onColorUpdateTriggerChanged() {
            if (SettingsData.launcherLogoAutoSync) {
                Qt.callLater(() => {
                    SettingsData.syncLauncherLogoWithWallpaper()
                })
            }
        }
    }

    Connections {
        target: SettingsData
        function onLauncherLogoAutoSyncChanged() {
            if (SettingsData.launcherLogoAutoSync) {
                SettingsData.syncLauncherLogoWithWallpaper()
            }
        }
    }

    Connections {
        target: ColorPaletteService
        function onColorsExtracted() {
            if (SettingsData.launcherLogoAutoSync) {
                Qt.callLater(() => {
                    SettingsData.syncLauncherLogoWithWallpaper()
                })
            }
        }
    }

    Connections {
        target: typeof SessionData !== "undefined" ? SessionData : null
        function onWallpaperPathChanged() {
            if (SettingsData.launcherLogoAutoSync) {
                Qt.callLater(() => {
                    Qt.callLater(() => {
                        SettingsData.syncLauncherLogoWithWallpaper()
                    })
                })
            }
        }
    }

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
                height: launchPrefixSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: launchPrefixSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "terminal"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Launch Prefix"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    StyledText {
                        width: parent.width
                        text: "Add a custom prefix to all application launches. This can be used for things like 'uwsm-app', 'systemd-run', or other command wrappers."
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        wrapMode: Text.WordWrap
                    }

                    DarkTextField {
                        width: parent.width
                        text: SessionData.launchPrefix
                        placeholderText: "Enter launch prefix (e.g., 'uwsm-app')"
                        onTextEdited: {
                            SessionData.setLaunchPrefix(text)
                        }
                    }
                }
            }


            StyledRect {
                width: parent.width
                height: launcherPositionSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: launcherPositionSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "open_in_full"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Launcher Position"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    StyledText {
                        text: "Choose where the app launcher menu appears when clicked"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }

                    Row {
                        spacing: Theme.spacingM

                        Repeater {
                            model: [
                                { "value": "bottom-center", "text": "Bottom Center", "icon": "center_focus_strong" },
                                { "value": "bottom-left", "text": "Bottom Left", "icon": "west" },
                                { "value": "bottom-right", "text": "Bottom Right", "icon": "east" }
                            ]

                            Rectangle {
                                width: 120
                                height: 80
                                radius: Theme.cornerRadius
                                color: SettingsData.launcherPosition === modelData.value ? Theme.primary : Theme.surfaceContainerHigh
                                border.color: SettingsData.launcherPosition === modelData.value ? Theme.primary : Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.3)
                                border.width: 1

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        SettingsData.launcherPosition = modelData.value
                                    }
                                }

                                Column {
                                    anchors.centerIn: parent
                                    spacing: Theme.spacingXS

                                    DarkIcon {
                                        name: modelData.icon
                                        size: Theme.iconSize
                                        color: SettingsData.launcherPosition === modelData.value ? Theme.onPrimary : Theme.surfaceText
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }

                                    StyledText {
                                        text: modelData.text
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: SettingsData.launcherPosition === modelData.value ? Theme.onPrimary : Theme.surfaceText
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: launcherButtonSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: launcherButtonSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "apps"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Launcher Button"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Logo Size"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 24
                            value: SettingsData.launcherLogoSize
                            minimum: 0
                            maximum: 64
                            unit: "px"
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setLauncherLogoSize(newValue)
                                                  }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            Column {
                                width: parent.width - autoSyncToggle.width - Theme.spacingM
                                spacing: Theme.spacingXS
                                anchors.verticalCenter: parent.verticalCenter

                                StyledText {
                                    text: "Logo Color (RGB)"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceText
                                    font.weight: Font.Medium
                                }

                                StyledText {
                                    text: SettingsData.launcherLogoAutoSync ? "Automatically syncing with wallpaper colors" : "Manual color control"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                    visible: true
                                }
                            }

                            DarkToggle {
                                id: autoSyncToggle
                                anchors.verticalCenter: parent.verticalCenter
                                checked: SettingsData.launcherLogoAutoSync
                                onToggled: checked => {
                                    SettingsData.setLauncherLogoAutoSync(checked)
                                    if (checked) {
                                        SettingsData.syncLauncherLogoWithWallpaper()
                                    }
                                }
                            }
                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacingS

                            Column {
                                width: (parent.width - parent.spacing * 2) / 3
                                spacing: Theme.spacingXS

                                StyledText {
                                    text: "Red"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                    font.weight: Font.Medium
                                }

                                DarkSlider {
                                    width: parent.width
                                    height: 24
                                    value: Math.round(SettingsData.launcherLogoRed * 255)
                                    minimum: 0
                                    maximum: 255
                                    unit: ""
                                    showValue: true
                                    wheelEnabled: false
                                    onSliderValueChanged: newValue => {
                                                              SettingsData.setLauncherLogoRed(newValue / 255)
                                                          }
                                }
                            }

                            Column {
                                width: (parent.width - parent.spacing * 2) / 3
                                spacing: Theme.spacingXS

                                StyledText {
                                    text: "Green"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                    font.weight: Font.Medium
                                }

                                DarkSlider {
                                    width: parent.width
                                    height: 24
                                    value: Math.round(SettingsData.launcherLogoGreen * 255)
                                    minimum: 0
                                    maximum: 255
                                    unit: ""
                                    showValue: true
                                    wheelEnabled: false
                                    onSliderValueChanged: newValue => {
                                                              SettingsData.setLauncherLogoGreen(newValue / 255)
                                                          }
                                }
                            }

                            Column {
                                width: (parent.width - parent.spacing * 2) / 3
                                spacing: Theme.spacingXS

                                StyledText {
                                    text: "Blue"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                    font.weight: Font.Medium
                                }

                                DarkSlider {
                                    width: parent.width
                                    height: 24
                                    value: Math.round(SettingsData.launcherLogoBlue * 255)
                                    minimum: 0
                                    maximum: 255
                                    unit: ""
                                    showValue: true
                                    wheelEnabled: false
                                    onSliderValueChanged: newValue => {
                                                              SettingsData.setLauncherLogoBlue(newValue / 255)
                                                          }
                                }
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Logo Drop Shadow Opacity"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        DarkSlider {
                            width: parent.width
                            height: 24
                            value: Math.round(SettingsData.launcherLogoDropShadowOpacity * 100)
                            minimum: 0
                            maximum: 100
                            unit: "%"
                            showValue: true
                            wheelEnabled: false
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setLauncherLogoDropShadowOpacity(
                                                          newValue / 100)
                                                  }
                        }
                    }

                    DarkToggle {
                        width: parent.width
                        text: "Use OS Logo"
                        description: "Display operating system logo instead of apps icon"
                        checked: SettingsData.useOSLogo && !SettingsData.useCustomLauncherImage
                        onToggled: checked => {
                                       if (checked) {
                                           SettingsData.setUseCustomLauncherImage(false)
                                       }
                                       return SettingsData.setUseOSLogo(checked)
                                   }
                    }

                    Row {
                        width: parent.width - Theme.spacingL
                        spacing: Theme.spacingL
                        visible: SettingsData.useOSLogo
                        opacity: visible ? 1 : 0
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.spacingL

                        Column {
                            width: 120
                            spacing: Theme.spacingS

                            StyledText {
                                text: "Color Override"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                            }

                            DarkTextField {
                                width: parent.width
                                text: SettingsData.osLogoColorOverride
                                placeholderText: "#FFFFFF"
                                onTextEdited: {
                                    SettingsData.setOSLogoColorOverride(text)
                                }
                            }
                        }

                        Column {
                            width: 120
                            spacing: Theme.spacingS

                            StyledText {
                                text: "Contrast"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                            }

                            DarkSlider {
                                width: parent.width
                                height: 24
                                value: SettingsData.osLogoContrast
                                minimum: 0
                                maximum: 2
                                unit: ""
                                showValue: true
                                wheelEnabled: false
                                onSliderValueChanged: newValue => {
                                                          SettingsData.setOSLogoContrast(newValue)
                                                      }
                            }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: customLauncherSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: customLauncherSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "image"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Custom Launcher Image"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    DarkToggle {
                        width: parent.width
                        text: "Use Custom Image"
                        description: "Use a custom PNG image instead of the default apps icon"
                        checked: SettingsData.useCustomLauncherImage
                        onToggled: checked => {
                                       if (checked) {
                                           SettingsData.setUseOSLogo(false)
                                       }
                                       return SettingsData.setUseCustomLauncherImage(checked)
                                   }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingL
                        visible: SettingsData.useCustomLauncherImage
                        opacity: visible ? 1 : 0

                        Rectangle {
                            width: 120
                            height: 120
                            radius: Theme.cornerRadius
                            color: Qt.rgba(Theme.surfaceContainer.r,
                                           Theme.surfaceContainer.g,
                                           Theme.surfaceContainer.b, 0.3)
                            border.color: Qt.rgba(Theme.outline.r,
                                                  Theme.outline.g,
                                                  Theme.outline.b, 0.2)
                            border.width: 1

                            Item {
                                anchors.fill: parent
                                anchors.margins: 1

                                Image {
                                    id: previewImage
                                    anchors.fill: parent
                                    source: SettingsData.customLauncherImagePath ? "file://" + SettingsData.customLauncherImagePath : ""
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true

                                    layer.enabled: SettingsData.launcherLogoRed !== 1.0 || SettingsData.launcherLogoGreen !== 1.0 || SettingsData.launcherLogoBlue !== 1.0
                                    layer.effect: ColorOverlay {
                                        color: Qt.rgba(SettingsData.launcherLogoRed, SettingsData.launcherLogoGreen, SettingsData.launcherLogoBlue, 0.8)
                                    }
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    color: Qt.rgba(0, 0, 0, 0.3)
                                    visible: launcherImageMouseArea.containsMouse

                                    Row {
                                        anchors.centerIn: parent
                                        spacing: Theme.spacingS

                                        DarkIcon {
                                            name: "edit"
                                            size: 16
                                            color: Theme.surfaceText
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        StyledText {
                                            text: "Click to change"
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Theme.surfaceText
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }
                                }

                                MouseArea {
                                    id: launcherImageMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        launcherImageBrowser.open()
                                    }
                                }
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: Theme.spacingS

                            StyledText {
                                text: SettingsData.customLauncherImagePath ? SettingsData.customLauncherImagePath.split('/').pop() : "No image selected"
                                font.pixelSize: Theme.fontSizeSmall
                                color: SettingsData.customLauncherImagePath ? Theme.surfaceVariantText : Theme.outline
                                elide: Text.ElideMiddle
                                width: parent.width
                            }

                            StyledText {
                                text: "Click the preview or browse to select a PNG image file for the launcher button"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: viewModeSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: viewModeSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "view_list"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "View Mode"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "App Launcher Display Mode"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            DarkButtonGroup {
                                id: launcherViewModeGroup
                                width: parent.width
                                model: ["List", "Grid"]
                                currentIndex: SettingsData.appLauncherViewMode === "list" ? 0 : 1
                                selectionMode: "single"
                                onSelectionChanged: (index, selected) => {
                                                      if (selected) {
                                                          var mode = index === 0 ? "list" : "grid"
                                                          SettingsData.setAppLauncherViewMode(mode)
                                                      }
                                                  }
                            }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: recentlyUsedSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: recentlyUsedSection

                    property var rankedAppsModel: {
                        var apps = []
                        for (var appId in (AppUsageHistoryData.appUsageRanking
                                           || {})) {
                            var appData = (AppUsageHistoryData.appUsageRanking
                                           || {})[appId]
                            apps.push({
                                          "id": appId,
                                          "name": appData.name,
                                          "exec": appData.exec,
                                          "icon": appData.icon,
                                          "comment": appData.comment,
                                          "usageCount": appData.usageCount,
                                          "lastUsed": appData.lastUsed
                                      })
                        }
                        apps.sort(function (a, b) {
                            if (a.usageCount !== b.usageCount)
                                return b.usageCount - a.usageCount

                            return a.name.localeCompare(b.name)
                        })
                        return apps.slice(0, 20)
                    }

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "history"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Recently Used Apps"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Item {
                            width: parent.width - parent.children[0].width
                                   - parent.children[1].width
                                   - clearAllButton.width - Theme.spacingM * 3
                            height: 1
                        }

                        DarkActionButton {
                            id: clearAllButton

                            iconName: "delete_sweep"
                            iconSize: Theme.iconSize - 2
                            iconColor: Theme.error
                            anchors.verticalCenter: parent.verticalCenter
                            onClicked: {
                                AppUsageHistoryData.appUsageRanking = {}
                                SettingsData.saveSettings()
                            }
                        }
                    }

                    StyledText {
                        width: parent.width
                        text: "Apps are ordered by usage frequency, then last used, then alphabetically."
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        wrapMode: Text.WordWrap
                    }

                    Column {
                        id: rankedAppsList

                        width: parent.width
                        spacing: Theme.spacingS

                        Repeater {
                            model: recentlyUsedSection.rankedAppsModel

                            delegate: Rectangle {
                                width: rankedAppsList.width
                                height: 48
                                radius: Theme.cornerRadius
                                color: Qt.rgba(Theme.surfaceContainer.r,
                                               Theme.surfaceContainer.g,
                                               Theme.surfaceContainer.b, 0.3)
                                border.color: Qt.rgba(Theme.outline.r,
                                                      Theme.outline.g,
                                                      Theme.outline.b, 0.1)
                                border.width: 1

                                Row {
                                    anchors.left: parent.left
                                    anchors.leftMargin: Theme.spacingM
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: Theme.spacingM

                                    StyledText {
                                        text: (index + 1).toString()
                                        font.pixelSize: Theme.fontSizeSmall
                                        font.weight: Font.Medium
                                        color: Theme.primary
                                        width: 20
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Image {
                                        width: 24
                                        height: 24
                                        source: modelData.icon ? "image://icon/" + modelData.icon : "image://icon/application-x-executable"
                                        sourceSize.width: 24
                                        sourceSize.height: 24
                                        fillMode: Image.PreserveAspectFit
                                        anchors.verticalCenter: parent.verticalCenter
                                        onStatusChanged: {
                                            if (status === Image.Error)
                                                source = "image://icon/application-x-executable"
                                        }
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 2

                                        StyledText {
                                            text: modelData.name
                                                  || "Unknown App"
                                            font.pixelSize: Theme.fontSizeMedium
                                            font.weight: Font.Medium
                                            color: Theme.surfaceText
                                        }

                                        StyledText {
                                            text: {
                                                if (!modelData.lastUsed)
                                                    return "Never used"

                                                var date = new Date(modelData.lastUsed)
                                                var now = new Date()
                                                var diffMs = now - date
                                                var diffMins = Math.floor(
                                                            diffMs / (1000 * 60))
                                                var diffHours = Math.floor(
                                                            diffMs / (1000 * 60 * 60))
                                                var diffDays = Math.floor(
                                                            diffMs / (1000 * 60 * 60 * 24))
                                                if (diffMins < 1)
                                                    return "Last launched just now"

                                                if (diffMins < 60)
                                                    return "Last launched " + diffMins + " minute"
                                                            + (diffMins === 1 ? "" : "s") + " ago"

                                                if (diffHours < 24)
                                                    return "Last launched " + diffHours + " hour"
                                                            + (diffHours === 1 ? "" : "s") + " ago"

                                                if (diffDays < 7)
                                                    return "Last launched " + diffDays + " day"
                                                            + (diffDays === 1 ? "" : "s") + " ago"

                                                return "Last launched " + date.toLocaleDateString()
                                            }
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Theme.surfaceVariantText
                                        }
                                    }
                                }

                                DarkActionButton {
                                    anchors.right: parent.right
                                    anchors.rightMargin: Theme.spacingM
                                    anchors.verticalCenter: parent.verticalCenter
                                    circular: true
                                    iconName: "close"
                                    iconSize: 16
                                    iconColor: Theme.error
                                    onClicked: {
                                        var currentRanking = Object.assign(
                                                    {},
                                                    AppUsageHistoryData.appUsageRanking
                                                    || {})
                                        delete currentRanking[modelData.id]
                                        AppUsageHistoryData.appUsageRanking = currentRanking
                                        SettingsData.saveSettings()
                                    }
                                }
                            }
                        }

                        StyledText {
                            width: parent.width
                            text: recentlyUsedSection.rankedAppsModel.length
                                  === 0 ? "No apps have been launched yet." : ""
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.surfaceVariantText
                            horizontalAlignment: Text.AlignHCenter
                            visible: recentlyUsedSection.rankedAppsModel.length === 0
                        }
                    }
                }
            }
        }
    }

    FileBrowserModal {
        id: launcherImageBrowser

        browserTitle: "Select Launcher Image"
        browserIcon: "image"
        browserType: "generic"
        fileExtensions: ["*.png"]
        onFileSelected: path => {
                            SettingsData.setCustomLauncherImagePath(path)
                            close()
                        }
    }
}
