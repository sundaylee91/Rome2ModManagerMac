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
                        
                        Button(action: { viewModel.writeUserScript() }) {
                            Label(loc.str(.writeScript), systemImage: "square.and.arrow.down")
                        }
                        .help(loc.str(.writeHelp))
                        .disabled(viewModel.mods.isEmpty)
                        
                        Divider()
                            .frame(height: 20)
                        
                        Button(action: { showSettings = true }) {
                            Label(loc.str(.settings), systemImage: "gearshape")
                        }
                        .help(loc.str(.settingsHelp))
                        
                        Button(action: { showDiagnostics = true }) {
                            Label(loc.str(.diagnostics), systemImage: "magnifyingglass")
                        }
                        .help(loc.str(.diagnosticsHelp))
                        
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
                    
                    // MOD 列表
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
                        List {
                            ForEach($viewModel.mods) { $mod in
                                ModRowView(
                                    mod: $mod,
                                    isSelected: viewModel.selectedModId == mod.id
                                ) {
                                    renamingMod = mod
                                    renameText = mod.displayName
                                    showRenameAlert = true
                                }
                                .onTapGesture {
                                    viewModel.selectMod(mod.id)
                                }
                                .environmentObject(loc)
                            }
                            .onMove { source, destination in
                                viewModel.mods.move(fromOffsets: source, toOffset: destination)
                                viewModel.updateLoadOrder()
                            }
                        }
                        .listStyle(.inset)
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
                        imageUrls: viewModel.selectedModImages
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
    
    @State private var fullImageUrl: URL?
    @State private var showFullImage = false
    
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
                                            fullImageUrl = url
                                            showFullImage = true
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
        .sheet(isPresented: $showFullImage) {
            if let url = fullImageUrl {
                FullImageView(imageUrl: url)
                    .environmentObject(loc)
            }
        }
    }
}

// MARK: - 大图查看

struct FullImageView: View {
    let imageUrl: URL
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var loc: LocalizationManager
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(imageUrl.lastPathComponent)
                    .font(.headline)
                Spacer()
                Button(loc.str(.close)) {
                    dismiss()
                }
                .keyboardShortcut(.return)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            if let nsImage = NSImage(contentsOf: imageUrl) {
                ScrollView([.horizontal, .vertical]) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                }
            } else {
                VStack {
                    Image(systemName: "photo.badge.exclamationmark")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text(loc.str(.cannotLoadImage))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(minWidth: 500, minHeight: 400)
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
            
            // Workshop 路径
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(loc.str(.workshopDir))
                        .font(.headline)
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
        .frame(width: 520, height: 500)
        .onAppear {
            workshopPathText = viewModel.customWorkshopPath
            userScriptPathText = viewModel.customUserScriptPath
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
