//
//  PhotoSortingViewModel.swift
//  PhotoSorter
//
//  Created by Rajeev Ranjan on 04/12/25.
//

import Foundation
import AppKit
import Combine
import SwiftData

@MainActor
class PhotoSortingViewModel: ObservableObject {
    @Published var project: Project
    @Published var allPhotos: [Photo] = []
    @Published var currentPhoto: Photo?
    @Published var currentIndex: Int = 0
    @Published var currentFilter: SelectionBucket = .all {
        didSet {
            currentIndex = 0
            filteredPhotosCache = nil
            updateCurrentPhoto()
        }
    }
    @Published var isLoading: Bool = false
    @Published var importProgress: Double = 0
    @Published var importedCount: Int = 0
    
    private var modelContext: ModelContext?
    private let fileManager = FileManager.default
    private var accessedURLs: [URL] = []
    private var importTask: Task<Void, Never>?
    
    // Performance optimizations
    private var filteredPhotosCache: [Photo]?
    private var bucketCountsCache: [SelectionBucket: Int]?
    private var cacheInvalidated = true
    
    var filteredPhotos: [Photo] {
        if let cached = filteredPhotosCache {
            return cached
        }
        let filtered = allPhotos.filter { $0.bucket == currentFilter }
        filteredPhotosCache = filtered
        return filtered
    }
    
    var bucketCounts: [SelectionBucket: Int] {
        if !cacheInvalidated, let cached = bucketCountsCache {
            return cached
        }
        
        var counts: [SelectionBucket: Int] = [:]
        for bucket in SelectionBucket.allCases {
            counts[bucket] = 0
        }
        
        // Single pass through array
        for photo in allPhotos {
            counts[photo.bucket, default: 0] += 1
        }
        
        bucketCountsCache = counts
        cacheInvalidated = false
        return counts
    }
    
    private func invalidateCaches() {
        filteredPhotosCache = nil
        cacheInvalidated = true
    }
    
    var selectedCount: Int {
        bucketCounts[.selected] ?? 0
    }
    
    var remainingToSelect: Int {
        max(0, project.targetSelectionCount - selectedCount)
    }
    
    init(project: Project) {
        self.project = project
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadPhotos()
    }
    
    func loadPhotos() {
        guard let modelContext = modelContext else { return }
        isLoading = true
        importProgress = 0
        importedCount = 0
        
        // Restore access to folders using security-scoped bookmarks
        restoreFolderAccess()
        
        // Check if photos already exist in database
        let projectId = project.id
        var descriptor = FetchDescriptor<Photo>(sortBy: [SortDescriptor(\.dateCreated)])
        descriptor.predicate = #Predicate<Photo> { photo in
            photo.projectId == projectId
        }
        let existingPhotos = (try? modelContext.fetch(descriptor)) ?? []
        
        if !existingPhotos.isEmpty {
            allPhotos = existingPhotos
            invalidateCaches()
            updateCurrentPhoto()
            isLoading = false
            return
        }
        
        // Import new photos with progress tracking and batching
        let sourceFolders = project.sourceFolders
        
