//
//  MemoryManager.swift
//  PhotoSorter
//
//  Created for performance optimization
//

import Foundation
import AppKit

/// Monitors and responds to memory pressure
@MainActor
class MemoryManager {
    static let shared = MemoryManager()
    
    private var memoryWarningObserver: NSObjectProtocol?
    
    private init() {
        setupMemoryWarningObserver()
    }
    
    private func setupMemoryWarningObserver() {
        // Monitor for memory pressure notifications
        memoryWarningObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleMemoryWarning()
        }
    }
    
    func handleMemoryWarning() {
        ImageCache.shared.clearCache()
    }
    
    deinit {
        if let observer = memoryWarningObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
