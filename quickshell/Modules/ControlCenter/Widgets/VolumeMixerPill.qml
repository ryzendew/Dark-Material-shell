import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.ControlCenter.Widgets

CompoundPill {
    id: root

    property bool showInputs: true
    property bool showOutputs: true

    iconName: {
        const outputCount = (ApplicationAudioService.applicationStreams || []).length
        const inputCount = (ApplicationAudioService.applicationInputStreams || []).length
        
        if (outputCount === 0 && inputCount === 0) return "volume_up"
        if (outputCount > 0 && inputCount > 0) return "volume_up"
        if (outputCount > 0) return "volume_up"
        return "mic"
    }

    isActive: {
        const outputCount = (ApplicationAudioService.applicationStreams || []).length
        const inputCount = (ApplicationAudioService.applicationInputStreams || []).length
        return outputCount > 0 || inputCount > 0
    }

    primaryText: {
        const outputCount = (ApplicationAudioService.applicationStreams || []).length
        const inputCount = (ApplicationAudioService.applicationInputStreams || []).length
        
        if (outputCount === 0 && inputCount === 0) return "No Audio Apps"
        if (outputCount > 0 && inputCount > 0) return "Audio Mixer"
        if (outputCount > 0) return "Output Apps"
        return "Input Apps"
    }

    secondaryText: {
        const outputCount = (ApplicationAudioService.applicationStreams || []).length
        const inputCount = (ApplicationAudioService.applicationInputStreams || []).length
        
        if (outputCount === 0 && inputCount === 0) return "No active applications"
        
        let text = ""
        if (outputCount > 0) text += `${outputCount} output`
        if (outputCount > 0 && inputCount > 0) text += ", "
        if (inputCount > 0) text += `${inputCount} input`
        
        return text
    }

    onToggled: {
        // This could open a detailed view or toggle mute for all applications
        // For now, we'll just show the detail view
    }

    onWheelEvent: function (wheelEvent) {
        // Could implement volume adjustment for all applications
        wheelEvent.accepted = true
    }
}
