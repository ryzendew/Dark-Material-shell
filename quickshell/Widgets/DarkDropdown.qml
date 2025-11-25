import "../Common/fzf.js" as Fzf
import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Widgets

Rectangle {
    id: root
    
    FontLoader {
        id: notoSansLoader
        source: "/usr/share/fonts/google-noto/NotoSans-Regular.ttf"
    }
    
    readonly property string notoSansFamily: notoSansLoader.status === FontLoader.Ready ? notoSansLoader.name : "Noto Sans"

    property string text: ""
    property string description: ""
    property string currentValue: ""
    property var options: []
    property var optionIcons: []
    property bool forceRecreate: false
    property bool enableFuzzySearch: false
    property int popupWidthOffset: 0
    property int maxPopupHeight: 400
    // Height of the clickable box on the right (the one in your screenshot)
    property int controlHeight: 42

    signal valueChanged(string value)

    width: parent.width
    height: Math.max(60, controlHeight + Theme.spacingL * 2)
    radius: Theme.cornerRadius
    color: "transparent"
    Component.onCompleted: forceRecreateTimer.start()
    Component.onDestruction: {
        const popup = popupLoader.item
        if (popup && popup.visible) {
            popup.close()
        }
    }
    onVisibleChanged: {
        const popup = popupLoader.item
        if (!visible && popup && popup.visible) {
            popup.close()
        } else if (visible) {
            forceRecreateTimer.start()
        }
    }

    Timer {
        id: forceRecreateTimer

        interval: 50
        repeat: false
        onTriggered: root.forceRecreate = !root.forceRecreate
    }

    Column {
        anchors.left: parent.left
        anchors.right: dropdown.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: Theme.spacingM
        anchors.rightMargin: Theme.spacingM
        spacing: Theme.spacingXS

        Text {
            text: root.text
            font.pixelSize: Theme.fontSizeMedium
            font.family: root.notoSansFamily
            color: Theme.surfaceText
            font.weight: Font.Medium
            visible: !root.currentValue || root.currentValue === ""
        }

        Text {
            text: root.description
            font.pixelSize: Theme.fontSizeSmall
            font.family: root.notoSansFamily
            color: Theme.surfaceVariantText
            visible: description.length > 0
            wrapMode: Text.WordWrap
            width: parent.width
        }
    }

    Rectangle {
        id: dropdown

        width: root.width <= 60 ? root.width : 180
        height: root.controlHeight
        anchors.right: parent.right
        anchors.rightMargin: Theme.spacingM
        anchors.verticalCenter: parent.verticalCenter
        radius: Theme.cornerRadius
        color: dropdownArea.containsMouse ? Theme.primaryHover : Theme.contentBackground()
        border.color: Theme.surfaceVariantAlpha
        border.width: 1

        MouseArea {
            id: dropdownArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                const popup = popupLoader.item
                if (!popup) {
                    return
                }

                if (popup.visible) {
                    popup.close()
                    return
                }

                const pos = dropdown.mapToItem(Overlay.overlay, 0, dropdown.height + 4)
                popup.x = pos.x - (root.popupWidthOffset / 2)
                popup.y = pos.y
                popup.open()
            }
        }

        Row {
            id: contentRow

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: Theme.spacingM
            spacing: Theme.spacingS

            Item {
                width: root.currentValue ? 18 : 0
                height: 18
                visible: {
                    if (!root.currentValue || root.currentValue === "") return false
                    const currentIndex = root.options.indexOf(root.currentValue)
                    return currentIndex >= 0 && root.optionIcons.length > currentIndex && root.optionIcons[currentIndex] !== "" && root.width > 60
                }
                
                Image {
                    anchors.centerIn: parent
                    width: 18
                    height: 18
                    source: {
                        const currentIndex = root.options.indexOf(root.currentValue)
                        const iconName = currentIndex >= 0 && root.optionIcons.length > currentIndex ? root.optionIcons[currentIndex] : ""
                        return iconName && iconName !== "" ? "image://icon/" + iconName : ""
                    }
                    sourceSize.width: 18
                    sourceSize.height: 18
                    fillMode: Image.PreserveAspectFit
                }
            }

            Text {
                text: root.currentValue || ""
                font.pixelSize: Theme.fontSizeMedium
                font.family: root.notoSansFamily
                font.weight: Font.Normal
                color: Theme.surfaceText
                width: root.width <= 60 ? dropdown.width - expandIcon.width - Theme.spacingS * 2 : dropdown.width - contentRow.x - expandIcon.width - Theme.spacingM - Theme.spacingS
                elide: root.width <= 60 ? Text.ElideNone : Text.ElideRight
                horizontalAlignment: root.width <= 60 ? Text.AlignHCenter : Text.AlignLeft
                visible: root.currentValue && root.currentValue !== ""
            }
        }

        Item {
            id: expandIcon
            width: root.currentValue ? 0 : 20
            height: 20
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: Theme.spacingS
            visible: !root.currentValue || root.currentValue === ""
            
            DarkIcon {
                anchors.centerIn: parent
                name: "expand_more"
                size: 20
                color: Theme.surfaceText
            }
        }
    }

    Loader {
        id: popupLoader

        property bool recreateFlag: root.forceRecreate

        active: true
        onRecreateFlagChanged: {
            active = false
            active = true
        }

        sourceComponent: Component {
            Popup {
                id: dropdownMenu

                property string searchQuery: ""
                property var filteredOptions: []
                property int selectedIndex: -1
                readonly property string notoSansFamily: root.notoSansFamily
                property var fzfFinder: new Fzf.Finder(root.options, {
                                                           "selector": option => option,
                                                           "limit": 50,
                                                           "casing": "case-insensitive"
                                                       })

                function updateFilteredOptions() {
                    if (!root.enableFuzzySearch || searchQuery.length === 0) {
                        filteredOptions = root.options
                        selectedIndex = -1
                        return
                    }

                    const results = fzfFinder.find(searchQuery)
                    filteredOptions = results.map(result => result.item)
                    selectedIndex = -1
                }

                function selectNext() {
                    if (filteredOptions.length === 0) {
                        return
                    }
                    selectedIndex = (selectedIndex + 1) % filteredOptions.length
                    listView.positionViewAtIndex(selectedIndex, ListView.Contain)
                }

                function selectPrevious() {
                    if (filteredOptions.length === 0) {
                        return
                    }
                    selectedIndex = selectedIndex <= 0 ? filteredOptions.length - 1 : selectedIndex - 1
                    listView.positionViewAtIndex(selectedIndex, ListView.Contain)
                }

                function selectCurrent() {
                    if (selectedIndex < 0 || selectedIndex >= filteredOptions.length) {
                        return
                    }
                    root.currentValue = filteredOptions[selectedIndex]
                    root.valueChanged(filteredOptions[selectedIndex])
                    close()
                }

                parent: Overlay.overlay
                width: dropdown.width + root.popupWidthOffset
                height: Math.min(root.maxPopupHeight, (root.enableFuzzySearch ? 54 : 0) + Math.min(filteredOptions.length, 10) * 36 + 16)
                padding: 0
                modal: true
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                onOpened: {
                    searchQuery = ""
                    updateFilteredOptions()
                    if (root.enableFuzzySearch && searchField.visible) {
                        searchField.forceActiveFocus()
                    }
                }

                background: Rectangle {
                    color: "transparent"
                }

                contentItem: Rectangle {
                    color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 1)
                    border.color: Theme.primarySelected
                    border.width: 1
                    radius: Theme.cornerRadius

                    Column {
                        anchors.fill: parent
                        anchors.margins: Theme.spacingS

                        Rectangle {
                            id: searchContainer

                            width: parent.width
                            height: 42
                            visible: root.enableFuzzySearch
                            radius: Theme.cornerRadius
                            color: Theme.surfaceVariantAlpha

                            DarkTextField {
                                id: searchField

                                anchors.fill: parent
                                anchors.margins: 1
                                placeholderText: "Search..."
                                text: searchQuery
                                topPadding: Theme.spacingS
                                bottomPadding: Theme.spacingS
                                onTextChanged: {
                                    searchQuery = text
                                    updateFilteredOptions()
                                }
                                Keys.onDownPressed: selectNext()
                                Keys.onUpPressed: selectPrevious()
                                Keys.onReturnPressed: selectCurrent()
                                Keys.onEnterPressed: selectCurrent()
                            }
                        }

                        Item {
                            width: 1
                            height: Theme.spacingXS
                            visible: root.enableFuzzySearch
                        }

                        DarkListView {
                            id: listView

                            property var popupRef: dropdownMenu

                            width: parent.width
                            height: parent.height - (root.enableFuzzySearch ? searchContainer.height + Theme.spacingXS : 0)
                            clip: true
                            model: filteredOptions
                            spacing: 2

                            interactive: true
                            flickDeceleration: 1500
                            maximumFlickVelocity: 2000
                            boundsBehavior: Flickable.DragAndOvershootBounds
                            boundsMovement: Flickable.FollowBoundsBehavior
                            pressDelay: 0
                            flickableDirection: Flickable.VerticalFlick

                            delegate: Rectangle {
                                property bool isSelected: selectedIndex === index
                                property bool isCurrentValue: root.currentValue === modelData
                                property int optionIndex: root.options.indexOf(modelData)

                                width: ListView.view.width
                                height: 32
                                radius: Theme.cornerRadius
                                color: isSelected ? Theme.primaryHover : optionArea.containsMouse ? Theme.primaryHoverLight : "transparent"

                                Row {
                                    anchors.left: parent.left
                                    anchors.leftMargin: Theme.spacingS
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: Theme.spacingS

                                    Item {
                                        width: 18
                                        height: 18
                                        visible: optionIndex >= 0 && root.optionIcons.length > optionIndex && root.optionIcons[optionIndex] !== ""
                                        
                                        Image {
                                            anchors.centerIn: parent
                                            width: 18
                                            height: 18
                                            source: {
                                                const iconName = optionIndex >= 0 && root.optionIcons.length > optionIndex ? root.optionIcons[optionIndex] : ""
                                                return iconName && iconName !== "" ? "image://icon/" + iconName : ""
                                            }
                                            sourceSize.width: 18
                                            sourceSize.height: 18
                                            fillMode: Image.PreserveAspectFit
                                        }
                                    }

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: modelData
                                        font.pixelSize: Theme.fontSizeMedium
                                        font.family: dropdownMenu.notoSansFamily
                                        font.weight: isCurrentValue ? Font.Medium : Font.Normal
                                        color: isCurrentValue ? Theme.primary : Theme.surfaceText
                                        width: parent.parent.width - parent.x - Theme.spacingS
                                        elide: Text.ElideRight
                                        
                                    }
                                }

                                MouseArea {
                                    id: optionArea

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        root.currentValue = modelData
                                        root.valueChanged(modelData)
                                        dropdownMenu.close()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
