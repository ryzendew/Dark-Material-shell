import QtQuick
import QtQuick.Controls
import Quickshell
import qs.Common
import qs.Widgets

Item {
    id: root

    property real widgetHeight: 40

    width: 20
    height: widgetHeight

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: 1
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.1)
        radius: 2

        Rectangle {
            anchors.centerIn: parent
            width: 2
            height: parent.height - 8
            color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.3)
            radius: 1
        }
    }
}







