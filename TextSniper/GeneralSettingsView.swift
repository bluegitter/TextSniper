//
//  GeneralSettingsView.swift
//  TextSniper
//
//  Created by yanfei on 2025/11/20.
//

import SwiftUI

struct GeneralSettingsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Form {
            Section("System") {
                Toggle("Launch at Login", isOn: $appState.launchAtLogin)
                Toggle("Show in Menu Bar", isOn: $appState.showInMenuBar)
                Toggle("Disable Sound Effects", isOn: $appState.disableSoundEffects)
                Toggle("Disable Success Notification", isOn: $appState.disableSuccessNotification)
                Toggle("Automatically Open Links", isOn: $appState.automaticallyOpenLinks)
            }

            Section("Recognition Language") {
                Picker("Language", selection: $appState.recognitionLanguage) {
                    ForEach(RecognitionLanguage.allCases) { language in
                        Text(language.rawValue).tag(language)
                    }
                }
                Toggle("Automatically Detect Language", isOn: $appState.autoDetectLanguage)
            }

            Section("Additive Clipboard") {
                Toggle("Clear Automatically", isOn: $appState.additiveClipboardClearAutomatically)
                    .help("Clear the additive clipboard history each time you paste (⌘V).")
            }

            Section("Text to Speech Rate") {
                Slider(value: $appState.textToSpeechRate, in: 100...320, step: 10) {
                    Text("Text to Speech Rate")
                }
                Text("\(Int(appState.textToSpeechRate)) WPM")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("About") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("TextSniper 1.11")
                        .font(.headline)
                    HStack {
                        Button("Check for Updates...") {
                            appState.showComingSoon(title: "Updates")
                        }
                        Toggle("Automatically Check for Updates", isOn: $appState.automaticallyCheckForUpdates)
                            .toggleStyle(.switch)
                    }
                    Button("Deactivate license...") {
                        appState.showComingSoon(title: "License")
                    }
                    Link("support@textsniper.app", destination: URL(string: "mailto:support@textsniper.app")!)
                }
            }
        }
        .formStyle(.grouped)
    }
}
