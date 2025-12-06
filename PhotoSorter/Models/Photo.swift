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
    var projectId: UUID
    
    var project: Project?
    
    init(path: String, dateCreated: Date, project: Project) {
        self.id = UUID()
        self.path = path
        self.bucket = .all
        self.dateCreated = dateCreated
        self.projectId = project.id
        self.project = project
    }
}
