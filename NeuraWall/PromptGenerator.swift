//
//  PromptGenerator.swift
//  NeuraWall
//
//  Created by Johannes Tampere on 04.11.2025.
//

import Foundation

final class PromptGenerator {
    static let shared = PromptGenerator()
    private init() {}
    
    func generatePrompt(from keywords: [String], timeOfDay: String, apiKey: String) async -> String? {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else { return nil }
        
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let joined = keywords.joined(separator: ", ")
        
        let systemPrompt = """
            You are a prompt crafter for an AI wallpaper generator. 
            The user gives you a few keywords describing their mood or themes.
            Generate one short, vivid image prompt for a wallpaper suited for the \(timeOfDay).
            It should be visual, cinematic, and use natural language (no AI jargon).
        """
        
        let userPrompt = "User keywords: \(joined)"
        let body: [String: Any] = [
            "model": "gpt-4-turbo",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userPrompt]
            ]
        ]
        
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, _) = try await URLSession.shared.data(for: req)
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let message = (choices.first?["message"] as? [String: Any])?["content"] as? String {
                print("GPT Prompt: \(message)")
                return message
            }
        } catch {
            print("GPT prompt generation failed: \(error)")
        }
        return nil
    }
}
