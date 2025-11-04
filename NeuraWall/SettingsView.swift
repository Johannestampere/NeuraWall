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
    @AppStorage("interval_hours") private var intervalHours: Double = 6

    @State private var isBusy = false

    private let models = ["gpt-image-1", "dall-e-3"]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("NeuraWall")
                .font(.title2).bold()

            Group {
                Text("OpenAI API Key:")
                SecureField("sk-...", text: $apiKey)
                    .textFieldStyle(.roundedBorder)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)

                Text("Choose model:")
                Picker("Model", selection: $selectedModel) {
                    ForEach(models, id: \.self) { Text($0) }
                }
                .pickerStyle(.menu)
            }

            Divider()

            Group {
                Text("Wallpaper keywords (comma-separated):")
                TextField("e.g. cats, coffee, stars", text: $keywords)
                    .textFieldStyle(.roundedBorder)

                Text("Change every \(Int(intervalHours)) hours")
                Slider(value: $intervalHours, in: 1...24, step: 1)
            }

            Button(action: {
                Task {
                    guard !apiKey.isEmpty else {
                        print("Missing API key")
                        return
                    }
                    isBusy = true
                    WallpaperScheduler.shared.scheduleRotation(
                        keywords: keywords,
                        intervalHours: intervalHours,
                        apiKey: apiKey,
                        model: selectedModel
                    )
                    isBusy = false
                }
            }) {
                HStack {
                    if isBusy { ProgressView() }
                    Text(isBusy ? "Setting up..." : "Start Wallpaper Rotation")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(apiKey.isEmpty || keywords.isEmpty || isBusy)

            Spacer()
        }
        .padding(16)
        .frame(width: 340, height: 320)
    }
}
