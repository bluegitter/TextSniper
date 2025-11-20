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
    private var preferencesWindowController: PreferencesWindowController?

    private var cancellables: Set<AnyCancellable> = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        constructStatusItem()
        observeStateChanges()
        HotKeyManager.shared.registerCaptureHotKey { [weak self] in
            self?.appState.captureText()
        }
    }

    private func constructStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            button.image = NSImage(systemSymbolName: "text.viewfinder", accessibilityDescription: "TextSniper")
        }

        let menu = NSMenu()
        menu.autoenablesItems = false

        let captureItem = NSMenuItem(
            title: "截取文字",
            action: #selector(captureText),
            keyEquivalent: "2"
        )
        captureItem.keyEquivalentModifierMask = [.command, .shift]
        captureItem.target = self
        menu.addItem(captureItem)

        let qrItem = NSMenuItem(
            title: "识别二维码/条码",
            action: #selector(readQRCode),
            keyEquivalent: ""
        )
        qrItem.target = self
        menu.addItem(qrItem)

        menu.addItem(.separator())

        let importItem = NSMenuItem(title: "从 iPhone 导入", action: nil, keyEquivalent: "")
        let importSubmenu = NSMenu(title: "从 iPhone 导入")
        let header = NSMenuItem(title: "iPhone", action: nil, keyEquivalent: "")
        header.isEnabled = false
        importSubmenu.addItem(header)
        importSubmenu.addItem(.separator())

        importSubmenu.addItem(menuButton(title: "拍照", action: #selector(takePhoto)))
        importSubmenu.addItem(menuButton(title: "扫描文稿", action: #selector(scanDocuments)))
        importSubmenu.addItem(menuButton(title: "添加草图", action: #selector(addSketch)))

        menu.setSubmenu(importSubmenu, for: importItem)
        menu.addItem(importItem)

        menu.addItem(.separator())

        keepLineBreaksItem = menuToggle(title: "保留换行", action: #selector(toggleKeepLineBreaks))
        if let keepLineBreaksItem {
            menu.addItem(keepLineBreaksItem)
        }

        additiveClipboardItem = menuToggle(title: "追加剪贴板", action: #selector(toggleAdditiveClipboard))
        if let additiveClipboardItem {
            menu.addItem(additiveClipboardItem)
        }

        clearHistoryItem = menuButton(title: "清空剪贴板历史", action: #selector(clearClipboardHistory))
        clearHistoryItem?.isEnabled = false
        if let clearHistoryItem {
            menu.addItem(clearHistoryItem)
        }

        menu.addItem(.separator())

        textToSpeechItem = menuToggle(title: "文字转语音", action: #selector(toggleTextToSpeech))
        if let textToSpeechItem {
            menu.addItem(textToSpeechItem)
        }

        stopSpeakingItem = menuButton(title: "停止朗读", action: #selector(stopSpeaking))
        stopSpeakingItem?.isEnabled = false
        if let stopSpeakingItem {
            menu.addItem(stopSpeakingItem)
        }

        menu.addItem(.separator())

        let settingsItem = NSMenuItem(title: "设置…", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "退出 TextSniper", action: #selector(quitApp), keyEquivalent: "q")
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
        appState.showComingSoon(title: "拍照")
    }

    @objc private func scanDocuments(_ sender: Any?) {
        appState.showComingSoon(title: "扫描文稿")
    }

    @objc private func addSketch(_ sender: Any?) {
        appState.showComingSoon(title: "添加草图")
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

    @objc func openSettings(_ sender: Any?) {
        if preferencesWindowController == nil {
            preferencesWindowController = PreferencesWindowController()
        }

        // 在下一个 runloop 再显示并激活
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let window = self.preferencesWindowController?.window else { return }

            self.preferencesWindowController?.showWindow(nil)
            window.center()
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    @objc private func quitApp(_ sender: Any?) {
        appState.quit()
    }
}
