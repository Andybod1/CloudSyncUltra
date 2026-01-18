//
//  RemotesViewModel.swift
//  CloudSyncApp
//
//  Manages cloud remotes and connections
//

import Foundation
import Combine

@MainActor
class RemotesViewModel: ObservableObject {
    static let shared = RemotesViewModel()
    
    @Published var remotes: [CloudRemote] = []
    @Published var selectedRemote: CloudRemote?
    @Published var isLoading = false
    @Published var error: String?
    @Published var showPaywall = false
    
    private let storageKey = "cloudRemotes_v6"  // Increment to force rescan
    
    private init() {
        loadRemotes()
    }
    
    /// Internal initializer for testing
    internal init(forTesting: Bool) {
        // Don't auto-load for tests
    }
    
    func loadRemotes() {
        // Start with default local storage (user home directory)
        var loadedRemotes: [CloudRemote] = [
            CloudRemote(name: "Local Storage", type: .local, isConfigured: true, path: NSHomeDirectory())
        ]

        // Load saved remotes from UserDefaults first
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let savedRemotes = try? JSONDecoder().decode([CloudRemote].self, from: data) {
            // Add saved local storage remotes with custom paths (#167)
            // These are user-added local storage folders with security-scoped bookmarks
            let savedLocalRemotes = savedRemotes.filter { $0.type == .local && !$0.path.isEmpty && $0.path != NSHomeDirectory() }
            loadedRemotes.append(contentsOf: savedLocalRemotes)

            // Add non-local saved remotes
            let savedCloudRemotes = savedRemotes.filter { $0.type != .local }
            loadedRemotes.append(contentsOf: savedCloudRemotes)
        }

        // Scan rclone config for any remotes not already in our saved list
        let rcloneRemotes = scanRcloneConfigRemotes()
        for rcloneRemote in rcloneRemotes {
            // Only add if not already present (by type or custom rclone name)
            let alreadyExists = loadedRemotes.contains { existing in
                existing.type == rcloneRemote.type ||
                (existing.customRcloneName != nil && existing.customRcloneName == rcloneRemote.customRcloneName)
            }
            if !alreadyExists {
                loadedRemotes.append(rcloneRemote)
            }
        }

        // Sort cloud remotes by sortOrder
        let localRemotes = loadedRemotes.filter { $0.type == .local }
        let cloudRemotes = loadedRemotes.filter { $0.type != .local }.sorted { $0.sortOrder < $1.sortOrder }
        remotes = localRemotes + cloudRemotes

        saveRemotes()
    }

    /// Scan rclone config and return found remotes (without modifying state)
    private func scanRcloneConfigRemotes() -> [CloudRemote] {
        var foundRemotes: [CloudRemote] = []
        let rclone = RcloneManager.shared

        let providerChecks: [(CloudProviderType, [String])] = [
            (.protonDrive, ["proton"]),
            (.googleDrive, ["google", "Google", "gdrive"]),
            (.dropbox, ["dropbox", "Dropbox"]),
            (.oneDrive, ["onedrive", "OneDrive"]),
            (.s3, ["s3", "S3", "aws"]),
            (.mega, ["mega", "Mega", "MEGA"]),
            (.box, ["box", "Box"]),
            (.pcloud, ["pcloud", "pCloud"])
        ]

        for (providerType, possibleNames) in providerChecks {
            for name in possibleNames {
                if rclone.isRemoteConfigured(name: name) {
                    let remote = CloudRemote(
                        name: providerType.displayName,
                        type: providerType,
                        isConfigured: true,
                        path: "",
                        customRcloneName: name
                    )
                    // Don't add duplicates within this scan
                    if !foundRemotes.contains(where: { $0.type == providerType }) {
                        foundRemotes.append(remote)
                    }
                    break
                }
            }
        }

        return foundRemotes
    }
    
