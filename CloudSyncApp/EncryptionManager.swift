//
//  EncryptionManager.swift
//  CloudSyncApp
//
//  Manages E2E encryption using rclone's crypt remote
//

import Foundation
import Security

/// Manages end-to-end encryption for cloud sync using rclone's crypt backend.
/// Files are encrypted locally before upload, ensuring zero-knowledge encryption.
final class EncryptionManager {
    static let shared = EncryptionManager()
    
    private let keychainService = "com.cloudsync.encryption"
    
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
        "proton-encrypted"
    }
    
    // MARK: - Keychain Operations
    
    func savePassword(_ password: String) throws {
        try saveToKeychain(key: "password", value: password)
    }
    
    func getPassword() -> String? {
        getFromKeychain(key: "password")
    }
    
    func saveSalt(_ salt: String) throws {
        try saveToKeychain(key: "salt", value: salt)
    }
    
    func getSalt() -> String? {
        getFromKeychain(key: "salt")
    }
    
    private func saveToKeychain(key: String, value: String) throws {
        let data = value.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key
        ]
        
        // Delete existing item
        SecItemDelete(query as CFDictionary)
        
        var newItem = query
        newItem[kSecValueData as String] = data
        newItem[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        
        let status = SecItemAdd(newItem as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw EncryptionError.keychainError(status)
        }
    }
    
    private func getFromKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return value
    }
    
    func deleteEncryptionCredentials() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService
        ]
        SecItemDelete(query as CFDictionary)
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
    case keychainError(OSStatus)
    case configurationFailed(String)
    case passwordMismatch
    case notConfigured
    
    var errorDescription: String? {
        switch self {
        case .keychainError(let status):
            return "Keychain error: \(status)"
        case .configurationFailed(let message):
            return "Encryption configuration failed: \(message)"
        case .passwordMismatch:
            return "Passwords do not match"
        case .notConfigured:
            return "Encryption is not configured"
        }
    }
}
