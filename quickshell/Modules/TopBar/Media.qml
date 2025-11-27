import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell.Services.Mpris
import qs.Common
import qs.Services
import qs.Widgets

Rectangle {
    id: root

    readonly property MprisPlayer activePlayer: MprisController.activePlayer
    readonly property bool playerAvailable: activePlayer !== null
    property bool compactMode: false
    readonly property int textWidth: {
        return 0;
    }
    readonly property int currentContentWidth: {
        return mediaRow.implicitWidth + horizontalPadding * 2;
    }
    property string section: "center"
    property var popupTarget: null
    property var parentScreen: null
    property real barHeight: 48
    property real widgetHeight: 30
    readonly property real horizontalPadding: SettingsData.topBarNoBackground ? 0 : Math.max(Theme.spacingXS, Theme.spacingS * (widgetHeight / 30))

    signal clicked()

    height: widgetHeight
    radius: SettingsData.topBarNoBackground ? 0 : Theme.cornerRadius
    color: {
        if (SettingsData.topBarNoBackground) {
            return "transparent";
        }

        const baseColor = Theme.widgetBaseBackgroundColor;
        return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, baseColor.a * Theme.widgetTransparency);
    }
    states: [
        State {
            name: "shown"
            when: playerAvailable

            PropertyChanges {
                target: root
                opacity: 1
                width: currentContentWidth
            }

        },
        State {
            name: "hidden"
            when: !playerAvailable

            PropertyChanges {
                target: root
                opacity: 0
                width: 0
            }

        }
    ]
    transitions: [
        Transition {
            from: "shown"
            to: "hidden"

            SequentialAnimation {
                PauseAnimation {
                    duration: 500
                }

                NumberAnimation {
                    properties: "opacity,width"
                    duration: Theme.shortDuration
                    easing.type: Theme.standardEasing
                }

            }

        },
        Transition {
            from: "hidden"
            to: "shown"

            NumberAnimation {
                properties: "opacity,width"
                duration: Theme.shortDuration
                easing.type: Theme.standardEasing
            }

        }
    ]

    Row {
        id: mediaRow

        anchors.centerIn: parent
        spacing: Theme.spacingXS

        AudioVisualization {
            anchors.verticalCenter: parent.verticalCenter
        }

        Row {
            spacing: Theme.spacingXS
            anchors.verticalCenter: parent.verticalCenter

            StyledText {
                id: mediaText
                
                property string displayText: {
                    if (!activePlayer || !activePlayer.trackTitle) {
                        return "";
                    }

                    let identity = activePlayer.identity || "";
                    let isWebMedia = identity.toLowerCase().includes("firefox") || identity.toLowerCase().includes("chrome") || identity.toLowerCase().includes("chromium") || identity.toLowerCase().includes("edge") || identity.toLowerCase().includes("safari");
                    let title = "";
                    let subtitle = "";
                    if (isWebMedia && activePlayer.trackTitle) {
                        title = activePlayer.trackTitle;
                        subtitle = activePlayer.trackArtist || identity;
                    } else {
                        title = activePlayer.trackTitle || "Unknown Track";
                        subtitle = activePlayer.trackArtist || "";
                    }
                    return subtitle.length > 0 ? title + " • " + subtitle : title;
                }

                anchors.verticalCenter: parent.verticalCenter
                text: displayText
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceText
                font.weight: Font.Medium
                wrapMode: Text.NoWrap
                visible: SettingsData.mediaSize > 0
                
                layer.enabled: true
                layer.effect: DropShadow {
                    horizontalOffset: 0
                    verticalOffset: 1
                    radius: 4
                    samples: 16
                    color: Qt.rgba(0, 0, 0, SettingsData.topBarDropShadowOpacity)
                    transparentBorder: true
                }

                MouseArea {
                    id: mediaHoverArea
                    anchors.fill: parent
                    enabled: root.playerAvailable && root.opacity > 0 && root.width > 0 && parent.visible
                    hoverEnabled: enabled
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
            }


            Rectangle {
                width: 20
                height: 20
                radius: 10
                anchors.verticalCenter: parent.verticalCenter
                color: prevArea.containsMouse ? Theme.primaryHover : "transparent"
                visible: root.playerAvailable
                opacity: (activePlayer && activePlayer.canGoPrevious) ? 1 : 0.3

                DarkIcon {
                    anchors.centerIn: parent
                    name: "skip_previous"
                    size: 12
                    color: Theme.surfaceText
                    
                    layer.enabled: true
                    layer.effect: DropShadow {
                        horizontalOffset: 0
                        verticalOffset: 1
                        radius: 3
                        samples: 16
                        color: Qt.rgba(0, 0, 0, SettingsData.topBarDropShadowOpacity)
                        transparentBorder: true
                    }
                }

                MouseArea {
                    id: prevArea

                    anchors.fill: parent
                    enabled: root.playerAvailable && root.width > 0
                    hoverEnabled: enabled
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        if (activePlayer) {
                            activePlayer.previous();
                        }
                    }
                }

            }

            Rectangle {
                width: 24
                height: 24
                radius: 12
                anchors.verticalCenter: parent.verticalCenter
                color: activePlayer && activePlayer.playbackState === 1 ? Theme.primary : Theme.primaryHover
                visible: root.playerAvailable
                opacity: activePlayer ? 1 : 0.3

                DarkIcon {
                    anchors.centerIn: parent
                    name: activePlayer && activePlayer.playbackState === 1 ? "pause" : "play_arrow"
                    size: 14
                    color: activePlayer && activePlayer.playbackState === 1 ? Theme.background : Theme.primary
                    
                    layer.enabled: true
                    layer.effect: DropShadow {
                        horizontalOffset: 0
                        verticalOffset: 1
                        radius: 3
                        samples: 16
                        color: Qt.rgba(0, 0, 0, SettingsData.topBarDropShadowOpacity)
                        transparentBorder: true
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: root.playerAvailable && root.width > 0
                    hoverEnabled: enabled
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        if (activePlayer) {
                            activePlayer.togglePlaying();
                        }
                    }
                }

            }

            Rectangle {
                width: 20
                height: 20
                radius: 10
                anchors.verticalCenter: parent.verticalCenter
                color: nextArea.containsMouse ? Theme.primaryHover : "transparent"
                visible: playerAvailable
                opacity: (activePlayer && activePlayer.canGoNext) ? 1 : 0.3

                DarkIcon {
                    anchors.centerIn: parent
                    name: "skip_next"
                    size: 12
                    color: Theme.surfaceText
                    
                    layer.enabled: true
                    layer.effect: DropShadow {
                        horizontalOffset: 0
                        verticalOffset: 1
                        radius: 3
                        samples: 16
                        color: Qt.rgba(0, 0, 0, SettingsData.topBarDropShadowOpacity)
                        transparentBorder: true
                    }
                }

                MouseArea {
                    id: nextArea

                    anchors.fill: parent
                    enabled: root.playerAvailable && root.width > 0
                    hoverEnabled: enabled
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        if (activePlayer) {
                            activePlayer.next();
                        }
                    }
                }

            }

        }

    }


    Behavior on width {
        NumberAnimation {
            duration: Theme.shortDuration
            easing.type: Theme.standardEasing
        }

    }

}
