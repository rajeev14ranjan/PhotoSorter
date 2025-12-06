//
//  ExportViewModel.swift
//  PhotoSorter
//
//  Created by Rajeev Ranjan on 05/12/25.
//

import Foundation
import AppKit
import Combine

@MainActor
class ExportViewModel: ObservableObject {
    @Published var selectedBuckets: Set<SelectionBucket> = [.selected]
    @Published var isExporting = false
    @Published var exportProgress: Double = 0
    @Published var exportedCount: Int = 0
    @Published var exportURL: URL?
    @Published var showingSuccess = false
    @Published var exportMessage = ""
    
    let photoSortingViewModel: PhotoSortingViewModel
    
    init(photoSortingViewModel: PhotoSortingViewModel) {
        self.photoSortingViewModel = photoSortingViewModel
    }
    
    var totalPhotosToExport: Int {
        var total = 0
        for bucket in selectedBuckets {
            total += photoSortingViewModel.bucketCounts[bucket] ?? 0
        }
        return total
    }
    
    var canExport: Bool {
        !selectedBuckets.isEmpty && !isExporting
    }
    
    func toggleBucket(_ bucket: SelectionBucket) {
        if selectedBuckets.contains(bucket) {
            selectedBuckets.remove(bucket)
        } else {
            selectedBuckets.insert(bucket)
        }
    }
    
    func selectDestinationAndExport() {
        // NEW APPROACH: Use NSSavePanel to let user name a folder, which grants proper write access
        let panel = NSSavePanel()
        panel.canCreateDirectories = true
        panel.showsTagField = false
        panel.nameFieldLabel = "Export Folder:"
        panel.message = "Choose name and location for export folder"
        panel.prompt = "Export"
        
        // Suggest a folder name
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmmss"
        let timestamp = formatter.string(from: Date())
        let projectName = photoSortingViewModel.project.name.replacingOccurrences(of: "/", with: "-")
        panel.nameFieldStringValue = "\(projectName)_\(timestamp)"
        
        panel.directoryURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        
        panel.begin { [weak self] response in
            guard let self = self else { return }
            
            if response == .OK, let exportURL = panel.url {
                Task { @MainActor in
                    self.startExport(to: exportURL)
                }
            }
        }
    }
    
    private func startExport(to exportURL: URL) {
        // Reset state
        isExporting = true
        exportProgress = 0
        exportedCount = 0
        self.exportURL = nil
        
        let fileManager = FileManager.default
        
        // NSSavePanel gives us the path, but we need to create the directory
        do {
            try fileManager.createDirectory(at: exportURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            isExporting = false
            exportMessage = "Cannot create export folder: \(error.localizedDescription)"
            showingSuccess = true
            return
        }
        
        // Get photos to export
        let photosToExport = photoSortingViewModel.allPhotos.filter { selectedBuckets.contains($0.bucket) }
        let totalCount = photosToExport.count
        
        var successCount = 0
        var errorCount = 0
        
        // Export photos synchronously on main thread
        for (index, photo) in photosToExport.enumerated() {
            let sourceURL = URL(fileURLWithPath: photo.path)
            let destinationFileURL = exportURL.appendingPathComponent(sourceURL.lastPathComponent)
            
            do {
                // Handle duplicate filenames
                var finalDestinationURL = destinationFileURL
                var counter = 1
                while fileManager.fileExists(atPath: finalDestinationURL.path) {
                    let filename = sourceURL.deletingPathExtension().lastPathComponent
                    let ext = sourceURL.pathExtension
                    finalDestinationURL = exportURL.appendingPathComponent("\(filename)_\(counter).\(ext)")
                    counter += 1
                }
                
                try fileManager.copyItem(at: sourceURL, to: finalDestinationURL)
                successCount += 1
            } catch {
                errorCount += 1
            }
            
            // Update progress
            exportProgress = Double(index + 1)
            exportedCount = index + 1
        }
        
        // Complete export
        isExporting = false
        
        if errorCount == 0 {
            self.exportURL = exportURL
            exportMessage = "Exported \(successCount) photos successfully."
        } else {
            exportMessage = "Exported \(successCount) photos successfully. \(errorCount) failed."
        }
        showingSuccess = true
    }
    
    func openInFinder() {
        guard let url = exportURL else { return }
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path)
    }
}
