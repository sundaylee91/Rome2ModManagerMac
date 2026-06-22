import Foundation
import Combine
import SwiftUI

/// 应用本地化管理器，支持中英双语
/// 规则：英文系统 → 英文，其他系统（含日文等）→ 中文
/// 用户可在设置中手动切换
final class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    /// 语言偏好：auto / zh / en
    @AppStorage("appLanguage") var appLanguage: String = "auto" {
        didSet { objectWillChange.send() }
    }
    
    /// 当前生效的语言
    var current: String {
        switch appLanguage {
        case "zh": return "zh"
        case "en": return "en"
        default: return detectSystem()
        }
    }
    
    var isChinese: Bool { current == "zh" }
    
    /// 语言显示名称
    var languageName: String {
        switch appLanguage {
        case "zh": return "中文"
        case "en": return "English"
        default: return isChinese ? "中文（跟随系统）" : "English (System)"
        }
    }
    
    private init() {}
    
    /// 检测系统语言：英文 → en，其他 → zh
    private func detectSystem() -> String {
        guard let pref = Locale.preferredLanguages.first else { return "zh" }
        return pref.hasPrefix("en") ? "en" : "zh"
    }
    
    // MARK: - 字符串获取
    
    func str(_ key: L10n) -> String {
        isChinese ? key.zh : key.en
    }
}

// MARK: - 本地化键枚举

enum L10n {
    // App
    case appName
    case scanMods, writeScript, settings, diagnostics, refresh
    case enableAll, disableAll, launchGame
    case file, edit, view, help, window
    
    // 按钮/标签
    case choose, browse, save, cancel, confirm, close, reset, rename, pencil
    case moveUp, moveDown, renameMods
    
    // 状态
    case scanning, loading, noMods, noModsHint
    case scriptFound(String), scriptNotFound
    case workshopConnected, workshopNotFound
    case clickModHint, detailHint
    case modCount(Int)
    case scanResult(Int)
    case enabledAll(Int), disabledAll
    case scriptWritten(Int), scriptWriteFailed(String)
    case renameOk(String, String), renameFail(String)
    case renameAllOk(Int), renameCancelled
    case pathsReset
    case pathSet(String)
    case refreshOk(Int)
    case noModsToSave
    
    // 拖拽排序
    case orderChanged
    
    // MOD 详情
    case fileName, status, loadOrder, folder
    case enabled, disabled
    case loadOrderLabel(Int)
    case previewImages, noPreviewImages, clickToEnlarge
    case loadOrderInfo, loadOrderDesc
    case cannotLoad, cannotLoadImage
    case selectGamePath
    
    // 设置
    case settingsTitle, pathSettings, pathSettingsDesc
    case workshopDir, workshopDirPrompt
    case custom, `default`
    case dirExists, dirNotExists
    case userScriptLabel, userScriptPrompt
    case fileExists, fileNotExists
    case language, languageAuto, languageChinese, languageEnglish
    case resetDefaults
    case workshopPathSet(String)
    case userScriptPathSet
    case openInFinder
    
    // 诊断
    case diagnosticsTitle
    case workshopPath, userScriptPath, scannedPacks
    case notSet, notFound, errorInfo
    case countUnit(Int)
    
    // 对话框
    case renameTitle, renamePrompt, renamePlaceholder
    case selectWorkshopPrompt, selectUserScriptPrompt
    
    // 帮助
    case scanHelp, writeHelp, settingsHelp, diagnosticsHelp
    case renameHelp
    
    // 错误
    case workshopDirNotFound(String)
    case noPackFiles
    case gameLaunched(String)
    case gamePathInvalid
    case workshopPathInvalid
    
    // 确认
    case confirmSaveScript, confirmSaveScriptMsg(Int, Int)
    case confirmRenameAll, confirmRenameAllMsg(Int)
    case renaming
    
    // 游戏路径（新增）
    case gamePath, gamePathPrompt, launchHelp, gamePathSet(String)
    
    // 自动保存
    case autoSavedAndLaunch(Int)
    
