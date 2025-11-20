pragma Singleton

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

Singleton {
    id: root

    readonly property list<MprisPlayer> availablePlayers: Mpris.players.values

    property MprisPlayer activePlayer: {
        // Try multiple strategies to find the best active player
        const players = availablePlayers
        
        // Strategy 1: Currently playing
        let player = players.find(p => p.isPlaying)
        if (player) {
            console.log("[MprisController] Active player (playing):", player.identity)
            return player
        }
        
        // Strategy 2: Can control and can play (most capable)
        player = players.find(p => p.canControl && p.canPlay)
        if (player) {
            console.log("[MprisController] Active player (capable):", player.identity)
            return player
        }
        
        // Strategy 3: Any player that can control
        player = players.find(p => p.canControl)
        if (player) {
            console.log("[MprisController] Active player (can control):", player.identity)
            return player
        }
        
        // Strategy 4: First available player (fallback)
        if (players.length > 0) {
            console.log("[MprisController] Active player (first available):", players[0].identity)
            return players[0]
        }
        
        return null
    }

    // Debug logging for player detection
    onAvailablePlayersChanged: {
        console.log("[MprisController] Available players changed:", availablePlayers.length)
        for (let i = 0; i < availablePlayers.length; i++) {
            const player = availablePlayers[i]
            console.log(`  [${i}] Identity: ${player.identity || "unknown"}, Playing: ${player.isPlaying}, CanControl: ${player.canControl}, CanPlay: ${player.canPlay}`)
        }
        console.log("[MprisController] Active player:", activePlayer ? activePlayer.identity : "none")
    }
    
    // Monitor Mpris.players directly for changes
    Connections {
        target: Mpris
        function onPlayersChanged() {
            console.log("[MprisController] Mpris.players changed, current count:", Mpris.players.values.length)
            // Force property update
            Qt.callLater(() => {
                console.log("[MprisController] After callLater - availablePlayers:", root.availablePlayers.length)
            })
        }
    }
    
    // Periodic refresh to catch players that register late (like Cider)
    Timer {
        id: playerRefreshTimer
        interval: 2000  // Check every 2 seconds
        running: true
        repeat: true
        onTriggered: {
            const currentCount = Mpris.players.values.length
            const cachedCount = root.availablePlayers.length
            
            // If counts don't match, force update
            if (currentCount !== cachedCount) {
                console.log("[MprisController] Timer detected mismatch - current:", currentCount, "cached:", cachedCount)
                // Force property re-evaluation
                Qt.callLater(() => {
                    const newCount = root.availablePlayers.length
                    console.log("[MprisController] After timer refresh - availablePlayers:", newCount)
                    if (newCount > 0 && root.activePlayer) {
                        console.log("[MprisController] Active player found:", root.activePlayer.identity)
                    }
                })
            }
        }
    }
    
    // Initial delay to catch players that start after Quickshell
    Timer {
        id: initialRefreshTimer
        interval: 5000  // Wait 5 seconds after startup
        running: true
        repeat: false
        onTriggered: {
            console.log("[MprisController] Initial refresh after startup - players:", Mpris.players.values.length)
            Qt.callLater(() => {
                console.log("[MprisController] After initial refresh - availablePlayers:", root.availablePlayers.length)
            })
        }
    }

    IpcHandler {
        target: "mpris"

        function list(): string {
            const players = root.availablePlayers.map(p => p.identity).join("\n")
            console.log("[MprisController] IPC list() called, returning:", players || "no players")
            return players
        }
        
        function debug(): string {
            const rawPlayers = Mpris.players.values || []
            const info = {
                rawMprisPlayersCount: rawPlayers.length,
                availablePlayersCount: root.availablePlayers.length,
                rawPlayers: rawPlayers.map(p => ({
                    identity: p.identity || "unknown",
                    isPlaying: p.isPlaying,
                    canControl: p.canControl,
                    canPlay: p.canPlay,
                    playbackState: p.playbackState,
                    trackTitle: p.trackTitle || "none"
                })),
                availablePlayers: root.availablePlayers.map(p => ({
                    identity: p.identity || "unknown",
                    isPlaying: p.isPlaying,
                    canControl: p.canControl,
                    canPlay: p.canPlay,
                    playbackState: p.playbackState,
                    trackTitle: p.trackTitle || "none"
                })),
                activePlayer: root.activePlayer ? root.activePlayer.identity : "none"
            }
            console.log("[MprisController] Debug info:", JSON.stringify(info, null, 2))
            return JSON.stringify(info, null, 2)
        }
        
        function refresh(): void {
            console.log("[MprisController] Manual refresh requested")
            console.log("[MprisController] Mpris.players.values count:", Mpris.players.values.length)
            // Force a re-evaluation by accessing the property
            const _ = root.availablePlayers
            console.log("[MprisController] After refresh - availablePlayers:", root.availablePlayers.length)
        }

        function play(): void {
            if (root.activePlayer && root.activePlayer.canPlay) {
                root.activePlayer.play()
            }
        }

        function pause(): void {
            if (root.activePlayer && root.activePlayer.canPause) {
                root.activePlayer.pause()
            }
        }

        function playPause(): void {
            if (root.activePlayer && root.activePlayer.canTogglePlaying) {
                root.activePlayer.togglePlaying()
            }
        }

        function previous(): void {
            if (root.activePlayer && root.activePlayer.canGoPrevious) {
                root.activePlayer.previous()
            }
        }

        function next(): void {
            if (root.activePlayer && root.activePlayer.canGoNext) {
                root.activePlayer.next()
            }
        }

        function stop(): void {
            if (root.activePlayer) {
                root.activePlayer.stop()
            }
        }
    }
}
