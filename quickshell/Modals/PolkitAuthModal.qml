import QtQuick
import qs.Common
import qs.Modals.Common
import qs.Services
import qs.Widgets

DankModal {
    id: root

    property var authFlow: null
    property string passwordInput: ""
    property string errorMessage: ""
    property bool isError: false
    property bool isResponseRequired: false
    property bool responseVisible: false  // Default to hidden for security
    property string inputPrompt: ""
    property string mainMessage: ""

    function show(authFlowObject) {
        authFlow = authFlowObject
        passwordInput = ""
        errorMessage = ""
        isError = false
        updateFromAuthFlow()
        open()
        Qt.callLater(() => {
                         if (contentLoader.item && contentLoader.item.passwordInput)
                         contentLoader.item.passwordInput.forceActiveFocus()
                     })
    }

    function updateFromAuthFlow() {
        if (!authFlow) return
        mainMessage = authFlow.message || "Authentication Required"
        inputPrompt = authFlow.inputPrompt || "Please enter your password"
        isResponseRequired = authFlow.isResponseRequired !== undefined ? authFlow.isResponseRequired : true
        // Default to hiding password for security (show only if explicitly requested)
        responseVisible = authFlow.responseVisible === true
        if (authFlow.supplementaryMessage) {
            errorMessage = authFlow.supplementaryMessage
            isError = authFlow.supplementaryIsError || false
        } else {
            errorMessage = ""
            isError = false
        }
    }

    function submitPassword() {
        console.log("PolkitAuthModal: submitPassword() called")
        console.log("  - authFlow exists:", !!authFlow)
        console.log("  - root.passwordInput:", root.passwordInput ? root.passwordInput.length : 0)
        
        if (!authFlow) {
            console.error("PolkitAuthModal: No authFlow available!")
            return
        }
        
        // Get password - prioritize direct field access, then fall back to property
        var pwd = ""
        if (contentLoader.item && contentLoader.item.passwordInput) {
            pwd = contentLoader.item.passwordInput.text || ""
            console.log("  - Got password from field, length:", pwd.length)
        }
        
        // Fall back to property if field is empty
        if (!pwd || pwd.length === 0) {
            pwd = root.passwordInput || ""
            console.log("  - Got password from property, length:", pwd.length)
        }
        
        console.log("  - Final password length:", pwd.length)
        
        if (pwd && pwd.length > 0) {
            console.log("PolkitAuthModal: Submitting password to authFlow (length:", pwd.length + ")")
            try {
                // Call submit on the authFlow
                if (typeof authFlow.submit === 'function') {
                    authFlow.submit(pwd)
                    console.log("PolkitAuthModal: Password submitted successfully via authFlow.submit()")
                } else {
                    console.error("PolkitAuthModal: authFlow.submit is not a function! Type:", typeof authFlow.submit)
                }
                
                // Clear the password fields
                root.passwordInput = ""
                if (contentLoader.item && contentLoader.item.passwordInput) {
                    contentLoader.item.passwordInput.text = ""
                }
            } catch (e) {
                console.error("PolkitAuthModal: Error submitting password:", e, e.toString())
            }
        } else {
            console.warn("PolkitAuthModal: Cannot submit - password is empty")
        }
    }

    function cancelAuth() {
        if (authFlow) {
            authFlow.cancelAuthenticationRequest()
        }
        passwordInput = ""
        errorMessage = ""
        isError = false
        close()
    }

    shouldBeVisible: false
    width: 400
    height: 280
    enableShadow: true
    shouldHaveFocus: true
    onShouldBeVisibleChanged: () => {
                                  if (!shouldBeVisible) {
                                      passwordInput = ""
                                      errorMessage = ""
                                  }
                              }
    onOpened: {
        console.log("PolkitAuthModal: Modal opened")
        Qt.callLater(() => {
                         console.log("PolkitAuthModal: Setting focus on password field")
                         if (contentLoader.item && contentLoader.item.passwordInput) {
                             contentLoader.item.passwordInput.forceActiveFocus()
                             console.log("PolkitAuthModal: Focus set, activeFocus:", contentLoader.item.passwordInput.activeFocus)
                         } else {
                             console.warn("PolkitAuthModal: Cannot set focus - contentLoader.item:", !!contentLoader.item, "passwordInput:", !!(contentLoader.item && contentLoader.item.passwordInput))
                         }
                     })
    }
    onBackgroundClicked: () => {
                             cancelAuth()
                         }

    Connections {
        target: authFlow
        enabled: authFlow !== null

        function onAuthenticationSucceeded() {
            passwordInput = ""
            errorMessage = ""
            isError = false
            close()
        }

        function onAuthenticationFailed() {
            updateFromAuthFlow()
            passwordInput = ""
            if (contentLoader.item && contentLoader.item.passwordInput) {
                contentLoader.item.passwordInput.text = ""
                Qt.callLater(() => {
                                 contentLoader.item.passwordInput.forceActiveFocus()
                             })
            }
        }

        function onAuthenticationRequestCancelled() {
            passwordInput = ""
            errorMessage = ""
            isError = false
            close()
        }

        function onMessageChanged() {
            updateFromAuthFlow()
        }

        function onSupplementaryMessageChanged() {
            updateFromAuthFlow()
        }

        function onSupplementaryIsErrorChanged() {
            updateFromAuthFlow()
        }

        function onInputPromptChanged() {
            updateFromAuthFlow()
        }

        function onIsResponseRequiredChanged() {
            updateFromAuthFlow()
        }

        function onResponseVisibleChanged() {
            updateFromAuthFlow()
        }
    }

    content: Component {
        FocusScope {
            id: authContent

            property alias passwordInput: passwordInput

            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: event => {
                                      cancelAuth()
                                      event.accepted = true
                                  }
            Keys.onReturnPressed: event => {
                                       console.log("PolkitAuthModal: FocusScope Return pressed")
                                       root.submitPassword()
                                       event.accepted = true
                                   }
            Keys.onEnterPressed: event => {
                                      console.log("PolkitAuthModal: FocusScope Enter pressed")
                                      root.submitPassword()
                                      event.accepted = true
                                  }

            Column {
                id: mainColumn
                anchors.fill: parent
                anchors.margins: Theme.spacingL
                spacing: Theme.spacingM

                // Header with title and close button
                Row {
                    id: titleRow
                    width: parent.width
                    spacing: Theme.spacingM

                    Column {
                        width: parent.width - 40
                        spacing: Theme.spacingXS

                        StyledText {
                            text: root.mainMessage
                            font.pixelSize: Theme.fontSizeLarge
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }

                        StyledText {
                            text: root.inputPrompt || "Please enter your password to continue"
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.surfaceVariantText
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }

                    DankActionButton {
                        iconName: "close"
                        iconSize: Theme.iconSize - 4
                        iconColor: Theme.surfaceText
                        onClicked: () => {
                                       cancelAuth()
                                   }
                    }
                }

                // Error message display
                Rectangle {
                    id: errorRect
                    width: parent.width
                    height: errorMessage.length > 0 ? errorText.height + Theme.spacingM * 2 : 0
                    radius: Theme.cornerRadius
                    color: root.isError ? Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.15) : Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1)
                    border.color: root.isError ? Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.4) : Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3)
                    border.width: 1
                    visible: errorMessage.length > 0
                    clip: true

                    Behavior on height {
                        NumberAnimation {
                            duration: Theme.shortDuration
                            easing.type: Theme.standardEasing
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.shortDuration
                            easing.type: Theme.standardEasing
                        }
                    }

                    Behavior on border.color {
                        ColorAnimation {
                            duration: Theme.shortDuration
                            easing.type: Theme.standardEasing
                        }
                    }

                    StyledText {
                        id: errorText
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.spacingM
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.spacingM
                        anchors.verticalCenter: parent.verticalCenter
                        text: errorMessage
                        font.pixelSize: Theme.fontSizeMedium
                        color: root.isError ? Theme.error : Theme.primary
                        wrapMode: Text.WordWrap
                    }
                }

                // Password input field
                Rectangle {
                    id: inputRect
                    width: parent.width
                    height: 52
                    radius: Theme.cornerRadius
                    color: Theme.surfaceContainer
                    border.color: passwordInput.activeFocus ? Theme.primary : Theme.outlineMedium
                    border.width: passwordInput.activeFocus ? 2 : 1
                    visible: true

                    Behavior on border.color {
                        ColorAnimation {
                            duration: Theme.shortDuration
                            easing.type: Theme.standardEasing
                        }
                    }

                    Behavior on border.width {
                        NumberAnimation {
                            duration: Theme.shortDuration
                            easing.type: Theme.standardEasing
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: () => {
                                       passwordInput.forceActiveFocus()
                                   }
                    }

                    TextInput {
                        id: passwordInput

                        anchors.fill: parent
                        anchors.margins: Theme.spacingM
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.surfaceText
                        echoMode: root.responseVisible ? TextInput.Normal : TextInput.Password
                        selectByMouse: true
                        clip: true
                        verticalAlignment: TextInput.AlignVCenter
                        focus: true
                        enabled: root.shouldBeVisible && root.visible
                        activeFocusOnTab: true
                        activeFocusOnPress: true
                        
                        Component.onCompleted: {
                            console.log("PolkitAuthModal: TextInput component completed, shouldBeVisible:", root.shouldBeVisible, "visible:", root.visible)
                            if (root.shouldBeVisible) {
                                focusDelayTimer.start()
                                Qt.callLater(() => {
                                    forceActiveFocus()
                                    console.log("PolkitAuthModal: TextInput forced focus, activeFocus:", activeFocus)
                                })
                            }
                        }
                        
                        onTextChanged: {
                            root.passwordInput = text
                            console.log("PolkitAuthModal: Text changed, length:", text.length, "root.passwordInput:", root.passwordInput.length)
                            // Clear error when user starts typing
                            if (root.isError) {
                                root.errorMessage = ""
                                root.isError = false
                            }
                        }
                        
                        onAccepted: {
                            console.log("PolkitAuthModal: TextInput onAccepted triggered, text length:", text.length)
                            root.submitPassword()
                        }
                        
                        Keys.onReturnPressed: event => {
                                                  console.log("PolkitAuthModal: TextInput Return pressed, text length:", text.length)
                                                  if (text.length > 0) {
                                                      root.submitPassword()
                                                      event.accepted = true
                                                  }
                                              }
                        Keys.onEnterPressed: event => {
                                                 console.log("PolkitAuthModal: TextInput Enter pressed, text length:", text.length)
                                                 if (text.length > 0) {
                                                     root.submitPassword()
                                                     event.accepted = true
                                                 }
                                             }
                        Timer {
                            id: focusDelayTimer

                            interval: 150
                            repeat: false
                            onTriggered: () => {
                                             if (root.shouldBeVisible)
                                             passwordInput.forceActiveFocus()
                                         }
                        }

                        Connections {
                            target: root

                            function onShouldBeVisibleChanged() {
                                if (root.shouldBeVisible)
                                    focusDelayTimer.start()
                            }
                        }
                    }
                }

                // Button row
                Row {
                    id: buttonRow
                    width: parent.width
                    height: 40
                    spacing: Theme.spacingM
                    layoutDirection: Qt.RightToLeft

                    Rectangle {
                        id: okButton
                        width: 100
                        height: 40
                        radius: Theme.cornerRadius
                        color: okArea.containsMouse ? Qt.darker(Theme.primary, 1.1) : Theme.primary
                        opacity: (passwordInput.text.length > 0 || root.passwordInput.length > 0) ? 1 : 0.6

                        StyledText {
                            anchors.centerIn: parent
                            text: "OK"
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.primaryText
                            font.weight: Font.Medium
                        }

                        MouseArea {
                            id: okArea

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                console.log("PolkitAuthModal: OK button CLICKED")
                                console.log("  - passwordInput.text:", passwordInput.text ? passwordInput.text.length + " chars" : "null")
                                console.log("  - root.passwordInput:", root.passwordInput ? root.passwordInput.length + " chars" : "null")
                                console.log("  - root.authFlow exists:", !!root.authFlow)
                                console.log("  - root.authFlow type:", root.authFlow ? typeof root.authFlow : "null")
                                if (root.authFlow) {
                                    console.log("  - authFlow.submit exists:", typeof root.authFlow.submit)
                                }
                                root.submitPassword()
                            }
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.shortDuration
                                easing.type: Theme.standardEasing
                            }
                        }

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Theme.shortDuration
                                easing.type: Theme.standardEasing
                            }
                        }
                    }

                    Rectangle {
                        width: 100
                        height: 40
                        radius: Theme.cornerRadius
                        color: cancelArea.containsMouse ? Theme.surfaceVariant : "transparent"
                        border.color: Theme.outlineMedium
                        border.width: 1

                        StyledText {
                            anchors.centerIn: parent
                            text: "Cancel"
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        MouseArea {
                            id: cancelArea

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: () => {
                                           cancelAuth()
                                       }
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.shortDuration
                                easing.type: Theme.standardEasing
                            }
                        }
                    }
                }
            }
        }
    }
}

