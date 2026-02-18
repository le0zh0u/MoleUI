//
//  UninstallView.swift
//  MoleUI
//
//  Created by 周椿杰 on 2026/2/18.
//

import SwiftUI

struct UninstallView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "trash")
                .font(.system(size: 60))
                .foregroundColor(.red)
            Text("Uninstall")
                .font(.largeTitle)
            Text("Remove apps completely")
                .foregroundColor(.secondary)
            Text("Coming soon in Sprint 4")
                .font(.caption)
                .foregroundColor(.orange)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    UninstallView()
}
