//
//  PhotoSortingView.swift
//  PhotoSorter
//
//  Created by Rajeev Ranjan on 04/12/25.
//

import SwiftUI
import SwiftData

struct PhotoSortingView: View {
  let project: Project
  @Environment(\.modelContext) private var modelContext
  @StateObject private var viewModel: PhotoSortingViewModel
  @State private var showingExport = false

  init(project: Project) {
    self.project = project
    _viewModel = StateObject(wrappedValue: PhotoSortingViewModel(project: project))
  }

  var body: some View {
    ZStack {
      if viewModel.isLoading {
        VStack(spacing: 20) {
          ProgressView(value: viewModel.importProgress) {
            Text("Importing photos...")
              .font(.headline)
          } currentValueLabel: {
            Text("\(viewModel.importedCount) photos imported")
              .font(.caption)
              .foregroundColor(.secondary)
          }
          .progressViewStyle(.linear)
          .frame(width: 300)
          
          if viewModel.importedCount > 0 {
            Button("Cancel") {
              viewModel.cancelImport()
            }
            .buttonStyle(.bordered)
          }
        }
        .padding()
        .background(Color(.windowBackgroundColor))
        .cornerRadius(12)
      } else if viewModel.currentPhoto == nil {
        VStack(spacing: 20) {
          Image(systemName: "photo.on.rectangle.angled")
            .font(.system(size: 60))
            .foregroundColor(.secondary)

          Text("No photos in \(viewModel.currentFilter.label)")
            .font(.title2)
            .foregroundColor(.secondary)

          Text("Select another filter to see photos")
            .font(.subheadline)
            .foregroundColor(.secondary)

          Picker("Switch to", selection: $viewModel.currentFilter) {
            ForEach(SelectionBucket.allCases, id: \.self) { bucket in
              HStack {
                Image(systemName: bucket.iconName)
                Text(bucket.label)
                Text("(\(viewModel.bucketCounts[bucket] ?? 0))")
                  .foregroundColor(.secondary)
              }
              .tag(bucket)
            }
          }
          .pickerStyle(.menu)
          .frame(width: 250)
        }
        .padding()
      } else {
        ZStack {
          // Full screen photo display
          PhotoDisplayView(viewModel: viewModel)

          // Top transparent control bar overlay
          VStack {
            HStack(spacing: 16) {
              Spacer()
              StatsBarView(viewModel: viewModel)

              Spacer()

              Button(action: {
                showingExport = true
              }) {
                Image(systemName: "square.and.arrow.up")
                  .font(.system(size: 20))
                  .foregroundColor(.white)
                  .padding(10)
                  .background(.clear)
                  .cornerRadius(8)
              }
              .buttonStyle(.borderless)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
              LinearGradient(
                gradient: Gradient(colors: [
                  Color.black.opacity(0.8),
                  Color.clear
                ]),
                startPoint: .top,
                endPoint: .bottom
              )
            )

            Spacer()
          }

          // Bottom bucket selection overlaid on photo
          VStack {
            Spacer()
            BucketSelectionView(viewModel: viewModel)
              .padding()
              .background(
                LinearGradient(
                  gradient: Gradient(colors: [
                    Color.clear,
                    Color.black.opacity(0.6)
                  ]),
                  startPoint: .top,
                  endPoint: .bottom
                )
              )
          }
        }
        .ignoresSafeArea()
      }
    }
    .sheet(isPresented: $showingExport) {
      ExportView(photoSortingViewModel: viewModel)
    }
    .onAppear {
      viewModel.setModelContext(modelContext)
    }
  }
}
