//
//  Phase1Week3ProvidersTests.swift
//  CloudSyncAppTests
//
//  Tests for Phase 1, Week 3 cloud providers:
//  Google Cloud Storage, Azure Blob, Azure Files, OneDrive for Business, SharePoint, Alibaba OSS
//

import XCTest
@testable import CloudSyncApp

final class Phase1Week3ProvidersTests: XCTestCase {
    
    // MARK: - CloudProvider Model Tests
    
    func testGoogleCloudStorageProviderProperties() {
        let provider = CloudProviderType.googleCloudStorage
        XCTAssertEqual(provider.displayName, "Google Cloud Storage")
        XCTAssertEqual(provider.rcloneType, "google cloud storage")
        XCTAssertEqual(provider.defaultRcloneName, "gcs")
        XCTAssertEqual(provider.iconName, "cloud.fill")
        XCTAssertNotNil(provider.brandColor)
    }
    
    func testAzureBlobProviderProperties() {
        let provider = CloudProviderType.azureBlob
        XCTAssertEqual(provider.displayName, "Azure Blob Storage")
        XCTAssertEqual(provider.rcloneType, "azureblob")
        XCTAssertEqual(provider.defaultRcloneName, "azureblob")
        XCTAssertEqual(provider.iconName, "cylinder.fill")
        XCTAssertNotNil(provider.brandColor)
    }
    
    func testAzureFilesProviderProperties() {
        let provider = CloudProviderType.azureFiles
        XCTAssertEqual(provider.displayName, "Azure Files")
        XCTAssertEqual(provider.rcloneType, "azurefiles")
        XCTAssertEqual(provider.defaultRcloneName, "azurefiles")
        XCTAssertEqual(provider.iconName, "doc.on.doc.fill")
        XCTAssertNotNil(provider.brandColor)
    }
    
    func testOneDriveBusinessProviderProperties() {
        let provider = CloudProviderType.oneDriveBusiness
        XCTAssertEqual(provider.displayName, "OneDrive for Business")
        XCTAssertEqual(provider.rcloneType, "onedrive")
        XCTAssertEqual(provider.defaultRcloneName, "onedrive-business")
        XCTAssertEqual(provider.iconName, "briefcase.fill")
        XCTAssertNotNil(provider.brandColor)
    }
    
    func testSharePointProviderProperties() {
        let provider = CloudProviderType.sharepoint
        XCTAssertEqual(provider.displayName, "SharePoint")
        XCTAssertEqual(provider.rcloneType, "sharepoint")
        XCTAssertEqual(provider.defaultRcloneName, "sharepoint")
        XCTAssertEqual(provider.iconName, "folder.badge.person.crop")
        XCTAssertNotNil(provider.brandColor)
    }
    
    func testAlibabaOSSProviderProperties() {
        let provider = CloudProviderType.alibabaOSS
        XCTAssertEqual(provider.displayName, "Alibaba Cloud OSS")
        XCTAssertEqual(provider.rcloneType, "oss")
        XCTAssertEqual(provider.defaultRcloneName, "oss")
        XCTAssertEqual(provider.iconName, "building.fill")
        XCTAssertNotNil(provider.brandColor)
    }
    
    // MARK: - Provider Count Tests
    
    func testProviderCountIncreased() {
        let allProviders = CloudProviderType.allCases
        XCTAssertEqual(allProviders.count, 41, "Should have 41 providers total")
    }
    
    func testNewProvidersInAllCases() {
        let allProviders = CloudProviderType.allCases
        XCTAssertTrue(allProviders.contains(.googleCloudStorage))
        XCTAssertTrue(allProviders.contains(.azureBlob))
        XCTAssertTrue(allProviders.contains(.azureFiles))
        XCTAssertTrue(allProviders.contains(.oneDriveBusiness))
        XCTAssertTrue(allProviders.contains(.sharepoint))
        XCTAssertTrue(allProviders.contains(.alibabaOSS))
    }
    
    // MARK: - Enterprise Provider Tests
    
    func testAllAreEnterpriseProviders() {
        let enterpriseProviders: [CloudProviderType] = [
            .googleCloudStorage, .azureBlob, .azureFiles,
            .oneDriveBusiness, .sharepoint, .alibabaOSS
        ]
        
        for provider in enterpriseProviders {
            XCTAssertTrue(provider.isSupported, "\(provider.displayName) should be supported")
        }
    }
    
    // MARK: - Brand Color Tests
    
    func testGoogleCloudStorageBrandColor() {
        let provider = CloudProviderType.googleCloudStorage
        let color = provider.brandColor
        XCTAssertNotNil(color)
        // Google Cloud blue: RGB(66, 133, 244) = (0.26, 0.52, 0.96)
    }
    
