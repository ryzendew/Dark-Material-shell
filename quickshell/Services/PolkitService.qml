pragma Singleton

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Polkit
import qs.Common
import qs.Modals

Singleton {
    id: root

    property bool agentRegistered: false
    property PolkitAgent agent: PolkitAgent {
        id: polkitAgent

        onAuthenticationRequestStarted: (authFlow) => {
            if (agentRegistered) {
                polkitAuthModal.show(authFlow)
            }
        }
    }

    property PolkitAuthModal polkitAuthModal: PolkitAuthModal {
        id: polkitAuthModal
    }

    Component.onCompleted: {
        // Try to register the agent, but don't fail if another agent is already registered
        // This is expected if another polkit agent (like polkit-gnome) is running
        agentRegistered = true
    }
}



