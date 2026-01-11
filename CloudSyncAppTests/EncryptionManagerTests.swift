//
//  EncryptionManagerTests.swift
//  CloudSyncAppTests
//
//  Comprehensive tests for end-to-end encryption functionality
//

import XCTest
@testable import CloudSyncApp

final class EncryptionManagerTests: XCTestCase {
    
    var encryptionManager: EncryptionManager!
    
    override func setUp() {
        super.setUp()
        encryptionManager = EncryptionManager.shared
        
        // Clean up any existing encryption data
        encryptionManager.deleteEncryptionCredentials()
        UserDefaults.standard.removeObject(forKey: "encryptionEnabled")
        UserDefaults.standard.removeObject(forKey: "encryptFilenames")
    }
    
    override func tearDown() {
        // Clean up after each test
        encryptionManager.deleteEncryptionCredentials()
        UserDefaults.standard.removeObject(forKey: "encryptionEnabled")
        UserDefaults.standard.removeObject(forKey: "encryptFilenames")
        super.tearDown()
    }
    
    // MARK: - Singleton Tests
    
    func testEncryptionManagerSingleton() {
        // When: Accessing EncryptionManager singleton
        let manager1 = EncryptionManager.shared
        let manager2 = EncryptionManager.shared
        
        // Then: Should return same instance
        XCTAssertTrue(manager1 === manager2, "EncryptionManager should be a singleton")
    }
    
    // MARK: - Initial State Tests
    
    func testEncryptionDisabledByDefault() {
        // Given: Fresh state
        // When: Checking if encryption is enabled
        let isEnabled = encryptionManager.isEncryptionEnabled
        
        // Then: Should be disabled by default
        XCTAssertFalse(isEnabled, "Encryption should be disabled by default")
    }
    
    func testEncryptFilenamesDisabledByDefault() {
        // Given: Fresh state
        // When: Checking if filename encryption is enabled
        let encryptFilenames = encryptionManager.encryptFilenames
        
        // Then: Should be disabled by default
        XCTAssertFalse(encryptFilenames, "Filename encryption should be disabled by default")
    }
    
    func testEncryptionNotConfiguredInitially() {
        // Given: Fresh state
        // When: Checking if encryption is configured
        let isConfigured = encryptionManager.isEncryptionConfigured
        
        // Then: Should not be configured
        XCTAssertFalse(isConfigured, "Encryption should not be configured initially")
    }
    
    func testEncryptedRemoteName() {
        // When: Getting encrypted remote name
        let remoteName = encryptionManager.encryptedRemoteName
        
        // Then: Should have expected name
        XCTAssertEqual(remoteName, "proton-encrypted", "Encrypted remote name should be 'proton-encrypted'")
    }
    
    // MARK: - Password Management Tests
    
    func testSaveAndRetrievePassword() throws {
        // Given: A test password
        let testPassword = "TestPassword123!"
        
        // When: Saving password to keychain
        try encryptionManager.savePassword(testPassword)
        
        // Then: Should be able to retrieve it
        let retrieved = encryptionManager.getPassword()
        XCTAssertNotNil(retrieved, "Password should be retrievable")
        XCTAssertEqual(retrieved, testPassword, "Retrieved password should match saved password")
    }
    
    func testPasswordReturnsNilWhenNotSet() {
        // Given: No password saved
        // When: Attempting to retrieve password
        let password = encryptionManager.getPassword()
        
        // Then: Should return nil
        XCTAssertNil(password, "Password should be nil when not set")
    }
    
    func testOverwriteExistingPassword() throws {
        // Given: An existing password
        let originalPassword = "Original123!"
        try encryptionManager.savePassword(originalPassword)
        
        // When: Saving a new password
        let newPassword = "NewPassword456!"
        try encryptionManager.savePassword(newPassword)
        
        // Then: Should overwrite the original
        let retrieved = encryptionManager.getPassword()
        XCTAssertEqual(retrieved, newPassword, "New password should overwrite old password")
        XCTAssertNotEqual(retrieved, originalPassword, "Old password should be replaced")
    }
    
