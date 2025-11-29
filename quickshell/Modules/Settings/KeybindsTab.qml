import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Widgets

Item {
    id: keybindsTab

    readonly property string keybindsPath: (Quickshell.env("HOME") || StandardPaths.writableLocation(StandardPaths.HomeLocation)) + "/.config/hypr/hyprland/keybinds.conf"
    
    property var keybinds: []
    property bool isLoading: false
    property bool hasUnsavedChanges: false
    property int editingIndex: -1

    readonly property var builtInKeybinds: [
        { "name": "Open Terminal", "modifiers": "SUPER", "key": "Q", "command": "exec, $terminal" },
        { "name": "Close Window", "modifiers": "SUPER", "key": "X", "command": "killactive" },
        { "name": "Toggle Floating", "modifiers": "SUPER", "key": "SPACE", "command": "togglefloating" },
        { "name": "Toggle Fullscreen", "modifiers": "SUPER", "key": "F", "command": "fullscreen" },
        { "name": "Move Focus Left", "modifiers": "SUPER", "key": "H", "command": "movefocus, l" },
        { "name": "Move Focus Right", "modifiers": "SUPER", "key": "L", "command": "movefocus, r" },
        { "name": "Move Focus Up", "modifiers": "SUPER", "key": "K", "command": "movefocus, u" },
        { "name": "Move Focus Down", "modifiers": "SUPER", "key": "J", "command": "movefocus, d" },
        { "name": "Move Window Left", "modifiers": "SUPER SHIFT", "key": "H", "command": "movewindow, l" },
        { "name": "Move Window Right", "modifiers": "SUPER SHIFT", "key": "L", "command": "movewindow, r" },
        { "name": "Move Window Up", "modifiers": "SUPER SHIFT", "key": "K", "command": "movewindow, u" },
        { "name": "Move Window Down", "modifiers": "SUPER SHIFT", "key": "J", "command": "movewindow, d" },
        { "name": "Resize Window Left", "modifiers": "SUPER CTRL", "key": "H", "command": "resizewindow, l -20 0" },
        { "name": "Resize Window Right", "modifiers": "SUPER CTRL", "key": "L", "command": "resizewindow, r 20 0" },
        { "name": "Resize Window Up", "modifiers": "SUPER CTRL", "key": "K", "command": "resizewindow, u 0 -20" },
        { "name": "Resize Window Down", "modifiers": "SUPER CTRL", "key": "J", "command": "resizewindow, d 0 20" },
        { "name": "Toggle Split", "modifiers": "SUPER", "key": "E", "command": "togglesplit" },
        { "name": "Toggle Pseudo", "modifiers": "SUPER", "key": "P", "command": "pseudo" },
        { "name": "Pin Window", "modifiers": "SUPER", "key": "S", "command": "pin" },
        { "name": "Move to Workspace 1", "modifiers": "SUPER", "key": "1", "command": "workspace, 1" },
        { "name": "Move to Workspace 2", "modifiers": "SUPER", "key": "2", "command": "workspace, 2" },
        { "name": "Move to Workspace 3", "modifiers": "SUPER", "key": "3", "command": "workspace, 3" },
        { "name": "Move to Workspace 4", "modifiers": "SUPER", "key": "4", "command": "workspace, 4" },
        { "name": "Move to Workspace 5", "modifiers": "SUPER", "key": "5", "command": "workspace, 5" },
        { "name": "Move to Workspace 6", "modifiers": "SUPER", "key": "6", "command": "workspace, 6" },
        { "name": "Move to Workspace 7", "modifiers": "SUPER", "key": "7", "command": "workspace, 7" },
        { "name": "Move to Workspace 8", "modifiers": "SUPER", "key": "8", "command": "workspace, 8" },
        { "name": "Move to Workspace 9", "modifiers": "SUPER", "key": "9", "command": "workspace, 9" },
        { "name": "Move Window to Workspace 1", "modifiers": "SUPER SHIFT", "key": "1", "command": "movetoworkspace, 1" },
        { "name": "Move Window to Workspace 2", "modifiers": "SUPER SHIFT", "key": "2", "command": "movetoworkspace, 2" },
        { "name": "Move Window to Workspace 3", "modifiers": "SUPER SHIFT", "key": "3", "command": "movetoworkspace, 3" },
        { "name": "Move Window to Workspace 4", "modifiers": "SUPER SHIFT", "key": "4", "command": "movetoworkspace, 4" },
        { "name": "Move Window to Workspace 5", "modifiers": "SUPER SHIFT", "key": "5", "command": "movetoworkspace, 5" },
        { "name": "Move Window to Workspace 6", "modifiers": "SUPER SHIFT", "key": "6", "command": "movetoworkspace, 6" },
        { "name": "Move Window to Workspace 7", "modifiers": "SUPER SHIFT", "key": "7", "command": "movetoworkspace, 7" },
        { "name": "Move Window to Workspace 8", "modifiers": "SUPER SHIFT", "key": "8", "command": "movetoworkspace, 8" },
        { "name": "Move Window to Workspace 9", "modifiers": "SUPER SHIFT", "key": "9", "command": "movetoworkspace, 9" },
        { "name": "Scroll Workspace", "modifiers": "SUPER", "key": "mouse_down", "command": "workspace, e+1" },
        { "name": "Scroll Workspace (Reverse)", "modifiers": "SUPER", "key": "mouse_up", "command": "workspace, e-1" },
        { "name": "Toggle Special Workspace", "modifiers": "SUPER", "key": "S", "command": "togglespecialworkspace" },
        { "name": "Move Window to Special Workspace", "modifiers": "SUPER SHIFT", "key": "S", "command": "movetoworkspace, special" },
        { "name": "Toggle Overview", "modifiers": "SUPER", "key": "O", "command": "overview" },
        { "name": "Toggle Group", "modifiers": "SUPER", "key": "G", "command": "togglegroup" },
        { "name": "Change Group Window", "modifiers": "SUPER", "key": "Tab", "command": "changegroupactive" },
        { "name": "Lock Screen", "modifiers": "SUPER", "key": "L", "command": "exec, $lock" },
        { "name": "Exit Hyprland", "modifiers": "SUPER SHIFT", "key": "Q", "command": "exit" },
        { "name": "Reload Config", "modifiers": "SUPER SHIFT", "key": "R", "command": "exec, hyprctl reload" },
        { "name": "Open App Launcher", "modifiers": "SUPER", "key": "A", "command": "exec, $menu" },
        { "name": "Screenshot", "modifiers": "SUPER", "key": "PRINT", "command": "exec, $screenshot" },
        { "name": "Screenshot Area", "modifiers": "SUPER SHIFT", "key": "S", "command": "exec, $screenshotarea" },
        { "name": "Dock - Toggle Dock", "modifiers": "SUPER", "key": "D", "command": "exec, hyprctl dispatch togglespecialworkspace quickshell:dock:blur" },
        { "name": "Dock - Show Dock", "modifiers": "SUPER", "key": "B", "command": "exec, hyprctl dispatch togglespecialworkspace quickshell:dock:blur" },
        { "name": "Dock - Hide Dock", "modifiers": "SUPER SHIFT", "key": "D", "command": "exec, hyprctl dispatch togglespecialworkspace quickshell:dock:blur" }
    ]

    Component.onCompleted: {
        loadKeybinds()
    }

    function loadKeybinds() {
        isLoading = true
        keybindsFile.path = ""
        keybindsFile.path = keybindsPath
    }

    function parseKeybinds(content) {
        var lines = content.split('\n')
        var parsed = []
        
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim()
            
            if (line.length === 0 || line.startsWith('#')) {
                parsed.push({
                    type: 'comment',
                    original: lines[i],
                    text: line
                })
                continue
            }
            
            var bindMatch = line.match(/^bind[rs]?\s*=\s*(.+)$/)
            if (bindMatch) {
                var parts = bindMatch[1].split(',').map(p => p.trim())
                if (parts.length >= 2) {
                    var modifiers = parts[0]
                    var key = parts[1]
                    var command = parts.slice(2).join(',').trim()
                    
                    parsed.push({
                        type: 'keybind',
                        original: lines[i],
                        modifiers: modifiers,
                        key: key,
                        command: command,
                        isRelease: line.startsWith('bindr')
                    })
                } else {
                    parsed.push({
                        type: 'raw',
                        original: lines[i],
                        text: line
                    })
                }
            } else {
                parsed.push({
                    type: 'raw',
                    original: lines[i],
                    text: line
                })
            }
        }
        
        keybinds = parsed
        isLoading = false
        hasUnsavedChanges = false
    }

    function saveKeybinds() {
        var content = keybinds.map(item => {
            if (item.type === 'comment' || item.type === 'raw') {
                return item.original
            } else if (item.type === 'keybind') {
                var bindType = item.isRelease ? 'bindr' : 'bind'
                var parts = [item.modifiers, item.key]
                if (item.command) {
                    parts.push(item.command)
                }
                return bindType + ' = ' + parts.join(', ')
            }
            return item.original
        }).join('\n')
        
        keybindsFile.setText(content)
        hasUnsavedChanges = false
    }

    function addNewKeybind() {
        var newKeybind = {
            type: 'keybind',
            original: 'bind = , , ',
            modifiers: '',
            key: '',
            command: '',
            isRelease: false
        }
        keybinds.push(newKeybind)
        editingIndex = keybinds.length - 1
        hasUnsavedChanges = true
    }

    function addBuiltInKeybind(builtIn) {
        var newKeybind = {
            type: 'keybind',
            original: 'bind = ' + builtIn.modifiers + ', ' + builtIn.key + ', ' + builtIn.command,
            modifiers: builtIn.modifiers,
            key: builtIn.key,
            command: builtIn.command,
            isRelease: false
        }
        keybinds.push(newKeybind)
        editingIndex = keybinds.length - 1
        hasUnsavedChanges = true
        builtInKeybindsPopup.close()
    }

    function startEditing(index) {
        editingIndex = index
    }

    function stopEditing() {
        editingIndex = -1
    }

    FileView {
        id: keybindsFile
        path: keybindsTab.keybindsPath
        blockWrites: true
        atomicWrites: true
        
        onLoaded: {
            parseKeybinds(text())
        }
        
        onLoadFailed: {
            isLoading = false
            if (typeof ToastService !== "undefined") {
                ToastService.showError("Failed to load keybinds file")
            }
        }
        
        onSaved: {
            if (typeof ToastService !== "undefined") {
                ToastService.showSuccess("Keybinds saved successfully")
            }
        }
        
        onSaveFailed: {
            if (typeof ToastService !== "undefined") {
                ToastService.showError("Failed to save keybinds file")
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
                            name: "keyboard"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingM
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: "Hyprland Keybinds"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Manage keyboard shortcuts for Hyprland window manager"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                            }
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: Theme.spacingS

                        Rectangle {
                            width: 120
                            height: 36
                            radius: Theme.cornerRadius
                            color: reloadMouseArea.containsMouse ? Theme.primaryContainer : Theme.surfaceVariant
                            enabled: !isLoading
                            opacity: enabled ? 1 : 0.5

                            StyledText {
                                anchors.centerIn: parent
                                text: "Reload"
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.surfaceText
                            }

                            MouseArea {
                                id: reloadMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                enabled: parent.enabled
                                onClicked: loadKeybinds()
                            }
                        }

                        Rectangle {
                            width: 120
                            height: 36
                            radius: Theme.cornerRadius
                            color: saveMouseArea.containsMouse ? Theme.primary : (hasUnsavedChanges ? Theme.primaryContainer : Theme.surfaceVariant)
                            enabled: hasUnsavedChanges && !isLoading
                            opacity: enabled ? 1 : 0.5

                            StyledText {
                                anchors.centerIn: parent
                                text: "Save"
                                font.pixelSize: Theme.fontSizeMedium
                                color: enabled ? Theme.onPrimary : Theme.surfaceText
                            }

                            MouseArea {
                                id: saveMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                enabled: parent.enabled
                                onClicked: saveKeybinds()
                            }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: keybindsSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                border.width: 1
                visible: !isLoading

                Column {
                    id: keybindsSection
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
                                text: "Keybinds"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Edit keyboard shortcuts. Format: bind = MODIFIER, KEY, COMMAND"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                            }
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: Theme.spacingS

                        Rectangle {
                            width: 140
                            height: 36
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
                                    text: "Add Keybind"
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
                                onClicked: addNewKeybind()
                            }
                        }

                        Rectangle {
                            width: 180
                            height: 36
                            radius: Theme.cornerRadius
                            color: builtInMouseArea.containsMouse ? Theme.primaryContainer : Theme.surfaceVariant

                            Row {
                                anchors.centerIn: parent
                                spacing: Theme.spacingXS

                                DarkIcon {
                                    name: "list"
                                    size: 18
                                    color: Theme.surfaceText
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                StyledText {
                                    text: "Add Built-in Keybind"
                                    font.pixelSize: Theme.fontSizeMedium
                                    color: Theme.surfaceText
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: builtInMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: builtInKeybindsPopup.open()
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 32
                        radius: Theme.cornerRadius
                        color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.5)
                        visible: keybindsTab.keybinds.filter(k => k.type === 'keybind').length > 0

                        Row {
                            anchors.fill: parent
                            anchors.margins: Theme.spacingM
                            spacing: Theme.spacingM

                            StyledText {
                                width: 140
                                text: "Modifier"
                                font.pixelSize: Theme.fontSizeSmall
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                                verticalAlignment: Text.AlignVCenter
                            }

                            StyledText {
                                width: 120
                                text: "Key"
                                font.pixelSize: Theme.fontSizeSmall
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                                verticalAlignment: Text.AlignVCenter
                            }

                            StyledText {
                                width: parent.width - 140 - 120 - 40
                                text: "Command"
                                font.pixelSize: Theme.fontSizeSmall
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }

                    DarkFlickable {
                        width: parent.width
                        height: Math.min(600, keybindsList.height)
                        clip: true
                        contentHeight: keybindsList.height
                        contentWidth: width

                        Column {
                            id: keybindsList
                            width: parent.width
                            spacing: Theme.spacingXS

                            Repeater {
                                model: keybindsTab.keybinds

                                Item {
                                    width: parent.width
                                    height: keybindItem.height
                                    visible: modelData.type === 'keybind'

                                    Rectangle {
                                        id: keybindItem
                                        width: parent.width
                                        height: 48
                                        radius: Theme.cornerRadius
                                        color: itemMouseArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.08) : Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.2)
                                        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.1)
                                        border.width: 1

                                        Row {
                                            id: keybindContent
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.margins: Theme.spacingM
                                            spacing: Theme.spacingM

                                            property bool isEditing: keybindsTab.editingIndex === index

                                            StyledText {
                                                width: 140
                                                text: modelData.modifiers || "MOD"
                                                font.pixelSize: Theme.fontSizeMedium
                                                color: modelData.modifiers ? Theme.surfaceText : Theme.surfaceVariantText
                                                verticalAlignment: Text.AlignVCenter
                                                visible: !keybindContent.isEditing

                                                MouseArea {
                                                    anchors.fill: parent
                                                    propagateComposedEvents: false
                                                    onClicked: (mouse) => {
                                                        if (keybindsTab.editingIndex !== index) {
                                                            keybindsTab.startEditing(index)
                                                        }
                                                        Qt.callLater(() => {
                                                            modifiersField.forceActiveFocus()
                                                            modifiersField.selectAll()
                                                        })
                                                        mouse.accepted = true
                                                    }
                                                }
                                            }

                                            DarkTextField {
                                                id: modifiersField
                                                width: 140
                                                placeholderText: "MOD"
                                                text: modelData.modifiers || ""
                                                visible: keybindContent.isEditing
                                                onVisibleChanged: {
                                                    if (visible && keybindsTab.editingIndex === index && !keyField.activeFocus && !commandField.activeFocus) {
                                                        Qt.callLater(() => {
                                                            forceActiveFocus()
                                                            selectAll()
                                                        })
                                                    }
                                                }
                                                onTextChanged: {
                                                    if (modelData.modifiers !== text) {
                                                        modelData.modifiers = text
                                                        keybindsTab.hasUnsavedChanges = true
                                                    }
                                                }
                                                Keys.onEscapePressed: {
                                                    keybindsTab.stopEditing()
                                                }
                                                Keys.onTabPressed: {
                                                    keyField.forceActiveFocus()
                                                    keyField.selectAll()
                                                }
                                                Keys.onEnterPressed: {
                                                    keybindsTab.stopEditing()
                                                }
                                                Keys.onReturnPressed: {
                                                    keybindsTab.stopEditing()
                                                }
                                            }

                                            StyledText {
                                                width: 120
                                                text: modelData.key || "key"
                                                font.pixelSize: Theme.fontSizeMedium
                                                color: modelData.key ? Theme.surfaceText : Theme.surfaceVariantText
                                                verticalAlignment: Text.AlignVCenter
                                                visible: !keybindContent.isEditing

                                                MouseArea {
                                                    anchors.fill: parent
                                                    propagateComposedEvents: false
                                                    onClicked: (mouse) => {
                                                        if (keybindsTab.editingIndex !== index) {
                                                            keybindsTab.startEditing(index)
                                                        }
                                                        Qt.callLater(() => {
                                                            keyField.forceActiveFocus()
                                                            keyField.selectAll()
                                                        })
                                                        mouse.accepted = true
                                                    }
                                                }
                                            }

                                            DarkTextField {
                                                id: keyField
                                                width: 120
                                                placeholderText: "key"
                                                text: modelData.key || ""
                                                visible: keybindContent.isEditing
                                                onTextChanged: {
                                                    if (modelData.key !== text) {
                                                        modelData.key = text
                                                        keybindsTab.hasUnsavedChanges = true
                                                    }
                                                }
                                                Keys.onEscapePressed: {
                                                    keybindsTab.stopEditing()
                                                }
                                                Keys.onTabPressed: {
                                                    commandField.forceActiveFocus()
                                                    commandField.selectAll()
                                                }
                                                Keys.onEnterPressed: {
                                                    keybindsTab.stopEditing()
                                                }
                                                Keys.onReturnPressed: {
                                                    keybindsTab.stopEditing()
                                                }
                                            }

                                            StyledText {
                                                width: parent.width - 140 - 120 - 40
                                                text: modelData.command || "command"
                                                font.pixelSize: Theme.fontSizeMedium
                                                color: modelData.command ? Theme.surfaceText : Theme.surfaceVariantText
                                                elide: Text.ElideRight
                                                verticalAlignment: Text.AlignVCenter
                                                visible: !keybindContent.isEditing

                                                MouseArea {
                                                    anchors.fill: parent
                                                    propagateComposedEvents: false
                                                    onClicked: (mouse) => {
                                                        if (keybindsTab.editingIndex !== index) {
                                                            keybindsTab.startEditing(index)
                                                        }
                                                        Qt.callLater(() => {
                                                            commandField.forceActiveFocus()
                                                            commandField.selectAll()
                                                        })
                                                        mouse.accepted = true
                                                    }
                                                }
                                            }

                                            DarkTextField {
                                                id: commandField
                                                width: parent.width - 140 - 120 - 40
                                                placeholderText: "command"
                                                text: modelData.command || ""
                                                visible: keybindContent.isEditing
                                                onTextChanged: {
                                                    if (modelData.command !== text) {
                                                        modelData.command = text
                                                        keybindsTab.hasUnsavedChanges = true
                                                    }
                                                }
                                                Keys.onEscapePressed: {
                                                    keybindsTab.stopEditing()
                                                }
                                                Keys.onEnterPressed: {
                                                    keybindsTab.stopEditing()
                                                }
                                                Keys.onReturnPressed: {
                                                    keybindsTab.stopEditing()
                                                }
                                            }

                                            DarkActionButton {
                                                buttonSize: 32
                                                circular: true
                                                iconName: "delete"
                                                iconSize: 16
                                                iconColor: Theme.error
                                                anchors.verticalCenter: parent.verticalCenter
                                                visible: itemMouseArea.containsMouse && !keybindContent.isEditing
                                                onClicked: {
                                                    keybindsTab.keybinds.splice(index, 1)
                                                    keybindsTab.hasUnsavedChanges = true
                                                }
                                            }
                                        }

                                        MouseArea {
                                            id: itemMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            propagateComposedEvents: true
                                            onClicked: {
                                                if (keybindsTab.editingIndex !== index) {
                                                    keybindsTab.startEditing(index)
                                                    Qt.callLater(() => {
                                                        modifiersField.forceActiveFocus()
                                                        modifiersField.selectAll()
                                                    })
                                                }
                                            }
                                            onPressed: (mouse) => {
                                                if (keybindsTab.editingIndex !== index && keybindsTab.editingIndex !== -1) {
                                                    keybindsTab.stopEditing()
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
                        text: "Loading keybinds..."
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.surfaceText
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }

    Popup {
        id: builtInKeybindsPopup

        parent: Overlay.overlay
        width: 500
        height: Math.min(600, builtInList.height + Theme.spacingL * 2)
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: StyledRect {
            color: Theme.surfaceContainer
            border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.3)
            border.width: 1
            radius: Theme.cornerRadius

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Qt.rgba(0, 0, 0, 0.3)
                shadowBlur: 0.8
                shadowHorizontalOffset: 0
                shadowVerticalOffset: 4
            }
        }

        Column {
            anchors.fill: parent
            anchors.margins: Theme.spacingL
            spacing: Theme.spacingM

            Row {
                width: parent.width
                spacing: Theme.spacingM

                DarkIcon {
                    name: "list"
                    size: Theme.iconSize
                    color: Theme.primary
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    width: parent.width - Theme.iconSize - Theme.spacingM
                    spacing: Theme.spacingXS
                    anchors.verticalCenter: parent.verticalCenter

                    StyledText {
                        text: "Built-in Keybinds"
                        font.pixelSize: Theme.fontSizeLarge
                        font.weight: Font.Medium
                        color: Theme.surfaceText
                    }

                    StyledText {
                        text: "Select a keybind to add to your configuration"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        wrapMode: Text.WordWrap
                    }
                }
            }

            DarkFlickable {
                width: parent.width
                height: parent.height - 100
                clip: true
                contentHeight: builtInList.height
                contentWidth: width

                Column {
                    id: builtInList
                    width: parent.width
                    spacing: Theme.spacingXS

                    Repeater {
                        model: keybindsTab.builtInKeybinds

                        Rectangle {
                            width: parent.width
                            height: 56
                            radius: Theme.cornerRadius
                            color: builtInMouseArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.08) : Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.3)
                            border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.1)
                            border.width: 1

                            Row {
                                anchors.fill: parent
                                anchors.margins: Theme.spacingM
                                spacing: Theme.spacingM

                                Column {
                                    width: parent.width - 100
                                    spacing: Theme.spacingXS
                                    anchors.verticalCenter: parent.verticalCenter

                                    StyledText {
                                        text: modelData.name
                                        font.pixelSize: Theme.fontSizeMedium
                                        font.weight: Font.Medium
                                        color: Theme.surfaceText
                                    }

                                    StyledText {
                                        text: modelData.modifiers + " + " + modelData.key + " → " + modelData.command
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                        font.family: "monospace"
                                        elide: Text.ElideRight
                                    }
                                }

                                DarkActionButton {
                                    buttonSize: 32
                                    circular: true
                                    iconName: "add"
                                    iconSize: 18
                                    iconColor: Theme.primary
                                    anchors.verticalCenter: parent.verticalCenter
                                    onClicked: keybindsTab.addBuiltInKeybind(modelData)
                                }
                            }

                            MouseArea {
                                id: builtInMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: keybindsTab.addBuiltInKeybind(modelData)
                            }
                        }
                    }
                }
            }
        }
    }
}
