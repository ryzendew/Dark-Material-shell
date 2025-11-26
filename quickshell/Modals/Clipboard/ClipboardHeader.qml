import QtQuick
import qs.Common
import qs.Widgets
import qs.Modals.Clipboard

Item {
    id: header

    property int totalCount: 0
    property bool showKeyboardHints: false

    signal keyboardHintsToggled
    signal clearAllClicked
    signal closeClicked

    height: ClipboardConstants.headerHeight

    Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacingM

        DarkIcon {
            name: "content_paste"
            size: Theme.iconSize - 4
            color: Theme.primary
            anchors.verticalCenter: parent.verticalCenter
        }

        StyledText {
            text: "Clipboard History (" + totalCount + ")"
            font.pixelSize: Theme.fontSizeLarge
            color: Theme.surfaceText
            font.weight: Font.Medium
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacingS

        DarkActionButton {
            iconName: "info"
            iconSize: Theme.iconSize - 4
            iconColor: showKeyboardHints ? Theme.primary : Theme.surfaceText
            onClicked: keyboardHintsToggled()
        }

        DarkActionButton {
            iconName: "delete_sweep"
            iconSize: Theme.iconSize - 4
            iconColor: Theme.surfaceText
            onClicked: clearAllClicked()
        }

        DarkActionButton {
            iconName: "close"
            iconSize: Theme.iconSize - 4
            iconColor: Theme.surfaceText
            onClicked: closeClicked()
        }
    }
}
