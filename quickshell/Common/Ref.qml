import QtQuick
import Quickshell

QtObject {
    required property Singleton service

    Component.onCompleted: {
        if (service && typeof service.refCount !== 'undefined') {
            service.refCount = service.refCount + 1
        }
    }

    Component.onDestruction: {
        if (service && typeof service.refCount !== 'undefined') {
            service.refCount = service.refCount - 1
        }
    }
}
