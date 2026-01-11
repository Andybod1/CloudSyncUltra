//
//  KeychainManager.swift
//  CloudSyncApp
//
//  Secure credential storage using macOS Keychain Services
//  Provides type-safe access to sensitive data with proper error handling
//

import Foundation
import Security
import OSLog

/// Manages secure storage of sensitive data in macOS Keychain
class KeychainManager {
    static let shared = KeychainManager()
    
    private let service: String
    private let accessGroup: String?
    
    private init() {
        // Use bundle identifier as service name
        self.service = Bundle.main.bundleIdentifier ?? "com.cloudsync.app"
        self.accessGroup = nil // Can be configured for keychain sharing
    }
    
    // MARK: - Keychain Errors
    
    enum KeychainError: LocalizedError {
        case itemNotFound
        case duplicateItem
        case invalidData
        case unexpectedStatus(OSStatus)
        case encodingFailed
        case decodingFailed
        
        var errorDescription: String? {
            switch self {
            case .itemNotFound:
                return "Item not found in keychain"
            case .duplicateItem:
                return "Item already exists in keychain"
            case .invalidData:
                return "Invalid data format"
            case .unexpectedStatus(let status):
                return "Keychain error: \(status)"
            case .encodingFailed:
                return "Failed to encode data"
            case .decodingFailed:
                return "Failed to decode data"
            }
        }
    }
    
    // MARK: - Save Operations
    
    /// Save a string value securely
    /// - Parameters:
    ///   - value: The string to save
    ///   - key: Unique identifier for this value
    /// - Throws: KeychainError if save fails
    func save(_ value: String, forKey key: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.encodingFailed
        }
        try save(data, forKey: key)
    }
    
    /// Save data securely
    /// - Parameters:
    ///   - data: The data to save
    ///   - key: Unique identifier for this data
    /// - Throws: KeychainError if save fails
    func save(_ data: Data, forKey key: String) throws {
        // Try to update existing item first
        var query = buildQuery(forKey: key)
        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        
        if updateStatus == errSecItemNotFound {
            // Item doesn't exist, create it
            query[kSecValueData as String] = data
            query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlocked
            
            let status = SecItemAdd(query as CFDictionary, nil)
            
            guard status == errSecSuccess else {
                Logger.auth.error("Failed to save keychain item: \(key, privacy: .private) - status: \(status)")
                if status == errSecDuplicateItem {
                    throw KeychainError.duplicateItem
                }
                throw KeychainError.unexpectedStatus(status)
            }
            
            Logger.auth.debug("Saved keychain item: \(key, privacy: .private)")
        } else if updateStatus == errSecSuccess {
            Logger.auth.debug("Updated keychain item: \(key, privacy: .private)")
        } else {
            Logger.auth.error("Failed to update keychain item: \(key, privacy: .private) - status: \(updateStatus)")
            throw KeychainError.unexpectedStatus(updateStatus)
        }
    }
    
    /// Save a Codable object securely
    /// - Parameters:
    ///   - object: The object to save
    ///   - key: Unique identifier
    /// - Throws: KeychainError if save fails
    func save<T: Codable>(_ object: T, forKey key: String) throws {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(object) else {
            throw KeychainError.encodingFailed
        }
        try save(data, forKey: key)
    }
    
    // MARK: - Retrieve Operations
    
    /// Retrieve a string value
    /// - Parameter key: Unique identifier
    /// - Returns: The stored string, or nil if not found
    /// - Throws: KeychainError if retrieval fails
    func getString(forKey key: String) throws -> String? {
        guard let data = try getData(forKey: key) else {
            return nil
        }
        
        guard let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.decodingFailed
        }
        
        return string
    }
    
    /// Retrieve data
    /// - Parameter key: Unique identifier
    /// - Returns: The stored data, or nil if not found
    /// - Throws: KeychainError if retrieval fails
    func getData(forKey key: String) throws -> Data? {
        var query = buildQuery(forKey: key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecItemNotFound {
            Logger.auth.debug("Keychain item not found: \(key, privacy: .private)")
            return nil
        }
        
        guard status == errSecSuccess else {
            Logger.auth.error("Failed to retrieve keychain item: \(key, privacy: .private) - status: \(status)")
            throw KeychainError.unexpectedStatus(status)
        }
        
        guard let data = result as? Data else {
            throw KeychainError.invalidData
        }
        
        Logger.auth.debug("Retrieved keychain item: \(key, privacy: .private)")
        return data
    }
    
    /// Retrieve a Codable object
    /// - Parameter key: Unique identifier
    /// - Returns: The decoded object, or nil if not found
    /// - Throws: KeychainError if retrieval fails
    func getObject<T: Codable>(forKey key: String) throws -> T? {
        guard let data = try getData(forKey: key) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        guard let object = try? decoder.decode(T.self, from: data) else {
            throw KeychainError.decodingFailed
        }
        
        return object
    }
    
    // MARK: - Delete Operations
    
    /// Delete an item from keychain
    /// - Parameter key: Unique identifier
    /// - Throws: KeychainError if deletion fails
    func delete(forKey key: String) throws {
        let query = buildQuery(forKey: key)
        let status = SecItemDelete(query as CFDictionary)
        
        if status == errSecItemNotFound {
            Logger.auth.debug("Keychain item not found for deletion: \(key, privacy: .private)")
            return // Not an error if item doesn't exist
        }
        
        guard status == errSecSuccess else {
            Logger.auth.error("Failed to delete keychain item: \(key, privacy: .private) - status: \(status)")
            throw KeychainError.unexpectedStatus(status)
        }
        
        Logger.auth.info("Deleted keychain item: \(key, privacy: .private)")
    }
    
    /// Delete all items for this app
    /// - Throws: KeychainError if deletion fails
    func deleteAll() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            Logger.auth.error("Failed to delete all keychain items - status: \(status)")
            throw KeychainError.unexpectedStatus(status)
        }
        
        Logger.auth.info("Deleted all keychain items")
    }
    
    // MARK: - Helper Methods
    
    private func buildQuery(forKey key: String) -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        return query
    }
}

