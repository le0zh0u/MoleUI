//
//  PurgeView.swift
//  MoleUI
//
//  Created by 周椿杰 on 2026/2/18.
//

import SwiftUI

struct PurgeView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder.badge.minus")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            Text("Purge")
                .font(.largeTitle)
            Text("Clean project artifacts")
                .foregroundColor(.secondary)
            Text("Next up! Coming in Sprint 5")
                .font(.caption)
                .foregroundColor(.green)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    PurgeView()
}
