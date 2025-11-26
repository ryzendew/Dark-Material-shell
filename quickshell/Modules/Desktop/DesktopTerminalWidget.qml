import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Widgets

PanelWindow {
    id: root

    property var modelData: null
    property var screen: modelData || null
    property real widgetWidth: SettingsData.desktopTerminalWidth
    property real widgetHeight: SettingsData.desktopTerminalHeight
    property bool alwaysVisible: true
    property string position: SettingsData.desktopTerminalPosition
    property var positioningBox: null
    
    property var outputLines: []
    property var commandHistory: []
    property int historyIndex: -1
    property string currentDirectory: ""
    property string prompt: "$ "
    property string currentInput: ""
    property bool commandRunning: false

    implicitWidth: widgetWidth
    implicitHeight: widgetHeight
    visible: alwaysVisible

    WlrLayershell.layer: WlrLayershell.Background
    WlrLayershell.namespace: "quickshell:desktop:terminal"
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    color: "transparent"

    anchors {
        left: position.includes("left") ? true : false
        right: position.includes("right") ? true : false
        top: position.includes("top") ? true : false
        bottom: position.includes("bottom") ? true : false
    }

    margins {
        left: position.includes("left") ? 20 : 0
        right: position.includes("right") ? 20 : 0
        top: position.includes("top") ? (SettingsData.topBarHeight + SettingsData.topBarSpacing + SettingsData.topBarBottomGap + 20) : 0
        bottom: position.includes("bottom") ? (SettingsData.dockExclusiveZone + SettingsData.dockBottomGap + 20) : 0
    }

    Component.onCompleted: {
        outputLines = []
        addOutput("Terminal ready. Type 'help' for commands.")
        updatePrompt()
        updateDirectory()
    }

    Connections {
        target: SettingsData
        function onDesktopTerminalPositionChanged() {
            position = SettingsData.desktopTerminalPosition
        }
        function onDesktopTerminalWidthChanged() {
            widgetWidth = SettingsData.desktopTerminalWidth
        }
        function onDesktopTerminalHeightChanged() {
            widgetHeight = SettingsData.desktopTerminalHeight
        }
        function onDesktopTerminalEnabledChanged() {
        }
    }

    Process {
        id: commandProcess
        running: false
        command: ["sh", "-c", ""]
        stdout: StdioCollector {}
        stderr: StdioCollector {}
        onExited: (exitCode) => {
            commandRunning = false
            var output = stdout.text.trim()
            var errorOutput = stderr.text.trim()
            
            var lines = output.split('\n')
            if (lines.length > 1) {
                var lastLine = lines[lines.length - 1]
                if (lastLine.startsWith('/') || lastLine.startsWith('~')) {
                    currentDirectory = lastLine
                    lines = lines.slice(0, -1)
                    output = lines.join('\n')
                }
            }
            
            if (exitCode === 0) {
                if (output !== "") {
                    addOutput(output)
                }
            } else {
                if (errorOutput !== "") {
                    addOutput("Error: " + errorOutput, true)
                } else if (output !== "") {
                    addOutput(output)
                } else {
                    addOutput("Command exited with code: " + exitCode, true)
                }
            }
            updatePrompt()
            inputField.focus = true
        }
    }

    Process {
        id: pwdProcess
        command: ["pwd"]
        running: false
        onExited: (exitCode) => {
            if (exitCode === 0) {
                currentDirectory = stdout.text.trim()
                updatePrompt()
            }
        }
        stdout: StdioCollector {}
    }

    Process {
        id: cdProcess
        command: ["sh", "-c", ""]
        running: false
        stdout: StdioCollector {}
        onExited: (exitCode) => {
            commandRunning = false
            var output = stdout.text.trim()
            if (output.startsWith("ERROR:")) {
                addOutput(output, true)
            } else if (output.startsWith("/") || output.startsWith(Quickshell.env("HOME") || "")) {
                currentDirectory = output
                updatePrompt()
            }
            inputField.focus = true
        }
    }

    function updateDirectory() {
        pwdProcess.running = true
    }

    function updatePrompt() {
        const homeDir = Quickshell.env("HOME") || ""
        let displayDir = currentDirectory
        if (displayDir.startsWith(homeDir)) {
            displayDir = "~" + displayDir.substring(homeDir.length)
        }
        const user = Quickshell.env("USER") || "user"
        prompt = user + "@" + (Quickshell.env("HOSTNAME") || "host") + ":" + displayDir + "$ "
    }

    function addOutput(text, isError) {
        if (!text) return
        const lines = text.split('\n')
        for (var i = 0; i < lines.length; i++) {
            outputLines.push({
                text: lines[i],
                isError: isError || false,
                timestamp: new Date()
            })
        }
        if (outputLines.length > 1000) {
            outputLines = outputLines.slice(-500)
        }
        outputView.positionViewAtEnd()
    }

    function executeCommand(command) {
        if (!command || command.trim() === "") return
        
        const trimmedCommand = command.trim()
        
        if (trimmedCommand === "clear" || trimmedCommand === "cls") {
            outputLines = []
            updatePrompt()
            inputField.focus = true
            return
        }
        
        if (trimmedCommand === "help") {
            addOutput("Available commands:")
            addOutput("  help          - Show this help message")
            addOutput("  clear, cls    - Clear the terminal")
            addOutput("  exit          - Close terminal (use settings to disable)")
            addOutput("All other commands are executed in your shell.")
            updatePrompt()
            inputField.focus = true
            return
        }
        
        addOutput(prompt + trimmedCommand)
        
        commandHistory.push(trimmedCommand)
        historyIndex = commandHistory.length
        if (commandHistory.length > 100) {
            commandHistory = commandHistory.slice(-100)
        }
        
        if (trimmedCommand.startsWith("cd ")) {
            const targetDir = trimmedCommand.substring(3).trim()
            commandRunning = true
            cdProcess.command = ["sh", "-c", "cd \"" + targetDir + "\" 2>&1 && pwd || echo 'ERROR: cd: No such file or directory: " + targetDir + "'"]
            cdProcess.running = true
            return
        }
        
        commandRunning = true
        var fullCommand = trimmedCommand + "; pwd"
        commandProcess.command = ["sh", "-c", fullCommand]
        commandProcess.running = true
    }

    Rectangle {
        width: widgetWidth
        height: widgetHeight
        radius: Theme.cornerRadius
        color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, SettingsData.desktopTerminalOpacity)
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.3)
        border.width: 1

        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 4
            radius: 12
            samples: 16
            color: Qt.rgba(0, 0, 0, 0.3)
            transparentBorder: true
        }

        Column {
            anchors.fill: parent
            anchors.margins: Theme.spacingM
            spacing: Theme.spacingS

            Rectangle {
                width: parent.width
                height: 30
                color: "transparent"
                
                Row {
                    anchors.centerIn: parent
                    spacing: Theme.spacingS
                    
                    Rectangle {
                        width: 4
                        height: 20
                        radius: Theme.cornerRadius * 0.2
                        color: Theme.primary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    StyledText {
                        text: "TERMINAL"
                        font.pixelSize: 12
                        color: Theme.surfaceText
                        font.weight: Font.Bold
                        font.letterSpacing: 1.2
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: parent.height - 30 - 50
                color: Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0.8)
                radius: Theme.cornerRadius * 0.3
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                border.width: 1

                ScrollView {
                    id: scrollView
                    anchors.fill: parent
                    anchors.margins: 4
                    clip: true

                    ListView {
                        id: outputView
                        model: outputLines
                        spacing: 2

                        delegate: Text {
                            width: outputView.width
                            text: modelData.text
                            color: modelData.isError ? Theme.error : Theme.surfaceText
                            font.family: "monospace"
                            font.pixelSize: SettingsData.desktopTerminalFontSize
                            wrapMode: Text.Wrap
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 40
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.5)
                radius: Theme.cornerRadius * 0.3
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                border.width: 1

                Row {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8

                    Text {
                        id: promptText
                        text: root.prompt
                        color: Theme.primary
                        font.family: "monospace"
                        font.pixelSize: SettingsData.desktopTerminalFontSize
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    TextInput {
                        id: inputField
                        width: parent.width - promptText.width - parent.spacing
                        anchors.verticalCenter: parent.verticalCenter
                        color: Theme.surfaceText
                        font.family: "monospace"
                        font.pixelSize: SettingsData.desktopTerminalFontSize
                        selectByMouse: true
                        focus: true
                        
                        property string lastCommand: ""

                        Keys.onPressed: (event) => {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                if (!commandRunning) {
                                    executeCommand(text)
                                    text = ""
                                }
                                event.accepted = true
                            } else if (event.key === Qt.Key_Up) {
                                if (commandHistory.length > 0) {
                                    if (historyIndex > 0) {
                                        historyIndex--
                                    }
                                    text = commandHistory[historyIndex]
                                }
                                event.accepted = true
                            } else if (event.key === Qt.Key_Down) {
                                if (commandHistory.length > 0 && historyIndex < commandHistory.length - 1) {
                                    historyIndex++
                                    text = commandHistory[historyIndex]
                                } else {
                                    historyIndex = commandHistory.length
                                    text = ""
                                }
                                event.accepted = true
                            }
                        }
                    }
                }
            }
        }
    }
}

