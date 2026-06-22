//
//  ModListViewModel.swift
//  Rome2ModManagerMac
//

import Foundation
import Combine
import SwiftUI
import UniformTypeIdentifiers

/// 提示类型枚举
enum ToastType {
    case success
    case error
    case info
    
    var color: Color {
        switch self {
        case .success: return .green
        case .error: return .red
        case .info: return .blue
        }
    }
    
    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .info: return "info.circle.fill"
        }
    }
}

/// MOD 列表的视图模型，管理状态与操作
final class ModListViewModel: ObservableObject {
    
    // MARK: - 发布的状态属性
    
    /// MOD 列表
    @Published var mods: [ModItem] = []
    
    /// 是否正在扫描
    @Published var isScanning = false
    
    /// 错误信息（持久显示）
    @Published var errorMessage: String?
    
    /// 操作提示信息
    @Published var toastMessage: String?
    
    /// 提示类型
    @Published var toastType: ToastType = .info
    
    /// 当前选中的 MOD ID
    @Published var selectedModId: UUID?
    
    /// 选中 MOD 的图片列表
    @Published var selectedModImages: [URL] = []
    
    // MARK: - 服务
    
    let fileManager = ModFileManager()
    
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
    
    /// 是否使用了自定义 Workshop 路径
    var isUsingCustomWorkshopPath: Bool {
        return fileManager.isUsingCustomWorkshopPath
    }
    
    /// 是否使用了自定义 user.script.txt 路径
    var isUsingCustomUserScriptPath: Bool {
        return fileManager.isUsingCustomUserScriptPath
    }
    
    // MARK: - 路径配置
    
    /// 自定义 Workshop 路径
    var customWorkshopPath: String {
        get { AppSettings.shared.customWorkshopPath ?? "" }
        set { AppSettings.shared.customWorkshopPath = newValue }
    }
    
    /// 自定义 user.script.txt 路径
    var customUserScriptPath: String {
        get { AppSettings.shared.customUserScriptPath ?? "" }
        set { AppSettings.shared.customUserScriptPath = newValue }
    }
    
    /// 重置为默认路径
    func resetPathsToDefault() {
        AppSettings.shared.resetAll()
        errorMessage = nil
        showToast("已恢复默认路径，请重新扫描", type: .info)
    }
    
    /// 从 NSOpenPanel 选择 Workshop 目录
    func selectWorkshopPath() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = "请选择 Steam Workshop 的 Rome 2 MOD 目录 (content/214950)"
        panel.prompt = "选择"
        
