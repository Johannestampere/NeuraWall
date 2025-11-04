//
//  NeuraWallApp.swift
//  NeuraWall
//
//  Created by Johannes Tampere on 04.11.2025.
//

import SwiftUI

@main
struct NeuraWallApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
