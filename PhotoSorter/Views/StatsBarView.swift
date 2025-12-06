//
//  StatsBarView.swift
//  PhotoSorter
//
//  Created by Rajeev Ranjan on 06/12/25.
//

import SwiftUI

struct StatsBarView: View {
  @ObservedObject var viewModel: PhotoSortingViewModel

  var body: some View {
    HStack(spacing: 24) {
      HStack(spacing: 8) {
        Picker("Viewing:", selection: $viewModel.currentFilter) {
          ForEach(SelectionBucket.allCases, id: \.self) { bucket in
            HStack {
              Image(systemName: bucket.iconName)
              Text(bucket.label)
            }
            .font(.system(size: 18, weight: .medium))
            .tag(bucket)
          }
        }
        .pickerStyle(.menu)
        .font(.system(size: 18))
        .frame(width: 200)
      }

      Divider()
        .frame(height: 30)
        .background(Color.white.opacity(0.5))

      HStack(spacing: 6) {
        Image(systemName: "photo")
          .font(.system(size: 13))
          .foregroundColor(.white.opacity(0.7))
        Text("\(viewModel.currentIndex + 1) of \(viewModel.filteredPhotos.count)")
          .font(.system(size: 14, weight: .medium))
          .foregroundColor(.white)
      }

      Divider()
        .frame(height: 30)
        .background(Color.white.opacity(0.5))

      HStack(spacing: 16) {
        StatItemView(
          icon: "photo.stack",
          label: "Total",
          value: "\(viewModel.allPhotos.count)",
          color: .white.opacity(0.7)
        )

        StatItemView(
          icon: "arrow.down.circle",
          label: "Remaining",
          value: "\(viewModel.remainingToSelect)",
          color: .white.opacity(0.7)
        )
      }

      Divider()
        .frame(height: 30)
        .background(Color.white.opacity(0.5))

      HStack(spacing: 16) {
        ForEach(SelectionBucket.allCases, id: \.self) { bucket in
          if bucket != .all {
            StatItemView(
              icon: bucket.iconName,
              label: bucket.label,
              value: "\(viewModel.bucketCounts[bucket] ?? 0)",
              color: bucket.color
            )
          }
        }
      }
    }
  }
}

struct StatItemView: View {
  let icon: String
  let label: String
  let value: String
  let color: Color

  var body: some View {
    VStack(alignment: .center, spacing: 1) {
      HStack(spacing: 5) {
        Image(systemName: icon)
          .font(.system(size: 14))
          .foregroundColor(color)
        Text(value)
          .font(.system(size: 15, weight: .semibold))
          .foregroundColor(.white)
      }
      Text(label)
        .font(.system(size: 11))
        .foregroundColor(.white.opacity(0.7))
    }
  }
}
