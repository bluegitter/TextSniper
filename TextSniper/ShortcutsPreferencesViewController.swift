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

    private let globalRows: [ShortcutRow] = [
        .init(title: "Capture Text", defaultKey: "⇧⌘2"),
        .init(title: "Capture Last Selection", defaultKey: nil),
        .init(title: "Capture Without Line Breaks", defaultKey: nil),
        .init(title: "Capture With Line Breaks", defaultKey: nil),
        .init(title: "Capture With Text to Speech", defaultKey: nil),
        .init(title: "Read QR/Bar Code", defaultKey: nil),
        .init(title: "Stop Speaking", defaultKey: nil),
        .init(title: "Toggle Additive Clipboard", defaultKey: nil),
        .init(title: "Clear Additive Clipboard History", defaultKey: nil)
    ]

    private let captureRows: [ShortcutRow] = [
        .init(title: "Keep Line Breaks", defaultKey: "⌘L"),
        .init(title: "Additive Clipboard", defaultKey: "⌘H"),
        .init(title: "Text to Speech", defaultKey: "⌘S")
    ]
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

        let globalTitle = sectionTitleLabel("Global")
        let globalStack = buildShortcutsStack(from: globalRows)

        let captureTitle = sectionTitleLabel("Capture Text mode")
        let captureSubtitle = smallLabel("Toggles preferences when Capture Text operation is active.")
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
            let recordButton = NSButton(title: "Record Shortcut", target: nil, action: nil)
            recordButton.bezelStyle = .rounded

            let shortcutLabel = NSTextField(labelWithString: row.defaultKey ?? "")
            shortcutLabel.font = .monospacedSystemFont(ofSize: 12, weight: .regular)

            let hStack = NSStackView(views: [label, NSView(), recordButton, shortcutLabel])
            hStack.orientation = .horizontal
            hStack.alignment = .centerY
            hStack.spacing = 8

            stack.addArrangedSubview(hStack)
        }
        return stack
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
}
