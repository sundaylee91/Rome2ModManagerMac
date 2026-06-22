//
//  ModFileManager.swift
//  Rome2ModManagerMac
//

import Foundation
import AppKit

/// 负责扫描 Workshop MOD 和读写 user.script.txt 的文件管理服务
class ModFileManager {
    
    // MARK: - 路径配置
    
    /// 当前使用的 Workshop 路径
    private var workshopPath: String {
        if let custom = AppSettings.shared.customWorkshopPath, !custom.isEmpty {
            return custom
        }
        return defaultWorkshopPath
    }
    
    /// 当前使用的 user.script.txt 路径
    var userScriptPath: String {
        if let custom = AppSettings.shared.customUserScriptPath, !custom.isEmpty {
            return custom
        }
        return defaultUserScriptPath
    }
    
    /// 默认 Workshop 路径
    private let defaultWorkshopPath: String
    
    /// 默认 user.script.txt 路径
    private let defaultUserScriptPath: String
    
    // MARK: - 初始化
    
    init() {
        let homeDir = NSHomeDirectory()
        let appSupport = "\(homeDir)/Library/Application Support"
        
        // Steam Workshop for Rome 2 on macOS
        // 典型路径：~/Library/Application Support/Steam/steamapps/workshop/content/214950/
        let steamWorkshop = "\(appSupport)/Steam/steamapps/workshop/content/214950"
        
        // Rome 2 data 目录（通常在 ~/Library/Application Support/Feral Interactive/Rome 2/）
        let rome2AppData = "\(appSupport)/Feral Interactive/Rome 2"
        
        self.defaultWorkshopPath = steamWorkshop
        self.defaultUserScriptPath = "\(rome2AppData)/data/user.script.txt"
        
        print("📁 ModFileManager 初始化")
        print("   默认 Workshop 路径: \(defaultWorkshopPath)")
        print("   默认 user.script.txt 路径: \(defaultUserScriptPath)")
        if let custom = AppSettings.shared.customWorkshopPath, !custom.isEmpty {
            print("   ⚙️ 自定义 Workshop 路径: \(custom)")
        }
        if let custom = AppSettings.shared.customUserScriptPath, !custom.isEmpty {
            print("   ⚙️ 自定义 user.script.txt 路径: \(custom)")
        }
    }
    
    // MARK: - Workshop 路径
    
    /// 获取 Workshop 根路径
    func getWorkshopPath() -> String {
        return workshopPath
    }
    
    /// 检查 Workshop 目录是否存在
    func workshopDirectoryExists() -> Bool {
        return FileManager.default.fileExists(atPath: workshopPath)
    }
    
    /// 检查 user.script.txt 是否存在
    func userScriptExists() -> Bool {
        return FileManager.default.fileExists(atPath: userScriptPath)
    }
    
    /// 是否使用了自定义路径
    var isUsingCustomWorkshopPath: Bool {
        if let custom = AppSettings.shared.customWorkshopPath, !custom.isEmpty {
            return true
        }
        return false
    }
    
    var isUsingCustomUserScriptPath: Bool {
        if let custom = AppSettings.shared.customUserScriptPath, !custom.isEmpty {
            return true
        }
        return false
    }
    
    // MARK: - 扫描 MOD
    
    /// 支持的文件扩展名（不区分大小写）
    private let supportedExtensions = ["pack", "bin"]
    
