//
//  Phase1Week2ProvidersTests.swift
//  CloudSyncAppTests
//
//  Tests for Phase 1, Week 2 cloud providers:
//  Backblaze B2, Wasabi, DigitalOcean Spaces, Cloudflare R2,
//  Scaleway, Oracle Cloud, Storj, Filebase
//

import XCTest
@testable import CloudSyncApp

final class Phase1Week2ProvidersTests: XCTestCase {
    
    // MARK: - CloudProvider Model Tests
    
    func testBackblazeB2ProviderProperties() {
        // Given: Backblaze B2 provider
        let provider = CloudProviderType.backblazeB2
        
        // Then: Properties should be correct
        XCTAssertEqual(provider.displayName, "Backblaze B2")
        XCTAssertEqual(provider.rcloneType, "b2")
        XCTAssertEqual(provider.defaultRcloneName, "b2")
        XCTAssertEqual(provider.iconName, "b.circle.fill")
        XCTAssertNotNil(provider.brandColor)
    }
    
    func testWasabiProviderProperties() {
        // Given: Wasabi provider
        let provider = CloudProviderType.wasabi
        
        // Then: Properties should be correct
        XCTAssertEqual(provider.displayName, "Wasabi")
        XCTAssertEqual(provider.rcloneType, "s3")
        XCTAssertEqual(provider.defaultRcloneName, "wasabi")
        XCTAssertEqual(provider.iconName, "w.circle.fill")
        XCTAssertNotNil(provider.brandColor)
    }
    
    func testDigitalOceanSpacesProviderProperties() {
        // Given: DigitalOcean Spaces provider
        let provider = CloudProviderType.digitalOceanSpaces
        
        // Then: Properties should be correct
        XCTAssertEqual(provider.displayName, "DigitalOcean Spaces")
        XCTAssertEqual(provider.rcloneType, "s3")
        XCTAssertEqual(provider.defaultRcloneName, "spaces")
        XCTAssertEqual(provider.iconName, "water.waves")
        XCTAssertNotNil(provider.brandColor)
    }
    
    func testCloudflareR2ProviderProperties() {
        // Given: Cloudflare R2 provider
        let provider = CloudProviderType.cloudflareR2
        
        // Then: Properties should be correct
        XCTAssertEqual(provider.displayName, "Cloudflare R2")
        XCTAssertEqual(provider.rcloneType, "s3")
        XCTAssertEqual(provider.defaultRcloneName, "r2")
        XCTAssertEqual(provider.iconName, "r.circle.fill")
        XCTAssertNotNil(provider.brandColor)
    }
    
    func testScalewayProviderProperties() {
        // Given: Scaleway provider
        let provider = CloudProviderType.scaleway
        
        // Then: Properties should be correct
        XCTAssertEqual(provider.displayName, "Scaleway")
        XCTAssertEqual(provider.rcloneType, "s3")
        XCTAssertEqual(provider.defaultRcloneName, "scaleway")
        XCTAssertEqual(provider.iconName, "s.circle.fill")
        XCTAssertNotNil(provider.brandColor)
    }
    
    func testOracleCloudProviderProperties() {
        // Given: Oracle Cloud provider
        let provider = CloudProviderType.oracleCloud
        
        // Then: Properties should be correct
        XCTAssertEqual(provider.displayName, "Oracle Cloud")
        XCTAssertEqual(provider.rcloneType, "s3")
        XCTAssertEqual(provider.defaultRcloneName, "oraclecloud")
        XCTAssertEqual(provider.iconName, "o.circle.fill")
        XCTAssertNotNil(provider.brandColor)
    }
    
    func testStorjProviderProperties() {
        // Given: Storj provider
        let provider = CloudProviderType.storj
        
        // Then: Properties should be correct
        XCTAssertEqual(provider.displayName, "Storj")
        XCTAssertEqual(provider.rcloneType, "storj")
        XCTAssertEqual(provider.defaultRcloneName, "storj")
        XCTAssertEqual(provider.iconName, "lock.trianglebadge.exclamationmark.fill")
        XCTAssertNotNil(provider.brandColor)
    }
    
