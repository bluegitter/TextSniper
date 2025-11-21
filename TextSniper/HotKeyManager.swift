//
//  HotKeyManager.swift
//  TextSniper
//
//  Created by yanfei on 2025/11/20.
//

import AppKit
import Carbon
import Foundation

final class HotKeyManager {
    static let shared = HotKeyManager()

    private struct RegisteredHotKey {
        let carbonID: UInt32
        let ref: EventHotKeyRef?
        let handler: () -> Void
    }

    private var hotKeys: [String: RegisteredHotKey] = [:]
    private var idLookup: [UInt32: String] = [:]
    private var nextID: UInt32 = 1
    private var eventHandler: EventHandlerRef?

    private init() {}

    func registerCaptureHotKey(handler: @escaping () -> Void) {
        let shortcut = Shortcut(keyCode: UInt16(kVK_ANSI_2), modifiers: [.command, .shift])
        register(id: "截取文字", shortcut: shortcut, handler: handler)
    }

    func register(id: String, shortcut: Shortcut, handler: @escaping () -> Void) {
        unregister(id: id)
        installEventHandlerIfNeeded()

        let carbonID = nextID
        nextID &+= 1

        var hotKeyRef: EventHotKeyRef?
        var hotKeyID = EventHotKeyID(signature: Self.signature, id: carbonID)
        let status = RegisterEventHotKey(
            UInt32(shortcut.keyCode),
            shortcut.modifiers.carbonFlags,
            hotKeyID,
            GetEventDispatcherTarget(),
            0,
            &hotKeyRef
        )

        if status == noErr {
            let registered = RegisteredHotKey(carbonID: carbonID, ref: hotKeyRef, handler: handler)
            hotKeys[id] = registered
            idLookup[carbonID] = id
        } else {
            print("[HotKeyManager] Failed to register hot key \(id): \(status)")
        }
    }

    func unregister(id: String) {
        guard let existing = hotKeys[id] else { return }
        if let ref = existing.ref {
            UnregisterEventHotKey(ref)
        }
        hotKeys[id] = nil
        idLookup[existing.carbonID] = nil
    }

    deinit {
        unregisterAll()
        if let eventHandler {
            RemoveEventHandler(eventHandler)
        }
    }

    private func unregisterAll() {
        for (_, entry) in hotKeys {
            if let ref = entry.ref {
                UnregisterEventHotKey(ref)
            }
        }
        hotKeys.removeAll()
        idLookup.removeAll()
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
        if hotKeyID.signature == HotKeyManager.signature,
           let id = manager.idLookup[hotKeyID.id],
           let entry = manager.hotKeys[id] {
            entry.handler()
        }
        return noErr
    }
}

private extension NSEvent.ModifierFlags {
    var carbonFlags: UInt32 {
        var carbon: UInt32 = 0
        if contains(.command) { carbon |= UInt32(cmdKey) }
        if contains(.shift) { carbon |= UInt32(shiftKey) }
        if contains(.option) { carbon |= UInt32(optionKey) }
        if contains(.control) { carbon |= UInt32(controlKey) }
        return carbon
    }
}