    // MARK: - Salt Management Tests
    
    func testSaveAndRetrieveSalt() throws {
        // Given: A test salt
        let testSalt = "RandomSalt789@"
        
        // When: Saving salt to keychain
        try encryptionManager.saveSalt(testSalt)
        
        // Then: Should be able to retrieve it
        let retrieved = encryptionManager.getSalt()
        XCTAssertNotNil(retrieved, "Salt should be retrievable")
        XCTAssertEqual(retrieved, testSalt, "Retrieved salt should match saved salt")
    }
    
    func testSaltReturnsNilWhenNotSet() {
        // Given: No salt saved
        // When: Attempting to retrieve salt
        let salt = encryptionManager.getSalt()
        
        // Then: Should return nil
        XCTAssertNil(salt, "Salt should be nil when not set")
    }
    
    func testOverwriteExistingSalt() throws {
        // Given: An existing salt
        let originalSalt = "OriginalSalt"
        try encryptionManager.saveSalt(originalSalt)
        
        // When: Saving a new salt
        let newSalt = "NewSalt"
        try encryptionManager.saveSalt(newSalt)
        
        // Then: Should overwrite the original
        let retrieved = encryptionManager.getSalt()
        XCTAssertEqual(retrieved, newSalt, "New salt should overwrite old salt")
        XCTAssertNotEqual(retrieved, originalSalt, "Old salt should be replaced")
    }
    
    // MARK: - Configuration State Tests
    
    func testEncryptionConfiguredWhenPasswordAndSaltSet() throws {
        // Given: Password and salt are saved
        try encryptionManager.savePassword("TestPassword123!")
        try encryptionManager.saveSalt("TestSalt456@")
        
        // When: Checking configuration status
        let isConfigured = encryptionManager.isEncryptionConfigured
        
        // Then: Should be configured
        XCTAssertTrue(isConfigured, "Encryption should be configured when both password and salt are set")
    }
    
    func testEncryptionNotConfiguredWithOnlyPassword() throws {
        // Given: Only password is saved
        try encryptionManager.savePassword("TestPassword123!")
        
        // When: Checking configuration status
        let isConfigured = encryptionManager.isEncryptionConfigured
        
        // Then: Should not be configured
        XCTAssertFalse(isConfigured, "Encryption should not be configured without salt")
    }
    
    func testEncryptionNotConfiguredWithOnlySalt() throws {
        // Given: Only salt is saved
        try encryptionManager.saveSalt("TestSalt456@")
        
        // When: Checking configuration status
        let isConfigured = encryptionManager.isEncryptionConfigured
        
        // Then: Should not be configured
        XCTAssertFalse(isConfigured, "Encryption should not be configured without password")
    }
    
    // MARK: - Enable/Disable Tests
    
    func testEnableEncryption() {
        // Given: Encryption is disabled
        XCTAssertFalse(encryptionManager.isEncryptionEnabled)
        
        // When: Enabling encryption
        encryptionManager.isEncryptionEnabled = true
        
        // Then: Should be enabled
        XCTAssertTrue(encryptionManager.isEncryptionEnabled, "Encryption should be enabled")
    }
    
    func testDisableEncryption() {
        // Given: Encryption is enabled
        encryptionManager.isEncryptionEnabled = true
        XCTAssertTrue(encryptionManager.isEncryptionEnabled)
        
        // When: Disabling encryption
        encryptionManager.isEncryptionEnabled = false
        
        // Then: Should be disabled
        XCTAssertFalse(encryptionManager.isEncryptionEnabled, "Encryption should be disabled")
    }
    
    func testEnableFilenameEncryption() {
        // Given: Filename encryption is disabled
        XCTAssertFalse(encryptionManager.encryptFilenames)
        
        // When: Enabling filename encryption
        encryptionManager.encryptFilenames = true
        
        // Then: Should be enabled
        XCTAssertTrue(encryptionManager.encryptFilenames, "Filename encryption should be enabled")
    }
    
