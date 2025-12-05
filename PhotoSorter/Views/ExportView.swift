//
//  ExportView.swift
//  PhotoSorter
//
//  Created by Rajeev Ranjan on 04/12/25.
//

import SwiftUI

struct ExportView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var exportViewModel: ExportViewModel
    
    init(photoSortingViewModel: PhotoSortingViewModel) {
        _exportViewModel = StateObject(wrappedValue: ExportViewModel(photoSortingViewModel: photoSortingViewModel))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Export Photos")
                .font(.title)
                .padding(.top)
            
            Text("Select which categories to export:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Form {
                Section {
                    ForEach(SelectionBucket.allCases.filter { $0 != .unrated }, id: \.self) { bucket in
                        Toggle(isOn: Binding(
                            get: { exportViewModel.selectedBuckets.contains(bucket) },
                            set: { _ in exportViewModel.toggleBucket(bucket) }
                        )) {
                            HStack {
                                Image(systemName: bucket.iconName)
                                    .foregroundColor(bucket.color)
                                Text(bucket.rawValue)
                                Spacer()
                                Text("\(exportViewModel.photoSortingViewModel.bucketCounts[bucket] ?? 0) photos")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Categories")
                }
                
                Section {
                    HStack {
                        Text("Total photos to export:")
                            .font(.headline)
                        Spacer()
                        Text("\(exportViewModel.totalPhotosToExport)")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                }
            }
            .formStyle(.grouped)
            
            if exportViewModel.isExporting {
                VStack(spacing: 12) {
                    ProgressView(value: exportViewModel.exportProgress, total: Double(exportViewModel.totalPhotosToExport)) {
                        Text("Exporting photos...")
                            .font(.headline)
                    } currentValueLabel: {
                        Text("\(exportViewModel.exportedCount) of \(exportViewModel.totalPhotosToExport)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .progressViewStyle(.linear)
                    .frame(width: 400)
                }
                .padding()
            }
            
            if let url = exportViewModel.exportURL, !exportViewModel.isExporting {
                VStack(spacing: 8) {
                    Text("Export Location:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text(url.path)
                            .font(.caption)
                            .foregroundColor(.blue)
                            .textSelection(.enabled)
                            .lineLimit(2)
                            .truncationMode(.middle)
                        
                        Button(action: exportViewModel.openInFinder) {
                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(.plain)
                        .help("Show in Finder")
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
            }
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                .disabled(exportViewModel.isExporting)
                
                Spacer()
                
                Button("Export...") {
                    exportViewModel.selectDestinationAndExport()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!exportViewModel.canExport)
            }
            .padding()
        }
        .frame(width: 500, height: 450)
        .alert("Export Complete", isPresented: $exportViewModel.showingSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text(exportViewModel.exportMessage)
        }
    }
}
