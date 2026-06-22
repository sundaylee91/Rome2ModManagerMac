//
//  Rome2ModManagerMacApp.swift
//  Rome2ModManagerMac
//
//  Created by 李拜天 on 2026/6/22.
//

import SwiftUI
import AppKit

/// 全局通知：打开关于窗口
extension Notification.Name {
    static let showAboutWindow = Notification.Name("showAboutWindow")
}

@main
struct Rome2ModManagerMacApp: App {
    @StateObject private var viewModel = ModListViewModel()
    @StateObject private var locManager = LocalizationManager.shared
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .environmentObject(locManager)
                .frame(minWidth: 700, minHeight: 450)
                .onReceive(NotificationCenter.default.publisher(for: .showAboutWindow)) { _ in
                    openAboutWindow()
                }
        }
        .defaultSize(width: 950, height: 580)
        .windowResizability(.contentMinSize)
        .commands {
            CommandGroup(replacing: .newItem) {}

            // 替换系统 About 为自定义关于窗口
            CommandGroup(replacing: .appInfo) {
                Button("About \(AppInfo.appName)") {
                    NotificationCenter.default.post(name: .showAboutWindow, object: nil)
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

        // 自定义关于窗口
        Window("About \(AppInfo.appName)", id: "about") {
            AboutView()
        }
        .defaultSize(width: 360, height: 340)
        .windowResizability(.contentSize)
    }

    private func openAboutWindow() {
        // 先尝试找到已存在的关于窗口
        for window in NSApp.windows {
            if window.identifier?.rawValue == "about" {
                window.makeKeyAndOrderFront(nil)
                return
            }
        }
        // 窗口不存在时，用 SwiftUI 的方式创建
        // 通过 openWindow action (available via Notification -> Scene)
        NSApp.sendAction(Selector(("showAboutWindow:")), to: NSApp.delegate, from: nil)
    }
}

// MARK: - App Delegate

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // App 启动完成后的初始化
    }

    /// 手动触发 SwiftUI 的关于窗口
    @objc func showAboutWindow(_ sender: Any?) {
        // 通过 Window scene 打开 id 为 "about" 的窗口
        if let windowScene = NSApp.connectedScenes.first {
            // 使用 SwiftUI 内部机制打开窗口
            // 如果上面 NotificationCenter 方式失败，这里做 fallback
            let userInfo: [String: Any] = ["windowID": "about"]
            NotificationCenter.default.post(
                name: Notification.Name("NSWindowWillOpenNotification"),
                object: nil,
                userInfo: userInfo
            )
        }
    }
}
