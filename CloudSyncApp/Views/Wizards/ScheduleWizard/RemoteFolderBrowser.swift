//
//  RemoteFolderBrowser.swift
//  CloudSyncApp
//
//  Folder browser for selecting a path within a remote
//

import SwiftUI

/// A folder browser that allows navigating and selecting a folder from a remote
struct RemoteFolderBrowser: View {
    let remoteName: String
    let isLocal: Bool
    @Binding var selectedPath: String
    let onDismiss: () -> Void

    @State private var currentPath: String = ""
    @State private var folders: [RemoteFile] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    init(remoteName: String, isLocal: Bool = false, selectedPath: Binding<String>, onDismiss: @escaping () -> Void) {
        self.remoteName = remoteName
        self.isLocal = isLocal
        self._selectedPath = selectedPath
        self.onDismiss = onDismiss
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with breadcrumb
            VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                Text("Select Folder")
                    .font(.headline)

                // Breadcrumb navigation
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        Button(action: { navigateTo("") }) {
                            HStack(spacing: 2) {
                                Image(systemName: "house.fill")
                                    .font(.caption)
                                Text("Root")
                                    .font(.caption)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(currentPath.isEmpty ? Color.accentColor.opacity(0.2) : Color.clear)
                            .cornerRadius(4)
                        }
                        .buttonStyle(.plain)

                        if !currentPath.isEmpty {
                            ForEach(pathComponents, id: \.path) { component in
                                HStack(spacing: 2) {
                                    Image(systemName: "chevron.right")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)

                                    Button(action: { navigateTo(component.path) }) {
                                        Text(component.name)
                                            .font(.caption)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 3)
                                            .background(component.path == currentPath ? Color.accentColor.opacity(0.2) : Color.clear)
                                            .cornerRadius(4)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            // Folder list
            if isLoading {
                VStack {
                    ProgressView()
                        .padding()
                    Text("Loading folders...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = errorMessage {
                VStack(spacing: AppTheme.spacingM) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        loadFolders()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else if folders.isEmpty {
                VStack(spacing: AppTheme.spacingM) {
                    Image(systemName: "folder")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("No subfolders")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(folders, id: \.Path) { folder in
                    Button(action: { navigateTo(folder.Path) }) {
                        HStack {
                            Image(systemName: "folder.fill")
                                .foregroundColor(.blue)
                            Text(folder.Name)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .listStyle(.plain)
            }

            Divider()

            // Footer with current selection and buttons
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Selected:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(currentPath.isEmpty ? "/ (root)" : "/\(currentPath)")
                        .font(.system(.body, design: .monospaced))
                        .lineLimit(1)
                }

                Spacer()

                Button("Cancel") {
                    onDismiss()
                }
                .keyboardShortcut(.escape)

                Button("Select") {
                    selectedPath = currentPath
                    onDismiss()
                }
                .keyboardShortcut(.return)
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
        }
        .frame(width: 400, height: 350)
        .onAppear {
            currentPath = selectedPath
            loadFolders()
        }
    }

    private var pathComponents: [(name: String, path: String)] {
        guard !currentPath.isEmpty else { return [] }

        var components: [(name: String, path: String)] = []
        var accumulatedPath = ""

        for part in currentPath.split(separator: "/") {
            if accumulatedPath.isEmpty {
                accumulatedPath = String(part)
            } else {
                accumulatedPath += "/\(part)"
            }
            components.append((name: String(part), path: accumulatedPath))
        }

        return components
    }

    private func navigateTo(_ path: String) {
        currentPath = path
        loadFolders()
    }

    private var isLocalStorage: Bool {
        if isLocal { return true }
        let name = remoteName.lowercased()
        return name == "local" || name == "local storage" || name == "local_storage"
    }

    private func loadFolders() {
        isLoading = true
        errorMessage = nil

        print("[RemoteFolderBrowser] Loading folders for remote: '\(remoteName)', path: '\(currentPath)', isLocal: \(isLocalStorage)")

        Task {
            do {
                let directoriesOnly: [RemoteFile]

                if isLocalStorage {
                    directoriesOnly = try await loadLocalFolders()
                    print("[RemoteFolderBrowser] Loaded \(directoriesOnly.count) local folders")
                } else {
                    let allFiles = try await RcloneManager.shared.listRemoteFiles(
                        remotePath: currentPath,
                        encrypted: false,
                        remoteName: remoteName
                    )

                    directoriesOnly = allFiles
                        .filter { $0.IsDir }
                        .sorted { $0.Name.localizedCaseInsensitiveCompare($1.Name) == .orderedAscending }
                }

                await MainActor.run {
                    folders = directoriesOnly
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to load folders: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }

    private func loadLocalFolders() async throws -> [RemoteFile] {
        let basePath: String
        if currentPath.isEmpty {
            basePath = NSHomeDirectory()
        } else if currentPath.hasPrefix("/") {
            basePath = currentPath
        } else {
            basePath = NSHomeDirectory() + "/" + currentPath
        }

        print("[RemoteFolderBrowser] Loading local folders from: '\(basePath)'")

        let fileManager = FileManager.default
        let contents = try fileManager.contentsOfDirectory(atPath: basePath)
        print("[RemoteFolderBrowser] Found \(contents.count) items in directory")

        var directories: [RemoteFile] = []
        for item in contents {
            if item.hasPrefix(".") { continue }

            let fullPath = basePath + "/" + item
            var isDir: ObjCBool = false
            if fileManager.fileExists(atPath: fullPath, isDirectory: &isDir), isDir.boolValue {
                let relativePath = currentPath.isEmpty ? item : currentPath + "/" + item
                directories.append(RemoteFile(
                    Path: relativePath,
                    Name: item,
                    Size: 0,
                    MimeType: nil,
                    ModTime: nil,
                    IsDir: true
                ))
            }
        }

        return directories.sorted { $0.Name.localizedCaseInsensitiveCompare($1.Name) == .orderedAscending }
    }
}

#Preview {
    RemoteFolderBrowser(
        remoteName: "gdrive",
        selectedPath: .constant(""),
        onDismiss: {}
    )
}
