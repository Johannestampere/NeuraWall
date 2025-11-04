//
//  SettingsView.swift
//  NeuraWall
//
//  Created by Johannes Tampere on 04.11.2025.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("openai_api_key") private var apiKey: String = ""
    @AppStorage("selected_model") private var selectedModel: String = "gpt-image-1"
    @AppStorage("keywords") private var keywords: String = ""

    @State private var isBusy = false
    private let models = ["gpt-image-1", "dall-e-3"]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("NeuraWall").font(.title2).bold()

            Text("OpenAI API Key:")
            SecureField("sk-...", text: $apiKey)
                .textFieldStyle(.roundedBorder)
                .disableAutocorrection(true)

            Text("Model:")
            Picker("Model", selection: $selectedModel) {
                ForEach(models, id: \.self) { Text($0) }
            }
            .pickerStyle(.menu)

            Divider()

            Text("Your wallpaper keywords:")
            TextField("e.g. cats, forest, coffee", text: $keywords)
                .textFieldStyle(.roundedBorder)

            Button(action: {
                Task {
                    guard !apiKey.isEmpty else {
                        print("Missing API key")
                        return
                    }
                    isBusy = true
                    WallpaperScheduler.shared.startAutoCycle(
                        keywords: keywords,
                        apiKey: apiKey,
                        model: selectedModel
                    )
                    isBusy = false
                }
            }) {
                HStack {
                    if isBusy { ProgressView() }
                    Text(isBusy ? "Starting..." : "Start Auto Wallpapers")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(apiKey.isEmpty || keywords.isEmpty || isBusy)

            Spacer()
        }
        .padding(16)
        .frame(width: 340, height: 280)
    }
}
