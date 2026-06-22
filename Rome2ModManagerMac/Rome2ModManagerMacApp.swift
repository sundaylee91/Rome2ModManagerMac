//
//  Rome2ModManagerMacApp.swift
//  Rome2ModManagerMac
//
//  Created by 李拜天 on 2026/6/22.
//

import SwiftUI

@main
struct Rome2ModManagerMacApp: App {
    @StateObject private var viewModel = ModListViewModel()
    @StateObject private var locManager = LocalizationManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .environmentObject(locManager)
                .frame(minWidth: 700, minHeight: 450)
        }
        .defaultSize(width: 950, height: 580)
        .windowResizability(.contentMinSize)
        .commands {
            CommandGroup(replacing: .newItem) {}

            CommandGroup(after: .newItem) {
                Button(locManager.str(.scanMods)) {
                    viewModel.scanMods()
                }
                .keyboardShortcut("R", modifiers: [.command])

                Button(locManager.str(.writeScript)) {
                    viewModel.writeUserScript()
                }
                .keyboardShortcut("S", modifiers: [.command])
                .disabled(viewModel.mods.isEmpty)
            }
        }

        // 自定义关于窗口：菜单栏 → 文件 → 关于 可打开
        Window("About \(AppInfo.appName)", id: "about") {
            AboutView()
        }
        .defaultSize(width: 360, height: 340)
        .windowResizability(.contentSize)
    }
}
