//
//  Rome2ModManagerMacApp.swift
//  Rome2ModManagerMac
//
//  Created by 李拜天 on 2026/6/22.
//

import SwiftUI
import AppKit

@main
struct Rome2ModManagerMacApp: App {
    @StateObject private var viewModel = ModListViewModel()
    @StateObject private var locManager = LocalizationManager.shared
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
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
            // 移除 "New Window" 菜单项
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

// MARK: - AppDelegate：运行时中文化标准菜单栏

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        localizeMainMenu()
        
        // 监听语言切换，实时更新菜单栏
        NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            self.localizeMainMenu()
        }
    }
    
    /// 遍历主菜单栏，将标准 macOS 菜单标题替换为中文
    private func localizeMainMenu() {
        let loc = LocalizationManager.shared
        
        // 顶层菜单标题映射
        let topLevelMap: [String: String] = [
            loc.str(.file):    "文件",
            loc.str(.edit):    "编辑",
            loc.str(.view):    "显示",
            loc.str(.window):  "窗口",
            loc.str(.help):    "帮助",
            // 同时覆盖英文原文（首次启动时可能还是英文）
            "File":            "文件",
            "Edit":            "编辑",
            "View":            "显示",
            "Window":          "窗口",
            "Help":            "帮助",
        ]
        
        // 子菜单项映射
        let subMenuMap: [String: String] = [
            "About Rome2ModManagerMac": "关于 Rome 2 Mod 管理器",
            "Preferences…":             "偏好设置…",
            "Settings…":                 "设置…",
            "Quit Rome2ModManagerMac":   "退出 Rome 2 Mod 管理器",
            "Hide Rome2ModManagerMac":   "隐藏 Rome 2 Mod 管理器",
            "Hide Others":               "隐藏其他",
            "Show All":                  "全部显示",
            "Close":                     "关闭",
            "Close Window":              "关闭窗口",
            "Minimize":                  "最小化",
            "Zoom":                      "缩放",
            "Enter Full Screen":         "进入全屏",
            "Exit Full Screen":          "退出全屏",
            "Bring All to Front":        "全部前置",
            "Tile Window to Left of Screen":   "将窗口贴到屏幕左侧",
            "Tile Window to Right of Screen":  "将窗口贴到屏幕右侧",
            "Show Tab Bar":              "显示标签栏",
            "Show All Tabs":             "显示所有标签",
            "Show Path Bar":             "显示路径栏",
            "Show Status Bar":           "显示状态栏",
            "Hide Toolbar":              "隐藏工具栏",
            "Show Toolbar":              "显示工具栏",
            "Customize Toolbar…":        "自定义工具栏…",
            "Show Sidebar":              "显示侧边栏",
            "Hide Sidebar":              "隐藏侧边栏",
            "Enter Full Screen":         "进入全屏",
            "Show Help Topics":          "显示帮助主题",
            "Rome2ModManagerMac Help":   "Rome 2 Mod 管理器 帮助",
            "Undo":                      "撤销",
            "Redo":                      "重做",
            "Cut":                       "剪切",
            "Copy":                      "复制",
            "Paste":                     "粘贴",
            "Paste and Match Style":     "粘贴并匹配样式",
            "Delete":                    "删除",
            "Select All":                "全选",
            "Find":                      "查找",
            "Find and Replace…":         "查找和替换…",
            "Find Next":                 "查找下一个",
            "Find Previous":             "查找上一个",
            "Use Selection for Find":    "用所选内容查找",
            "Jump to Selection":         "跳转到所选内容",
            "Spelling and Grammar":      "拼写和语法",
            "Show Spelling and Grammar": "显示拼写和语法",
            "Check Document Now":        "立即检查文稿",
            "Check Spelling While Typing": "键入时检查拼写",
            "Check Grammar With Spelling": "检查拼写和语法",
            "Correct Spelling Automatically": "自动纠正拼写",
            "Substitutions":             "替换",
            "Show Substitutions":        "显示替换",
            "Smart Copy/Paste":          "智能拷贝/粘贴",
            "Smart Quotes":              "智能引号",
            "Smart Dashes":              "智能破折号",
            "Smart Links":               "智能链接",
            "Text Replacement":          "文本替换",
            "Data Detectors":            "数据检测器",
            "Transformations":           "变换",
            "Make Upper Case":           "转为大写",
            "Make Lower Case":           "转为小写",
            "Capitalize":                "首字母大写",
            "Speech":                    "语音",
            "Start Speaking":            "开始朗读",
            "Stop Speaking":             "停止朗读",
        ]
        
        // 仅在中文环境下执行
        guard loc.isChinese else { return }
        
        guard let mainMenu = NSApp.mainMenu else { return }
        
        func localizeMenu(_ menu: NSMenu) {
            for item in menu.items {
                // 处理分隔线
                guard !item.isSeparatorItem else { continue }
                
                let title = item.title
                
                // 如果没有标题，跳过
                if title.isEmpty { 
                    if let sub = item.submenu { localizeMenu(sub) }
                    continue 
                }
                
                // 尝试匹配映射
                if let localized = subMenuMap[title] {
                    item.title = localized
                }
                
                // 递归处理子菜单
                if let sub = item.submenu {
                    localizeMenu(sub)
                }
            }
        }
        
        for item in mainMenu.items {
            guard !item.isSeparatorItem else { continue }
            
            let title = item.title
            
            // 先更新子菜单内容
            if let sub = item.submenu {
                localizeMenu(sub)
            }
            
            // 再更新顶层菜单标题（subMenuMap 中可能已有对应项）
            if let localized = topLevelMap[title] {
                item.title = localized
            }
        }
    }
}
