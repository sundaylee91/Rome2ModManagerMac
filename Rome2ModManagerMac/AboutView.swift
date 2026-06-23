import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 22) {

            if let icon = NSImage(named: NSImage.applicationIconName) {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 80, height: 80)
                    .cornerRadius(12)
            }

            Text(AppInfo.appName)
                .font(.title)
                .fontWeight(.bold)

            Text("Version \(AppInfo.version) (Build \(AppInfo.build))")
                .font(.subheadline)
                .foregroundColor(.gray)

            Text(AppInfo.appDescription)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Divider()
                .padding(.horizontal, 40)

            // 作者 / 版权 / 项目地址 → 小间距归组
            VStack(spacing: 6) {
                Text(AppInfo.isChinese ? "作者：\(AppInfo.author)" : "Author: \(AppInfo.author)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                // 版权文本：显式多行 + 固定垂直伸展，防止截断
                Text(AppInfo.copyrightText)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 30)

                // 项目地址：纯文字，无蓝框，点击打开浏览器
                let projectURL = "https://github.com/sundaylee91/Rome2ModManagerMac"
                Text(AppInfo.isChinese
                        ? "项目地址：\(projectURL)"
                        : "Project: \(projectURL)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .onHover { inside in
                        if inside {
                            NSCursor.pointingHand.push()
                        } else {
                            NSCursor.pop()
                        }
                    }
                    .onTapGesture {
                        if let url = URL(string: projectURL) {
                            NSWorkspace.shared.open(url)
                        }
                    }
            }

            Button("OK") {
                NSApplication.shared.keyWindow?.close()
            }
            .keyboardShortcut(.defaultAction)
            .padding(.top, 4)
        }
        .padding(.vertical, 24)
        .frame(width: 420)
    }
}
