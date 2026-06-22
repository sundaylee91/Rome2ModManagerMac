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
    @State private var showDiagnostics = false
    @State private var showSettings = false
    @State private var showRenameAlert = false
    @State private var renameText = ""
    @State private var renamingMod: ModItem?
    @State private var selectedModImages: [URL] = []
    
    var body: some View {
        ZStack {
            HSplitView {
                // 左侧：MOD 列表
                VStack(spacing: 0) {
                    // 工具栏
                    HStack {
                        Button(action: { viewModel.scanMods() }) {
                            Label(loc.str(.scanMods), systemImage: "arrow.triangle.2.circlepath")
                        }
                        .help(loc.str(.scanHelp))
                        .focusEffectDisabled()
                        .focusable(false)
                        
                        Button(action: { viewModel.writeUserScript() }) {
                            Label(loc.str(.writeScript), systemImage: "square.and.arrow.down")
                        }
                        .help(loc.str(.writeHelp))
                        .disabled(viewModel.mods.isEmpty)
                        .focusEffectDisabled()
                        .focusable(false)
                        
                        Divider()
                            .frame(height: 20)
                        
                        Button(action: { launchGame() }) {
                            Label(loc.str(.launchGame), systemImage: "play.fill")
                        }
                        .help(loc.str(.launchHelp))
                        .focusEffectDisabled()
                        .focusable(false)
                        
                        Divider()
                            .frame(height: 20)
                        
                        Button(action: { showSettings = true }) {
                            Label(loc.str(.settings), systemImage: "gearshape")
                        }
                        .help(loc.str(.settingsHelp))
                        .focusEffectDisabled()
                        .focusable(false)
                        
                        Button(action: { showDiagnostics = true }) {
                            Label(loc.str(.diagnostics), systemImage: "magnifyingglass")
                        }
                        .help(loc.str(.diagnosticsHelp))
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
                                    renamingMod = mod
                                    renameText = mod.displayName
                                    showRenameAlert = true
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
                        imageUrls: selectedModImages
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
            if let id = newId, let mod = viewModel.mods.first(where: { $0.id == id }) {
                selectedModImages = viewModel.imagesForMod(mod)
            } else {
                selectedModImages = []
            }
        }
        .sheet(isPresented: $showDiagnostics) {
            DiagnosticsView()
                .environmentObject(viewModel)
                .environmentObject(loc)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(viewModel)
                .environmentObject(loc)
        }
        .alert(loc.str(.renameTitle), isPresented: $showRenameAlert) {
            TextField(loc.str(.renamePlaceholder), text: $renameText)
            Button(loc.str(.confirm)) {
                if let mod = renamingMod {
                    viewModel.renameMod(mod, newName: renameText)
                }
            }
            Button(loc.str(.cancel), role: .cancel) {}
        } message: {
            Text(loc.str(.renamePrompt))
        }
    }
    
    // MARK: - 启动游戏
    
    /// 按优先级尝试启动 Rome 2 Total War：
    /// 1. 用户自定义 .app 路径
    /// 2. Steam URL scheme (steam://run/214950)
    /// 3. 自动检测 Steam 安装目录
    func launchGame() {
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
                    .font(.caption)
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
                        Text(loc.str(.previewImages(imageUrls.count)))
                            .font(.headline)
                    }
                    
                    LazyVStack(spacing: 10) {
                        ForEach(imageUrls, id: \.self) { url in
                            VStack(spacing: 4) {
                                if let nsImage = NSImage(contentsOf: url) {
                                    Image(nsImage: nsImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: 260, maxHeight: 200)
                                        .cornerRadius(6)
                                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                        .onTapGesture {
                                            // 使用 macOS 原生 Preview.app 打开图片
                                            // 避免 SwiftUI .sheet 首次弹出空白窗口的 bug
                                            NSWorkspace.shared.open(url)
                                        }
                                        .help(loc.str(.clickToEnlarge))
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
        .frame(width: 520, height: 600)
        .onAppear {
            workshopPathText = viewModel.customWorkshopPath
            userScriptPathText = viewModel.customUserScriptPath
            gamePathText = AppSettings.shared.customGamePath ?? ""
        }
    }
    
    // MARK: - 在 Finder 中定位游戏路径
    
    /// 点击「游戏路径」标题时，跳转到对应的文件夹
    func openGamePathInFinder() {
        // 优先自定义路径
        if let customPath = AppSettings.shared.customGamePath, !customPath.isEmpty {
            let url = URL(fileURLWithPath: customPath)
            if FileManager.default.fileExists(atPath: customPath) {
                // 选中 .app 文件在 Finder 中高亮显示
                NSWorkspace.shared.activateFileViewerSelecting([url])
                return
            }
        }
        
        // 默认：Steam 安装目录
        let homeDir = NSHomeDirectory()
        let commonPath = "\(homeDir)/Library/Application Support/Steam/steamapps/common/Total War ROME II"
        if FileManager.default.fileExists(atPath: commonPath) {
            NSWorkspace.shared.open(URL(fileURLWithPath: commonPath))
        } else {
            // 回退：Steam common 父目录
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

// MARK: - 诊断视图

struct DiagnosticsView: View {
    @EnvironmentObject var viewModel: ModListViewModel
    @EnvironmentObject var loc: LocalizationManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.str(.diagnosticsTitle))
                .font(.title2)
                .fontWeight(.bold)
            
            Group {
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
            }
            
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
            
            Spacer()
            
            HStack {
                Spacer()
                Button(loc.str(.close)) {
                    dismiss()
                }
                .keyboardShortcut(.return)
            }
        }
        .padding()
        .frame(width: 500, height: 350)
    }
}

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
