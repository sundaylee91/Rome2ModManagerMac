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
                            Label("扫描", systemImage: "arrow.triangle.2.circlepath")
                        }
                        .help("扫描 Workshop MOD 文件夹 (⌘R)")
                        
                        Button(action: { viewModel.writeUserScript() }) {
                            Label("写入", systemImage: "square.and.arrow.down")
                        }
                        .help("写入 user.script.txt (⌘S)")
                        .disabled(viewModel.mods.isEmpty)
                        
                        Divider()
                            .frame(height: 20)
                        
                        Button(action: { showSettings = true }) {
                            Label("设置", systemImage: "gearshape")
                        }
                        .help("设置路径")
                        
                        Button(action: { showDiagnostics = true }) {
                            Label("诊断", systemImage: "magnifyingglass")
                        }
                        .help("路径诊断")
                        
                        Spacer()
                        
                        if viewModel.isScanning {
                            ProgressView()
                                .scaleEffect(0.7)
                                .frame(width: 20, height: 20)
                        }
                        
                        Text("\(viewModel.mods.count) 个 MOD")
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
                            Text("暂无 MOD")
                                .font(.title3)
                                .foregroundColor(.secondary)
                            Text("点击「扫描」或按 ⌘R 加载 MOD 列表")
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
                            }
                            .onMove { source, destination in
                                viewModel.mods.move(fromOffsets: source, toOffset: destination)
                                // 拖拽后同步 loadOrder 到新的列表位置
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
                            Text("脚本: \(scriptPath)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                            Text("未找到 user.script.txt")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Circle()
                            .fill(viewModel.workshopExists ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                        Text(viewModel.workshopExists ? "Workshop 已连接" : "Workshop 未找到")
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
                    .frame(minWidth: 200, idealWidth: 320)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 36))
                            .foregroundColor(.secondary)
                        Text("点击左侧 MOD 查看详情")
                            .font(.body)
                            .foregroundColor(.secondary)
                        Text("详情包括 MOD 信息和预览图片")
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
            // 当选中变化时同步图片（ViewModel 已在 selectMod 中处理）
            if let id = newId, let mod = viewModel.mods.first(where: { $0.id == id }) {
                selectedModImages = viewModel.imagesForMod(mod)
            } else {
                selectedModImages = []
            }
        }
        .sheet(isPresented: $showDiagnostics) {
            DiagnosticsView()
                .environmentObject(viewModel)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(viewModel)
        }
        .alert("重命名", isPresented: $showRenameAlert) {
            TextField("新名称", text: $renameText)
            Button("确定") {
                if let mod = renamingMod {
                    viewModel.renameMod(mod, newName: renameText)
                }
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("输入 MOD 的新显示名称")
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
    
    var body: some View {
        HStack(spacing: 10) {
            // 启用开关
            Toggle("", isOn: $mod.isEnabled)
                .toggleStyle(.switch)
                .controlSize(.small)
                .labelsHidden()
            
            // MOD 图标
            Image(systemName: "doc.text")
                .font(.title3)
                .foregroundColor(mod.isEnabled ? .accentColor : .secondary)
                .frame(width: 24)
            
            // MOD 名称
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
            
            // 重命名按钮
            Button(action: onRename) {
                Image(systemName: "pencil")
                    .font(.caption)
            }
            .buttonStyle(.borderless)
            .opacity(isSelected ? 1 : 0.4)
            .help("重命名")
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 6)
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
    
    @State private var fullImageUrl: URL?
    @State private var showFullImage = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                // 标题
                Text(mod.displayName)
                    .font(.title3)
                    .fontWeight(.bold)
                    .lineLimit(2)
                
                Divider()
                
                // 基本信息
                Group {
                    DetailRow(label: "文件名", value: mod.packFileName)
                    DetailRow(label: "状态", value: mod.isEnabled ? "✓ 启用" : "✗ 禁用")
                    DetailRow(label: "加载顺序", value: "第 \(mod.loadOrder + 1) 位")
                    
                    if !mod.workshopSubfolder.isEmpty {
                        DetailRow(label: "所在文件夹", value: mod.workshopSubfolder)
                    }
                }
                
                // 预览图片
                if !imageUrls.isEmpty {
                    Divider()
                    
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                            .foregroundColor(.accentColor)
                        Text("预览图片")
                            .font(.headline)
                        Text("(\(imageUrls.count))")
                            .font(.caption)
                            .foregroundColor(.secondary)
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
                                        .help("点击查看大图")
                                } else {
                                    HStack {
                                        Image(systemName: "photo.badge.exclamationmark")
                                            .foregroundColor(.orange)
                                        Text("无法加载")
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
                        Text("该 MOD 文件夹中没有预览图片")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Divider()
                
                // 加载顺序说明
                VStack(alignment: .leading, spacing: 4) {
                    Text("MOD 加载顺序说明")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("列表中的 MOD 按从上到下的顺序加载。拖拽行可调整加载顺序。")
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
            }
        }
    }
}

// MARK: - 大图查看

struct FullImageView: View {
    let imageUrl: URL
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(imageUrl.lastPathComponent)
                    .font(.headline)
                Spacer()
                Button("关闭") {
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
                    Text("无法加载图片")
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
    @Environment(\.dismiss) var dismiss
    
    @State private var workshopPathText: String = ""
    @State private var userScriptPathText: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("路径设置")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("如果默认路径不正确，可以在这里自定义 Workshop 目录和 user.script.txt 文件的位置。留空则使用默认路径。")
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            Divider()
            
            // Workshop 路径
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Workshop 目录")
                        .font(.headline)
                    if viewModel.isUsingCustomWorkshopPath {
                        Text("(自定义)")
                            .font(.caption)
                            .foregroundColor(.orange)
                    } else {
                        Text("(默认)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack(spacing: 8) {
                    TextField("输入 Workshop 路径或点击「浏览」选择...", text: $workshopPathText)
                        .textFieldStyle(.roundedBorder)
                        .font(.caption)
                        .onChange(of: workshopPathText) { newValue in
                            viewModel.customWorkshopPath = newValue
                        }
                    
                    Button("浏览") {
                        viewModel.selectWorkshopPath()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: viewModel.workshopExists ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(viewModel.workshopExists ? .green : .red)
                        .font(.caption)
                    Text(viewModel.workshopExists ? "目录存在" : "目录不存在")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // user.script.txt 路径
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("user.script.txt")
                        .font(.headline)
                    if viewModel.isUsingCustomUserScriptPath {
                        Text("(自定义)")
                            .font(.caption)
                            .foregroundColor(.orange)
                    } else {
                        Text("(默认)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack(spacing: 8) {
                    TextField("输入 user.script.txt 路径或点击「浏览」选择...", text: $userScriptPathText)
                        .textFieldStyle(.roundedBorder)
                        .font(.caption)
                        .onChange(of: userScriptPathText) { newValue in
                            viewModel.customUserScriptPath = newValue
                        }
                    
                    Button("浏览") {
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
                        Text("文件存在")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text("文件不存在（写入时会自动创建）")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Divider()
            
            // 重置按钮
            HStack {
                Button("恢复默认路径") {
                    viewModel.resetPathsToDefault()
                    workshopPathText = ""
                    userScriptPathText = ""
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("关闭") {
                    dismiss()
                }
                .keyboardShortcut(.return)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 520, height: 420)
        .onAppear {
            workshopPathText = viewModel.customWorkshopPath
            userScriptPathText = viewModel.customUserScriptPath
        }
    }
}

// MARK: - 诊断视图

struct DiagnosticsView: View {
    @EnvironmentObject var viewModel: ModListViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("路径诊断")
                .font(.title2)
                .fontWeight(.bold)
            
            Group {
                DiagnosticRow(
                    label: "Workshop 路径",
                    value: viewModel.workshopPath?.path ?? "未设置",
                    exists: viewModel.workshopExists
                )
                
                DiagnosticRow(
                    label: "user.script.txt 路径",
                    value: viewModel.userScriptPath ?? "未找到",
                    exists: viewModel.userScriptPath != nil
                )
                
                DiagnosticRow(
                    label: "扫描到的 .pack 文件",
                    value: "\(viewModel.mods.count) 个",
                    exists: !viewModel.mods.isEmpty
                )
            }
            
            if let error = viewModel.errorMessage {
                VStack(alignment: .leading, spacing: 4) {
                    Text("错误信息")
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
                Button("关闭") {
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
}
