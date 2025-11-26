import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: aboutTab

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
                height: hardwareSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g,
                               Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 1

                Column {
                    id: hardwareSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingXL

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DarkIcon {
                            name: "memory"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Hardware Information"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    StyledRect {
                        width: parent.width
                        height: processorSection.implicitHeight + Theme.spacingM * 2
                        radius: Theme.cornerRadius
                        color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g,
                                       Theme.surfaceContainer.b, 0.5)
                        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                              Theme.outline.b, 0.1)
                        border.width: 1

                        Column {
                            id: processorSection

                            anchors.fill: parent
                            anchors.margins: Theme.spacingM
                            spacing: Theme.spacingM

                            Row {
                                width: parent.width
                                spacing: Theme.spacingM

                                DarkIcon {
                                    name: "memory"
                                    size: Theme.iconSize - 4
                                    color: Theme.primary
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                StyledText {
                                    text: "Processor"
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Grid {
                                width: parent.width
                                columns: 2
                                columnSpacing: Theme.spacingL
                                rowSpacing: Theme.spacingM

                                StyledText {
                                    text: "Model:"
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                }

                                Column {
                                    spacing: 2
                                    width: parent.width - parent.children[0].width - Theme.spacingL

                                    StyledText {
                                        text: HardwareService.cpuModel || "Loading..."
                                        font.pixelSize: Theme.fontSizeMedium
                                        color: Theme.surfaceVariantText
                                        width: parent.width
                                        elide: Text.ElideRight
                                    }
                                }

                                StyledText {
                                    text: "Cores:"
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                    visible: HardwareService.cpuCores > 0
                                }

                                StyledText {
                                    text: HardwareService.cpuCores > 0 ? HardwareService.cpuCores + " cores" : ""
                                    font.pixelSize: Theme.fontSizeMedium
                                    color: Theme.surfaceVariantText
                                    visible: HardwareService.cpuCores > 0
                                }

                                StyledText {
                                    text: "Threads:"
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                    visible: HardwareService.cpuThreads > 0
                                }

                                StyledText {
                                    text: HardwareService.cpuThreads > 0 ? HardwareService.cpuThreads + " threads" : ""
                                    font.pixelSize: Theme.fontSizeMedium
                                    color: Theme.surfaceVariantText
                                    visible: HardwareService.cpuThreads > 0
                                }

                                StyledText {
                                    text: "Frequency:"
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                    visible: HardwareService.cpuFrequency && HardwareService.cpuFrequency.length > 0
                                }

                                StyledText {
                                    text: HardwareService.cpuFrequency || ""
                                    font.pixelSize: Theme.fontSizeMedium
                                    color: Theme.surfaceVariantText
                                    visible: HardwareService.cpuFrequency && HardwareService.cpuFrequency.length > 0
                                }

                                StyledText {
                                    text: "Architecture:"
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                    visible: HardwareService.cpuArchitecture && HardwareService.cpuArchitecture.length > 0
                                }

                                StyledText {
                                    text: HardwareService.cpuArchitecture || ""
                                    font.pixelSize: Theme.fontSizeMedium
                                    color: Theme.surfaceVariantText
                                    visible: HardwareService.cpuArchitecture && HardwareService.cpuArchitecture.length > 0
                                }
                            }
                        }
                    }

                    StyledRect {
                        width: parent.width
                        height: memorySection.implicitHeight + Theme.spacingM * 2
                        radius: Theme.cornerRadius
                        color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g,
                                       Theme.surfaceContainer.b, 0.5)
                        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                              Theme.outline.b, 0.1)
                        border.width: 1

                        Column {
                            id: memorySection

                            anchors.fill: parent
                            anchors.margins: Theme.spacingM
                            spacing: Theme.spacingM

                            Row {
                                width: parent.width
                                spacing: Theme.spacingM

                                DarkIcon {
                                    name: "memory"
                                    size: Theme.iconSize - 4
                                    color: Theme.primary
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                StyledText {
                                    text: "Memory"
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Grid {
                                width: parent.width
                                columns: 2
                                columnSpacing: Theme.spacingL
                                rowSpacing: Theme.spacingM

                                StyledText {
                                    text: "Total:"
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                }

                                StyledText {
                                    text: HardwareService.totalMemory || "Loading..."
                                    font.pixelSize: Theme.fontSizeMedium
                                    color: Theme.surfaceVariantText
                                }

                                StyledText {
                                    text: "Used:"
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                    visible: HardwareService.usedMemory && HardwareService.usedMemory.length > 0
                                }

                                StyledText {
                                    text: HardwareService.usedMemory || ""
                                    font.pixelSize: Theme.fontSizeMedium
                                    color: Theme.surfaceVariantText
                                    visible: HardwareService.usedMemory && HardwareService.usedMemory.length > 0
                                }

                                StyledText {
                                    text: "Available:"
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                    visible: HardwareService.availableMemory && HardwareService.availableMemory.length > 0
                                }

                                StyledText {
                                    text: HardwareService.availableMemory || ""
                                    font.pixelSize: Theme.fontSizeMedium
                                    color: Theme.surfaceVariantText
                                    visible: HardwareService.availableMemory && HardwareService.availableMemory.length > 0
                                }
                            }
                        }
                    }

                    StyledRect {
                        width: parent.width
                        height: graphicsSection.implicitHeight + Theme.spacingM * 2
                        radius: Theme.cornerRadius
                        color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g,
                                       Theme.surfaceContainer.b, 0.5)
                        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                              Theme.outline.b, 0.1)
                        border.width: 1

                        Column {
                            id: graphicsSection

                            anchors.fill: parent
                            anchors.margins: Theme.spacingM
                            spacing: Theme.spacingM

                            Row {
                                width: parent.width
                                spacing: Theme.spacingM

                                DarkIcon {
                                    name: "videocam"
                                    size: Theme.iconSize - 4
                                    color: Theme.primary
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                StyledText {
                                    text: "Graphics"
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Grid {
                                width: parent.width
                                columns: 2
                                columnSpacing: Theme.spacingL
                                rowSpacing: Theme.spacingM

                                StyledText {
                                    text: "Model:"
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                }

                                Column {
                                    spacing: 2
                                    width: parent.width - parent.children[0].width - Theme.spacingL

                                    StyledText {
                                        text: HardwareService.gpuModel || "Loading..."
                                        font.pixelSize: Theme.fontSizeMedium
                                        color: Theme.surfaceVariantText
                                        width: parent.width
                                        elide: Text.ElideRight
                                    }
                                }

                                StyledText {
                                    text: "Driver:"
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                    visible: HardwareService.gpuDriver && HardwareService.gpuDriver.length > 0
                                }

                                StyledText {
                                    text: HardwareService.gpuDriver || ""
                                    font.pixelSize: Theme.fontSizeMedium
                                    color: Theme.surfaceVariantText
                                    visible: HardwareService.gpuDriver && HardwareService.gpuDriver.length > 0
                                }
                            }
                        }
                    }

                    StyledRect {
                        width: parent.width
                        height: storageSection.implicitHeight + Theme.spacingM * 2
                        radius: Theme.cornerRadius
                        color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g,
                                       Theme.surfaceContainer.b, 0.5)
                        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                              Theme.outline.b, 0.1)
                        border.width: 1

                        Column {
                            id: storageSection

                            anchors.fill: parent
                            anchors.margins: Theme.spacingM
                            spacing: Theme.spacingM

                            Row {
                                width: parent.width
                                spacing: Theme.spacingM

                                DarkIcon {
                                    name: "storage"
                                    size: Theme.iconSize - 4
                                    color: Theme.primary
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                StyledText {
                                    text: "Storage"
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Grid {
                                width: parent.width
                                columns: 2
                                columnSpacing: Theme.spacingL
                                rowSpacing: Theme.spacingM

                                StyledText {
                                    text: "Total:"
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                }

                                StyledText {
                                    text: HardwareService.diskTotal || "Loading..."
                                    font.pixelSize: Theme.fontSizeMedium
                                    color: Theme.surfaceVariantText
                                }

                                StyledText {
                                    text: "Used:"
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                    visible: HardwareService.diskUsed && HardwareService.diskUsed.length > 0
                                }

                                StyledText {
                                    text: HardwareService.diskUsed || ""
                                    font.pixelSize: Theme.fontSizeMedium
                                    color: Theme.surfaceVariantText
                                    visible: HardwareService.diskUsed && HardwareService.diskUsed.length > 0
                                }

                                StyledText {
                                    text: "Available:"
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                    visible: HardwareService.diskAvailable && HardwareService.diskAvailable.length > 0
                                }

                                StyledText {
                                    text: HardwareService.diskAvailable || ""
                                    font.pixelSize: Theme.fontSizeMedium
                                    color: Theme.surfaceVariantText
                                    visible: HardwareService.diskAvailable && HardwareService.diskAvailable.length > 0
                                }

                                StyledText {
                                    text: "Usage:"
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                    visible: HardwareService.diskUsagePercent && HardwareService.diskUsagePercent.length > 0
                                }

                                StyledText {
                                    text: HardwareService.diskUsagePercent || ""
                                    font.pixelSize: Theme.fontSizeMedium
                                    color: Theme.surfaceVariantText
                                    visible: HardwareService.diskUsagePercent && HardwareService.diskUsagePercent.length > 0
                                }
                            }
                        }
                    }

                    StyledRect {
                        width: parent.width
                        height: systemSection.implicitHeight + Theme.spacingM * 2
                        radius: Theme.cornerRadius
                        color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g,
                                       Theme.surfaceContainer.b, 0.5)
                        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                              Theme.outline.b, 0.1)
                        border.width: 1

                        Column {
                            id: systemSection

                            anchors.fill: parent
                            anchors.margins: Theme.spacingM
                            spacing: Theme.spacingM

                            Row {
                                width: parent.width
                                spacing: Theme.spacingM

                                DarkIcon {
                                    name: "computer"
                                    size: Theme.iconSize - 4
                                    color: Theme.primary
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                StyledText {
                                    text: "System"
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Grid {
                                width: parent.width
                                columns: 2
                                columnSpacing: Theme.spacingL
                                rowSpacing: Theme.spacingM

                                StyledText {
                                    text: "OS:"
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                }

                                StyledText {
                                    text: HardwareService.osName || "Loading..."
                                    font.pixelSize: Theme.fontSizeMedium
                                    color: Theme.surfaceVariantText
                                }

                                StyledText {
                                    text: "Kernel:"
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                    visible: HardwareService.kernelVersion && HardwareService.kernelVersion.length > 0
                                }

                                StyledText {
                                    text: HardwareService.kernelVersion || ""
                                    font.pixelSize: Theme.fontSizeMedium
                                    color: Theme.surfaceVariantText
                                    visible: HardwareService.kernelVersion && HardwareService.kernelVersion.length > 0
                                }

                                StyledText {
                                    text: "Hostname:"
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                    visible: HardwareService.hostname && HardwareService.hostname.length > 0
                                }

                                StyledText {
                                    text: HardwareService.hostname || ""
                                    font.pixelSize: Theme.fontSizeMedium
                                    color: Theme.surfaceVariantText
                                    visible: HardwareService.hostname && HardwareService.hostname.length > 0
                                }
                            }
                        }
                    }

                    Component.onCompleted: {
                        HardwareService.refreshAll()
                    }
                }
            }
        }
    }
}
