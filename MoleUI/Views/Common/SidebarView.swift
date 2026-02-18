//
//  SidebarView.swift
//  MoleUI
//
//  Created by 周椿杰 on 2026/2/18.
//

import SwiftUI

struct SidebarView: View {
    @Binding var selection: Tab

    var body: some View {
        List(Tab.allCases, selection: $selection) { tab in
            NavigationLink(value: tab) {
                Label {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(tab.rawValue)
                            .font(.headline)
                        Text(tab.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } icon: {
                    Image(systemName: tab.icon)
                        .font(.title2)
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("MoleUI")
    }
}

#Preview {
    SidebarView(selection: .constant(.clean))
        .frame(width: 250)
}
