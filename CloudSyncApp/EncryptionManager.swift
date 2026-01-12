//
//  EncryptionManager.swift
//  CloudSyncApp
//
//  Manages per-remote E2E encryption using rclone's crypt backend
//

import Foundation
import Security

/// Configuration for a remote's encryption settings
struct RemoteEncryptionConfig: Codable {
    let password: String
    let salt: String
    let encryptFilenames: Bool
    let encryptFolders: Bool
    
    var filenameEncryptionMode: String {
        encryptFilenames ? "standard" : "off"
    }
}

/// Manages end-to-end encryption for cloud sync using rclone's crypt backend.
/// Each remote can have its own encryption configuration with independent passwords.
final class EncryptionManager {
    static let shared = EncryptionManager()
    
    private init() {}
    
    // MARK: - Per-Remote Encryption State
    
    /// Check if encryption view is enabled for a specific remote (toggle state)
    /// Always returns false for local storage since encryption doesn't apply
    func isEncryptionEnabled(for remoteName: String) -> Bool {
        guard remoteName != "local" else { return false }
        return UserDefaults.standard.bool(forKey: "encryption_enabled_\(remoteName)")
    }
    
    /// Enable/disable encryption view for a specific remote
    /// Ignores requests for local storage since encryption doesn't apply
    func setEncryptionEnabled(_ enabled: Bool, for remoteName: String) {
        guard remoteName != "local" else { return }
        UserDefaults.standard.set(enabled, forKey: "encryption_enabled_\(remoteName)")
        NotificationCenter.default.post(
            name: .encryptionStateChanged,
            object: nil,
            userInfo: ["remoteName": remoteName, "enabled": enabled]
        )
    }
    
    /// Check if a remote has encryption configured (password + salt saved + crypt remote exists)
    /// Always returns false for local storage since encryption doesn't apply
    func isEncryptionConfigured(for remoteName: String) -> Bool {
        guard remoteName != "local" else { return false }
        return getConfig(for: remoteName) != nil
    }
    
    /// Get the crypt remote name for a base remote (e.g., "googledrive" -> "googledrive-crypt")
    func getCryptRemoteName(for baseRemote: String) -> String {
        "\(baseRemote)-crypt"
    }
    
    /// Legacy alias for getCryptRemoteName (backward compatibility)
    func getEncryptedRemoteName(for baseRemote: String) -> String {
        getCryptRemoteName(for: baseRemote)
    }
    
    /// Get effective remote name based on encryption state
    func getEffectiveRemoteName(for baseRemote: String) -> String {
        if isEncryptionEnabled(for: baseRemote) && isEncryptionConfigured(for: baseRemote) {
            return getCryptRemoteName(for: baseRemote)
        }
        return baseRemote
    }
    
    // MARK: - Per-Remote Configuration Storage
    
    /// Save encryption configuration for a remote
    /// Ignores requests for local storage since encryption doesn't apply
    func saveConfig(_ config: RemoteEncryptionConfig, for remoteName: String) throws {
        guard remoteName != "local" else {
            print("[EncryptionManager] Ignoring encryption config save for local storage")
            return
        }
        let encoder = JSONEncoder()
        let data = try encoder.encode(config)
        UserDefaults.standard.set(data, forKey: "encryption_config_\(remoteName)")
        print("[EncryptionManager] Saved config for \(remoteName)")
    }
    
    /// Get encryption configuration for a remote
    func getConfig(for remoteName: String) -> RemoteEncryptionConfig? {
        guard let data = UserDefaults.standard.data(forKey: "encryption_config_\(remoteName)") else {
            return nil
        }
        let decoder = JSONDecoder()
        return try? decoder.decode(RemoteEncryptionConfig.self, from: data)
    }
    
    /// Delete encryption configuration for a remote
    func deleteConfig(for remoteName: String) {
        UserDefaults.standard.removeObject(forKey: "encryption_config_\(remoteName)")
        UserDefaults.standard.removeObject(forKey: "encryption_enabled_\(remoteName)")
        print("[EncryptionManager] Deleted config for \(remoteName)")
    }
    
