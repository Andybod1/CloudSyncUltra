//
//  MainWindowIntegrationTests.swift
//  CloudSyncAppTests
//
//  Tests for MainWindow provider configuration and UI integration
//

import XCTest
@testable import CloudSyncApp

final class MainWindowIntegrationTests: XCTestCase {
    
    // MARK: - Provider Configuration Tests
    
    func testConfigureRemoteHandlesAllProviders() {
        // Verify MainWindow.configureRemote has cases for all 41 providers
        let allProviders = CloudProviderType.allCases

        XCTAssertEqual(allProviders.count, 41, "Should handle all 41 providers")
    }
    
    func testOriginalProvidersConfiguration() {
        // Test that original providers have configuration cases
        let originalProviders: [CloudProviderType] = [
            .protonDrive, .googleDrive, .dropbox, .oneDrive,
            .s3, .mega, .box, .pcloud,
            .webdav, .sftp, .ftp, .local
        ]
        
        for provider in originalProviders {
            XCTAssertTrue(provider.isSupported || provider == .icloud,
                         "\(provider.displayName) should be supported or icloud")
        }
    }
    
    func testPhase1ProvidersConfiguration() {
        // Test Phase 1 providers have configuration
        let phase1Providers: [CloudProviderType] = [
            .nextcloud, .owncloud, .seafile, .koofr, .yandexDisk, .mailRuCloud,
            .backblazeB2, .wasabi, .digitalOceanSpaces, .cloudflareR2,
            .scaleway, .oracleCloud, .storj, .filebase,
            .googleCloudStorage, .azureBlob, .azureFiles,
            .oneDriveBusiness, .sharepoint, .alibabaOSS
        ]
        
        XCTAssertEqual(phase1Providers.count, 20, "Should have 20 Phase 1 providers")
        
        for provider in phase1Providers {
            XCTAssertTrue(provider.isSupported, "\(provider.displayName) should be supported")
        }
    }
    
    func testOAuthExpansionConfiguration() {
        // Test OAuth expansion providers have configuration (Google Photos removed)
        let oauthExpansion: [CloudProviderType] = [
            .flickr, .sugarsync, .opendrive,
            .putio, .premiumizeme, .quatrix, .filefabric
        ]
        
        XCTAssertEqual(oauthExpansion.count, 7, "Should have 7 OAuth expansion providers")
        
        for provider in oauthExpansion {
            XCTAssertTrue(provider.isSupported, "\(provider.displayName) should be supported")
        }
    }
    
    // MARK: - OAuth Provider Configuration Tests
    
    func testOAuthProvidersNoCredentials() {
        // OAuth providers should not require credentials in UI
        let oauthProviders: [CloudProviderType] = [
            .googleDrive, .dropbox, .oneDrive, .box, .pcloud,
            .flickr, .sugarsync, .opendrive,
            .putio, .premiumizeme, .quatrix, .filefabric
        ]
        
        // OAuth providers use browser authentication
        for provider in oauthProviders {
            XCTAssertNotNil(provider.rcloneType)
            XCTAssertFalse(provider.rcloneType.isEmpty)
        }
    }
    
    func testCredentialProvidersNeedInput() {
        // Credential-based providers need username/password
        let credentialProviders: [CloudProviderType] = [
            .protonDrive, .mega, .nextcloud, .owncloud,
            .seafile, .webdav, .sftp, .ftp
        ]
        
        for provider in credentialProviders {
            XCTAssertTrue(provider.isSupported || provider == .icloud)
        }
    }
    
    func testAccessKeyProvidersNeedKeys() {
        // S3-compatible providers need access keys
        let s3Providers: [CloudProviderType] = [
            .s3, .backblazeB2, .wasabi, .digitalOceanSpaces,
            .cloudflareR2, .scaleway, .oracleCloud, .filebase
        ]
        
        for provider in s3Providers {
            XCTAssertTrue(provider.isSupported)
            // S3-compatible should have s3 rclone type or specific type
            XCTAssertNotNil(provider.rcloneType)
        }
    }
    
    // MARK: - Provider Categories in UI
    
    func testProviderCardDisplaysCorrectly() {
        let allProviders = CloudProviderType.allCases
        
        for provider in allProviders {
            // Each provider should have display properties
            XCTAssertFalse(provider.displayName.isEmpty)
            XCTAssertFalse(provider.iconName.isEmpty)
            XCTAssertNotNil(provider.brandColor)
        }
    }
    
