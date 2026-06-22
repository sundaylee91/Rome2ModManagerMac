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
            // 拦截系统「关于」菜单 → 打开自定义关于窗口
            CommandGroup(replacing: .appInfo) {
                Button("About \(AppInfo.appName)") {
                    AboutWindowController.show()
                }
            }

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
    }
}

/// 管理自定义关于窗口
final class AboutWindowController: NSObject {
    private static var window: NSWindow?

    static func show() {
        if let existing = window, existing.isVisible {
            existing.makeKeyAndOrderFront(nil)
            return
        }

        let aboutView = AboutView()
        let hosting = NSHostingController(rootView: aboutView)

        let w = NSWindow(contentViewController: hosting)
        w.title = "About \(AppInfo.appName)"
        w.styleMask = [.titled, .closable]
        w.isReleasedWhenClosed = false
        w.center()
        w.makeKeyAndOrderFront(nil)

        window = w
    }
}
