//
//  CustomWordsView.swift
//  TextSniper
//
//  Created by yanfei on 2025/11/20.
//

import SwiftUI

struct CustomWordsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("If the text you're recognizing uses domain-specific jargon, such as medical or technical terms, you can tailor the language correction behavior by setting the Custom Words list. The words in the list take precedence over the standard lexicon.")
                .font(.callout)
                .foregroundStyle(.secondary)

            TextEditor(text: $appState.customWordsText)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .font(.body.monospaced())
                .padding(.top, 8)
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.secondary.opacity(0.2))
                )

            Text("Type custom words separated by comma…")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
