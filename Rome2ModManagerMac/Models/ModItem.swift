//
//  ModItem.swift
//  Rome2ModManagerMac
//

import Foundation

/// 表示一个 MOD 的数据模型
struct ModItem: Identifiable, Codable, Equatable, Sendable {
    /// 唯一标识符
    var id = UUID()
    
    /// .pack 文件的完整文件名（例如 "xxx.pack"）
    var packFileName: String
    
    /// 用户自定义的显示名称
    var displayName: String
    
    /// 是否启用（决定是否写入 user.script.txt）
    var isEnabled: Bool
    
    /// 在列表中的加载顺序（0 为最先加载）
    var loadOrder: Int
    
    /// Workshop 的相对路径（用于区分同名 MOD）
    var relativePath: String?
    
    init(
        packFileName: String,
        displayName: String? = nil,
        isEnabled: Bool = true,
        loadOrder: Int = 0,
        relativePath: String? = nil
    ) {
        self.packFileName = packFileName
        self.displayName = displayName ?? packFileName.replacingOccurrences(of: ".pack", with: "")
        self.isEnabled = isEnabled
        self.loadOrder = loadOrder
        self.relativePath = relativePath
    }
    
    /// 生成 user.script.txt 中的一行
    func toScriptLine() -> String {
        let modPath: String
        if let relative = relativePath, !relative.isEmpty {
            modPath = "\"\(relative)/\(packFileName)\""
        } else {
            modPath = "\"\(packFileName)\""
        }
        return "mod \(modPath);"
    }
    
    static func == (lhs: ModItem, rhs: ModItem) -> Bool {
        lhs.id == rhs.id
    }
}