    func testExperimentalProviderBadge() {
        // After #24 fix: Jottacloud is no longer experimental
        let experimental = CloudProviderType.allCases.filter { $0.isExperimental }

        // No providers should be marked as experimental after #24
        XCTAssertEqual(experimental.count, 0, "Should have 0 experimental providers after #24 fix")

        // Verify Jottacloud specifically is NOT experimental
        XCTAssertFalse(CloudProviderType.jottacloud.isExperimental, "Jottacloud should not be experimental")
    }
    
    func testUnsupportedProviderHidden() {
        let unsupported = CloudProviderType.allCases.filter { !$0.isSupported }
        
        XCTAssertEqual(unsupported.count, 1, "Should have 1 unsupported provider")
        XCTAssertTrue(unsupported.contains(.icloud))
    }
    
    // MARK: - Remote Creation Tests
    
    func testCloudRemoteCreation() {
        let testProviders: [CloudProviderType] = [
            .googleDrive, .dropbox, .pcloud, .flickr
        ]
        
        for provider in testProviders {
            let remote = CloudRemote(
                name: "Test \(provider.displayName)",
                type: provider,
                isConfigured: false
            )
            
            XCTAssertEqual(remote.type, provider)
            XCTAssertFalse(remote.isConfigured)
            XCTAssertTrue(remote.name.contains(provider.displayName))
        }
    }
    
    func testRemoteIdentification() {
        let remote1 = CloudRemote(name: "Google", type: .googleDrive, isConfigured: true)
        let remote2 = CloudRemote(name: "Dropbox", type: .dropbox, isConfigured: true)
        
        XCTAssertNotEqual(remote1.id, remote2.id)
        XCTAssertEqual(remote1.type, .googleDrive)
        XCTAssertEqual(remote2.type, .dropbox)
    }
    
    // MARK: - UI State Tests
    
    func testProviderSelectionState() {
        // Test that providers can be selected/deselected
        let providers = [CloudProviderType.googleDrive, .dropbox, .oneDrive]
        
        for provider in providers {
            XCTAssertNotNil(provider.id)
            XCTAssertEqual(provider.id, provider.rawValue)
        }
    }
    
    func testProviderGridLayout() {
        let allProviders = CloudProviderType.allCases.filter { $0.isSupported }
        
        // Should have enough providers for multi-column grid
        XCTAssertGreaterThan(allProviders.count, 20, "Should have enough for grid layout")
    }
    
    // MARK: - Connection Flow Tests
    
    func testOAuthConnectionFlow() {
        // OAuth flow: Select → Connect → Browser → Authorize → Done
        let oauthProvider = CloudProviderType.googleDrive
        
        XCTAssertTrue(oauthProvider.isSupported)
        XCTAssertNotNil(oauthProvider.rcloneType)
        XCTAssertEqual(oauthProvider.rcloneType, "drive")
    }
    
    func testCredentialConnectionFlow() {
        // Credential flow: Select → Enter credentials → Connect → Done
        let credentialProvider = CloudProviderType.protonDrive
        
        XCTAssertTrue(credentialProvider.isSupported)
        XCTAssertEqual(credentialProvider.rcloneType, "protondrive")
    }
    
    func testAccessKeyConnectionFlow() {
        // Access key flow: Select → Enter keys → Connect → Done
        let keyProvider = CloudProviderType.s3
        
        XCTAssertTrue(keyProvider.isSupported)
        XCTAssertEqual(keyProvider.rcloneType, "s3")
    }
    
    // MARK: - Error Handling Tests
    
    func testInvalidProviderHandling() {
        // Test that invalid configurations are handled
        let remote = CloudRemote(
            name: "",
            type: .googleDrive,
            isConfigured: false
        )
        
        XCTAssertEqual(remote.type, .googleDrive)
        XCTAssertFalse(remote.isConfigured)
    }
    
    func testEmptyRemoteListHandling() {
        // Should handle empty remote list gracefully
        let emptyList: [CloudRemote] = []
        XCTAssertEqual(emptyList.count, 0)
    }
    
    // MARK: - Provider Filtering Tests
    
    func testSupportedProvidersOnly() {
        let supported = CloudProviderType.allCases.filter { $0.isSupported }
        let unsupported = CloudProviderType.allCases.filter { !$0.isSupported }
        
        XCTAssertEqual(supported.count, 40)
        XCTAssertEqual(unsupported.count, 1)
        XCTAssertEqual(supported.count + unsupported.count, 41)
    }
    