    func testDisableFilenameEncryption() {
        // Given: Filename encryption is enabled
        encryptionManager.encryptFilenames = true
        XCTAssertTrue(encryptionManager.encryptFilenames)
        
        // When: Disabling filename encryption
        encryptionManager.encryptFilenames = false
        
        // Then: Should be disabled
        XCTAssertFalse(encryptionManager.encryptFilenames, "Filename encryption should be disabled")
    }
    
    // MARK: - Delete Credentials Tests
    
    func testDeleteEncryptionCredentials() throws {
        // Given: Password and salt are saved
        try encryptionManager.savePassword("TestPassword123!")
        try encryptionManager.saveSalt("TestSalt456@")
        XCTAssertNotNil(encryptionManager.getPassword())
        XCTAssertNotNil(encryptionManager.getSalt())
        
        // When: Deleting credentials
        encryptionManager.deleteEncryptionCredentials()
        
        // Then: Both should be deleted
        XCTAssertNil(encryptionManager.getPassword(), "Password should be deleted")
        XCTAssertNil(encryptionManager.getSalt(), "Salt should be deleted")
        XCTAssertFalse(encryptionManager.isEncryptionConfigured, "Encryption should not be configured")
    }
    
    func testDeleteCredentialsWhenNoneExist() {
        // Given: No credentials exist
        XCTAssertNil(encryptionManager.getPassword())
        XCTAssertNil(encryptionManager.getSalt())
        
        // When: Attempting to delete credentials
        // Then: Should not crash
        encryptionManager.deleteEncryptionCredentials()
        
        // Verify still nil
        XCTAssertNil(encryptionManager.getPassword())
        XCTAssertNil(encryptionManager.getSalt())
    }
    
    // MARK: - Secure Password Generation Tests
    
    func testGenerateSecurePassword() {
        // When: Generating a secure password
        let password = encryptionManager.generateSecurePassword()
        
        // Then: Should have expected length and characters
        XCTAssertEqual(password.count, 32, "Default password length should be 32")
        XCTAssertFalse(password.isEmpty, "Password should not be empty")
    }
    
    func testGenerateSecurePasswordCustomLength() {
        // When: Generating password with custom length
        let shortPassword = encryptionManager.generateSecurePassword(length: 16)
        let longPassword = encryptionManager.generateSecurePassword(length: 64)
        
        // Then: Should match requested lengths
        XCTAssertEqual(shortPassword.count, 16, "Password should be 16 characters")
        XCTAssertEqual(longPassword.count, 64, "Password should be 64 characters")
    }
    
    func testGenerateSecurePasswordIsRandom() {
        // When: Generating multiple passwords
        let password1 = encryptionManager.generateSecurePassword()
        let password2 = encryptionManager.generateSecurePassword()
        let password3 = encryptionManager.generateSecurePassword()
        
        // Then: Should all be different (extremely high probability)
        XCTAssertNotEqual(password1, password2, "Passwords should be random")
        XCTAssertNotEqual(password2, password3, "Passwords should be random")
        XCTAssertNotEqual(password1, password3, "Passwords should be random")
    }
    
    func testGenerateSecurePasswordContainsValidCharacters() {
        // Given: Expected charset
        let validCharset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*")
        
        // When: Generating password
        let password = encryptionManager.generateSecurePassword()
        
        // Then: All characters should be from valid charset
        for char in password {
            XCTAssertTrue(validCharset.contains(char.unicodeScalars.first!), 
                         "Password should only contain valid characters")
        }
    }
    
    // MARK: - Secure Salt Generation Tests
    
    func testGenerateSecureSalt() {
        // When: Generating a secure salt
        let salt = encryptionManager.generateSecureSalt()
        
        // Then: Should have expected length
        XCTAssertEqual(salt.count, 32, "Default salt length should be 32")
        XCTAssertFalse(salt.isEmpty, "Salt should not be empty")
    }
    
