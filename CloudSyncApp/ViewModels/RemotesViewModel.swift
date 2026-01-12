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
    
    private let storageKey = "cloudRemotes_v5"  // Increment to force rescan
    
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
    
    func addRemote(_ remote: CloudRemote) {
        remotes.append(remote)
        saveRemotes()
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
}
