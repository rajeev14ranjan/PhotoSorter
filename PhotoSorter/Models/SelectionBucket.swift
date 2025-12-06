//
//  SelectionBucket.swift
//  PhotoSorter
//
//  Created by Rajeev Ranjan on 04/12/25.
//

import Foundation
import SwiftUI

enum SelectionBucket: Int, CaseIterable, Codable, Hashable, Identifiable {
  case all = 0
  case selected = 1
  case shortlisted = 2
  case unsure = 3
  case rejected = 4
  
  var id: Int { self.rawValue }
  
  var iconName: String {
    switch self {
    case .all:
      return "circle.badge.exclamationmark"
    case .selected:
      return "heart.fill"
    case .shortlisted:
      return "flag.fill"
    case .unsure:
      return "questionmark.circle.fill"
    case .rejected:
      return "xmark.circle.fill"
    }
  }
  
  var color: Color {
    switch self {
    case .all:
      return .gray
    case .selected:
      return .green
    case .shortlisted:
      return .blue
    case .unsure:
      return .orange
    case .rejected:
      return .red
    }
  }
  
  var label: String {
    switch self {
    case .all:
      return "All Photos"
    case .selected:
      return "Selected"
    case .shortlisted:
      return "Shortlisted"
    case .unsure:
      return "Unsure"
    case .rejected:
      return "Rejected"
    }
  }
}
