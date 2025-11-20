//
//  CustomWordsPreferencesViewController.swift
//  TextSniper
//
//  Created by yanfei on 2025/11/20.
//

import AppKit

final class CustomWordsPreferencesViewController: NSViewController {
  deinit {
        print("🔥 CustomWordsPreferencesViewController deinit")
    }

    private let infoLabel: NSTextField = {
        let text = """
        If the text you're recognizing uses domain-specific jargon, such as medical or technical terms, \
        you can tailor the language correction's behavior by setting the Custom Words list. \
        The words in the list takes precedence over the standard lexicon.
        """
        let label = NSTextField(wrappingLabelWithString: text)
        label.font = .systemFont(ofSize: 12)
        return label
    }()

    private let textView: NSTextView = {
        let view = NSTextView()
        view.isRichText = false
        view.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        view.string = "Type custom words separated by comma..."
        return view
    }()

    override func loadView() {
        print("✅ CustomWordsPreferencesViewController.loadView")
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
