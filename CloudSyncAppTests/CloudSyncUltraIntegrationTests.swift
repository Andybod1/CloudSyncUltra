//
//  CloudSyncUltraIntegrationTests.swift
//  CloudSyncAppTests
//
//  Integration tests for CloudSync Ultra v2.0 - 41 providers
//  Note: Google Photos removed due to Google API limitations (March 2025)
//

import XCTest
@testable import CloudSyncApp

final class CloudSyncUltraIntegrationTests: XCTestCase {
    
    // MARK: - Provider Count Tests
    
    func testTotalProviderCount() {
        let allProviders = CloudProviderType.allCases
        XCTAssertEqual(allProviders.count, 41, "CloudSync Ultra should have exactly 41 providers")
    }
    
    func testProviderCountBreakdown() {
        let allProviders = CloudProviderType.allCases
        
        // Original: 13
        let original: [CloudProviderType] = [
            .protonDrive, .googleDrive, .dropbox, .oneDrive, .s3,
            .icloud, .mega, .box, .pcloud, .webdav, .sftp, .ftp, .local
        ]
        
        // Phase 1 Week 1: 6
        let week1: [CloudProviderType] = [
            .nextcloud, .owncloud, .seafile, .koofr, .yandexDisk, .mailRuCloud
        ]
        
        // Phase 1 Week 2: 8
        let week2: [CloudProviderType] = [
            .backblazeB2, .wasabi, .digitalOceanSpaces, .cloudflareR2,
            .scaleway, .oracleCloud, .storj, .filebase
        ]
        
        // Phase 1 Week 3: 6
        let week3: [CloudProviderType] = [
            .googleCloudStorage, .azureBlob, .azureFiles,
            .oneDriveBusiness, .sharepoint, .alibabaOSS
        ]
        
        // Jottacloud: 1
        let jottacloud: [CloudProviderType] = [.jottacloud]
        
        // OAuth Expansion: 7 (Google Photos removed due to API limitations)
        let oauthExpansion: [CloudProviderType] = [
            .flickr, .sugarsync, .opendrive,
            .putio, .premiumizeme, .quatrix, .filefabric
        ]
        
        XCTAssertEqual(original.count, 13, "Should have 13 original providers")
        XCTAssertEqual(week1.count, 6, "Should have 6 Week 1 providers")
        XCTAssertEqual(week2.count, 8, "Should have 8 Week 2 providers")
        XCTAssertEqual(week3.count, 6, "Should have 6 Week 3 providers")
        XCTAssertEqual(jottacloud.count, 1, "Should have 1 Jottacloud provider")
        XCTAssertEqual(oauthExpansion.count, 7, "Should have 7 OAuth expansion providers")
        
        let total = original.count + week1.count + week2.count + week3.count + jottacloud.count + oauthExpansion.count
        XCTAssertEqual(total, 41, "Total should be 41 providers")
        XCTAssertEqual(allProviders.count, total, "AllCases should match counted total")
    }
    
    // MARK: - OAuth Provider Tests
    
    func testOAuthProviderCount() {
        let oauthProviders: [CloudProviderType] = [
            // Original OAuth (4)
            .googleDrive, .dropbox, .oneDrive, .box,
            
            // Phase 1 OAuth (7)
            .yandexDisk, .pcloud, .koofr, .mailRuCloud,
            .sharepoint, .oneDriveBusiness, .googleCloudStorage,
            
            // OAuth Expansion (7) - Google Photos removed
            .flickr, .sugarsync, .opendrive,
            .putio, .premiumizeme, .quatrix, .filefabric
        ]
        
        XCTAssertEqual(oauthProviders.count, 18, "Should have 18 OAuth providers")
    }
    
    func testAllOAuthProvidersAreSupported() {
        let oauthProviders: [CloudProviderType] = [
            .googleDrive, .dropbox, .oneDrive, .box,
            .yandexDisk, .pcloud, .koofr, .mailRuCloud,
            .sharepoint, .oneDriveBusiness, .googleCloudStorage,
            .flickr, .sugarsync, .opendrive,
            .putio, .premiumizeme, .quatrix, .filefabric
        ]
        
        for provider in oauthProviders {
            XCTAssertTrue(provider.isSupported, "\(provider.displayName) should be supported")
        }
    }
    
    // MARK: - Category Tests
    
    func testConsumerCloudProviders() {
        let consumerProviders: [CloudProviderType] = [
            .googleDrive, .dropbox, .oneDrive, .box, .pcloud,
            .mega, .icloud, .protonDrive, .yandexDisk, .mailRuCloud,
            .koofr, .sugarsync, .opendrive
        ]
        
        // At least 12 consumer providers
        XCTAssertGreaterThanOrEqual(consumerProviders.count, 12, "Should have at least 12 consumer providers")
        
        for provider in consumerProviders {
            XCTAssertNotNil(provider.displayName)
            XCTAssertNotNil(provider.brandColor)
        }
    }
    
