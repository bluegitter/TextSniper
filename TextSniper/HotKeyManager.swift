//
//  HotKeyManager.swift
//  TextSniper
//
//  Created by yanfei on 2025/11/20.
//

import Carbon
import Foundation

final class HotKeyManager {
    static let shared = HotKeyManager()

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    private var handler: (() -> Void)?

    private init() {}

    func registerCaptureHotKey(handler: @escaping () -> Void) {
        register(keyCode: UInt32(kVK_ANSI_2), modifiers: UInt32(cmdKey | shiftKey), handler: handler)
    }

    private func register(keyCode: UInt32, modifiers: UInt32, handler: @escaping () -> Void) {
        unregisterExisting()
        installEventHandlerIfNeeded()

        var hotKeyID = EventHotKeyID(signature: Self.signature, id: 1)
        let status = RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetEventDispatcherTarget(), 0, &hotKeyRef)

        if status == noErr {
            self.handler = handler
        } else {
            print("[HotKeyManager] Failed to register hot key: \(status)")
        }
    }

    private func unregisterExisting() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
    }

    deinit {
        unregisterExisting()
        if let eventHandler {
            RemoveEventHandler(eventHandler)
        }
    }

    private func installEventHandlerIfNeeded() {
        guard eventHandler == nil else { return }

        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventHotKeyPressed))

        let status = InstallEventHandler(
            GetEventDispatcherTarget(),
            HotKeyManager.hotKeyCallback,
            1,
            &eventType,
            UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),
            &eventHandler
        )

        if status != noErr {
            print("[HotKeyManager] Failed to install event handler: \(status)")
        }
    }

    private static let signature: OSType = 0x5453484B // 'TSHK'

    private static let hotKeyCallback: EventHandlerUPP = { _, event, userData in
        guard
            let event,
            let userData
        else { return noErr }

        var hotKeyID = EventHotKeyID()
        let status = GetEventParameter(
            event,
            EventParamName(kEventParamDirectObject),
            EventParamType(typeEventHotKeyID),
            nil,
            MemoryLayout<EventHotKeyID>.size,
            nil,
            &hotKeyID
        )

        guard status == noErr else { return noErr }

        let manager = Unmanaged<HotKeyManager>.fromOpaque(userData).takeUnretainedValue()
        if hotKeyID.signature == HotKeyManager.signature {
            manager.handler?()
        }
        return noErr
    }
}
