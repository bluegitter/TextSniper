//
//  TextSniperApp.swift
//  TextSniper
//
//  Created by yanfei on 2025/11/20.
//

import SwiftUI

@main
struct TextSniperApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
