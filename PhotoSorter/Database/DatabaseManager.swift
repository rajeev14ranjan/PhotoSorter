//
//  DatabaseManager.swift
//  PhotoSorter
//
//  Created by Rajeev Ranjan on 04/12/25.
//

import Foundation
import SwiftData

@MainActor
class DatabaseManager {
    static let shared = DatabaseManager()
    
    private init() {}
    
    // MARK: - Project Operations
    
    func saveProject(_ project: Project, context: ModelContext) {
        context.insert(project)
        try? context.save()
    }
    
    func getAllProjects(context: ModelContext) -> [Project] {
        let descriptor = FetchDescriptor<Project>(sortBy: [SortDescriptor(\.dateModified, order: .reverse)])
        return (try? context.fetch(descriptor)) ?? []
    }
    
    func deleteProject(_ project: Project, context: ModelContext) {
        // Delete all photos for this project first
        let projectId = project.id
        var photoDescriptor = FetchDescriptor<Photo>()
        photoDescriptor.predicate = #Predicate<Photo> { photo in
            photo.projectId == projectId
        }
        if let photos = try? context.fetch(photoDescriptor) {
            photos.forEach { context.delete($0) }
        }
        
        context.delete(project)
        try? context.save()
    }
    
    // MARK: - Photo Operations
    
    func savePhoto(_ photo: Photo, context: ModelContext) {
        context.insert(photo)
        try? context.save()
    }
    
    func savePhotos(_ photos: [Photo], context: ModelContext) {
        photos.forEach { context.insert($0) }
        try? context.save()
    }
    
    func getPhotos(forProject projectId: UUID, context: ModelContext) -> [Photo] {
        var descriptor = FetchDescriptor<Photo>(sortBy: [SortDescriptor(\.dateCreated)])
        descriptor.predicate = #Predicate<Photo> { photo in
            photo.projectId == projectId
        }
        return (try? context.fetch(descriptor)) ?? []
    }
    
    func updatePhotoBucket(_ photo: Photo, bucket: SelectionBucket, context: ModelContext) {
        photo.bucket = bucket
        try? context.save()
    }
}
