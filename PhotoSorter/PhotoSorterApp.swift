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
        }
        .modelContainer(for: [Project.self, Photo.self])
    }
}
