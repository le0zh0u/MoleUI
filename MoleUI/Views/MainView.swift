//
//  MainView.swift
//  MoleUI
//
//  Created by 周椿杰 on 2026/2/18.
//

import SwiftUI

struct MainView: View {
    @State private var selectedTab: Tab = .clean

    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $selectedTab)
                .frame(minWidth: 200)
        } detail: {
            DetailView(tab: selectedTab)
        }
    }
}

#Preview {
    MainView()
        .frame(width: 900, height: 600)
}