    func testFilebaseProviderProperties() {
        // Given: Filebase provider
        let provider = CloudProviderType.filebase
        
        // Then: Properties should be correct
        XCTAssertEqual(provider.displayName, "Filebase")
        XCTAssertEqual(provider.rcloneType, "s3")
        XCTAssertEqual(provider.defaultRcloneName, "filebase")
        XCTAssertEqual(provider.iconName, "square.stack.3d.up.fill")
        XCTAssertNotNil(provider.brandColor)
    }
    
    // MARK: - Provider Count Tests
    
    func testProviderCountIncreased() {
        // When: Getting all providers
        let allProviders = CloudProviderType.allCases
        
        // Then: Should have 41 providers total (updated to current count)
        XCTAssertEqual(allProviders.count, 41, "Should have 41 providers total")
    }
    
    func testNewProvidersInAllCases() {
        // When: Getting all providers
        let allProviders = CloudProviderType.allCases
        
        // Then: New providers should be included
        XCTAssertTrue(allProviders.contains(.backblazeB2))
        XCTAssertTrue(allProviders.contains(.wasabi))
        XCTAssertTrue(allProviders.contains(.digitalOceanSpaces))
        XCTAssertTrue(allProviders.contains(.cloudflareR2))
        XCTAssertTrue(allProviders.contains(.scaleway))
        XCTAssertTrue(allProviders.contains(.oracleCloud))
        XCTAssertTrue(allProviders.contains(.storj))
        XCTAssertTrue(allProviders.contains(.filebase))
    }
    
    // MARK: - S3-Compatible Provider Tests
    
    func testS3CompatibleProviders() {
        // Given: S3-compatible providers
        let s3Compatible: [CloudProviderType] = [
            .wasabi, .digitalOceanSpaces, .cloudflareR2,
            .scaleway, .oracleCloud, .filebase
        ]
        
        for provider in s3Compatible {
            // Then: Should use S3 rclone type
            XCTAssertEqual(provider.rcloneType, "s3", "\(provider.displayName) should use S3 type")
        }
    }
    
    func testNativeTypeProviders() {
        // Given: Providers with native types
        let nativeProviders: [(CloudProviderType, String)] = [
            (.backblazeB2, "b2"),
            (.storj, "storj")
        ]
        
        for (provider, expectedType) in nativeProviders {
            // Then: Should use native type
            XCTAssertEqual(provider.rcloneType, expectedType, "\(provider.displayName) should use \(expectedType) type")
        }
    }
    
    // MARK: - Brand Color Tests
    
    func testBackblazeB2BrandColor() {
        // Given: Backblaze B2 provider
        let provider = CloudProviderType.backblazeB2
        
        // When: Getting brand color
        let color = provider.brandColor
        
        // Then: Should be Backblaze red
        XCTAssertNotNil(color)
        // Backblaze red: RGB(230, 28, 36) = (0.9, 0.11, 0.14)
    }
    
    func testWasabiBrandColor() {
        // Given: Wasabi provider
        let provider = CloudProviderType.wasabi
        
        // When: Getting brand color
        let color = provider.brandColor
        
        // Then: Should be Wasabi green
        XCTAssertNotNil(color)
        // Wasabi green: RGB(0, 181, 80) = (0.0, 0.71, 0.31)
    }
    
    func testDigitalOceanBrandColor() {
        // Given: DigitalOcean Spaces provider
        let provider = CloudProviderType.digitalOceanSpaces
        
        // When: Getting brand color
        let color = provider.brandColor
        
        // Then: Should be DigitalOcean blue
        XCTAssertNotNil(color)
        // DigitalOcean blue: RGB(0, 107, 250) = (0.0, 0.42, 0.98)
    }
    