// MARK: - Convenience Extensions

extension KeychainManager {
    // MARK: - Cloud Provider Credentials
    
    /// Save cloud provider credentials
    func saveCredentials(provider: String, username: String, password: String) throws {
        let credentials = CloudCredentials(username: username, password: password)
        try save(credentials, forKey: "credentials_\(provider)")
        Logger.auth.info("Saved credentials for provider: \(provider)")
    }
    
    /// Retrieve cloud provider credentials
    func getCredentials(provider: String) throws -> CloudCredentials? {
        return try getObject(forKey: "credentials_\(provider)")
    }
    
    /// Delete cloud provider credentials
    func deleteCredentials(provider: String) throws {
        try delete(forKey: "credentials_\(provider)")
        Logger.auth.info("Deleted credentials for provider: \(provider)")
    }
    
    // MARK: - OAuth Tokens
    
    /// Save OAuth token
    func saveToken(provider: String, token: String) throws {
        try save(token, forKey: "token_\(provider)")
        Logger.auth.info("Saved OAuth token for provider: \(provider)")
    }
    
    /// Retrieve OAuth token
    func getToken(provider: String) throws -> String? {
        return try getString(forKey: "token_\(provider)")
    }
    
    /// Delete OAuth token
    func deleteToken(provider: String) throws {
        try delete(forKey: "token_\(provider)")
        Logger.auth.info("Deleted OAuth token for provider: \(provider)")
    }
    
    // MARK: - Encryption Keys
    
    /// Save encryption key
    func saveEncryptionKey(_ key: String) throws {
        try save(key, forKey: "encryption_key")
        Logger.auth.info("Saved encryption key")
    }
    
    /// Retrieve encryption key
    func getEncryptionKey() throws -> String? {
        return try getString(forKey: "encryption_key")
    }
    
    /// Delete encryption key
    func deleteEncryptionKey() throws {
        try delete(forKey: "encryption_key")
        Logger.auth.warning("Deleted encryption key")
    }
}

// MARK: - Models

/// Cloud provider credentials
struct CloudCredentials: Codable {
    let username: String
    let password: String
    let createdAt: Date
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
        self.createdAt = Date()
    }
}

// MARK: - Migration Helper

extension KeychainManager {
    /// Migrate credentials from UserDefaults to Keychain
    /// This should be called once during app upgrade
    func migrateFromUserDefaults() {
        Logger.config.info("Starting keychain migration from UserDefaults")
        
        let defaults = UserDefaults.standard
        var migratedCount = 0
        
        // List of known credential keys in UserDefaults
        let keysToMigrate = [
            "proton_username", "proton_password",
            "mega_username", "mega_password",
            "webdav_username", "webdav_password"
            // Add more as needed
        ]
        
        for key in keysToMigrate {
            if let value = defaults.string(forKey: key) {
                do {
                    try save(value, forKey: key)
                    defaults.removeObject(forKey: key)
                    migratedCount += 1
                } catch {
                    Logger.config.error("Failed to migrate \(key, privacy: .private): \(error.localizedDescription)")
                }
            }
        }
        
        if migratedCount > 0 {
            Logger.config.info("Successfully migrated \(migratedCount) credentials to keychain")
        }
    }
}

// MARK: - Usage Examples

/*
 // Save credentials
 try KeychainManager.shared.saveCredentials(
     provider: "google_drive",
     username: "user@example.com",
     password: "secret123"
 )
 
 // Retrieve credentials
 if let creds = try KeychainManager.shared.getCredentials(provider: "google_drive") {
     print("Username: \(creds.username)")
     // Use credentials...
 }
 
 // Save OAuth token
 try KeychainManager.shared.saveToken(provider: "dropbox", token: "abc123xyz")
 
 // Retrieve OAuth token
 if let token = try KeychainManager.shared.getToken(provider: "dropbox") {
     // Use token...
 }
 
 // Save encryption key
 try KeychainManager.shared.saveEncryptionKey("my-super-secret-key")
 
 // Delete specific credentials
 try KeychainManager.shared.deleteCredentials(provider: "google_drive")
 
 // Delete all keychain data (use with caution!)
 try KeychainManager.shared.deleteAll()
 */
