import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.Common
import qs.Modals.Common
import qs.Modals.Overview
import qs.Services
import qs.Widgets

DarkModal {
    id: overviewModal

    required property var modelData
    property bool overviewOpen: false
    
    screen: modelData
    
    property string screenName: {
        if (modelData && modelData.name) {
            return modelData.name
        }
        if (screen && screen.name) {
            return screen.name
        }
        return ""
    }
    

    function show() {
        overviewOpen = true
        open()
        OverviewService.refreshWindows()
        OverviewService.captureAllScreenshots()
        Qt.callLater(() => {
            if (contentLoader.item) {
                if (contentLoader.item.screenName !== screenName) {
                    contentLoader.item.screenName = screenName
                }
                if (contentLoader.item.focusScope) {
                    contentLoader.item.focusScope.forceActiveFocus()
                }
            }
        })
    }

    function hide() {
        overviewOpen = false
        close()
    }

    function toggle() {
        if (overviewOpen) {
            hide()
        } else {
            show()
        }
    }

    shouldBeVisible: overviewOpen
    width: screenWidth
    height: screenHeight
    positioning: "custom"
    customPosition: Qt.point(0, 0)
    backgroundColor: Theme.surfaceContainer
    backgroundOpacity: 0.85
    cornerRadius: 0
    borderWidth: 0
    enableShadow: false
    closeOnEscapeKey: true
    closeOnBackgroundClick: false
    allowStacking: true  // Allow multiple overview modals on different screens
    
    onBackgroundClicked: () => {
        return hide()
    }
    
    content: Component {
        OverviewContent {
            parentModal: overviewModal
            screenName: overviewModal.screenName
        }
    }

    Connections {
        function onCloseAllModalsExcept(excludedModal) {
            if (excludedModal !== overviewModal && !allowStacking && overviewOpen) {
                overviewOpen = false
            }
        }

        target: ModalManager
    }
}

