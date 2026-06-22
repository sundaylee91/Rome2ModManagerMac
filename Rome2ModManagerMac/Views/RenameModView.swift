import SwiftUI

/// 重命名 MOD 弹窗
/// 使用主界面已经预热的缩略图，零等待显示
struct RenameModView: View {
    let mod: Mod
    let previewImage: NSImage?       // 主界面预热好的缩略图
    let loc: LocalizationManager      // 显式传入，不依赖 @EnvironmentObject
    let onConfirm: (String) -> Void
    let onCancel: () -> Void

    @State private var newName: String = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(spacing: 16) {
            // 标题
            Text(loc.str(.renameMod))
                .font(.headline)

            // MOD 缩略图
            if let image = previewImage {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 320, maxHeight: 320)
                    .cornerRadius(8)
                    .shadow(radius: 2)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 320, height: 200)
                    .overlay(
                        VStack(spacing: 6) {
                            Image(systemName: "photo")
                                .font(.title2)
                                .foregroundColor(.secondary)
                            Text(loc.str(.noPreviewAvailable))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    )
            }

            // 当前文件名
            HStack {
                Text(loc.str(.currentNameLabel))
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(mod.name)
                    .font(.caption)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            // 新名称输入框
            TextField(loc.str(.enterNewFileName), text: $newName)
                .textFieldStyle(.roundedBorder)
                .focused($isTextFieldFocused)
                .onSubmit { confirm() }

            // 按钮
            HStack(spacing: 12) {
                Button(loc.str(.cancel)) { onCancel() }
                    .keyboardShortcut(.escape, modifiers: [])

                Button(loc.str(.confirmRename)) { confirm() }
                    .keyboardShortcut(.return, modifiers: [])
                    .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(24)
        .frame(width: 380)
        .onAppear {
            // 去掉扩展名，方便用户编辑
            let base = (mod.name as NSString).deletingPathExtension
            newName = base
            isTextFieldFocused = true
        }
    }

    private func confirm() {
        let trimmed = newName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        onConfirm(trimmed)
    }
}

#Preview {
    RenameModView(
        mod: Mod(id: UUID(), name: "test_mod.pack", filePath: "/tmp/test_mod.pack", fileSize: 1024),
        previewImage: nil,
        loc: LocalizationManager.shared,
        onConfirm: { _ in },
        onCancel: { }
    )
}
