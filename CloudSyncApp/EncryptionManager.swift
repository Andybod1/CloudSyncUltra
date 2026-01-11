//
//  EncryptionManager.swift
//  CloudSyncApp
//
//  Manages E2E encryption using rclone's crypt remote
//

import Foundation

/// Manages end-to-end encryption for cloud sync using rclone's crypt backend.
/// Files are encrypted locally before upload, ensuring zero-knowledge encryption.
final class EncryptionManager {
    static let shared = EncryptionManager()
    
    private init() {}
    
    // MARK: - Encryption State
    
    var isEncryptionEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "encryptionEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "encryptionEnabled") }
    }
    
    var encryptFilenames: Bool {
        get { UserDefaults.standard.bool(forKey: "encryptFilenames") }
        set { UserDefaults.standard.set(newValue, forKey: "encryptFilenames") }
    }
    
    var isEncryptionConfigured: Bool {
        getPassword() != nil && getSalt() != nil
    }
    
    /// The name of the encrypted remote in rclone config
    var encryptedRemoteName: String {
        "encrypted"
    }
    
    // MARK: - UserDefaults Storage
    
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
}

// MARK: - Errors

enum EncryptionError: LocalizedError {
    case configurationFailed(String)
    case passwordMismatch
    case notConfigured
    
    var errorDescription: String? {
        switch self {
        case .configurationFailed(let message):
            return "Encryption configuration failed: \(message)"
        case .passwordMismatch:
            return "Passwords do not match"
        case .notConfigured:
            return "Encryption is not configured"
        }
    }
}