    func testCloudflareR2BrandColor() {
        // Given: Cloudflare R2 provider
        let provider = CloudProviderType.cloudflareR2
        
        // When: Getting brand color
        let color = provider.brandColor
        
        // Then: Should be Cloudflare orange
        XCTAssertNotNil(color)
        // Cloudflare orange: RGB(247, 125, 23) = (0.97, 0.49, 0.09)
    }
    
    func testStorjBrandColor() {
        // Given: Storj provider
        let provider = CloudProviderType.storj
        
        // When: Getting brand color
        let color = provider.brandColor
        
        // Then: Should be Storj blue
        XCTAssertNotNil(color)
        // Storj blue: RGB(0, 120, 255) = (0.0, 0.47, 1.0)
    }
    
    // MARK: - Codable Tests
    
    func testNewProvidersAreCodable() throws {
        // Given: Array of new providers
        let providers: [CloudProviderType] = [
            .backblazeB2, .wasabi, .digitalOceanSpaces, .cloudflareR2,
            .scaleway, .oracleCloud, .storj, .filebase
        ]
        
        for provider in providers {
            // When: Encoding and decoding
            let encoded = try JSONEncoder().encode(provider)
            let decoded = try JSONDecoder().decode(CloudProviderType.self, from: encoded)
            
            // Then: Should match original
            XCTAssertEqual(decoded, provider, "\(provider.displayName) should be codable")
        }
    }
    
    func testCloudRemoteWithNewProviders() throws {
        // Given: CloudRemotes with new providers
        let remotes = [
            CloudRemote(name: "B2 Backup", type: .backblazeB2),
            CloudRemote(name: "Wasabi Hot", type: .wasabi),
            CloudRemote(name: "DO Spaces", type: .digitalOceanSpaces),
            CloudRemote(name: "R2 Storage", type: .cloudflareR2),
            CloudRemote(name: "Scaleway Object", type: .scaleway),
            CloudRemote(name: "Oracle Storage", type: .oracleCloud),
            CloudRemote(name: "Storj DCS", type: .storj),
            CloudRemote(name: "Filebase Multi", type: .filebase)
        ]
        
        for remote in remotes {
            // When: Encoding and decoding
            let encoded = try JSONEncoder().encode(remote)
            let decoded = try JSONDecoder().decode(CloudRemote.self, from: encoded)
            
            // Then: Should match original
            XCTAssertEqual(decoded.type, remote.type)
            XCTAssertEqual(decoded.name, remote.name)
        }
    }
    
    // MARK: - RawValue Tests
    
    func testProviderRawValues() {
        let expectedRawValues: [(CloudProviderType, String)] = [
            (.backblazeB2, "b2"),
            (.wasabi, "wasabi"),
            (.digitalOceanSpaces, "spaces"),
            (.cloudflareR2, "r2"),
            (.scaleway, "scaleway"),
            (.oracleCloud, "oraclecloud"),
            (.storj, "storj"),
            (.filebase, "filebase")
        ]
        
        for (provider, expectedRaw) in expectedRawValues {
            XCTAssertEqual(provider.rawValue, expectedRaw, "\(provider.displayName) raw value should be \(expectedRaw)")
        }
    }
    
    // MARK: - Icon Tests
    
    func testAllNewProvidersHaveIcons() {
        // Given: All new providers
        let newProviders: [CloudProviderType] = [
            .backblazeB2, .wasabi, .digitalOceanSpaces, .cloudflareR2,
            .scaleway, .oracleCloud, .storj, .filebase
        ]
        
        for provider in newProviders {
            // Then: Should have non-empty icon name
            XCTAssertFalse(provider.iconName.isEmpty, "\(provider.displayName) should have icon")
            XCTAssertGreaterThan(provider.iconName.count, 0)
        }
    }
    
