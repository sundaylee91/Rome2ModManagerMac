//
//  AppInfo.swift
//  Rome2ModManagerMac
//
//  全局常量配置 — 在这里修改作者、版本号、中英文介绍
//

import Foundation

struct AppInfo {
    // MARK: - 基本信息（中英共用）
    static let appName = "Rome II Mod Manager"
    static let version = "1.0.0"
    static let build = "1"

    // MARK: - 作者（在关于窗口中双语显示）
    // 中文
    static let authorCN = "Sunday Lee"
    // English
    static let authorEN = "Sunday Lee"

    // MARK: - 版权信息（双语）
    static let copyrightCN = "版权所有 © 2026 Sunday Lee。保留所有权利。"
    static let copyrightEN = "Copyright © 2026 Sunday Lee. All rights reserved."

    // MARK: - 应用简介（双语）
    // 中文
    static let descriptionCN = "Mac 上的 Total War: Rome II 模组管理器\n快速扫描、管理模组并生成用户脚本。"
    // English
    static let descriptionEN = "A Total War: Rome II mod manager for Mac.\nScan, manage mods and generate user script."
}
