import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Common

Item {
    id: root
    
    property var screen: null
    
    Item {
        id: topLeft
        anchors.left: parent.left
        anchors.top: parent.top
        width: 1
        height: 1
        visible: false
    }
    
    Item {
        id: topCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: 1
        height: 1
        visible: false
    }
    
    Item {
        id: topRight
        anchors.right: parent.right
        anchors.top: parent.top
        width: 1
        height: 1
        visible: false
    }
    
    Item {
        id: middleLeft
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 1
        height: 1
        visible: false
    }
    
    Item {
        id: middleCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: 1
        height: 1
        visible: false
    }
    
    Item {
        id: middleRight
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: 1
        height: 1
        visible: false
    }
    
    Item {
        id: bottomLeft
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: 1
        height: 1
        visible: false
    }
    
    Item {
        id: bottomCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        width: 1
        height: 1
        visible: false
    }
    
    Item {
        id: bottomRight
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: 1
        height: 1
        visible: false
    }
    
    function getPositionBox(position) {
        switch(position) {
            case "top-left": return topLeft
            case "top-center": return topCenter
            case "top-right": return topRight
            case "middle-left": return middleLeft
            case "middle-center": return middleCenter
            case "middle-right": return middleRight
            case "bottom-left": return bottomLeft
            case "bottom-center": return bottomCenter
            case "bottom-right": return bottomRight
            default: return topLeft
        }
    }
}





