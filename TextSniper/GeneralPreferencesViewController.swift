//
//  GeneralPreferencesViewController.swift
//  TextSniper
//
//  Created by yanfei on 2025/11/20.
//

import AppKit

final class GeneralPreferencesViewController: NSViewController {
    private let launchAtLoginButton = NSButton(checkboxWithTitle: "登录时启动", target: nil, action: nil)
    private let showInMenuBarButton = NSButton(checkboxWithTitle: "在菜单栏显示", target: nil, action: nil)
    private let disableSoundButton = NSButton(checkboxWithTitle: "关闭提示音", target: nil, action: nil)
    private let disableSuccessButton = NSButton(checkboxWithTitle: "关闭成功提示", target: nil, action: nil)
    private let autoOpenLinksButton = NSButton(checkboxWithTitle: "自动打开链接", target: nil, action: nil)

    private let recognitionPopup = NSPopUpButton()
    private let autoDetectLanguageButton = NSButton(checkboxWithTitle: "自动检测语言", target: nil, action: nil)

    private let additiveCheckbox = NSButton(checkboxWithTitle: "粘贴后自动清空", target: nil, action: nil)

    private let ttsSlider = NSSlider(value: 180, minValue: 80, maxValue: 400, target: nil, action: nil)

    private let versionLabel = NSTextField(labelWithString: "TextSniper 1.11")
    private let checkUpdatesButton = NSButton(title: "检查更新…", target: nil, action: nil)
    private let autoCheckUpdatesButton = NSButton(checkboxWithTitle: "自动检查更新", target: nil, action: nil)
    private let deactivateButton = NSButton(title: "停用许可证…", target: nil, action: nil)
    private let feedbackLabel = NSTextField(labelWithString: "反馈：")
    private let feedbackButton = NSButton(title: "support@textsniper.app", target: nil, action: nil)

    override func loadView() {
        let rootView = NSView(frame: NSRect(x: 0, y: 0, width: 510, height: 520))
        rootView.translatesAutoresizingMaskIntoConstraints = false
        self.view = rootView

        view.translatesAutoresizingMaskIntoConstraints = false

        setupControls()
        buildLayout()
    }

    private func setupControls() {
        showInMenuBarButton.state = .on

        recognitionPopup.addItems(withTitles: [
            "跟随系统",
            "简体中文",
            "英语",
            "日语"
        ])
        recognitionPopup.selectItem(withTitle: "简体中文")

        feedbackButton.bezelStyle = .inline
        feedbackButton.isBordered = false
        feedbackButton.font = .systemFont(ofSize: 12)

        versionLabel.font = .systemFont(ofSize: 12)
        feedbackLabel.font = .systemFont(ofSize: 12)
    }

    private func buildLayout() {
        let systemTitle = sectionTitleLabel("系统：")
        let systemStack = verticalStack(spacing: 6, views: [
            launchAtLoginButton,
            showInMenuBarButton,
            disableSoundButton,
            disableSuccessButton,
            autoOpenLinksButton
        ])
        let systemGroup = groupStack(title: systemTitle, content: systemStack)

        let recogTitle = sectionTitleLabel("识别语言：")
        recognitionPopup.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        let recogRow = horizontalStack(spacing: 8, views: [recognitionPopup, NSView()])
        let recogStack = verticalStack(spacing: 8, views: [
            recogRow,
            autoDetectLanguageButton
        ])
        let recogGroup = groupStack(title: recogTitle, content: recogStack)

        let additiveTitle = sectionTitleLabel("追加剪贴板：")
        let additiveGroup = groupStack(title: additiveTitle, content: additiveCheckbox)

        let ttsTitle = sectionTitleLabel("文字转语音语速：")
        ttsSlider.isContinuous = true
        let ttsGroup = groupStack(title: ttsTitle, content: ttsSlider)

        let aboutTitle = sectionTitleLabel("关于：")
        let versionRow = horizontalStack(views: [versionLabel, NSView()])
        let updatesRow = horizontalStack(spacing: 12, views: [checkUpdatesButton, autoCheckUpdatesButton])
        let deactivateRow = horizontalStack(views: [deactivateButton, NSView()])
        let feedbackRow = horizontalStack(spacing: 6, views: [feedbackLabel, feedbackButton, NSView()])
        let aboutStack = verticalStack(spacing: 8, views: [
            versionRow,
            updatesRow,
            deactivateRow,
            feedbackRow
        ])
        let aboutGroup = groupStack(title: aboutTitle, content: aboutStack)

        let mainStack = verticalStack(spacing: 18, views: [
            systemGroup,
            makeSeparator(),
            recogGroup,
            makeSeparator(),
            additiveGroup,
            makeSeparator(),
            ttsGroup,
            makeSeparator(),
            aboutGroup
        ])
        mainStack.edgeInsets = NSEdgeInsets(top: 24, left: 32, bottom: 24, right: 32)
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func makeSeparator() -> NSView {
        let line = NSView()
        line.wantsLayer = true
        line.layer?.backgroundColor = NSColor.separatorColor.cgColor // 或 .lightGray.cgColor
        line.translatesAutoresizingMaskIntoConstraints = false
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return line
    }
    
    private func sectionTitleLabel(_ text: String) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = .boldSystemFont(ofSize: 12)
        return label
    }

    private func groupStack(title: NSTextField, content: NSView) -> NSStackView {
        let stack = NSStackView(views: [title, content])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 6
        return stack
    }

    private func verticalStack(spacing: CGFloat = 4, views: [NSView]) -> NSStackView {
        let stack = NSStackView(views: views)
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = spacing
        return stack
    }

    private func horizontalStack(spacing: CGFloat = 4, views: [NSView]) -> NSStackView {
        let stack = NSStackView(views: views)
        stack.orientation = .horizontal
        stack.alignment = .centerY
        stack.spacing = spacing
        return stack
    }
}
