//
//  ModFileManager.swift
//  Rome2ModManagerMac
//

import Foundation

/// 负责扫描 Workshop MOD 和读写 user.script.txt 的文件管理服务
class ModFileManager {
    
    // MARK: - 路径配置
    
    /// Rome 2 的数据目录（通常是游戏根目录下的 data 文件夹）
    private let rome2DataPath: String
    
    /// Steam Workshop MOD 文件夹
    private let workshopPath: String
    
    /// user.script.txt 的完整路径
    let userScriptPath: String
    
    /// 脚本目录
    private let scriptsPath: String
    
    // MARK: - 初始化
    
    init() {
        let homeDir = NSHomeDirectory()
        let appSupport = "\(homeDir)/Library/Application Support"
        
        // Steam Workshop for Rome 2 on macOS
        // 典型路径：~/Library/Application Support/Steam/steamapps/workshop/content/214950/
        let steamWorkshop = "\(appSupport)/Steam/steamapps/workshop/content/214950"
        
        // Rome 2 data 目录（通常在游戏 .app 包内或用户数据目录）
        // macOS 上 Rome 2 的数据通常在 ~/Library/Application Support/Feral Interactive/Rome 2/
        let rome2AppData = "\(appSupport)/Feral Interactive/Rome 2"
        
        self.workshopPath = steamWorkshop
        self.rome2DataPath = rome2AppData
        self.scriptsPath = "\(rome2AppData)/data"
        self.userScriptPath = "\(scriptsPath)/user.script.txt"
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
    
    // MARK: - 扫描 MOD
    
    /// 递归扫描 Workshop 目录中的所有 .pack 文件
    /// - Returns: 扫描到的 MOD 列表
    func scanWorkshopMods() -> [ModItem] {
        var mods: [ModItem] = []
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: workshopPath) else {
            print("⚠️ Workshop 目录不存在: \(workshopPath)")
            return mods
        }
        
        // 递归遍历所有子目录（每个 MOD 有自己的数字 ID 文件夹）
        if let enumerator = fileManager.enumerator(atPath: workshopPath) {
            var orderIndex = 0
            
            for case let relativePath as String in enumerator {
                let fullPath = "\(workshopPath)/\(relativePath)"
                
                // 只处理 .pack 文件
                guard relativePath.hasSuffix(".pack") else { continue }
                
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
                    loadOrder: orderIndex,
                    relativePath: parentDir.isEmpty ? nil : parentDir
                )
                
                mods.append(mod)
                orderIndex += 1
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
