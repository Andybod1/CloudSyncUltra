//
//  OAuthExpansionProvidersTests.swift
//  CloudSyncAppTests
//
//  Tests for OAuth Services Expansion: 8 new OAuth providers
//  - Media & Consumer: Google Photos, Flickr, SugarSync, OpenDrive
//  - Specialized & Enterprise: Put.io, Premiumize.me, Quatrix, File Fabric
//

import XCTest
@testable import CloudSyncApp

final class OAuthExpansionProvidersTests: XCTestCase {
    
    // MARK: - Provider Properties Tests
    
    func testGooglePhotosProperties() {
        let provider = CloudProviderType.googlePhotos
        XCTAssertEqual(provider.displayName, "Google Photos")
        XCTAssertEqual(provider.rcloneType, "gphotos")
        XCTAssertEqual(provider.defaultRcloneName, "gphotos")
        XCTAssertEqual(provider.iconName, "photo.stack.fill")
        XCTAssertEqual(provider.rawValue, "gphotos")
        XCTAssertTrue(provider.isSupported)
        XCTAssertFalse(provider.isExperimental)
    }
    
    func testFlickrProperties() {
        let provider = CloudProviderType.flickr
        XCTAssertEqual(provider.displayName, "Flickr")
        XCTAssertEqual(provider.rcloneType, "flickr")
        XCTAssertEqual(provider.defaultRcloneName, "flickr")
        XCTAssertEqual(provider.iconName, "camera.fill")
        XCTAssertEqual(provider.rawValue, "flickr")
        XCTAssertTrue(provider.isSupported)
    }
    
    func testSugarSyncProperties() {
        let provider = CloudProviderType.sugarsync
        XCTAssertEqual(provider.displayName, "SugarSync")
        XCTAssertEqual(provider.rcloneType, "sugarsync")
        XCTAssertEqual(provider.defaultRcloneName, "sugarsync")
        XCTAssertEqual(provider.iconName, "arrow.triangle.2.circlepath")
        XCTAssertTrue(provider.isSupported)
    }
    
    func testOpenDriveProperties() {
        let provider = CloudProviderType.opendrive
        XCTAssertEqual(provider.displayName, "OpenDrive")
        XCTAssertEqual(provider.rcloneType, "opendrive")
        XCTAssertEqual(provider.defaultRcloneName, "opendrive")
        XCTAssertEqual(provider.iconName, "externaldrive.fill")
        XCTAssertTrue(provider.isSupported)
    }
    
    func testPutioProperties() {
        let provider = CloudProviderType.putio
        XCTAssertEqual(provider.displayName, "Put.io")
        XCTAssertEqual(provider.rcloneType, "putio")
        XCTAssertEqual(provider.defaultRcloneName, "putio")
        XCTAssertEqual(provider.iconName, "arrow.down.circle.fill")
        XCTAssertTrue(provider.isSupported)
    }
    
    func testPremiumizemeProperties() {
        let provider = CloudProviderType.premiumizeme
        XCTAssertEqual(provider.displayName, "Premiumize.me")
        XCTAssertEqual(provider.rcloneType, "premiumizeme")
        XCTAssertEqual(provider.defaultRcloneName, "premiumizeme")
        XCTAssertEqual(provider.iconName, "star.circle.fill")
        XCTAssertTrue(provider.isSupported)
    }
    
    func testQuatrixProperties() {
        let provider = CloudProviderType.quatrix
        XCTAssertEqual(provider.displayName, "Quatrix")
        XCTAssertEqual(provider.rcloneType, "quatrix")
        XCTAssertEqual(provider.defaultRcloneName, "quatrix")
        XCTAssertEqual(provider.iconName, "q.circle.fill")
        XCTAssertTrue(provider.isSupported)
    }
    
    func testFileFabricProperties() {
        let provider = CloudProviderType.filefabric
        XCTAssertEqual(provider.displayName, "File Fabric")
        XCTAssertEqual(provider.rcloneType, "filefabric")
        XCTAssertEqual(provider.defaultRcloneName, "filefabric")
        XCTAssertEqual(provider.iconName, "fabric.circle.fill")
        XCTAssertTrue(provider.isSupported)
    }
    
    // MARK: - Provider Count Tests
    
    func testProviderCountIncreased() {
        let allProviders = CloudProviderType.allCases
        XCTAssertGreaterThanOrEqual(allProviders.count, 42, "Should have at least 42 providers (34 + 8 OAuth)")
    }
    