    var zh: String {
        switch self {
        case .appName: return "Rome 2 Mod 管理器"
        case .scanMods: return "扫描"
        case .writeScript: return "写入"
        case .settings: return "设置"
        case .diagnostics: return "诊断"
        case .refresh: return "刷新"
        case .enableAll: return "全部启用"
        case .disableAll: return "全部关闭"
        case .launchGame: return "启动游戏"
        case .file: return "文件"
        case .edit: return "编辑"
        case .view: return "显示"
        case .help: return "帮助"
        case .window: return "窗口"
        case .choose: return "选择"
        case .browse: return "浏览..."
        case .save: return "保存"
        case .cancel: return "取消"
        case .confirm: return "确定"
        case .close: return "关闭"
        case .reset: return "恢复"
        case .rename: return "重命名"
        case .pencil: return "编辑"
        case .moveUp: return "上移"
        case .moveDown: return "下移"
        case .renameMods: return "规范化名称"
        case .scanning: return "正在扫描..."
        case .loading: return "加载中..."
        case .noMods: return "暂无 MOD"
        case .noModsHint: return "点击「扫描」或按 ⌘R 加载 MOD 列表"
        case .scriptFound(let p): return "脚本: \(p)"
        case .scriptNotFound: return "未找到 user.script.txt"
        case .workshopConnected: return "Workshop 已连接"
        case .workshopNotFound: return "Workshop 未找到"
        case .clickModHint: return "点击左侧 MOD 查看详情"
        case .detailHint: return "详情包括 MOD 信息和预览图片"
        case .modCount(let n): return "\(n) 个 MOD"
        case .scanResult(let n): return "已扫描到 \(n) 个 MOD"
        case .enabledAll(let n): return "已全部启用（\(n) 个）"
        case .disabledAll: return "已全部关闭"
        case .scriptWritten(let n): return "已写入 \(n) 个启用 MOD 到 user.script.txt"
        case .scriptWriteFailed(let e): return "写入失败: \(e)"
        case .renameOk(_, let n): return "已重命名为「\(n)」"
        case .renameFail(let e): return "重命名失败: \(e)"
        case .renameAllOk(let n): return "已规范化 \(n) 个 MOD 名称"
        case .renameCancelled: return "已取消"
        case .pathsReset: return "已恢复默认路径，请重新扫描"
        case .pathSet(let p): return "已设置路径: \(p)"
        case .refreshOk(let n): return "列表已刷新，共 \(n) 个 MOD"
        case .noModsToSave: return "没有 MOD 可写入"
        case .orderChanged: return "排序已更新"
        case .fileName: return "文件名"
        case .status: return "状态"
        case .loadOrder: return "加载顺序"
        case .folder: return "所在文件夹"
        case .enabled: return "✓ 启用"
        case .disabled: return "✗ 关闭"
        case .loadOrderLabel(let n): return "第 \(n) 位"
        case .previewImages: return "预览图片"
        case .noPreviewImages: return "该 MOD 文件夹中没有预览图片"
        case .clickToEnlarge: return "点击查看大图"
        case .loadOrderInfo: return "MOD 加载顺序说明"
        case .loadOrderDesc: return "列表中的 MOD 按从上到下的顺序加载。拖拽行可调整加载顺序。"
        case .cannotLoad: return "无法加载"
        case .cannotLoadImage: return "无法加载图片"
        case .selectGamePath: return "选择 Rome2.app 或 Rome Remastered.app"
        case .settingsTitle: return "设置"
        case .pathSettings: return "路径设置"
        case .pathSettingsDesc: return "如果默认路径不正确，可以在这里自定义 Workshop 目录和 user.script.txt 文件的位置。留空则使用默认路径。"
        case .workshopDir: return "Workshop 目录"
        case .workshopDirPrompt: return "输入 Workshop 路径或点击「浏览」选择..."
        case .custom: return "自定义"
        case .default: return "默认"
        case .dirExists: return "目录存在"
        case .dirNotExists: return "目录不存在"
        case .userScriptLabel: return "user.script.txt"
        case .userScriptPrompt: return "输入 user.script.txt 路径或点击「浏览」选择..."
        case .fileExists: return "文件存在"
        case .fileNotExists: return "文件不存在（写入时会自动创建）"
        case .language: return "界面语言"
        case .languageAuto: return "跟随系统"
        case .languageChinese: return "中文"
        case .languageEnglish: return "English"
        case .resetDefaults: return "恢复默认路径"
        case .workshopPathSet(let p): return "已设置 Workshop 路径: \(p)，请重新扫描"
        case .userScriptPathSet: return "已设置 user.script.txt 路径"
        case .openInFinder: return "点击在 Finder 中显示"
        case .diagnosticsTitle: return "路径诊断"
        case .workshopPath: return "Workshop 路径"
        case .userScriptPath: return "user.script.txt 路径"
        case .scannedPacks: return "扫描到的 .pack 文件"
        case .notSet: return "未设置"
        case .notFound: return "未找到"
        case .errorInfo: return "错误信息"
        case .countUnit(let n): return "\(n) 个"
        case .renameTitle: return "重命名"
        case .renamePrompt: return "输入 MOD 的新显示名称"
        case .renamePlaceholder: return "新名称"
        case .selectWorkshopPrompt: return "请选择 Steam Workshop 的 Rome 2 MOD 目录 (content/214950)"
        case .selectUserScriptPrompt: return "请选择 user.script.txt 文件"
        case .scanHelp: return "扫描 Workshop MOD 文件夹 (⌘R)"
        case .writeHelp: return "写入 user.script.txt (⌘S)"
        case .settingsHelp: return "设置路径和语言"
        case .diagnosticsHelp: return "路径诊断"
        case .renameHelp: return "重命名 MOD"
        case .workshopDirNotFound(let p): return "Workshop 目录不存在：\(p)"
        case .noPackFiles: return "Workshop 目录未发现 .pack 文件"
        case .gameLaunched(let n): return "游戏已启动：\(n)"
        case .gamePathInvalid: return "游戏路径无效，请在设置中重新选择。"
        case .workshopPathInvalid: return "创意工坊路径无效，请在设置中重新选择。"
        case .confirmSaveScript: return "确认保存脚本"
        case .confirmSaveScriptMsg(let e, let t): return "将保存 \(e)/\(t) 个启用的 MOD 到 user.script.txt，是否继续？"
        case .confirmRenameAll: return "确认批量重命名"
        case .confirmRenameAllMsg(let n): return "将重命名 \(n) 个 MOD 文件为规范化名称（中文转拼音），是否继续？"
        case .renaming: return "重命名中..."
        case .gamePath: return "游戏路径"
        case .gamePathPrompt: return "留空则通过 Steam 启动，或选择 Rome2 .app"
        case .launchHelp: return "启动 Rome 2 Total War"
        case .gamePathSet(let p): return "已设置游戏路径: \(p)"
        case .autoSavedAndLaunch(let n): return "MOD 配置已自动保存（\(n) 个），正在启动游戏..."
        }
    }
    
