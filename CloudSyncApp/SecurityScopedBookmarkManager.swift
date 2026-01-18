//
//  SecurityScopedBookmarkManager.swift
//  CloudSyncApp
//
//  Manages security-scoped bookmarks for persisting access to user-selected folders
//  across app launches in sandboxed macOS apps.
//
//  Issue #167: Local Storage security-scoped bookmarks
//

import Foundation
import os.log

/// Manages security-scoped bookmarks for folder access persistence
/// Required for sandboxed macOS apps to maintain folder access across launches
@MainActor
class SecurityScopedBookmarkManager: ObservableObject {
    static let shared = SecurityScopedBookmarkManager()

    private let logger = Logger(subsystem: "com.cloudsync.ultra", category: "SecurityScopedBookmarks")
    private let bookmarksKey = "securityScopedBookmarks_v1"

    /// Currently accessed security-scoped resources (need to be stopped on cleanup)
    private var accessedResources: [URL: Bool] = [:]

    /// Published list of available bookmarked folders
    @Published var bookmarkedFolders: [BookmarkedFolder] = []

    /// Error state for UI display
    @Published var lastError: BookmarkError?

    private init() {
        loadBookmarks()
    }

    // MARK: - Public API

    /// Create a security-scoped bookmark for a user-selected folder
    /// - Parameters:
    ///   - url: The folder URL from NSOpenPanel
    ///   - identifier: A unique identifier for this bookmark (e.g., remote ID)
    /// - Returns: True if bookmark was created successfully
    @discardableResult
    func createBookmark(for url: URL, identifier: String) -> Bool {
        do {
            // Create security-scoped bookmark data
            let bookmarkData = try url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: [.isDirectoryKey, .nameKey],
                relativeTo: nil
            )

            // Save bookmark data
            var bookmarks = loadBookmarkData()
            bookmarks[identifier] = bookmarkData
            saveBookmarkData(bookmarks)

            // Add to published list
            let folder = BookmarkedFolder(
                identifier: identifier,
                url: url,
                name: url.lastPathComponent,
                isAccessible: true,
                isStale: false
            )

            if let existingIndex = bookmarkedFolders.firstIndex(where: { $0.identifier == identifier }) {
                bookmarkedFolders[existingIndex] = folder
            } else {
                bookmarkedFolders.append(folder)
            }

            logger.info("Created security-scoped bookmark for: \(url.path, privacy: .public)")
            lastError = nil
            return true

        } catch {
            logger.error("Failed to create bookmark for \(url.path, privacy: .public): \(error.localizedDescription, privacy: .public)")
            lastError = .creationFailed(error.localizedDescription)
            return false
        }
    }

    /// Resolve a bookmark and start accessing the security-scoped resource
    /// - Parameter identifier: The bookmark identifier
    /// - Returns: The resolved URL if successful, nil otherwise
    func resolveBookmark(identifier: String) -> URL? {
        guard let bookmarkData = loadBookmarkData()[identifier] else {
            logger.warning("No bookmark found for identifier: \(identifier, privacy: .public)")
            return nil
        }

        do {
            var isStale = false
            let url = try URL(
                resolvingBookmarkData: bookmarkData,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )

            if isStale {
                logger.warning("Bookmark is stale for: \(url.path, privacy: .public)")
                updateBookmarkStaleStatus(identifier: identifier, isStale: true)
                lastError = .bookmarkStale(url.path)
                // Still try to use it - stale doesn't mean invalid
            }

            // Start accessing the security-scoped resource
            if url.startAccessingSecurityScopedResource() {
                accessedResources[url] = true
                logger.info("Started accessing security-scoped resource: \(url.path, privacy: .public)")

                // If stale, try to refresh the bookmark
                if isStale {
                    refreshBookmark(for: url, identifier: identifier)
                }

                return url
            } else {
                logger.error("Failed to start accessing security-scoped resource: \(url.path, privacy: .public)")
                lastError = .accessDenied(url.path)
                return nil
            }

        } catch {
            logger.error("Failed to resolve bookmark \(identifier, privacy: .public): \(error.localizedDescription, privacy: .public)")
            lastError = .resolutionFailed(error.localizedDescription)
            removeBookmark(identifier: identifier)
            return nil
        }
    }

    /// Stop accessing a security-scoped resource
    /// - Parameter url: The URL to stop accessing
    func stopAccessing(url: URL) {
        if accessedResources[url] == true {
            url.stopAccessingSecurityScopedResource()
            accessedResources.removeValue(forKey: url)
            logger.info("Stopped accessing security-scoped resource: \(url.path, privacy: .public)")
        }
    }

    /// Stop accessing all security-scoped resources (call on app termination)
    func stopAccessingAll() {
        for (url, _) in accessedResources {
            url.stopAccessingSecurityScopedResource()
        }
        accessedResources.removeAll()
        logger.info("Stopped accessing all security-scoped resources")
    }

    /// Remove a bookmark
    /// - Parameter identifier: The bookmark identifier to remove
    func removeBookmark(identifier: String) {
        var bookmarks = loadBookmarkData()
        bookmarks.removeValue(forKey: identifier)
        saveBookmarkData(bookmarks)

        bookmarkedFolders.removeAll { $0.identifier == identifier }
        logger.info("Removed bookmark: \(identifier, privacy: .public)")
    }

    /// Check if a bookmark exists for an identifier
    /// - Parameter identifier: The bookmark identifier
    /// - Returns: True if bookmark exists
    func hasBookmark(for identifier: String) -> Bool {
        return loadBookmarkData()[identifier] != nil
    }

    /// Get the bookmarked folder info for an identifier
    /// - Parameter identifier: The bookmark identifier
    /// - Returns: BookmarkedFolder if found
    func getBookmarkedFolder(identifier: String) -> BookmarkedFolder? {
        return bookmarkedFolders.first { $0.identifier == identifier }
    }

    /// Resolve all bookmarks on app launch
    /// Returns list of successfully resolved folders
    @discardableResult
    func resolveAllBookmarks() -> [BookmarkedFolder] {
        var resolved: [BookmarkedFolder] = []

        for (identifier, _) in loadBookmarkData() {
            if let url = resolveBookmark(identifier: identifier) {
                if let folder = bookmarkedFolders.first(where: { $0.identifier == identifier }) {
                    resolved.append(folder)
                } else {
                    // Create folder entry if not in list
                    let folder = BookmarkedFolder(
                        identifier: identifier,
                        url: url,
                        name: url.lastPathComponent,
                        isAccessible: true,
                        isStale: false
                    )
                    bookmarkedFolders.append(folder)
                    resolved.append(folder)
                }
            }
        }

        logger.info("Resolved \(resolved.count) bookmarks on launch")
        return resolved
    }

    /// Validate all bookmarks and update their status
    func validateAllBookmarks() {
        let bookmarks = loadBookmarkData()
        var updatedFolders: [BookmarkedFolder] = []

        for (identifier, bookmarkData) in bookmarks {
            var isStale = false

            do {
                let url = try URL(
                    resolvingBookmarkData: bookmarkData,
                    options: .withSecurityScope,
                    relativeTo: nil,
                    bookmarkDataIsStale: &isStale
                )

                // Check if folder still exists
                let isAccessible = FileManager.default.fileExists(atPath: url.path)

                let folder = BookmarkedFolder(
                    identifier: identifier,
                    url: url,
                    name: url.lastPathComponent,
                    isAccessible: isAccessible,
                    isStale: isStale
                )
                updatedFolders.append(folder)

            } catch {
                // Bookmark is invalid - mark for cleanup
                logger.warning("Invalid bookmark \(identifier, privacy: .public): \(error.localizedDescription, privacy: .public)")
            }
        }

        bookmarkedFolders = updatedFolders
    }

    /// Clean up invalid/inaccessible bookmarks
    func cleanupInvalidBookmarks() {
        let invalidIdentifiers = bookmarkedFolders
            .filter { !$0.isAccessible }
            .map { $0.identifier }

        for identifier in invalidIdentifiers {
            removeBookmark(identifier: identifier)
        }

        if !invalidIdentifiers.isEmpty {
            logger.info("Cleaned up \(invalidIdentifiers.count) invalid bookmarks")
        }
    }

    // MARK: - Private Methods

    private func loadBookmarks() {
        validateAllBookmarks()
    }

    private func loadBookmarkData() -> [String: Data] {
        guard let data = UserDefaults.standard.data(forKey: bookmarksKey),
              let bookmarks = try? JSONDecoder().decode([String: Data].self, from: data) else {
            return [:]
        }
        return bookmarks
    }

    private func saveBookmarkData(_ bookmarks: [String: Data]) {
        if let data = try? JSONEncoder().encode(bookmarks) {
            UserDefaults.standard.set(data, forKey: bookmarksKey)
        }
    }

    private func updateBookmarkStaleStatus(identifier: String, isStale: Bool) {
        if let index = bookmarkedFolders.firstIndex(where: { $0.identifier == identifier }) {
            bookmarkedFolders[index].isStale = isStale
        }
    }

    private func refreshBookmark(for url: URL, identifier: String) {
        // Try to create a new bookmark to refresh the stale one
        if createBookmark(for: url, identifier: identifier) {
            logger.info("Successfully refreshed stale bookmark: \(identifier, privacy: .public)")
        }
    }
}

