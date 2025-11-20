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
            let recordButton = NSButton(title: "设置快捷键", target: nil, action: nil)
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
