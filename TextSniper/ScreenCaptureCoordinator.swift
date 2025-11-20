//
//  ScreenCaptureCoordinator.swift
//  TextSniper
//
//  Created by yanfei on 2025/11/20.
//

import AppKit

final class ScreenCaptureCoordinator {
    private var windowController: SelectionOverlayWindowController?

    func beginCapture(completion: @escaping (NSImage?) -> Void) {
        DispatchQueue.main.async {
            guard self.windowController == nil else { return }
            guard let screen = NSScreen.main else {
                completion(nil)
                return
            }

            let controller = SelectionOverlayWindowController(screen: screen) { image in
                completion(image)
                self.windowController = nil
            }

            self.windowController = controller
            controller.showWindow(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
