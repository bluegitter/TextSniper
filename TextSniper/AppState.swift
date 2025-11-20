//
//  AppState.swift
//  TextSniper
//
//  Created by yanfei on 2025/11/20.
//

import AppKit
import AVFoundation
import Combine
import SwiftUI

final class AppState: NSObject, ObservableObject {
    // MARK: - Published Settings
    @Published var keepLineBreaks = true
    @Published var additiveClipboard = false
    @Published var additiveClipboardHistory: [String] = []
    @Published var additiveClipboardClearAutomatically = false

    @Published var textToSpeechEnabled = false
    @Published var textToSpeechRate: Double = 180
    @Published private(set) var isSpeaking = false

    @Published var recognitionLanguage: RecognitionLanguage = .english
    @Published var autoDetectLanguage = true
    @Published var customWordsText: String = ""

    @Published var launchAtLogin = false
    @Published var showInMenuBar = true
    @Published var disableSoundEffects = false
    @Published var disableSuccessNotification = false
    @Published var automaticallyOpenLinks = false
    @Published var automaticallyCheckForUpdates = true

    // MARK: - Services
    private let captureCoordinator = ScreenCaptureCoordinator()
    private let textRecognizer = TextRecognizer()
    private let barcodeReader = BarcodeReader()
    private let speechSynthesizer = AVSpeechSynthesizer()

    private var cancellables: Set<AnyCancellable> = []

    override init() {
        super.init()
        speechSynthesizer.delegate = self
    }

    // MARK: - Actions
    func captureText(preserveLineBreaksOverride: Bool? = nil) {
        captureCoordinator.beginCapture { [weak self] image in
            guard let self, let image else { return }

            if let png = image.pngData {
                try? png.write(to: URL(fileURLWithPath: "/tmp/textsniper-capture.png"))
            }
            let keepBreaks = preserveLineBreaksOverride ?? self.keepLineBreaks
            self.recognizeText(from: image, keepLineBreaks: keepBreaks)
        }
    }

    func captureCode() {
        captureCoordinator.beginCapture { [weak self] image in
            guard let self, let image else { return }
            self.barcodeReader.read(from: image) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let payload):
                        self.copyToClipboard(payload)
                        self.notifyUser(title: "Code Copied", text: payload)
                        if self.textToSpeechEnabled {
                            self.speak(text: payload)
                        }
                    case .failure(let error):
                        self.notifyUser(title: "Unable to read code", text: error.localizedDescription)
                    }
                }
            }
        }
    }

    func showComingSoon(title: String) {
        notifyUser(title: title, text: "This action will be available in a future version of TextSniper.")
    }

    func clearAdditiveClipboardHistory() {
        additiveClipboardHistory.removeAll()
    }

    func stopSpeaking() {
        speechSynthesizer.stopSpeaking(at: .immediate)
    }

    func openSettings() {
        if
            let delegate = NSApp.delegate as? AppDelegate
        {
            delegate.openSettings(nil)
        } else {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        }
    }

    func quit() {
        NSApp.terminate(nil)
    }

    // MARK: - Helpers
    private func recognizeText(from image: NSImage, keepLineBreaks: Bool) {
        let customWords = customWordsText
            .split(whereSeparator: { $0 == "," || $0.isNewline })
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        #if DEBUG
        if let png = image.pngData {
            let directory = FileManager.default.temporaryDirectory
            let url = directory.appendingPathComponent("textsniper-capture.png")
            do {
                try png.write(to: url)
                print("[AppState] Saved capture to \(url.path)")
            } catch {
                print("[AppState] Failed to save capture: \(error)")
            }
        } else {
            print("[AppState] Unable to export capture as PNG.")
        }
        #endif

        textRecognizer.recognize(
            in: image,
            language: recognitionLanguage,
            autoDetect: autoDetectLanguage,
            customWords: customWords
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let text):
                    self.handleRecognizedText(text, keepLineBreaks: keepLineBreaks)
                case .failure(let error):
                    self.notifyUser(title: "Recognition Failed", text: error.localizedDescription)
                }
            }
        }
    }

    private func handleRecognizedText(_ text: String, keepLineBreaks: Bool) {
        let processed: String
        if keepLineBreaks {
            processed = text
        } else {
            processed = text.replacingOccurrences(of: "\\s*\\n\\s*", with: " ", options: .regularExpression)
        }

        if additiveClipboard {
            additiveClipboardHistory.append(processed)

            let combined = additiveClipboardHistory.joined(separator: "\n")
            copyToClipboard(combined)
        } else {
            copyToClipboard(processed)
        }

        notifyUser(title: "识别成功", text: "识别内容已放入剪贴板")

        if textToSpeechEnabled {
            speak(text: processed)
        }
    }

    private func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }

    private func notifyUser(title: String, text: String) {
        guard !disableSuccessNotification else { return }
        ToastPresenter.shared.show(message: text)
    }

    private func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        let normalized = max(0.4, min(1.2, textToSpeechRate / 180.0))
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * Float(normalized)
        speechSynthesizer.speak(utterance)
        isSpeaking = true
    }
}

extension AppState: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isSpeaking = synthesizer.isSpeaking
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        isSpeaking = true
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        isSpeaking = synthesizer.isSpeaking
    }
}
