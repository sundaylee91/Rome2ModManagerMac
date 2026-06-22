//
//  AboutView.swift
//  Rome2ModManagerMac
//
//  自定义关于窗口
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 14) {
            // App 图标
            Image(nsImage: NSImage(named: NSImage.applicationIconName) ?? NSImage())
                .resizable()
                .frame(width: 80, height: 80)
                .padding(.top, 10)

            // App 名称
            Text(AppInfo.appName)
                .font(.title.weight(.semibold))

            // 版本号
            Text("Version \(AppInfo.version) (Build \(AppInfo.build))")
                .font(.system(size: 11))
                .foregroundColor(.secondary)

            // 简介
            Text(AppInfo.description)
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .padding(.horizontal, 30)

            Divider()
                .padding(.horizontal, 20)

            // 作者
            Text("Author: \(AppInfo.author)")
                .font(.headline)

            // 版权
            Text(AppInfo.copyright)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
                .padding(.bottom, 4)

            // 关闭按钮
            Button("OK") {
                NSApplication.shared.keyWindow?.close()
            }
            .keyboardShortcut(.defaultAction)
            .padding(.bottom, 10)
        }
        .frame(width: 360, height: 340)
        .padding()
    }
}

#Preview {
    AboutView()
}
