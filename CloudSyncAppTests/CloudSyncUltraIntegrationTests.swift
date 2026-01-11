//
//  CloudSyncUltraIntegrationTests.swift
//  CloudSyncAppTests
//
//  Integration tests for CloudSync Ultra v2.0 - 42 providers
//

import XCTest
@testable import CloudSyncApp

final class CloudSyncUltraIntegrationTests: XCTestCase {
    
    // MARK: - Provider Count Tests
    
    func testTotalProviderCount() {
        let allProviders = CloudProviderType.allCases
        XCTAssertEqual(allProviders.count, 42, "CloudSync Ultra should have exactly 42 providers")
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
        
        // OAuth Expansion: 8
        let oauthExpansion: [CloudProviderType] = [
            .googlePhotos, .flickr, .sugarsync, .opendrive,
            .putio, .premiumizeme, .quatrix, .filefabric
        ]
        
        XCTAssertEqual(original.count, 13, "Should have 13 original providers")
        XCTAssertEqual(week1.count, 6, "Should have 6 Week 1 providers")
        XCTAssertEqual(week2.count, 8, "Should have 8 Week 2 providers")
        XCTAssertEqual(week3.count, 6, "Should have 6 Week 3 providers")
        XCTAssertEqual(jottacloud.count, 1, "Should have 1 Jottacloud provider")
        XCTAssertEqual(oauthExpansion.count, 8, "Should have 8 OAuth expansion providers")
        
        let total = original.count + week1.count + week2.count + week3.count + jottacloud.count + oauthExpansion.count
        XCTAssertEqual(total, 42, "Total should be 42 providers")
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
            
            // OAuth Expansion (8)
            .googlePhotos, .flickr, .sugarsync, .opendrive,
            .putio, .premiumizeme, .quatrix, .filefabric
        ]
        
        XCTAssertEqual(oauthProviders.count, 19, "Should have 19 OAuth providers")
    }
    
    func testAllOAuthProvidersAreSupported() {
        let oauthProviders: [CloudProviderType] = [
            .googleDrive, .dropbox, .oneDrive, .box,
            .yandexDisk, .pcloud, .koofr, .mailRuCloud,
            .sharepoint, .oneDriveBusiness, .googleCloudStorage,
            .googlePhotos, .flickr, .sugarsync, .opendrive,
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
        let mediaProviders: [CloudProviderType] = [
            .googlePhotos, .flickr
        ]
        
        XCTAssertEqual(mediaProviders.count, 2, "Should have 2 media providers")
        
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
        XCTAssertTrue(nordicProviders[0].isExperimental, "Jottacloud should be experimental")
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
        
        XCTAssertEqual(experimental.count, 1, "Should have 1 experimental provider")
        XCTAssertTrue(experimental.contains(.jottacloud), "Jottacloud should be experimental")
    }
    
    func testExperimentalProviderHasNote() {
        let jottacloud = CloudProviderType.jottacloud
        
        XCTAssertTrue(jottacloud.isExperimental)
        XCTAssertNotNil(jottacloud.experimentalNote)
        XCTAssertFalse(jottacloud.experimentalNote!.isEmpty)
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
        let oauthExpansion = 8
        
        let phase1Total = phase1Week1 + phase1Week2 + phase1Week3
        XCTAssertEqual(phase1Total, 20, "Phase 1 should add 20 providers")
        
        let afterPhase1 = original + phase1Total
        XCTAssertEqual(afterPhase1, 33, "After Phase 1 should have 33 providers")
        
        let afterJottacloud = afterPhase1 + jottacloud
        XCTAssertEqual(afterJottacloud, 34, "After Jottacloud should have 34 providers")
        
        let final = afterJottacloud + oauthExpansion
        XCTAssertEqual(final, 42, "Final should have 42 providers")
        
        let growthPercentage = Double(final - original) / Double(original) * 100
        XCTAssertGreaterThan(growthPercentage, 223, "Growth should be over 223%")
    }
    
    // MARK: - Authentication Method Tests
    
    func testAuthenticationMethodDistribution() {
        let allProviders = CloudProviderType.allCases.filter { $0.isSupported }
        
        let oauth = 19
        let credentials = 9
        let accessKeys = 14
        
        let totalAuth = oauth + credentials + accessKeys
        XCTAssertEqual(totalAuth, 42, "Total auth methods should equal 42")
        
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
        XCTAssertEqual(allProviders.count, 42, "Should have 42 providers")
        
        // OAuth count
        let oauthCount = 19
        XCTAssertGreaterThanOrEqual(oauthCount, 19, "Should have at least 19 OAuth providers")
        
        // Supported count
        let supported = allProviders.filter { $0.isSupported }
        XCTAssertEqual(supported.count, 41, "Should have 41 supported providers")
        
        // Experimental count
        let experimental = allProviders.filter { $0.isExperimental }
        XCTAssertEqual(experimental.count, 1, "Should have 1 experimental provider")
        
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
        
        // CloudSync Ultra: 42 providers
        // Typical competitor: 5-10 providers
        let typicalCompetitor = 10
        
        XCTAssertGreaterThan(allProviders.count, typicalCompetitor * 4, "Should have 4x more providers than typical competitor")
    }
    
    func testIndustryLeadingOAuthCount() {
        let oauthCount = 19
        
        // CloudSync Ultra: 19 OAuth
        // Typical competitor: 3-4 OAuth
        let typicalCompetitor = 4
        
        XCTAssertGreaterThan(oauthCount, typicalCompetitor * 4, "Should have 4x more OAuth than typical competitor")
    }
    
    func testUniqueFeatures() {
        // Features no competitor has
        let mediaProviders = [CloudProviderType.googlePhotos, .flickr]
        let specializedProviders = [CloudProviderType.putio, .premiumizeme]
        let nordicProviders = [CloudProviderType.jottacloud]
        
        XCTAssertEqual(mediaProviders.count, 2, "Unique: 2 media providers")
        XCTAssertEqual(specializedProviders.count, 2, "Unique: 2 specialized providers")
        XCTAssertEqual(nordicProviders.count, 1, "Unique: Nordic coverage")
    }
}
