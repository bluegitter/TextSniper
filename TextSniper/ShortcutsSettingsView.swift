//
//  ShortcutsSettingsView.swift
//  TextSniper
//
//  Created by yanfei on 2025/11/20.
//

import SwiftUI

struct ShortcutsSettingsView: View {
    @State private var captureText = "⇧⌘2"
    @State private var captureLastSelection = ""
    @State private var captureWithoutLineBreaks = ""
    @State private var captureWithLineBreaks = ""
    @State private var captureWithTextToSpeech = ""
    @State private var readCode = ""
    @State private var stopSpeaking = ""
    @State private var toggleAdditiveClipboard = ""
    @State private var clearAdditiveClipboard = ""

    @State private var keepLineBreaks = "⌘L"
    @State private var additiveClipboard = "⌘H"
    @State private var textToSpeech = "⌘S"

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Global")
                    .font(.headline)
                shortcutRow(title: "Capture Text", text: $captureText, enabled: true)
                shortcutRow(title: "Capture Last Selection", text: $captureLastSelection, enabled: false)
                shortcutRow(title: "Capture Without Line Breaks", text: $captureWithoutLineBreaks, enabled: false)
                shortcutRow(title: "Capture With Line Breaks", text: $captureWithLineBreaks, enabled: true, placeholder: "Press Shortcut")
                shortcutRow(title: "Capture With Text to Speech", text: $captureWithTextToSpeech, enabled: false)
                shortcutRow(title: "Read QR/Bar Code", text: $readCode, enabled: false)
                shortcutRow(title: "Stop Speaking", text: $stopSpeaking, enabled: false)
                shortcutRow(title: "Toggle Additive Clipboard", text: $toggleAdditiveClipboard, enabled: false)
                shortcutRow(title: "Clear Additive Clipboard History", text: $clearAdditiveClipboard, enabled: false)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Capture Text mode")
                    .font(.headline)
                Text("Toggles preferences when Capture Text operation is active.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                shortcutRow(title: "Keep Line Breaks", text: $keepLineBreaks, enabled: true)
                shortcutRow(title: "Additive Clipboard", text: $additiveClipboard, enabled: true)
                shortcutRow(title: "Text to Speech", text: $textToSpeech, enabled: true)
            }
            Spacer()
        }
    }

    private func shortcutRow(title: String, text: Binding<String>, enabled: Bool, placeholder: String = "Record Shortcut") -> some View {
        HStack {
            Text(title)
                .frame(width: 240, alignment: .leading)
            if enabled {
                TextField(placeholder, text: text)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 180)
            } else {
                Button(placeholder) {}
                    .buttonStyle(.bordered)
                    .disabled(true)
                    .frame(width: 180)
            }
        }
    }
}
