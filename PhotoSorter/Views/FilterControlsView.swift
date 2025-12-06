//
//  FilterControlsView.swift
//  PhotoSorter
//
//  Created by Rajeev Ranjan on 06/12/25.
//

import SwiftUI

struct FilterControlsView: View {
  @ObservedObject var viewModel: PhotoSortingViewModel

  var body: some View {
    VStack(spacing: 12) {
      Text("View Filter")
        .font(.system(size: 16, weight: .semibold))
        .padding(.top)

      ForEach(SelectionBucket.allCases, id: \.self) { bucket in
        Button {
          viewModel.changeFilter(to: bucket)
        } label: {
          HStack {
            Image(systemName: bucket.iconName)
              .font(.system(size: 14))
              .foregroundColor(bucket.color)
            Text(bucket.label)
              .font(.system(size: 14))
            Spacer()
            Text("\(viewModel.bucketCounts[bucket] ?? 0)")
              .font(.system(size: 12))
              .foregroundColor(.secondary)
          }
          .padding(.horizontal, 12)
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity)
          .background(
            viewModel.currentFilter == bucket ?
            Color.accentColor.opacity(0.2) :
              Color.clear
          )
          .cornerRadius(6)
        }
        .buttonStyle(.plain)
      }
    }
    .padding()
  }
}
