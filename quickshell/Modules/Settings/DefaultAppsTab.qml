import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Widgets
// Services singletons (e.g., AppSearchService) are globally available; no module import needed

Item {
    id: root
    
    FontLoader {
        id: notoSansLoader
        source: "/usr/share/fonts/noto/NotoSans-Regular.ttf"
    }
    
    readonly property string notoSansFamily: notoSansLoader.status === FontLoader.Ready ? notoSansLoader.name : "Noto Sans"

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

    // Set default handler using gio mime (handles mimeapps.list automatically)
    function setDefault(mime, desktopId) {
        // Ensure desktopId has .desktop extension
        var finalId = desktopId
        if (!finalId.endsWith(".desktop")) {
            finalId = finalId + ".desktop"
        }
        
        // Use gio mime which properly updates mimeapps.list
        Quickshell.execDetached(["gio", "mime", mime, finalId])
        
        // Also use xdg-mime as backup
        Quickshell.execDetached(["xdg-mime", "default", finalId, mime])
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
          candidates: () => uniqueApps(appsByCategory("FileManager").concat(appsByCategory("Utilities"))) },
        { key: "terminal",   title: "Terminal Emulator", icon: "terminal",
          mimes: [],
          isTerminal: true,
          candidates: () => [] },
        { key: "aurhelper",  title: "AUR Helper",        icon: "",
          mimes: [],
          isAurHelper: true,
          candidates: () => [] }
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

                            Text {
                                text: modelData.title
                                font.pixelSize: Theme.fontSizeLarge
                                font.family: root.notoSansFamily
                                font.weight: Font.Normal
                                color: Theme.surfaceText
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Text {
                            width: parent.width
                            text: "Choose the default application. Changes apply immediately."
                            font.pixelSize: Theme.fontSizeSmall
                            font.family: root.notoSansFamily
                            color: Theme.surfaceVariantText
                            wrapMode: Text.WordWrap
                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            // Prefer apps that explicitly declare the mime(s); fallback to category candidates or all apps
                            property var candidates: []
                            property string currentDesktopId: ""
                            
                            // Function to initialize candidates
                            function initCandidates() {
                                if (modelData.isTerminal) {
                                    // For terminals, use detected terminals from SettingsData
                                    candidates = SettingsData.availableTerminals.map(function(term) {
                                        return { name: term, id: term, displayName: term }
                                    })
                                } else if (modelData.isAurHelper) {
                                    // For AUR helpers, use detected helpers from SettingsData
                                    candidates = SettingsData.availableAurHelpers.map(function(helper) {
                                        return { name: helper, id: helper, displayName: helper }
                                    })
                                } else {
                                    var apps = allApps || []
                                    var byMime = []
                                    for (var mi = 0; mi < (modelData.mimes || []).length; mi++) {
                                        var m = modelData.mimes[mi]
                                        for (var ai = 0; ai < apps.length; ai++) {
                                            var a = apps[ai]
                                            if ((a.mimeTypes || []).indexOf(m) !== -1) byMime.push(a)
                                        }
                                    }
                                    if (byMime.length > 0) {
                                        candidates = uniqueApps(byMime)
                                    } else if (modelData.candidates) {
                                        candidates = modelData.candidates() || []
                                    } else {
                                        candidates = apps
                                    }
                                }
                            }
                            
                            // Function to ensure current default app is in candidates
                            function ensureCurrentAppInCandidates() {
                                if (modelData.isTerminal || modelData.isAurHelper || !currentDesktopId) return
                                
                                // Check if currentDesktopId is already in candidates
                                var found = false
                                for (var i = 0; i < candidates.length; i++) {
                                    var appId = getAppId(candidates[i])
                                    if (appId === currentDesktopId || normalizeId(appId) === normalizeId(currentDesktopId)) {
                                        found = true
                                        break
                                    }
                                }
                                
                                // If not found, add it from allApps
                                if (!found) {
                                    var normalizedCurrent = normalizeId(currentDesktopId)
                                    var currentWithoutExt = normalizedCurrent
                                    
                                    for (var j = 0; j < allApps.length; j++) {
                                        var app = allApps[j]
                                        var appId = getAppId(app)
                                        var normalizedAppId = normalizeId(appId)
                                        
                                        // Try various matching strategies
                                        var matches = false
                                        
                                        // Exact matches
                                        if (appId === currentDesktopId || normalizedAppId === normalizedCurrent) {
                                            matches = true
                                        }
                                        // Filename matches
                                        else if (app.filename && (app.filename === currentDesktopId || normalizeId(app.filename) === normalizedCurrent)) {
                                            matches = true
                                        }
                                        // Desktop ID matches
                                        else if (app.desktopId && (app.desktopId === currentDesktopId || normalizeId(app.desktopId) === normalizedCurrent)) {
                                            matches = true
                                        }
                                        // ID matches
                                        else if (app.id && (app.id === currentDesktopId || normalizeId(app.id) === normalizedCurrent)) {
                                            matches = true
                                        }
                                        // Extension variations
                                        else if (appId === normalizedCurrent + ".desktop" || normalizedAppId + ".desktop" === currentDesktopId) {
                                            matches = true
                                        }
                                        // Partial matches (name-based)
                                        else if (app.name && normalizeId(app.name) === normalizedCurrent) {
                                            matches = true
                                        }
                                        
                                        if (matches) {
                                            // Create a new array to trigger binding updates
                                            var newCandidates = [app]
                                            for (var k = 0; k < candidates.length; k++) {
                                                newCandidates.push(candidates[k])
                                            }
                                            candidates = newCandidates
                                            break
                                        }
                                    }
                                }
                            }
                            property var optionNames: (candidates || []).map(a => ((modelData.isTerminal || modelData.isAurHelper) ? a.name : displayName(a)))
                            property var optionIcons: (candidates || []).map(a => (modelData.isTerminal ? "terminal" : (modelData.isAurHelper ? "" : (a.icon || "application-x-executable"))))
                            property var nameToDesktopId: {
                                // Force recalculation when candidates changes
                                var _ = candidates.length // Dummy access to make this reactive
                                const m = {}
                                for (var i = 0; i < (candidates || []).length; i++) {
                                    var a = candidates[i]
                                    var id = ((modelData.isTerminal || modelData.isAurHelper) ? a.id : (a.id || a.desktopId || a.filename || a.appId || ((a.name || "Unknown") + ".desktop")))
                                    var name = ((modelData.isTerminal || modelData.isAurHelper) ? a.name : displayName(a))
                                    m[name] = id
                                }
                                return m
                            }
                            // Helper function to normalize desktop IDs for comparison
                            function normalizeId(id) {
                                if (!id) return ""
                                // Remove .desktop extension if present
                                var normalized = id.toString()
                                if (normalized.endsWith(".desktop")) {
                                    normalized = normalized.substring(0, normalized.length - 8)
                                }
                                return normalized.toLowerCase()
                            }
                            
                            // Helper function to get app ID from candidate
                            function getAppId(app) {
                                return app.id || app.desktopId || app.filename || app.appId || ((app.name || "Unknown") + ".desktop")
                            }
                            
                            property string currentName: {
                                if (modelData.isTerminal) {
                                    return SettingsData.terminalEmulator || ""
                                }
                                if (modelData.isAurHelper) {
                                    return SettingsData.aurHelper || ""
                                }
                                if (!currentDesktopId) return ""
                                var normalizedCurrent = normalizeId(currentDesktopId)
                                
                                // Try to match against all candidates
                                for (var i = 0; i < (candidates || []).length; i++) {
                                    var a = candidates[i]
                                    var appId = getAppId(a)
                                    var normalizedAppId = normalizeId(appId)
                                    
                                    // Try exact match first
                                    if (appId === currentDesktopId) {
                                        return displayName(a)
                                    }
                                    
                                    // Try normalized match (most common case)
                                    if (normalizedAppId === normalizedCurrent) {
                                        return displayName(a)
                                    }
                                    
                                    // Try all app properties for matches
                                    var propertiesToCheck = [a.id, a.desktopId, a.filename, a.appId]
                                    for (var p = 0; p < propertiesToCheck.length; p++) {
                                        var prop = propertiesToCheck[p]
                                        if (prop && (prop === currentDesktopId || normalizeId(prop) === normalizedCurrent)) {
                                            return displayName(a)
                                        }
                                        // Also try with/without .desktop
                                        if (prop && (prop + ".desktop" === currentDesktopId || normalizeId(prop) + ".desktop" === currentDesktopId)) {
                                            return displayName(a)
                                        }
                                        if (prop && prop === normalizedCurrent + ".desktop") {
                                            return displayName(a)
                                        }
                                    }
                                    
                                    // Try partial matches on the base name
                                    var currentBase = normalizedCurrent.split('.')[0] // Get base name before first dot
                                    var appBase = normalizedAppId.split('.')[0]
                                    if (currentBase && appBase && currentBase === appBase && currentBase.length > 2) {
                                        return displayName(a)
                                    }
                                }
                                
                                // If no match found, try to extract a readable name from the desktop ID
                                var readableName = currentDesktopId.replace(".desktop", "").split('.').pop() || currentDesktopId.replace(".desktop", "")
                                return readableName || ""
                            }
                            property string currentIcon: {
                                if (modelData.isTerminal) {
                                    return "terminal"
                                }
                                if (modelData.isAurHelper) {
                                    return "" // No icon for AUR helpers
                                }
                                if (!currentDesktopId) return "application-x-executable"
                                var normalizedCurrent = normalizeId(currentDesktopId)
                                for (var i = 0; i < (candidates || []).length; i++) {
                                    var a = candidates[i]
                                    var appId = getAppId(a)
                                    // Try exact match first
                                    if (appId === currentDesktopId) {
                                        return a.icon || "application-x-executable"
                                    }
                                    // Try normalized match
                                    if (normalizeId(appId) === normalizedCurrent) {
                                        return a.icon || "application-x-executable"
                                    }
                                    // Try matching just the filename part
                                    if (appId.includes(normalizedCurrent) || normalizedCurrent.includes(normalizeId(a.name || ""))) {
                                        return a.icon || "application-x-executable"
                                    }
                                }
                                return "application-x-executable"
                            }
                            
                            property string currentDisplayName: {
                                // Return the current name which matches the dropdown option format
                                return currentName
                            }

                            // Function to refresh the current default
                            function refreshDefault() {
                                if (modelData.isTerminal) {
                                    currentDesktopId = SettingsData.terminalEmulator || ""
                                } else if (modelData.isAurHelper) {
                                    currentDesktopId = SettingsData.aurHelper || ""
                                } else {
                                    var mime = modelData.mimes[0]
                                    root.queryDefault(mime, function(id) {
                                        currentDesktopId = id || ""
                                        ensureCurrentAppInCandidates()
                                    })
                                }
                            }

                            Component.onCompleted: {
                                initCandidates()
                                refreshDefault()
                            }

                            DankDropdown {
                                id: dropdown
                                width: Math.min(parent.width, 200)
                                text: "Select application"
                                description: ""
                                options: parent.optionNames || []
                                optionIcons: parent.optionIcons || []
                                // Set currentValue to show selected option in dropdown
                                currentValue: parent.currentDisplayName || ""
                                onValueChanged: (value) => {
                                    var desktopId = parent.nameToDesktopId[value] || ""
                                    if (!desktopId) return
                                    if (modelData.isTerminal) {
                                        // For terminals, update SettingsData directly
                                        SettingsData.terminalEmulator = desktopId
                                        parent.currentDesktopId = desktopId
                                    } else if (modelData.isAurHelper) {
                                        // For AUR helpers, update SettingsData directly
                                        SettingsData.aurHelper = desktopId
                                        parent.currentDesktopId = desktopId
                                    } else {
                                        for (const mime of modelData.mimes) {
                                            root.setDefault(mime, desktopId)
                                        }
                                        parent.currentDesktopId = desktopId
                                        parent.ensureCurrentAppInCandidates()
                                        // Wait a bit for the file to be written, then refresh
                                        Qt.callLater(function() {
                                            // Use setTimeout-like delay via callLater
                                            Qt.callLater(function() {
                                                parent.refreshDefault()
                                            })
                                        })
                                    }
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
                                    visible: parent.parent.currentIcon && parent.parent.currentIcon !== ""
                                }

                                Text {
                                    text: parent.parent.currentName || ""
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.family: root.notoSansFamily
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


