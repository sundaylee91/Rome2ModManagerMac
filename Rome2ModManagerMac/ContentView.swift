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
    @State private var showRenameAlert = false
    @State private var renameText = ""
    @State private var renamingMod: ModItem?
    
    var body: some View {
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
                            ModRowView(mod: $mod) {
                                renamingMod = mod
                                renameText = mod.displayName
                                showRenameAlert = true
                            }
                            .onTapGesture {
                                mod.isEnabled.toggle()
                            }
                        }
                        .onMove { source, destination in
                            viewModel.mods.move(fromOffsets: source, toOffset: destination)
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
            if let selectedMod = viewModel.mods.first(where: { _ in true }) {
                // 暂时显示第一个 MOD 的详情
                ModDetailView(mod: selectedMod)
                    .frame(minWidth: 200, idealWidth: 280)
            } else {
                VStack {
                    Image(systemName: "info.circle")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("选择一个 MOD 查看详情")
                        .foregroundColor(.secondary)
                }
                .frame(minWidth: 200, idealWidth: 280)
            }
        }
        .onAppear {
            viewModel.scanMods()
        }
        .sheet(isPresented: $showDiagnostics) {
            DiagnosticsView()
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

// MARK: - MOD 行视图

struct ModRowView: View {
    @Binding var mod: ModItem
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
            .opacity(0.6)
            .help("重命名")
        }
        .padding(.vertical, 4)
    }
}

// MARK: - MOD 详情视图

struct ModDetailView: View {
    let mod: ModItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MOD 详情")
                .font(.headline)
                .padding(.bottom, 4)
            
            Group {
                DetailRow(label: "名称", value: mod.displayName)
                DetailRow(label: "文件名", value: mod.packFileName)
                DetailRow(label: "状态", value: mod.isEnabled ? "✓ 启用" : "✗ 禁用")
            }
            
            Divider()
            
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

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
