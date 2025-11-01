import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Widgets

ScrollView {
    id: root

    contentWidth: contentColumn.width
    contentHeight: contentColumn.height

    Column {
        id: contentColumn
        width: parent.width
        spacing: Theme.spacingL

        // Desktop Widgets Header
        Column {
            width: parent.width
            spacing: Theme.spacingS

            StyledText {
                text: "Desktop Widgets"
                font.pixelSize: Theme.fontSizeXLarge
                color: Theme.surfaceText
                font.weight: Font.Bold
            }

            StyledText {
                text: "Enable floating desktop widgets for system monitoring"
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.surfaceTextMedium
                wrapMode: Text.WordWrap
                width: parent.width
            }
        }

        // Master Toggle
        Column {
            width: parent.width
            spacing: Theme.spacingS

            StyledText {
                text: "Enable Desktop Widgets"
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.surfaceText
                font.weight: Font.Medium
            }

            StyledText {
                text: "Master switch to enable/disable all desktop widgets"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceTextMedium
                wrapMode: Text.WordWrap
                width: parent.width
            }

            DankToggle {
                checked: SettingsData.desktopWidgetsEnabled
                onToggled: {
                    SettingsData.setDesktopWidgetsEnabled(checked)
                }
            }
        }

        // Individual Widget Toggles
        Column {
            width: parent.width
            spacing: Theme.spacingL
            visible: SettingsData.desktopWidgetsEnabled

            // CPU Temperature Widget
            Column {
                width: parent.width
                spacing: Theme.spacingS

                StyledText {
                    text: "CPU Temperature Widget"
                    font.pixelSize: Theme.fontSizeLarge
                    color: Theme.surfaceText
                    font.weight: Font.Medium
                }

                StyledText {
                    text: "Shows CPU temperature with color-coded warnings"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceTextMedium
                    wrapMode: Text.WordWrap
                    width: parent.width
                }

                DankToggle {
                    checked: SettingsData.desktopCpuTempEnabled
                    onToggled: {
                        SettingsData.setDesktopCpuTempEnabled(checked)
                    }
                }
                
                // Opacity slider
                Column {
                    width: parent.width
                    spacing: Theme.spacingXS
                    visible: SettingsData.desktopCpuTempEnabled
                    
                    StyledText {
                        text: "Opacity: " + Math.round(SettingsData.desktopCpuTempOpacity * 100) + "%"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceTextMedium
                    }
                    
                    Slider {
                        width: parent.width
                        from: 0.1
                        to: 1.0
                        stepSize: 0.1
                        value: SettingsData.desktopCpuTempOpacity
                        onValueChanged: {
                            SettingsData.setDesktopCpuTempOpacity(value)
                        }
                    }
                }
            }

            // GPU Temperature Widget
            Column {
                width: parent.width
                spacing: Theme.spacingS

                StyledText {
                    text: "GPU Temperature Widget"
                    font.pixelSize: Theme.fontSizeLarge
                    color: Theme.surfaceText
                    font.weight: Font.Medium
                }

                StyledText {
                    text: "Shows GPU temperature with color-coded warnings"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceTextMedium
                    wrapMode: Text.WordWrap
                    width: parent.width
                }

                DankToggle {
                    checked: SettingsData.desktopGpuTempEnabled
                    onToggled: {
                        SettingsData.setDesktopGpuTempEnabled(checked)
                    }
                }
                
                // Opacity slider
                Column {
                    width: parent.width
                    spacing: Theme.spacingXS
                    visible: SettingsData.desktopGpuTempEnabled
                    
                    StyledText {
                        text: "Opacity: " + Math.round(SettingsData.desktopGpuTempOpacity * 100) + "%"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceTextMedium
                    }
                    
                    Slider {
                        width: parent.width
                        from: 0.1
                        to: 1.0
                        stepSize: 0.1
                        value: SettingsData.desktopGpuTempOpacity
                        onValueChanged: {
                            SettingsData.setDesktopGpuTempOpacity(value)
                        }
                    }
                }
            }

            // System Monitor Widget
            Column {
                width: parent.width
                spacing: Theme.spacingS

                StyledText {
                    text: "System Monitor Widget"
                    font.pixelSize: Theme.fontSizeLarge
                    color: Theme.surfaceText
                    font.weight: Font.Medium
                }

                StyledText {
                    text: "Shows CPU temperature, GPU temperature, and RAM usage in one widget"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceTextMedium
                    wrapMode: Text.WordWrap
                    width: parent.width
                }

                DankToggle {
                    checked: SettingsData.desktopSystemMonitorEnabled
                    onToggled: {
                        SettingsData.setDesktopSystemMonitorEnabled(checked)
                    }
                }
                
                // Size sliders - moved up for visibility
                Column {
                    width: parent.width
                    spacing: Theme.spacingXS
                    visible: SettingsData.desktopSystemMonitorEnabled
                    
                    StyledText {
                        text: "Size: " + SettingsData.desktopSystemMonitorWidth + "x" + SettingsData.desktopSystemMonitorHeight
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceTextMedium
                    }
                    
                    // Width slider
                    Column {
                        width: parent.width
                        spacing: 4
                        
                        StyledText {
                            text: "Width: " + SettingsData.desktopSystemMonitorWidth + "px"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceTextMedium
                        }
                        
                        Slider {
                            width: parent.width
                            from: 200
                            to: 600
                            stepSize: 20
                            value: SettingsData.desktopSystemMonitorWidth
                            onValueChanged: {
                                SettingsData.setDesktopSystemMonitorWidth(value)
                            }
                        }
                    }
                    
                    // Height slider
                    Column {
                        width: parent.width
                        spacing: 4
                        
                        StyledText {
                            text: "Height: " + SettingsData.desktopSystemMonitorHeight + "px"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceTextMedium
                        }
                        
                        Slider {
                            width: parent.width
                            from: 120
                            to: 400
                            stepSize: 20
                            value: SettingsData.desktopSystemMonitorHeight
                            onValueChanged: {
                                SettingsData.setDesktopSystemMonitorHeight(value)
                            }
                        }
                    }
                }
                
                // Opacity slider
                Column {
                    width: parent.width
                    spacing: Theme.spacingXS
                    visible: SettingsData.desktopSystemMonitorEnabled
                    
                    StyledText {
                        text: "Opacity: " + Math.round(SettingsData.desktopSystemMonitorOpacity * 100) + "%"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceTextMedium
                    }
                    
                    Slider {
                        width: parent.width
                        from: 0.1
                        to: 1.0
                        stepSize: 0.1
                        value: SettingsData.desktopSystemMonitorOpacity
                        onValueChanged: {
                            SettingsData.setDesktopSystemMonitorOpacity(value)
                        }
                    }
                }
            }

            // Desktop Clock Widget
            Column {
                width: parent.width
                spacing: Theme.spacingS

                StyledText {
                    text: "Desktop Clock Widget"
                    font.pixelSize: Theme.fontSizeLarge
                    color: Theme.surfaceText
                    font.weight: Font.Medium
                }

                StyledText {
                    text: "Shows current time and date on the desktop"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceTextMedium
                    wrapMode: Text.WordWrap
                    width: parent.width
                }

                DankToggle {
                    checked: SettingsData.desktopClockEnabled
                    onToggled: {
                        SettingsData.setDesktopClockEnabled(checked)
                    }
                }
                
                // Opacity slider
                Column {
                    width: parent.width
                    spacing: Theme.spacingXS
                    visible: SettingsData.desktopClockEnabled
                    
                    StyledText {
                        text: "Opacity: " + Math.round(SettingsData.desktopClockOpacity * 100) + "%"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceTextMedium
                    }
                    
                    Slider {
                        width: parent.width
                        from: 0.1
                        to: 1.0
                        stepSize: 0.1
                        value: SettingsData.desktopClockOpacity
                        onValueChanged: {
                            SettingsData.setDesktopClockOpacity(value)
                        }
                    }
                }
            }

            // Desktop Terminal Widget
            Column {
                width: parent.width
                spacing: Theme.spacingS

                StyledText {
                    text: "Desktop Terminal Widget"
                    font.pixelSize: Theme.fontSizeLarge
                    color: Theme.surfaceText
                    font.weight: Font.Medium
                }

                StyledText {
                    text: "Interactive terminal widget for running commands directly on the desktop"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceTextMedium
                    wrapMode: Text.WordWrap
                    width: parent.width
                }

                DankToggle {
                    checked: SettingsData.desktopTerminalEnabled
                    onToggled: {
                        SettingsData.setDesktopTerminalEnabled(checked)
                    }
                }
                
                // Size sliders
                Column {
                    width: parent.width
                    spacing: Theme.spacingXS
                    visible: SettingsData.desktopTerminalEnabled
                    
                    StyledText {
                        text: "Size: " + SettingsData.desktopTerminalWidth + "x" + SettingsData.desktopTerminalHeight
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceTextMedium
                    }
                    
                    // Width slider
                    Column {
                        width: parent.width
                        spacing: 4
                        
                        StyledText {
                            text: "Width: " + SettingsData.desktopTerminalWidth + "px"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceTextMedium
                        }
                        
                        Slider {
                            width: parent.width
                            from: 400
                            to: 1200
                            stepSize: 50
                            value: SettingsData.desktopTerminalWidth
                            onValueChanged: {
                                SettingsData.setDesktopTerminalWidth(value)
                            }
                        }
                    }
                    
                    // Height slider
                    Column {
                        width: parent.width
                        spacing: 4
                        
                        StyledText {
                            text: "Height: " + SettingsData.desktopTerminalHeight + "px"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceTextMedium
                        }
                        
                        Slider {
                            width: parent.width
                            from: 200
                            to: 800
                            stepSize: 50
                            value: SettingsData.desktopTerminalHeight
                            onValueChanged: {
                                SettingsData.setDesktopTerminalHeight(value)
                            }
                        }
                    }
                    
                    // Font size slider
                    Column {
                        width: parent.width
                        spacing: 4
                        
                        StyledText {
                            text: "Font Size: " + SettingsData.desktopTerminalFontSize + "px"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceTextMedium
                        }
                        
                        Slider {
                            width: parent.width
                            from: 8
                            to: 20
                            stepSize: 1
                            value: SettingsData.desktopTerminalFontSize
                            onValueChanged: {
                                SettingsData.setDesktopTerminalFontSize(value)
                            }
                        }
                    }
                }
                
                // Position dropdown
                Column {
                    width: parent.width
                    spacing: Theme.spacingXS
                    visible: SettingsData.desktopTerminalEnabled
                    
                    StyledText {
                        text: "Position"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceTextMedium
                    }
                    
                    ComboBox {
                        width: 200
                        model: ["top-left", "top-center", "top-right", "middle-left", "middle-center", "middle-right", "bottom-left", "bottom-center", "bottom-right"]
                        currentIndex: {
                            const positions = ["top-left", "top-center", "top-right", "middle-left", "middle-center", "middle-right", "bottom-left", "bottom-center", "bottom-right"]
                            return positions.indexOf(SettingsData.desktopTerminalPosition)
                        }
                        onActivated: {
                            SettingsData.setDesktopTerminalPosition(model[index])
                        }
                    }
                }
                
                // Opacity slider
                Column {
                    width: parent.width
                    spacing: Theme.spacingXS
                    visible: SettingsData.desktopTerminalEnabled
                    
                    StyledText {
                        text: "Opacity: " + Math.round(SettingsData.desktopTerminalOpacity * 100) + "%"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceTextMedium
                    }
                    
                    Slider {
                        width: parent.width
                        from: 0.1
                        to: 1.0
                        stepSize: 0.1
                        value: SettingsData.desktopTerminalOpacity
                        onValueChanged: {
                            SettingsData.setDesktopTerminalOpacity(value)
                        }
                    }
                }
            }

            // Desktop Weather Widget
            Column {
                width: parent.width
                spacing: Theme.spacingS

                StyledText {
                    text: "Desktop Weather Widget"
                    font.pixelSize: Theme.fontSizeLarge
                    color: Theme.surfaceText
                    font.weight: Font.Medium
                }

                StyledText {
                    text: "Shows current weather conditions, forecast, and detailed weather information on the desktop"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceTextMedium
                    wrapMode: Text.WordWrap
                    width: parent.width
                }

                Row {
                    width: parent.width
                    spacing: Theme.spacingM
                    
                    // Position dropdown
                    Column {
                        spacing: Theme.spacingXS
                        
                        StyledText {
                            text: "Position"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceTextMedium
                        }
                        
                        ComboBox {
                            width: 120
                            model: ["top-left", "top-center", "top-right", "center-left", "center", "center-right", "bottom-left", "bottom-center", "bottom-right"]
                            currentIndex: {
                                const positions = ["top-left", "top-center", "top-right", "center-left", "center", "center-right", "bottom-left", "bottom-center", "bottom-right"]
                                return positions.indexOf(SettingsData.desktopWeatherPosition)
                            }
                            onActivated: {
                                SettingsData.setDesktopWeatherPosition(model[index])
                            }
                        }
                    }
                    
                    // Toggle switch
                    Column {
                        spacing: Theme.spacingXS
                        
                        StyledText {
                            text: "Enabled"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceTextMedium
                        }
                        
                        DankToggle {
                            checked: SettingsData.desktopWeatherEnabled
                            onToggled: {
                                SettingsData.setDesktopWeatherEnabled(checked)
                            }
                        }
                    }
                }
                
                // Opacity slider
                Column {
                    width: parent.width
                    spacing: Theme.spacingXS
                    visible: SettingsData.desktopWeatherEnabled
                    
                    StyledText {
                        text: "Opacity: " + Math.round(SettingsData.desktopWeatherOpacity * 100) + "%"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceTextMedium
                    }
                    
                    Slider {
                        width: parent.width
                        from: 0.1
                        to: 1.0
                        stepSize: 0.1
                        value: SettingsData.desktopWeatherOpacity
                        onValueChanged: {
                            SettingsData.setDesktopWeatherOpacity(value)
                        }
                    }
                }
            }
        }

        // Usage Instructions
        Column {
            width: parent.width
            spacing: Theme.spacingS
            visible: SettingsData.desktopWidgetsEnabled

            StyledText {
                text: "Usage Instructions"
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.surfaceText
                font.weight: Font.Medium
            }

            StyledText {
                text: "• Widgets are draggable - click and drag to move them around\n• Widgets automatically update their data in real-time\n• Right-click or middle-click to interact with widgets\n• Widgets respect your theme colors and settings"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceTextMedium
                wrapMode: Text.WordWrap
                width: parent.width
            }
        }
    }
}

