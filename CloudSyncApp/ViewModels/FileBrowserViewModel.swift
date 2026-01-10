//
//  FileBrowserViewModel.swift
//  CloudSyncApp
//
//  Manages file browsing for local and remote storage
//

import Foundation
import Combine

@MainActor
class FileBrowserViewModel: ObservableObject {
    @Published var currentPath: String = ""
    @Published var files: [FileItem] = []
    @Published var selectedFiles: Set<UUID> = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var sortOrder: SortOrder = .nameAsc
    @Published var viewMode: ViewMode = .list
    @Published var searchQuery: String = ""
    
    var remote: CloudRemote?
    
    enum SortOrder: String, CaseIterable {
        case nameAsc = "Name ↑"
        case nameDesc = "Name ↓"
        case sizeAsc = "Size ↑"
        case sizeDesc = "Size ↓"
        case dateAsc = "Date ↑"
        case dateDesc = "Date ↓"
    }
    
    enum ViewMode: String, CaseIterable {
        case list = "List"
        case grid = "Grid"
    }
    
    func setRemote(_ remote: CloudRemote) {
        self.remote = remote
        // For cloud remotes, use empty string as root, for local use the path or /
        if remote.type == .local {
            self.currentPath = remote.path.isEmpty ? NSHomeDirectory() : remote.path
        } else {
            self.currentPath = remote.path  // Empty string for cloud root
        }
        Task { await loadFiles() }
    }
    
    func loadFiles() async {
        guard let remote = remote else { return }
        
        // Don't try to load if remote is not configured
        guard remote.isConfigured else {
            error = "Remote '\(remote.name)' is not connected. Please connect it first."
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            if remote.type == .local {
                files = try loadLocalFiles(at: currentPath)
            } else {
                files = try await loadRemoteFiles(remote: remote, path: currentPath)
            }
            sortFiles()
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func loadLocalFiles(at path: String) throws -> [FileItem] {
        let fm = FileManager.default
        let contents = try fm.contentsOfDirectory(atPath: path)
        
        return contents.compactMap { name -> FileItem? in
            // Skip hidden files
            guard !name.hasPrefix(".") else { return nil }
            
            let fullPath = (path as NSString).appendingPathComponent(name)
            var isDir: ObjCBool = false
            
            guard fm.fileExists(atPath: fullPath, isDirectory: &isDir) else { return nil }
            
            let attrs = try? fm.attributesOfItem(atPath: fullPath)
            let size = (attrs?[.size] as? Int64) ?? 0
            let modDate = (attrs?[.modificationDate] as? Date) ?? Date()
            
            return FileItem(
                name: name,
                path: fullPath,
                isDirectory: isDir.boolValue,
                size: size,
                modifiedDate: modDate
            )
        }
    }
    
    private func loadRemoteFiles(remote: CloudRemote, path: String) async throws -> [FileItem] {
        // Use the remote's rcloneName for consistent naming
        let remoteFiles = try await RcloneManager.shared.listRemoteFiles(
            remotePath: path,
            encrypted: remote.isEncrypted,
            remoteName: remote.rcloneName
        )
        
        return remoteFiles.map { file in
            let dateFormatter = ISO8601DateFormatter()
            let modDate = dateFormatter.date(from: file.ModTime) ?? Date()
            
            // Construct full path by combining current path with file name
            let fullPath: String
            if path.isEmpty {
                fullPath = file.Name
            } else {
                fullPath = (path as NSString).appendingPathComponent(file.Name)
            }
            
            return FileItem(
                name: file.Name,
                path: fullPath,
                isDirectory: file.IsDir,
                size: file.Size,
                modifiedDate: modDate,
                mimeType: file.MimeType
            )
        }
    }
    
    func navigateTo(_ path: String) {
        currentPath = path
        selectedFiles.removeAll()
        Task { await loadFiles() }
    }
    
    func navigateUp() {
        if remote?.type == .local {
            let parent = (currentPath as NSString).deletingLastPathComponent
            if !parent.isEmpty && parent != currentPath {
                navigateTo(parent)
            }
        } else {
            // For cloud remotes, navigate to parent or empty string for root
            if !currentPath.isEmpty {
                let parent = (currentPath as NSString).deletingLastPathComponent
                navigateTo(parent)
            }
        }
    }
    
    func navigateToFile(_ file: FileItem) {
        if file.isDirectory {
            navigateTo(file.path)
        }
    }
    
    func refresh() {
        Task { await loadFiles() }
    }
    
    func sortFiles() {
        switch sortOrder {
        case .nameAsc:
            files.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .nameDesc:
            files.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending }
        case .sizeAsc:
            files.sort { $0.size < $1.size }
        case .sizeDesc:
            files.sort { $0.size > $1.size }
        case .dateAsc:
            files.sort { $0.modifiedDate < $1.modifiedDate }
        case .dateDesc:
            files.sort { $0.modifiedDate > $1.modifiedDate }
        }
        
        // Always keep directories first
        let dirs = files.filter { $0.isDirectory }
        let fileItems = files.filter { !$0.isDirectory }
        files = dirs + fileItems
    }
    
    func toggleSelection(_ file: FileItem) {
        if selectedFiles.contains(file.id) {
            selectedFiles.remove(file.id)
        } else {
            selectedFiles.insert(file.id)
        }
    }
    
    func selectAll() {
        selectedFiles = Set(files.map { $0.id })
    }
    
    func deselectAll() {
        selectedFiles.removeAll()
    }
    
    var filteredFiles: [FileItem] {
        if searchQuery.isEmpty {
            return files
        }
        return files.filter { $0.name.localizedCaseInsensitiveContains(searchQuery) }
    }
    
    var selectedItems: [FileItem] {
        files.filter { selectedFiles.contains($0.id) }
    }
    
    var pathComponents: [(name: String, path: String)] {
        var components: [(String, String)] = []
        var path = currentPath
        
        // For cloud remotes, empty path is root
        if remote?.type != .local && path.isEmpty {
            return [(remote?.name ?? "Root", "")]
        }
        
        while !path.isEmpty && path != "/" {
            let name = (path as NSString).lastPathComponent
            components.insert((name, path), at: 0)
            path = (path as NSString).deletingLastPathComponent
        }
        
        if remote?.type == .local {
            components.insert(("/", "/"), at: 0)
        } else {
            components.insert((remote?.name ?? "Root", ""), at: 0)
        }
        
        return components
    }
}
