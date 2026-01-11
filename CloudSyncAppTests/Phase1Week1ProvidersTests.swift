//
//  Phase1Week1ProvidersTests.swift
//  CloudSyncAppTests
//
//  Tests for Phase 1, Week 1 cloud providers:
//  Nextcloud, ownCloud, Seafile, Koofr, Yandex Disk, Mail.ru Cloud
//

import XCTest
@testable import CloudSyncApp

final class Phase1Week1ProvidersTests: XCTestCase {
    
    // MARK: - CloudProvider Model Tests
    
    func testNextcloudProviderProperties() {
        // Given: Nextcloud provider
        let provider = CloudProviderType.nextcloud
        
        // Then: Properties should be correct
        XCTAssertEqual(provider.displayName, "Nextcloud")
        XCTAssertEqual(provider.rcloneType, "webdav")
        XCTAssertEqual(provider.defaultRcloneName, "nextcloud")
        XCTAssertEqual(provider.iconName, "cloud.circle")
        XCTAssertNotNil(provider.brandColor)
    }
    
    func testOwnCloudProviderProperties() {
        // Given: ownCloud provider
        let provider = CloudProviderType.owncloud
        
        // Then: Properties should be correct
        XCTAssertEqual(provider.displayName, "ownCloud")
        XCTAssertEqual(provider.rcloneType, "webdav")
        XCTAssertEqual(provider.defaultRcloneName, "owncloud")
        XCTAssertEqual(provider.iconName, "cloud.circle.fill")
        XCTAssertNotNil(provider.brandColor)
    }
    
    func testSeafileProviderProperties() {
        // Given: Seafile provider
        let provider = CloudProviderType.seafile
        
        // Then: Properties should be correct
        XCTAssertEqual(provider.displayName, "Seafile")
        XCTAssertEqual(provider.rcloneType, "seafile")
        XCTAssertEqual(provider.defaultRcloneName, "seafile")
        XCTAssertEqual(provider.iconName, "server.rack")
        XCTAssertNotNil(provider.brandColor)
    }
    
    func testKoofrProviderProperties() {
        // Given: Koofr provider
        let provider = CloudProviderType.koofr
        
        // Then: Properties should be correct
        XCTAssertEqual(provider.displayName, "Koofr")
        XCTAssertEqual(provider.rcloneType, "koofr")
        XCTAssertEqual(provider.defaultRcloneName, "koofr")
        XCTAssertEqual(provider.iconName, "arrow.triangle.2.circlepath.circle")
        XCTAssertNotNil(provider.brandColor)
    }
    
    func testYandexDiskProviderProperties() {
        // Given: Yandex Disk provider
        let provider = CloudProviderType.yandexDisk
        
        // Then: Properties should be correct
        XCTAssertEqual(provider.displayName, "Yandex Disk")
        XCTAssertEqual(provider.rcloneType, "yandex")
        XCTAssertEqual(provider.defaultRcloneName, "yandex")
        XCTAssertEqual(provider.iconName, "y.circle.fill")
        XCTAssertNotNil(provider.brandColor)
    }
    
    func testMailRuCloudProviderProperties() {
        // Given: Mail.ru Cloud provider
        let provider = CloudProviderType.mailRuCloud
        
        // Then: Properties should be correct
        XCTAssertEqual(provider.displayName, "Mail.ru Cloud")
        XCTAssertEqual(provider.rcloneType, "mailru")
        XCTAssertEqual(provider.defaultRcloneName, "mailru")
        XCTAssertEqual(provider.iconName, "envelope.circle.fill")
        XCTAssertNotNil(provider.brandColor)
    }
    
    // MARK: - Provider Count Tests
    
    func testProviderCountIncreased() {
        // When: Getting all providers
        let allProviders = CloudProviderType.allCases
        
        // Then: Should have 19 providers (13 original + 6 new)
        XCTAssertEqual(allProviders.count, 19, "Should have 19 providers after Phase 1, Week 1")
    }
    
    func testNewProvidersInAllCases() {
        // When: Getting all providers
        let allProviders = CloudProviderType.allCases
        
        // Then: New providers should be included
        XCTAssertTrue(allProviders.contains(.nextcloud))
        XCTAssertTrue(allProviders.contains(.owncloud))
        XCTAssertTrue(allProviders.contains(.seafile))
        XCTAssertTrue(allProviders.contains(.koofr))
        XCTAssertTrue(allProviders.contains(.yandexDisk))
        XCTAssertTrue(allProviders.contains(.mailRuCloud))
    }
    