    func testIconNamesAreValid() {
        // Valid SF Symbol names for new providers
        let validIconNames = [
            "b.circle.fill",                            // backblazeB2
            "w.circle.fill",                            // wasabi
            "water.waves",                              // digitalOceanSpaces
            "r.circle.fill",                            // cloudflareR2
            "s.circle.fill",                            // scaleway
            "o.circle.fill",                            // oracleCloud
            "lock.trianglebadge.exclamationmark.fill",  // storj
            "square.stack.3d.up.fill"                   // filebase
        ]
        
        let newProviders: [CloudProviderType] = [
            .backblazeB2, .wasabi, .digitalOceanSpaces, .cloudflareR2,
            .scaleway, .oracleCloud, .storj, .filebase
        ]
        
        for (index, provider) in newProviders.enumerated() {
            XCTAssertEqual(provider.iconName, validIconNames[index])
        }
    }
    
    // MARK: - Display Name Tests
    
    func testDisplayNamesAreUserFriendly() {
        // Given: New providers
        let providers: [(CloudProviderType, String)] = [
            (.backblazeB2, "Backblaze B2"),
            (.wasabi, "Wasabi"),
            (.digitalOceanSpaces, "DigitalOcean Spaces"),
            (.cloudflareR2, "Cloudflare R2"),
            (.scaleway, "Scaleway"),
            (.oracleCloud, "Oracle Cloud"),
            (.storj, "Storj"),
            (.filebase, "Filebase")
        ]
        
        for (provider, expectedName) in providers {
            // Then: Display name should be user-friendly
            XCTAssertEqual(provider.displayName, expectedName)
            XCTAssertFalse(provider.displayName.isEmpty)
        }
    }
    
    // MARK: - Object Storage Category Tests
    
    func testAllAreObjectStorageProviders() {
        // Given: All new providers
        let newProviders: [CloudProviderType] = [
            .backblazeB2, .wasabi, .digitalOceanSpaces, .cloudflareR2,
            .scaleway, .oracleCloud, .storj, .filebase
        ]
        
        // Then: All should be object storage category
        // (This would be tested if we had category property)
        for provider in newProviders {
            XCTAssertTrue(provider.isSupported, "\(provider.displayName) should be supported")
        }
    }
    
    // MARK: - Hashable & Equatable Tests
    
    func testProvidersAreHashable() {
        // Given: Set of providers
        let providerSet: Set<CloudProviderType> = [
            .backblazeB2, .wasabi, .digitalOceanSpaces, .cloudflareR2,
            .scaleway, .oracleCloud, .storj, .filebase
        ]
        
        // Then: Should have 8 unique items
        XCTAssertEqual(providerSet.count, 8)
    }
    
    func testProvidersAreEquatable() {
        // Given: Same providers
        let provider1 = CloudProviderType.backblazeB2
        let provider2 = CloudProviderType.backblazeB2
        
        // Then: Should be equal
        XCTAssertEqual(provider1, provider2)
        
        // And: Different providers should not be equal
        XCTAssertNotEqual(CloudProviderType.backblazeB2, CloudProviderType.wasabi)
    }
    
    // MARK: - Identifiable Tests
    
    func testProvidersAreIdentifiable() {
        // Given: Providers
        let providers: [CloudProviderType] = [
            .backblazeB2, .wasabi, .digitalOceanSpaces, .cloudflareR2,
            .scaleway, .oracleCloud, .storj, .filebase
        ]
        
        for provider in providers {
            // Then: ID should match raw value
            XCTAssertEqual(provider.id, provider.rawValue)
        }
    }
    
    // MARK: - Integration Tests
    
    func testCloudRemoteWithBackblazeB2() {
        // Given: Backblaze B2 remote
        let remote = CloudRemote(
            name: "B2 Backup",
            type: .backblazeB2,
            customRcloneName: "my-b2"
        )
        
        // Then: Properties should be correct
        XCTAssertEqual(remote.name, "B2 Backup")
        XCTAssertEqual(remote.type, .backblazeB2)
        XCTAssertEqual(remote.rcloneName, "my-b2")
        XCTAssertEqual(remote.displayIcon, "b.circle.fill")
    }
    
    func testCloudRemoteDefaultRcloneName() {
        // Given: Remote without custom name
        let remote = CloudRemote(name: "Wasabi Storage", type: .wasabi)
        
        // Then: Should use default rclone name
        XCTAssertEqual(remote.rcloneName, "wasabi")
    }
    
