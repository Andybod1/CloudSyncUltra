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
        self.service = Bundle.main.bundleIdentifier ?? "com.cloudsync.app"
        self.accessGroup = nil
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
    func save(_ value: String, forKey key: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.encodingFailed
        }
        try save(data, forKey: key)
    }
    
    /// Save data securely
    func save(_ data: Data, forKey key: String) throws {
        var query = buildQuery(forKey: key)
        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        
        if updateStatus == errSecItemNotFound {
            query[kSecValueData as String] = data
            query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlocked
            
            let status = SecItemAdd(query as CFDictionary, nil)
            guard status == errSecSuccess else {
                if status == errSecDuplicateItem {
                    throw KeychainError.duplicateItem
                }
                throw KeychainError.unexpectedStatus(status)
            }
        } else if updateStatus != errSecSuccess {
            throw KeychainError.unexpectedStatus(updateStatus)
        }
    }
    
    /// Save a Codable object securely
    func save<T: Codable>(_ object: T, forKey key: String) throws {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(object) else {
            throw KeychainError.encodingFailed
        }
        try save(data, forKey: key)
    }
    
    // MARK: - Retrieve Operations
    
    /// Retrieve a string value
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
    func getData(forKey key: String) throws -> Data? {
        var query = buildQuery(forKey: key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecItemNotFound {
            return nil
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
        
        guard let data = result as? Data else {
            throw KeychainError.invalidData
        }
        return data
    }
    
    /// Retrieve a Codable object
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
    func delete(forKey key: String) throws {
        let query = buildQuery(forKey: key)
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    /// Delete all items for this app
    func deleteAll() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    // MARK: - Accessibility Check

    /// Checks if the Keychain is accessible
    /// - Returns: true if Keychain operations are possible
    static func isKeychainAccessible() -> Bool {
        let testKey = "com.cloudsync.accessibilityTest"
        let testData = "test".data(using: .utf8)!

        // Try to save
        let saveQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: testKey,
            kSecValueData as String: testData
        ]

        // Delete any existing item first
        SecItemDelete(saveQuery as CFDictionary)

        // Try to add
        let status = SecItemAdd(saveQuery as CFDictionary, nil)

        // Clean up
        SecItemDelete(saveQuery as CFDictionary)

        return status == errSecSuccess
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

// MARK: - Proton Drive Credentials Model

/// Proton Drive credentials with full 2FA support
struct ProtonDriveCredentials: Codable {
    let username: String
    let password: String
    let otpSecretKey: String?
    let mailboxPassword: String?
    let createdAt: Date
    
    init(username: String, password: String, otpSecretKey: String? = nil, mailboxPassword: String? = nil) {
        self.username = username
        self.password = password
        self.otpSecretKey = otpSecretKey
        self.mailboxPassword = mailboxPassword
        self.createdAt = Date()
    }
    
    /// Check if 2FA is configured
    var has2FA: Bool {
        otpSecretKey != nil && !otpSecretKey!.isEmpty
    }
    
    /// Check if mailbox password is set (two-password account)
    var hasTwoPassword: Bool {
        mailboxPassword != nil && !mailboxPassword!.isEmpty
    }
}

// MARK: - Proton Drive Keychain Extension

extension KeychainManager {
    private static let protonCredentialsKey = "proton_drive_credentials"
    
    /// Save Proton Drive credentials securely
    func saveProtonCredentials(
        username: String,
        password: String,
        otpSecretKey: String? = nil,
        mailboxPassword: String? = nil
    ) throws {
        let credentials = ProtonDriveCredentials(
            username: username,
            password: password,
            otpSecretKey: otpSecretKey,
            mailboxPassword: mailboxPassword
        )
        try save(credentials, forKey: Self.protonCredentialsKey)
    }
    
    /// Retrieve Proton Drive credentials
    func getProtonCredentials() throws -> ProtonDriveCredentials? {
        return try getObject(forKey: Self.protonCredentialsKey)
    }
    
    /// Delete Proton Drive credentials
    func deleteProtonCredentials() throws {
        try delete(forKey: Self.protonCredentialsKey)
    }
    
    /// Check if Proton Drive credentials exist
    var hasProtonCredentials: Bool {
        do {
            return try getProtonCredentials() != nil
        } catch {
            return false
        }
    }
    
    /// Update just the OTP secret (for session refresh)
    func updateProtonOTPSecret(_ otpSecretKey: String) throws {
        guard let existing = try getProtonCredentials() else {
            throw KeychainError.itemNotFound
        }
        try saveProtonCredentials(
            username: existing.username,
            password: existing.password,
            otpSecretKey: otpSecretKey,
            mailboxPassword: existing.mailboxPassword
        )
    }
}

// MARK: - Generic Cloud Credentials

/// Generic cloud provider credentials
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

extension KeychainManager {
    // MARK: - Cloud Provider Credentials
    
    /// Save cloud provider credentials
    func saveCredentials(provider: String, username: String, password: String) throws {
        let credentials = CloudCredentials(username: username, password: password)
        try save(credentials, forKey: "credentials_\(provider)")
    }
    
    /// Retrieve cloud provider credentials
    func getCredentials(provider: String) throws -> CloudCredentials? {
        return try getObject(forKey: "credentials_\(provider)")
    }
    
    /// Delete cloud provider credentials
    func deleteCredentials(provider: String) throws {
        try delete(forKey: "credentials_\(provider)")
    }
    
    // MARK: - OAuth Tokens
    
    /// Save OAuth token
    func saveToken(provider: String, token: String) throws {
        try save(token, forKey: "token_\(provider)")
    }
    
    /// Retrieve OAuth token
    func getToken(provider: String) throws -> String? {
        return try getString(forKey: "token_\(provider)")
    }
    
    /// Delete OAuth token
    func deleteToken(provider: String) throws {
        try delete(forKey: "token_\(provider)")
    }
}
