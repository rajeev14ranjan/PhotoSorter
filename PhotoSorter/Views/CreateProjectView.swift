//
//  CreateProjectView.swift
//  PhotoSorter
//
//  Created by Rajeev Ranjan on 04/12/25.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct CreateProjectView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var projectName: String = ""
    @State private var sourceFolders: [String] = []
    @State private var folderURLs: [URL] = []
    @State private var targetSelectionCount: String = "50"
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create New Project")
                .font(.title)
                .padding(.top)
            
            Form {
                Section {
                    TextField("Project Name", text: $projectName)
                        .textFieldStyle(.roundedBorder)
                } header: {
                    Text("Project Information")
                }
                
                Section {
                    TextField("Number of photos to select", text: $targetSelectionCount)
                        .textFieldStyle(.roundedBorder)
                } header: {
                    Text("Target Selection Count")
                }
                
                Section {
                    ForEach(sourceFolders, id: \.self) { folder in
                        HStack {
                            Image(systemName: "folder.fill")
                                .foregroundColor(.blue)
                            Text(URL(fileURLWithPath: folder).lastPathComponent)
                            Spacer()
                            Button {
                                sourceFolders.removeAll { $0 == folder }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    Button {
                        selectFolders()
                    } label: {
                        Label("Add Folder", systemImage: "plus.circle.fill")
                    }
                } header: {
                    Text("Source Folders (\(sourceFolders.count))")
                }
            }
            .formStyle(.grouped)
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button("Create") {
                    createProject()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!isValid)
            }
            .padding()
        }
        .frame(width: 500, height: 500)
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private var isValid: Bool {
        !projectName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !sourceFolders.isEmpty &&
        Int(targetSelectionCount) != nil &&
        (Int(targetSelectionCount) ?? 0) > 0
    }
    
    private func selectFolders() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = true
        panel.canCreateDirectories = false
        panel.message = "Select folders containing photos"
        
        if panel.runModal() == .OK {
            for url in panel.urls {
                if !sourceFolders.contains(url.path) {
                    sourceFolders.append(url.path)
                    folderURLs.append(url)
                }
            }
        }
    }
    
    private func createBookmarks(for urls: [URL]) -> [Data] {
        var bookmarks: [Data] = []
        for url in urls {
            do {
                let bookmark = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
                bookmarks.append(bookmark)
            } catch {
                print("Failed to create bookmark for \(url.path): \(error)")
            }
        }
        return bookmarks
    }
    
    private func createProject() {
        guard let targetCount = Int(targetSelectionCount), targetCount > 0 else {
            errorMessage = "Please enter a valid target selection count"
            showingError = true
            return
        }
        
        let bookmarks = createBookmarks(for: folderURLs)
        print("Creating project with \(bookmarks.count) bookmarks for \(folderURLs.count) folders")
        
        let project = Project(
            name: projectName.trimmingCharacters(in: .whitespaces),
            sourceFolders: sourceFolders,
            targetSelectionCount: targetCount,
            folderBookmarks: bookmarks
        )
        
        modelContext.insert(project)
        dismiss()
    }
}
