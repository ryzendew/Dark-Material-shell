import QtQuick
import qs.Common

MouseArea {
    id: root

    property bool disabled: false
    property color stateColor: Theme.surfaceText
    property real cornerRadius: {
        if (parent && parent.radius !== undefined) {
            return parent.radius
        }
        return Theme.cornerRadius
    }

    readonly property real stateOpacity: {
        if (disabled) return 0
        if (pressed) return 0.12
        if (containsMouse) return 0.08
        return 0
    }

    anchors.fill: parent
    cursorShape: disabled ? undefined : Qt.PointingHandCursor
    hoverEnabled: true

    Rectangle {
        anchors.fill: parent
        radius: root.cornerRadius
        color: Qt.rgba(stateColor.r, stateColor.g, stateColor.b, root.stateOpacity)
    }
}
