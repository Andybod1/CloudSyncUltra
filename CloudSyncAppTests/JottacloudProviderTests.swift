//
//  JottacloudProviderTests.swift
//  CloudSyncAppTests
//
//  Tests for Jottacloud cloud storage provider
//  Norwegian unlimited storage provider
//

import XCTest
@testable import CloudSyncApp

final class JottacloudProviderTests: XCTestCase {
    
    // MARK: - Provider Properties Tests
    
    func testJottacloudProviderProperties() {
        // Given: Jottacloud provider
        let provider = CloudProviderType.jottacloud
        
        // Then: Properties should be correct
        XCTAssertEqual(provider.displayName, "Jottacloud")
        XCTAssertEqual(provider.rcloneType, "jottacloud")
        XCTAssertEqual(provider.defaultRcloneName, "jottacloud")
        XCTAssertEqual(provider.iconName, "j.circle.fill")
        XCTAssertNotNil(provider.brandColor)
    }
    
    func testJottacloudDisplayName() {
        // Given: Jottacloud provider
        let provider = CloudProviderType.jottacloud
        
        // Then: Display name should be user-friendly
        XCTAssertEqual(provider.displayName, "Jottacloud")
        XCTAssertFalse(provider.displayName.isEmpty)
        XCTAssertNotEqual(provider.displayName, provider.rawValue)
    }
    
    func testJottacloudRcloneType() {
        // Given: Jottacloud provider
        let provider = CloudProviderType.jottacloud
        
        // Then: Should use native jottacloud type
        XCTAssertEqual(provider.rcloneType, "jottacloud")
    }
    
    func testJottacloudDefaultRemoteName() {
        // Given: Jottacloud provider
        let provider = CloudProviderType.jottacloud
        
        // Then: Should have correct default name
        XCTAssertEqual(provider.defaultRcloneName, "jottacloud")
    }
    
    func testJottacloudIcon() {
        // Given: Jottacloud provider
        let provider = CloudProviderType.jottacloud
        
        // Then: Should have valid SF Symbol icon
        XCTAssertEqual(provider.iconName, "j.circle.fill")
        XCTAssertFalse(provider.iconName.isEmpty)
    }
    
    func testJottacloudBrandColor() {
        // Given: Jottacloud provider
        let provider = CloudProviderType.jottacloud
        
        // When: Getting brand color
        let color = provider.brandColor
        
        // Then: Should be Jottacloud blue
        XCTAssertNotNil(color)
        // Jottacloud blue: RGB(0, 148, 196) = (0.0, 0.58, 0.77)
    }
    
    // MARK: - Provider Count Tests
    
    func testProviderCountIncreased() {
        // When: Getting all providers
        let allProviders = CloudProviderType.allCases
        
        // Then: Should have 34 providers (33 + Jottacloud)
        XCTAssertEqual(allProviders.count, 34, "Should have 34 providers after adding Jottacloud")
    }
    
    func testJottacloudInAllCases() {
        // When: Getting all providers
        let allProviders = CloudProviderType.allCases
        
        // Then: Jottacloud should be included
        XCTAssertTrue(allProviders.contains(.jottacloud), "Jottacloud should be in allCases")
    }
    
    // MARK: - Codable Tests
    
    func testJottacloudIsCodable() throws {
        // Given: Jottacloud provider
        let provider = CloudProviderType.jottacloud
        
        // When: Encoding and decoding
        let encoded = try JSONEncoder().encode(provider)
        let decoded = try JSONDecoder().decode(CloudProviderType.self, from: encoded)
        
        // Then: Should match original
        XCTAssertEqual(decoded, provider, "Jottacloud should be codable")
    }
    
    func testCloudRemoteWithJottacloud() throws {
        // Given: CloudRemote with Jottacloud
        let remote = CloudRemote(name: "My Jottacloud", type: .jottacloud)
        
        // When: Encoding and decoding
        let encoded = try JSONEncoder().encode(remote)
        let decoded = try JSONDecoder().decode(CloudRemote.self, from: encoded)
        
        // Then: Should match original
        XCTAssertEqual(decoded.type, .jottacloud)
        XCTAssertEqual(decoded.name, "My Jottacloud")
    }
    
    // MARK: - Raw Value Tests
    
    func testJottacloudRawValue() {
        // Given: Jottacloud provider
        let provider = CloudProviderType.jottacloud
        
        // Then: Raw value should be "jottacloud"
        XCTAssertEqual(provider.rawValue, "jottacloud")
    }
    
    // MARK: - Protocol Conformance Tests
    
    func testJottacloudIsHashable() {
        // Given: Set with Jottacloud
        let providerSet: Set<CloudProviderType> = [.jottacloud]
        
        // Then: Should be in set
        XCTAssertTrue(providerSet.contains(.jottacloud))
        XCTAssertEqual(providerSet.count, 1)
    }
    
