import QtQuick

Item {
    id: keyboard_controller

    property Item target
    property bool isKeyboardActive: false

    property var rootObject

    function show() {
        if (!isKeyboardActive && keyboard === null) {
            keyboard = keyboardComponent.createObject(keyboard_controller.rootObject)
            keyboard.target = keyboard_controller.target
            isKeyboardActive = true
        }
    }

    function hide() {
        if (isKeyboardActive && keyboard !== null) {
            keyboard.destroy()
            isKeyboardActive = false
        }
    }

    property Item keyboard: null
    Component {
        id: keyboardComponent
        Keyboard {}
    }
}