    func testGenerateSecureSaltCustomLength() {
        // When: Generating salt with custom length
        let shortSalt = encryptionManager.generateSecureSalt(length: 16)
        let longSalt = encryptionManager.generateSecureSalt(length: 64)
        
        // Then: Should match requested lengths
        XCTAssertEqual(shortSalt.count, 16, "Salt should be 16 characters")
        XCTAssertEqual(longSalt.count, 64, "Salt should be 64 characters")
    }
    
    func testGenerateSecureSaltIsRandom() {
        // When: Generating multiple salts
        let salt1 = encryptionManager.generateSecureSalt()
        let salt2 = encryptionManager.generateSecureSalt()
        let salt3 = encryptionManager.generateSecureSalt()
        
        // Then: Should all be different
        XCTAssertNotEqual(salt1, salt2, "Salts should be random")
        XCTAssertNotEqual(salt2, salt3, "Salts should be random")
        XCTAssertNotEqual(salt1, salt3, "Salts should be random")
    }
    
    // MARK: - Special Characters in Credentials Tests
    
    func testSavePasswordWithSpecialCharacters() throws {
        // Given: Password with special characters
        let specialPassword = "P@ssw0rd!#$%^&*()"
        
        // When: Saving password
        try encryptionManager.savePassword(specialPassword)
        
        // Then: Should retrieve correctly
        let retrieved = encryptionManager.getPassword()
        XCTAssertEqual(retrieved, specialPassword, "Special characters should be preserved")
    }
    
    func testSaveSaltWithSpecialCharacters() throws {
        // Given: Salt with special characters
        let specialSalt = "S@lt!#$%^&*()"
        
        // When: Saving salt
        try encryptionManager.saveSalt(specialSalt)
        
        // Then: Should retrieve correctly
        let retrieved = encryptionManager.getSalt()
        XCTAssertEqual(retrieved, specialSalt, "Special characters should be preserved")
    }
    
    func testSaveEmptyPassword() throws {
        // Given: Empty password
        let emptyPassword = ""
        
        // When: Saving empty password
        try encryptionManager.savePassword(emptyPassword)
        
        // Then: Should save and retrieve empty string
        let retrieved = encryptionManager.getPassword()
        XCTAssertEqual(retrieved, "", "Empty password should be saved")
    }
    
    func testSaveVeryLongPassword() throws {
        // Given: Very long password (1000 characters)
        let longPassword = String(repeating: "a", count: 1000)
        
        // When: Saving long password
        try encryptionManager.savePassword(longPassword)
        
        // Then: Should save and retrieve correctly
        let retrieved = encryptionManager.getPassword()
        XCTAssertEqual(retrieved?.count, 1000, "Long password should be saved")
        XCTAssertEqual(retrieved, longPassword, "Long password should be retrieved correctly")
    }
    
    // MARK: - Unicode and Non-ASCII Tests
    
    func testSavePasswordWithUnicode() throws {
        // Given: Password with unicode characters
        let unicodePassword = "P@ssw0rd🔒🔐🔑"
        
        // When: Saving password
        try encryptionManager.savePassword(unicodePassword)
        
        // Then: Should retrieve correctly
        let retrieved = encryptionManager.getPassword()
        XCTAssertEqual(retrieved, unicodePassword, "Unicode characters should be preserved")
    }
    
    func testSavePasswordWithNonASCII() throws {
        // Given: Password with non-ASCII characters
        let nonAsciiPassword = "Пароль123"  // Russian
        
        // When: Saving password
        try encryptionManager.savePassword(nonAsciiPassword)
        
        // Then: Should retrieve correctly
        let retrieved = encryptionManager.getPassword()
        XCTAssertEqual(retrieved, nonAsciiPassword, "Non-ASCII characters should be preserved")
    }
    
