import SwiftUI

/// MOD 详情面板
/// 左侧列表 + 右侧 info 面板 / 空白占位
struct ModDetailView: View {
    @EnvironmentObject var viewModel: ModViewModel
    @EnvironmentObject private var loc: LocalizationManager

    var body: some View {
        HSplitView {
            // ---- 左侧 MOD 列表 ----
            modListPanel

            // ---- 右侧详情面板 ----
            detailPanel
        }
        .frame(minWidth: 700, minHeight: 400)
        .sheet(isPresented: $viewModel.showRenameSheet) {
            if let mod = viewModel.selectedMod {
                RenameModView(
                    mod: mod,
                    previewImage: viewModel.modPreviewImage[mod.id],
                    onConfirm: { newBaseName in
                        viewModel.commitRename(newName: newBaseName)
                    },
                    onCancel: {
                        viewModel.cancelRename()
                    }
                )
                .environmentObject(loc)
            }
        }
        .onChange(of: viewModel.showRenameSheet) { newValue in
            if !newValue {
                // 用户关闭重命名窗口后确保清理
                viewModel.cancelRename()
            }
        }
        // ---- Toast 覆盖层 ----
        .overlay(alignment: .top) {
            if let toast = viewModel.activeToast {
                ToastBanner(
                    message: toast.message,
                    type: toast.type,
                    onDismiss: { viewModel.dismissToast() }
                )
                .padding(.top, 12)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.activeToast?.message)
    }

    // MARK: - Left Panel (MOD List)

    private var modListPanel: some View {
        VStack(spacing: 0) {
            // 搜索区域
            searchBar

            // MOD 列表
            if viewModel.filteredMods.isEmpty {
                emptyModList
            } else {
                modList
            }

            // 底栏：已启用计数
            enabledCountBar
        }
        .frame(minWidth: 200, idealWidth: 260)
    }

    // MARK: Search

    private var searchBar: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField(loc.t(.searchModsPlaceholder), text: $viewModel.searchText)
                .textFieldStyle(.plain)
                .font(.system(size: 13))
            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(Color.primary.opacity(0.04))
    }

    // MARK: Empty State

