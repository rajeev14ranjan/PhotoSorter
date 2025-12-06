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
            updateCurrentPhoto()
        }
    }
    @Published var isLoading: Bool = false
    
    private var modelContext: ModelContext?
    private let fileManager = FileManager.default
    private var accessedURLs: [URL] = []
    
    var filteredPhotos: [Photo] {
      return allPhotos.filter { $0.bucket == currentFilter }
    }
    
    var bucketCounts: [SelectionBucket: Int] {
        var counts: [SelectionBucket: Int] = [:]
        for bucket in SelectionBucket.allCases {
            counts[bucket] = allPhotos.filter { $0.bucket == bucket }.count
        }
        return counts
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
            allPhotos = existingPhotos.sorted { $0.dateCreated < $1.dateCreated }
            updateCurrentPhoto()
            isLoading = false
            return
        }
        
        // Import new photos
        let sourceFolders = project.sourceFolders
        
        Task.detached {
            let supportedExtensions = ["jpg", "jpeg", "png", "heic"]
            let fileManager = FileManager.default
            var photoData: [(path: String, date: Date)] = []
            
            let foldersArray = Array(sourceFolders)
            for folderPath in foldersArray {
                let folderURL = URL(fileURLWithPath: folderPath)
                
                guard let enumerator = fileManager.enumerator(at: folderURL, includingPropertiesForKeys: [.creationDateKey, .contentModificationDateKey]) else { continue }
                
                for case let fileURL as URL in enumerator {
                    let fileExtension = fileURL.pathExtension.lowercased()
                    
                    if supportedExtensions.contains(fileExtension) {
                        do {
                            let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
                            let creationDate = attributes[.creationDate] as? Date ?? Date()
                            photoData.append((path: fileURL.path, date: creationDate))
                        } catch {
                            print("Error reading file attributes: \(error)")
                        }
                    }
                }
            }
            
            // Sort by creation date
            let sortedPhotoData = photoData.sorted { $0.date < $1.date }
            
            // Save to database
            await MainActor.run {
                guard let modelContext = self.modelContext else { return }
                
                let photos = sortedPhotoData.map { Photo(path: $0.path, dateCreated: $0.date, project: self.project) }
                photos.forEach { modelContext.insert($0) }
                try? modelContext.save()
                
                self.allPhotos = photos
                self.updateCurrentPhoto()
                self.isLoading = false
            }
        }
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
            try? modelContext.save()
        }
        
        moveNext()
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
            try? modelContext.save()
        }
        
        moveNext()
    }
    
    // MARK: - Computed Properties for Views
    
    /// Returns the filename of the current photo
    var currentPhotoFileName: String {
        guard let photo = currentPhoto else { return "" }
        return URL(fileURLWithPath: photo.path).lastPathComponent
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
        // Clean up security-scoped access
        for url in accessedURLs {
            url.stopAccessingSecurityScopedResource()
        }
    }
}
