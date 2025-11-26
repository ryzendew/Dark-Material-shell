import Quickshell
pragma Singleton

Singleton {
    id: root

    function clearImageCache() {
        const cachePath = Paths.stringify(Paths.imagecache)
        Quickshell.execDetached(["rm", "-rf", cachePath])
        Paths.mkdir(Paths.imagecache)
    }

    function clearOldCache(ageInMinutes) {
        const cachePath = Paths.stringify(Paths.imagecache)
        Quickshell.execDetached(["find", cachePath, "-name", "*.png", "-mmin", `+${ageInMinutes}`, "-delete"])
    }

    function clearCacheForSize(size) {
        const cachePath = Paths.stringify(Paths.imagecache)
        const pattern = `*@${size}x${size}.png`
        Quickshell.execDetached(["find", cachePath, "-name", pattern, "-delete"])
    }

    function getCacheSize(callback) {
        const cachePath = Paths.stringify(Paths.imagecache)
        const processCode = `
            import Quickshell.Io
            Process {
                command: ["du", "-sm", "${cachePath}"]
                running: true
                stdout: StdioCollector {
                    onStreamFinished: {
                        const parts = text.split("\\t")
                        const sizeMB = parseInt(parts[0]) || 0
                        callback(sizeMB)
                    }
                }
            }
        `
        Qt.createQmlObject(processCode, root)
    }
}
