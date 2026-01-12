//
//  KeychainManagerTests.swift
//  CloudSyncAppTests
//
//  Unit tests for KeychainManager and credential storage
//

import XCTest
@testable import CloudSyncApp

final class KeychainManagerTests: XCTestCase {
    
    // Use a unique test key prefix to avoid conflicts
    private let testPrefix = "test_keychain_\(UUID().uuidString.prefix(8))_"
    
    override func tearDown() {
        super.tearDown()
        // Clean up test keys
        cleanupTestKeys()
    }
    
    private func cleanupTestKeys() {
        // Clean up any test keys we created
        let keysToClean = [
            "\(testPrefix)string",
            "\(testPrefix)data",
            "\(testPrefix)object",
            "\(testPrefix)proton"
        ]
        for key in keysToClean {
            try? KeychainManager.shared.delete(forKey: key)
        }
    }
    
    // MARK: - String Storage Tests
    
    func testSaveAndRetrieveString() throws {
        let key = "\(testPrefix)string"
        let testValue = "TestPassword123!"
        
        // Save
        try KeychainManager.shared.save(testValue, forKey: key)
        
        // Retrieve
        let retrieved = try KeychainManager.shared.getString(forKey: key)
        
        XCTAssertEqual(retrieved, testValue)
    }
    
    func testUpdateString() throws {
        let key = "\(testPrefix)string"
        let originalValue = "Original"
        let updatedValue = "Updated"
        
        // Save original
        try KeychainManager.shared.save(originalValue, forKey: key)
        
        // Update
        try KeychainManager.shared.save(updatedValue, forKey: key)
        
        // Retrieve
        let retrieved = try KeychainManager.shared.getString(forKey: key)
        
        XCTAssertEqual(retrieved, updatedValue)
    }
    
    func testRetrieveNonExistentString() throws {
        let key = "\(testPrefix)nonexistent"
        
        let retrieved = try KeychainManager.shared.getString(forKey: key)
        
        XCTAssertNil(retrieved)
    }
    
    // MARK: - Data Storage Tests
    
    func testSaveAndRetrieveData() throws {
        let key = "\(testPrefix)data"
        let testData = "Test data content".data(using: .utf8)!
        
        // Save
        try KeychainManager.shared.save(testData, forKey: key)
        
        // Retrieve
        let retrieved = try KeychainManager.shared.getData(forKey: key)
        
        XCTAssertEqual(retrieved, testData)
    }
    
    // MARK: - Codable Object Tests
    
