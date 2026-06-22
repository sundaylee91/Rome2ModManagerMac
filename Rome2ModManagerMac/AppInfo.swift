import Foundation

struct AppInfo {
    static let appName = "Rome II Mod Manager"
    static let version = "1.0.0"       // ⭐ 改版本号
    static let build = "1"             // ⭐ 改 Build 号

    // ═══════════════════════════════════════
    // 只需改这里
    // ═══════════════════════════════════════
    static let authorCN   = "Sunday Lee"
    static let authorEN   = "Sunday Lee"

    static let descriptionCN = "Mac 上的 Total War: Rome II 模组管理器\n快速扫描、管理模组并生成用户脚本。"
    static let descriptionEN = "A Total War: Rome II mod manager for Mac.\nScan, manage mods and generate user script."

    static let copyrightCN = "版权所有 © 2026 Sunday Lee。保留所有权利。"
    static let copyrightEN = "Copyright © 2026 Sunday Lee. All rights reserved."
    // ═══════════════════════════════════════

    // ── 语言检测：跟随软件设置（非系统语言）──
    static var isChinese: Bool {
        LocalizationManager.shared.isChinese
    }

    // ── 根据软件语言设置自动选择 ──
    static var author: String         { isChinese ? authorCN : authorEN }
    static var appDescription: String { isChinese ? descriptionCN : descriptionEN }
    static var copyrightText: String  { isChinese ? copyrightCN : copyrightEN }
}