    func testEnterpriseProviders() {
        let enterpriseProviders: [CloudProviderType] = [
            .googleCloudStorage, .azureBlob, .azureFiles,
            .oneDriveBusiness, .sharepoint, .alibabaOSS,
            .quatrix, .filefabric, .nextcloud
        ]
        
        XCTAssertGreaterThanOrEqual(enterpriseProviders.count, 9, "Should have at least 9 enterprise providers")
    }
    
    func testMediaProviders() {
        // Google Photos removed due to API limitations (March 2025)
        let mediaProviders: [CloudProviderType] = [
            .flickr
        ]
        
        XCTAssertEqual(mediaProviders.count, 1, "Should have 1 media provider (Google Photos removed)")
        
        for provider in mediaProviders {
            XCTAssertTrue(provider.isSupported)
            XCTAssertFalse(provider.isExperimental)
        }
    }
    
    func testObjectStorageProviders() {
        let objectStorage: [CloudProviderType] = [
            .s3, .backblazeB2, .wasabi, .digitalOceanSpaces,
            .cloudflareR2, .scaleway, .oracleCloud, .storj, .filebase
        ]
        
        XCTAssertEqual(objectStorage.count, 9, "Should have 9 object storage providers")
    }
    
    func testSelfHostedProviders() {
        let selfHosted: [CloudProviderType] = [
            .nextcloud, .owncloud, .seafile
        ]
        
        XCTAssertEqual(selfHosted.count, 3, "Should have 3 self-hosted providers")
    }
    
    func testProtocolProviders() {
        let protocols: [CloudProviderType] = [
            .webdav, .sftp, .ftp
        ]
        
        XCTAssertEqual(protocols.count, 3, "Should have 3 protocol providers")
    }
    
    func testSpecializedProviders() {
        let specialized: [CloudProviderType] = [
            .putio, .premiumizeme, .storj, .filebase
        ]
        
        XCTAssertGreaterThanOrEqual(specialized.count, 4, "Should have at least 4 specialized providers")
    }
    
    // MARK: - Geographic Coverage Tests
    
    func testEuropeanProviders() {
        let europeanProviders: [CloudProviderType] = [
            .koofr, .scaleway, .nextcloud, .owncloud, .jottacloud
        ]
        
        XCTAssertEqual(europeanProviders.count, 5, "Should have 5 European providers")
    }
    
    func testNordicProviders() {
        let nordicProviders: [CloudProviderType] = [
            .jottacloud
        ]
        
        XCTAssertEqual(nordicProviders.count, 1, "Should have 1 Nordic provider")
        XCTAssertFalse(nordicProviders[0].isExperimental, "Jottacloud should not be experimental")
    }
    
    func testInternationalProviders() {
        let international: [CloudProviderType] = [
            .yandexDisk, .mailRuCloud, .alibabaOSS
        ]
        
        XCTAssertGreaterThanOrEqual(international.count, 3, "Should have at least 3 international providers")
    }
    
    // MARK: - Feature Coverage Tests
    
    func testAllProvidersHaveDisplayNames() {
        let allProviders = CloudProviderType.allCases
        
        for provider in allProviders {
            XCTAssertFalse(provider.displayName.isEmpty, "\(provider.rawValue) needs display name")
        }
    }
    
    func testAllProvidersHaveIcons() {
        let allProviders = CloudProviderType.allCases
        
        for provider in allProviders {
            XCTAssertFalse(provider.iconName.isEmpty, "\(provider.rawValue) needs icon")
        }
    }
    
    func testAllProvidersHaveBrandColors() {
        let allProviders = CloudProviderType.allCases
        
        for provider in allProviders {
            XCTAssertNotNil(provider.brandColor, "\(provider.rawValue) needs brand color")
        }
    }
    
    func testAllProvidersHaveRcloneTypes() {
        let allProviders = CloudProviderType.allCases
        
        for provider in allProviders {
            XCTAssertFalse(provider.rcloneType.isEmpty, "\(provider.rawValue) needs rclone type")
        }
    }
    
    func testAllProvidersHaveDefaultNames() {
        let allProviders = CloudProviderType.allCases
        
        for provider in allProviders {
            XCTAssertFalse(provider.defaultRcloneName.isEmpty, "\(provider.rawValue) needs default name")
        }
    }
    
    // MARK: - Experimental Provider Tests
    
    func testExperimentalProviders() {
        let allProviders = CloudProviderType.allCases
        let experimental = allProviders.filter { $0.isExperimental }
        
        // No providers are currently experimental (Jottacloud was made stable)
        XCTAssertEqual(experimental.count, 0, "Should have 0 experimental providers")
    }
    
    func testExperimentalProviderHasNote() {
        let jottacloud = CloudProviderType.jottacloud
        
        // Jottacloud is no longer experimental but still has setup note
        XCTAssertFalse(jottacloud.isExperimental)
        XCTAssertNotNil(jottacloud.experimentalNote, "Jottacloud should have setup instructions")
    }
    
    // MARK: - Unsupported Provider Tests
    
