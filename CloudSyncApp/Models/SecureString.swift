//
//  SecureString.swift
//  CloudSyncApp
//
//  Secure string wrapper for handling sensitive data like passwords and tokens (#119)
//  Provides automatic memory clearing when no longer needed
//

import Foundation
import Security

// MARK: - Secure String Wrapper (#119)

/// A secure wrapper for sensitive string data that ensures memory is cleared when deallocated
/// Use this for passwords, tokens, API keys, and other sensitive credentials
final class SecureString {

    // MARK: - Properties

    /// Internal storage using Data for secure memory handling
    private var storage: Data

    /// Length of the secure string
    var length: Int {
        storage.count
    }

    /// Check if the secure string is empty
    var isEmpty: Bool {
        storage.isEmpty
    }

    // MARK: - Initialization

    /// Initialize with a string value
    /// - Parameter string: The sensitive string to store securely
    init(_ string: String) {
        self.storage = Data(string.utf8)
    }

    /// Initialize with raw bytes
    /// - Parameter data: Raw data to store securely
    init(data: Data) {
        self.storage = data
    }

    /// Initialize empty secure string
    init() {
        self.storage = Data()
    }

    // MARK: - Deinitialization

    deinit {
        // Securely clear the memory before deallocation
        clearMemory()
    }

    // MARK: - Secure Operations

    /// Access the string value temporarily
    /// The string should be used immediately and not stored
    /// - Parameter block: Closure that receives the decrypted string value
    /// - Returns: The result of the closure
    @discardableResult
    func withUnsafeValue<T>(_ block: (String) throws -> T) rethrows -> T {
        let string = String(decoding: storage, as: UTF8.self)
        defer {
            // Note: We can't zero out the Swift String's internal buffer,
            // but we minimize exposure by using defer
        }
        return try block(string)
    }

    /// Access the raw bytes temporarily
    /// - Parameter block: Closure that receives the raw bytes
    /// - Returns: The result of the closure
    @discardableResult
    func withUnsafeBytes<T>(_ block: (UnsafeRawBufferPointer) throws -> T) rethrows -> T {
        return try storage.withUnsafeBytes(block)
    }

    /// Get the string value (use sparingly, prefer withUnsafeValue)
    /// - Returns: The decrypted string value
    func getValue() -> String {
        return String(decoding: storage, as: UTF8.self)
    }

    /// Clear the secure string memory immediately
    /// Call this when you're done with the sensitive data
    func clear() {
        clearMemory()
    }

    // MARK: - Private Methods

    /// Securely clear the internal storage by overwriting with zeros
    private func clearMemory() {
        guard !storage.isEmpty else { return }

        // Overwrite with zeros before releasing
        storage.resetBytes(in: 0..<storage.count)

        // Additional paranoid clearing with random data then zeros
        storage.withUnsafeMutableBytes { buffer in
            guard let baseAddress = buffer.baseAddress else { return }
            // First pass: random data
            _ = SecRandomCopyBytes(kSecRandomDefault, buffer.count, baseAddress)
            // Second pass: zeros
            memset(baseAddress, 0, buffer.count)
        }

        // Clear the data object
        storage = Data()
    }
}

// MARK: - Secure Data Extension

extension Data {

    /// Create a mutable copy that can be securely cleared
    /// - Returns: A new Data instance that can be modified
    func secureClone() -> Data {
        var clone = Data(self)
        return clone
    }

    /// Securely clear this data by overwriting with zeros
    /// Note: Only works on mutable Data instances
    mutating func secureClear() {
        guard !isEmpty else { return }
        resetBytes(in: 0..<count)
    }
}

// MARK: - Secure Credentials Container (#119)

/// Container for storing multiple credentials securely
/// Automatically clears all credentials on deallocation
final class SecureCredentials {

    // MARK: - Properties

    private var credentials: [String: SecureString] = [:]
    private let lock = NSLock()

    // MARK: - Initialization

    init() {}

    deinit {
        clearAll()
    }

    // MARK: - Public API

    /// Store a credential securely
    /// - Parameters:
    ///   - value: The sensitive value to store
    ///   - key: The key to identify this credential
    func set(_ value: String, forKey key: String) {
        lock.lock()
        defer { lock.unlock() }

        // Clear existing value if any
        credentials[key]?.clear()
        credentials[key] = SecureString(value)
    }

    /// Retrieve a credential value
    /// - Parameter key: The key identifying the credential
    /// - Returns: The credential value, or nil if not found
    func get(_ key: String) -> String? {
        lock.lock()
        defer { lock.unlock() }

        return credentials[key]?.getValue()
    }

    /// Access a credential value temporarily
    /// - Parameters:
    ///   - key: The key identifying the credential
    ///   - block: Closure that receives the value
    /// - Returns: The result of the closure, or nil if credential not found
    @discardableResult
    func withValue<T>(forKey key: String, _ block: (String) throws -> T) rethrows -> T? {
        lock.lock()
        defer { lock.unlock() }

        guard let secureString = credentials[key] else { return nil }
        return try secureString.withUnsafeValue(block)
    }

    /// Remove and clear a specific credential
    /// - Parameter key: The key identifying the credential
    func remove(_ key: String) {
        lock.lock()
        defer { lock.unlock() }

        credentials[key]?.clear()
        credentials.removeValue(forKey: key)
    }

    /// Clear all stored credentials
    func clearAll() {
        lock.lock()
        defer { lock.unlock() }

        for (_, secureString) in credentials {
            secureString.clear()
        }
        credentials.removeAll()
    }

    /// Check if a credential exists
    /// - Parameter key: The key to check
    /// - Returns: True if credential exists
    func hasCredential(_ key: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }

        return credentials[key] != nil
    }
}

// MARK: - Common Credential Keys

extension SecureCredentials {

    /// Standard keys for common credential types
    enum Key {
        static let password = "password"
        static let token = "token"
        static let apiKey = "apiKey"
        static let secret = "secret"
        static let twoFactorCode = "2fa"
        static let mailboxPassword = "mailboxPassword"
        static let refreshToken = "refreshToken"
        static let accessToken = "accessToken"
    }
}

// MARK: - Secure String Utilities

extension String {

    /// Convert to a secure string for sensitive data handling
    /// - Returns: A SecureString wrapping this value
    func toSecure() -> SecureString {
        return SecureString(self)
    }
}
