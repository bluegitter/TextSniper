//
//  ToastPresenter.swift
//  TextSniper
//
//  Created by yanfei on 2025/11/20.
//

import AppKit

final class ToastPresenter {
    static let shared = ToastPresenter()

    private var panel: NSPanel?
    private var hideWorkItem: DispatchWorkItem?

    private init() {}

    func show(message: String) {
        DispatchQueue.main.async {
            guard !message.isEmpty else { return }
            let panel = self.panel ?? self.makePanel()
            self.panel = panel

            let contentSize = self.layoutContent(for: panel, message: message)
            self.position(panel: panel, size: contentSize)

            if panel.isVisible == false {
                panel.alphaValue = 0
                panel.makeKeyAndOrderFront(nil)
            }

            NSAnimationContext.runAnimationGroup { ctx in
                ctx.duration = 0.2
                panel.animator().alphaValue = 1
            }

            self.hideWorkItem?.cancel()
            let workItem = DispatchWorkItem { [weak self] in
                self?.hideToast()
            }
            self.hideWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2, execute: workItem)
        }
    }

    private func hideToast() {
        guard let panel else { return }
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.2
            panel.animator().alphaValue = 0
        }, completionHandler: {
            panel.orderOut(nil)
        })
    }

    private func layoutContent(for panel: NSPanel, message: String) -> NSSize {
        let label = NSTextField(labelWithString: message)
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .black
        label.alignment = .center
        label.lineBreakMode = .byWordWrapping

        let textWidth: CGFloat = 360
        let bounding = label.attributedStringValue.boundingRect(
            with: NSSize(width: textWidth, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin]
        )
        let size = NSSize(width: max(220, bounding.width + 40), height: max(60, bounding.height + 24))

        let blurView = NSVisualEffectView()
        blurView.material = .hudWindow
        blurView.state = .active
        blurView.blendingMode = .withinWindow
        blurView.wantsLayer = true
        blurView.layer?.cornerRadius = 12
        blurView.translatesAutoresizingMaskIntoConstraints = false

        label.translatesAutoresizingMaskIntoConstraints = false
        blurView.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: blurView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: blurView.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: blurView.topAnchor, constant: 12),
            label.bottomAnchor.constraint(equalTo: blurView.bottomAnchor, constant: -12)
        ])

        panel.contentView?.subviews.forEach { $0.removeFromSuperview() }
        panel.contentView?.addSubview(blurView)

        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: panel.contentView!.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: panel.contentView!.trailingAnchor),
            blurView.topAnchor.constraint(equalTo: panel.contentView!.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: panel.contentView!.bottomAnchor)
        ])

        panel.setFrame(NSRect(origin: .zero, size: size), display: true)
        return size
    }

    private func position(panel: NSPanel, size: NSSize) {
        guard let screen = NSScreen.main else { return }
        let visibleFrame = screen.visibleFrame
        let origin = NSPoint(
            x: visibleFrame.midX - size.width / 2,
            y: visibleFrame.minY + 120
        )
        panel.setFrameOrigin(origin)
    }

    private func makePanel() -> NSPanel {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 240, height: 60),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        panel.isReleasedWhenClosed = false
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.level = .floating
        panel.ignoresMouseEvents = true
        panel.collectionBehavior = [.canJoinAllSpaces, .transient, .ignoresCycle]
        return panel
    }
}
