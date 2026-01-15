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
        // Start fresh with local storage
        remotes = [
            CloudRemote(name: "Local Storage", type: .local, isConfigured: true, path: NSHomeDirectory())
        ]

        // Scan rclone config for existing remotes
        scanRcloneConfig()

        // Sort cloud remotes by sortOrder
        let localRemotes = remotes.filter { $0.type == .local }
        let cloudRemotes = remotes.filter { $0.type != .local }.sorted { $0.sortOrder < $1.sortOrder }
        remotes = localRemotes + cloudRemotes

        saveRemotes()
    }
    
    private func scanRcloneConfig() {
        let rclone = RcloneManager.shared
        
        // Check for known provider types
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
                    // Found a configured remote
                    let remote = CloudRemote(
                        name: providerType.displayName,
                        type: providerType,
                        isConfigured: true,
                        path: "",
                        customRcloneName: name
                    )
                    // Don't add duplicates
                    if !remotes.contains(where: { $0.type == providerType }) {
                        remotes.append(remote)
                    }
                    break  // Found one for this provider, move to next
                }
            }
        }
    }
    
    func saveRemotes() {
        if let data = try? JSONEncoder().encode(remotes) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    func addRemote(_ remote: CloudRemote) -> Bool {
        // Check if user can add more remotes based on subscription tier
        if let limit = StoreKitManager.shared.currentTier.connectionLimit {
            let currentCount = remotes.count
            if currentCount >= limit {
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
        // Also remove from rclone config
        let rcloneName = remote.rcloneName
        Task {
            try? await RcloneManager.shared.deleteRemote(name: rcloneName)
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
    var canAddMoreRemotes: Bool {
        guard let limit = StoreKitManager.shared.currentTier.connectionLimit else {
            return true // No limit
        }
        return remotes.count < limit
    }

    /// Get the number of remaining remotes user can add
    var remainingRemotesCount: Int? {
        guard let limit = StoreKitManager.shared.currentTier.connectionLimit else {
            return nil // No limit
        }
        return max(0, limit - remotes.count)
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
