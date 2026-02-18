//
//  InstallerView.swift
//  MoleUI
//
//  Created by 周椿杰 on 2026/2/18.
//

import SwiftUI

struct InstallerView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "shippingbox")
                .font(.system(size: 60))
                .foregroundColor(.brown)
            Text("Installer")
                .font(.largeTitle)
            Text("Remove installer files")
                .foregroundColor(.secondary)
            Text("Coming soon in Sprint 9")
                .font(.caption)
                .foregroundColor(.orange)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    InstallerView()
}
