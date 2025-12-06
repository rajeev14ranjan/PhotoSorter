//
//  ImageCache.swift
//  PhotoSorter
//
//  Created for performance optimization
//

import Foundation
import AppKit

/// Thread-safe LRU cache for loaded images
@MainActor
class ImageCache {
    static let shared = ImageCache()
    
    private var cache = NSCache<NSString, NSImage>()
    private let maxMemoryMB: Int = 500 // 500MB cache limit
    
    private init() {
        cache.totalCostLimit = maxMemoryMB * 1024 * 1024
        cache.countLimit = 25 // Max 25 images in memory
    }
    
    func getImage(forPath path: String) -> NSImage? {
        return cache.object(forKey: path as NSString)
    }
    
    func setImage(_ image: NSImage, forPath path: String) {
        // Estimate image size (rough approximation)
        let estimatedSize = Int(image.size.width * image.size.height * 4) // 4 bytes per pixel
        cache.setObject(image, forKey: path as NSString, cost: estimatedSize)
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
    
    func removeImage(forPath path: String) {
        cache.removeObject(forKey: path as NSString)
    }
}
