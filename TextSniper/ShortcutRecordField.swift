//
//  ShortcutRecordField.swift
//  TextSniper
//
//  Created by yanfei on 2025/11/20.
//

import AppKit

/// 简单的快捷键信息模型
struct Shortcut {
    let keyCode: UInt16
    let modifiers: NSEvent.ModifierFlags
}

/// 负责展示与录制快捷键的文本框
final class ShortcutRecordField: NSTextField {

    /// 当前快捷键信息
    var shortcut: Shortcut? {
        didSet { updateDisplay() }
    }

    /// 默认展示的字符串，如 "⇧⌘2" 或 "Record Shortcut"
    var defaultDisplayString: String? {
        didSet { updateDisplay() }
    }

    /// 当快捷键发生变化或被清空时的回调
    var onShortcutChanged: ((Shortcut?) -> Void)?

    private var isActive = false

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        isBordered = true
        isBezeled = true
        bezelStyle = .roundedBezel
        isEditable = false
        isSelectable = false
        wantsLayer = true
        focusRingType = .none
        alignment = .center
        font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        usesSingleLineMode = true

        placeholderString = "Press Shortcut"
        updateDisplay()
        updateSelectionAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - First Responder & Keyboard

    override var acceptsFirstResponder: Bool { true }

    override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(self)
        updateSelectionAppearance()
        super.mouseDown(with: event)
    }

    override func becomeFirstResponder() -> Bool {
        let ok = super.becomeFirstResponder()
        if ok {
            stringValue = ""
            placeholderString = "Press Shortcut"
            isActive = true
            updateSelectionAppearance()
        }
        return ok
    }

    override func resignFirstResponder() -> Bool {
        let ok = super.resignFirstResponder()
        if ok {
            isActive = false
            updateDisplay()
            updateSelectionAppearance()
        }
        return ok
    }

    override func keyDown(with event: NSEvent) {
        // ESC 退出录制
        if event.keyCode == 53 {
            window?.makeFirstResponder(nil)
            updateDisplay()
            return
        }

        let mods = event.modifierFlags.intersection([.command, .shift, .option, .control])
        guard !mods.isEmpty else {
            NSSound.beep()
            return
        }

        let newShortcut = Shortcut(keyCode: event.keyCode, modifiers: mods)
        shortcut = newShortcut
        onShortcutChanged?(newShortcut)

        window?.makeFirstResponder(nil)
    }

    // MARK: - Exposed Helpers

    func clearShortcut() {
        shortcut = nil
        onShortcutChanged?(nil)
    }

    // MARK: - Private

    private func updateDisplay() {
        if let shortcut = shortcut {
            stringValue = Self.displayString(for: shortcut)
            placeholderString = nil
        } else {
            stringValue = ""
            placeholderString = defaultDisplayString ?? "Record Shortcut"
        }
    }

    private func updateSelectionAppearance() {
        guard let layer = layer else { return }
        layer.cornerRadius = 6
        layer.borderWidth = isActive ? 2 : 1
        layer.borderColor = (isActive ? NSColor.controlAccentColor : NSColor.separatorColor).cgColor
        layer.masksToBounds = true
        layer.backgroundColor = NSColor.textBackgroundColor.cgColor
    }

    private static func displayString(for shortcut: Shortcut) -> String {
        var components: [String] = []

        if shortcut.modifiers.contains(.control) { components.append("⌃") }
        if shortcut.modifiers.contains(.option) { components.append("⌥") }
        if shortcut.modifiers.contains(.shift) { components.append("⇧") }
        if shortcut.modifiers.contains(.command) { components.append("⌘") }

        if let key = keyString(from: shortcut.keyCode) {
            components.append(key)
        } else {
            components.append("?")
        }
        return components.joined()
    }

    private static func keyString(from keyCode: UInt16) -> String? {
        // 常用键位映射，后续有需要可继续扩展
        let mapping: [UInt16: String] = [
            18: "1", 19: "2", 20: "3", 21: "4", 23: "5", 22: "6", 26: "7", 28: "8", 25: "9", 29: "0",
            0: "A", 11: "B", 8: "C", 2: "D", 14: "E", 3: "F", 5: "G", 4: "H", 34: "I", 38: "J", 40: "K", 37: "L",
            46: "M", 45: "N", 31: "O", 35: "P", 12: "Q", 15: "R", 1: "S", 17: "T", 32: "U", 9: "V",
            13: "W", 7: "X", 16: "Y", 6: "Z"
        ]
        return mapping[keyCode]
    }
}