    var en: String {
        switch self {
        case .appName: return "Rome 2 Mod Manager"
        case .scanMods: return "Scan"
        case .writeScript: return "Write"
        case .settings: return "Settings"
        case .diagnostics: return "Diagnostics"
        case .refresh: return "Refresh"
        case .enableAll: return "Enable All"
        case .disableAll: return "Disable All"
        case .launchGame: return "Launch Game"
        case .file: return "File"
        case .edit: return "Edit"
        case .view: return "View"
        case .help: return "Help"
        case .window: return "Window"
        case .choose: return "Choose"
        case .browse: return "Browse..."
        case .save: return "Save"
        case .cancel: return "Cancel"
        case .confirm: return "OK"
        case .close: return "Close"
        case .reset: return "Reset"
        case .rename: return "Rename"
        case .pencil: return "Edit"
        case .moveUp: return "Move Up"
        case .moveDown: return "Move Down"
        case .renameMods: return "Normalize Names"
        case .scanning: return "Scanning..."
        case .loading: return "Loading..."
        case .noMods: return "No MODs"
        case .noModsHint: return "Click Scan or press ⌘R to load MOD list"
        case .scriptFound(let p): return "Script: \(p)"
        case .scriptNotFound: return "user.script.txt not found"
        case .workshopConnected: return "Workshop Connected"
        case .workshopNotFound: return "Workshop Not Found"
        case .clickModHint: return "Click a MOD on the left to view details"
        case .detailHint: return "Details include MOD info and preview images"
        case .modCount(let n): return "\(n) MODs"
        case .scanResult(let n): return "Scanned \(n) MODs"
        case .enabledAll(let n): return "All \(n) MODs enabled"
        case .disabledAll: return "All MODs disabled"
        case .scriptWritten(let n): return "Wrote \(n) enabled MODs to user.script.txt"
        case .scriptWriteFailed(let e): return "Write failed: \(e)"
        case .renameOk(_, let n): return "Renamed to \"\(n)\""
        case .renameFail(let e): return "Rename failed: \(e)"
        case .renameAllOk(let n): return "Normalized \(n) MOD names"
        case .renameCancelled: return "Cancelled"
        case .pathsReset: return "Paths reset to defaults. Please rescan."
        case .pathSet(let p): return "Path set: \(p)"
        case .refreshOk(let n): return "List refreshed: \(n) MODs total"
        case .noModsToSave: return "No MODs to save"
        case .orderChanged: return "Order updated"
        case .fileName: return "Filename"
        case .status: return "Status"
        case .loadOrder: return "Load Order"
        case .folder: return "Folder"
        case .enabled: return "✓ Enabled"
        case .disabled: return "✗ Disabled"
        case .loadOrderLabel(let n): return "#\(n)"
        case .previewImages: return "Preview Images"
        case .noPreviewImages: return "No preview images in this MOD folder"
        case .clickToEnlarge: return "Click to enlarge"
        case .loadOrderInfo: return "Load Order Info"
        case .loadOrderDesc: return "MODs are loaded from top to bottom. Drag rows to adjust load order."
        case .cannotLoad: return "Cannot load"
        case .cannotLoadImage: return "Cannot load image"
        case .selectGamePath: return "Select Rome2.app or Rome Remastered.app"
        case .settingsTitle: return "Settings"
        case .pathSettings: return "Path Settings"
        case .pathSettingsDesc: return "Customize Workshop directory and user.script.txt file location. Leave blank to use defaults."
        case .workshopDir: return "Workshop Directory"
        case .workshopDirPrompt: return "Enter Workshop path or click Browse..."
        case .custom: return "Custom"
        case .default: return "Default"
        case .dirExists: return "Directory exists"
        case .dirNotExists: return "Directory not found"
        case .userScriptLabel: return "user.script.txt"
        case .userScriptPrompt: return "Enter user.script.txt path or click Browse..."
        case .fileExists: return "File exists"
        case .fileNotExists: return "File not found (will be created on save)"
        case .language: return "Interface Language"
        case .languageAuto: return "Follow System"
        case .languageChinese: return "中文"
        case .languageEnglish: return "English"
        case .resetDefaults: return "Reset to Defaults"
        case .workshopPathSet(let p): return "Workshop path set: \(p). Please rescan."
        case .userScriptPathSet: return "user.script.txt path set"
        case .openInFinder: return "Click to show in Finder"
        case .diagnosticsTitle: return "Path Diagnostics"
        case .workshopPath: return "Workshop Path"
        case .userScriptPath: return "user.script.txt Path"
        case .scannedPacks: return "Scanned .pack Files"
        case .notSet: return "Not Set"
        case .notFound: return "Not Found"
        case .errorInfo: return "Error Info"
        case .countUnit(let n): return "\(n)"
        case .renameTitle: return "Rename"
        case .renamePrompt: return "Enter new display name for this MOD"
        case .renamePlaceholder: return "New Name"
        case .selectWorkshopPrompt: return "Select the Steam Workshop Rome 2 MOD directory (content/214950)"
        case .selectUserScriptPrompt: return "Select the user.script.txt file"
        case .scanHelp: return "Scan Workshop MOD folder (⌘R)"
        case .writeHelp: return "Write to user.script.txt (⌘S)"
        case .settingsHelp: return "Settings & Language"
        case .diagnosticsHelp: return "Path Diagnostics"
        case .renameHelp: return "Rename MOD"
        case .workshopDirNotFound(let p): return "Workshop directory not found: \(p)"
        case .noPackFiles: return "No .pack files found in Workshop directory"
        case .gameLaunched(let n): return "Game launched: \(n)"
        case .gamePathInvalid: return "Game path is invalid. Please reselect in Settings."
        case .workshopPathInvalid: return "Workshop path is invalid. Please reselect in Settings."
        case .confirmSaveScript: return "Confirm Save Script"
        case .confirmSaveScriptMsg(let e, let t): return "Save \(e)/\(t) enabled MODs to user.script.txt?"
        case .confirmRenameAll: return "Confirm Batch Rename"
        case .confirmRenameAllMsg(let n): return "Rename \(n) MOD files to normalized names (Chinese → Pinyin). Continue?"
        case .renaming: return "Renaming..."
        case .gamePath: return "Game Path"
        case .gamePathPrompt: return "Leave blank to launch via Steam, or select Rome2 .app"
        case .launchHelp: return "Launch Rome 2 Total War"
        case .gamePathSet(let p): return "Game path set: \(p)"
        case .autoSavedAndLaunch(let n): return "Auto-saved \(n) MOD(s), launching game..."
        }
    }
}

// MARK: - View 便捷扩展

extension View {
    func loc(_ key: L10n) -> String {
        LocalizationManager.shared.str(key)
    }
}