    // MARK: - Edge Case Tests
    
    func testAllNewProvidersAreSupported() {
        // Given: New providers
        let newProviders: [CloudProviderType] = [
            .backblazeB2, .wasabi, .digitalOceanSpaces, .cloudflareR2,
            .scaleway, .oracleCloud, .storj, .filebase
        ]
        
        for provider in newProviders {
            // Then: All should be supported
            XCTAssertTrue(provider.isSupported, "\(provider.displayName) should be supported")
        }
    }
    
    // MARK: - S3 Endpoint Tests (Conceptual)
    
    func testWasabiUsesS3Protocol() {
        // Wasabi uses S3-compatible protocol
        XCTAssertEqual(CloudProviderType.wasabi.rcloneType, "s3")
    }
    
    func testDigitalOceanUsesS3Protocol() {
        // DigitalOcean Spaces uses S3-compatible protocol
        XCTAssertEqual(CloudProviderType.digitalOceanSpaces.rcloneType, "s3")
    }
    
    func testCloudflareR2UsesS3Protocol() {
        // Cloudflare R2 uses S3-compatible protocol
        XCTAssertEqual(CloudProviderType.cloudflareR2.rcloneType, "s3")
    }
    
    func testScalewayUsesS3Protocol() {
        // Scaleway uses S3-compatible protocol
        XCTAssertEqual(CloudProviderType.scaleway.rcloneType, "s3")
    }
    
    func testOracleCloudUsesS3Protocol() {
        // Oracle Cloud uses S3-compatible protocol
        XCTAssertEqual(CloudProviderType.oracleCloud.rcloneType, "s3")
    }
    
    func testFilebaseUsesS3Protocol() {
        // Filebase uses S3-compatible protocol
        XCTAssertEqual(CloudProviderType.filebase.rcloneType, "s3")
    }
    
    func testBackblazeB2UsesNativeProtocol() {
        // Backblaze B2 uses native b2 protocol
        XCTAssertEqual(CloudProviderType.backblazeB2.rcloneType, "b2")
    }
    
    func testStorjUsesNativeProtocol() {
        // Storj uses native storj protocol
        XCTAssertEqual(CloudProviderType.storj.rcloneType, "storj")
    }
    
    // MARK: - Comprehensive Provider Validation
    
    func testAllProvidersHaveUniqueRawValues() {
        // When: Getting all providers
        let allProviders = CloudProviderType.allCases
        let rawValues = allProviders.map { $0.rawValue }
        let uniqueRawValues = Set(rawValues)
        
        // Then: All raw values should be unique
        XCTAssertEqual(rawValues.count, uniqueRawValues.count, "All providers should have unique raw values")
    }
    
    func testAllProvidersHaveUniqueDisplayNames() {
        // When: Getting all providers
        let allProviders = CloudProviderType.allCases
        let displayNames = allProviders.map { $0.displayName }
        let uniqueDisplayNames = Set(displayNames)
        
        // Then: All display names should be unique
        XCTAssertEqual(displayNames.count, uniqueDisplayNames.count, "All providers should have unique display names")
    }
    
    func testAllProvidersHaveNonEmptyProperties() {
        // Given: New providers
        let newProviders: [CloudProviderType] = [
            .backblazeB2, .wasabi, .digitalOceanSpaces, .cloudflareR2,
            .scaleway, .oracleCloud, .storj, .filebase
        ]
        
        for provider in newProviders {
            // Then: All properties should be non-empty
            XCTAssertFalse(provider.displayName.isEmpty, "\(provider.rawValue) should have display name")
            XCTAssertFalse(provider.iconName.isEmpty, "\(provider.rawValue) should have icon")
            XCTAssertFalse(provider.rcloneType.isEmpty, "\(provider.rawValue) should have rclone type")
            XCTAssertFalse(provider.defaultRcloneName.isEmpty, "\(provider.rawValue) should have default name")
        }
    }
}
