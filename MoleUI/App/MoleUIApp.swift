//
//  MoleUIApp.swift
//  MoleUI
//
//  Created by 周椿杰 on 2026/2/15.
//

import SwiftUI

@main
struct MoleUIApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            MainView()
                .frame(minWidth: 900, minHeight: 600)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            // 自定义菜单
            CommandGroup(replacing: .appInfo) {
                Button("About MoleUI") {
                    // TODO: 显示关于窗口
                }
            }
        }
    }
}
