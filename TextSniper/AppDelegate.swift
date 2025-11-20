//
//  AppDelegate.swift
//  TextSniper
//
//  Created by yanfei on 2025/11/20.
//

import AppKit
import Combine

final class AppDelegate: NSObject, NSApplicationDelegate {
    let appState = AppState()

    private var statusItem: NSStatusItem?
    private var keepLineBreaksItem: NSMenuItem?
    private var additiveClipboardItem: NSMenuItem?
    private var clearHistoryItem: NSMenuItem?
    private var textToSpeechItem: NSMenuItem?
    private var stopSpeakingItem: NSMenuItem?

    private var cancellables: Set<AnyCancellable> = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        constructStatusItem()
        observeStateChanges()
    }

    private func constructStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            button.image = NSImage(systemSymbolName: "text.viewfinder", accessibilityDescription: "TextSniper")
        }

        let menu = NSMenu()
        menu.autoenablesItems = false

        let captureItem = NSMenuItem(
            title: "Capture Text",
            action: #selector(captureText),
            keyEquivalent: "2"
        )
        captureItem.keyEquivalentModifierMask = [.command, .shift]
        captureItem.target = self
        menu.addItem(captureItem)

        let qrItem = NSMenuItem(
            title: "Read QR/Bar Code",
            action: #selector(readQRCode),
            keyEquivalent: ""
        )
        qrItem.target = self
        menu.addItem(qrItem)

        menu.addItem(.separator())

        let importItem = NSMenuItem(title: "Import from iPhone", action: nil, keyEquivalent: "")
        let importSubmenu = NSMenu(title: "Import from iPhone")
        let header = NSMenuItem(title: "iPhone", action: nil, keyEquivalent: "")
        header.isEnabled = false
        importSubmenu.addItem(header)
        importSubmenu.addItem(.separator())

        importSubmenu.addItem(menuButton(title: "Take Photo", action: #selector(takePhoto)))
        importSubmenu.addItem(menuButton(title: "Scan Documents", action: #selector(scanDocuments)))
        importSubmenu.addItem(menuButton(title: "Add Sketch", action: #selector(addSketch)))

        menu.setSubmenu(importSubmenu, for: importItem)
        menu.addItem(importItem)

        menu.addItem(.separator())

        keepLineBreaksItem = menuToggle(title: "Keep Line Breaks", action: #selector(toggleKeepLineBreaks))
        if let keepLineBreaksItem {
            menu.addItem(keepLineBreaksItem)
        }

        additiveClipboardItem = menuToggle(title: "Additive Clipboard", action: #selector(toggleAdditiveClipboard))
        if let additiveClipboardItem {
            menu.addItem(additiveClipboardItem)
        }

        clearHistoryItem = menuButton(title: "Clear Clipboard History", action: #selector(clearClipboardHistory))
        clearHistoryItem?.isEnabled = false
        if let clearHistoryItem {
            menu.addItem(clearHistoryItem)
        }

        menu.addItem(.separator())

        textToSpeechItem = menuToggle(title: "Text to Speech", action: #selector(toggleTextToSpeech))
        if let textToSpeechItem {
            menu.addItem(textToSpeechItem)
        }

        stopSpeakingItem = menuButton(title: "Stop Speaking", action: #selector(stopSpeaking))
        stopSpeakingItem?.isEnabled = false
        if let stopSpeakingItem {
            menu.addItem(stopSpeakingItem)
        }

        menu.addItem(.separator())

        let settingsItem = NSMenuItem(title: "Settings…", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit TextSniper", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        item.menu = menu
        statusItem = item
        refreshMenuStates()
    }

    private func observeStateChanges() {
        appState.$keepLineBreaks
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.refreshMenuStates() }
            .store(in: &cancellables)

        appState.$additiveClipboard
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.refreshMenuStates() }
            .store(in: &cancellables)

        appState.$textToSpeechEnabled
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.refreshMenuStates() }
            .store(in: &cancellables)

        appState.$additiveClipboardHistory
            .receive(on: RunLoop.main)
            .sink { [weak self] history in
                self?.clearHistoryItem?.isEnabled = !history.isEmpty
            }
            .store(in: &cancellables)

        appState.$isSpeaking
            .receive(on: RunLoop.main)
            .sink { [weak self] speaking in
                self?.stopSpeakingItem?.isEnabled = speaking
            }
            .store(in: &cancellables)
    }

    private func refreshMenuStates() {
        keepLineBreaksItem?.state = appState.keepLineBreaks ? .on : .off
        additiveClipboardItem?.state = appState.additiveClipboard ? .on : .off
        textToSpeechItem?.state = appState.textToSpeechEnabled ? .on : .off
    }

    private func menuButton(title: String, action: Selector) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.target = self
        return item
    }

    private func menuToggle(title: String, action: Selector) -> NSMenuItem {
        let item = menuButton(title: title, action: action)
        item.state = .off
        return item
    }

    // MARK: - Menu Actions

    @objc private func captureText(_ sender: Any?) {
        appState.captureText()
    }

    @objc private func readQRCode(_ sender: Any?) {
        appState.captureCode()
    }

    @objc private func takePhoto(_ sender: Any?) {
        appState.showComingSoon(title: "Take Photo")
    }

    @objc private func scanDocuments(_ sender: Any?) {
        appState.showComingSoon(title: "Scan Documents")
    }

    @objc private func addSketch(_ sender: Any?) {
        appState.showComingSoon(title: "Add Sketch")
    }

    @objc private func toggleKeepLineBreaks(_ sender: NSMenuItem) {
        appState.keepLineBreaks.toggle()
    }

    @objc private func toggleAdditiveClipboard(_ sender: NSMenuItem) {
        appState.additiveClipboard.toggle()
    }

    @objc private func clearClipboardHistory(_ sender: Any?) {
        appState.clearAdditiveClipboardHistory()
    }

    @objc private func toggleTextToSpeech(_ sender: NSMenuItem) {
        appState.textToSpeechEnabled.toggle()
    }

    @objc private func stopSpeaking(_ sender: Any?) {
        appState.stopSpeaking()
    }

    @objc private func openSettings(_ sender: Any?) {
        appState.openSettings()
    }

    @objc private func quitApp(_ sender: Any?) {
        appState.quit()
    }
}