    /// 递归扫描 Workshop 目录中的所有 MOD 文件
    /// - Returns: 扫描到的 MOD 列表
    func scanWorkshopMods() -> [ModItem] {
        var mods: [ModItem] = []
        let fileManager = FileManager.default
        
        print("🔍 开始扫描 Workshop 目录...")
        print("   路径: \(workshopPath)")
        
        guard fileManager.fileExists(atPath: workshopPath) else {
            print("⚠️ Workshop 目录不存在: \(workshopPath)")
            return mods
        }
        
        // 先列出 workshop 根目录下有哪些子目录
        if let topLevelContents = try? fileManager.contentsOfDirectory(atPath: workshopPath) {
            print("   Workshop 根目录内容 (\(topLevelContents.count) 项):")
            for item in topLevelContents.prefix(20) {
                var isDir: ObjCBool = false
                let full = "\(workshopPath)/\(item)"
                fileManager.fileExists(atPath: full, isDirectory: &isDir)
                print("     \(isDir.boolValue ? "📁" : "📄") \(item)")
            }
            if topLevelContents.count > 20 {
                print("     ... 还有 \(topLevelContents.count - 20) 项")
            }
        }
        
        // 收集所有找到的文件（用于调试）
        var allFilesFound: [String] = []
        
        // 递归遍历所有子目录（每个 MOD 有自己的数字 ID 文件夹）
        if let enumerator = fileManager.enumerator(atPath: workshopPath) {
            for case let relativePath as String in enumerator {
                let fullPath = "\(workshopPath)/\(relativePath)"
                
                // 记录所有文件用于调试
                allFilesFound.append(relativePath)
                
                // 检查扩展名（不区分大小写）
                let lowercased = relativePath.lowercased()
                let hasValidExtension = supportedExtensions.contains { ext in
                    lowercased.hasSuffix(".\(ext)")
                }
                
                guard hasValidExtension else { continue }
                
                // 检查是否为文件（而非目录）
                var isDirectory: ObjCBool = false
                guard fileManager.fileExists(atPath: fullPath, isDirectory: &isDirectory),
                      !isDirectory.boolValue else {
                    continue
                }
                
                let fileName = (relativePath as NSString).lastPathComponent
                
                // 获取 MOD 所在文件夹名称（通常为数字 ID）
                let parentDir = (relativePath as NSString).deletingLastPathComponent
                
                let mod = ModItem(
                    packFileName: fileName,
                    loadOrder: mods.count,
                    relativePath: parentDir.isEmpty ? nil : parentDir
                )
                
                print("   ✅ 发现 MOD: \(fileName) (路径: \(parentDir))")
                mods.append(mod)
            }
        }
        
        // 如果没有找到 MOD，打印调试信息
        if mods.isEmpty {
            print("⚠️ 未找到 .pack/.bin 文件")
            print("   共遍历了 \(allFilesFound.count) 个文件/目录:")
            for f in allFilesFound.prefix(30) {
                print("     \(f)")
            }
            if allFilesFound.count > 30 {
                print("     ... 还有 \(allFilesFound.count - 30) 项")
            }
        }
        
        // 按文件名排序
        mods.sort { $0.packFileName.localizedStandardCompare($1.packFileName) == .orderedAscending }
        
        // 更新 loadOrder
        for (index, _) in mods.enumerated() {
            mods[index].loadOrder = index
        }
        
        print("✅ 扫描完成：发现 \(mods.count) 个 MOD")
        return mods
    }
    
    // MARK: - 读写 user.script.txt
    
    /// 读取现有的 user.script.txt 内容
    /// - Returns: 文件内容（如不存在返回 nil）
    func readUserScript() -> String? {
        guard userScriptExists() else {
            print("⚠️ user.script.txt 不存在于: \(userScriptPath)")
            return nil
        }
        
        do {
            return try String(contentsOfFile: userScriptPath, encoding: .utf8)
        } catch {
            print("❌ 读取 user.script.txt 失败: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// 将 MOD 列表写入 user.script.txt
    /// - Parameter mods: 要写入的 MOD 列表（仅写入启用的 MOD）
    /// - Parameter existingContent: 现有文件内容中需要保留的非 MOD 行
    func writeUserScript(mods: [ModItem], preserving existingContent: String? = nil) throws {
        // 确保 scripts 目录存在
        let fileManager = FileManager.default
        let scriptsDir = (userScriptPath as NSString).deletingLastPathComponent
        
        if !fileManager.fileExists(atPath: scriptsDir) {
            try fileManager.createDirectory(atPath: scriptsDir, withIntermediateDirectories: true)
            print("📁 创建 scripts 目录: \(scriptsDir)")
        }
        
        var lines: [String] = []
        
        // 文件头注释
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        lines.append("// Rome 2 Mod Manager - user.script.txt")
        lines.append("// 生成时间: \(formatter.string(from: Date()))")
        lines.append("// 本文件由 Rome2ModManagerMac 自动生成")
        lines.append("")
        
        // 保留现有非 mod 行（如果存在）
        if let existing = existingContent {
            let existingLines = existing.components(separatedBy: .newlines)
            for line in existingLines {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if !trimmed.hasPrefix("mod ") && !trimmed.isEmpty && !trimmed.hasPrefix("//") {
                    lines.append(line)
                }
            }
            if lines.count > 4 {
                lines.append("")
            }
        }
        
        // 写入所有启用的 MOD（按 loadOrder 排序）
        let enabledMods = mods
            .filter { $0.isEnabled }
            .sorted { $0.loadOrder < $1.loadOrder }
        
        for mod in enabledMods {
            lines.append(mod.toScriptLine())
        }
        
        let content = lines.joined(separator: "\n") + "\n"
        
        try content.write(toFile: userScriptPath, atomically: true, encoding: .utf8)
        print("✅ 已写入 \(enabledMods.count) 个 MOD 到 user.script.txt")
    }
    
    // MARK: - 辅助功能
    
    /// 打开 Workshop 目录（用于手动管理 MOD）
    func openWorkshopDirectory() {
        NSWorkspace.shared.open(URL(fileURLWithPath: workshopPath))
    }
    
    /// 打开 user.script.txt 所在目录
    func openScriptDirectory() {
        let dir = (userScriptPath as NSString).deletingLastPathComponent
        if FileManager.default.fileExists(atPath: dir) {
            NSWorkspace.shared.open(URL(fileURLWithPath: dir))
        }
    }
}
