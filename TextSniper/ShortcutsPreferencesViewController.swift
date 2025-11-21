//
//  ShortcutsPreferencesViewController.swift
//  TextSniper
//
//  Created by yanfei on 2025/11/20.
//

import AppKit

final class ShortcutsPreferencesViewController: NSViewController {
    struct ShortcutRow {
        let title: String
        let defaultKey: String?
    }

    private let appState: AppState
    private let hotKeyManager: HotKeyManager
    private var shortcuts: [String: Shortcut?] = [:]
    private let defaultShortcuts: [String: Shortcut] = [
        "截取文字": Shortcut(keyCode: 19, modifiers: [.command, .shift]),
        "保留换行": Shortcut(keyCode: 37, modifiers: [.command]),
        "追加剪贴板": Shortcut(keyCode: 4, modifiers: [.command]),
        "文字转语音": Shortcut(keyCode: 1, modifiers: [.command])
    ]

    private lazy var actions: [String: () -> Void] = {
        [
            "截取文字": { [weak self] in self?.appState.captureText() },
            "截取上一次区域": { [weak self] in self?.appState.showComingSoon(title: "截取上一次区域") },
            "截取时移除换行": { [weak self] in self?.appState.captureText(preserveLineBreaksOverride: false) },
            "截取时保留换行": { [weak self] in self?.appState.captureText(preserveLineBreaksOverride: true) },
            "截取并朗读": { [weak self] in
                self?.appState.textToSpeechEnabled = true
                self?.appState.captureText()
            },
            "识别二维码/条码": { [weak self] in self?.appState.captureCode() },
            "停止朗读": { [weak self] in self?.appState.stopSpeaking() },
            "切换追加剪贴板": { [weak self] in self?.appState.additiveClipboard.toggle() },
            "清空追加剪贴板历史": { [weak self] in self?.appState.clearAdditiveClipboardHistory() },
            // Capture mode toggles
            "保留换行": { [weak self] in self?.appState.keepLineBreaks = true },
            "追加剪贴板": { [weak self] in self?.appState.additiveClipboard.toggle() },
            "文字转语音": { [weak self] in self?.appState.textToSpeechEnabled.toggle() }
        ]
    }()

    private let globalRows: [ShortcutRow] = [
        .init(title: "截取文字", defaultKey: "⇧⌘2"),
        .init(title: "截取上一次区域", defaultKey: nil),
        .init(title: "截取时移除换行", defaultKey: nil),
        .init(title: "截取时保留换行", defaultKey: nil),
        .init(title: "截取并朗读", defaultKey: nil),
        .init(title: "识别二维码/条码", defaultKey: nil),
        .init(title: "停止朗读", defaultKey: nil),
        .init(title: "切换追加剪贴板", defaultKey: nil),
        .init(title: "清空追加剪贴板历史", defaultKey: nil)
    ]

    private let captureRows: [ShortcutRow] = [
        .init(title: "保留换行", defaultKey: "⌘L"),
        .init(title: "追加剪贴板", defaultKey: "⌘H"),
        .init(title: "文字转语音", defaultKey: "⌘S")
    ]

    init(appState: AppState, hotKeyManager: HotKeyManager = .shared) {
        self.appState = appState
        self.hotKeyManager = hotKeyManager
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func makeSeparator() -> NSView {
        let line = NSView()
        line.wantsLayer = true
        line.layer?.backgroundColor = NSColor.separatorColor.cgColor // 或 .lightGray.cgColor
        line.translatesAutoresizingMaskIntoConstraints = false
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return line
    }

    override func loadView() {
        let rootView = NSView(frame: NSRect(x: 0, y: 0, width: 510, height: 620))
        rootView.translatesAutoresizingMaskIntoConstraints = false
        self.view = rootView

        let globalTitle = sectionTitleLabel("全局快捷键")
        let globalStack = buildShortcutsStack(from: globalRows)

        let captureTitle = sectionTitleLabel("截取模式切换")
        let captureSubtitle = smallLabel("执行截取操作时，可使用以下快捷键快速切换偏好。")
        let captureStack = buildShortcutsStack(from: captureRows)

        let contentStack = NSStackView(views: [
            globalTitle,
            globalStack,
            makeSeparator(),
            captureTitle,
            captureSubtitle,
            captureStack
        ])
        contentStack.orientation = .vertical
        contentStack.alignment = .leading
        contentStack.spacing = 12
        contentStack.edgeInsets = NSEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: view.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentStack.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor)
        ])
    }

    private func buildShortcutsStack(from rows: [ShortcutRow]) -> NSStackView {
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.spacing = 6
        stack.alignment = .leading

        for row in rows {
            let label = NSTextField(labelWithString: row.title)
            label.setContentHuggingPriority(.defaultHigh, for: .horizontal)

            let shortcutField = ShortcutRecordField(frame: .zero)
            shortcutField.translatesAutoresizingMaskIntoConstraints = false
            shortcutField.widthAnchor.constraint(equalToConstant: 180).isActive = true
            shortcutField.defaultDisplayString = row.defaultKey ?? "Record Shortcut"
            if let defaultShortcut = defaultShortcuts[row.title] {
                shortcutField.shortcut = defaultShortcut
                shortcuts[row.title] = defaultShortcut
                registerShortcut(defaultShortcut, for: row.title)
            }
            shortcutField.onShortcutChanged = { [weak self] shortcut in
                self?.shortcuts[row.title] = shortcut
                self?.registerShortcut(shortcut, for: row.title)
            }

            let clearButton = NSButton(title: "✕", target: self, action: #selector(clearShortcutButtonTapped(_:)))
            clearButton.bezelStyle = .texturedRounded
            clearButton.setButtonType(.momentaryPushIn)
            clearButton.identifier = NSUserInterfaceItemIdentifier(row.title)
            clearButton.cell?.representedObject = shortcutField
            clearButton.translatesAutoresizingMaskIntoConstraints = false
            clearButton.widthAnchor.constraint(equalToConstant: 26).isActive = true

            let spacer = NSView()
            spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)

            let hStack = NSStackView(views: [label, spacer, shortcutField, clearButton])
            hStack.orientation = .horizontal
            hStack.alignment = .centerY
            hStack.spacing = 8

            stack.addArrangedSubview(hStack)
        }
        return stack
    }

    @objc private func clearShortcutButtonTapped(_ sender: NSButton) {
        guard let field = sender.cell?.representedObject as? ShortcutRecordField else { return }
        field.clearShortcut()

        if let title = sender.identifier?.rawValue {
            shortcuts[title] = nil
            registerShortcut(nil, for: title)
        }
    }

    private func sectionTitleLabel(_ text: String) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = .boldSystemFont(ofSize: 12)
        return label
    }

    private func smallLabel(_ text: String) -> NSTextField {
        let label = NSTextField(wrappingLabelWithString: text)
        label.font = .systemFont(ofSize: 11)
        label.textColor = .secondaryLabelColor
        return label
    }

    private func registerShortcut(_ shortcut: Shortcut?, for title: String) {
        hotKeyManager.unregister(id: title)
        guard let shortcut, let action = actions[title] else { return }
        hotKeyManager.register(id: title, shortcut: shortcut, handler: action)
    }
}
