import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io
import qs.Common
import qs.Widgets
import qs.Modules
import qs.Services

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

                readonly property bool transitioning: transitionAnimation.running || transitionTimer.running

                property bool hasCurrent: currentWallpaper.status === Image.Ready && !!currentWallpaper.source
                property bool booting: !hasCurrent && nextWallpaper.status === Image.Ready
                property bool useAwww: SessionData.useAwwwBackend && AwwwService.awwwAvailable

                WallpaperEngineProc {
                    id: weProc
                    monitor: modelData.name
                }

                Connections {
                    target: SessionData
                    function onUseAwwwBackendChanged() {
                        if (SessionData.useAwwwBackend && AwwwService.awwwAvailable) {
                            // When switching to awww, set current wallpaper
                            applyWallpaperToAwww()
                        }
                    }
                    function onWallpaperPathChanged() {
                        // When wallpaper path changes, ensure it's applied
                        Qt.callLater(() => {
                            applyWallpaperOnStartup()
                        })
                    }
                }

                function applyWallpaperOnStartup() {
                    var currentSource = SessionData.getMonitorWallpaper(modelData.name) || ""
                    if (currentSource && currentSource !== "") {
                        console.log("WallpaperBackground: Applying wallpaper on startup, source:", currentSource)
                        if (useAwww) {
                            // For awww, wait for daemon to be ready
                            if (AwwwService.daemonRunning) {
                                applyWallpaperToAwww()
                            } else {
                                // Wait a bit for daemon to start, retry a few times
                                var retryCount = 0
                                var checkTimer = Qt.createQmlObject(`
                                    import QtQuick
                                    Timer {
                                        property int retryCount: 0
                                        interval: 500
                                        repeat: true
                                        running: true
                                        onTriggered: {
                                            retryCount++
                                            if (AwwwService.daemonRunning || retryCount >= 10) {
                                                applyWallpaperToAwww()
                                                stop()
                                                destroy()
                                            }
                                        }
                                    }
                                `, root)
                            }
                        } else {
                            // For QML Image backend, set immediately
                            const isWE = currentSource.startsWith("we:")
                            const isColor = currentSource.startsWith("#")
                            if (isWE) {
                                setWallpaperImmediate("")
                                weProc.start(currentSource.substring(3))
                            } else if (isColor) {
                                setWallpaperImmediate("")
                            } else {
                                setWallpaperImmediate(currentSource)
                            }
                        }
                    } else {
                        console.log("WallpaperBackground: No wallpaper source on startup")
                    }
                }

                Component.onCompleted: {
                    // Ensure wallpaper is applied on startup
                    // Wait a bit for SessionData to finish loading
                    Qt.callLater(() => {
                        Qt.callLater(() => {
                            applyWallpaperOnStartup()
                        })
                    })
                }

                Component.onDestruction: {
                    weProc.stop()
                }

                function applyWallpaperToAwww() {
                    if (!useAwww) {
                        console.log("WallpaperBackground: Not using awww backend (useAwww:", useAwww, ")")
                        return
                    }
                    
                    // Determine if we should set for specific monitor or all monitors
                    const screenName = SessionData.perMonitorWallpaper ? modelData.name : ""
                    
                    console.log("WallpaperBackground: Applying wallpaper via awww, source:", source, "screen:", screenName || "all", "perMonitor:", SessionData.perMonitorWallpaper)
                    
                    const isWE = source.startsWith("we:")
                    const isColor = source.startsWith("#")
                    
                    if (isWE) {
                        // Wallpaper Engine not supported by awww, fall back to empty
                        console.log("WallpaperBackground: Wallpaper Engine not supported by awww, clearing")
                        AwwwService.clearWallpaper(screenName)
                    } else if (isColor) {
                        console.log("WallpaperBackground: Setting color wallpaper:", source)
                        AwwwService.setWallpaperColor(screenName, source)
                    } else if (source && source !== "") {
                        console.log("WallpaperBackground: Setting image wallpaper:", source)
                        AwwwService.setWallpaper(screenName, source)
                    } else {
                        console.log("WallpaperBackground: Clearing wallpaper (empty source)")
                        AwwwService.clearWallpaper(screenName)
                    }
                }

                onSourceChanged: {
                    console.log("WallpaperBackground: onSourceChanged fired, source:", source, "useAwww:", useAwww)
                    // If using awww backend, handle wallpaper through awww
                    if (useAwww) {
                        applyWallpaperToAwww()
                        return
                    }

                    // Otherwise use QML Image backend
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
                            // QML Image accepts plain paths, no need for file:// prefix
                            if (!currentWallpaper.source) {
                                setWallpaperImmediate(source)
                            } else {
                                changeWallpaper(source)
                            }
                        }
                    }
                }

                function setWallpaperImmediate(newSource) {
                    transitionAnimation.stop()
                    transitionTimer.stop()
                    root.transitionProgress = 0.0
                    currentWallpaper.source = newSource
                    nextWallpaper.source = ""
                }

                function changeWallpaper(newPath, force) {
                    if (!force && newPath === currentWallpaper.source) return
                    if (!newPath || newPath.startsWith("#")) return

                    if (root.transitioning) {
                        transitionAnimation.stop()
                        transitionTimer.stop()
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
                        // Use Timer-based animation for precise FPS control
                        root.transitionProgress = 0.0
                        transitionTimer.interval = Math.max(1, Math.round(1000.0 / root.transitionFps))
                        transitionTimer.start()
                    }
                }


                Loader {
                    anchors.fill: parent
                    active: (!root.source || root.isColorSource) && !root.useAwww
                    asynchronous: true

                    sourceComponent: DarkBackdrop {
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
                    visible: root.transitionType === "none" && !root.useAwww
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
                    visible: root.transitionType === "fade" && (root.hasCurrent || root.booting) && !root.useAwww

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

                    // Add data property to prevent warnings
                    property var data: null

                    fragmentShader: Qt.resolvedUrl("../Shaders/qsb/wp_fade.frag.qsb")
                }

                ShaderEffect {
                    id: wipeShader
                    anchors.fill: parent
                    visible: root.transitionType === "wipe" && (root.hasCurrent || root.booting) && !root.useAwww

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

                    // Add data property to prevent warnings
                    property var data: null

                    fragmentShader: Qt.resolvedUrl("../Shaders/qsb/wp_wipe.frag.qsb")
                }

                ShaderEffect {
                    id: discShader
                    anchors.fill: parent
                    visible: root.transitionType === "disc" && (root.hasCurrent || root.booting) && !root.useAwww

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

                    // Add data property to prevent warnings
                    property var data: null

                    fragmentShader: Qt.resolvedUrl("../Shaders/qsb/wp_disc.frag.qsb")
                }

                ShaderEffect {
                    id: stripesShader
                    anchors.fill: parent
                    visible: root.transitionType === "stripes" && (root.hasCurrent || root.booting) && !root.useAwww

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

                    // Add data property to prevent warnings
                    property var data: null

                    fragmentShader: Qt.resolvedUrl("../Shaders/qsb/wp_stripes.frag.qsb")
                }

                ShaderEffect {
                    id: irisBloomShader
                    anchors.fill: parent
                    visible: root.transitionType === "iris bloom" && (root.hasCurrent || root.booting) && !root.useAwww

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

                    // Add data property to prevent warnings
                    property var data: null

                    fragmentShader: Qt.resolvedUrl("../Shaders/qsb/wp_iris_bloom.frag.qsb")
                }

                ShaderEffect {
                    id: pixelateShader
                    anchors.fill: parent
                    visible: root.transitionType === "pixelate" && (root.hasCurrent || root.booting) && !root.useAwww

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

                    // Add data property to prevent warnings
                    property var data: null

                    fragmentShader: Qt.resolvedUrl("../Shaders/qsb/wp_pixelate.frag.qsb")
                }

                ShaderEffect {
                    id: portalShader
                    anchors.fill: parent
                    visible: root.transitionType === "portal" && (root.hasCurrent || root.booting) && !root.useAwww

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

                    // Add data property to prevent warnings
                    property var data: null

                    fragmentShader: Qt.resolvedUrl("../Shaders/qsb/wp_portal.frag.qsb")
                }

                property int transitionDuration: 1000 // Base duration in ms
                property real transitionFps: SessionData.wallpaperTransitionFps || 60
                property real transitionStep: 1.0 / (transitionDuration / 1000.0 * transitionFps) // Progress per frame

                Timer {
                    id: transitionTimer
                    interval: Math.max(1, Math.round(1000.0 / root.transitionFps)) // ms per frame
                    running: false
                    repeat: true
                    onTriggered: {
                        if (root.transitionProgress >= 1.0) {
                            stop()
                            root.transitionAnimationFinished()
                            return
                        }
                        // Use easing function for smooth animation
                        var t = root.transitionProgress
                        var eased = 0.5 - Math.cos(t * Math.PI) / 2.0 // Smooth ease in/out
                        root.transitionProgress = Math.min(1.0, root.transitionProgress + root.transitionStep)
                    }
                }

                function transitionAnimationFinished() {
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

                NumberAnimation {
                    id: transitionAnimation
                    target: root
                    property: "transitionProgress"
                    from: 0.0
                    to: 1.0
                    duration: root.transitionType === "none" ? 0 : (root.transitionFps > 0 ? root.transitionDuration : 1000)
                    easing.type: Easing.InOutCubic
                    onFinished: {
                        root.transitionAnimationFinished()
                    }
                }

                // Use Timer-based animation when FPS is set and not using default
                Connections {
                    target: SessionData
                    function onWallpaperTransitionFpsChanged() {
                        if (transitionTimer.running) {
                            transitionTimer.interval = Math.max(1, Math.round(1000.0 / root.transitionFps))
                        }
                    }
                }
            }
        }
    }
}