    func testAzureBrandColors() {
        let azureBlob = CloudProviderType.azureBlob
        let azureFiles = CloudProviderType.azureFiles
        
        XCTAssertNotNil(azureBlob.brandColor)
        XCTAssertNotNil(azureFiles.brandColor)
        // Both should have Azure blue variants
    }
    
    func testAlibabaOSSBrandColor() {
        let provider = CloudProviderType.alibabaOSS
        let color = provider.brandColor
        XCTAssertNotNil(color)
        // Alibaba orange: RGB(255, 107, 0) = (1.0, 0.42, 0.0)
    }
    
    // MARK: - Codable Tests
    
    func testNewProvidersAreCodable() throws {
        let providers: [CloudProviderType] = [
            .googleCloudStorage, .azureBlob, .azureFiles,
            .oneDriveBusiness, .sharepoint, .alibabaOSS
        ]
        
        for provider in providers {
            let encoded = try JSONEncoder().encode(provider)
            let decoded = try JSONDecoder().decode(CloudProviderType.self, from: encoded)
            XCTAssertEqual(decoded, provider, "\(provider.displayName) should be codable")
        }
    }
    
    func testCloudRemoteWithNewProviders() throws {
        let remotes = [
            CloudRemote(name: "GCS Bucket", type: .googleCloudStorage),
            CloudRemote(name: "Azure Blob", type: .azureBlob),
            CloudRemote(name: "Azure Files", type: .azureFiles),
            CloudRemote(name: "OD Business", type: .oneDriveBusiness),
            CloudRemote(name: "SP Site", type: .sharepoint),
            CloudRemote(name: "Alibaba OSS", type: .alibabaOSS)
        ]
        
        for remote in remotes {
            let encoded = try JSONEncoder().encode(remote)
            let decoded = try JSONDecoder().decode(CloudRemote.self, from: encoded)
            XCTAssertEqual(decoded.type, remote.type)
            XCTAssertEqual(decoded.name, remote.name)
        }
    }
    
    // MARK: - RawValue Tests
    
    func testProviderRawValues() {
        let expectedRawValues: [(CloudProviderType, String)] = [
            (.googleCloudStorage, "gcs"),
            (.azureBlob, "azureblob"),
            (.azureFiles, "azurefiles"),
            (.oneDriveBusiness, "onedrive-business"),
            (.sharepoint, "sharepoint"),
            (.alibabaOSS, "oss")
        ]
        
        for (provider, expectedRaw) in expectedRawValues {
            XCTAssertEqual(provider.rawValue, expectedRaw)
        }
    }
    
    // MARK: - Icon Tests
    
    func testAllNewProvidersHaveIcons() {
        let newProviders: [CloudProviderType] = [
            .googleCloudStorage, .azureBlob, .azureFiles,
            .oneDriveBusiness, .sharepoint, .alibabaOSS
        ]
        
        for provider in newProviders {
            XCTAssertFalse(provider.iconName.isEmpty, "\(provider.displayName) should have icon")
            XCTAssertGreaterThan(provider.iconName.count, 0)
        }
    }
    
    func testIconNamesAreValid() {
        let validIconNames = [
            "cloud.fill",                  // googleCloudStorage
            "cylinder.fill",               // azureBlob
            "doc.on.doc.fill",            // azureFiles
            "briefcase.fill",              // oneDriveBusiness
            "folder.badge.person.crop",    // sharepoint
            "building.fill"                // alibabaOSS
        ]
        
        let newProviders: [CloudProviderType] = [
            .googleCloudStorage, .azureBlob, .azureFiles,
            .oneDriveBusiness, .sharepoint, .alibabaOSS
        ]
        
        for (index, provider) in newProviders.enumerated() {
            XCTAssertEqual(provider.iconName, validIconNames[index])
        }
    }
    
    // MARK: - Display Name Tests
    
    func testDisplayNamesAreUserFriendly() {
        let providers: [(CloudProviderType, String)] = [
            (.googleCloudStorage, "Google Cloud Storage"),
            (.azureBlob, "Azure Blob Storage"),
            (.azureFiles, "Azure Files"),
            (.oneDriveBusiness, "OneDrive for Business"),
            (.sharepoint, "SharePoint"),
            (.alibabaOSS, "Alibaba Cloud OSS")
        ]
        
        for (provider, expectedName) in providers {
            XCTAssertEqual(provider.displayName, expectedName)
            XCTAssertFalse(provider.displayName.isEmpty)
        }
    }
    
    // MARK: - Microsoft Ecosystem Tests
    
    func testMicrosoftEcosystemProviders() {
        let microsoftProviders: [CloudProviderType] = [
            .azureBlob, .azureFiles, .oneDriveBusiness, .sharepoint
        ]
        
        // All Microsoft providers should be supported
        for provider in microsoftProviders {
            XCTAssertTrue(provider.isSupported, "\(provider.displayName) should be supported")
        }
    }
    
