//
//  Rome2ModManagerMacApp.swift
//  Rome2ModManagerMac
//
//  Created by 李拜天 on 2026/6/22.
//

import SwiftUI

@main
struct Rome2ModManagerMacApp: App {
    @StateObject private var viewModel = ModListViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .frame(minWidth: 700, minHeight: 450)
        }
        .windowResizability(.contentMinSize)
        .commands {
            CommandGroup(after: .newItem) {
                Button("扫描 Workshop MOD") {
                    viewModel.scanMods()
                }
                .keyboardShortcut("R", modifiers: [.command])
                
                Button("写入 user.script.txt") {
                    viewModel.writeUserScript()
                }
                .keyboardShortcut("S", modifiers: [.command])
                .disabled(viewModel.mods.isEmpty)
            }
        }
    }
}
