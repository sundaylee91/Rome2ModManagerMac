import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 16) {

            if let icon = NSImage(named: NSImage.applicationIconName) {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 80, height: 80)
                    .cornerRadius(12)
            }

            Text(AppInfo.appName)
                .font(.title2)
                .fontWeight(.semibold)

            Text("Version \(AppInfo.version) (Build \(AppInfo.build))")
                .font(.caption)
                .foregroundColor(.secondary)

            Text(AppInfo.appDescription)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Divider()
                .padding(.horizontal, 40)

            Text(AppInfo.isChinese ? "作者：\(AppInfo.author)" : "Author: \(AppInfo.author)")
                .font(.body)

            Text(AppInfo.copyrightText)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            Link(destination: URL(string: "https://github.com/sundaylee91/Rome2ModManagerMac")!) {
                HStack(spacing: 6) {
                    Image(systemName: "github")
                        .font(.system(size: 14))
                    Text("Rome2ModManagerMac")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            .padding(.top, 4)
            .pointingHandCursor()

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
