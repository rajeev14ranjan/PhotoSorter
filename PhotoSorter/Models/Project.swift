//
//  Project.swift
//  PhotoSorter
//
//  Created by Rajeev Ranjan on 04/12/25.
//

import Foundation
import SwiftData

@Model
class Project {
    @Attribute(.unique) var id: UUID
    var name: String
    var sourceFolders: [String]
    @Attribute(.externalStorage) var folderBookmarks: [Data]
    var targetSelectionCount: Int
    var dateCreated: Date
    var dateModified: Date
    
    @Relationship(deleteRule: .cascade, inverse: \Photo.project)
    var photos: [Photo]? = []
    
    init(name: String, sourceFolders: [String], targetSelectionCount: Int, folderBookmarks: [Data] = []) {
        self.id = UUID()
        self.name = name
        self.sourceFolders = sourceFolders
        self.folderBookmarks = folderBookmarks
        self.targetSelectionCount = targetSelectionCount
        self.dateCreated = Date()
        self.dateModified = Date()
    }
}
