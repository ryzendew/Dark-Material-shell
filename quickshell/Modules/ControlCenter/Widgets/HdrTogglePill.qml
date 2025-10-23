import QtQuick
import QtQuick.Controls
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.ControlCenter.Widgets

CompoundPill {
    id: root

    iconName: HdrService.hdrEnabled ? "hdr_on" : "hdr_off"
    isActive: HdrService.hdrEnabled
    primaryText: HdrService.hdrEnabled ? "HDR Enabled" : "HDR Disabled"
    secondaryText: HdrService.isChecking ? "Checking..." : (HdrService.hdrEnabled ? "Click to disable" : "Click to enable")

    onToggled: {
        if (HdrService.isChecking) return
        
        console.log("HDR Toggle clicked - toggling via service")
        HdrService.toggleHdr()
    }
}