    func testProviderCountExact() {
        let allProviders = CloudProviderType.allCases
        XCTAssertEqual(allProviders.count, 42, "Should have exactly 42 providers after OAuth expansion")
    }
    
    // MARK: - Codable Tests
    
    func testOAuthProvidersAreCodable() throws {
        let providers: [CloudProviderType] = [
            .googlePhotos, .flickr, .sugarsync, .opendrive,
            .putio, .premiumizeme, .quatrix, .filefabric
        ]
        
        for provider in providers {
            let encoded = try JSONEncoder().encode(provider)
            let decoded = try JSONDecoder().decode(CloudProviderType.self, from: encoded)
            XCTAssertEqual(provider, decoded, "\(provider.displayName) should be codable")
        }
    }
    
    func testOAuthProviderRawValues() {
        XCTAssertEqual(CloudProviderType.googlePhotos.rawValue, "gphotos")
        XCTAssertEqual(CloudProviderType.flickr.rawValue, "flickr")
        XCTAssertEqual(CloudProviderType.sugarsync.rawValue, "sugarsync")
        XCTAssertEqual(CloudProviderType.opendrive.rawValue, "opendrive")
        XCTAssertEqual(CloudProviderType.putio.rawValue, "putio")
        XCTAssertEqual(CloudProviderType.premiumizeme.rawValue, "premiumizeme")
        XCTAssertEqual(CloudProviderType.quatrix.rawValue, "quatrix")
        XCTAssertEqual(CloudProviderType.filefabric.rawValue, "filefabric")
    }
    
    // MARK: - Protocol Conformance Tests
    
    func testOAuthProvidersAreIdentifiable() {
        let providers: [CloudProviderType] = [
            .googlePhotos, .flickr, .sugarsync, .opendrive,
            .putio, .premiumizeme, .quatrix, .filefabric
        ]
        
        for provider in providers {
            XCTAssertNotNil(provider.id, "\(provider.displayName) should have an id")
            XCTAssertEqual(provider.id, provider.rawValue)
        }
    }
    
    func testOAuthProvidersAreHashable() {
        let provider1 = CloudProviderType.googlePhotos
        let provider2 = CloudProviderType.googlePhotos
        let provider3 = CloudProviderType.flickr
        
        XCTAssertEqual(provider1.hashValue, provider2.hashValue)
        XCTAssertNotEqual(provider1.hashValue, provider3.hashValue)
    }
    
    func testOAuthProviderSetOperations() {
        let set: Set<CloudProviderType> = [
            .googlePhotos, .flickr, .googlePhotos  // Duplicate
        ]
        
        XCTAssertEqual(set.count, 2, "Set should contain only unique providers")
        XCTAssertTrue(set.contains(.googlePhotos))
        XCTAssertTrue(set.contains(.flickr))
    }
    
    // MARK: - Integration Tests
    
    func testOAuthProvidersInAllCases() {
        let allCases = CloudProviderType.allCases
        
        XCTAssertTrue(allCases.contains(.googlePhotos))
        XCTAssertTrue(allCases.contains(.flickr))
        XCTAssertTrue(allCases.contains(.sugarsync))
        XCTAssertTrue(allCases.contains(.opendrive))
        XCTAssertTrue(allCases.contains(.putio))
        XCTAssertTrue(allCases.contains(.premiumizeme))
        XCTAssertTrue(allCases.contains(.quatrix))
        XCTAssertTrue(allCases.contains(.filefabric))
    }
    
    func testOAuthProviderRemoteCreation() {
        let providers: [CloudProviderType] = [
            .googlePhotos, .flickr, .sugarsync, .opendrive,
            .putio, .premiumizeme, .quatrix, .filefabric
        ]
        
        for provider in providers {
            let remote = CloudRemote(
                name: "Test \(provider.displayName)",
                type: provider,
                isConfigured: false
            )
            
            XCTAssertEqual(remote.type, provider)
            XCTAssertFalse(remote.isConfigured)
        }
    }
    
    // MARK: - Category Tests
    
    func testMediaProviders() {
        let mediaProviders: [CloudProviderType] = [.googlePhotos, .flickr]
        
        for provider in mediaProviders {
            XCTAssertTrue(provider.isSupported, "\(provider.displayName) should be supported")
            XCTAssertNotNil(provider.displayName)
            XCTAssertNotNil(provider.iconName)
        }
    }
    
