//
//  SettingsView.swift
//  NeuraWall
//
//  Created by Johannes Tampere on 04.11.2025.
//

import SwiftUI

// UI for the pop-up
struct SettingsView: View {
    @State private var prompt = ""
    @State private var isBusy = false

    var body: some View {
        // vertical stack
        VStack(alignment: .leading, spacing: 14) {
            Text("NeuraWall")
                .font(.title2).bold()

            Text("Describe the wallpaper you’d like:")
                .font(.subheadline)

            TextField("e.g. sunset over forest, cozy vibes", text: $prompt)
                .textFieldStyle(.roundedBorder)

            Button(action: {
                Task {
                    isBusy = true
                    await WallpaperEngine.shared.generateAndSetWallpaper(prompt: prompt)
                    isBusy = false
                }
            }) {
                HStack {
                    if isBusy { ProgressView() }
                    Text(isBusy ? "Generating..." : "Generate Wallpaper")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(prompt.trimmingCharacters(in: .whitespaces).isEmpty || isBusy)

            Spacer()
        }
        .padding(16)
        .frame(width: 300, height: 200)
    }
}
