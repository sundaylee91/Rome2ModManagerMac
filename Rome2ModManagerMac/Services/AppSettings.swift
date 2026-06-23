//
//  AppSettings.swift
//  Rome2ModManagerMac
//

import Foundation

/// 管理用户自定义设置的持久化存储
final class AppSettings {
    
    static let shared = AppSettings()
    
    private let defaults = UserDefaults.standard
    
    // MARK: - Keys
    
    private enum Keys {
        static let customWorkshopPath = "custom_workshop_path"
        static let customUserScriptPath = "custom_user_script_path"
        static let customGamePath = "custom_game_path"
        static let modDisplayNames = "mod_display_names"
    }
    
    private init() {}
    
    // MARK: - 自定义 Workshop 路径
    
    /// 用户自定义的 Workshop 路径（nil 或空字符串表示使用默认路径）
    var customWorkshopPath: String? {
        get {
            let value = defaults.string(forKey: Keys.customWorkshopPath)
            return (value?.isEmpty == true) ? nil : value
        }
        set {
            if let path = newValue, !path.isEmpty {
                defaults.set(path, forKey: Keys.customWorkshopPath)
            } else {
                defaults.removeObject(forKey: Keys.customWorkshopPath)
            }
        }
    }
    
    // MARK: - 自定义 user.script.txt 路径
    
    /// 用户自定义的 user.script.txt 路径（nil 或空字符串表示使用默认路径）
    var customUserScriptPath: String? {
        get {
            let value = defaults.string(forKey: Keys.customUserScriptPath)
            return (value?.isEmpty == true) ? nil : value
        }
        set {
            if let path = newValue, !path.isEmpty {
                defaults.set(path, forKey: Keys.customUserScriptPath)
            } else {
                defaults.removeObject(forKey: Keys.customUserScriptPath)
            }
        }
    }
    
    // MARK: - 自定义游戏路径
    
    /// 用户自定义的 Rome2.app 路径（nil 或空字符串表示自动检测/Steam）
    var customGamePath: String? {
        get {
            let value = defaults.string(forKey: Keys.customGamePath)
            return (value?.isEmpty == true) ? nil : value
        }
        set {
            if let path = newValue, !path.isEmpty {
                defaults.set(path, forKey: Keys.customGamePath)
            } else {
                defaults.removeObject(forKey: Keys.customGamePath)
            }
        }
    }
    
    // MARK: - MOD 自定义显示名称
    
    /// 持久化存储用户自定义的 MOD 显示名称
    /// Key = "relativePath/packFileName"（如 "2532655874/dei_cn.pack"）
    /// Value = 用户自定义的显示名称
    var modDisplayNames: [String: String] {
        get {
            return defaults.dictionary(forKey: Keys.modDisplayNames) as? [String: String] ?? [:]
        }
        set {
            defaults.set(newValue, forKey: Keys.modDisplayNames)
        }
    }
    
    /// 获取某个 MOD 的自定义显示名称（如果存在）
    func customDisplayName(forPackFileName packFileName: String, relativePath: String?) -> String? {
        let key = makeKey(packFileName: packFileName, relativePath: relativePath)
        return modDisplayNames[key]
    }
    
    /// 保存某个 MOD 的自定义显示名称
    func setCustomDisplayName(_ name: String, forPackFileName packFileName: String, relativePath: String?) {
        let key = makeKey(packFileName: packFileName, relativePath: relativePath)
        var dict = modDisplayNames
        dict[key] = name
        modDisplayNames = dict
    }
    
    /// 删除某个 MOD 的自定义显示名称（恢复默认）
    func removeCustomDisplayName(forPackFileName packFileName: String, relativePath: String?) {
        let key = makeKey(packFileName: packFileName, relativePath: relativePath)
        var dict = modDisplayNames
        dict.removeValue(forKey: key)
        modDisplayNames = dict
    }
    
    /// 清除所有自定义显示名称
    func resetAllDisplayNames() {
        defaults.removeObject(forKey: Keys.modDisplayNames)
    }
    
    // MARK: - 辅助
    
    /// 构造持久化 key：relativePath/packFileName
    /// 若 relativePath 为空则仅用 packFileName
    private func makeKey(packFileName: String, relativePath: String?) -> String {
        if let rp = relativePath, !rp.isEmpty {
            return "\(rp)/\(packFileName)"
        }
        return packFileName
    }
    
    // MARK: - 重置
    
    /// 重置所有自定义路径，恢复默认设置
    func resetAll() {
        defaults.removeObject(forKey: Keys.customWorkshopPath)
        defaults.removeObject(forKey: Keys.customUserScriptPath)
        defaults.removeObject(forKey: Keys.customGamePath)
        defaults.removeObject(forKey: Keys.modDisplayNames)
    }
}
