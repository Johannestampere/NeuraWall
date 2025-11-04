//
//  AppDelegate.swift
//  NeuraWall
//
//  Created by Johannes Tampere on 04.11.2025.
//

import Cocoa
import SwiftUI

// AppDelegate gets app lifecycle callbacks
final class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover = NSPopover()

    // lifecycle method called by macos after the app finished launching
    func applicationDidFinishLaunching(_ notification: Notification) { // no external label needed
        
        // create the mac menu bar button
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "🖼️"
        statusItem.button?.target = self
        statusItem.button?.action = #selector(togglePopover) // defined below

        popover.behavior = .transient // auto closes when user clicks anywhere else
        popover.contentSize = NSSize(width: 320, height: 240)
        popover.contentViewController = NSHostingController(rootView: SettingsView())
    }

    // makes the popover appear and disappear
    @objc func togglePopover() { // exposes the function to objective c runtime
        if popover.isShown {
            popover.performClose(nil)
        } else if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
}
