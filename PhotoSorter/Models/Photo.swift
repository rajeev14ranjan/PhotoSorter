//
//  Photo.swift
//  PhotoSorter
//
//  Created by Rajeev Ranjan on 04/12/25.
//

import Foundation
import SwiftData

@Model
class Photo {
    @Attribute(.unique) var id: UUID
    var path: String
    var bucket: SelectionBucket
    var dateCreated: Date
    
    // Add index for faster queries
    @Attribute var projectId: UUID
    
    // Cache filename to avoid repeated URL parsing
    var fileName: String
    
    var project: Project?
    
    init(path: String, dateCreated: Date, project: Project) {
        self.id = UUID()
        self.path = path
        self.bucket = .all
        self.dateCreated = dateCreated
        self.projectId = project.id
        self.project = project
        self.fileName = URL(fileURLWithPath: path).lastPathComponent
    }
}
