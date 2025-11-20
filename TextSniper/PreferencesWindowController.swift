//
//  PreferencesWindowController.swift
//  TextSniper
//
//  Created by yanfei on 2025/11/20.
//

import AppKit

final class PreferencesWindowController: NSWindowController, NSToolbarDelegate {
    enum Tab: String, CaseIterable {
        case general = "常规"
        case customWords = "自定义词汇"
        case shortcuts = "快捷键"

        var toolbarIdentifier: NSToolbarItem.Identifier {
            switch self {
            case .general: return .init("pref.general")
            case .customWords: return .init("pref.customWords")
            case .shortcuts: return .init("pref.shortcuts")
            }
        }

        var image: NSImage? {
            switch self {
            case .general:
                return NSImage(named: NSImage.preferencesGeneralName)
            case .customWords:
                return NSImage(systemSymbolName: "text.badge.plus", accessibilityDescription: nil)
            case .shortcuts:
                return NSImage(systemSymbolName: "command", accessibilityDescription: nil)
            }
        }
    }

    private let generalVC = GeneralPreferencesViewController()
    private let customVC = CustomWordsPreferencesViewController()
    private let shortcutsVC = ShortcutsPreferencesViewController()

    private lazy var toolbar: NSToolbar = {
        let tb = NSToolbar(identifier: .init("PreferencesToolbar"))
        tb.delegate = self
        tb.allowsUserCustomization = false
        tb.displayMode = .iconAndLabel
        tb.sizeMode = .regular
        return tb
    }()

    private var currentTab: Tab = .general

    init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 620, height: 520),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isReleasedWhenClosed = false

        super.init(window: window)
        window.toolbar = toolbar
        window.center()

        switchTo(tab: .general)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func switchTo(tab: Tab) {
        currentTab = tab

        let vc: NSViewController
        switch tab {
        case .general:
            vc = generalVC
        case .customWords:
            vc = customVC
        case .shortcuts:
            vc = shortcutsVC
        }

        window?.contentViewController = vc

        window?.title = tab.rawValue
        toolbar.selectedItemIdentifier = tab.toolbarIdentifier
    }

    // MARK: - NSToolbarDelegate

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        // Tab.allCases.map(\.toolbarIdentifier)
         [.flexibleSpace] + Tab.allCases.map(\.toolbarIdentifier)
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        // Tab.allCases.map(\.toolbarIdentifier)
        [.flexibleSpace] + Tab.allCases.map(\.toolbarIdentifier)
    }

    func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        // Tab.allCases.map(\.toolbarIdentifier)
        [.flexibleSpace] + Tab.allCases.map(\.toolbarIdentifier)
    }

    func toolbar(
        _ toolbar: NSToolbar,
        itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
        willBeInsertedIntoToolbar flag: Bool
    ) -> NSToolbarItem? {
        guard let tab = Tab.allCases.first(where: { $0.toolbarIdentifier == itemIdentifier }) else {
            return nil
        }

        let item = NSToolbarItem(itemIdentifier: itemIdentifier)
        item.label = tab.rawValue
        item.image = tab.image
        item.target = self
        item.action = #selector(toolbarItemClicked(_:))
        return item
    }

    @objc private func toolbarItemClicked(_ sender: NSToolbarItem) {
        guard let tab = Tab.allCases.first(where: { $0.toolbarIdentifier == sender.itemIdentifier }) else {
            return
        }
        switchTo(tab: tab)
    }
}
