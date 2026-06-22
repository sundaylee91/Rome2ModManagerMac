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
    
    @Published var mods: [ModItem] = []
    @Published var isScanning = false
    @Published var errorMessage: String?
    @Published var toastMessage: String?
    @Published var toastType: ToastType = .info
    @Published var selectedModId: UUID?
    @Published var selectedModImages: [URL] = []
    
    // MARK: - 服务
    
    let fileManager = ModFileManager()
    
    /// 便捷访问本地化管理器
    private var loc: LocalizationManager { LocalizationManager.shared }
    
    // MARK: - 计算属性
    
    var workshopPath: URL? {
        let path = fileManager.getWorkshopPath()
        if FileManager.default.fileExists(atPath: path) {
            return URL(fileURLWithPath: path)
        }
        return nil
    }
    
    var workshopExists: Bool {
        return fileManager.workshopDirectoryExists()
    }
    
    var userScriptPath: String? {
        return fileManager.userScriptExists() ? fileManager.userScriptPath : nil
    }
    
    var enabledCount: Int {
        mods.filter { $0.isEnabled }.count
    }
    
    var disabledCount: Int {
        mods.filter { !$0.isEnabled }.count
    }
    
    var isUsingCustomWorkshopPath: Bool {
        return fileManager.isUsingCustomWorkshopPath
    }
    
    var isUsingCustomUserScriptPath: Bool {
        return fileManager.isUsingCustomUserScriptPath
    }
    
    // MARK: - 路径配置
    
    var customWorkshopPath: String {
        get { AppSettings.shared.customWorkshopPath ?? "" }
        set { AppSettings.shared.customWorkshopPath = newValue }
    }
    
    var customUserScriptPath: String {
        get { AppSettings.shared.customUserScriptPath ?? "" }
        set { AppSettings.shared.customUserScriptPath = newValue }
    }
    
    func resetPathsToDefault() {
        AppSettings.shared.resetAll()
        errorMessage = nil
        showToast(loc.str(.pathsReset), type: .info)
    }
    
    func selectWorkshopPath() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = loc.str(.selectWorkshopPrompt)
        panel.prompt = loc.str(.choose)
        
        if panel.runModal() == .OK, let url = panel.url {
            AppSettings.shared.customWorkshopPath = url.path
            showToast(loc.str(.workshopPathSet(url.lastPathComponent)), type: .success)
        }
    }
    
    func selectUserScriptPath() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.text, .plainText]
        panel.message = loc.str(.selectUserScriptPrompt)
        panel.prompt = loc.str(.choose)
        
        if panel.runModal() == .OK, let url = panel.url {
            AppSettings.shared.customUserScriptPath = url.path
            showToast(loc.str(.userScriptPathSet), type: .success)
        }
    }
    
    // MARK: - 操作
    
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
                    foundMods[i].loadOrder = scriptIndex
                } else {
                    foundMods[i].isEnabled = false
                    foundMods[i].loadOrder = scriptMods.count + i
                }
            }
            
            // 排序：脚本中启用的在前（按脚本顺序），未启用的在后（按文件名）
            foundMods.sort { a, b in
                if a.isEnabled != b.isEnabled {
                    return a.isEnabled
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
                
                if let firstMod = finalMods.first {
                    self.selectedModId = firstMod.id
                    self.selectedModImages = self.fileManager.findImagesInModFolder(relativePath: firstMod.workshopSubfolder)
                } else {
                    self.selectedModId = nil
                    self.selectedModImages = []
                }
                
                if finalMods.isEmpty {
                    if !self.workshopExists {
                        let msg = self.loc.str(.workshopDirNotFound(self.fileManager.getWorkshopPath()))
                        self.errorMessage = msg
                        self.showToast(self.loc.str(.workshopNotFound), type: .error)
                    } else {
                        let msg = self.loc.str(.noPackFiles)
                        self.errorMessage = msg
                        self.showToast(self.loc.str(.noPackFiles), type: .error)
                    }
                } else {
                    self.showToast(self.loc.str(.scanResult(finalMods.count)), type: .success)
                }
            }
        }
    }
    
    func writeUserScript() {
        guard !mods.isEmpty else {
            errorMessage = loc.str(.noModsToSave)
            showToast(loc.str(.noModsToSave), type: .error)
            return
        }
        
        let existingContent = fileManager.readUserScript()
        
        do {
            try fileManager.writeUserScript(mods: mods, preserving: existingContent)
            let count = enabledCount
            errorMessage = nil
            showToast(loc.str(.scriptWritten(count)), type: .success)
        } catch {
            errorMessage = loc.str(.scriptWriteFailed(error.localizedDescription))
            showToast(loc.str(.scriptWriteFailed(error.localizedDescription)), type: .error)
        }
    }
    
    func renameMod(_ mod: ModItem, newName: String) {
        guard !newName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        if let index = mods.firstIndex(where: { $0.id == mod.id }) {
            mods[index].displayName = newName.trimmingCharacters(in: .whitespaces)
            showToast(loc.str(.renameOk(mod.displayName, newName)), type: .success)
        }
    }
    
    func toggleAll() {
        let targetState = enabledCount < mods.count
        for i in mods.indices {
            mods[i].isEnabled = targetState
        }
        if targetState {
            showToast(loc.str(.enabledAll(mods.count)), type: .info)
        } else {
            showToast(loc.str(.disabledAll), type: .info)
        }
    }
    
    /// 拖拽排序：移动 MOD 并更新 loadOrder
    func moveMod(from source: IndexSet, to destination: Int) {
        mods.move(fromOffsets: source, toOffset: destination)
        updateLoadOrder()
        showToast(loc.str(.orderChanged), type: .info)
    }
    
    func updateLoadOrder() {
        for (index, _) in mods.enumerated() {
            mods[index].loadOrder = index
        }
    }
    
    func selectMod(_ modId: UUID?) {
        selectedModId = modId
        if let modId = modId, let mod = mods.first(where: { $0.id == modId }) {
            selectedModImages = fileManager.findImagesInModFolder(relativePath: mod.workshopSubfolder)
        } else {
            selectedModImages = []
        }
    }
    
    func imagesForMod(_ mod: ModItem) -> [URL] {
        return fileManager.findImagesInModFolder(relativePath: mod.workshopSubfolder)
    }
    
    // MARK: - Toast 辅助
    
    func showToast(_ message: String, type: ToastType) {
        toastMessage = message
        toastType = type
        
        let duration: Double = (type == .error) ? 5 : 3
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            if self?.toastMessage == message {
                self?.toastMessage = nil
            }
        }
    }
}
