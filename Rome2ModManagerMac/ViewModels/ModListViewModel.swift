//
//  ModListViewModel.swift
//  Rome2ModManagerMac
//

import Foundation
import SwiftUI

/// MOD 列表的视图模型，管理状态与操作
class ModListViewModel: ObservableObject {
    
    // MARK: - 发布的状态属性
    
    /// MOD 列表
    @Published var mods: [ModItem] = []
    
    /// 是否正在扫描
    @Published var isScanning = false
    
    /// 错误信息
    @Published var errorMessage: String?
    
    /// 操作提示信息
    @Published var toastMessage: String?
    
    // MARK: - 服务
    
    private let fileManager = ModFileManager()
    
    // MARK: - 计算属性
    
    /// Workshop 路径
    var workshopPath: URL? {
        let path = fileManager.getWorkshopPath()
        if FileManager.default.fileExists(atPath: path) {
            return URL(fileURLWithPath: path)
        }
        return nil
    }
    
    /// Workshop 目录是否存在
    var workshopExists: Bool {
        return fileManager.workshopDirectoryExists()
    }
    
    /// user.script.txt 路径
    var userScriptPath: String? {
        return fileManager.userScriptExists() ? fileManager.userScriptPath : nil
    }
    
    /// 启用的 MOD 数量
    var enabledCount: Int {
        mods.filter { $0.isEnabled }.count
    }
    
    /// 禁用的 MOD 数量
    var disabledCount: Int {
        mods.filter { !$0.isEnabled }.count
    }
    
    // MARK: - 操作
    
    /// 扫描 Workshop MOD
    func scanMods() {
        isScanning = true
        errorMessage = nil
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let foundMods = self.fileManager.scanWorkshopMods()
            
            DispatchQueue.main.async {
                self.mods = foundMods
                self.isScanning = false
                
                if foundMods.isEmpty {
                    if !self.workshopExists {
                        self.errorMessage = "Workshop 目录不存在：\(self.fileManager.getWorkshopPath())"
                    } else {
                        self.errorMessage = "Workshop 目录未发现 .pack 文件"
                    }
                } else {
                    self.toastMessage = "已扫描到 \(foundMods.count) 个 MOD"
                    self.clearToastAfterDelay()
                }
            }
        }
    }
    
    /// 写入 user.script.txt
    func writeUserScript() {
        guard !mods.isEmpty else {
            errorMessage = "没有 MOD 可写入"
            return
        }
        
        let existingContent = fileManager.readUserScript()
        
        do {
            try fileManager.writeUserScript(mods: mods, preserving: existingContent)
            toastMessage = "已写入 \(enabledCount) 个启用 MOD 到 user.script.txt"
            errorMessage = nil
            clearToastAfterDelay()
        } catch {
            errorMessage = "写入失败: \(error.localizedDescription)"
        }
    }
    
    /// 重命名 MOD
    func renameMod(_ mod: ModItem, newName: String) {
        guard !newName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        if let index = mods.firstIndex(where: { $0.id == mod.id }) {
            mods[index].displayName = newName.trimmingCharacters(in: .whitespaces)
        }
    }
    
    /// 切换全部启用/禁用
    func toggleAll() {
        let targetState = enabledCount < mods.count
        for i in mods.indices {
            mods[i].isEnabled = targetState
        }
    }
    
    /// 更新加载顺序（通过拖拽）
    func updateLoadOrder() {
        for (index, _) in mods.enumerated() {
            mods[index].loadOrder = index
        }
    }
    
    // MARK: - 辅助
    
    private func clearToastAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.toastMessage = nil
        }
    }
}
