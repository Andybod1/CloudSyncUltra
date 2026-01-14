//
//  CloudProviderTests.swift
//  CloudSyncAppTests
//
//  Unit tests for CloudProvider and CloudRemote models
//

import XCTest
@testable import CloudSyncApp

final class CloudProviderTests: XCTestCase {
    
    // MARK: - CloudProviderType Tests
    
    func testDisplayName() {
        XCTAssertEqual(CloudProviderType.protonDrive.displayName, "Proton Drive")
        XCTAssertEqual(CloudProviderType.googleDrive.displayName, "Google Drive")
        XCTAssertEqual(CloudProviderType.dropbox.displayName, "Dropbox")
        XCTAssertEqual(CloudProviderType.oneDrive.displayName, "OneDrive")
        XCTAssertEqual(CloudProviderType.s3.displayName, "Amazon S3")
        XCTAssertEqual(CloudProviderType.local.displayName, "Local Storage")
    }
    
    func testDisplayIcon() {
        XCTAssertEqual(CloudProviderType.protonDrive.iconName, "shield.checkered")
        XCTAssertEqual(CloudProviderType.googleDrive.iconName, "g.circle.fill")
        XCTAssertEqual(CloudProviderType.dropbox.iconName, "shippingbox.fill")
        XCTAssertEqual(CloudProviderType.oneDrive.iconName, "cloud.fill")
        XCTAssertEqual(CloudProviderType.local.iconName, "folder.fill")
    }
    
    func testDefaultRcloneName() {
        XCTAssertEqual(CloudProviderType.protonDrive.defaultRcloneName, "proton")
        XCTAssertEqual(CloudProviderType.googleDrive.defaultRcloneName, "google")
        XCTAssertEqual(CloudProviderType.dropbox.defaultRcloneName, "dropbox")
        XCTAssertEqual(CloudProviderType.oneDrive.defaultRcloneName, "onedrive")
        XCTAssertEqual(CloudProviderType.s3.defaultRcloneName, "s3")
    }
    
    func testIsSupported() {
        XCTAssertTrue(CloudProviderType.protonDrive.isSupported)
        XCTAssertTrue(CloudProviderType.googleDrive.isSupported)
        XCTAssertTrue(CloudProviderType.dropbox.isSupported)
        XCTAssertTrue(CloudProviderType.local.isSupported)
        XCTAssertTrue(CloudProviderType.icloud.isSupported)  // Updated: iCloud Phase 1 now supported
    }
    
    func testRequiresOAuth() {
        XCTAssertTrue(CloudProviderType.googleDrive.requiresOAuth)
        XCTAssertTrue(CloudProviderType.dropbox.requiresOAuth)
        XCTAssertTrue(CloudProviderType.oneDrive.requiresOAuth)
        XCTAssertTrue(CloudProviderType.box.requiresOAuth)
        XCTAssertFalse(CloudProviderType.protonDrive.requiresOAuth)
        XCTAssertFalse(CloudProviderType.s3.requiresOAuth)
        XCTAssertFalse(CloudProviderType.local.requiresOAuth)
    }
    
    // MARK: - CloudRemote Tests
    
    func testCloudRemote_RcloneName_Default() {
        let remote = CloudRemote(
            name: "My Google Drive",
            type: .googleDrive,
            isConfigured: true
        )
        XCTAssertEqual(remote.rcloneName, "google")
    }
    
    func testCloudRemote_RcloneName_Custom() {
        let remote = CloudRemote(
            name: "My Google Drive",
            type: .googleDrive,
            isConfigured: true,
            customRcloneName: "Google"
        )
        XCTAssertEqual(remote.rcloneName, "Google")
    }
    
    func testCloudRemote_DisplayColor() {
        let proton = CloudRemote(name: "Proton", type: .protonDrive, isConfigured: true)
        let google = CloudRemote(name: "Google", type: .googleDrive, isConfigured: true)
        let dropbox = CloudRemote(name: "Dropbox", type: .dropbox, isConfigured: true)
        
        // Colors should not crash
        _ = proton.displayColor
        _ = google.displayColor
        _ = dropbox.displayColor
    }
    
    func testCloudRemote_DisplayIcon() {
        let remote = CloudRemote(name: "Proton", type: .protonDrive, isConfigured: true)
        XCTAssertEqual(remote.displayIcon, "shield.checkered")
    }
    
    func testCloudRemote_LocalStorage() {
        let local = CloudRemote(
            name: "Local",
            type: .local,
            isConfigured: true,
            path: "/Users/test"
        )
        XCTAssertEqual(local.rcloneName, "local")
        XCTAssertEqual(local.path, "/Users/test")
    }
    
    func testCloudRemote_Equality() {
        // CloudRemote uses auto-synthesized Equatable - all properties must match
        let id = UUID()
        let remote1 = CloudRemote(id: id, name: "Test", type: .googleDrive, isConfigured: true)
        let remote2 = CloudRemote(id: id, name: "Test", type: .googleDrive, isConfigured: true)
        XCTAssertEqual(remote1, remote2)
        
        // Different properties = not equal
        let remote3 = CloudRemote(id: id, name: "Different", type: .dropbox, isConfigured: false)
        XCTAssertNotEqual(remote1, remote3)
    }
    
    func testCloudRemote_Hashable() {
        let remote1 = CloudRemote(name: "Test", type: .googleDrive, isConfigured: true)
        let remote2 = CloudRemote(name: "Test2", type: .dropbox, isConfigured: true)
        
        var set = Set<CloudRemote>()
        set.insert(remote1)
        set.insert(remote2)
        
        XCTAssertEqual(set.count, 2)
    }
    
    // MARK: - All Provider Types
    
    func testAllProviderTypes() {
        let allTypes = CloudProviderType.allCases
        XCTAssertTrue(allTypes.count > 10)
        XCTAssertTrue(allTypes.contains(.protonDrive))
        XCTAssertTrue(allTypes.contains(.googleDrive))
        XCTAssertTrue(allTypes.contains(.local))
    }

    // MARK: - Jottacloud Tests (#24)

    func testJottacloudNotExperimental() {
        // #24: Jottacloud should not be marked as experimental
        let jottacloud = CloudProviderType.jottacloud
        XCTAssertFalse(jottacloud.isExperimental, "Jottacloud should not be marked as experimental")
    }

    func testJottacloudIsSupported() {
        // Jottacloud should be a fully supported provider
        let jottacloud = CloudProviderType.jottacloud
        XCTAssertTrue(jottacloud.isSupported, "Jottacloud should be supported")
    }

    func testJottacloudDisplayName() {
        XCTAssertEqual(CloudProviderType.jottacloud.displayName, "Jottacloud")
    }

    func testJottacloudRcloneType() {
        XCTAssertEqual(CloudProviderType.jottacloud.rcloneType, "jottacloud")
    }

    func testNoExperimentalProviders() {
        // After #24 fix, there should be no experimental providers
        let experimental = CloudProviderType.allCases.filter { $0.isExperimental }
        XCTAssertEqual(experimental.count, 0, "There should be no experimental providers after #24 fix")
    }
}