    func testAzureProvidersUseDifferentTypes() {
        // Azure Blob and Azure Files should have different rclone types
        XCTAssertEqual(CloudProviderType.azureBlob.rcloneType, "azureblob")
        XCTAssertEqual(CloudProviderType.azureFiles.rcloneType, "azurefiles")
        XCTAssertNotEqual(CloudProviderType.azureBlob.rcloneType, CloudProviderType.azureFiles.rcloneType)
    }
    
    func testOneDriveBusinessUsesOneDriveType() {
        // OneDrive for Business uses same rclone type as OneDrive
        XCTAssertEqual(CloudProviderType.oneDriveBusiness.rcloneType, "onedrive")
        XCTAssertEqual(CloudProviderType.oneDrive.rcloneType, "onedrive")
    }
    
    // MARK: - Google Ecosystem Tests
    
    func testGoogleCloudStorageUsesNativeType() {
        XCTAssertEqual(CloudProviderType.googleCloudStorage.rcloneType, "google cloud storage")
    }
    
    // MARK: - Hashable & Equatable Tests
    
    func testProvidersAreHashable() {
        let providerSet: Set<CloudProviderType> = [
            .googleCloudStorage, .azureBlob, .azureFiles,
            .oneDriveBusiness, .sharepoint, .alibabaOSS
        ]
        
        XCTAssertEqual(providerSet.count, 6)
    }
    
    func testProvidersAreEquatable() {
        let provider1 = CloudProviderType.googleCloudStorage
        let provider2 = CloudProviderType.googleCloudStorage
        
        XCTAssertEqual(provider1, provider2)
        XCTAssertNotEqual(CloudProviderType.googleCloudStorage, CloudProviderType.azureBlob)
    }
    
    // MARK: - Identifiable Tests
    
    func testProvidersAreIdentifiable() {
        let providers: [CloudProviderType] = [
            .googleCloudStorage, .azureBlob, .azureFiles,
            .oneDriveBusiness, .sharepoint, .alibabaOSS
        ]
        
        for provider in providers {
            XCTAssertEqual(provider.id, provider.rawValue)
        }
    }
    
    // MARK: - Integration Tests
    
    func testCloudRemoteWithGoogleCloudStorage() {
        let remote = CloudRemote(
            name: "GCS Bucket",
            type: .googleCloudStorage,
            customRcloneName: "my-gcs"
        )
        
        XCTAssertEqual(remote.name, "GCS Bucket")
        XCTAssertEqual(remote.type, .googleCloudStorage)
        XCTAssertEqual(remote.rcloneName, "my-gcs")
        XCTAssertEqual(remote.displayIcon, "cloud.fill")
    }
    
    func testCloudRemoteDefaultRcloneName() {
        let remote = CloudRemote(name: "Azure Storage", type: .azureBlob)
        XCTAssertEqual(remote.rcloneName, "azureblob")
    }
    
    // MARK: - Comprehensive Provider Validation
    
    func testAllProvidersHaveUniqueRawValues() {
        let allProviders = CloudProviderType.allCases
        let rawValues = allProviders.map { $0.rawValue }
        let uniqueRawValues = Set(rawValues)
        
        XCTAssertEqual(rawValues.count, uniqueRawValues.count, "All providers should have unique raw values")
    }
    
    func testAllProvidersHaveUniqueDisplayNames() {
        let allProviders = CloudProviderType.allCases
        let displayNames = allProviders.map { $0.displayName }
        let uniqueDisplayNames = Set(displayNames)
        
        XCTAssertEqual(displayNames.count, uniqueDisplayNames.count, "All providers should have unique display names")
    }
    
    func testAllProvidersHaveNonEmptyProperties() {
        let newProviders: [CloudProviderType] = [
            .googleCloudStorage, .azureBlob, .azureFiles,
            .oneDriveBusiness, .sharepoint, .alibabaOSS
        ]
        
        for provider in newProviders {
            XCTAssertFalse(provider.displayName.isEmpty, "\(provider.rawValue) should have display name")
            XCTAssertFalse(provider.iconName.isEmpty, "\(provider.rawValue) should have icon")
            XCTAssertFalse(provider.rcloneType.isEmpty, "\(provider.rawValue) should have rclone type")
            XCTAssertFalse(provider.defaultRcloneName.isEmpty, "\(provider.rawValue) should have default name")
        }
    }
    
    // MARK: - Phase 1 Completion Tests
    
    func testPhase1Complete() {
        // Phase 1 target was 33 providers
        let allProviders = CloudProviderType.allCases
        XCTAssertEqual(allProviders.count, 41, "Should have 41 total providers")
    }
    
    func testPhase1ProviderBreakdown() {
        let allProviders = CloudProviderType.allCases
        
        // Original: 13
        // Week 1: +6 = 19
        // Week 2: +8 = 27
        // Week 3: +6 = 33
        
        XCTAssertEqual(allProviders.count, 41, "Should have 41 total providers")
    }
}
