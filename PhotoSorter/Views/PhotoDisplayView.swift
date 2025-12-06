//
//  PhotoDisplayView.swift
//  PhotoSorter
//
//  Created by Rajeev Ranjan on 06/12/25.
//

import SwiftUI

struct PhotoDisplayView: View {
  @ObservedObject var viewModel: PhotoSortingViewModel
  @State private var loadedImage: NSImage?
  @State private var errorMessage: String = ""

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        Color.black

        if viewModel.currentPhoto != nil {
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
                  Text(viewModel.currentPhotoFileName)
                    .font(.caption)
                  Text(viewModel.currentPhotoPositionText)
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
