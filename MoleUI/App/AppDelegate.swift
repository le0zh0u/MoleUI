//
//  AppDelegate.swift
//  MoleUI
//
//  Created by 周椿杰 on 2026/2/18.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 应用启动完成
        print("MoleUI started")
    }

    func applicationWillTerminate(_ notification: Notification) {
        // 应用即将退出
        print("MoleUI will terminate")
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // 关闭最后一个窗口时退出应用
        return true
    }
}