    // MARK: - Brand Color Tests
    
    func testNextcloudBrandColor() {
        // Given: Nextcloud provider
        let provider = CloudProviderType.nextcloud
        
        // When: Getting brand color
        let color = provider.brandColor
        
        // Then: Should be Nextcloud blue
        XCTAssertNotNil(color)
        // Nextcloud blue: RGB(0, 130, 201) = (0.0, 0.51, 0.79)
    }
    
    func testOwnCloudBrandColor() {
        // Given: ownCloud provider
        let provider = CloudProviderType.owncloud
        
        // When: Getting brand color
        let color = provider.brandColor
        
        // Then: Should be ownCloud dark blue
        XCTAssertNotNil(color)
        // ownCloud dark blue: RGB(10, 67, 125) = (0.04, 0.26, 0.49)
    }
    
    func testSeafileBrandColor() {
        // Given: Seafile provider
        let provider = CloudProviderType.seafile
        
        // When: Getting brand color
        let color = provider.brandColor
        
        // Then: Should be Seafile green
        XCTAssertNotNil(color)
        // Seafile green: RGB(0, 158, 107) = (0.0, 0.62, 0.42)
    }
    
    func testYandexDiskBrandColor() {
        // Given: Yandex Disk provider
        let provider = CloudProviderType.yandexDisk
        
        // When: Getting brand color
        let color = provider.brandColor
        
        // Then: Should be Yandex red
        XCTAssertNotNil(color)
        // Yandex red: RGB(255, 51, 0) = (1.0, 0.2, 0.0)
    }
    
    // MARK: - Codable Tests
    
