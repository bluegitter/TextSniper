//
//  CustomWordsPreferencesViewController.swift
//  TextSniper
//
//  Created by yanfei on 2025/11/20.
//

import AppKit

final class CustomWordsPreferencesViewController: NSViewController {
    private let infoLabel: NSTextField = {
        let text = """
        当识别内容包含专业术语（如医学、技术等）时，可在此添加自定义词列表；列表中的词将优先于默认词典。
        """
        let label = NSTextField(wrappingLabelWithString: text)
        label.font = .systemFont(ofSize: 12)
        return label
    }()

    private let textView: NSTextView = {
        let view = NSTextView()
        view.isRichText = false
        view.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        view.string = "请输入自定义词语，使用逗号分隔…"
        return view
    }()

    override func loadView() {
        let rootView = NSView(frame: NSRect(x: 0, y: 0, width: 510, height: 327))
        rootView.translatesAutoresizingMaskIntoConstraints = false
        self.view = rootView

        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.documentView = textView
        scrollView.borderType = .bezelBorder
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let stack = NSStackView(views: [infoLabel, scrollView])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 12
        stack.edgeInsets = NSEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.topAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            scrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: 260)
        ])
    }
}
