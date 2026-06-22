import SwiftUI
import Combine

/// MOD 列表 & 交互中枢
/// 持有所有 MOD 数据，供主界面和重命名窗口共同使用
@MainActor
final class ModViewModel: ObservableObject {

    // MARK: - Published state

    @Published var mods: [Mod] = []
    @Published var filteredMods: [Mod] = []
    @Published var searchText: String = ""

    @Published var selectedModId: UUID?
    @Published var showRenameSheet: Bool = false

    /// 每个 MOD 是否启用（key: mod.id）
    @Published var modEnabledState: [UUID: Bool] = [:]

    /// 已生成的预览图（key: mod.id）；重命名弹窗也复读这个，不再单独生成
    @Published var modPreviewImage: [UUID: NSImage] = [:]

    /// 全局 Toast
    @Published var activeToast: ToastMessage?

    // MARK: - Services

    private let fileManager: ModFileManager
    private let userScriptService = UserScriptService()

    /// 正在做重命名的 MOD（只有非 nil 时表示重命名流程进行中）
    private(set) var renamingMod: Mod?

    // MARK: - Combine

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(fileManager: ModFileManager = ModFileManager()) {
        self.fileManager = fileManager

        // 搜索过滤绑定
        $searchText
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.applyFilter(query: query)
            }
            .store(in: &cancellables)
    }

    // MARK: - Public API

    /// 从 data 目录扫描所有 MOD，并重新加载用户脚本启用状态
    func scanMods() async {
        let discovered = await fileManager.discoverMods()

        // 启动状态：先和用户脚本对齐
        let currentEnabled = userScriptService.loadEnabledModNames()
        let updated = ModEnableService.applyEnabledState(
            mods: discovered,
            previouslyEnabled: currentEnabled
        )

        mods = updated
        applyFilter(query: searchText)

        // 旧预览图全部清掉，重新预热
        modPreviewImage.removeAll()
        modEnabledState.removeAll()
        for mod in updated {
            modEnabledState[mod.id] = (mod.status == .enabled)
        }

        // 后台静默预热全部缩略图
        Task.detached(priority: .background) { [weak self] in
            let format = ModPreviewImage.Format.thumbnail(320)
            for mod in updated {
                if let img = ModPreviewImage.generateAndCache(for: mod, format: format) {
                    await MainActor.run {
                        self?.modPreviewImage[mod.id] = img
                    }
                }
            }
        }
    }

    /// 切换 MOD 启用 / 禁用
    func toggleMod(id: UUID, enabled: Bool) {
        guard let idx = mods.firstIndex(where: { $0.id == id }) else { return }

        mods[idx].status = enabled ? .enabled : .disabled
        modEnabledState[id] = enabled

        applyFilter(query: searchText)
        persistEnabledState()
    }

    /// 切换全部 MOD 启用 / 禁用
    func toggleAllMods(enabled: Bool) {
        for i in mods.indices {
            mods[i].status = enabled ? .enabled : .disabled
            modEnabledState[mods[i].id] = enabled
        }
        applyFilter(query: searchText)
        persistEnabledState()

        let msg = enabled ? L10n.allModsEnabled : L10n.allModsDisabled
        activeToast = ToastMessage(message: msg, type: .success)
    }

    /// 在 Finder 中定位 MOD 文件
    func showInFinder(mod: Mod) {
        NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: mod.filePath)])
    }

    // MARK: - Rename flow

    /// 进入重命名流程（弹出 sheet）
    func renameMod(_ mod: Mod) {
        renamingMod = mod
        showRenameSheet = true
    }

    /// 用户确认重命名 → 在磁盘上改名 + 刷新
    func commitRename(newName: String) {
        guard let mod = renamingMod else { return }

        let baseName = (mod.name as NSString).deletingPathExtension
        guard !newName.isEmpty, newName != baseName else {
            showRenameSheet = false
            renamingMod = nil
            return
        }

        let newFileName = newName + "." + (mod.name as NSString).pathExtension

        do {
            try fileManager.renameMod(mod: mod, to: newFileName)
            showRenameSheet = false
            renamingMod = nil
            activeToast = ToastMessage(
                message: String(format: L10n.renameSuccess, newFileName),
                type: .success
            )
            Task { await scanMods() }
        } catch {
            showRenameSheet = false
            renamingMod = nil
            activeToast = ToastMessage(
                message: String(format: L10n.renameFailed, error.localizedDescription),
                type: .error
            )
        }
    }

    /// 取消重命名
    func cancelRename() {
        renamingMod = nil
        if showRenameSheet {
            showRenameSheet = false
        }
    }

    // MARK: Toast

    func dismissToast() {
        activeToast = nil
    }

    // MARK: - Private helpers

    /// 根据搜索文本过滤 MOD
    private func applyFilter(query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            filteredMods = mods
            return
        }
        filteredMods = mods.filter { mod in
            mod.name.localizedCaseInsensitiveContains(trimmed)
        }
    }

    /// 将当前启用/禁用状态写入 UserScript
    private func persistEnabledState() {
        let names = mods
            .filter { $0.status == .enabled }
            .map { $0.name }

        let ok = userScriptService.writeUserScriptSilently(modNames: names)
        if !ok {
            activeToast = ToastMessage(message: L10n.userScriptUpdateFailed, type: .error)
        }
    }

    /// 当前列表中已启用 MOD 的数量
    var enabledModCount: Int {
        mods.filter { $0.status == .enabled }.count
    }
}

// MARK: - Toast model

struct ToastMessage: Equatable {
    enum ToastType: Equatable {
        case success
        case error
        case info
    }

    let message: String
    let type: ToastType
}
