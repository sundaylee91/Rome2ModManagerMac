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
    
    // MARK: - 重置
    
    /// 重置所有自定义路径，恢复默认设置
    func resetAll() {
        defaults.removeObject(forKey: Keys.customWorkshopPath)
        defaults.removeObject(forKey: Keys.customUserScriptPath)
        defaults.removeObject(forKey: Keys.customGamePath)
    }
}