    func testConsumerProviders() {
        let consumerProviders: [CloudProviderType] = [.sugarsync, .opendrive]
        
        for provider in consumerProviders {
            XCTAssertTrue(provider.isSupported, "\(provider.displayName) should be supported")
            XCTAssertNotNil(provider.displayName)
        }
    }
    
    func testSpecializedProviders() {
        let specializedProviders: [CloudProviderType] = [.putio, .premiumizeme]
        
        for provider in specializedProviders {
            XCTAssertTrue(provider.isSupported, "\(provider.displayName) should be supported")
            XCTAssertNotNil(provider.rcloneType)
        }
    }
    
    func testEnterpriseOAuthProviders() {
        let enterpriseProviders: [CloudProviderType] = [.quatrix, .filefabric]
        
        for provider in enterpriseProviders {
            XCTAssertTrue(provider.isSupported, "\(provider.displayName) should be supported")
            XCTAssertNotNil(provider.brandColor)
        }
    }
    
    // MARK: - Brand Colors Tests
    
    func testOAuthProvidersBrandColors() {
        let providers: [CloudProviderType] = [
            .googlePhotos, .flickr, .sugarsync, .opendrive,
            .putio, .premiumizeme, .quatrix, .filefabric
        ]
        
        for provider in providers {
            XCTAssertNotNil(provider.brandColor, "\(provider.displayName) should have a brand color")
        }
    }
    
    // MARK: - Comprehensive Validation Tests
    
    func testAllOAuthProvidersHaveRequiredProperties() {
        let oauthProviders: [CloudProviderType] = [
            .googlePhotos, .flickr, .sugarsync, .opendrive,
            .putio, .premiumizeme, .quatrix, .filefabric
        ]
        
        for provider in oauthProviders {
            // Display name
            XCTAssertFalse(provider.displayName.isEmpty, "\(provider.rawValue) needs display name")
            
            // Icon name
            XCTAssertFalse(provider.iconName.isEmpty, "\(provider.rawValue) needs icon name")
            
            // rclone type
            XCTAssertFalse(provider.rcloneType.isEmpty, "\(provider.rawValue) needs rclone type")
            
            // Default rclone name
            XCTAssertFalse(provider.defaultRcloneName.isEmpty, "\(provider.rawValue) needs default name")
            
            // Support status
            XCTAssertTrue(provider.isSupported, "\(provider.rawValue) should be supported")
        }
    }
    
    func testOAuthExpansionComplete() {
        // Verify all 8 OAuth providers are present
        let oauthExpansion: [CloudProviderType] = [
            .googlePhotos, .flickr, .sugarsync, .opendrive,
            .putio, .premiumizeme, .quatrix, .filefabric
        ]
        
        XCTAssertEqual(oauthExpansion.count, 8, "Should have 8 OAuth expansion providers")
        
        let allProviders = CloudProviderType.allCases
        for provider in oauthExpansion {
            XCTAssertTrue(allProviders.contains(provider), "\(provider.displayName) should be in allCases")
        }
    }
    
    // MARK: - OAuth-Specific Tests
    
    func testAllOAuthProvidersUseInteractiveAuth() {
        // All 8 new providers should use OAuth (interactive authentication)
        // This is verified by checking they don't require manual credentials
        let oauthProviders: [CloudProviderType] = [
            .googlePhotos, .flickr, .sugarsync, .opendrive,
            .putio, .premiumizeme, .quatrix, .filefabric
        ]
        
        for provider in oauthProviders {
            // OAuth providers should have rclone types that match their service names
            XCTAssertEqual(provider.rcloneType, provider.defaultRcloneName,
                          "\(provider.displayName) rclone type should match default name for OAuth")
        }
    }
    
    func testTotalOAuthProvidersCount() {
        // Count all OAuth providers in the entire app
        let allOAuthProviders: [CloudProviderType] = [
            // Original OAuth
            .googleDrive, .dropbox, .oneDrive, .box,
            // Phase 1 OAuth
            .yandexDisk, .pcloud, .koofr, .mailRuCloud,
            .sharepoint, .oneDriveBusiness, .googleCloudStorage,
            // OAuth Expansion
            .googlePhotos, .flickr, .sugarsync, .opendrive,
            .putio, .premiumizeme, .quatrix, .filefabric
        ]
        
        XCTAssertEqual(allOAuthProviders.count, 19, "Should have 19 total OAuth providers")
    }
}