import QtQuick
import Quickshell
import qs.config
import qs
import qs.core.system
import qs.ui.controls.providers
import qs.ui.controls.auxiliary
import qs.ui.components.panel
import QtQuick.VectorImage
import QtQuick.Controls
import QtQuick.Effects

NotchApplication {
    id: root
    details.version: "0.1.1"
    details.appType: "media"
    meta.height: 60
    meta.width: 300

    property int pause: 0      // accumulated elapsed time in ms
    property var startTime: 0  // last start timestamp
    property string time: "--:--"

    Timer {
        id: timer
        interval: 1000
        running: false
        repeat: true
        onTriggered: {
            let diff = (new Date() - startTime) + pause
            let minutes = Math.floor(diff / 60000)
            let seconds = Math.floor((diff % 60000) / 1000)
            root.time =
                minutes.toString().padStart(2, '0') + ":" +
                seconds.toString().padStart(2, '0')
        }
    }

    indicative: Item {
        Rectangle {
            id: indIndicator
            anchors {
                left: parent.left
                leftMargin: 10
                verticalCenter: parent.verticalCenter
            }
            width: 14
            height: 14
            radius: 7
            border {
                width: 4
                color: '#33ff9100'
            }
            color: '#ff9100'
        }
        Text {
            id: indTimerText
            anchors {
                right: parent.right
                rightMargin: 10
                verticalCenter: parent.verticalCenter
            }
            color: '#ff9d00'
            text: root.time
            font.family: Fonts.sFProMonoRegular.family
            font.pixelSize: 20
        }
    }
    active: Item {
        anchors.fill: parent
        Text {
            id: timerText
            anchors {
                right: parent.right
                rightMargin: 20
                verticalCenter: parent.verticalCenter
            }
            color: '#ff9d00'
            text: root.time
            font.family: Fonts.sFProMonoRegular.family
            font.pixelSize: 20
        }

        Button {
            id: startButton
            width: 40
            height: 40
            anchors {
                left: parent.left
                leftMargin: 10
                verticalCenter: parent.verticalCenter
            }
            background: Rectangle {
                anchors.fill: parent
                color: '#30ff9e1e'
                radius: 99
                VectorImage {
                    id: rBStart
                    source: timer.running
                            ? Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/music/pause.svg")
                            : Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/music/play.svg")
                    width: 25
                    height: 25
                    preferredRendererType: VectorImage.CurveRenderer
                    anchors.centerIn: parent
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        colorization: 1
                        colorizationColor: "#ff9100"
                    }
                }
            }
            onClicked: {
                if (timer.running) {
                    // pause
                    timer.stop()
                    pause += new Date() - startTime
                } else {
                    // resume
                    startTime = new Date()
                    timer.start()
                }
            }
        }

        Button {
            id: stopButton
            width: 40
            height: 40
            anchors {
                left: startButton.right
                leftMargin: 10
                verticalCenter: parent.verticalCenter
            }
            background: Rectangle {
                anchors.fill: parent
                color: '#30ffffff'
                radius: 99
                VectorImage {
                    id: rBStop
                    source: Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/arrow-counterclockwise.svg")
                    width: 25
                    height: 25
                    preferredRendererType: VectorImage.CurveRenderer
                    anchors.centerIn: parent
                    rotation: -90
                }
            }
            onClicked: {
                timer.stop()
                pause = 0
                startTime = new Date()
                root.time = "--:--"
            }
        }

        
        MouseArea {
            width: 40
            height: 40
            anchors {
                left: stopButton.right
                leftMargin: 10
                verticalCenter: parent.verticalCenter
            }
            onClicked: {
                notch.closeNotchInstance(meta.id)
            }
            Rectangle {
                id: closeButton
                anchors.fill: parent
                color: '#20ffffff'
                radius: 99
                Behavior on opacity {
                    NumberAnimation { duration: 50; easing.type: Easing.InOutQuad}
                }
                VectorImage {
                    id: rBClose
                    source: Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/notch/x.svg")
                    width: 25
                    height: 25
                    preferredRendererType: VectorImage.CurveRenderer
                    anchors.centerIn: parent
                }
            }
        }
    }
}
