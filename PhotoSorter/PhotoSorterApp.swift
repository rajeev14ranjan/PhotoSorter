//
//  PhotoSorterApp.swift
//  PhotoSorter
//
//  Created by Rajeev Ranjan on 04/12/25.
//

import SwiftUI
import SwiftData

@main
struct PhotoSorterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem) {}
            
            CommandGroup(after: .pasteboard) {
                Divider()
                
                Button("Reset All Data") {
                    resetAllData()
                }
                .keyboardShortcut("r", modifiers: [.command, .shift, .option])
            }
        }
        .modelContainer(for: [Project.self, Photo.self])
    }
    
    private func resetAllData() {
        // Delete the entire SwiftData container
        let url = URL.applicationSupportDirectory.appendingPathComponent("default.store")
        let shmURL = url.appendingPathExtension("shm")
        let walURL = url.appendingPathExtension("wal")
        
        // Try to delete all SwiftData files
        try? FileManager.default.removeItem(at: url)
        try? FileManager.default.removeItem(at: shmURL)
        try? FileManager.default.removeItem(at: walURL)
        
        // Exit the app so user can restart with fresh data
        NSApplication.shared.terminate(nil)
    }
}