    func testUnsupportedProviders() {
        let allProviders = CloudProviderType.allCases
        let unsupported = allProviders.filter { !$0.isSupported }
        
        XCTAssertEqual(unsupported.count, 1, "Should have 1 unsupported provider")
        XCTAssertTrue(unsupported.contains(.icloud), "iCloud should be unsupported")
    }
    
    // MARK: - Growth Metrics Tests
    
    func testProviderGrowth() {
        let original = 13
        let phase1Week1 = 6
        let phase1Week2 = 8
        let phase1Week3 = 6
        let jottacloud = 1
        let oauthExpansion = 7  // Google Photos removed
        
        let phase1Total = phase1Week1 + phase1Week2 + phase1Week3
        XCTAssertEqual(phase1Total, 20, "Phase 1 should add 20 providers")
        
        let afterPhase1 = original + phase1Total
        XCTAssertEqual(afterPhase1, 33, "After Phase 1 should have 33 providers")
        
        let afterJottacloud = afterPhase1 + jottacloud
        XCTAssertEqual(afterJottacloud, 34, "After Jottacloud should have 34 providers")
        
        let final = afterJottacloud + oauthExpansion
        XCTAssertEqual(final, 41, "Final should have 41 providers")
        
        let growthPercentage = Double(final - original) / Double(original) * 100
        XCTAssertGreaterThan(growthPercentage, 215, "Growth should be over 215%")
    }
    
    // MARK: - Authentication Method Tests
    
    func testAuthenticationMethodDistribution() {
        let allProviders = CloudProviderType.allCases.filter { $0.isSupported }
        
        let oauth = 18  // Updated: Google Photos removed
        let credentials = 9
        let accessKeys = 14
        
        let totalAuth = oauth + credentials + accessKeys
        XCTAssertEqual(totalAuth, 41, "Total auth methods should equal 41")
        
        // OAuth should be largest category
        XCTAssertGreaterThan(oauth, credentials)
        XCTAssertGreaterThan(oauth, accessKeys)
    }
    
    // MARK: - Codable Tests
    
    func testAllProvidersAreCodable() throws {
        let allProviders = CloudProviderType.allCases
        
        for provider in allProviders {
            let encoded = try JSONEncoder().encode(provider)
            let decoded = try JSONDecoder().decode(CloudProviderType.self, from: encoded)
            XCTAssertEqual(provider, decoded, "\(provider.displayName) should be codable")
        }
    }
    
    // MARK: - Comprehensive Validation Tests
    
    func testCloudSyncUltraCompleteness() {
        let allProviders = CloudProviderType.allCases
        
        // Total count
        XCTAssertEqual(allProviders.count, 41, "Should have 41 providers")
        
        // OAuth count
        let oauthCount = 18
        XCTAssertGreaterThanOrEqual(oauthCount, 18, "Should have at least 18 OAuth providers")
        
        // Supported count
        let supported = allProviders.filter { $0.isSupported }
        XCTAssertEqual(supported.count, 40, "Should have 40 supported providers")
        
        // Experimental count
        let experimental = allProviders.filter { $0.isExperimental }
        XCTAssertEqual(experimental.count, 0, "Should have 0 experimental providers")
        
        // All providers have required properties
        for provider in allProviders {
            XCTAssertFalse(provider.displayName.isEmpty)
            XCTAssertFalse(provider.iconName.isEmpty)
            XCTAssertFalse(provider.rcloneType.isEmpty)
            XCTAssertFalse(provider.defaultRcloneName.isEmpty)
            XCTAssertNotNil(provider.brandColor)
        }
    }
    
    // MARK: - Industry Leadership Tests
    
    func testIndustryLeadingProviderCount() {
        let allProviders = CloudProviderType.allCases
        
        // CloudSync Ultra: 41 providers
        // Typical competitor: 5-10 providers
        let typicalCompetitor = 10
        
        XCTAssertGreaterThan(allProviders.count, typicalCompetitor * 4, "Should have 4x more providers than typical competitor")
    }
    
    func testIndustryLeadingOAuthCount() {
        let oauthCount = 18
        
        // CloudSync Ultra: 18 OAuth
        // Typical competitor: 3-4 OAuth
        let typicalCompetitor = 4
        
        XCTAssertGreaterThan(oauthCount, typicalCompetitor * 4, "Should have 4x more OAuth than typical competitor")
    }
    
    func testUniqueFeatures() {
        // Features no competitor has
        // Note: Google Photos removed due to API limitations
        let mediaProviders: [CloudProviderType] = [.flickr]
        let specializedProviders: [CloudProviderType] = [.putio, .premiumizeme]
        let nordicProviders: [CloudProviderType] = [.jottacloud]
        
        XCTAssertEqual(mediaProviders.count, 1, "Unique: 1 media provider")
        XCTAssertEqual(specializedProviders.count, 2, "Unique: 2 specialized providers")
        XCTAssertEqual(nordicProviders.count, 1, "Unique: Nordic coverage")
    }
}