    private var emptyModList: some View {
        VStack(spacing: 8) {
            if viewModel.mods.isEmpty {
                Image(systemName: "tray")
                    .font(.system(size: 28))
                    .foregroundColor(.secondary)
                Text(loc.t(.noModsLoaded))
                    .foregroundColor(.secondary)
                    .font(.callout)
            } else {
                Text(loc.t(.noModsMatchSearch))
                    .foregroundColor(.secondary)
                    .font(.callout)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: Mod List

    private var modList: some View {
        List(selection: $viewModel.selectedModId) {
            ForEach(viewModel.filteredMods) { mod in
                ModRowView(
                    mod: mod,
                    isEnabled: viewModel.modEnabledState[mod.id] ?? true,
                    thumbnail: viewModel.modPreviewImage[mod.id],
                    onToggle: { enabled in
                        viewModel.toggleMod(id: mod.id, enabled: enabled)
                    },
                    onRename: {
                        viewModel.renameMod(mod)
                    }
                )
                .tag(mod.id)
                .contextMenu { modContextMenu(for: mod) }
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 220)
    }

    // MARK: Enabled Count Bar

    private var enabledCountBar: some View {
        HStack {
            Text(String(format: loc.t(.enabledCountFormat), viewModel.enabledModCount, viewModel.filteredMods.count))
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(Color.primary.opacity(0.03))
    }

    // MARK: Context Menu

    private func modContextMenu(for mod: Mod) -> some View {
        Group {
            Button {
                viewModel.showInFinder(mod: mod)
            } label: {
                Text(loc.t(.showInFinder))
            }

            Divider()

            Button {
                viewModel.renameMod(mod)
            } label: {
                Text(loc.t(.rename))
            }
        }
    }

    // MARK: - Right Detail Panel

    @ViewBuilder
    private var detailPanel: some View {
        if let mod = viewModel.selectedMod {
            detailContent(for: mod)
                .frame(minWidth: 280, idealWidth: 340, maxWidth: .infinity,
                       minHeight: 400, maxHeight: .infinity)
        } else {
            noSelectionPanel
                .frame(minWidth: 280, idealWidth: 340, maxWidth: .infinity,
                       minHeight: 400, maxHeight: .infinity)
        }
    }

    private var noSelectionPanel: some View {
        VStack(spacing: 10) {
            Image(systemName: "square.grid.3x3.topleft.filled")
                .font(.system(size: 36))
                .foregroundColor(.secondary.opacity(0.6))
            Text(loc.t(.selectModHint))
                .foregroundColor(.secondary)
                .font(.body)
        }
    }

    // MARK: Detail Content

    private func detailContent(for mod: Mod) -> some View {
        ScrollView {
            VStack(spacing: 14) {
                // 大预览图
                modPreviewImage(mod: mod)

                // 文件名
                Text((mod.name as NSString).lastPathComponent)
                    .font(.title3)
                    .multilineTextAlignment(.center)

                // 启用开关
                Toggle(isOn: Binding(
                    get: { viewModel.modEnabledState[mod.id] ?? true },
                    set: { viewModel.toggleMod(id: mod.id, enabled: $0) }
                )) {
                    Text(loc.t(.enableMod))
                        .font(.subheadline)
                }

                Divider()

                // 详细信息
                infoGrid(for: mod)

                Spacer()
            }
            .padding(20)
        }
    }

    // MARK: Mod Preview Image (Detail Panel)

    private func modPreviewImage(mod: Mod) -> some View {
        let size: CGFloat = 300

        return Group {
            if let cached = viewModel.modPreviewImage[mod.id] {
                Image(nsImage: cached)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                    .background(Color.gray.opacity(0.12))
                    .cornerRadius(10)
            } else {
                generateAndCache(mod: mod, size: size)
            }
        }
    }

    @ViewBuilder
    private func generateAndCache(mod: Mod, size: CGFloat) -> some View {
        let format = ModPreviewImage.Format.thumbnail(CGFloat(size))
        Color.gray.opacity(0.12)
            .frame(width: size, height: size)
            .cornerRadius(10)
            .overlay {
                ProgressView()
                    .controlSize(.small)
            }
            .onAppear {
                DispatchQueue.global(qos: .userInitiated).async {
                    if let img = ModPreviewImage.generateAndCache(for: mod, format: format) {
                        DispatchQueue.main.async {
                            viewModel.modPreviewImage[mod.id] = img
                        }
                    }
                }
            }
    }

    // MARK: Info Grid

    private func infoGrid(for mod: Mod) -> some View {
        Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
            GridRow {
                Text(loc.t(.fileSizeLabel))
                    .foregroundColor(.secondary)
                Text(ByteCountFormatter.string(fromByteCount: mod.fileSize, countStyle: .file))
            }
            GridRow {
                Text(loc.t(.modTypeLabel))
                    .foregroundColor(.secondary)
                Text(mod.filePath.lowercased().hasSuffix(".pack") ? "PACK" : loc.t(.unknown))
            }
            GridRow {
                Text(loc.t(.lastModifiedLabel))
                    .foregroundColor(.secondary)
                Text(mod.lastModified.formatted(date: .abbreviated, time: .shortened))
            }
        }
        .font(.callout)
    }
}

// MARK: - ModRowView

struct ModRowView: View {
    let mod: Mod
    let isEnabled: Bool
    let thumbnail: NSImage?
    let onToggle: (Bool) -> Void
    let onRename: () -> Void

    @EnvironmentObject private var loc: LocalizationManager

    private let thumbSize: CGFloat = 35

    var body: some View {
        HStack(spacing: 8) {
            // 缩略图
            if let thumb = thumbnail {
                Image(nsImage: thumb)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: thumbSize, height: thumbSize)
                    .cornerRadius(4)
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: thumbSize, height: thumbSize)
                    .overlay(
                        Image(systemName: "doc")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    )
            }

            // 文件名
            Text(mod.name)
                .font(.system(size: 12))
                .lineLimit(1)
                .truncationMode(.middle)
                .foregroundColor(isEnabled ? .primary : .secondary)

            Spacer()

            // 重命名按钮（悬浮显示）
            Button {
                onRename()
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .opacity(0.4)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    ModDetailView()
        .environmentObject(ModViewModel())
        .environmentObject(LocalizationManager.shared)
}
