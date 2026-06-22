//
//  AboutView.swift
//  Rome2ModManagerMac
//
//  自定义关于窗口 — 中英双语显示
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 10) {
            // App 图标
            Image(nsImage: NSImage(named: NSImage.applicationIconName) ?? NSImage())
                .resizable()
                .frame(width: 72, height: 72)
                .padding(.top, 8)

            // App 名称
            Text(AppInfo.appName)
                .font(.title2.weight(.semibold))

            // 版本号
            Text("Version \(AppInfo.version) (Build \(AppInfo.build))")
                .font(.system(size: 11))
                .foregroundColor(.secondary)

            // ---- 简介（中英双语） ----
            VStack(spacing: 2) {
                Text(AppInfo.descriptionCN)
                    .font(.callout)
                    .foregroundColor(.primary)

                Text(AppInfo.descriptionEN)
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .italic()
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)

            Divider()
                .padding(.horizontal, 16)

            // ---- 作者（中英双语） ----
            VStack(spacing: 2) {
                Text("作者：\(AppInfo.authorCN)")
                    .font(.subheadline.weight(.medium))

                Text("Author: \(AppInfo.authorEN)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // ---- 版权（中英双语） ----
            VStack(spacing: 1) {
                Text(AppInfo.copyrightCN)
                Text(AppInfo.copyrightEN)
            }
            .font(.system(size: 9.5))
            .foregroundColor(.secondary)

            // 关闭按钮
            Button("确定 / OK") {
                NSApplication.shared.keyWindow?.close()
            }
            .keyboardShortcut(.defaultAction)
            .padding(.vertical, 6)
        }
        .frame(width: 380, height: 380)
        .padding()
    }
}

#Preview {
    AboutView()
}
