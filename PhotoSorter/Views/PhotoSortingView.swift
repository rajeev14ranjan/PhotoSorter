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
        VStack {
          ProgressView()
            .scaleEffect(1.5)
          Text("Loading photos...")
            .padding()
        }
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

  struct PhotoDisplayView: View {
    @ObservedObject var viewModel: PhotoSortingViewModel
    @State private var loadedImage: NSImage?
    @State private var errorMessage: String = ""

    var body: some View {
      GeometryReader { geometry in
        ZStack {
          Color.black

          if let photo = viewModel.currentPhoto {
            if let image = loadedImage {
              Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: geometry.size.width, height: geometry.size.height)

              // Navigation arrows overlay
              HStack {
                Button {
                  viewModel.movePrevious()
                } label: {
                  Image(systemName: "chevron.left.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white.opacity(0.7))
                }
                .buttonStyle(.plain)
                .padding(.leading, 40)
                .keyboardShortcut(.leftArrow, modifiers: [])

                Spacer()

                Button {
                  viewModel.moveNext()
                } label: {
                  Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white.opacity(0.7))
                }
                .buttonStyle(.plain)
                .padding(.trailing, 40)
                .keyboardShortcut(.rightArrow, modifiers: [])
              }

              // Photo info overlay
              VStack {
                Spacer()
                HStack {
                  VStack(alignment: .leading) {
                    Text(URL(fileURLWithPath: photo.path).lastPathComponent)
                      .font(.caption)
                    Text("\(viewModel.currentIndex + 1) of \(viewModel.filteredPhotos.count)")
                      .font(.caption2)
                  }
                  .padding(8)
                  .background(Color.black.opacity(0.6))
                  .cornerRadius(8)
                  Spacer()
                }
                .padding()
              }
            } else {
              VStack(spacing: 10) {
                Image(systemName: "exclamationmark.triangle")
                  .font(.system(size: 40))
                  .foregroundColor(.white)
                Text("Unable to load image")
                  .foregroundColor(.white)
                Text(errorMessage)
                  .font(.caption)
                  .foregroundColor(.white.opacity(0.7))
                  .multilineTextAlignment(.center)
                  .padding()
              }
            }
          } else {
            VStack {
              Image(systemName: "photo")
                .font(.system(size: 40))
                .foregroundColor(.white)
              Text("No photo selected")
                .foregroundColor(.white)
            }
          }
        }
        .onChange(of: viewModel.currentPhoto) { oldValue, newValue in
          loadImage()
        }
        .onAppear {
          loadImage()
        }
      }
    }

    private func loadImage() {
      loadedImage = nil
      errorMessage = ""

      guard let photo = viewModel.currentPhoto else { return }

      let path = photo.path
      let url = URL(fileURLWithPath: path)

      // Check if file exists
      guard FileManager.default.fileExists(atPath: path) else {
        errorMessage = "File not found: \(url.lastPathComponent)"
        print("File does not exist at path: \(path)")
        return
      }

      // Try multiple methods to load the image
      if let image = NSImage(contentsOf: url) {
        loadedImage = image
      } else if let image = NSImage(contentsOfFile: path) {
        loadedImage = image
      } else if let data = try? Data(contentsOf: url), let image = NSImage(data: data) {
        loadedImage = image
      } else {
        errorMessage = "Unsupported format: \(url.lastPathComponent)"
        print("Failed to load image from path: \(path)")
        print("File extension: \(url.pathExtension)")
      }
    }
  }

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

  struct BucketSelectionView: View {
    @ObservedObject var viewModel: PhotoSortingViewModel

    var body: some View {
      HStack(spacing: 30) {
        Spacer()

        ForEach(SelectionBucket.allCases.filter { $0 != .all && $0 != viewModel.currentFilter }, id: \.self) { bucket in
          Button {
            viewModel.selectBucket(bucket)
          } label: {
            HStack(spacing: 6) {
              Image(systemName: bucket.iconName)
                .font(.system(size: 32))
              Text(bucket.label.replacingOccurrences(of: "ed\\b", with: "", options: .regularExpression))
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
        if viewModel.currentFilter != .all {
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
}