    func testSaveAndRetrieveCodableObject() throws {
        let key = "\(testPrefix)object"
        let credentials = CloudCredentials(username: "test@example.com", password: "secret123")
        
        // Save
        try KeychainManager.shared.save(credentials, forKey: key)
        
        // Retrieve
        let retrieved: CloudCredentials? = try KeychainManager.shared.getObject(forKey: key)
        
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.username, "test@example.com")
        XCTAssertEqual(retrieved?.password, "secret123")
    }
    
    // MARK: - Delete Tests
    
    func testDeleteKey() throws {
        let key = "\(testPrefix)string"
        let testValue = "ToBeDeleted"
        
        // Save
        try KeychainManager.shared.save(testValue, forKey: key)
        
        // Verify it exists
        var retrieved = try KeychainManager.shared.getString(forKey: key)
        XCTAssertNotNil(retrieved)
        
        // Delete
        try KeychainManager.shared.delete(forKey: key)
        
        // Verify it's gone
        retrieved = try KeychainManager.shared.getString(forKey: key)
        XCTAssertNil(retrieved)
    }
    
    func testDeleteNonExistentKey() throws {
        // Should not throw when deleting non-existent key
        XCTAssertNoThrow(try KeychainManager.shared.delete(forKey: "\(testPrefix)nonexistent"))
    }
    
    // MARK: - ProtonDriveCredentials Model Tests
    
    func testProtonCredentialsCreation() {
        let creds = ProtonDriveCredentials(
            username: "user@proton.me",
            password: "password123"
        )
        
        XCTAssertEqual(creds.username, "user@proton.me")
        XCTAssertEqual(creds.password, "password123")
        XCTAssertNil(creds.otpSecretKey)
        XCTAssertNil(creds.mailboxPassword)
        XCTAssertFalse(creds.has2FA)
        XCTAssertFalse(creds.hasTwoPassword)
        XCTAssertNotNil(creds.createdAt)
    }
    
    func testProtonCredentialsWith2FA() {
        let creds = ProtonDriveCredentials(
            username: "user@proton.me",
            password: "password123",
            otpSecretKey: "JBSWY3DPEHPK3PXP"
        )
        
        XCTAssertTrue(creds.has2FA)
        XCTAssertEqual(creds.otpSecretKey, "JBSWY3DPEHPK3PXP")
        XCTAssertFalse(creds.hasTwoPassword)
    }
    
    func testProtonCredentialsWithMailboxPassword() {
        let creds = ProtonDriveCredentials(
            username: "user@proton.me",
            password: "password123",
            mailboxPassword: "mailbox456"
        )
        
        XCTAssertFalse(creds.has2FA)
        XCTAssertTrue(creds.hasTwoPassword)
        XCTAssertEqual(creds.mailboxPassword, "mailbox456")
    }
    
    func testProtonCredentialsFullConfiguration() {
        let creds = ProtonDriveCredentials(
            username: "user@proton.me",
            password: "password123",
            otpSecretKey: "JBSWY3DPEHPK3PXP",
            mailboxPassword: "mailbox456"
        )
        
        XCTAssertTrue(creds.has2FA)
        XCTAssertTrue(creds.hasTwoPassword)
        XCTAssertEqual(creds.username, "user@proton.me")
        XCTAssertEqual(creds.password, "password123")
        XCTAssertEqual(creds.otpSecretKey, "JBSWY3DPEHPK3PXP")
        XCTAssertEqual(creds.mailboxPassword, "mailbox456")
    }
    
    func testProtonCredentialsEmptyOTPNotCounted() {
        let creds = ProtonDriveCredentials(
            username: "user@proton.me",
            password: "password123",
            otpSecretKey: ""  // Empty string
        )
        
        XCTAssertFalse(creds.has2FA)  // Empty string should not count as having 2FA
    }
    
    // MARK: - Proton Drive Keychain Integration Tests
    
    func testSaveProtonCredentials() throws {
        // Save
        try KeychainManager.shared.saveProtonCredentials(
            username: "test@proton.me",
            password: "testpass",
            otpSecretKey: "TOTP123",
            mailboxPassword: "mailbox123"
        )
        
        // Verify
        XCTAssertTrue(KeychainManager.shared.hasProtonCredentials)
        
        // Retrieve
        let retrieved = try KeychainManager.shared.getProtonCredentials()
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.username, "test@proton.me")
        XCTAssertEqual(retrieved?.password, "testpass")
        XCTAssertEqual(retrieved?.otpSecretKey, "TOTP123")
        XCTAssertEqual(retrieved?.mailboxPassword, "mailbox123")
        
        // Cleanup
        try KeychainManager.shared.deleteProtonCredentials()
    }
    
    func testDeleteProtonCredentials() throws {
        // Save first
        try KeychainManager.shared.saveProtonCredentials(
            username: "test@proton.me",
            password: "testpass"
        )
        
        XCTAssertTrue(KeychainManager.shared.hasProtonCredentials)
        
        // Delete
        try KeychainManager.shared.deleteProtonCredentials()
        
        // Verify deleted
        XCTAssertFalse(KeychainManager.shared.hasProtonCredentials)
        
        let retrieved = try KeychainManager.shared.getProtonCredentials()
        XCTAssertNil(retrieved)
    }
    
    func testHasProtonCredentialsWhenEmpty() {
        // Make sure there are no credentials
        try? KeychainManager.shared.deleteProtonCredentials()
        
        XCTAssertFalse(KeychainManager.shared.hasProtonCredentials)
    }
    
    func testUpdateProtonCredentials() throws {
        // Save initial
        try KeychainManager.shared.saveProtonCredentials(
            username: "user1@proton.me",
            password: "pass1"
        )
        
        // Update
        try KeychainManager.shared.saveProtonCredentials(
            username: "user2@proton.me",
            password: "pass2",
            otpSecretKey: "NEWTOTP"
        )
        
        // Verify updated
        let retrieved = try KeychainManager.shared.getProtonCredentials()
        XCTAssertEqual(retrieved?.username, "user2@proton.me")
        XCTAssertEqual(retrieved?.password, "pass2")
        XCTAssertEqual(retrieved?.otpSecretKey, "NEWTOTP")
        
        // Cleanup
        try KeychainManager.shared.deleteProtonCredentials()
    }
    
    // MARK: - Generic Cloud Credentials Tests
    
    func testSaveGenericCredentials() throws {
        let provider = "test_provider"
        
        try KeychainManager.shared.saveCredentials(
            provider: provider,
            username: "user@example.com",
            password: "genericpass"
        )
        
        let retrieved = try KeychainManager.shared.getCredentials(provider: provider)
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.username, "user@example.com")
        XCTAssertEqual(retrieved?.password, "genericpass")
        
        // Cleanup
        try KeychainManager.shared.deleteCredentials(provider: provider)
    }
    
    func testDeleteGenericCredentials() throws {
        let provider = "test_provider"
        
        try KeychainManager.shared.saveCredentials(
            provider: provider,
            username: "user@example.com",
            password: "pass"
        )
        
        try KeychainManager.shared.deleteCredentials(provider: provider)
        
        let retrieved = try KeychainManager.shared.getCredentials(provider: provider)
        XCTAssertNil(retrieved)
    }
    
    // MARK: - OAuth Token Tests
    
    func testSaveAndRetrieveToken() throws {
        let provider = "test_oauth"
        let token = "oauth_token_12345"
        
        try KeychainManager.shared.saveToken(provider: provider, token: token)
        
        let retrieved = try KeychainManager.shared.getToken(provider: provider)
        XCTAssertEqual(retrieved, token)
        
        // Cleanup
        try KeychainManager.shared.deleteToken(provider: provider)
    }
    
    func testDeleteToken() throws {
        let provider = "test_oauth"
        
        try KeychainManager.shared.saveToken(provider: provider, token: "token123")
        try KeychainManager.shared.deleteToken(provider: provider)
        
        let retrieved = try KeychainManager.shared.getToken(provider: provider)
        XCTAssertNil(retrieved)
    }
    
    // MARK: - Edge Case Tests
    
    func testSpecialCharactersInPassword() throws {
        let key = "\(testPrefix)special"
        let specialPassword = "P@$$w0rd!#$%^&*()_+-=[]{}|;':\",./<>?"
        
        try KeychainManager.shared.save(specialPassword, forKey: key)
        
        let retrieved = try KeychainManager.shared.getString(forKey: key)
        XCTAssertEqual(retrieved, specialPassword)
    }
    
    func testUnicodeCharacters() throws {
        let key = "\(testPrefix)unicode"
        let unicodeValue = "密码🔐パスワード"
        
        try KeychainManager.shared.save(unicodeValue, forKey: key)
        
        let retrieved = try KeychainManager.shared.getString(forKey: key)
        XCTAssertEqual(retrieved, unicodeValue)
    }
    
    func testEmptyString() throws {
        let key = "\(testPrefix)empty"
        let emptyValue = ""
        
        try KeychainManager.shared.save(emptyValue, forKey: key)
        
        let retrieved = try KeychainManager.shared.getString(forKey: key)
        XCTAssertEqual(retrieved, emptyValue)
    }
    
    func testLongPassword() throws {
        let key = "\(testPrefix)long"
        let longPassword = String(repeating: "A", count: 10000)
        
        try KeychainManager.shared.save(longPassword, forKey: key)
        
        let retrieved = try KeychainManager.shared.getString(forKey: key)
        XCTAssertEqual(retrieved, longPassword)
    }
    
    // MARK: - CloudCredentials Model Tests
    
    func testCloudCredentialsCreation() {
        let creds = CloudCredentials(username: "user@test.com", password: "pass123")
        
        XCTAssertEqual(creds.username, "user@test.com")
        XCTAssertEqual(creds.password, "pass123")
        XCTAssertNotNil(creds.createdAt)
    }
    
    func testCloudCredentialsCodable() throws {
        let original = CloudCredentials(username: "test@test.com", password: "secret")

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(CloudCredentials.self, from: data)

        XCTAssertEqual(decoded.username, original.username)
        XCTAssertEqual(decoded.password, original.password)
    }

    // MARK: - Accessibility Tests (Task: KeychainManager Accessibility)

    func test_KeychainManager_SaveAndRetrieve_WorksCorrectly() throws {
        // Test that saving and retrieving works with unique test key
        let testKey = "testRemote_\(UUID().uuidString)"
        let testPassword = "testPassword123"

        // Save
        try KeychainManager.shared.save(testPassword, forKey: testKey)

        // Retrieve
        let retrieved = try KeychainManager.shared.getString(forKey: testKey)
        XCTAssertEqual(retrieved, testPassword, "Retrieved password should match saved password")

        // Cleanup
        try KeychainManager.shared.delete(forKey: testKey)
    }

    func test_KeychainManager_DeletePassword_RemovesEntry() throws {
        let testKey = "testRemote_\(UUID().uuidString)"
        let testPassword = "testPassword123"

        // Save first
        try KeychainManager.shared.save(testPassword, forKey: testKey)

        // Verify it exists
        let beforeDelete = try KeychainManager.shared.getString(forKey: testKey)
        XCTAssertNotNil(beforeDelete, "Password should exist before deletion")

        // Delete
        try KeychainManager.shared.delete(forKey: testKey)

        // Verify gone
        let afterDelete = try KeychainManager.shared.getString(forKey: testKey)
        XCTAssertNil(afterDelete, "Password should be nil after deletion")
    }

    func test_KeychainManager_MultipleKeys_IndependentStorage() throws {
        // Verify multiple keys are stored independently
        let key1 = "testKey1_\(UUID().uuidString)"
        let key2 = "testKey2_\(UUID().uuidString)"
        let password1 = "password1"
        let password2 = "password2"

        // Save both
        try KeychainManager.shared.save(password1, forKey: key1)
        try KeychainManager.shared.save(password2, forKey: key2)

        // Retrieve and verify independence
        let retrieved1 = try KeychainManager.shared.getString(forKey: key1)
        let retrieved2 = try KeychainManager.shared.getString(forKey: key2)

        XCTAssertEqual(retrieved1, password1, "Key1 should return password1")
        XCTAssertEqual(retrieved2, password2, "Key2 should return password2")
        XCTAssertNotEqual(retrieved1, retrieved2, "Different keys should return different values")

        // Delete one and verify other is unaffected
        try KeychainManager.shared.delete(forKey: key1)

        let afterDelete1 = try KeychainManager.shared.getString(forKey: key1)
        let afterDelete2 = try KeychainManager.shared.getString(forKey: key2)

        XCTAssertNil(afterDelete1, "Deleted key should return nil")
        XCTAssertEqual(afterDelete2, password2, "Undeleted key should still return its value")

        // Cleanup
        try KeychainManager.shared.delete(forKey: key2)
    }

    func test_KeychainManager_OverwriteExisting_ReturnsNewValue() throws {
        let testKey = "testOverwrite_\(UUID().uuidString)"
        let originalPassword = "originalPassword"
        let newPassword = "newPassword"

        // Save original
        try KeychainManager.shared.save(originalPassword, forKey: testKey)

        // Overwrite with new value
        try KeychainManager.shared.save(newPassword, forKey: testKey)

        // Retrieve and verify new value
        let retrieved = try KeychainManager.shared.getString(forKey: testKey)
        XCTAssertEqual(retrieved, newPassword, "Should return the new overwritten value")

        // Cleanup
        try KeychainManager.shared.delete(forKey: testKey)
    }

    func test_KeychainManager_NonExistentKey_ReturnsNil() throws {
        let nonExistentKey = "nonexistent_\(UUID().uuidString)"

        let retrieved = try KeychainManager.shared.getString(forKey: nonExistentKey)
        XCTAssertNil(retrieved, "Non-existent key should return nil")
    }
}
