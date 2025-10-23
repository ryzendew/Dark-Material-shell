import QtQuick
import QtQuick.Controls
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: root

    property real widgetHeight: 40

    width: 2
    height: widgetHeight

    Rectangle {
        anchors.centerIn: parent
        width: 2
        height: parent.height - 8
        color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.3)
        radius: 1
    }
}