    func testJottacloudIsEquatable() {
        // Given: Two Jottacloud providers
        let provider1 = CloudProviderType.jottacloud
        let provider2 = CloudProviderType.jottacloud
        
        // Then: Should be equal
        XCTAssertEqual(provider1, provider2)
        
        // And: Different from other providers
        XCTAssertNotEqual(CloudProviderType.jottacloud, CloudProviderType.googleDrive)
    }
    
    func testJottacloudIsIdentifiable() {
        // Given: Jottacloud provider
        let provider = CloudProviderType.jottacloud
        
        // Then: ID should match raw value
        XCTAssertEqual(provider.id, provider.rawValue)
        XCTAssertEqual(provider.id, "jottacloud")
    }
    
    // MARK: - Integration Tests
    
    func testCloudRemoteCreation() {
        // Given: Create CloudRemote with Jottacloud
        let remote = CloudRemote(
            name: "Unlimited Backup",
            type: .jottacloud,
            customRcloneName: "my-jottacloud"
        )
        
        // Then: Properties should be correct
        XCTAssertEqual(remote.name, "Unlimited Backup")
        XCTAssertEqual(remote.type, .jottacloud)
        XCTAssertEqual(remote.rcloneName, "my-jottacloud")
        XCTAssertEqual(remote.displayIcon, "j.circle.fill")
    }
    
    func testDefaultRcloneName() {
        // Given: CloudRemote without custom name
        let remote = CloudRemote(name: "Jottacloud Storage", type: .jottacloud)
        
        // Then: Should use default rclone name
        XCTAssertEqual(remote.rcloneName, "jottacloud")
    }
    
    // MARK: - European Provider Tests
    
    func testJottacloudIsEuropeanProvider() {
        // Given: Jottacloud provider
        let provider = CloudProviderType.jottacloud
        
        // Then: Should be supported (all European providers are supported)
        XCTAssertTrue(provider.isSupported, "Jottacloud should be supported")
    }
    
    func testJottacloudGDPRCompliant() {
        // Jottacloud is GDPR compliant by default (Norwegian provider)
        // This is a documentation test - the provider exists and is supported
        let provider = CloudProviderType.jottacloud
        XCTAssertTrue(provider.isSupported)
        XCTAssertEqual(provider.displayName, "Jottacloud")
    }
    
    // MARK: - Nordic Market Tests
    
    func testJottacloudNordicRelevance() {
        // Jottacloud is relevant for Nordic users (Norway, Sweden, Denmark, Finland)
        // User is in Finland, making this provider highly relevant
        let provider = CloudProviderType.jottacloud
        
        XCTAssertTrue(provider.isSupported, "Jottacloud should be supported for Nordic users")
        XCTAssertEqual(provider.displayName, "Jottacloud")
        XCTAssertEqual(provider.rcloneType, "jottacloud")
    }
    
    // MARK: - Unique Features Tests
    
    func testJottacloudUnlimitedStorageProvider() {
        // Jottacloud offers unlimited storage plans
        // This test verifies the provider is properly configured
        let provider = CloudProviderType.jottacloud
        
        XCTAssertEqual(provider.displayName, "Jottacloud")
        XCTAssertTrue(provider.isSupported)
        // Provider is ready for unlimited storage use cases
    }
    
    // MARK: - Comprehensive Validation Tests
    
    func testJottacloudHasAllRequiredProperties() {
        // Given: Jottacloud provider
        let provider = CloudProviderType.jottacloud
        
        // Then: All properties should be non-empty and valid
        XCTAssertFalse(provider.displayName.isEmpty, "Should have display name")
        XCTAssertFalse(provider.iconName.isEmpty, "Should have icon")
        XCTAssertFalse(provider.rcloneType.isEmpty, "Should have rclone type")
        XCTAssertFalse(provider.defaultRcloneName.isEmpty, "Should have default name")
        XCTAssertNotNil(provider.brandColor, "Should have brand color")
    }
    
    func testJottacloudUniqueAmongProviders() {
        // When: Getting all providers
        let allProviders = CloudProviderType.allCases
        
        // Then: Jottacloud should be unique
        let jottacloudProviders = allProviders.filter { $0 == .jottacloud }
        XCTAssertEqual(jottacloudProviders.count, 1, "Should have exactly one Jottacloud provider")
    }
    
    func testAllProvidersStillHaveUniqueRawValues() {
        // When: Getting all providers
        let allProviders = CloudProviderType.allCases
        let rawValues = allProviders.map { $0.rawValue }
        let uniqueRawValues = Set(rawValues)
        
        // Then: All raw values should still be unique (including Jottacloud)
        XCTAssertEqual(rawValues.count, uniqueRawValues.count, "All providers should have unique raw values")
    }
    
    func testAllProvidersStillHaveUniqueDisplayNames() {
        // When: Getting all providers
        let allProviders = CloudProviderType.allCases
        let displayNames = allProviders.map { $0.displayName }
        let uniqueDisplayNames = Set(displayNames)
        
        // Then: All display names should still be unique (including Jottacloud)
        XCTAssertEqual(displayNames.count, uniqueDisplayNames.count, "All providers should have unique display names")
    }
}
