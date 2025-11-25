import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Widgets

Rectangle {
    id: root
    
    property var minimizedWindow: null
    property var toplevel: minimizedWindow ? minimizedWindow.toplevel : null
    property bool isHovered: mouseArea.containsMouse
    property bool showPreview: isHovered && minimizedWindow && minimizedWindow.preview
    
    width: 200
    height: 150
    radius: Theme.cornerRadius
    color: Theme.surfaceContainer
    border.width: 1
    border.color: Theme.outline
    
    // Preview image
    Rectangle {
        id: previewContainer
        anchors.fill: parent
        anchors.margins: 4
        radius: parent.radius - 2
        color: Theme.surface
        
        // Placeholder for actual window preview
        Rectangle {
            anchors.fill: parent
            color: Theme.surfaceVariant
            radius: parent.radius
            
            // App icon in center
            Image {
                id: appIcon
                anchors.centerIn: parent
                width: 48
                height: 48
                sourceSize.width: 48
                sourceSize.height: 48
                fillMode: Image.PreserveAspectFit
                source: {
                    if (!root.toplevel || !root.toplevel.appId) return ""
                    const desktopEntry = DesktopEntries.heuristicLookup(root.toplevel.appId)
                    return desktopEntry && desktopEntry.icon ? Quickshell.iconPath(desktopEntry.icon, true) : ""
                }
                mipmap: true
                smooth: true
                visible: status === Image.Ready
            }
            
            // Fallback icon
            DarkIcon {
                anchors.centerIn: parent
                size: 48
                name: "window"
                color: Theme.surfaceText
                visible: appIcon.status !== Image.Ready
            }
        }
        
        // Window title overlay
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 24
            color: Qt.rgba(0, 0, 0, 0.7)
            radius: parent.radius
            
            StyledText {
                anchors.fill: parent
                anchors.margins: 8
                text: root.minimizedWindow ? root.minimizedWindow.title : ""
                font.pixelSize: 10
                color: "white"
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
    
    // Hover effects
    scale: isHovered ? 1.05 : 1.0
    Behavior on scale {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }
    
    // Shadow effect
    layer.enabled: true
    layer.effect: DropShadow {
        horizontalOffset: 0
        verticalOffset: 4
        radius: 12
        samples: 16
        color: Qt.rgba(0, 0, 0, 0.3)
        transparentBorder: true
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            if (root.toplevel) {
                // Restore the window
                MinimizedWindowManager.restoreWindow(root.toplevel)
            }
        }
    }
    
    // Close button
    Rectangle {
        id: closeButton
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 4
        width: 20
        height: 20
        radius: 10
        color: closeArea.containsMouse ? Qt.rgba(1, 0, 0, 0.8) : Qt.rgba(0, 0, 0, 0.6)
        visible: isHovered
        
        Behavior on color {
            ColorAnimation { duration: 200 }
        }
        
        MouseArea {
            id: closeArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            
            onClicked: {
                if (root.toplevel) {
                    // Close the window instead of restoring
                    root.toplevel.close()
                    // Remove from minimized list
                    MinimizedWindowManager.restoreWindow(root.toplevel)
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