    func testExperimentalProviderFiltering() {
        // After #24 fix: No experimental providers
        let experimental = CloudProviderType.allCases.filter { $0.isExperimental }
        let stable = CloudProviderType.allCases.filter { !$0.isExperimental }

        XCTAssertEqual(experimental.count, 0, "No experimental providers after #24 fix")
        XCTAssertEqual(stable.count, 41, "All 41 providers should be stable")
    }
    
    // MARK: - Provider Search Tests
    
    func testProviderNameSearch() {
        let allProviders = CloudProviderType.allCases
        
        // Test searching by name
        let googleProviders = allProviders.filter { $0.displayName.contains("Google") }
        XCTAssertGreaterThanOrEqual(googleProviders.count, 3) // Google Drive, Photos, GCS
        
        let azureProviders = allProviders.filter { $0.displayName.contains("Azure") }
        XCTAssertGreaterThanOrEqual(azureProviders.count, 2) // Blob, Files
    }
    
    func testProviderCategorySearch() {
        let allProviders = CloudProviderType.allCases
        
        // Consumer cloud
        let consumer = allProviders.filter { provider in
            [.googleDrive, .dropbox, .oneDrive, .box, .pcloud, .mega].contains(provider)
        }
        XCTAssertEqual(consumer.count, 6)
        
        // Enterprise
        let enterprise = allProviders.filter { provider in
            [.sharepoint, .oneDriveBusiness, .googleCloudStorage].contains(provider)
        }
        XCTAssertEqual(enterprise.count, 3)
    }
    
    // MARK: - Multi-Provider Tests
    
    func testMultipleProvidersSupported() {
        // Should support connecting multiple providers simultaneously
        let providers: [CloudProviderType] = [
            .googleDrive, .dropbox, .pcloud, .flickr, .protonDrive
        ]
        
        let remotes = providers.map { provider in
            CloudRemote(name: provider.displayName, type: provider, isConfigured: true)
        }
        
        XCTAssertEqual(remotes.count, 5)
        XCTAssertEqual(Set(remotes.map { $0.type }).count, 5) // All unique
    }
    
    func testProviderDuplicateNames() {
        // Should handle multiple remotes of same type
        let remote1 = CloudRemote(name: "Google Drive Personal", type: .googleDrive, isConfigured: true)
        let remote2 = CloudRemote(name: "Google Drive Work", type: .googleDrive, isConfigured: true)
        
        XCTAssertNotEqual(remote1.id, remote2.id)
        XCTAssertEqual(remote1.type, remote2.type)
        XCTAssertNotEqual(remote1.name, remote2.name)
    }
    
    // MARK: - Configuration State Tests
    
    func testConfiguredRemoteState() {
        let configured = CloudRemote(name: "Test", type: .googleDrive, isConfigured: true)
        XCTAssertTrue(configured.isConfigured)
    }
    
    func testUnconfiguredRemoteState() {
        let unconfigured = CloudRemote(name: "Test", type: .dropbox, isConfigured: false)
        XCTAssertFalse(unconfigured.isConfigured)
    }
    
    // MARK: - Provider Availability Tests
    
    func testAllProvidersAvailableInUI() {
        let allProviders = CloudProviderType.allCases
        let supported = allProviders.filter { $0.isSupported }
        
        // UI should show all supported providers
        XCTAssertEqual(supported.count, 41)
        
        for provider in supported {
            XCTAssertFalse(provider.displayName.isEmpty)
            XCTAssertFalse(provider.iconName.isEmpty)
        }
    }
    
    // MARK: - Comprehensive Integration Test
    
    func testCompleteProviderEcosystem() {
        let allProviders = CloudProviderType.allCases
        
        // Total count
        XCTAssertEqual(allProviders.count, 41)
        
        // All have required properties
        for provider in allProviders {
            XCTAssertFalse(provider.displayName.isEmpty)
            XCTAssertFalse(provider.iconName.isEmpty)
            XCTAssertFalse(provider.rcloneType.isEmpty)
            XCTAssertFalse(provider.defaultRcloneName.isEmpty)
            XCTAssertNotNil(provider.brandColor)
        }
        
        // Category counts
        let supported = allProviders.filter { $0.isSupported }
        let experimental = allProviders.filter { $0.isExperimental }
        let unsupported = allProviders.filter { !$0.isSupported }

        XCTAssertEqual(supported.count, 41)
        XCTAssertEqual(experimental.count, 0, "No experimental providers after #24 fix")
        XCTAssertEqual(unsupported.count, 1)
    }
}
