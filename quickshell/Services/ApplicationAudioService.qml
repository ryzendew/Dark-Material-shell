pragma Singleton

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Singleton {
    id: root
    readonly property int totalNodeCount: (Pipewire.nodes?.values || []).length

    signal applicationVolumeChanged
    signal applicationMuteChanged
    signal streamsChanged

    Component.onCompleted: {
        console.log("[ApplicationAudioService] Service initialized")
        console.log("[ApplicationAudioService] Pipewire ready:", Pipewire.ready)
        if (Pipewire.nodes) {
            console.log("[ApplicationAudioService] Total nodes available:", Pipewire.nodes.values ? Pipewire.nodes.values.length : 0)
        }
        // Log when nodes change to help debug
        if (Pipewire.nodes) {
            Pipewire.nodes.valuesChanged.connect(() => {
                console.log("[ApplicationAudioService] Nodes changed, new count:", Pipewire.nodes.values ? Pipewire.nodes.values.length : 0)
                // Force property recalculation by emitting signal
                streamsChanged()
                console.log("[ApplicationAudioService] Valid streams:", applicationStreams.length, "inputs:", applicationInputStreams.length)
                console.log("[ApplicationAudioService] Valid devices - outputs:", outputDevices.length, "inputs:", inputDevices.length)
            })
        }
    }

    function isValidNode(node) {
        if (!node) return false
        // For streams, we don't require ready state immediately as they might still be initializing
        // But we do need audio object
        if (!node.audio) return false
        // Skip nodes that might have incomplete device information
        // These are the ones causing the card.profile.device errors
        try {
            // For application streams, we're more lenient - just need basic info
            if (node.isStream) {
                // Streams should have a name (even if empty initially)
                // Properties might not be set immediately
                return true
            }
            // For devices, we need ready state and properties
            if (!node.ready) return false
            // Properties check is optional for streams but required for devices
            // Don't check properties === undefined as it might be an empty object
            return true
        } catch (e) {
            console.log("[ApplicationAudioService] Error validating node:", e)
            return false
        }
    }

    function isValidStreamNode(node) {
        if (!node) return false
        // Streams need audio and should be ready/bound to be usable
        if (!node.audio) return false
        // Check if node is ready - unbound nodes will cause errors
        // We can be lenient and show nodes that are initializing, but filter them out when trying to change volume
        try {
            // Basic check - just need to be a stream
            // Note: We'll show unbound nodes but disable controls for them
            return node.isStream !== undefined
        } catch (e) {
            return false
        }
    }
    
    function isNodeReadyForVolumeControl(node) {
        if (!node || !node.audio) return false
        // Node must be ready (bound) to change volume
        // ready === false means unbound, ready === true means bound
        // ready === undefined might mean still initializing
        // For streams, we can be more lenient - if ready is not explicitly false, allow it
        if (node.ready === false) {
            console.log("[ApplicationAudioService] Node not ready for volume control:", node.id || node.name, "ready:", node.ready)
            return false
        }
        // If ready is true or undefined, allow volume control
        // We'll catch errors in the actual volume setting function
        return true
    }

    readonly property var applicationStreams: (Pipewire.nodes?.values || []).filter(node => {
        if (!isValidStreamNode(node)) return false
        try {
            const isStream = node.isStream && node.isSink
            if (isStream) {
                console.log("[ApplicationAudioService] Found output stream:", node.name || node.id, "ready:", node.ready, "hasAudio:", !!node.audio)
            }
            return isStream
        } catch (e) {
            console.log("[ApplicationAudioService] Error checking application stream:", e, node ? (node.name || node.id) : "null")
            return false
        }
    })

    readonly property var applicationInputStreams: (Pipewire.nodes?.values || []).filter(node => {
        if (!isValidStreamNode(node)) return false
        try {
            const isStream = node.isStream && !node.isSink
            if (isStream) {
                console.log("[ApplicationAudioService] Found input stream:", node.name || node.id, "ready:", node.ready, "hasAudio:", !!node.audio)
            }
            return isStream
        } catch (e) {
            console.log("[ApplicationAudioService] Error checking application input stream:", e, node ? (node.name || node.id) : "null")
            return false
        }
    })

    readonly property var outputDevices: (Pipewire.nodes?.values || []).filter(node => {
        if (!isValidNode(node)) return false
        try {
            return !node.isStream && node.isSink
        } catch (e) {
            console.log("[ApplicationAudioService] Error checking output device:", e, node ? node.name : "null")
            return false
        }
    })

    readonly property var inputDevices: (Pipewire.nodes?.values || []).filter(node => {
        if (!isValidNode(node)) return false
        try {
            return !node.isStream && !node.isSink
        } catch (e) {
            console.log("[ApplicationAudioService] Error checking input device:", e, node ? node.name : "null")
            return false
        }
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

    function getApplicationIcon(node) {
        // Alias for getApplicationIconName for compatibility
        return getApplicationIconName(node)
    }

    function isNodeBound(node) {
        return isNodeReadyForVolumeControl(node)
    }

    function setApplicationVolume(node, percentage) {
        if (!node || !node.audio) {
            console.log("[ApplicationAudioService] Cannot set volume - no node or audio")
            return "No audio stream available"
        }
        
        if (node.ready === false) {
            console.log("[ApplicationAudioService] Cannot set volume - node not bound:", node.id || node.name)
            return "Node not ready"
        }

        try {
            const clampedVolume = Math.max(0, Math.min(100, percentage))
            const volumeValue = clampedVolume / 100
            console.log("[ApplicationAudioService] Setting volume for node", node.id || node.name, "to", volumeValue)
            node.audio.volume = volumeValue
            root.applicationVolumeChanged()
            return `Volume set to ${clampedVolume}%`
        } catch (e) {
            console.log("[ApplicationAudioService] Error setting volume:", e, "node:", node.id || node.name, "ready:", node.ready)
            return "Failed to set volume"
        }
    }

    function toggleApplicationMute(node) {
        if (!node || !node.audio) {
            return "No audio stream available"
        }
        
        if (!isNodeBound(node)) {
            console.log("[ApplicationAudioService] Cannot toggle mute - node not bound:", node.id || node.name)
            return "Node not ready"
        }

        try {
            node.audio.muted = !node.audio.muted
            root.applicationMuteChanged()
            return node.audio.muted ? "Application muted" : "Application unmuted"
        } catch (e) {
            console.log("[ApplicationAudioService] Error toggling mute:", e)
            return "Failed to toggle mute"
        }
    }

    function setApplicationInputVolume(node, percentage) {
        if (!node || !node.audio) {
            return "No audio input stream available"
        }
        
        if (!isNodeBound(node)) {
            console.log("[ApplicationAudioService] Cannot set input volume - node not bound:", node.id || node.name)
            return "Node not ready"
        }

        try {
            const clampedVolume = Math.max(0, Math.min(100, percentage))
            node.audio.volume = clampedVolume / 100
            root.applicationVolumeChanged()
            return `Input volume set to ${clampedVolume}%`
        } catch (e) {
            console.log("[ApplicationAudioService] Error setting input volume:", e)
            return "Failed to set input volume"
        }
    }

    function toggleApplicationInputMute(node) {
        if (!node || !node.audio) {
            return "No audio input stream available"
        }
        
        if (!isNodeBound(node)) {
            console.log("[ApplicationAudioService] Cannot toggle input mute - node not bound:", node.id || node.name)
            return "Node not ready"
        }

        try {
            node.audio.muted = !node.audio.muted
            root.applicationMuteChanged()
            return node.audio.muted ? "Application input muted" : "Application input unmuted"
        } catch (e) {
            console.log("[ApplicationAudioService] Error toggling input mute:", e)
            return "Failed to toggle input mute"
        }
    }

    function routeStreamToOutput(streamNode, targetSinkNode) {
        if (!streamNode || !targetSinkNode) {
            console.log("[ApplicationAudioService] Invalid stream or target device")
            return "Invalid stream or target device"
        }
        if (!streamNode.isStream || !streamNode.isSink) {
            console.log("[ApplicationAudioService] Not an output stream")
            return "Not an output stream"
        }
        if (targetSinkNode.isStream || !targetSinkNode.isSink) {
            console.log("[ApplicationAudioService] Not a valid output device")
            return "Not a valid output device"
        }
        
        try {
            const streamId = streamNode.id
            const sinkId = targetSinkNode.id
            
            if (!streamId || !sinkId) {
                console.log("[ApplicationAudioService] Invalid IDs - stream:", streamId, "sink:", sinkId)
                return "Invalid stream or sink ID"
            }
            
            console.log("[ApplicationAudioService] Routing stream", streamId, "to sink", sinkId)
            
            // Use pw-link to create a link between stream and sink
            // Format: pw-link <output_port> <input_port>
            // For streams: pw-link <stream_id>:output_FL <sink_id>:input_FL
            // We'll try the simple format first, then try with port names if needed
            const connectCmd = ["pw-link", streamId.toString(), sinkId.toString()]
            
            // Create process to handle the routing
            const connectProcess = connectProcessComponent.createObject(root, {
                streamId: streamId,
                sinkId: sinkId,
                deviceName: targetSinkNode.description || targetSinkNode.name,
                callback: function() {
                    console.log("[ApplicationAudioService] Stream routed to", targetSinkNode.description || targetSinkNode.name)
                    root.applicationVolumeChanged()
                }
            })
            
            return "Routing stream..."
        } catch (e) {
            console.log("[ApplicationAudioService] Error routing stream:", e)
            return "Failed to route stream: " + e
        }
    }
    
    Component {
        id: connectProcessComponent
        Process {
            property int streamId
            property int sinkId
            property string deviceName
            property var callback
            
            command: ["pw-link", streamId.toString(), sinkId.toString()]
            
            Component.onCompleted: {
                console.log("[ApplicationAudioService] Executing pw-link:", command.join(" "))
                running = true
            }
            
            onExited: function(exitCode) {
                if (exitCode === 0) {
                    console.log("[ApplicationAudioService] Successfully routed stream", streamId, "to sink", sinkId)
                    if (callback) callback()
                } else {
                    console.log("[ApplicationAudioService] pw-link failed with exit code", exitCode)
                    // Try alternative format with port names
                    const altProcess = connectProcessAltComponent.createObject(root, {
                        streamId: streamId,
                        sinkId: sinkId,
                        deviceName: deviceName,
                        callback: callback
                    })
                }
                destroy()
            }
        }
    }
    
    Component {
        id: connectProcessAltComponent
        Process {
            property int streamId
            property int sinkId
            property string deviceName
            property var callback
            
            // Try with explicit port names
            command: ["pw-link", streamId.toString() + ":output_FL", sinkId.toString() + ":input_FL"]
            
            Component.onCompleted: {
                console.log("[ApplicationAudioService] Trying alternative pw-link format:", command.join(" "))
                running = true
            }
            
            onExited: function(exitCode) {
                if (exitCode === 0 && callback) {
                    console.log("[ApplicationAudioService] Successfully routed stream using alternative format")
                    callback()
                } else {
                    console.log("[ApplicationAudioService] Alternative routing also failed")
                }
                destroy()
            }
        }
    }

    function routeStreamToInput(streamNode, targetSourceNode) {
        if (!streamNode || !targetSourceNode) {
            console.log("[ApplicationAudioService] Invalid stream or target device")
            return "Invalid stream or target device"
        }
        if (!streamNode.isStream || streamNode.isSink) {
            console.log("[ApplicationAudioService] Not an input stream")
            return "Not an input stream"
        }
        if (targetSourceNode.isStream || targetSourceNode.isSink) {
            console.log("[ApplicationAudioService] Not a valid input device")
            return "Not a valid input device"
        }
        
        try {
            const streamId = streamNode.id
            const sourceId = targetSourceNode.id
            
            if (!streamId || !sourceId) {
                console.log("[ApplicationAudioService] Invalid IDs - stream:", streamId, "source:", sourceId)
                return "Invalid stream or source ID"
            }
            
            console.log("[ApplicationAudioService] Routing input stream", streamId, "to source", sourceId)
            
            // Use pw-link to create a link between source and stream
            // Format: pw-link <output_port> <input_port>
            // For input: pw-link <source_id>:output_FL <stream_id>:input_FL
            const connectCmd = ["pw-link", sourceId.toString(), streamId.toString()]
            
            const connectProcess = connectInputProcessComponent.createObject(root, {
                streamId: streamId,
                sourceId: sourceId,
                deviceName: targetSourceNode.description || targetSourceNode.name,
                callback: function() {
                    console.log("[ApplicationAudioService] Input stream routed to", targetSourceNode.description || targetSourceNode.name)
                    root.applicationVolumeChanged()
                }
            })
            
            return "Routing input stream..."
        } catch (e) {
            console.log("[ApplicationAudioService] Error routing input stream:", e)
            return "Failed to route stream: " + e
        }
    }
    
    Component {
        id: connectInputProcessComponent
        Process {
            property int streamId
            property int sourceId
            property string deviceName
            property var callback
            
            command: ["pw-link", sourceId.toString(), streamId.toString()]
            
            Component.onCompleted: {
                console.log("[ApplicationAudioService] Executing pw-link for input:", command.join(" "))
                running = true
            }
            
            onExited: function(exitCode) {
                if (exitCode === 0) {
                    console.log("[ApplicationAudioService] Successfully routed input stream", streamId, "to source", sourceId)
                    if (callback) callback()
                } else {
                    console.log("[ApplicationAudioService] pw-link for input failed with exit code", exitCode)
                    // Try alternative format
                    const altProcess = connectInputProcessAltComponent.createObject(root, {
                        streamId: streamId,
                        sourceId: sourceId,
                        deviceName: deviceName,
                        callback: callback
                    })
                }
                destroy()
            }
        }
    }
    
    Component {
        id: connectInputProcessAltComponent
        Process {
            property int streamId
            property int sourceId
            property string deviceName
            property var callback
            
            command: ["pw-link", sourceId.toString() + ":output_FL", streamId.toString() + ":input_FL"]
            
            Component.onCompleted: {
                console.log("[ApplicationAudioService] Trying alternative pw-link format for input:", command.join(" "))
                running = true
            }
            
            onExited: function(exitCode) {
                if (exitCode === 0 && callback) {
                    console.log("[ApplicationAudioService] Successfully routed input stream using alternative format")
                    callback()
                } else {
                    console.log("[ApplicationAudioService] Alternative input routing also failed")
                }
                destroy()
            }
        }
    }

    function getCurrentOutputDevice(streamNode) {
        if (!streamNode || !streamNode.isStream || !streamNode.isSink) {
            return null
        }
        // Try to find which sink this stream is connected to
        // This might be available through streamNode.targetSink or similar
        // For now, return the default sink as a fallback
        return AudioService.sink
    }

    function getCurrentInputDevice(streamNode) {
        if (!streamNode || !streamNode.isStream || streamNode.isSink) {
            return null
        }
        // Similar to output
        return AudioService.source
    }

    // Filter out problematic nodes before tracking to avoid card.profile.device errors
    function getTrackableNodes() {
        if (!Pipewire.nodes?.values) return []
        const nodes = []
        for (let i = 0; i < Pipewire.nodes.values.length; i++) {
            const node = Pipewire.nodes.values[i]
            if (!node) continue
            // Only track nodes that are ready and have audio
            // This helps avoid errors with nodes that have incomplete device information
            if (node.ready && node.audio) {
                try {
                    // Additional check - ensure node has basic properties
                    if (node.properties !== undefined && node.name !== undefined) {
                        nodes.push(node)
                    }
                } catch (e) {
                    // Skip nodes that throw errors when accessing properties
                    console.log("[ApplicationAudioService] Skipping problematic node:", node.id || "unknown")
                }
            }
        }
        return nodes
    }

    PwObjectTracker { 
        objects: root.getTrackableNodes()
        Component.onCompleted: {
            console.log("[ApplicationAudioService] Tracking", objects.length, "nodes out of", (Pipewire.nodes?.values || []).length, "total")
        }
    }

    function debugAllNodes() {
        if (!Pipewire.ready || !Pipewire.nodes?.values) {
            console.log("[ApplicationAudioService] Pipewire not ready or no nodes")
            return
        }
        
        console.log("[ApplicationAudioService] ========== Debug All Nodes ==========")
        console.log("[ApplicationAudioService] Total nodes:", Pipewire.nodes.values.length)
        console.log("[ApplicationAudioService] Application streams:", applicationStreams.length)
        console.log("[ApplicationAudioService] Application input streams:", applicationInputStreams.length)
        console.log("[ApplicationAudioService] Output devices:", outputDevices.length)
        console.log("[ApplicationAudioService] Input devices:", inputDevices.length)
        
        for (let i = 0; i < Pipewire.nodes.values.length; i++) {
            const node = Pipewire.nodes.values[i]
            if (!node) {
                console.log("[ApplicationAudioService] Node", i, "is null")
                continue
            }
            
            try {
                console.log("[ApplicationAudioService] Node", i, ":", {
                    id: node.id,
                    name: node.name || "unnamed",
                    ready: node.ready,
                    hasAudio: !!node.audio,
                    isStream: node.isStream,
                    isSink: node.isSink,
                    hasProperties: node.properties !== undefined,
                    propertiesCount: node.properties ? Object.keys(node.properties).length : 0
                })
            } catch (e) {
                console.log("[ApplicationAudioService] Error accessing node", i, ":", e)
            }
        }
        console.log("[ApplicationAudioService] ======================================")
    }
}
