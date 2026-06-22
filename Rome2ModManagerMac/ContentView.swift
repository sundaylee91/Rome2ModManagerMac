//
//  ContentView.swift
//  Rome2ModManagerMac
//
//  Created by 李拜天 on 2026/6/22.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject var viewModel: ModListViewModel
    @EnvironmentObject var loc: LocalizationManager
    @State private var showSettings = false
    @State private var showRenameSheet = false
    @State private var renameText = ""
    @State private var renamingMod: ModItem?
    @State private var renamingModImages: [URL] = []
    @State private var renamePreviewImages: [NSImage] = []
    @State private var selectedModImages: [URL] = []
    @State private var renameSheetId = UUID()

    var body: some View {
        ZStack {
            HSplitView {
                // 左侧：MOD 列表
                VStack(spacing: 0) {
                    // 工具栏 — 极简风格：仅启动游戏 + 设置
                    HStack {
                        Button(action: { launchGame() }) {
                            Label(loc.str(.launchGame), systemImage: "play.fill")
                        }
                        .help(loc.str(.launchHelp))
                        .keyboardShortcut(.return, modifiers: [.command])
                        .focusEffectDisabled()
                        .focusable(false)

                        Button(action: { showSettings = true }) {
                            Label(loc.str(.settings), systemImage: "gearshape")
                        }
                        .help(loc.str(.settingsHelp))
                        .focusEffectDisabled()
                        .focusable(false)

                        Spacer()

                        if viewModel.isScanning {
                            ProgressView()
                                .scaleEffect(0.7)
                                .frame(width: 20, height: 20)
                        }

                        Text(loc.str(.modCount(viewModel.mods.count)))
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(NSColor.controlBackgroundColor).opacity(0.5))

                    Divider()

                    // MOD 列表 (带拖拽排序)
                    if viewModel.mods.isEmpty && !viewModel.isScanning {
                        VStack(spacing: 16) {
                            Image(systemName: "tray")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            Text(loc.str(.noMods))
                                .font(.title3)
                                .foregroundColor(.secondary)
                            Text(loc.str(.noModsHint))
                                .font(.caption)
                                .foregroundColor(.secondary)

                            if let error = viewModel.errorMessage {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding()
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List(selection: $viewModel.selectedModId) {
                            ForEach($viewModel.mods) { $mod in
                                ModRowView(
                                    mod: $mod,
                                    isSelected: viewModel.selectedModId == mod.id
                                ) {
                                    renameSheetId = UUID()
                                    renamingMod = mod
                                    renameText = mod.displayName

                                    // renamePreviewImages 已在 ModDetailView 加载时设置好
                                    // 极端情况（用户直接对未选中 mod 点重命名）才走回退
                                    if renamePreviewImages.isEmpty {
                                        let urls = viewModel.imagesForMod(mod)
                                        renamingModImages = urls
                                        renamePreviewImages = urls.compactMap {
                                            ImageThumbnailCache.shared.cachedThumbnail(for: $0)
                                                ?? ImageThumbnailCache.shared.generateAndCache(for: $0, maxSize: 320)
                                        }
                                    }
                                    showRenameSheet = true
                                }
                                .environmentObject(loc)
                            }
                            .onMove(perform: viewModel.moveMod)
                        }
                        .listStyle(.inset)
                        .focusable(true)
                    }

                    Divider()

                    // 状态栏
                    HStack {
                        if let scriptPath = viewModel.userScriptPath {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            Text(loc.str(.scriptFound(scriptPath)))
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                            Text(loc.str(.scriptNotFound))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Circle()
                            .fill(viewModel.workshopExists ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                        Text(viewModel.workshopExists ? loc.str(.workshopConnected) : loc.str(.workshopNotFound))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    .background(Color(NSColor.controlBackgroundColor).opacity(0.3))
                }
                .frame(minWidth: 300)

                // 右侧：详情面板
                if let selectedId = viewModel.selectedModId,
                   let selectedMod = viewModel.mods.first(where: { $0.id == selectedId }) {
                    ModDetailView(
                        mod: selectedMod,
                        imageUrls: selectedModImages,
                        onFirstImageLoaded: { image in
                            // 🔑 直接把图片写入重命名预览数组
                            // Sheet 出现时图片已就绪，零帧延迟
                            renamePreviewImages = [image]
                        }
                    )
                    .environmentObject(loc)
                    .frame(minWidth: 200, idealWidth: 320)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 36))
                            .foregroundColor(.secondary)
                        Text(loc.str(.clickModHint))
                            .font(.body)
                            .foregroundColor(.secondary)
                        Text(loc.str(.detailHint))
                            .font(.caption)
                            .foregroundColor(.secondary.opacity(0.7))
                    }
                    .frame(minWidth: 200, idealWidth: 320)
                }
            }

            // Toast 横幅覆盖层
            VStack {
                if let message = viewModel.toastMessage {
                    ToastBanner(message: message, type: viewModel.toastType) {
                        viewModel.toastMessage = nil
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(100)
                }
                Spacer()
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.toastMessage != nil)
        .onAppear {
            viewModel.scanMods()
        }
        .onChange(of: viewModel.selectedModId) { newId in
            // 切换选中 mod 时清掉旧的重命名预览图，等待新 mod 加载
            renamePreviewImages = []
            if let id = newId, let mod = viewModel.mods.first(where: { $0.id == id }) {
                selectedModImages = viewModel.imagesForMod(mod)
            } else {
                selectedModImages = []
            }
        }
        // 📸 扫描完成后，后台并发预加载所有 MOD 缩略图（TaskGroup 并行）
        .onChange(of: viewModel.mods.count) { newCount in
            guard newCount > 0 else { return }
            let mods = viewModel.mods

            Task {
                var allUrls: [URL] = []
                for mod in mods {
                    allUrls.append(contentsOf: viewModel.imagesForMod(mod))
                }
                await ImageThumbnailCache.shared.preloadAll(urls: allUrls, maxSize: 320)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(viewModel)
                .environmentObject(loc)
        }
        .sheet(isPresented: $showRenameSheet) {
            RenameSheetView(
                modName: renamingMod?.displayName ?? "",
                packFileName: renamingMod?.packFileName ?? "",
                previewImages: renamePreviewImages,
                renameText: $renameText,
                onConfirm: {
                    if let mod = renamingMod {
                        viewModel.renameMod(mod, newName: renameText)
                    }
                    showRenameSheet = false
                },
                onCancel: { showRenameSheet = false }
            )
            .environmentObject(loc)
            .id(renameSheetId)
        }
    }

    // MARK: - 启动游戏

    /// 按优先级尝试启动 Rome 2 Total War：
    /// 1. 用户自定义 .app 路径
    /// 2. Steam URL scheme (steam://run/214950)
    /// 3. 自动检测 Steam 安装目录
    func launchGame() {
        // 自动写入脚本（防止用户忘记点击「写入脚本」）
        if viewModel.writeUserScriptSilently() {
            viewModel.showToast(loc.str(.autoSavedAndLaunch(viewModel.enabledCount)), type: .success)
        } else {
            return  // 写入失败，阻止启动（错误提示已在 writeUserScriptSilently 中显示）
        }

        // 1. 用户自定义路径
        if let customPath = AppSettings.shared.customGamePath, !customPath.isEmpty {
            if FileManager.default.fileExists(atPath: customPath) {
                NSWorkspace.shared.open(URL(fileURLWithPath: customPath))
                viewModel.showToast(loc.str(.gameLaunched("Rome 2")), type: .success)
                return
            } else {
                viewModel.showToast(loc.str(.gamePathInvalid), type: .error)
                return
            }
        }

        // 2. Steam URL scheme
        if let steamURL = URL(string: "steam://run/214950"),
           NSWorkspace.shared.urlForApplication(toOpen: steamURL) != nil {
            NSWorkspace.shared.open(steamURL)
            viewModel.showToast(loc.str(.gameLaunched("Rome 2 (Steam)")), type: .success)
            return
        }

        // 3. 自动检测 Steam 安装目录
        let homeDir = NSHomeDirectory()
        let commonPath = "\(homeDir)/Library/Application Support/Steam/steamapps/common/Total War ROME II"
        let appPath = "\(commonPath)/Total War ROME II.app"
        if FileManager.default.fileExists(atPath: appPath) {
            NSWorkspace.shared.open(URL(fileURLWithPath: appPath))
            viewModel.showToast(loc.str(.gameLaunched("Rome 2")), type: .success)
            return
        }

        // 全部失败
        viewModel.showToast(loc.str(.gamePathInvalid), type: .error)
    }
}

// MARK: - 重命名弹窗（自定义 Sheet，带 MOD 预览图）

struct RenameSheetView: View {
    let modName: String
    let packFileName: String
    let previewImages: [NSImage]
    @Binding var renameText: String
    let onConfirm: () -> Void
    let onCancel: () -> Void

    @EnvironmentObject var loc: LocalizationManager

    var body: some View {
        VStack(spacing: 20) {
            // 标题
            Text(loc.str(.renameTitle))
                .font(.title2)
                .fontWeight(.bold)

            // MOD 预览图（图片已在 ModDetailView 加载时写入，零等待 ⚡️）
            if let nsImage = previewImages.first {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 320, maxHeight: 180)
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
            } else {
                // 无预览图时显示 MOD 图标占位
                VStack(spacing: 8) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text(packFileName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                .frame(maxWidth: 320, minHeight: 100)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(NSColor.controlBackgroundColor).opacity(0.5))
                )
            }

            // 提示文字
            Text(loc.str(.renamePrompt))
                .font(.callout)
                .foregroundColor(.secondary)

            // 输入框
            TextField(loc.str(.renamePlaceholder), text: $renameText)
                .textFieldStyle(.roundedBorder)
                .frame(width: 300)
                .onSubmit {
                    onConfirm()
                }

            // 按钮
            HStack(spacing: 16) {
                Button(loc.str(.cancel), action: onCancel)
                    .keyboardShortcut(.escape)

                Button(loc.str(.confirm), action: onConfirm)
                    .keyboardShortcut(.return)
                    .buttonStyle(.borderedProminent)
                    .disabled(renameText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(30)
        .frame(width: 420, height: 420)
    }
}

// MARK: - Toast 横幅

struct ToastBanner: View {
    let message: String
    let type: ToastType
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: type.icon)
                .foregroundColor(type.color)
                .font(.title3)

            Text(message)
                .font(.callout)
                .foregroundColor(.primary)
                .lineLimit(2)

            Spacer()

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.borderless)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(type.color.opacity(0.4), lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

// MARK: - MOD 行视图

struct ModRowView: View {
    @Binding var mod: ModItem
    var isSelected: Bool
    var onRename: () -> Void
    @EnvironmentObject var loc: LocalizationManager

    var body: some View {
        HStack(spacing: 10) {
            // 拖拽排序手柄
            Image(systemName: "line.3.horizontal")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.4))
                .frame(width: 12)

            Toggle("", isOn: $mod.isEnabled)
                .toggleStyle(.switch)
                .controlSize(.small)
                .labelsHidden()

            Image(systemName: "doc.text")
                .font(.title3)
                .foregroundColor(mod.isEnabled ? .accentColor : .secondary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(mod.displayName)
                    .font(.body)
                    .foregroundColor(mod.isEnabled ? .primary : .secondary)
                    .lineLimit(1)

                Text(mod.packFileName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Button(action: onRename) {
                Image(systemName: "pencil")
                    .font(.body)
            }
            .buttonStyle(.borderless)
            .opacity(isSelected ? 1 : 0.4)
            .help(loc.str(.renameHelp))
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 6)
        .contentShape(Rectangle())
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isSelected ? Color.accentColor.opacity(0.12) : Color.clear)
        )
    }
}

// MARK: - MOD 详情视图

struct ModDetailView: View {
    let mod: ModItem
    let imageUrls: [URL]
    /// ModDetailView 加载完第一张预览图后回调，直接写入 renamePreviewImages
    var onFirstImageLoaded: ((NSImage) -> Void)? = nil
    @EnvironmentObject var loc: LocalizationManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text(mod.displayName)
                    .font(.title3)
                    .fontWeight(.bold)
                    .lineLimit(2)

                Divider()

                Group {
                    DetailRow(label: loc.str(.fileName), value: mod.packFileName)
                    DetailRow(label: loc.str(.status), value: mod.isEnabled ? loc.str(.enabled) : loc.str(.disabled))
                    DetailRow(label: loc.str(.loadOrder), value: loc.str(.loadOrderLabel(mod.loadOrder + 1)))

                    if !mod.workshopSubfolder.isEmpty {
                        DetailRow(label: loc.str(.folder), value: mod.workshopSubfolder)
                    }
                }

                if !imageUrls.isEmpty {
                    Divider()

                    HStack {
                        Image(systemName: "photo.on.rectangle")
                            .foregroundColor(.accentColor)
                        Text(loc.str(.previewImages))
                            .font(.headline)
                    }

                    LazyVStack(spacing: 10) {
                        ForEach(Array(imageUrls.enumerated()), id: \.element) { index, url in
                            VStack(spacing: 4) {
                                if let nsImage = ImageThumbnailCache.shared.generateAndCache(for: url, maxSize: 600) {
                                    Image(nsImage: nsImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: 260, maxHeight: 200)
                                        .cornerRadius(6)
                                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                        .onTapGesture {
                                            NSWorkspace.shared.open(url)
                                        }
                                        .help(loc.str(.clickToEnlarge))
                                        .onAppear {
                                            // 🔑 第一张图加载完成后，直接写入重命名预览
                                            // Sheet 出现时图片已就绪
                                            if index == 0 {
                                                onFirstImageLoaded?(nsImage)
                                            }
                                        }
                                } else {
                                    HStack {
                                        Image(systemName: "photo.badge.exclamationmark")
                                            .foregroundColor(.orange)
                                        Text(loc.str(.cannotLoad))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }

                                Text(url.lastPathComponent)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(NSColor.controlBackgroundColor).opacity(0.5))
                            )
                        }
                    }
                } else {
                    Divider()
                    HStack(spacing: 6) {
                        Image(systemName: "photo.on.rectangle")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        Text(loc.str(.noPreviewImages))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Divider()

                VStack(alignment: .leading, spacing: 4) {
                    Text(loc.str(.loadOrderInfo))
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(loc.str(.loadOrderDesc))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - 详情行

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
                .textSelection(.enabled)
        }
    }
}

// MARK: - 设置视图

struct SettingsView: View {
    @EnvironmentObject var viewModel: ModListViewModel
    @EnvironmentObject var loc: LocalizationManager
    @Environment(\.dismiss) var dismiss

    @State private var workshopPathText: String = ""
    @State private var userScriptPathText: String = ""
    @State private var gamePathText: String = ""
    @State private var showDiagnostics = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(loc.str(.settingsTitle))
                .font(.title2)
                .fontWeight(.bold)

            Text(loc.str(.pathSettingsDesc))
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Divider()

            // 界面语言
            VStack(alignment: .leading, spacing: 6) {
                Text(loc.str(.language))
                    .font(.headline)

                Picker("", selection: Binding(
                    get: { loc.appLanguage },
                    set: { loc.appLanguage = $0 }
                )) {
                    Text(loc.str(.languageAuto)).tag("auto")
                    Text(loc.str(.languageChinese)).tag("zh")
                    Text(loc.str(.languageEnglish)).tag("en")
                }
                .pickerStyle(.segmented)
                .frame(width: 330)
            }

            Divider()

            // 游戏路径
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(loc.str(.gamePath))
                        .font(.headline)
                        .foregroundColor(.accentColor)
                        .underline()
                        .onTapGesture { openGamePathInFinder() }
                        .help(loc.str(.openInFinder))
                    if let path = AppSettings.shared.customGamePath, !path.isEmpty {
                        Text("(\(loc.str(.custom)))")
                            .font(.caption)
                            .foregroundColor(.orange)
                    } else {
                        Text("(\(loc.str(.default)))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                HStack(spacing: 8) {
                    TextField(loc.str(.gamePathPrompt), text: $gamePathText)
                        .textFieldStyle(.roundedBorder)
                        .font(.caption)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .onChange(of: gamePathText) { newValue in
                            AppSettings.shared.customGamePath = newValue
                        }

                    Button(loc.str(.browse)) {
                        selectGamePath()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }

                HStack(spacing: 4) {
                    let hasPath = AppSettings.shared.customGamePath.map { FileManager.default.fileExists(atPath: $0) } ?? true
                    Image(systemName: hasPath ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(hasPath ? .green : .orange)
                        .font(.caption)
                    Text(hasPath ? loc.str(.dirExists) : loc.str(.dirNotExists))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            // Workshop 路径
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(loc.str(.workshopDir))
                        .font(.headline)
                        .foregroundColor(.accentColor)
                        .underline()
                        .onTapGesture {
                            if let path = viewModel.workshopPath?.path {
                                NSWorkspace.shared.open(URL(fileURLWithPath: path))
                            }
                        }
                        .help(loc.str(.openInFinder))
                    if viewModel.isUsingCustomWorkshopPath {
                        Text("(\(loc.str(.custom)))")
                            .font(.caption)
                            .foregroundColor(.orange)
                    } else {
                        Text("(\(loc.str(.default)))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                HStack(spacing: 8) {
                    TextField(loc.str(.workshopDirPrompt), text: $workshopPathText)
                        .textFieldStyle(.roundedBorder)
                        .font(.caption)
                        .onChange(of: workshopPathText) { newValue in
                            viewModel.customWorkshopPath = newValue
                        }

                    Button(loc.str(.browse)) {
                        viewModel.selectWorkshopPath()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }

                HStack(spacing: 4) {
                    Image(systemName: viewModel.workshopExists ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(viewModel.workshopExists ? .green : .red)
                        .font(.caption)
                    Text(viewModel.workshopExists ? loc.str(.dirExists) : loc.str(.dirNotExists))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // user.script.txt 路径
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(loc.str(.userScriptLabel))
                        .font(.headline)
                        .foregroundColor(.accentColor)
                        .underline()
                        .onTapGesture {
                            if let path = viewModel.userScriptPath {
                                NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: path)])
                            }
                        }
                        .help(loc.str(.openInFinder))
                    if viewModel.isUsingCustomUserScriptPath {
                        Text("(\(loc.str(.custom)))")
                            .font(.caption)
                            .foregroundColor(.orange)
                    } else {
                        Text("(\(loc.str(.default)))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                HStack(spacing: 8) {
                    TextField(loc.str(.userScriptPrompt), text: $userScriptPathText)
                        .textFieldStyle(.roundedBorder)
                        .font(.caption)
                        .onChange(of: userScriptPathText) { newValue in
                            viewModel.customUserScriptPath = newValue
                        }

                    Button(loc.str(.browse)) {
                        viewModel.selectUserScriptPath()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }

                if let path = viewModel.userScriptPath {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text(loc.str(.fileExists))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text(loc.str(.fileNotExists))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Divider()

            // 诊断区块
            VStack(alignment: .leading, spacing: 8) {
                Button(action: { showDiagnostics.toggle() }) {
                    Label(loc.str(.diagnostics), systemImage: showDiagnostics ? "magnifyingglass.circle.fill" : "magnifyingglass")
                }
                .buttonStyle(.bordered)

                if showDiagnostics {
                    VStack(alignment: .leading, spacing: 8) {
                        DiagnosticRow(
                            label: loc.str(.workshopPath),
                            value: viewModel.workshopPath?.path ?? loc.str(.notSet),
                            exists: viewModel.workshopExists
                        )

                        DiagnosticRow(
                            label: loc.str(.userScriptPath),
                            value: viewModel.userScriptPath ?? loc.str(.notFound),
                            exists: viewModel.userScriptPath != nil
                        )

                        DiagnosticRow(
                            label: loc.str(.scannedPacks),
                            value: loc.str(.countUnit(viewModel.mods.count)),
                            exists: !viewModel.mods.isEmpty
                        )

                        if let error = viewModel.errorMessage {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(loc.str(.errorInfo))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding(8)
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(6)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }

            Divider()

            // 按钮
            HStack {
                Button(loc.str(.resetDefaults)) {
                    viewModel.resetPathsToDefault()
                    workshopPathText = ""
                    userScriptPathText = ""
                    gamePathText = ""
                }
                .buttonStyle(.bordered)

                Spacer()

                Button(loc.str(.close)) {
                    dismiss()
                }
                .keyboardShortcut(.return)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 520, height: showDiagnostics ? 720 : 600)
        .onAppear {
            workshopPathText = viewModel.customWorkshopPath
            userScriptPathText = viewModel.customUserScriptPath
            gamePathText = AppSettings.shared.customGamePath ?? ""
        }
    }

    // MARK: - 在 Finder 中定位游戏路径

    func openGamePathInFinder() {
        if let customPath = AppSettings.shared.customGamePath, !customPath.isEmpty {
            let url = URL(fileURLWithPath: customPath)
            if FileManager.default.fileExists(atPath: customPath) {
                NSWorkspace.shared.activateFileViewerSelecting([url])
                return
            }
        }

        let homeDir = NSHomeDirectory()
        let commonPath = "\(homeDir)/Library/Application Support/Steam/steamapps/common/Total War ROME II"
        if FileManager.default.fileExists(atPath: commonPath) {
            NSWorkspace.shared.open(URL(fileURLWithPath: commonPath))
        } else {
            let steamCommon = "\(homeDir)/Library/Application Support/Steam/steamapps/common"
            if FileManager.default.fileExists(atPath: steamCommon) {
                NSWorkspace.shared.open(URL(fileURLWithPath: steamCommon))
            }
        }
    }

    // MARK: - 选择游戏路径

    func selectGamePath() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.application]
        panel.message = loc.str(.selectGamePath)
        panel.prompt = loc.str(.choose)

        if panel.runModal() == .OK, let url = panel.url {
            AppSettings.shared.customGamePath = url.path
            gamePathText = url.path
            viewModel.showToast(loc.str(.gamePathSet(url.lastPathComponent)), type: .success)
        }
    }
}

// MARK: - 诊断行（设置页内复用）

struct DiagnosticRow: View {
    let label: String
    let value: String
    let exists: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
                Circle()
                    .fill(exists ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(value)
                .font(.caption)
                .foregroundColor(.primary)
                .textSelection(.enabled)
                .lineLimit(2)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    ContentView()
        .environmentObject(ModListViewModel())
        .environmentObject(LocalizationManager.shared)
}