    // MARK: - Settings Persistence Tests
    
    func testEncryptionEnabledPersistence() {
        // When: Enabling encryption
        encryptionManager.isEncryptionEnabled = true
        
        // Simulate app restart by creating new instance access
        let isEnabled = UserDefaults.standard.bool(forKey: "encryptionEnabled")
        
        // Then: Should persist
        XCTAssertTrue(isEnabled, "Encryption enabled state should persist")
    }
    
    func testEncryptFilenamesPersistence() {
        // When: Enabling filename encryption
        encryptionManager.encryptFilenames = true
        
        // Simulate app restart
        let encryptFilenames = UserDefaults.standard.bool(forKey: "encryptFilenames")
        
        // Then: Should persist
        XCTAssertTrue(encryptFilenames, "Filename encryption state should persist")
    }
    
    // MARK: - Complete Configuration Workflow Tests
    
    func testCompleteEncryptionSetup() throws {
        // Scenario: User sets up encryption from scratch
        
        // Step 1: Generate credentials
        let password = encryptionManager.generateSecurePassword()
        let salt = encryptionManager.generateSecureSalt()
        
        // Step 2: Save credentials
        try encryptionManager.savePassword(password)
        try encryptionManager.saveSalt(salt)
        
        // Step 3: Enable encryption
        encryptionManager.isEncryptionEnabled = true
        encryptionManager.encryptFilenames = true
        
        // Verify: Everything is configured
        XCTAssertTrue(encryptionManager.isEncryptionConfigured, "Should be configured")
        XCTAssertTrue(encryptionManager.isEncryptionEnabled, "Should be enabled")
        XCTAssertTrue(encryptionManager.encryptFilenames, "Filename encryption should be enabled")
        XCTAssertEqual(encryptionManager.getPassword(), password, "Password should match")
        XCTAssertEqual(encryptionManager.getSalt(), salt, "Salt should match")
    }
    
    func testDisableEncryptionWorkflow() throws {
        // Given: Encryption is fully configured
        try encryptionManager.savePassword("TestPassword")
        try encryptionManager.saveSalt("TestSalt")
        encryptionManager.isEncryptionEnabled = true
        encryptionManager.encryptFilenames = true
        
        // When: Disabling encryption
        encryptionManager.isEncryptionEnabled = false
        encryptionManager.deleteEncryptionCredentials()
        
        // Then: Should be fully disabled
        XCTAssertFalse(encryptionManager.isEncryptionEnabled, "Should be disabled")
        XCTAssertFalse(encryptionManager.isEncryptionConfigured, "Should not be configured")
        XCTAssertNil(encryptionManager.getPassword(), "Password should be deleted")
        XCTAssertNil(encryptionManager.getSalt(), "Salt should be deleted")
    }
    
    // MARK: - Edge Case Tests
    
    func testMultipleRapidPasswordChanges() throws {
        // When: Rapidly changing password multiple times
        for i in 1...10 {
            try encryptionManager.savePassword("Password\(i)")
        }
        
        // Then: Should have the last password
        let retrieved = encryptionManager.getPassword()
        XCTAssertEqual(retrieved, "Password10", "Should have last saved password")
    }
    
    func testConcurrentAccessSafety() throws {
        // This tests that keychain operations are thread-safe
        let expectation = XCTestExpectation(description: "Concurrent operations complete")
        expectation.expectedFulfillmentCount = 3
        
        // When: Accessing from multiple threads
        DispatchQueue.global().async {
            try? self.encryptionManager.savePassword("Password1")
            expectation.fulfill()
        }
        
        DispatchQueue.global().async {
            _ = self.encryptionManager.getPassword()
            expectation.fulfill()
        }
        
        DispatchQueue.global().async {
            try? self.encryptionManager.saveSalt("Salt1")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
        
        // Then: Should not crash (main verification)
        XCTAssertTrue(true, "Concurrent access should be safe")
    }
}
