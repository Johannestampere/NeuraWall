//
//  WallpaperScheduler.swift
//  NeuraWall
//
//  Created by Johannes Tampere on 04.11.2025.
//

import Foundation

final class WallpaperScheduler {
    static let shared = WallpaperScheduler()
    private var timer: Timer?
    private var lastPhase: String?
    private init() {}
    
    func startAutoCycle(keywords: String, apiKey: String, model: String) {
        let words = keywords.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        Task {
            await self.updateWallpaper(for: Date(), keywords: words, apiKey: apiKey, model: model)
        }
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { _ in
            Task {
                await self.updateWallpaper(for: Date(), keywords: words, apiKey: apiKey, model: model)
            }
        }
    }
    
    private func updateWallpaper(for date: Date, keywords: [String], apiKey: String, model: String) async {
        let hour = Calendar.current.component(.hour, from: date)

        let phase: String
        
        switch hour {
        case 0..<10:
            phase = "morning"
        case 10..<14:
            phase = "midday"
        case 14..<18:
            phase = "afternoon"
        default:
            phase = "nighttime"
        }
        
        print("Current phase: \(phase) (\(hour):00)")
        
        if phase == lastPhase {
            print("Same phase, skipping regeneration")
            return
        }
        lastPhase = phase
        
        guard let prompt = await PromptGenerator.shared.generatePrompt(from: keywords, timeOfDay: phase, apiKey: apiKey)
        else { return }

        await WallpaperEngine.shared.generateAndSetWallpaper(prompt: prompt, apiKey: apiKey, model: model)
    }
}