    func testNewProvidersAreCodable() throws {
        // Given: Array of new providers
        let providers: [CloudProviderType] = [
            .nextcloud, .owncloud, .seafile,
            .koofr, .yandexDisk, .mailRuCloud
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
            CloudRemote(name: "My Nextcloud", type: .nextcloud),
            CloudRemote(name: "Company ownCloud", type: .owncloud),
            CloudRemote(name: "Seafile Server", type: .seafile),
            CloudRemote(name: "Koofr Storage", type: .koofr),
            CloudRemote(name: "Yandex Drive", type: .yandexDisk),
            CloudRemote(name: "Mail.ru", type: .mailRuCloud)
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
    
    func testNextcloudRawValue() {
        XCTAssertEqual(CloudProviderType.nextcloud.rawValue, "nextcloud")
    }
    
    func testOwnCloudRawValue() {
        XCTAssertEqual(CloudProviderType.owncloud.rawValue, "owncloud")
    }
    
    func testSeafileRawValue() {
        XCTAssertEqual(CloudProviderType.seafile.rawValue, "seafile")
    }
    
    func testKoofrRawValue() {
        XCTAssertEqual(CloudProviderType.koofr.rawValue, "koofr")
    }
    
    func testYandexDiskRawValue() {
        XCTAssertEqual(CloudProviderType.yandexDisk.rawValue, "yandex")
    }
    
    func testMailRuCloudRawValue() {
        XCTAssertEqual(CloudProviderType.mailRuCloud.rawValue, "mailru")
    }
    
    // MARK: - Icon Tests
    
    func testAllNewProvidersHaveIcons() {
        // Given: All new providers
        let newProviders: [CloudProviderType] = [
            .nextcloud, .owncloud, .seafile,
            .koofr, .yandexDisk, .mailRuCloud
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
            "cloud.circle",           // nextcloud
            "cloud.circle.fill",      // owncloud
            "server.rack",            // seafile
            "arrow.triangle.2.circlepath.circle", // koofr
            "y.circle.fill",          // yandex
            "envelope.circle.fill"    // mailru
        ]
        
        let newProviders: [CloudProviderType] = [
            .nextcloud, .owncloud, .seafile,
            .koofr, .yandexDisk, .mailRuCloud
        ]
        
        for (index, provider) in newProviders.enumerated() {
            XCTAssertEqual(provider.iconName, validIconNames[index])
        }
    }
    
    // MARK: - Display Name Tests
    
    func testDisplayNamesAreUserFriendly() {
        // Given: New providers
        let providers: [(CloudProviderType, String)] = [
            (.nextcloud, "Nextcloud"),
            (.owncloud, "ownCloud"),
            (.seafile, "Seafile"),
            (.koofr, "Koofr"),
            (.yandexDisk, "Yandex Disk"),
            (.mailRuCloud, "Mail.ru Cloud")
        ]
        
        for (provider, expectedName) in providers {
            // Then: Display name should be user-friendly
            XCTAssertEqual(provider.displayName, expectedName)
            XCTAssertFalse(provider.displayName.isEmpty)
            XCTAssertNotEqual(provider.displayName, provider.rawValue)
        }
    }
    
    // MARK: - WebDAV Vendor Tests
    
    func testNextcloudUsesWebDAVType() {
        // Then: Nextcloud should use webdav rclone type
        XCTAssertEqual(CloudProviderType.nextcloud.rcloneType, "webdav")
    }
    
    func testOwnCloudUsesWebDAVType() {
        // Then: ownCloud should use webdav rclone type
        XCTAssertEqual(CloudProviderType.owncloud.rcloneType, "webdav")
    }
    
    func testSeafileUsesNativeType() {
        // Then: Seafile should use native seafile type
        XCTAssertEqual(CloudProviderType.seafile.rcloneType, "seafile")
    }
    
    // MARK: - Hashable & Equatable Tests
    
    func testProvidersAreHashable() {
        // Given: Set of providers
        let providerSet: Set<CloudProviderType> = [
            .nextcloud, .owncloud, .seafile,
            .koofr, .yandexDisk, .mailRuCloud
        ]
        
        // Then: Should have 6 unique items
        XCTAssertEqual(providerSet.count, 6)
    }
    
    func testProvidersAreEquatable() {
        // Given: Same providers
        let provider1 = CloudProviderType.nextcloud
        let provider2 = CloudProviderType.nextcloud
        
        // Then: Should be equal
        XCTAssertEqual(provider1, provider2)
        
        // And: Different providers should not be equal
        XCTAssertNotEqual(CloudProviderType.nextcloud, CloudProviderType.owncloud)
    }
    
    // MARK: - Identifiable Tests
    
    func testProvidersAreIdentifiable() {
        // Given: Providers
        let providers: [CloudProviderType] = [
            .nextcloud, .owncloud, .seafile,
            .koofr, .yandexDisk, .mailRuCloud
        ]
        
        for provider in providers {
            // Then: ID should match raw value
            XCTAssertEqual(provider.id, provider.rawValue)
        }
    }
    
    // MARK: - Integration Tests
    
    func testCloudRemoteWithNextcloud() {
        // Given: Nextcloud remote
        let remote = CloudRemote(
            name: "My Nextcloud",
            type: .nextcloud,
            customRcloneName: "my-nextcloud"
        )
        
        // Then: Properties should be correct
        XCTAssertEqual(remote.name, "My Nextcloud")
        XCTAssertEqual(remote.type, .nextcloud)
        XCTAssertEqual(remote.rcloneName, "my-nextcloud")
        XCTAssertEqual(remote.displayIcon, "cloud.circle")
    }
    
    func testCloudRemoteDefaultRcloneName() {
        // Given: Remote without custom name
        let remote = CloudRemote(name: "Koofr Storage", type: .koofr)
        
        // Then: Should use default rclone name
        XCTAssertEqual(remote.rcloneName, "koofr")
    }
    
    // MARK: - Edge Case Tests
    
    func testAllNewProvidersAreSupported() {
        // Given: New providers
        let newProviders: [CloudProviderType] = [
            .nextcloud, .owncloud, .seafile,
            .koofr, .yandexDisk, .mailRuCloud
        ]
        
        for provider in newProviders {
            // Then: All should be supported (isSupported defaults to true)
            XCTAssertTrue(provider.isSupported, "\(provider.displayName) should be supported")
        }
    }
    
    func testProvidersSortedAlphabetically() {
        // When: Getting all providers
        let allProviders = CloudProviderType.allCases
        let newProviders = allProviders.filter { provider in
            [.nextcloud, .owncloud, .seafile, .koofr, .yandexDisk, .mailRuCloud].contains(provider)
        }
        
        // Then: Should have all 6 new providers
        XCTAssertEqual(newProviders.count, 6)
    }
}
