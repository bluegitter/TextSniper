//
//  SelectionOverlayWindowController.swift
//  TextSniper
//
//  Created by yanfei on 2025/11/20.
//

import AppKit

final class SelectionOverlayWindowController: NSWindowController {
    private let screen: NSScreen
    private let completion: (NSImage?) -> Void

    init(screen: NSScreen, completion: @escaping (NSImage?) -> Void) {
        self.screen = screen
        self.completion = completion
        let window = NSWindow(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false,
            screen: screen
        )
        window.isReleasedWhenClosed = false
        window.level = .screenSaver
        window.backgroundColor = .clear
        window.isOpaque = false
        window.ignoresMouseEvents = false
        window.hasShadow = false

        let overlay = SelectionOverlayView(frame: window.contentView?.bounds ?? .zero)
        super.init(window: window)
        overlay.autoresizingMask = [.width, .height]
        overlay.onSelection = { [weak self] rect in
            self?.finish(with: rect)
        }
        overlay.onCancel = { [weak self] in
            self?.close()
            self?.completion(nil)
        }
        window.contentView = overlay
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        window?.makeKeyAndOrderFront(nil)
    }

    private func finish(with rect: NSRect?) {
        defer { close() }
        guard
            let rectInView = rect,
            rectInView.width > 5,
            rectInView.height > 5,
            let window,
            let screen = window.screen
        else {
            completion(nil)
            return
        }

        let rectInScreen = window.convertToScreen(rectInView)
        let screenFrame = screen.frame

        let cgRect = CGRect(
            x: rectInScreen.origin.x,
            y: screenFrame.maxY - rectInScreen.maxY,
            width: rectInScreen.width,
            height: rectInScreen.height
        )

        window.orderOut(nil)

        guard let cgImage = CGWindowListCreateImage(
            cgRect,
            .optionOnScreenOnly,
            kCGNullWindowID,
            [.bestResolution, .boundsIgnoreFraming]
        ) else {
            completion(nil)
            return
        }

        let imageSize = NSSize(width: CGFloat(cgImage.width), height: CGFloat(cgImage.height))
        let image = NSImage(cgImage: cgImage, size: imageSize)
        completion(image)
    }
}

final class SelectionOverlayView: NSView {
    var onSelection: ((NSRect) -> Void)?
    var onCancel: (() -> Void)?

    private var startPoint: CGPoint?
    private var currentPoint: CGPoint?

    override var acceptsFirstResponder: Bool { true }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        window?.makeFirstResponder(self)
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // Escape key
            onCancel?()
        }
    }

    override func mouseDown(with event: NSEvent) {
        startPoint = convert(event.locationInWindow, from: nil)
        currentPoint = startPoint
        needsDisplay = true
    }

    override func mouseDragged(with event: NSEvent) {
        currentPoint = convert(event.locationInWindow, from: nil)
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        currentPoint = convert(event.locationInWindow, from: nil)
        defer {
            startPoint = nil
            currentPoint = nil
        }

        guard let selection = selectionRect else {
            onCancel?()
            return
        }

        onSelection?(selection)
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let selection = selectionRect else {
            NSColor.black.withAlphaComponent(0.35).setFill()
            dirtyRect.fill()
            return
        }

        let overlay = NSBezierPath(rect: bounds)
        overlay.append(NSBezierPath(rect: selection))
        overlay.windingRule = .evenOdd
        NSColor.black.withAlphaComponent(0.35).setFill()
        overlay.fill()
    }

    private var selectionRect: NSRect? {
        guard let start = startPoint, let end = currentPoint else { return nil }
        return NSRect(
            x: min(start.x, end.x),
            y: min(start.y, end.y),
            width: abs(start.x - end.x),
            height: abs(start.y - end.y)
        )
    }
}
