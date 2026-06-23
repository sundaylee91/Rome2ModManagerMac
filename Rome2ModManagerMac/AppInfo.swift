import Foundation

struct AppInfo {
    static let appName = "Rome2 Mod Manager Mac"
    static let version = "1.0.0"       // ⭐ 改版本号
    static let build = "1"             // ⭐ 改 Build 号

    // ═══════════════════════════════════════
    // 只需改这里
    // ═══════════════════════════════════════
    static let authorCN   = "Sunday Lee"
    static let authorEN   = "Sunday Lee"

    static let descriptionCN = "Mac 上的 Total War: Rome II 模组管理器。"
    static let descriptionEN = "A Total War: Rome II mod manager for Mac."

    static let copyrightCN = "2026 MIT License\nhttps://github.com/sundaylee91/Rome2ModManagerMac"
    static let copyrightEN = "2026 MIT License\nhttps://github.com/sundaylee91/Rome2ModManagerMac"
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
