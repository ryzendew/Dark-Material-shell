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
        const players = availablePlayers
        
        let player = players.find(p => p.isPlaying)
        if (player) {
            return player
        }
        
        player = players.find(p => p.canControl && p.canPlay)
        if (player) {
            return player
        }
        
        player = players.find(p => p.canControl)
        if (player) {
            return player
        }
        
        if (players.length > 0) {
            return players[0]
        }
        
        return null
    }

    onAvailablePlayersChanged: {
        for (let i = 0; i < availablePlayers.length; i++) {
            const player = availablePlayers[i]
        }
    }
    
    
    Timer {
        id: playerRefreshTimer
        interval: 2000  // Check every 2 seconds
        running: true
        repeat: true
        onTriggered: {
            const currentCount = Mpris.players.values.length
            const cachedCount = root.availablePlayers.length
            
            if (currentCount !== cachedCount) {
                Qt.callLater(() => {
                    const newCount = root.availablePlayers.length
                    if (newCount > 0 && root.activePlayer) {
                    }
                })
            }
        }
    }
    
    Timer {
        id: initialRefreshTimer
        interval: 5000  // Wait 5 seconds after startup
        running: true
        repeat: false
        onTriggered: {
            Qt.callLater(() => {
            })
        }
    }

    IpcHandler {
        target: "mpris"

        function list(): string {
            const players = root.availablePlayers.map(p => p.identity).join("\n")
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
            return JSON.stringify(info, null, 2)
        }
        
        function refresh(): void {
            const _ = root.availablePlayers
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
