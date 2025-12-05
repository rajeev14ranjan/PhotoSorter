//
//  ProjectListView.swift
//  PhotoSorter
//
//  Created by Rajeev Ranjan on 04/12/25.
//

import SwiftUI
import SwiftData

struct ProjectListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Project.dateModified, order: .reverse) private var projects: [Project]
    @State private var showingCreateProject = false
    @State private var selectedProject: Project?
    
    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                List(projects, selection: $selectedProject) { project in
                    NavigationLink(value: project) {
                        ProjectRowView(project: project)
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            deleteProject(project)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .navigationTitle("PhotoSorter")
                
                // New Project Button at bottom
                Button {
                    showingCreateProject = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                        Text("New Project")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
                .padding()
            }
        } detail: {
            if let project = selectedProject {
                PhotoSortingView(project: project)
            } else {
                VStack {
                    Image(systemName: "photo.stack")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("Select a project or create a new one")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .sheet(isPresented: $showingCreateProject) {
            CreateProjectView()
        }
    }
    
    private func deleteProject(_ project: Project) {
        // Delete all photos for this project
        let projectId = project.id
        var photoDescriptor = FetchDescriptor<Photo>()
        photoDescriptor.predicate = #Predicate<Photo> { photo in
            photo.projectId == projectId
        }
        if let photos = try? modelContext.fetch(photoDescriptor) {
            photos.forEach { modelContext.delete($0) }
        }
        
        modelContext.delete(project)
    }
}

struct ProjectRowView: View {
    let project: Project
    @State private var photoCount: Int = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(project.name)
                .font(.headline)
            Text("\(project.sourceFolders.count) folder(s) • Target: \(project.targetSelectionCount)")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(project.dateModified.formatted(date: .abbreviated, time: .shortened))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}
