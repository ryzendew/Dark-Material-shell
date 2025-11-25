import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Widgets

Item {
    id: root
    
    property var minimizedWindow: null
    property bool isVisible: minimizedWindow !== null && minimizedWindow.preview
    
    width: 220
    height: 180
    
    // Background
    Rectangle {
        anchors.fill: parent
        radius: Theme.cornerRadius
        color: Theme.surfaceContainer
        border.width: 1
        border.color: Theme.outline
        
        // Shadow
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 8
            radius: 16
            samples: 20
            color: Qt.rgba(0, 0, 0, 0.4)
            transparentBorder: true
        }
    }
    
    // Preview content
    Rectangle {
        id: previewContent
        anchors.fill: parent
        anchors.margins: 8
        radius: Theme.cornerRadius - 2
        color: Theme.surface
        
        // Window preview placeholder
        Rectangle {
            id: windowPreview
            anchors.fill: parent
            anchors.bottomMargin: 32
            color: Theme.surfaceVariant
            radius: parent.radius
            
            // App icon
            Image {
                id: appIcon
                anchors.centerIn: parent
                width: 64
                height: 64
                sourceSize.width: 64
                sourceSize.height: 64
                fillMode: Image.PreserveAspectFit
                source: {
                    if (!root.minimizedWindow || !root.minimizedWindow.toplevel) return ""
                    const desktopEntry = DesktopEntries.heuristicLookup(root.minimizedWindow.toplevel.appId)
                    return desktopEntry && desktopEntry.icon ? Quickshell.iconPath(desktopEntry.icon, true) : ""
                }
                mipmap: true
                smooth: true
                visible: status === Image.Ready
            }
            
            // Fallback icon
            DarkIcon {
                anchors.centerIn: parent
                size: 64
                name: "window"
                color: Theme.surfaceText
                visible: appIcon.status !== Image.Ready
            }
            
            // Minimized indicator
            Rectangle {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 8
                width: 24
                height: 24
                radius: 12
                color: Qt.rgba(1, 0.5, 0, 0.8)
                
                DarkIcon {
                    anchors.centerIn: parent
                    size: 16
                    name: "minimize"
                    color: "white"
                }
            }
        }
        
        // Window title and controls
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 32
            color: Qt.rgba(0, 0, 0, 0.7)
            radius: parent.radius
            
            Row {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8
                
                // Window title
                StyledText {
                    width: parent.width - restoreButton.width - closeButton.width - parent.spacing * 2
                    text: root.minimizedWindow ? root.minimizedWindow.title : ""
                    font.pixelSize: 11
                    color: "white"
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
                
                // Restore button
                Rectangle {
                    id: restoreButton
                    width: 20
                    height: 20
                    radius: 10
                    color: restoreArea.containsMouse ? Qt.rgba(0, 0.5, 1, 0.8) : Qt.rgba(0, 0, 0, 0.6)
                    
                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
                    
                    MouseArea {
                        id: restoreArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        
                        onClicked: {
                            if (root.minimizedWindow && root.minimizedWindow.toplevel) {
                                // Minimize functionality removed
                            }
                        }
                    }
                    
                    DarkIcon {
                        anchors.centerIn: parent
                        size: 12
                        name: "open_in_full"
                        color: "white"
                    }
                }
                
                // Close button
                Rectangle {
                    id: closeButton
                    width: 20
                    height: 20
                    radius: 10
                    color: closeArea.containsMouse ? Qt.rgba(1, 0, 0, 0.8) : Qt.rgba(0, 0, 0, 0.6)
                    
                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
                    
                    MouseArea {
                        id: closeArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        
                        onClicked: {
                            if (root.minimizedWindow && root.minimizedWindow.toplevel) {
                                root.minimizedWindow.toplevel.close()
                                // Minimize functionality removed
                            }
                        }
                    }
                    
                    DarkIcon {
                        anchors.centerIn: parent
                        size: 12
                        name: "close"
                        color: "white"
                    }
                }
            }
        }
    }
    
    // Animation
    scale: isVisible ? 1.0 : 0.8
    opacity: isVisible ? 1.0 : 0.0
    
    Behavior on scale {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }
    
    Behavior on opacity {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }
}
