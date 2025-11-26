pragma Singleton

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root
    readonly property int totalNodeCount: (Pipewire.nodes?.values || []).length

    signal applicationVolumeChanged
    signal applicationMuteChanged

    readonly property var applicationStreams: (Pipewire.nodes?.values || []).filter(node => {
        if (!node || !node.ready || !node.audio) return false
        return node.isStream && node.isSink
    })

    readonly property var applicationInputStreams: (Pipewire.nodes?.values || []).filter(node => {
        if (!node || !node.ready || !node.audio) return false
        return node.isStream && !node.isSink
    })

    readonly property var outputDevices: (Pipewire.nodes?.values || []).filter(node => {
        if (!node || !node.ready || !node.audio) return false
        return !node.isStream && node.isSink
    })

    readonly property var inputDevices: (Pipewire.nodes?.values || []).filter(node => {
        if (!node || !node.ready || !node.audio) return false
        return !node.isStream && !node.isSink
    })

    function getApplicationName(node) {
        if (!node) return "Unknown Application"
        const props = node.properties || {}
        const base = props["application.name"] || (node.description && node.description !== "" ? node.description : node.name)
        const media = props["media.name"]
        return media !== undefined && media !== "" ? `${base} - ${media}` : base || "Unknown Application"
    }

    function getApplicationIconName(node) {
        if (!node) return ""
        const props = node.properties || {}
        let preferred = props["application.icon-name"] || props["node.name"] || props["application.name"] || ""
        const blacklist = [
            "speech-dispatcher-dummy",
        ]
        if (blacklist.indexOf(preferred) !== -1) return ""
        return preferred
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

    PwObjectTracker { objects: Pipewire.nodes?.values || [] }

    function debugAllNodes() {
        if (!Pipewire.ready || !Pipewire.nodes?.values) {
            return
        }
        
        
        for (let i = 0; i < Pipewire.nodes.values.length; i++) {
            const node = Pipewire.nodes.values[i]
            if (!node) continue
            
        }
    }
}
