//
//  SettingsContainerView.swift
//  TextSniper
//
//  Created by yanfei on 2025/11/20.
//

import SwiftUI

struct SettingsContainerView: View {
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }

            CustomWordsView()
                .tabItem {
                    Label("Custom Words", systemImage: "text.badge.plus")
                }

            ShortcutsSettingsView()
                .tabItem {
                    Label("Shortcuts", systemImage: "command")
                }
        }
        .padding(24)
        .frame(width: 540, height: 420)
    }
}
