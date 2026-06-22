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

/// 管理自定义关于窗口（居中显示）
final class AboutWindowController: NSObject {
    private static var window: NSWindow?

    static func show() {
        // 如果已存在，直接前置
        if let existing = window, existing.isVisible {
            existing.makeKeyAndOrderFront(nil)
            existing.center()
            return
        }

        let aboutView = AboutView()
        let hosting = NSHostingController(rootView: aboutView)

        let w = NSWindow(contentViewController: hosting)
        w.title = "About \(AppInfo.appName)"
        w.styleMask = [.titled, .closable]
        w.isReleasedWhenClosed = false

        // 先设定窗口大小，再居中（确保 center() 基于正确尺寸计算）
        w.setFrame(NSRect(x: 0, y: 0, width: 420, height: 430), display: false)
        w.center()
        w.makeKeyAndOrderFront(nil)

        window = w
    }
}
