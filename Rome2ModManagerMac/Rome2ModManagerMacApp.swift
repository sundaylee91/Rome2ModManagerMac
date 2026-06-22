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
        // 主窗口
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .environmentObject(locManager)
                .frame(minWidth: 700, minHeight: 450)
        }
        .defaultSize(width: 950, height: 580)
        .windowResizability(.contentMinSize)
        .commands {
            // 移除 "New Window" 菜单项
            CommandGroup(replacing: .newItem) {}

            // 替换系统关于窗口为自定义窗口
            CommandGroup(replacing: .appInfo) {
                Button("About \(AppInfo.appName)") {
                    NSApplication.shared.orderFrontStandardAboutPanel(nil)
                    // 延迟替换系统关于窗口内容
                    DispatchQueue.main.async {
                        showCustomAbout()
                    }
                }
            }

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

        // 自定义关于窗口（独立窗口，用户也可直接通过菜单打开）
        Window("About \(AppInfo.appName)", id: "about") {
            AboutView()
        }
        .defaultSize(width: 360, height: 340)
        .windowResizability(.contentSize)
    }

    /// 显示自定义关于窗口
    private func showCustomAbout() {
        // 关闭系统关于面板
        if let systemAbout = NSApp.windows.first(where: {
            $0.className == "NSAboutPanel" || $0.title.contains("About")
        }) {
            systemAbout.close()
        }

        // 打开自定义关于窗口
        if let window = NSApp.windows.first(where: { $0.identifier?.rawValue == "about" }) {
            window.makeKeyAndOrderFront(nil)
        } else {
            // 如果窗口还不存在，通过 openWindow 创建
            // 使用 NSWorkspace 或其他方式打开
            openAboutWindow()
        }
    }

    private func openAboutWindow() {
        // 使用 SwiftUI 的 openWindow 环境值
        if let windowScene = NSApp.connectedScenes.first as? NSWindowScene {
            // 尝试通过 window scene 打开
            NSApp.sendAction(Selector(("showAboutWindow:")), to: nil, from: nil)
        }
    }
}
