import QtQuick
import Qt5Compat.GraphicalEffects
import qs.Common
import qs.Widgets

Rectangle {
    id: root

    property string iconName: ""
    property string text: ""

    signal pressed()

    height: 34
    radius: Theme.cornerRadius
    color: mouseArea.containsMouse ? Qt.rgba(
                                        Theme.primary.r,
                                        Theme.primary.g,
                                        Theme.primary.b,
                                        0.12) : Qt.rgba(
                                        Theme.surfaceVariant.r,
                                        Theme.surfaceVariant.g,
                                        Theme.surfaceVariant.b,
                                        SettingsData.controlCenterWidgetBackgroundOpacity)
    
    // Drop shadow
    layer.enabled: true
    layer.effect: DropShadow {
        horizontalOffset: 0
        verticalOffset: 2
        radius: 6
        samples: 16
        color: Qt.rgba(0, 0, 0, SettingsData.controlCenterDropShadowOpacity)
        transparentBorder: true
    }

    Row {
        anchors.centerIn: parent
        spacing: Theme.spacingXS

        DankIcon {
            name: root.iconName
            size: Theme.fontSizeSmall
            color: mouseArea.containsMouse ? Theme.primary : Theme.surfaceText
            anchors.verticalCenter: parent.verticalCenter
        }

        Typography {
            text: root.text
            style: Typography.Style.Button
            color: mouseArea.containsMouse ? Theme.primary : Theme.surfaceText
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed: root.pressed()
    }
}