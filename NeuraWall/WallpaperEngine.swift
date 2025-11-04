//
//  WallpaperEngine.swift
//  NeuraWall
//
//  Created by Johannes Tampere on 04.11.2025.
//

import Foundation
import AppKit

final class WallpaperEngine {
    static let shared = WallpaperEngine()
    private init() {}
    
    func generateAndSetWallpaper(prompt: String, apiKey: String, model: String) async {
        print("Generating wallpaper based on prompt: \(prompt)")
        
        guard let imageData = await generateImage(prompt: prompt, apiKey: apiKey, model: model) else {
            print("No image data received.")
            return
        }
        
        let fileURL = saveImageToDisk(data: imageData)
        
        setWallpaper(at: fileURL)
    }
    
    private func generateImage(prompt: String, apiKey: String, model: String) async -> Data? {
        guard let url = URL(string: "https://api.openai.com/v1/images/generations") else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "model": model,
            "prompt": prompt,
            "size": "auto"
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                if let text = String(data: data, encoding: .utf8) {
                    print("API error: \(text)")
                }
                return nil
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let arr = json["data"] as? [[String: Any]],
               let b64 = arr.first?["b64_json"] as? String,
               let decoded = Data(base64Encoded: b64) {
                return decoded
            }
        } catch {
            print("Network error: \(error)")
        }
        
        return nil
    }
    
    private func saveImageToDisk(data: Data) -> URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("NeuraWall", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let fileURL = dir.appendingPathComponent("current_wallpaper.png")
        try? data.write(to: fileURL)
        print("Saved wallpaper to \(fileURL.path)")
        return fileURL
    }

    private func setWallpaper(at fileURL: URL) {
        for screen in NSScreen.screens {
            do {
                try NSWorkspace.shared.setDesktopImageURL(fileURL, for: screen, options: [:])
                print("Wallpaper applied on \(screen.localizedName)")
            } catch {
                print("Could not set wallpaper: \(error)")
            }
        }
    }
}
