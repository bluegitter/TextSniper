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
        Button("截取文字") {
            appState.captureText()
        }
        .keyboardShortcut("2", modifiers: [.shift, .command])

        Button("识别二维码/条码") {
            appState.captureCode()
        }

        Menu("从 iPhone 导入") {
            Text("iPhone")
                .foregroundStyle(.secondary)
                .disabled(true)

            Divider()

            Button("拍照") {
                appState.showComingSoon(title: "拍照")
            }

            Button("扫描文稿") {
                appState.showComingSoon(title: "扫描文稿")
            }

            Button("添加草图") {
                appState.showComingSoon(title: "添加草图")
            }
        }

        Divider()

        Toggle("保留换行", isOn: $appState.keepLineBreaks)
        Toggle("追加剪贴板", isOn: $appState.additiveClipboard)

        Button("清空剪贴板历史") {
            appState.clearAdditiveClipboardHistory()
        }
        .disabled(appState.additiveClipboardHistory.isEmpty)

        Toggle("文字转语音", isOn: $appState.textToSpeechEnabled)

        Button("停止朗读") {
            appState.stopSpeaking()
        }
        .disabled(!appState.isSpeaking)

        Divider()

        Button("设置…") {
            appState.openSettings()
        }

        Button("退出 TextSniper") {
            appState.quit()
        }
        .keyboardShortcut("Q")
    }
}
