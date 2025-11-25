import QtQuick
import qs.Common
import qs.Modals.Common
import qs.Services
import qs.Widgets

DarkModal {
    id: root

    property string action: ""
    property string title: ""
    property string message: ""
    property int countdown: 60
    property bool isActive: false

    signal confirmed(string action)
    signal cancelled()

    Timer {
        id: countdownTimer
        interval: 1000
        repeat: true
        running: root.isActive
        onTriggered: {
            root.countdown--
            if (root.countdown <= 0) {
                stop()
                root.confirmed(root.action)
                root.close()
            }
        }
    }

    function showConfirmation(actionType, actionTitle, actionMessage) {
        root.action = actionType
        root.title = actionTitle
        root.message = actionMessage
        root.countdown = 60
        root.isActive = true
        root.open()
    }

    function cancelAction() {
        countdownTimer.stop()
        root.isActive = false
        root.cancelled()
        root.close()
    }

    function confirmAction() {
        countdownTimer.stop()
        root.isActive = false
        root.confirmed(root.action)
        root.close()
    }

    shouldBeVisible: false
    width: 400
    height: contentLoader.item ? contentLoader.item.implicitHeight : 200
    enableShadow: true
    positioning: "center"
    onBackgroundClicked: () => {
        return cancelAction();
    }

    content: Component {
        Item {
            anchors.fill: parent
            implicitHeight: mainColumn.implicitHeight + Theme.spacingL * 2

            Column {
                id: mainColumn
                anchors.fill: parent
                anchors.margins: Theme.spacingL
                spacing: Theme.spacingM

                Row {
                    width: parent.width

                    StyledText {
                        text: root.title
                        font.pixelSize: Theme.fontSizeLarge
                        color: Theme.surfaceText
                        font.weight: Font.Medium
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Item {
                        width: parent.width - 150
                        height: 1
                    }

                    DarkActionButton {
                        iconName: "close"
                        iconSize: Theme.iconSize - 4
                        iconColor: Theme.surfaceText
                        onClicked: () => {
                            return cancelAction();
                        }
                    }
                }

                StyledText {
                    text: root.message
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.surfaceVariantText
                    wrapMode: Text.WordWrap
                    width: parent.width
                }

                // Countdown display
                Rectangle {
                    width: parent.width
                    height: 60
                    radius: Theme.cornerRadius
                    color: Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.1)
                    border.color: Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.3)
                    border.width: 1

                    Row {
                        anchors.centerIn: parent
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "timer"
                            size: Theme.iconSize
                            color: Theme.error
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: `Action will execute in ${root.countdown} seconds`
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.error
                            font.weight: Font.Medium
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                // Progress bar
                Rectangle {
                    width: parent.width
                    height: 4
                    radius: 2
                    color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)

                    Rectangle {
                        width: parent.width * (1 - root.countdown / 60)
                        height: parent.height
                        radius: 2
                        color: Theme.error
                        Behavior on width {
                            NumberAnimation {
                                duration: 1000
                                easing.type: Easing.Linear
                            }
                        }
                    }
                }

                // Action buttons
                Row {
                    width: parent.width
                    spacing: Theme.spacingM

                    Rectangle {
                        width: (parent.width - Theme.spacingM) / 2
                        height: 48
                        radius: Theme.cornerRadius
                        color: cancelMouseArea.containsMouse ? Theme.surfaceVariant : Theme.surfaceContainer
                        border.color: Theme.outline
                        border.width: 1

                        StyledText {
                            text: "Cancel"
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            id: cancelMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: cancelAction()
                        }
                    }

                    Rectangle {
                        width: (parent.width - Theme.spacingM) / 2
                        height: 48
                        radius: Theme.cornerRadius
                        color: confirmMouseArea.containsMouse ? Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.2) : Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.1)
                        border.color: Theme.error
                        border.width: 1

                        StyledText {
                            text: root.title
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.error
                            font.weight: Font.Medium
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            id: confirmMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: confirmAction()
                        }
                    }
                }
            }
        }
    }
}
