import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Widgets
import qs.Modals
import qs.Modals.FileBrowser

Item {
    id: execsTab

    readonly property string defaultExecsPath: (Quickshell.env("HOME") || StandardPaths.writableLocation(StandardPaths.HomeLocation)) + "/.config/hypr/hyprland/execs.conf"
    
    property string execsPath: (SettingsData.execsPath && SettingsData.execsPath !== "") ? SettingsData.execsPath : defaultExecsPath
    
    property var lines: []
    property bool isLoading: false
    property bool hasUnsavedChanges: false
    property int editingIndex: -1

    Component.onCompleted: {
        loadExecs()
    }

    function loadExecs() {
        isLoading = true
        execsFile.path = ""
        execsFile.path = execsPath
    }

    function parseExecs(content) {
        var fileLines = content.split('\n')
        var parsed = []
        
        for (var i = 0; i < fileLines.length; i++) {
            var line = fileLines[i]
            var trimmed = line.trim()
            
            if (trimmed.length === 0) {
                parsed.push({
                    type: 'empty',
                    original: line,
                    text: ''
                })
            } else if (trimmed.startsWith('#')) {
                parsed.push({
                    type: 'comment',
                    original: line,
                    text: trimmed
                })
            } else {
                parsed.push({
                    type: 'raw',
                    original: line,
                    text: trimmed
                })
            }
        }
        
        lines = parsed
        isLoading = false
        hasUnsavedChanges = false
    }

    function saveExecs() {
        var fileLines = []
        
        for (var i = 0; i < lines.length; i++) {
            var item = lines[i]
            fileLines.push(item.original)
        }
        
        var content = fileLines.join('\n')
        
        // Ensure directory exists
        var dirPath = execsPath.substring(0, execsPath.lastIndexOf('/'))
        ensureDirProcess.command = ["mkdir", "-p", dirPath]
        ensureDirProcess.running = true
        pendingSaveContent = content
    }
    
    Process {
        id: ensureDirProcess
        command: ["mkdir", "-p"]
        running: false
        
        onExited: exitCode => {
            if (pendingSaveContent !== "") {
                touchFileProcess.command = ["touch", execsPath]
                touchFileProcess.running = true
            }
        }
    }
    
    Process {
        id: touchFileProcess
        command: ["touch"]
        running: false
        
        onExited: exitCode => {
            if (pendingSaveContent !== "") {
                saveExecsFile.path = ""
                Qt.callLater(() => {
                    saveExecsFile.path = execsPath
                    Qt.callLater(() => {
                        saveExecsFile.setText(pendingSaveContent)
                    })
                })
            }
        }
    }
    
    property string pendingSaveContent: ""

    function addNewLine() {
        var newLine = {
            type: 'raw',
            original: '',
            text: ''
        }
        lines.push(newLine)
        editingIndex = lines.length - 1
        hasUnsavedChanges = true
    }

    function startEditing(index) {
        editingIndex = index
    }

    function stopEditing() {
        editingIndex = -1
    }

    FileView {
        id: execsFile
        path: execsTab.execsPath
        blockWrites: true
        blockLoading: false
        atomicWrites: true
        printErrors: true
        
        onLoaded: {
            var fileContent = text()
            parseExecs(fileContent)
        }
        
        onLoadFailed: {
            isLoading = false
            if (typeof ToastService !== "undefined") {
                ToastService.showError("Failed to load execs file")
            }
        }
    }
    
    FileView {
        id: saveExecsFile
        blockWrites: false
        blockLoading: true
        atomicWrites: true
        printErrors: true
        
        onSaved: {
            hasUnsavedChanges = false
            if (typeof ToastService !== "undefined") {
                ToastService.showSuccess("Execs saved successfully")
            }
            Qt.callLater(() => {
                execsFile.reload()
            })
            reloadHyprlandProcess.running = true
            pendingSaveContent = ""
        }
        
        onSaveFailed: (error) => {
            if (typeof ToastService !== "undefined") {
                ToastService.showError("Failed to save execs file: " + (error || "Unknown error"))
            }
            pendingSaveContent = ""
        }
    }

    Process {
        id: reloadHyprlandProcess
        command: ["hyprctl", "reload"]
        running: false
        
        onExited: exitCode => {
            if (exitCode === 0) {
                if (typeof ToastService !== "undefined") {
                    ToastService.showSuccess("Hyprland configuration reloaded")
                }
            } else {
                if (typeof ToastService !== "undefined") {
                    ToastService.showError("Failed to reload Hyprland configuration")
                }
            }
        }
    }

    DarkFlickable {
        anchors.fill: parent
        anchors.topMargin: Theme.spacingL
        clip: true
        contentHeight: mainColumn.height
        contentWidth: width

        Column {
            id: mainColumn
            width: parent.width
            spacing: Theme.spacingXL

            StyledRect {
                width: parent.width
                height: headerSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: headerSection
                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "play_arrow"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingM
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: "Hyprland Execs"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Manage startup commands for Hyprland window manager. Changes are saved to your config file."
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                            }
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM
                        anchors.topMargin: Theme.spacingM

                        Rectangle {
                            width: 140
                            height: 40
                            radius: Theme.cornerRadius
                            color: reloadMouseArea.containsMouse ? Theme.primaryContainer : Theme.surfaceVariant
                            enabled: !isLoading
                            opacity: enabled ? 1 : 0.5

                            Row {
                                anchors.centerIn: parent
                                spacing: Theme.spacingXS

                                DarkIcon {
                                    name: "refresh"
                                    size: 18
                                    color: Theme.surfaceText
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                StyledText {
                                    text: "Reload"
                                    font.pixelSize: Theme.fontSizeMedium
                                    color: Theme.surfaceText
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: reloadMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                enabled: parent.enabled
                                onClicked: loadExecs()
                            }
                        }

                        Rectangle {
                            id: saveButton
                            width: 140
                            height: 40
                            radius: Theme.cornerRadius
                            property bool isEnabled: execsTab.hasUnsavedChanges && !execsTab.isLoading
                            color: saveMouseArea.containsMouse ? Theme.primary : (isEnabled ? Theme.primaryContainer : Theme.surfaceVariant)
                            opacity: isEnabled ? 1 : 0.5

                            Row {
                                anchors.centerIn: parent
                                spacing: Theme.spacingXS

                                DarkIcon {
                                    name: "save"
                                    size: 18
                                    color: saveButton.isEnabled ? Theme.onPrimary : Theme.surfaceText
                                    anchors.verticalCenter: parent.verticalCenter
                                    visible: saveButton.isEnabled
                                }

                                StyledText {
                                    text: "Save"
                                    font.pixelSize: Theme.fontSizeMedium
                                    color: saveButton.isEnabled ? Theme.onPrimary : Theme.surfaceText
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: saveMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                enabled: saveButton.isEnabled
                                onClicked: saveExecs()
                            }
                        }

                        Rectangle {
                            width: 180
                            height: 40
                            radius: Theme.cornerRadius
                            color: selectFileMouseArea.containsMouse ? Theme.primaryContainer : Theme.surfaceVariant
                            enabled: !isLoading
                            opacity: enabled ? 1 : 0.5

                            Row {
                                anchors.centerIn: parent
                                spacing: Theme.spacingXS

                                DarkIcon {
                                    name: "folder_open"
                                    size: 18
                                    color: Theme.surfaceText
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                StyledText {
                                    text: "Select Config"
                                    font.pixelSize: Theme.fontSizeMedium
                                    color: Theme.surfaceText
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: selectFileMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                enabled: parent.enabled
                                onClicked: execsFileBrowser.open()
                            }
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM
                        visible: execsPath !== ""
                        anchors.topMargin: Theme.spacingS

                        StyledText {
                            text: "Config file:"
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.Medium
                            color: Theme.surfaceVariantText
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            width: parent.width - implicitWidth - Theme.spacingM
                            text: execsPath
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            elide: Text.ElideMiddle
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: execsSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                border.width: 1
                visible: !isLoading

                Column {
                    id: execsSection
                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "settings"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingM
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: "Execs"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Edit startup commands. Format: exec = COMMAND or exec-once = COMMAND"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                            }
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM
                        anchors.topMargin: Theme.spacingM

                        Rectangle {
                            width: 160
                            height: 40
                            radius: Theme.cornerRadius
                            color: addMouseArea.containsMouse ? Theme.primaryContainer : Theme.surfaceVariant

                            Row {
                                anchors.centerIn: parent
                                spacing: Theme.spacingXS

                                DarkIcon {
                                    name: "add"
                                    size: 18
                                    color: Theme.surfaceText
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                StyledText {
                                    text: "Add Line"
                                    font.pixelSize: Theme.fontSizeMedium
                                    color: Theme.surfaceText
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: addMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: addNewLine()
                            }
                        }
                    }

                    DarkFlickable {
                        width: parent.width
                        height: Math.min(600, execsList.height)
                        clip: true
                        contentHeight: execsList.height
                        contentWidth: width
                        anchors.topMargin: Theme.spacingM

                        Column {
                            id: execsList
                            width: parent.width
                            spacing: Theme.spacingS

                            Repeater {
                                model: execsTab.lines

                                Item {
                                    width: parent.width
                                    height: lineItem.height

                                    Rectangle {
                                        id: lineItem
                                        width: parent.width
                                        height: Math.max(40, lineContent.implicitHeight + Theme.spacingL * 2)
                                        radius: Theme.cornerRadius
                                        color: itemMouseArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.08) : Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.2)
                                        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.1)
                                        border.width: 1

                                        Row {
                                            id: lineContent
                                            anchors.left: parent.left
                                            anchors.right: deleteButton.visible ? deleteButton.left : parent.right
                                            anchors.top: parent.top
                                            anchors.bottom: parent.bottom
                                            anchors.leftMargin: Theme.spacingL
                                            anchors.rightMargin: deleteButton.visible ? Theme.spacingM : Theme.spacingL
                                            anchors.topMargin: Theme.spacingL
                                            anchors.bottomMargin: Theme.spacingL

                                            property bool isEditing: execsTab.editingIndex === index

                                            StyledText {
                                                width: parent.width
                                                text: modelData.original || ""
                                                font.pixelSize: Theme.fontSizeMedium
                                                font.family: modelData.type === 'comment' ? "monospace" : "monospace"
                                                color: modelData.type === 'comment' ? Theme.surfaceVariantText : Theme.surfaceText
                                                wrapMode: Text.Wrap
                                                visible: !lineContent.isEditing
                                            }

                                            DarkTextField {
                                                id: lineField
                                                width: parent.width
                                                text: modelData.original || ""
                                                visible: lineContent.isEditing
                                                onVisibleChanged: {
                                                    if (visible && execsTab.editingIndex === index) {
                                                        Qt.callLater(() => {
                                                            forceActiveFocus()
                                                            selectAll()
                                                        })
                                                    }
                                                }
                                                onTextChanged: {
                                                    if (modelData.original !== text) {
                                                        if (index >= 0 && index < execsTab.lines.length) {
                                                            execsTab.lines[index].original = text
                                                            execsTab.lines[index].text = text.trim()
                                                            if (text.trim().startsWith('#')) {
                                                                execsTab.lines[index].type = 'comment'
                                                            } else if (text.trim().length === 0) {
                                                                execsTab.lines[index].type = 'empty'
                                                            } else {
                                                                execsTab.lines[index].type = 'raw'
                                                            }
                                                        }
                                                        modelData.original = text
                                                        execsTab.hasUnsavedChanges = true
                                                    }
                                                }
                                                Keys.onEscapePressed: {
                                                    execsTab.stopEditing()
                                                }
                                                Keys.onEnterPressed: {
                                                    execsTab.stopEditing()
                                                }
                                                Keys.onReturnPressed: {
                                                    execsTab.stopEditing()
                                                }
                                            }
                                        }

                                        DarkActionButton {
                                            id: deleteButton
                                            buttonSize: 32
                                            circular: true
                                            iconName: "delete"
                                            iconSize: 16
                                            iconColor: Theme.error
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.right: parent.right
                                            anchors.rightMargin: Theme.spacingM
                                            visible: itemMouseArea.containsMouse && !lineContent.isEditing
                                            onClicked: {
                                                if (execsTab.editingIndex === index) {
                                                    execsTab.stopEditing()
                                                }
                                                execsTab.hasUnsavedChanges = true
                                                var newLines = execsTab.lines.slice()
                                                newLines.splice(index, 1)
                                                execsTab.lines = newLines
                                            }
                                        }

                                        MouseArea {
                                            id: itemMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            propagateComposedEvents: true
                                            onClicked: {
                                                if (execsTab.editingIndex !== index) {
                                                    execsTab.startEditing(index)
                                                    Qt.callLater(() => {
                                                        lineField.forceActiveFocus()
                                                        lineField.selectAll()
                                                    })
                                                }
                                            }
                                            onPressed: (mouse) => {
                                                if (execsTab.editingIndex !== index && execsTab.editingIndex !== -1) {
                                                    execsTab.stopEditing()
                                                }
                                                mouse.accepted = false
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: 80
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                border.width: 1
                visible: isLoading

                Row {
                    anchors.centerIn: parent
                    spacing: Theme.spacingM

                    DarkIcon {
                        name: "hourglass_empty"
                        size: 24
                        color: Theme.primary
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    StyledText {
                        text: "Loading execs..."
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.surfaceText
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }

    FileBrowserModal {
        id: execsFileBrowser

        browserTitle: "Select Execs Config File"
        browserIcon: "play_arrow"
        browserType: "generic"
        fileExtensions: ["*.conf"]
        saveMode: false
        showHiddenFiles: true
        
        onFileSelected: path => {
            var cleanPath = path.replace(/^file:\/\//, '')
            SettingsData.execsPath = cleanPath
            SettingsData.saveSettings()
            execsTab.execsPath = cleanPath
            loadExecs()
            close()
        }
    }
}

