//
//  SelectionBucket.swift
//  PhotoSorter
//
//  Created by Rajeev Ranjan on 04/12/25.
//

import Foundation
import SwiftUI

enum SelectionBucket: String, CaseIterable, Codable {
    case unrated = "Unrated"
    case definitelySelected = "Definitely Selected"
    case selectionCandidate = "Selection Candidate"
    case notSure = "Not Sure"
    case rejected = "Rejected"
    
    var iconName: String {
        switch self {
        case .unrated:
            return "circle.badge.exclamationmark"
        case .definitelySelected:
            return "heart.fill"
        case .selectionCandidate:
            return "flag.fill"
        case .notSure:
            return "questionmark.circle.fill"
        case .rejected:
            return "xmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .unrated:
            return .gray
        case .definitelySelected:
            return .green
        case .selectionCandidate:
            return .blue
        case .notSure:
            return .orange
        case .rejected:
            return .red
        }
    }

  var bgColor: Color {
    switch self {
    case .unrated:
      return .gray
    case .definitelySelected:
      return .green
    case .selectionCandidate:
      return .green.opacity(0.7)
    case .notSure:
      return .orange
    case .rejected:
      return .red
    }
  }
}
