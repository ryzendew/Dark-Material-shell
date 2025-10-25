pragma Singleton

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    signal applicationVolumeChanged
    signal applicationMuteChanged

    // Get all application audio output streams
    readonly property var applicationStreams: {
        if (!Pipewire.ready || !Pipewire.nodes?.values) {
            // console.log("ApplicationAudioService: Pipewire not ready or no nodes")
            return []
        }

        const streams = Pipewire.nodes.values.filter(node => {
            if (!node || !node.ready || !node.audio) {
                return false
            }
            
            // Try different approaches to detect application streams
            // Check if it's a stream (not a device) and has application properties
            const hasAppName = node.properties && node.properties["application.name"]
            const isStream = node.isStream
            const isSink = node.isSink
            
            // Also check for media class properties
            const mediaClass = node.properties && node.properties["media.class"]
            const isAudioStream = mediaClass && (mediaClass.includes("Audio") || mediaClass.includes("Stream"))
            
            const isOutputStream = isStream && isSink && (hasAppName || isAudioStream)
            
            if (isOutputStream) {
                // console.log("ApplicationAudioService: Found output stream:", node.name, "app:", node.properties["application.name"], "media:", mediaClass)
            }
            return isOutputStream
        })
        
        // console.log("ApplicationAudioService: Found", streams.length, "output streams")
        return streams
    }

    // Get all application audio input streams
    readonly property var applicationInputStreams: {
        if (!Pipewire.ready || !Pipewire.nodes?.values) {
            // console.log("ApplicationAudioService: Pipewire not ready or no nodes")
            return []
        }

        const streams = Pipewire.nodes.values.filter(node => {
            if (!node || !node.ready || !node.audio) {
                return false
            }
            
            // Try different approaches to detect application input streams
            const hasAppName = node.properties && node.properties["application.name"]
            const isStream = node.isStream
            const isSink = node.isSink
            
            // Also check for media class properties
            const mediaClass = node.properties && node.properties["media.class"]
            const isAudioStream = mediaClass && (mediaClass.includes("Audio") || mediaClass.includes("Stream"))
            
            const isInputStream = isStream && !isSink && (hasAppName || isAudioStream)
            
            if (isInputStream) {
                // console.log("ApplicationAudioService: Found input stream:", node.name, "app:", node.properties["application.name"], "media:", mediaClass)
            }
            return isInputStream
        })
        
        // console.log("ApplicationAudioService: Found", streams.length, "input streams")
        return streams
    }

    function getApplicationName(node) {
        if (!node || !node.properties) {
            return "Unknown Application"
        }

        // Try to get application name from properties
        const appName = node.properties["application.name"]
        if (appName && appName !== "") {
            return appName
        }

        // Try to get from media name
        const mediaName = node.properties["media.name"]
        if (mediaName && mediaName !== "") {
            return mediaName
        }

        // Fallback to node name
        if (node.name && node.name !== "") {
            return node.name
        }

        return "Unknown Application"
    }

    function getApplicationIcon(node) {
        if (!node || !node.properties) {
            return "apps"
        }

        const appName = (node.properties["application.name"] || "").toLowerCase()
        
        // Common application icons
        if (appName.includes("firefox") || appName.includes("mozilla")) return "firefox"
        if (appName.includes("chrome") || appName.includes("chromium")) return "chrome"
        if (appName.includes("discord")) return "discord"
        if (appName.includes("spotify")) return "spotify"
        if (appName.includes("vlc")) return "vlc"
        if (appName.includes("obs")) return "obs"
        if (appName.includes("steam")) return "steam"
        if (appName.includes("telegram")) return "telegram"
        if (appName.includes("signal")) return "signal"
        if (appName.includes("whatsapp")) return "whatsapp"
        if (appName.includes("zoom")) return "zoom"
        if (appName.includes("teams")) return "teams"
        if (appName.includes("skype")) return "skype"
        if (appName.includes("slack")) return "slack"
        if (appName.includes("code") || appName.includes("vscode")) return "code"
        if (appName.includes("terminal") || appName.includes("gnome-terminal")) return "terminal"
        if (appName.includes("gedit")) return "text-editor"
        if (appName.includes("libreoffice")) return "libreoffice"
        if (appName.includes("gimp")) return "gimp"
        if (appName.includes("inkscape")) return "inkscape"
        if (appName.includes("blender")) return "blender"
        if (appName.includes("audacity")) return "audacity"
        if (appName.includes("pavucontrol")) return "pavucontrol"
        if (appName.includes("pulseaudio")) return "pulseaudio"
        
        return "apps"
    }

    function setApplicationVolume(node, percentage) {
        if (!node || !node.audio) {
            return "No audio stream available"
        }

        const clampedVolume = Math.max(0, Math.min(100, percentage))
        node.audio.volume = clampedVolume / 100
        root.applicationVolumeChanged()
        return `Volume set to ${clampedVolume}%`
    }

    function toggleApplicationMute(node) {
        if (!node || !node.audio) {
            return "No audio stream available"
        }

        node.audio.muted = !node.audio.muted
        root.applicationMuteChanged()
        return node.audio.muted ? "Application muted" : "Application unmuted"
    }

    function setApplicationInputVolume(node, percentage) {
        if (!node || !node.audio) {
            return "No audio input stream available"
        }

        const clampedVolume = Math.max(0, Math.min(100, percentage))
        node.audio.volume = clampedVolume / 100
        root.applicationVolumeChanged()
        return `Input volume set to ${clampedVolume}%`
    }

    function toggleApplicationInputMute(node) {
        if (!node || !node.audio) {
            return "No audio input stream available"
        }

        node.audio.muted = !node.audio.muted
        root.applicationMuteChanged()
        return node.audio.muted ? "Application input muted" : "Application input unmuted"
    }

    // Track changes to application streams
    PwObjectTracker {
        objects: root.applicationStreams.concat(root.applicationInputStreams)
    }

    // Debug function to log all available nodes
    function debugAllNodes() {
        if (!Pipewire.ready || !Pipewire.nodes?.values) {
            // console.log("ApplicationAudioService: Pipewire not ready for debugging")
            return
        }
        
        // console.log("ApplicationAudioService: Debugging all nodes...")
        // console.log("Total nodes:", Pipewire.nodes.values.length)
        
        for (let i = 0; i < Pipewire.nodes.values.length; i++) {
            const node = Pipewire.nodes.values[i]
            if (!node) continue
            
            // console.log("Node", i, ":", {
            //     name: node.name,
            //     ready: node.ready,
            //     hasAudio: !!node.audio,
            //     isSink: node.isSink,
            //     isStream: node.isStream,
            //     type: node.type,
            //     properties: node.properties
            // })
        }
    }
}
