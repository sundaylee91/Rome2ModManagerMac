import Foundation
import Combine
import SwiftUI

/// 应用本地化管理器，支持中英双语
/// 规则：英文系统 → 英文，其他系统（含日文等）→ 中文
/// 用户可在设置中手动切换
final class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @AppStorage("appLanguage") var appLanguage: String = "auto" {
        didSet { objectWillChange.send() }
    }
    
    var current: String {
        switch appLanguage {
        case "zh": return "zh"
        case "en": return "en"
        default: return detectSystem()
        }
    }
    
    var isChinese: Bool { current == "zh" }
    
    var languageName: String {
        switch appLanguage {
        case "zh": return "中文"
        case "en": return "English"
        default: return isChinese ? "中文（跟随系统）" : "English (System)"
        }
    }
    
    private init() {}
    
    private func detectSystem() -> String {
        guard let pref = Locale.preferredLanguages.first else { return "zh" }
        return pref.hasPrefix("en") ? "en" : "zh"
    }
    
    func str(_ key: L10n) -> String {
        isChinese ? key.zh : key.en
    }
}

enum L10n {
    case appName
    case scanMods, writeScript, settings, diagnostics, refresh
    case enableAll, disableAll, launchGame
    case file, edit, view, help, window
    case choose, browse, save, cancel, confirm, close, reset, rename, pencil
    case moveUp, moveDown, renameMods
    case confirmRename, renameMod
    case showInFinder
    case scanning, loading, noMods, noModsHint, noModsLoaded, noModsMatchSearch
    case scriptFound(String), scriptNotFound
    case workshopConnected, workshopNotFound
    case clickModHint, detailHint, selectModHint
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
    case orderChanged
    case fileName, status, loadOrder, folder
    case enabled, disabled
    case enableMod
    case loadOrderLabel(Int)
    case previewImages, noPreviewImages, noPreviewAvailable, clickToEnlarge
    case loadOrderInfo, loadOrderDesc
    case cannotLoad, cannotLoadImage
    case selectGamePath
    case fileSizeLabel, modTypeLabel, lastModifiedLabel, unknown
    case currentNameLabel, enterNewFileName
    case searchModsPlaceholder
    case enabledCountFormat
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
    case diagnosticsTitle
    case workshopPath, userScriptPath, scannedPacks
    case notSet, notFound, errorInfo
    case countUnit(Int)
    case renameTitle, renamePrompt, renamePlaceholder
    case selectWorkshopPrompt, selectUserScriptPrompt
    case scanHelp, writeHelp, settingsHelp, diagnosticsHelp
    case renameHelp
    case workshopDirNotFound(String)
    case noPackFiles
    case gameLaunched(String)
    case gamePathInvalid
    case workshopPathInvalid
    case confirmSaveScript, confirmSaveScriptMsg(Int, Int)
    case confirmRenameAll, confirmRenameAllMsg(Int)
    case renaming
    case gamePath, gamePathPrompt, launchHelp, gamePathSet(String)
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
        case .confirmRename: return "确认重命名"
        case .renameMod: return "重命名 MOD"
        case .showInFinder: return "在 Finder 中显示"
        case .scanning: return "正在扫描..."
        case .loading: return "加载中..."
        case .noMods: return "暂无 MOD"
        case .noModsHint: return "点击「扫描」或按 ⌘R 加载 MOD 列表"
        case .noModsLoaded: return "暂无 MOD\n点击工具栏「扫描」加载"
        case .noModsMatchSearch: return "没有匹配的 MOD"
        case .scriptFound(let p): return "脚本: \(p)"
        case .scriptNotFound: return "未找到 user.script.txt"
        case .workshopConnected: return "Workshop 已连接"
        case .workshopNotFound: return "Workshop 未找到"
        case .clickModHint: return "点击左侧 MOD 查看详情"
        case .detailHint: return "详情包括 MOD 信息和预览图片"
        case .selectModHint: return "从左侧列表选择一个 MOD 查看详情"
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
        case .enableMod: return "启用此 MOD"
        case .loadOrderLabel(let n): return "第 \(n) 位"
        case .previewImages: return "预览图片"
        case .noPreviewImages: return "该 MOD 文件夹中没有预览图片"
        case .noPreviewAvailable: return "暂无预览图"
        case .clickToEnlarge: return "点击查看大图"
        case .loadOrderInfo: return "MOD 加载顺序说明"
        case .loadOrderDesc: return "列表中的 MOD 按从上到下的顺序加载。拖拽行可调整加载顺序。"
        case .cannotLoad: return "无法加载"
        case .cannotLoadImage: return "无法加载图片"
        case .selectGamePath: return "选择 Rome2.app 或 Rome Remastered.app"
        case .fileSizeLabel: return "文件大小"
        case .modTypeLabel: return "MOD 类型"
        case .lastModifiedLabel: return "最后修改"
        case .unknown: return "未知"
        case .currentNameLabel: return "当前文件名:"
        case .enterNewFileName: return "输入新文件名（不含扩展名）"
        case .searchModsPlaceholder: return "搜索 MOD..."
        case .enabledCountFormat: return "已启用 %d / %d"
        case .settingsTitle: return "设置"
        case .pathSettings: return "路径设置"
        case .pathSettingsDesc: return "如果默认路径不正确，可自定义 Workshop 目录和 user.script.txt 位置。留空则使用默认路径。"
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
        case .confirmRename: return "Confirm Rename"
        case .renameMod: return "Rename MOD"
        case .showInFinder: return "Show in Finder"
        case .scanning: return "Scanning..."
        case .loading: return "Loading..."
        case .noMods: return "No MODs"
        case .noModsHint: return "Click Scan or press ⌘R to load MOD list"
        case .noModsLoaded: return "No MODs loaded\nClick Scan in toolbar"
        case .noModsMatchSearch: return "No MODs match search"
        case .scriptFound(let p): return "Script: \(p)"
        case .scriptNotFound: return "user.script.txt not found"
        case .workshopConnected: return "Workshop Connected"
        case .workshopNotFound: return "Workshop Not Found"
        case .clickModHint: return "Click a MOD on the left to view details"
        case .detailHint: return "Details include MOD info and preview images"
        case .selectModHint: return "Select a MOD from the list to view details"
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
        case .enableMod: return "Enable this MOD"
        case .loadOrderLabel(let n): return "#\(n)"
        case .previewImages: return "Preview Images"
        case .noPreviewImages: return "No preview images in this MOD folder"
        case .noPreviewAvailable: return "No preview available"
        case .clickToEnlarge: return "Click to enlarge"
        case .loadOrderInfo: return "Load Order Info"
        case .loadOrderDesc: return "MODs are loaded from top to bottom. Drag rows to adjust load order."
        case .cannotLoad: return "Cannot load"
        case .cannotLoadImage: return "Cannot load image"
        case .selectGamePath: return "Select Rome2.app or Rome Remastered.app"
        case .fileSizeLabel: return "File Size"
        case .modTypeLabel: return "MOD Type"
        case .lastModifiedLabel: return "Last Modified"
        case .unknown: return "Unknown"
        case .currentNameLabel: return "Current filename:"
        case .enterNewFileName: return "Enter new filename (without extension)"
        case .searchModsPlaceholder: return "Search MODs..."
        case .enabledCountFormat: return "%d / %d enabled"
        case .settingsTitle: return "Settings"
        case .pathSettings: return "Path Settings"
        case .pathSettingsDesc: return "Customize Workshop directory and user.script.txt location. Leave blank to use defaults."
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

extension View {
    func loc(_ key: L10n) -> String {
        LocalizationManager.shared.str(key)
    }
}
