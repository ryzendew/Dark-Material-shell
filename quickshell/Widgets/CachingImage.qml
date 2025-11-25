import QtQuick
import Quickshell.Io
import qs.Common

Image {
    id: root

    property string imagePath: ""
    property string imageHash: ""
    property int maxCacheSize: 512
    readonly property string cachePath: imageHash ? `${Paths.stringify(Paths.imagecache)}/${imageHash}@${maxCacheSize}x${maxCacheSize}.png` : ""

    asynchronous: true
    fillMode: Image.PreserveAspectCrop
    sourceSize.width: maxCacheSize
    sourceSize.height: maxCacheSize
    smooth: true
    onImagePathChanged: {
        if (!imagePath) {
            source = ""
            imageHash = ""
            return
        }
        // Reset hash first to trigger cache path recalculation
        imageHash = ""
        hashProcess.command = ["sha256sum", Paths.strip(imagePath)]
        hashProcess.running = true
    }
    onCachePathChanged: {
        if (!imageHash || !cachePath)
            return

        Paths.mkdir(Paths.imagecache)
        // Try to load from cache first, but if it doesn't exist, fallback will handle it
        // cachePath is already a URL string from Paths.stringify()
        source = cachePath
        console.log("CachingImage: Attempting to load from cache:", cachePath)
    }
    onStatusChanged: {
        if (source == cachePath && status === Image.Error) {
            // Cache file doesn't exist or failed to load, try original path
            // QML Image accepts both plain paths and URLs - use path as-is
            console.log("CachingImage: Cache miss or error, loading from original:", imagePath, "status:", status)
            source = imagePath
            return
        }
        // If loading from original path fails and it's a WebP, log a helpful message
        var sourceStr = source ? source.toString() : ""
        var imagePathStr = imagePath ? imagePath.toString() : ""
        var strippedImagePath = Paths.strip(imagePath)
        var sourceStripped = Paths.strip(sourceStr)
        if (sourceStr && imagePathStr && (sourceStripped === strippedImagePath || sourceStr === imagePathStr) && status === Image.Error && imagePath.toLowerCase().endsWith('.webp')) {
            console.warn("CachingImage: WebP image failed to load. Path:", imagePath)
            console.warn("CachingImage: Source was:", sourceStr)
            console.warn("CachingImage: Check qt6-qtimageformats plugin is installed and Quickshell can access it")
        }
        // Only cache when loading from original path and it's ready
        // Check if source matches the original imagePath (using stripped paths for comparison)
        var sourceMatches = sourceStr && imagePathStr && (sourceStripped === strippedImagePath || sourceStr === imagePathStr)
        if (!sourceMatches || status !== Image.Ready || !imageHash || !cachePath) {
            if (status === Image.Ready && sourceMatches) {
                console.log("CachingImage: Image loaded, ready to cache. Source:", sourceStr, "Path:", imagePath)
            }
            return
        }

        // Image loaded successfully from original path, now cache it
        Paths.mkdir(Paths.imagecache)
        const grabPath = cachePath
        if (visible && width > 0 && height > 0 && Window.window && Window.window.visible) {
            grabToImage(res => {
                if (res) {
                    res.saveToFile(grabPath)
                    console.log("CachingImage: Cached image to:", grabPath)
                }
            })
        }
    }

    Process {
        id: hashProcess

        stdout: StdioCollector {
            onStreamFinished: root.imageHash = text.split(" ")[0]
        }
    }
}
