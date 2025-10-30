import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Widgets
// Services singletons (e.g., AppSearchService) are globally available; no module import needed

Item {
    id: root

    // Reusable Process for querying current defaults
    property var queryCallback: null
    Process {
        id: queryProcess
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                if (root.queryCallback)
                    root.queryCallback(text)
                root.queryCallback = null
            }
        }
    }

    // Query current default handler for a MIME/scheme
    function queryDefault(mime, cb) {
        root.queryCallback = function(out) {
            var id = (out || "").trim()
            cb(id)
        }
        queryProcess.command = ["xdg-mime", "query", "default", mime]
        queryProcess.running = true
    }

    // Set default handler via gio (preferred)
    function setDefault(mime, desktopId) {
        Quickshell.execDetached(["gio", "mime", mime, desktopId])
    }

    // Application list sourced from DesktopEntries when available (reactive binding)
    readonly property var allApps: (
        (typeof DesktopEntries !== "undefined" && DesktopEntries.applications)
            ? (function(){
                  var raw = DesktopEntries.applications
                  var list = Array.isArray(raw) ? raw : (raw && raw.values ? raw.values : [])
                  return list.filter(function(app){ return !(app && (app.noDisplay || app.runInTerminal)) })
              })()
            : []
    )

    function appsByCategory(cat) {
        return allApps.filter(a => (a.categories || []).includes(cat))
    }

    function appsByMime(mime) {
        return allApps.filter(a => (a.mimeTypes || []).includes(mime))
    }

    function uniqueApps(list) {
        const seen = new Set()
        const out = []
        for (const a of list) {
            const id = a.id || a.desktopId || a.filename || a.appId || a.name
            if (!seen.has(id)) { seen.add(id); out.push(a) }
        }
        return out
    }

    function displayName(app) {
        if (!app)
            return "Unknown"
        return app.name || app.displayName || app.genericName || app.comment || app.title || app.id || app.filename || "Unknown"
    }

    // Data model describing defaults we manage
    readonly property var defaultsModel: [
        { key: "browser",    title: "Web Browser",      icon: "web",
          mimes: ["x-scheme-handler/http", "x-scheme-handler/https"],
          candidates: () => uniqueApps(appsByCategory("WebBrowser")) },
        { key: "mailer",     title: "Mail Client",      icon: "mail",
          mimes: ["x-scheme-handler/mailto"],
          candidates: () => uniqueApps(appsByCategory("Email")) },
        { key: "pdf",        title: "PDF Viewer",       icon: "picture_as_pdf",
          mimes: ["application/pdf"],
          candidates: () => uniqueApps(appsByMime("application/pdf").concat(appsByCategory("Office"))) },
        { key: "images",     title: "Image Viewer",     icon: "photo",
          mimes: ["image/jpeg", "image/png"],
          candidates: () => uniqueApps(appsByCategory("Graphics").concat(appsByCategory("Photography"))) },
        { key: "video",      title: "Video Player",     icon: "movie",
          mimes: ["video/mp4", "video/x-matroska"],
          candidates: () => uniqueApps(appsByCategory("Video").concat(appsByCategory("AudioVideo"))) },
        { key: "text",       title: "Text Editor",      icon: "edit",
          mimes: ["text/plain"],
          candidates: () => uniqueApps(appsByCategory("TextEditor").concat(appsByCategory("Development"))) },
        { key: "files",      title: "File Manager",     icon: "folder",
          mimes: ["inode/directory"],
          candidates: () => uniqueApps(appsByCategory("FileManager").concat(appsByCategory("Utilities"))) }
    ]

    // UI
    DankFlickable {
        anchors.fill: parent
        anchors.topMargin: Theme.spacingL
        clip: true
        contentHeight: contentCol.height
        contentWidth: width

        Column {
            id: contentCol
            width: parent.width
            spacing: Theme.spacingXL

            Repeater {
                model: root.defaultsModel

                StyledRect {
                    required property var modelData
                    width: parent.width
                    height: innerCol.implicitHeight + Theme.spacingL * 2
                    radius: Theme.cornerRadius
                    color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                    border.width: 1

                    Column {
                        id: innerCol
                        anchors.fill: parent
                        anchors.margins: Theme.spacingL
                        spacing: Theme.spacingM

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            DankIcon {
                                name: modelData.icon
                                size: Theme.iconSize
                                color: Theme.primary
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            StyledText {
                                text: modelData.title
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Normal
                                color: Theme.surfaceText
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        StyledText {
                            width: parent.width
                            text: "Choose the default application. Changes apply immediately."
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            wrapMode: Text.WordWrap
                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            // Prefer apps that explicitly declare the mime(s); fallback to category candidates or all apps
                            property var candidates: (function(){
                                var apps = allApps || []
                                var byMime = []
                                for (var mi = 0; mi < (modelData.mimes || []).length; mi++) {
                                    var m = modelData.mimes[mi]
                                    for (var ai = 0; ai < apps.length; ai++) {
                                        var a = apps[ai]
                                        if ((a.mimeTypes || []).indexOf(m) !== -1) byMime.push(a)
                                    }
                                }
                                if (byMime.length > 0) return uniqueApps(byMime)
                                if (modelData.candidates) return modelData.candidates() || []
                                return apps
                            })()
                            property string currentDesktopId: ""
                            property var optionNames: (candidates || []).map(a => displayName(a))
                            property var optionIcons: (candidates || []).map(a => a.icon || "application-x-executable")
                            property var nameToDesktopId: (function() {
                                const m = {}
                                for (var i = 0; i < (candidates || []).length; i++) {
                                    var a = candidates[i]
                                    var id = a.id || a.desktopId || a.filename || a.appId || ((a.name || "Unknown") + ".desktop")
                                    var name = displayName(a)
                                    m[name] = id
                                }
                                return m
                            })()
                            property string currentName: {
                                for (var i = 0; i < (candidates || []).length; i++) {
                                    var a = candidates[i]
                                    var id = a.id || a.desktopId || a.filename || a.appId || ((a.name || "Unknown") + ".desktop")
                                    if (id === currentDesktopId)
                                        return displayName(a)
                                }
                                return ""
                            }
                            property string currentIcon: {
                                for (var i = 0; i < (candidates || []).length; i++) {
                                    var a = candidates[i]
                                    var id = a.id || a.desktopId || a.filename || a.appId || ((a.name || "Unknown") + ".desktop")
                                    if (id === currentDesktopId)
                                        return a.icon || "application-x-executable"
                                }
                                return "application-x-executable"
                            }

                            Component.onCompleted: {
                                // pick first mime to read current default
                                var mime = modelData.mimes[0]
                                root.queryDefault(mime, function(id) {
                                    currentDesktopId = id
                                })
                            }

                            DankDropdown {
                                id: dropdown
                                width: Math.min(parent.width, 200)
                                text: "Select application"
                                description: ""
                                options: parent.optionNames || []
                                optionIcons: parent.optionIcons || []
                                currentValue: "" // suppress inline label; show icon+name to the right
                                onValueChanged: (value) => {
                                    var desktopId = parent.nameToDesktopId[value] || ""
                                    if (!desktopId) return
                                    for (const mime of modelData.mimes) {
                                        root.setDefault(mime, desktopId)
                                    }
                                    parent.currentDesktopId = desktopId
                                }
                            }

                            Row {
                                spacing: Theme.spacingS
                                anchors.verticalCenter: dropdown.verticalCenter

                                Image {
                                    width: 24
                                    height: 24
                                    source: "image://icon/" + parent.parent.currentIcon
                                    sourceSize.width: 24
                                    sourceSize.height: 24
                                    fillMode: Image.PreserveAspectFit
                                }

                                StyledText {
                                    text: parent.parent.currentName || ""
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.family: SettingsData.defaultFontFamily
                                    font.weight: Font.Normal
                                    color: Theme.surfaceText
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}