    // MARK: - Legacy Support (for backward compatibility)
    
    /// Get the encrypted remote name (legacy - use getCryptRemoteName instead)
    var encryptedRemoteName: String {
        "encrypted"
    }
    
    /// Check if legacy encryption is enabled
    var isEncryptionEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "encryptionEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "encryptionEnabled") }
    }
    
    /// Check if legacy encryption is configured
    var isEncryptionConfigured: Bool {
        getPassword() != nil && getSalt() != nil
    }
    
    var encryptFilenames: Bool {
        get { UserDefaults.standard.bool(forKey: "encryptFilenames") }
        set { UserDefaults.standard.set(newValue, forKey: "encryptFilenames") }
    }
    
    func savePassword(_ password: String) throws {
        UserDefaults.standard.set(password, forKey: "encryption.password")
    }
    
    func getPassword() -> String? {
        UserDefaults.standard.string(forKey: "encryption.password")
    }
    
    func saveSalt(_ salt: String) throws {
        UserDefaults.standard.set(salt, forKey: "encryption.salt")
    }
    
    func getSalt() -> String? {
        UserDefaults.standard.string(forKey: "encryption.salt")
    }
    
    func deleteEncryptionCredentials() {
        UserDefaults.standard.removeObject(forKey: "encryption.password")
        UserDefaults.standard.removeObject(forKey: "encryption.salt")
    }
    
    // Per-remote password storage (legacy methods)
    func savePassword(_ password: String, for remoteName: String) throws {
        UserDefaults.standard.set(password, forKey: "encryption_password_\(remoteName)")
    }
    
    func getPassword(for remoteName: String) -> String? {
        UserDefaults.standard.string(forKey: "encryption_password_\(remoteName)")
    }
    
    func saveSalt(_ salt: String, for remoteName: String) throws {
        UserDefaults.standard.set(salt, forKey: "encryption_salt_\(remoteName)")
    }
    
    func getSalt(for remoteName: String) -> String? {
        UserDefaults.standard.string(forKey: "encryption_salt_\(remoteName)")
    }
    
    func deleteEncryptionCredentials(for remoteName: String) {
        UserDefaults.standard.removeObject(forKey: "encryption_password_\(remoteName)")
        UserDefaults.standard.removeObject(forKey: "encryption_salt_\(remoteName)")
        UserDefaults.standard.removeObject(forKey: "encryption_enabled_\(remoteName)")
    }
    
    // MARK: - Password Generation
    
    /// Generates a cryptographically secure random password
    func generateSecurePassword(length: Int = 32) -> String {
        let charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*"
        var password = ""
        var randomBytes = [UInt8](repeating: 0, count: length)
        
        _ = SecRandomCopyBytes(kSecRandomDefault, length, &randomBytes)
        
        for byte in randomBytes {
            password.append(charset[charset.index(charset.startIndex, offsetBy: Int(byte) % charset.count)])
        }
        
        return password
    }
    
    /// Generates a cryptographically secure salt
    func generateSecureSalt(length: Int = 32) -> String {
        generateSecurePassword(length: length)
    }
    
    // MARK: - Utility
    
    /// Get all remotes that have encryption configured
    func getEncryptedRemotes() -> [String] {
        let defaults = UserDefaults.standard
        let allKeys = defaults.dictionaryRepresentation().keys
        
        return allKeys
            .filter { $0.hasPrefix("encryption_config_") }
            .map { String($0.dropFirst("encryption_config_".count)) }
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let encryptionStateChanged = Notification.Name("encryptionStateChanged")
}

// MARK: - Errors

enum EncryptionError: LocalizedError {
    case configurationFailed(String)
    case passwordMismatch
    case notConfigured
    case remoteMissing(String)
    
    var errorDescription: String? {
        switch self {
        case .configurationFailed(let message):
            return "Encryption configuration failed: \(message)"
        case .passwordMismatch:
            return "Passwords do not match"
        case .notConfigured:
            return "Encryption is not configured for this remote"
        case .remoteMissing(let name):
            return "Remote '\(name)' not found"
        }
    }
}
