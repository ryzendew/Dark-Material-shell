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

                property string source: {
                    if (SessionData.perMonitorWallpaper) {
                        return SessionData.monitorWallpapers[modelData.name] || SessionData.wallpaperPath || ""
                    }
                    return SessionData.wallpaperPath || ""
                }
                property bool isColorSource: source.startsWith("#")
                property string transitionType: SessionData.wallpaperTransition
                onTransitionTypeChanged: {
                    currentWallpaper.visible = (transitionType === "none")
                }
                property real transitionProgress: 0
                property real fillMode: {
                    switch (SessionData.wallpaperFillMode) {
                    case "center": return 0.0
                    case "crop": return 1.0
                    case "fit": return 2.0
                    case "stretch": return 3.0
                    case "tile": return 4.0
                    default: return 1.0
                    }
                }
                property int imageFillMode: {
                    switch (SessionData.wallpaperFillMode) {
                    case "center": return Image.Pad
                    case "crop": return Image.PreserveAspectCrop
                    case "fit": return Image.PreserveAspectFit
                    case "stretch": return Image.Stretch
                    case "tile": return Image.Tile
                    default: return Image.PreserveAspectCrop
                    }
                }
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
                            root.applyWallpaperToAwww()
                        }
                    }
                    function onWallpaperPathChanged() {
                        Qt.callLater(() => {
                            if (root.useAwww && root.source && root.source !== "") {
                                root.applyWallpaperToAwww()
                            } else {
                                root.applyWallpaperOnStartup()
                            }
                        })
                    }
                    function onMonitorWallpapersChanged() {
                        Qt.callLater(() => {
                            if (root.useAwww && root.source && root.source !== "") {
                                root.applyWallpaperToAwww()
                            } else {
                                root.applyWallpaperOnStartup()
                            }
                        })
                    }
                    function onPerMonitorWallpaperChanged() {
                        Qt.callLater(() => {
                            if (root.useAwww && root.source && root.source !== "") {
                                root.applyWallpaperToAwww()
                            } else {
                                root.applyWallpaperOnStartup()
                            }
                        })
                    }
                }

                Connections {
                    target: AwwwService
                    function onDaemonRunningChanged() {
                        if (AwwwService.daemonRunning && root.useAwww && root.source && root.source !== "") {
                            Qt.callLater(() => {
                                root.applyWallpaperToAwww()
                            })
                        }
                    }
                }

                function applyWallpaperOnStartup() {
                    var currentSource = SessionData.getMonitorWallpaper(modelData.name) || ""
                    if (currentSource && currentSource !== "") {
                        if (useAwww) {
                            if (AwwwService.daemonRunning) {
                                applyWallpaperToAwww()
                            } else {
                                AwwwService.startDaemon()
                                var retryTimer = Qt.createQmlObject(`
                                    import QtQuick
                                    Timer {
                                        property int attempts: 0
                                        interval: 500
                                        repeat: true
                                        running: true
                                        onTriggered: {
                                            attempts++
                                            if (AwwwService.daemonRunning || attempts >= 10) {
                                                if (AwwwService.daemonRunning) {
                                                    root.applyWallpaperToAwww()
                                                }
                                                stop()
                                                destroy()
                                            }
                                        }
                                    }
                                `, root)
                            }
                        } else {
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
                    }
                }

                Component.onCompleted: {
                    Qt.callLater(() => {
                        Qt.callLater(() => {
                            var currentSource = root.source
                            if (currentSource && currentSource !== "") {
                                if (root.useAwww) {
                                    if (AwwwService.daemonRunning) {
                                        root.applyWallpaperToAwww()
                                    } else {
                                        AwwwService.startDaemon()
                                        var applyTimer = Qt.createQmlObject(`
                                            import QtQuick
                                            Timer {
                                                property int attempts: 0
                                                interval: 500
                                                repeat: true
                                                running: true
                                                onTriggered: {
                                                    attempts++
                                                    if (AwwwService.daemonRunning || attempts >= 10) {
                                                        if (AwwwService.daemonRunning) {
                                                            root.applyWallpaperToAwww()
                                                        }
                                                        stop()
                                                        destroy()
                                                    }
                                                }
                                            }
                                        `, root)
                                    }
                                } else {
                                    root.applyWallpaperOnStartup()
                                }
                            }
                        })
                    })
                }

                Component.onDestruction: {
                    weProc.stop()
                }

                function applyWallpaperToAwww() {
                    const isWebP = source && source.toLowerCase().endsWith('.webp')
                    const shouldUseAwww = useAwww || (isWebP && AwwwService.awwwAvailable)
                    
                    if (!shouldUseAwww) {
                        return
                    }
                    
                    const screenName = SessionData.perMonitorWallpaper ? modelData.name : ""
                    
                    const isWE = source.startsWith("we:")
                    const isColor = source.startsWith("#")
                    
                    if (isWE) {
                        AwwwService.clearWallpaper(screenName)
                    } else if (isColor) {
                        AwwwService.setWallpaperColor(screenName, source)
                    } else if (source && source !== "") {
                        AwwwService.setWallpaper(screenName, source)
                    } else {
                        AwwwService.clearWallpaper(screenName)
                    }
                }

                onSourceChanged: {
                    const isWE = source.startsWith("we:")
                    const isColor = source.startsWith("#")
                    const isWebP = source.toLowerCase().endsWith('.webp')
                    
                    const shouldUseAwww = useAwww || (isWebP && AwwwService.awwwAvailable)
                    
                    if (shouldUseAwww) {
                        if (AwwwService.daemonRunning) {
                            root.applyWallpaperToAwww()
                        } else {
                            AwwwService.startDaemon()
                            Qt.callLater(() => {
                                var retryTimer = Qt.createQmlObject(`
                                    import QtQuick
                                    Timer {
                                        property int attempts: 0
                                        interval: 500
                                        repeat: true
                                        running: true
                                        onTriggered: {
                                            attempts++
                                            if (AwwwService.daemonRunning || attempts >= 10) {
                                                if (AwwwService.daemonRunning) {
                                                    root.applyWallpaperToAwww()
                                                }
                                                stop()
                                                destroy()
                                            }
                                        }
                                    }
                                `, root)
                            })
                        }
                        return
                    }

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

                    if (!currentWallpaper.source) {
                        setWallpaperImmediate(newPath)
                        return
                    }

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
                    anchors.fill: SessionData.wallpaperFillMode === "center" ? undefined : parent
                    anchors.centerIn: SessionData.wallpaperFillMode === "center" ? parent : undefined
                    width: {
                        if (SessionData.wallpaperFillMode !== "center") return undefined
                        var imgWidth = status === Image.Ready ? implicitWidth : 0
                        var imgHeight = status === Image.Ready ? implicitHeight : 0
                        if (imgWidth > 0 && imgHeight > 0 && (imgWidth > modelData.width || imgHeight > modelData.height)) {
                            var scale = Math.min(modelData.width / imgWidth, modelData.height / imgHeight)
                            return imgWidth * scale
                        }
                        return imgWidth > 0 ? imgWidth : undefined
                    }
                    height: {
                        if (SessionData.wallpaperFillMode !== "center") return undefined
                        var imgWidth = status === Image.Ready ? implicitWidth : 0
                        var imgHeight = status === Image.Ready ? implicitHeight : 0
                        if (imgWidth > 0 && imgHeight > 0 && (imgWidth > modelData.width || imgHeight > modelData.height)) {
                            var scale = Math.min(modelData.width / imgWidth, modelData.height / imgHeight)
                            return imgHeight * scale
                        }
                        return imgHeight > 0 ? imgHeight : undefined
                    }
                    visible: root.transitionType === "none" && !root.useAwww && status === Image.Ready
                    opacity: 1
                    layer.enabled: false
                    asynchronous: true
                    smooth: true
                    cache: true
                    fillMode: SessionData.wallpaperFillMode === "center" ? Image.Pad : root.imageFillMode
                    onStatusChanged: {
                        if (status === Image.Ready && implicitWidth > 0 && implicitHeight > 0) {
                            Qt.callLater(() => {
                                var _ = fillMode
                            })
                        }
                    }
                }

                Image {
                    id: nextWallpaper
                    anchors.fill: SessionData.wallpaperFillMode === "center" ? undefined : parent
                    anchors.centerIn: SessionData.wallpaperFillMode === "center" ? parent : undefined
                    width: {
                        if (SessionData.wallpaperFillMode !== "center") return undefined
                        var imgWidth = sourceSize.width > 0 ? sourceSize.width : (status === Image.Ready ? implicitWidth : 0)
                        var imgHeight = sourceSize.height > 0 ? sourceSize.height : (status === Image.Ready ? implicitHeight : 0)
                        if (imgWidth > 0 && imgHeight > 0 && (imgWidth > modelData.width || imgHeight > modelData.height)) {
                            var scale = Math.min(modelData.width / imgWidth, modelData.height / imgHeight)
                            return imgWidth * scale
                        }
                        return imgWidth > 0 ? imgWidth : undefined
                    }
                    height: {
                        if (SessionData.wallpaperFillMode !== "center") return undefined
                        var imgWidth = sourceSize.width > 0 ? sourceSize.width : (status === Image.Ready ? implicitWidth : 0)
                        var imgHeight = sourceSize.height > 0 ? sourceSize.height : (status === Image.Ready ? implicitHeight : 0)
                        if (imgWidth > 0 && imgHeight > 0 && (imgWidth > modelData.width || imgHeight > modelData.height)) {
                            var scale = Math.min(modelData.width / imgWidth, modelData.height / imgHeight)
                            return imgHeight * scale
                        }
                        return imgHeight > 0 ? imgHeight : undefined
                    }
                    visible: false
                    opacity: 0
                    layer.enabled: false
                    asynchronous: true
                    smooth: true
                    cache: true
                    fillMode: SessionData.wallpaperFillMode === "center" ? Image.Pad : root.imageFillMode

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
                    property real smoothness: root.edgeSmoothness
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
