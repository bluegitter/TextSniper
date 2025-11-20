//
//  MenuBarView.swift
//  TextSniper
//
//  Created by yanfei on 2025/11/20.
//

import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Button("Capture Text") {
            appState.captureText()
        }
        .keyboardShortcut("2", modifiers: [.shift, .command])

        Button("Read QR/Bar Code") {
            appState.captureCode()
        }

        Menu("Import from iPhone") {
            Text("iPhone")
                .foregroundStyle(.secondary)
                .disabled(true)

            Divider()

            Button("Take Photo") {
                appState.showComingSoon(title: "Take Photo")
            }

            Button("Scan Documents") {
                appState.showComingSoon(title: "Scan Document")
            }

            Button("Add Sketch") {
                appState.showComingSoon(title: "Add Sketch")
            }
        }

        Divider()

        Toggle("Keep Line Breaks", isOn: $appState.keepLineBreaks)
        Toggle("Additive Clipboard", isOn: $appState.additiveClipboard)

        Button("Clear Clipboard History") {
            appState.clearAdditiveClipboardHistory()
        }
        .disabled(appState.additiveClipboardHistory.isEmpty)

        Toggle("Text to Speech", isOn: $appState.textToSpeechEnabled)

        Button("Stop Speaking") {
            appState.stopSpeaking()
        }
        .disabled(!appState.isSpeaking)

        Divider()

        Button("Settings...") {
            appState.openSettings()
        }

        Button("Quit TextSniper") {
            appState.quit()
        }
        .keyboardShortcut("Q")
    }
}
