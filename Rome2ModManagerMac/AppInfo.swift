import Foundation

struct AppInfo {
    static let appName = "Rome2 Mod Manager Mac"
    static let version = "1.0.0"       // ⭐ 改版本号
    static let build = "6"             // ⭐ 改 Build 号

    // ═══════════════════════════════════════
    // 只需改这里
    // ═══════════════════════════════════════
    static let authorCN   = "Sunday Lee"
    static let authorEN   = "Sunday Lee"

    static let descriptionCN = "macOS上的《全面战争:罗马2》专用模组管理器"
    static let descriptionEN = "A Total War: Rome II mod manager for Macos."

    static let copyrightCN = "Copyright © 2026 Sunday Lee\n本软件基于 MIT 开源许可证分发"
    static let copyrightEN = "Copyright © 2026 Sunday Lee\nDistributed under the MIT License."
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