// MARK: - Supporting Types

/// Represents a bookmarked folder with its status
struct BookmarkedFolder: Identifiable, Equatable {
    let id = UUID()
    let identifier: String
    let url: URL
    let name: String
    var isAccessible: Bool
    var isStale: Bool

    var path: String {
        url.path
    }

    var displayPath: String {
        // Show abbreviated path (replace home directory with ~)
        let homePath = NSHomeDirectory()
        if path.hasPrefix(homePath) {
            return "~" + path.dropFirst(homePath.count)
        }
        return path
    }
}

/// Errors that can occur with security-scoped bookmarks
enum BookmarkError: LocalizedError {
    case creationFailed(String)
    case resolutionFailed(String)
    case accessDenied(String)
    case bookmarkStale(String)
    case folderNotFound(String)

    var errorDescription: String? {
        switch self {
        case .creationFailed(let detail):
            return "Failed to create bookmark: \(detail)"
        case .resolutionFailed(let detail):
            return "Failed to resolve bookmark: \(detail)"
        case .accessDenied(let path):
            return "Access denied to folder: \(path)"
        case .bookmarkStale(let path):
            return "Bookmark is stale for: \(path). Please re-select the folder."
        case .folderNotFound(let path):
            return "Folder no longer exists: \(path)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .creationFailed, .resolutionFailed, .accessDenied:
            return "Please select the folder again using the folder picker."
        case .bookmarkStale:
            return "The folder was moved or modified. Please select it again."
        case .folderNotFound:
            return "The folder may have been deleted. Please select a different folder."
        }
    }
}
