import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io
import qs.Common
import qs.Widgets
import qs.Modules

LazyLoader {
    active: true

    Variants {
        model: SettingsData.getFilteredScreens("wallpaper")

        PanelWindow {
            id: wallpaperWindow

            required property var modelData

            screen: modelData

            WlrLayershell.layer: WlrLayer.Background
            WlrLayershell.exclusionMode: ExclusionMode.Ignore

            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true

            color: "transparent"

            Item {
                id: root
                anchors.fill: parent

                property string source: SessionData.getMonitorWallpaper(modelData.name) || ""
                property bool isColorSource: source.startsWith("#")
                property string transitionType: SessionData.wallpaperTransition
                onTransitionTypeChanged: {
                    currentWallpaper.visible = (transitionType === "none")
                }
                property real transitionProgress: 0
                property real fillMode: 1.0
                property vector4d fillColor: Qt.vector4d(0, 0, 0, 1)
                property real edgeSmoothness: 0.1

                property real wipeDirection: 0
                property real discCenterX: 0.5
                property real discCenterY: 0.5
                property real stripesCount: 16
                property real stripesAngle: 0

                readonly property bool transitioning: transitionAnimation.running

                property bool hasCurrent: currentWallpaper.status === Image.Ready && !!currentWallpaper.source
                property bool booting: !hasCurrent && nextWallpaper.status === Image.Ready

                WallpaperEngineProc {
                    id: weProc
                    monitor: modelData.name
                }


                Component.onDestruction: {
                    weProc.stop()
                }

                onSourceChanged: {
                    const isWE = source.startsWith("we:")
                    const isColor = source.startsWith("#")

                    if (isWE) {
                        setWallpaperImmediate("")
                        weProc.start(source.substring(3))
                    } else {
                        weProc.stop()
                        if (!source) {
                            setWallpaperImmediate("")
                        } else if (isColor) {
                            setWallpaperImmediate("")
                        } else {
                            // Always set immediately if there's no current wallpaper (startup)
                            if (!currentWallpaper.source) {
                                setWallpaperImmediate(source.startsWith("file://") ? source : "file://" + source)
                            } else {
                                changeWallpaper(source.startsWith("file://") ? source : "file://" + source)
                            }
                        }
                    }
                }

                function setWallpaperImmediate(newSource) {
                    transitionAnimation.stop()
                    root.transitionProgress = 0.0
                    currentWallpaper.source = newSource
                    nextWallpaper.source = ""
                }

                function changeWallpaper(newPath, force) {
                    if (!force && newPath === currentWallpaper.source) return
                    if (!newPath || newPath.startsWith("#")) return

                    if (root.transitioning) {
                        transitionAnimation.stop()
                        root.transitionProgress = 0
                        currentWallpaper.source = nextWallpaper.source
                        nextWallpaper.source = ""
                    }

                    // If no current wallpaper, set immediately to avoid scaling issues
                    if (!currentWallpaper.source) {
                        setWallpaperImmediate(newPath)
                        return
                    }

                    // If transition is "none", set immediately
                    if (root.transitionType === "none") {
                        setWallpaperImmediate(newPath)
                        return
                    }

                    if (root.transitionType === "wipe") {
                        root.wipeDirection = Math.random() * 4
                    } else if (root.transitionType === "disc") {
                        root.discCenterX = Math.random()
                        root.discCenterY = Math.random()
                    } else if (root.transitionType === "stripes") {
                        root.stripesCount = Math.round(Math.random() * 20 + 4)
                        root.stripesAngle = Math.random() * 360
                    }

                    nextWallpaper.source = newPath

                    if (nextWallpaper.status === Image.Ready) {
                        transitionAnimation.start()
                    }
                }


                Loader {
                    anchors.fill: parent
                    active: !root.source || root.isColorSource
                    asynchronous: true

                    sourceComponent: DankBackdrop {
                        screenName: modelData.name
                    }
                }

                Rectangle {
                    id: transparentRect
                    anchors.fill: parent
                    color: "transparent"
                    visible: false
                }

                ShaderEffectSource {
                    id: transparentSource
                    sourceItem: transparentRect
                    hideSource: true
                    live: false
                }

                Image {
                    id: currentWallpaper
                    anchors.fill: parent
                    visible: root.transitionType === "none"
                    opacity: 1
                    layer.enabled: false
                    asynchronous: true
                    smooth: true
                    cache: true
                    fillMode: Image.PreserveAspectCrop
                }

                Image {
                    id: nextWallpaper
                    anchors.fill: parent
                    visible: false
                    opacity: 0
                    layer.enabled: false
                    asynchronous: true
                    smooth: true
                    cache: true
                    fillMode: Image.PreserveAspectCrop

                    onStatusChanged: {
                        if (status !== Image.Ready) return

                        if (root.transitionType === "none") {
                            currentWallpaper.source = source
                            nextWallpaper.source = ""
                            root.transitionProgress = 0.0
                        } else {
                            currentWallpaper.layer.enabled = true
                            layer.enabled = true
                            visible = true
                            if (!root.transitioning) {
                                transitionAnimation.start()
                            }
                        }
                    }
                }

                ShaderEffect {
                    id: fadeShader
                    anchors.fill: parent
                    visible: root.transitionType === "fade" && (root.hasCurrent || root.booting)

                    property variant source1: root.hasCurrent ? currentWallpaper : transparentSource
                    property variant source2: nextWallpaper
                    property real progress: root.transitionProgress
                    property real fillMode: root.fillMode
                    property vector4d fillColor: root.fillColor
                    property real imageWidth1: Math.max(1, root.hasCurrent ? source1.sourceSize.width : modelData.width)
                    property real imageHeight1: Math.max(1, root.hasCurrent ? source1.sourceSize.height : modelData.height)
                    property real imageWidth2: Math.max(1, source2.sourceSize.width)
                    property real imageHeight2: Math.max(1, source2.sourceSize.height)
                    property real screenWidth: modelData.width
                    property real screenHeight: modelData.height

                    fragmentShader: Qt.resolvedUrl("../Shaders/qsb/wp_fade.frag.qsb")
                }

                ShaderEffect {
                    id: wipeShader
                    anchors.fill: parent
                    visible: root.transitionType === "wipe" && (root.hasCurrent || root.booting)

                    property variant source1: root.hasCurrent ? currentWallpaper : transparentSource
                    property variant source2: nextWallpaper
                    property real progress: root.transitionProgress
                    property real smoothness: root.edgeSmoothness
                    property real direction: root.wipeDirection
                    property real fillMode: root.fillMode
                    property vector4d fillColor: root.fillColor
                    property real imageWidth1: Math.max(1, root.hasCurrent ? source1.sourceSize.width : modelData.width)
                    property real imageHeight1: Math.max(1, root.hasCurrent ? source1.sourceSize.height : modelData.height)
                    property real imageWidth2: Math.max(1, source2.sourceSize.width)
                    property real imageHeight2: Math.max(1, source2.sourceSize.height)
                    property real screenWidth: modelData.width
                    property real screenHeight: modelData.height

                    fragmentShader: Qt.resolvedUrl("../Shaders/qsb/wp_wipe.frag.qsb")
                }

                ShaderEffect {
                    id: discShader
                    anchors.fill: parent
                    visible: root.transitionType === "disc" && (root.hasCurrent || root.booting)

                    property variant source1: root.hasCurrent ? currentWallpaper : transparentSource
                    property variant source2: nextWallpaper
                    property real progress: root.transitionProgress
                    property real smoothness: root.edgeSmoothness
                    property real aspectRatio: root.width / root.height
                    property real centerX: root.discCenterX
                    property real centerY: root.discCenterY
                    property real fillMode: root.fillMode
                    property vector4d fillColor: root.fillColor
                    property real imageWidth1: Math.max(1, root.hasCurrent ? source1.sourceSize.width : modelData.width)
                    property real imageHeight1: Math.max(1, root.hasCurrent ? source1.sourceSize.height : modelData.height)
                    property real imageWidth2: Math.max(1, source2.sourceSize.width)
                    property real imageHeight2: Math.max(1, source2.sourceSize.height)
                    property real screenWidth: modelData.width
                    property real screenHeight: modelData.height

                    fragmentShader: Qt.resolvedUrl("../Shaders/qsb/wp_disc.frag.qsb")
                }

                ShaderEffect {
                    id: stripesShader
                    anchors.fill: parent
                    visible: root.transitionType === "stripes" && (root.hasCurrent || root.booting)

                    property variant source1: root.hasCurrent ? currentWallpaper : transparentSource
                    property variant source2: nextWallpaper
                    property real progress: root.transitionProgress
                    property real smoothness: root.edgeSmoothness
                    property real aspectRatio: root.width / root.height
                    property real stripeCount: root.stripesCount
                    property real angle: root.stripesAngle
                    property real fillMode: root.fillMode
                    property vector4d fillColor: root.fillColor
                    property real imageWidth1: Math.max(1, root.hasCurrent ? source1.sourceSize.width : modelData.width)
                    property real imageHeight1: Math.max(1, root.hasCurrent ? source1.sourceSize.height : modelData.height)
                    property real imageWidth2: Math.max(1, source2.sourceSize.width)
                    property real imageHeight2: Math.max(1, source2.sourceSize.height)
                    property real screenWidth: modelData.width
                    property real screenHeight: modelData.height

                    fragmentShader: Qt.resolvedUrl("../Shaders/qsb/wp_stripes.frag.qsb")
                }

                ShaderEffect {
                    id: irisBloomShader
                    anchors.fill: parent
                    visible: root.transitionType === "iris bloom" && (root.hasCurrent || root.booting)

                    property variant source1: root.hasCurrent ? currentWallpaper : transparentSource
                    property variant source2: nextWallpaper
                    property real progress: root.transitionProgress
                    property real smoothness: root.edgeSmoothness
                    property real centerX: 0.5
                    property real centerY: 0.5
                    property real aspectRatio: root.width / root.height
                    property real fillMode: root.fillMode
                    property vector4d fillColor: root.fillColor
                    property real imageWidth1: Math.max(1, root.hasCurrent ? source1.sourceSize.width : modelData.width)
                    property real imageHeight1: Math.max(1, root.hasCurrent ? source1.sourceSize.height : modelData.height)
                    property real imageWidth2: Math.max(1, source2.sourceSize.width)
                    property real imageHeight2: Math.max(1, source2.sourceSize.height)
                    property real screenWidth: modelData.width
                    property real screenHeight: modelData.height

                    fragmentShader: Qt.resolvedUrl("../Shaders/qsb/wp_iris_bloom.frag.qsb")
                }

                ShaderEffect {
                    id: pixelateShader
                    anchors.fill: parent
                    visible: root.transitionType === "pixelate" && (root.hasCurrent || root.booting)

                    property variant source1: root.hasCurrent ? currentWallpaper : transparentSource
                    property variant source2: nextWallpaper
                    property real progress: root.transitionProgress
                    property real smoothness: root.edgeSmoothness   // controls starting block size
                    property real fillMode: root.fillMode
                    property vector4d fillColor: root.fillColor
                    property real imageWidth1: Math.max(1, root.hasCurrent ? source1.sourceSize.width : modelData.width)
                    property real imageHeight1: Math.max(1, root.hasCurrent ? source1.sourceSize.height : modelData.height)
                    property real imageWidth2: Math.max(1, source2.sourceSize.width)
                    property real imageHeight2: Math.max(1, source2.sourceSize.height)
                    property real screenWidth: modelData.width
                    property real screenHeight: modelData.height
                    property real centerX: root.discCenterX
                    property real centerY: root.discCenterY
                    property real aspectRatio: root.width / root.height

                    fragmentShader: Qt.resolvedUrl("../Shaders/qsb/wp_pixelate.frag.qsb")
                }

                ShaderEffect {
                    id: portalShader
                    anchors.fill: parent
                    visible: root.transitionType === "portal" && (root.hasCurrent || root.booting)

                    property variant source1: root.hasCurrent ? currentWallpaper : transparentSource
                    property variant source2: nextWallpaper
                    property real progress: root.transitionProgress
                    property real smoothness: root.edgeSmoothness
                    property real aspectRatio: root.width / root.height
                    property real centerX: root.discCenterX
                    property real centerY: root.discCenterY
                    property real fillMode: root.fillMode
                    property vector4d fillColor: root.fillColor
                    property real imageWidth1: Math.max(1, root.hasCurrent ? source1.sourceSize.width : modelData.width)
                    property real imageHeight1: Math.max(1, root.hasCurrent ? source1.sourceSize.height : modelData.height)
                    property real imageWidth2: Math.max(1, source2.sourceSize.width)
                    property real imageHeight2: Math.max(1, source2.sourceSize.height)
                    property real screenWidth: modelData.width
                    property real screenHeight: modelData.height

                    fragmentShader: Qt.resolvedUrl("../Shaders/qsb/wp_portal.frag.qsb")
                }

                NumberAnimation {
                    id: transitionAnimation
                    target: root
                    property: "transitionProgress"
                    from: 0.0
                    to: 1.0
                    duration: root.transitionType === "none" ? 0 : 1000
                    easing.type: Easing.InOutCubic
                    onFinished: {
                        Qt.callLater(() => {
                            if (nextWallpaper.source && nextWallpaper.status === Image.Ready && !nextWallpaper.source.toString().startsWith("#")) {
                                currentWallpaper.source = nextWallpaper.source
                            }
                            nextWallpaper.source = ""
                            nextWallpaper.visible = false
                            currentWallpaper.visible = root.transitionType === "none"
                            currentWallpaper.layer.enabled = false
                            nextWallpaper.layer.enabled = false
                            root.transitionProgress = 0.0
                        })
                    }
                }
            }
        }
    }
}
