//
//  BucketSelectionView.swift
//  PhotoSorter
//
//  Created by Rajeev Ranjan on 06/12/25.
//

import SwiftUI

struct BucketSelectionView: View {
  @ObservedObject var viewModel: PhotoSortingViewModel

  var body: some View {
    HStack(spacing: 30) {
      Spacer()

      ForEach(viewModel.availableBucketsForSelection, id: \.self) { bucket in
        Button {
          viewModel.selectBucket(bucket)
        } label: {
          HStack(spacing: 6) {
            Image(systemName: bucket.iconName)
              .font(.system(size: 32))
            Text(viewModel.bucketDisplayName(for: bucket))
              .font(.system(size: 20, weight: .semibold))
          }
          .foregroundColor(bucket.color)
          .padding(.horizontal, 16)
          .padding(.vertical, 10)
        }
        .buttonStyle(.glass)
        .keyboardShortcut(keyEquivalent(for: bucket), modifiers: [])
        .onHover { isHovered in
          if isHovered {
            NSCursor.pointingHand.push()
          } else {
            NSCursor.pop()
          }
        }
      }

      // Reset button - only show when not viewing unrated
      if viewModel.shouldShowResetButton {
        Button {
          viewModel.resetCurrentPhotoToUnrated()
        } label: {
          HStack(spacing: 4) {
            Image(systemName: "arrow.uturn.backward.circle")
              .font(.system(size: 28))
              .foregroundColor(.purple)
            Text("Reset")
              .font(.system(size: 12, weight: .medium))
          }
          .padding(.horizontal, 16)
          .padding(.vertical, 10)
        }
        .buttonStyle(.glass)
        .keyboardShortcut("0", modifiers: [])
      }

      Spacer()
    }
  }

  private func keyEquivalent(for bucket: SelectionBucket) -> KeyEquivalent {
    switch bucket {
    case .selected: return "1"
    case .shortlisted: return "2"
    case .unsure: return "3"
    case .rejected: return "4"
    case .all: return " "
    }
  }
}
