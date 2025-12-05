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
    
    init(path: String, dateCreated: Date, projectId: UUID) {
        self.id = UUID()
        self.path = path
        self.bucket = .unrated
        self.dateCreated = dateCreated
        self.projectId = projectId
    }
}
