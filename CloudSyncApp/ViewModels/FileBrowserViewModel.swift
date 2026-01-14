//
//  FileBrowserViewModel.swift
//  CloudSyncApp
//
//  Manages file browsing for local and remote storage
//

import Foundation
import Combine
import os

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

    // Legacy Pagination (page-based)
    @Published var currentPage: Int = 1
    @Published var pageSize: Int = 100 {
        didSet {
            // Reset to page 1 when page size changes
            currentPage = 1
        }
    }
    @Published var isPaginationEnabled: Bool = true

    // Lazy Loading / Infinite Scroll State
    @Published var displayedFiles: [FileItem] = []
    @Published var isLoadingMore = false
    @Published var useLazyLoading: Bool = true
    private let lazyPageSize = 100

    // Performance logging
    private let logger = Logger(subsystem: "com.cloudsync", category: "performance")

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
    
    // MARK: - Pagination Computed Properties
    
    var totalPages: Int {
        guard isPaginationEnabled else { return 1 }
        let baseFiles = searchQuery.isEmpty ? files : filteredFiles
        return max(1, Int(ceil(Double(baseFiles.count) / Double(pageSize))))
    }
    
    var paginatedFiles: [FileItem] {
        guard isPaginationEnabled else {
            return searchQuery.isEmpty ? files : filteredFiles
        }
        
        let baseFiles = searchQuery.isEmpty ? files : filteredFiles
        let startIndex = (currentPage - 1) * pageSize
        let endIndex = min(startIndex + pageSize, baseFiles.count)
        
        guard startIndex < baseFiles.count else { return [] }
        return Array(baseFiles[startIndex..<endIndex])
    }
    
    var canGoToPreviousPage: Bool {
        currentPage > 1
    }
    
    var canGoToNextPage: Bool {
        currentPage < totalPages
    }
    
    var pageInfo: String {
        let baseFiles = searchQuery.isEmpty ? files : filteredFiles
        let startIndex = (currentPage - 1) * pageSize + 1
        let endIndex = min(currentPage * pageSize, baseFiles.count)
        return "\(startIndex)-\(endIndex) of \(baseFiles.count)"
    }
    
    // MARK: - Pagination Actions
    
    func nextPage() {
        guard canGoToNextPage else { return }
        currentPage += 1
        selectedFiles.removeAll()
    }
    
    func previousPage() {
        guard canGoToPreviousPage else { return }
        currentPage -= 1
        selectedFiles.removeAll()
    }
    
    func goToPage(_ page: Int) {
        guard page >= 1 && page <= totalPages else { return }
        currentPage = page
        selectedFiles.removeAll()
    }
    
    func firstPage() {
        currentPage = 1
        selectedFiles.removeAll()
    }
    
    func lastPage() {
        currentPage = totalPages
        selectedFiles.removeAll()
    }
    
    // MARK: - Setup
    
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

        let startTime = CFAbsoluteTimeGetCurrent()
        isLoading = true
        error = nil

        do {
            if remote.type == .local {
                files = try loadLocalFiles(at: currentPath)
            } else {
                files = try await loadRemoteFiles(remote: remote, path: currentPath)
            }
            sortFiles()

            // Reset to first page when loading new directory
            currentPage = 1
            selectedFiles.removeAll()

            // Reset lazy loading display
            resetDisplayedFiles()

            let duration = CFAbsoluteTimeGetCurrent() - startTime
            logger.info("Loaded \(self.files.count) files in \(String(format: "%.3f", duration))s")
        } catch {
            self.error = error.localizedDescription
            logger.error("Failed to load files: \(error.localizedDescription)")
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
        // Use the effective remote name (base or crypt) based on encryption state
        let effectiveRemote = remote.effectiveRemoteName
        print("[FileBrowserVM] Loading files from \(effectiveRemote):\(path) (encryption: \(remote.isEncrypted ? "ON" : "OFF"))")
        
        let remoteFiles = try await RcloneManager.shared.listRemoteFiles(
            remotePath: path,
            encrypted: false,  // Don't use legacy encryption routing
            remoteName: effectiveRemote  // Use effective remote (base or crypt)
        )
        
        return remoteFiles.map { file in
            let dateFormatter = ISO8601DateFormatter()
            let modDate: Date
            if let modTimeString = file.ModTime {
                modDate = dateFormatter.date(from: modTimeString) ?? Date()
            } else {
                modDate = Date()
            }

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
                mimeType: file.MimeType  // Now optional, matches FileItem definition
            )
        }
    }
    
    func navigateTo(_ path: String) {
        currentPath = path
        selectedFiles.removeAll()
        currentPage = 1
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
        currentPage = 1
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
        // Select all on current page only
        selectedFiles = Set(paginatedFiles.map { $0.id })
    }
    
    func selectAllInDirectory() {
        // Select all files in directory (all pages)
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

    // MARK: - Lazy Loading / Infinite Scroll

    /// Total count of all files in the current directory (for status display)
    var totalFileCount: Int {
        let baseFiles = searchQuery.isEmpty ? files : filteredFiles
        return baseFiles.count
    }

    /// Count of files currently displayed (for infinite scroll)
    var displayedFileCount: Int {
        displayedFiles.count
    }

    /// Whether there are more files to load
    var hasMoreFilesToLoad: Bool {
        let baseFiles = searchQuery.isEmpty ? files : filteredFiles
        return displayedFiles.count < baseFiles.count
    }

    /// Progress indicator text for lazy loading
    var lazyLoadingInfo: String {
        let baseFiles = searchQuery.isEmpty ? files : filteredFiles
        return "Showing \(displayedFiles.count) of \(baseFiles.count) files"
    }

    /// Reset displayed files to initial page
    func resetDisplayedFiles() {
        let baseFiles = searchQuery.isEmpty ? files : filteredFiles
        displayedFiles = Array(baseFiles.prefix(lazyPageSize))
        logger.info("Reset displayed files: \(self.displayedFiles.count) of \(baseFiles.count)")
    }

    /// Load more files for infinite scroll
    func loadMoreIfNeeded(currentFile: FileItem? = nil) {
        // Only load more if the current file is near the end
        guard let file = currentFile else {
            loadMoreFiles()
            return
        }

        // Check if we're near the end of displayed files
        if let index = displayedFiles.firstIndex(where: { $0.id == file.id }) {
            let threshold = displayedFiles.count - 10 // Load more when 10 items from end
            if index >= threshold {
                loadMoreFiles()
            }
        }
    }

    /// Load the next batch of files for infinite scroll
    func loadMoreFiles() {
        guard !isLoadingMore && hasMoreFilesToLoad else { return }

        let startTime = CFAbsoluteTimeGetCurrent()
        isLoadingMore = true

        let baseFiles = searchQuery.isEmpty ? files : filteredFiles
        let startIndex = displayedFiles.count
        let endIndex = min(startIndex + lazyPageSize, baseFiles.count)

        // Simulate async loading to prevent UI blocking on large datasets
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            guard let self = self else { return }
            self.displayedFiles.append(contentsOf: baseFiles[startIndex..<endIndex])
            self.isLoadingMore = false

            let duration = CFAbsoluteTimeGetCurrent() - startTime
            self.logger.info("Loaded \(endIndex - startIndex) more files in \(String(format: "%.3f", duration))s. Total displayed: \(self.displayedFiles.count)")
        }
    }

    /// Files to display in lazy scroll view
    var lazyScrollFiles: [FileItem] {
        guard useLazyLoading else {
            return searchQuery.isEmpty ? files : filteredFiles
        }

        // Apply search filter if active
        if !searchQuery.isEmpty {
            // For search, filter displayed files
            return displayedFiles.filter { $0.name.localizedCaseInsensitiveContains(searchQuery) }
        }

        return displayedFiles
    }

    /// Called when search query changes to reset lazy loading
    func onSearchQueryChanged() {
        currentPage = 1
        resetDisplayedFiles()
    }
}
