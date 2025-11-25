import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets

Rectangle {
    id: root

    property string iconName: PerformanceService.getCurrentModeInfo().icon
    property color iconColor: PerformanceService.getCurrentModeInfo().color
    property string primaryText: PerformanceService.isChanging ? "Changing..." : PerformanceService.getCurrentModeInfo().name
    property string secondaryText: ""
    property bool isActive: false

    signal toggled()
    signal wheelEvent(var wheelEvent)

    width: parent ? parent.width : 220
    height: 60
    radius: Theme.cornerRadius

    function hoverTint(base) {
        const factor = 1.2
        return Theme.isLightMode ? Qt.darker(base, factor) : Qt.lighter(base, factor)
    }

    readonly property color _containerBg:
        Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b,
                Theme.getContentBackgroundAlpha() * SettingsData.controlCenterWidgetBackgroundOpacity)

    color: _containerBg
    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.10)
    border.width: 1
    antialiasing: true

    // Color overlay based on performance mode
    Rectangle {
        id: modeOverlay
        anchors.fill: parent
        radius: parent.radius
        color: PerformanceService.getCurrentModeInfo().color
        opacity: 0.15
        antialiasing: true
        Behavior on color {
            ColorAnimation {
                duration: Theme.mediumDuration
                easing.type: Easing.OutCubic
            }
        }
    }

    // Drop shadow
    layer.enabled: true
    layer.effect: DropShadow {
        horizontalOffset: 0
        verticalOffset: 2
        radius: 8
        samples: 16
        color: Qt.rgba(0, 0, 0, SettingsData.controlCenterDropShadowOpacity)
        transparentBorder: true
    }

    readonly property color _labelPrimary: Theme.surfaceText
    readonly property color _labelSecondary: Theme.surfaceVariantText
    readonly property color _tileBgActive: Theme.primary
    readonly property color _tileBgInactive: {
        const transparency = Theme.popupTransparency || 0.92
        const surface = Theme.surfaceContainer || Qt.rgba(0.1, 0.1, 0.1, 1)
        return Qt.rgba(surface.r, surface.g, surface.b, transparency)
    }
    readonly property color _tileRingActive:
        Qt.rgba(Theme.primaryText.r, Theme.primaryText.g, Theme.primaryText.b, 0.22)
    readonly property color _tileRingInactive:
        Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.18)
    readonly property color _tileIconActive: Theme.primaryContainer
    readonly property color _tileIconInactive: Theme.primary

    property int _padH: Theme.spacingS
    property int _tileSize: 48
    property int _tileRadius: Theme.cornerRadius

    Rectangle {
        id: rightHoverOverlay
        anchors.fill: parent
        radius: root.radius
        z: 2
        visible: false
        color: hoverTint(_containerBg)
        opacity: 0.08
        antialiasing: true
        Behavior on opacity { NumberAnimation { duration: Theme.shortDuration } }
    }

    Row {
        id: row
        anchors.fill: parent
        anchors.leftMargin: _padH
        anchors.rightMargin: Theme.spacingM
        spacing: Theme.spacingM
        z: 1

        Item {
            id: iconTile
            z: 1
            width: _tileSize
            height: _tileSize
            anchors.verticalCenter: parent.verticalCenter

            DarkIcon {
                anchors.centerIn: parent
                name: root.iconName
                size: Theme.iconSize
                color: root.iconColor
            }

            MouseArea {
                id: tileMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.toggled()
            }
        }

        Item {
            id: body
            width: row.width - iconTile.width - row.spacing
            height: row.height

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                StyledText {
                    width: parent.width
                    text: root.primaryText
                    color: _labelPrimary
                    font.pixelSize: Theme.fontSizeMedium
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                    wrapMode: Text.NoWrap
                }
                StyledText {
                    width: parent.width
                    text: root.secondaryText
                    color: _labelSecondary
                    font.pixelSize: Theme.fontSizeSmall
                    visible: text.length > 0
                    elide: Text.ElideRight
                    wrapMode: Text.NoWrap
                }
            }

            MouseArea {
                id: bodyMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: { rightHoverOverlay.visible = true; rightHoverOverlay.opacity = 0.08 }
                onExited:  { rightHoverOverlay.opacity = 0.0; rightHoverOverlay.visible = false }
                onPressed: rightHoverOverlay.opacity = 0.16
                onReleased: rightHoverOverlay.opacity = containsMouse ? 0.08 : 0.0
                onClicked: {
                    if (PerformanceService.isChanging) return
                    
                    // Cycle through modes: balanced -> performance -> powersave -> balanced
                    const modes = ["balanced", "performance", "power-saver"]
                    const currentIndex = modes.indexOf(PerformanceService.currentMode)
                    const nextIndex = (currentIndex + 1) % modes.length
                    PerformanceService.setMode(modes[nextIndex])
                }
                onWheel: function (ev) {
                    root.wheelEvent(ev)
                }
            }
        }
    }

    focus: true
    Keys.onPressed: function (ev) {
        if (ev.key === Qt.Key_Space || ev.key === Qt.Key_Return) { 
            if (PerformanceService.isChanging) return
            
            // Cycle through modes: balanced -> performance -> powersave -> balanced
            const modes = ["balanced", "performance", "power-saver"]
            const currentIndex = modes.indexOf(PerformanceService.currentMode)
            const nextIndex = (currentIndex + 1) % modes.length
            PerformanceService.setMode(modes[nextIndex])
            ev.accepted = true 
        }
    }
}