    func saveRemotes() {
        if let data = try? JSONEncoder().encode(remotes) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    func addRemote(_ remote: CloudRemote) -> Bool {
        // Check if user can add more remotes based on subscription tier
        // Only count cloud remotes against the limit, not local storage
        if let limit = StoreKitManager.shared.currentTier.connectionLimit {
            let cloudRemoteCount = remotes.filter { $0.type != .local }.count
            if cloudRemoteCount >= limit {
                // User has reached the limit
                error = StoreKitManager.shared.currentTier.limitMessage(for: "connections")
                return false
            }
        }

        remotes.append(remote)
        saveRemotes()
        return true
    }
    
    func removeRemote(_ remote: CloudRemote) {
        // For local storage remotes with custom paths, remove the security-scoped bookmark (#167)
        if remote.type == .local && !remote.path.isEmpty && remote.path != NSHomeDirectory() {
            let bookmarkIdentifier = "local_storage_\(remote.rcloneName)"
            SecurityScopedBookmarkManager.shared.removeBookmark(identifier: bookmarkIdentifier)
        } else {
            // For cloud remotes, also remove from rclone config
            let rcloneName = remote.rcloneName
            Task {
                try? await RcloneManager.shared.deleteRemote(name: rcloneName)
            }
        }
        remotes.removeAll { $0.id == remote.id }
        saveRemotes()
    }
    
    func updateRemote(_ remote: CloudRemote) {
        if let index = remotes.firstIndex(where: { $0.id == remote.id }) {
            remotes[index] = remote
            saveRemotes()
        }
    }
    
    /// Refresh remotes by rescanning rclone config
    func refresh() {
        loadRemotes()
    }
    
    var configuredRemotes: [CloudRemote] {
        remotes.filter { $0.isConfigured }
    }
    
    var cloudRemotes: [CloudRemote] {
        remotes.filter { $0.type != .local && $0.isConfigured }
    }

    /// Move cloud remotes to reorder them in the sidebar
    /// - Parameters:
    ///   - source: IndexSet of items to move
    ///   - destination: Target index
    func moveCloudRemotes(from source: IndexSet, to destination: Int) {
        // Get cloud-only remotes (excluding local)
        var cloudRemotes = remotes.filter { $0.type != .local }
        let localRemotes = remotes.filter { $0.type == .local }

        // Perform the move
        cloudRemotes.move(fromOffsets: source, toOffset: destination)

        // Update sort orders
        for (index, _) in cloudRemotes.enumerated() {
            cloudRemotes[index].sortOrder = index
        }

        // Rebuild full remotes array: local first, then sorted cloud remotes
        remotes = localRemotes + cloudRemotes

        saveRemotes()
    }

    /// Update account name for a remote
    /// - Parameters:
    ///   - remoteName: The rclone name of the remote
    ///   - accountName: The account email or username
    func setAccountName(_ accountName: String, for remoteName: String) {
        if let index = remotes.firstIndex(where: { $0.rcloneName == remoteName }) {
            remotes[index].accountName = accountName
            saveRemotes()
        }
    }

    // MARK: - Subscription Feature Gating

    /// Check if user can add more remotes based on subscription tier
    /// Only counts cloud remotes, not local storage
    var canAddMoreRemotes: Bool {
        guard let limit = StoreKitManager.shared.currentTier.connectionLimit else {
            return true // No limit
        }
        let cloudRemoteCount = remotes.filter { $0.type != .local }.count
        return cloudRemoteCount < limit
    }

    /// Get the number of remaining remotes user can add
    /// Only counts cloud remotes, not local storage
    var remainingRemotesCount: Int? {
        guard let limit = StoreKitManager.shared.currentTier.connectionLimit else {
            return nil // No limit
        }
        let cloudRemoteCount = remotes.filter { $0.type != .local }.count
        return max(0, limit - cloudRemoteCount)
    }

    /// Check if user should be shown the paywall for adding remotes
    func checkRemoteLimit() -> Bool {
        if !canAddMoreRemotes {
            error = StoreKitManager.shared.currentTier.limitMessage(for: "connections")
            showPaywall = true
            return false
        }
        return true
    }
}
