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

        imageHash = ""
        hashProcess.command = ["sha256sum", Paths.strip(imagePath)]
        hashProcess.running = true
    }
    onCachePathChanged: {
        if (!imageHash || !cachePath)
            return

        Paths.mkdir(Paths.imagecache)


        source = cachePath
    }
    onStatusChanged: {
        if (source == cachePath && status === Image.Error) {



            source = imagePath
            return
        }

        var sourceStr = source ? source.toString() : ""
        var imagePathStr = imagePath ? imagePath.toString() : ""
        var strippedImagePath = Paths.strip(imagePath)
        var sourceStripped = Paths.strip(sourceStr)
        if (sourceStr && imagePathStr && (sourceStripped === strippedImagePath || sourceStr === imagePathStr) && status === Image.Error) {
            const isWebP = imagePath.toLowerCase().endsWith('.webp')
            if (isWebP) {


                source = ""
                return
            }
        }


        var sourceMatches = sourceStr && imagePathStr && (sourceStripped === strippedImagePath || sourceStr === imagePathStr)
        if (!sourceMatches || status !== Image.Ready || !imageHash || !cachePath) {
            if (status === Image.Ready && sourceMatches) {
            }
            return
        }


        Paths.mkdir(Paths.imagecache)
        const grabPath = cachePath
        if (visible && width > 0 && height > 0 && Window.window && Window.window.visible) {
            grabToImage(res => {
                if (res) {
                    res.saveToFile(grabPath)
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