        if panel.runModal() == .OK, let url = panel.url {
            AppSettings.shared.customWorkshopPath = url.path
            showToast("已设置 Workshop 路径: \(url.lastPathComponent)，请重新扫描", type: .success)
        }
    }
    
    /// 从 NSOpenPanel 选择 user.script.txt 文件
    func selectUserScriptPath() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.text, .plainText]
        panel.message = "请选择 user.script.txt 文件"
        panel.prompt = "选择"
        
        if panel.runModal() == .OK, let url = panel.url {
            AppSettings.shared.customUserScriptPath = url.path
            showToast("已设置 user.script.txt 路径", type: .success)
        }
    }
    
    // MARK: - 操作
    
    /// 扫描 Workshop MOD
    func scanMods() {
        isScanning = true
        errorMessage = nil
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            var foundMods = self.fileManager.scanWorkshopMods()
            let scriptMods = self.fileManager.parseUserScript()
            
            // 根据 user.script.txt 设置启用状态和排序权重
            for i in 0..<foundMods.count {
                if let scriptIndex = scriptMods.firstIndex(of: foundMods[i].packFileName) {
                    foundMods[i].isEnabled = true
                    foundMods[i].loadOrder = scriptIndex  // 临时用作排序权重
                } else {
                    foundMods[i].isEnabled = false
                    foundMods[i].loadOrder = scriptMods.count + i  // 脚本中没有的排在后面
                }
            }
            
            // 排序：脚本中启用的在前（按脚本顺序），未启用的在后（按文件名）
            foundMods.sort { a, b in
                if a.isEnabled != b.isEnabled {
                    return a.isEnabled  // 启用的在前
                }
                if a.isEnabled {
                    return a.loadOrder < b.loadOrder
                }
                return a.packFileName.localizedStandardCompare(b.packFileName) == .orderedAscending
            }
            
            // 更新最终 loadOrder
            for (index, _) in foundMods.enumerated() {
                foundMods[index].loadOrder = index
            }
            
            let finalMods = foundMods
            
            DispatchQueue.main.async {
                self.mods = finalMods
                self.isScanning = false
                
                // 扫描完成后自动选中第一个 MOD（让右侧面板立即有内容，窗口形态正常）
                if let firstMod = finalMods.first {
                    self.selectedModId = firstMod.id
                    self.selectedModImages = self.fileManager.findImagesInModFolder(relativePath: firstMod.workshopSubfolder)
                } else {
                    self.selectedModId = nil
                    self.selectedModImages = []
                }
                
                if finalMods.isEmpty {
                    if !self.workshopExists {
                        let msg = "Workshop 目录不存在：\(self.fileManager.getWorkshopPath())"
                        self.errorMessage = msg
                        self.showToast("Workshop 目录不存在", type: .error)
                    } else {
                        let msg = "Workshop 目录未发现 .pack 文件"
                        self.errorMessage = msg
                        self.showToast("未发现 MOD 文件", type: .error)
                    }
                } else {
                    self.showToast("已扫描到 \(finalMods.count) 个 MOD", type: .success)
                }
            }
        }
    }
    
    /// 写入 user.script.txt
    func writeUserScript() {
        guard !mods.isEmpty else {
            errorMessage = "没有 MOD 可写入"
            showToast("没有 MOD 可写入", type: .error)
            return
        }
        
        let existingContent = fileManager.readUserScript()
        
        do {
            try fileManager.writeUserScript(mods: mods, preserving: existingContent)
            let count = enabledCount
            errorMessage = nil
            showToast("已写入 \(count) 个启用 MOD 到 user.script.txt", type: .success)
        } catch {
            errorMessage = "写入失败: \(error.localizedDescription)"
            showToast("写入失败: \(error.localizedDescription)", type: .error)
        }
    }
    
    /// 重命名 MOD
    func renameMod(_ mod: ModItem, newName: String) {
        guard !newName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        if let index = mods.firstIndex(where: { $0.id == mod.id }) {
            mods[index].displayName = newName.trimmingCharacters(in: .whitespaces)
            showToast("已重命名为「\(newName)」", type: .success)
        }
    }
    
    /// 切换全部启用/禁用
    func toggleAll() {
        let targetState = enabledCount < mods.count
        for i in mods.indices {
            mods[i].isEnabled = targetState
        }
        showToast(targetState ? "已全部启用" : "已全部禁用", type: .info)
    }
    
    /// 更新加载顺序（通过拖拽）
    func updateLoadOrder() {
        for (index, _) in mods.enumerated() {
            mods[index].loadOrder = index
        }
    }
    
    /// 选中 MOD 并加载其图片
    func selectMod(_ modId: UUID?) {
        selectedModId = modId
        if let modId = modId, let mod = mods.first(where: { $0.id == modId }) {
            selectedModImages = fileManager.findImagesInModFolder(relativePath: mod.workshopSubfolder)
        } else {
            selectedModImages = []
        }
    }
    
    /// 获取指定 MOD 的图片（供外部调用）
    func imagesForMod(_ mod: ModItem) -> [URL] {
        return fileManager.findImagesInModFolder(relativePath: mod.workshopSubfolder)
    }
    
    // MARK: - Toast 辅助
    
    /// 显示提示横幅
    private func showToast(_ message: String, type: ToastType) {
        toastMessage = message
        toastType = type
        
        // 错误消息显示更久
        let duration: Double = (type == .error) ? 5 : 3
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            if self?.toastMessage == message {
                self?.toastMessage = nil
            }
        }
    }
}