        importTask = Task.detached(priority: .userInitiated) {
            let supportedExtensions = Set(["jpg", "jpeg", "png", "heic"])
            let fileManager = FileManager.default
            var photoData: [(path: String, date: Date, fileName: String)] = []
            
            // Phase 1: Discover all files
            let foldersArray = Array(sourceFolders)
            for folderPath in foldersArray {
                let folderURL = URL(fileURLWithPath: folderPath)
                
                guard let enumerator = fileManager.enumerator(
                    at: folderURL,
                    includingPropertiesForKeys: [.creationDateKey, .contentModificationDateKey],
                    options: [.skipsHiddenFiles]
                ) else { continue }
                
                while let fileURL = enumerator.nextObject() as? URL {
                    // Check for cancellation
                    if Task.isCancelled { return }
                    
                    let fileExtension = fileURL.pathExtension.lowercased()
                    
                    if supportedExtensions.contains(fileExtension) {
                        do {
                            let resourceValues = try fileURL.resourceValues(forKeys: [.creationDateKey])
                            let creationDate = resourceValues.creationDate ?? Date()
                            let fileName = fileURL.lastPathComponent
                            photoData.append((path: fileURL.path, date: creationDate, fileName: fileName))
                        } catch {
                            print("Error reading file attributes: \(error)")
                        }
                    }
                }
            }
            
            // Sort by creation date
            let sortedPhotoData = photoData.sorted { $0.date < $1.date }
            let totalCount = sortedPhotoData.count
            
            // Phase 2: Save to database in batches for better performance
            let batchSize = 100
            var processedCount = 0
            
            for batchStart in stride(from: 0, to: sortedPhotoData.count, by: batchSize) {
                // Check for cancellation
                if Task.isCancelled { return }
                
                let batchEnd = min(batchStart + batchSize, sortedPhotoData.count)
                let batch = Array(sortedPhotoData[batchStart..<batchEnd])
                
                await MainActor.run {
                    guard let modelContext = self.modelContext else { return }
                    
                    let photos = batch.map { Photo(path: $0.path, dateCreated: $0.date, project: self.project) }
                    photos.forEach { modelContext.insert($0) }
                    
                    do {
                        try modelContext.save()
                        
                        // Update progress
                        self.allPhotos.append(contentsOf: photos)
                        processedCount += photos.count
                        self.importedCount = processedCount
                        self.importProgress = Double(processedCount) / Double(totalCount)
                    } catch {
                        print("Error saving batch: \(error)")
                    }
                }
            }
            
            // Finalize
            await MainActor.run {
                self.invalidateCaches()
                self.updateCurrentPhoto()
                self.isLoading = false
            }
        }
    }
    
    func cancelImport() {
        importTask?.cancel()
        isLoading = false
    }
    
    func updateCurrentPhoto() {
        let filtered = filteredPhotos
        if currentIndex < filtered.count {
            currentPhoto = filtered[currentIndex]
        } else {
            currentIndex = max(0, filtered.count - 1)
            currentPhoto = filtered.isEmpty ? nil : filtered[currentIndex]
        }
    }
    
    func selectBucket(_ bucket: SelectionBucket) {
        guard let photo = currentPhoto, let modelContext = modelContext else { return }
        
        if let index = allPhotos.firstIndex(where: { $0.id == photo.id }) {
            allPhotos[index].bucket = bucket
            
            // Invalidate caches when bucket changes
            invalidateCaches()
            
            // Batch saves - only save every 10th photo or when switching photos
            // This significantly improves performance for rapid categorization
            if index % 10 == 0 {
                try? modelContext.save()
            }
        }
        
        moveNext()
    }
    
    func forceSave() {
        guard let modelContext = modelContext else { return }
        try? modelContext.save()
    }
    
    func moveNext() {
        let filtered = filteredPhotos
        if currentIndex < filtered.count - 1 {
            currentIndex += 1
        } else if !filtered.isEmpty {
            currentIndex = 0
        }
        updateCurrentPhoto()
    }
    
    func movePrevious() {
        let filtered = filteredPhotos
        if currentIndex > 0 {
            currentIndex -= 1
        } else if !filtered.isEmpty {
            currentIndex = filtered.count - 1
        }
        updateCurrentPhoto()
    }
    
    func changeFilter(to bucket: SelectionBucket) {
        currentFilter = bucket
        currentIndex = 0
        updateCurrentPhoto()
    }
    
    func resetCurrentPhotoToUnrated() {
        guard let photo = currentPhoto, let modelContext = modelContext else { return }
        
        if let index = allPhotos.firstIndex(where: { $0.id == photo.id }) {
            allPhotos[index].bucket = .all
            invalidateCaches()
            try? modelContext.save()
        }
        
        moveNext()
    }
    
    // MARK: - Computed Properties for Views
    
    /// Returns the filename of the current photo (cached in model)
    var currentPhotoFileName: String {
        guard let photo = currentPhoto else { return "" }
        return photo.fileName
    }
    
    /// Returns the position text for the current photo (e.g., "1 of 10")
    var currentPhotoPositionText: String {
        return "\(currentIndex + 1) of \(filteredPhotos.count)"
    }
    
    /// Returns buckets available for selection (excludes current filter and .all)
    var availableBucketsForSelection: [SelectionBucket] {
        return SelectionBucket.allCases.filter { $0 != .all && $0 != currentFilter }
    }
    
    /// Returns whether the reset button should be shown
    var shouldShowResetButton: Bool {
        return currentFilter != .all
    }
    
    /// Returns the display name for a bucket (removes "ed" suffix)
    func bucketDisplayName(for bucket: SelectionBucket) -> String {
        return bucket.label.replacingOccurrences(of: "ed\\b", with: "", options: .regularExpression)
    }
    
    private func restoreFolderAccess() {
        // Stop accessing previously accessed URLs
        for url in accessedURLs {
            url.stopAccessingSecurityScopedResource()
        }
        accessedURLs.removeAll()
        
        // Restore access from bookmarks
        for bookmark in project.folderBookmarks {
            do {
                var isStale = false
                let url = try URL(resolvingBookmarkData: bookmark, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
                
                if url.startAccessingSecurityScopedResource() {
                    accessedURLs.append(url)
                    print("Restored access to: \(url.path)")
                } else {
                    print("Failed to start accessing: \(url.path)")
                }
                
                if isStale {
                    print("Bookmark is stale for: \(url.path)")
                }
            } catch {
                print("Failed to resolve bookmark: \(error)")
            }
        }
    }
    
    deinit {
        // Cancel any ongoing import
        importTask?.cancel()
        
        // Force save any pending changes
        if let modelContext = modelContext {
            try? modelContext.save()
        }
        
        // Clean up security-scoped access
        for url in accessedURLs {
            url.stopAccessingSecurityScopedResource()
        }
    }
}
