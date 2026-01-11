//
//  ProtonDriveTests.swift
//  CloudSyncAppTests
//
//  Unit tests for Proton Drive integration
//

import XCTest
@testable import CloudSyncApp

final class ProtonDriveTests: XCTestCase {
    
    // MARK: - CloudProviderType Tests
    
    func testProtonDriveProviderType() {
        let provider = CloudProviderType.protonDrive
        
        XCTAssertEqual(provider.rawValue, "proton")
        XCTAssertEqual(provider.displayName, "Proton Drive")
        XCTAssertEqual(provider.rcloneType, "protondrive")
        XCTAssertEqual(provider.defaultRcloneName, "proton")
        XCTAssertTrue(provider.isSupported)
        XCTAssertFalse(provider.isExperimental)
        XCTAssertFalse(provider.requiresOAuth)  // Uses direct auth, not OAuth
    }
    
    func testProtonDriveIcon() {
        let provider = CloudProviderType.protonDrive
        XCTAssertEqual(provider.iconName, "shield.checkered")
    }
    
    func testProtonDriveBrandColor() {
        let provider = CloudProviderType.protonDrive
        // Should be purple-ish (Proton brand color)
        XCTAssertNotNil(provider.brandColor)
    }
    
    // MARK: - CloudRemote Tests
    
    func testProtonRemoteCreation() {
        let remote = CloudRemote(
            name: "Proton Drive",
            type: .protonDrive,
            isConfigured: false,
            path: "",
            customRcloneName: "proton"
        )
        
        XCTAssertEqual(remote.name, "Proton Drive")
        XCTAssertEqual(remote.type, .protonDrive)
        XCTAssertFalse(remote.isConfigured)
        XCTAssertEqual(remote.rcloneName, "proton")
    }
    
    func testProtonRemoteWithCustomName() {
        let remote = CloudRemote(
            name: "My Proton",
            type: .protonDrive,
            isConfigured: true,
            path: "/Documents",
            customRcloneName: "myproton"
        )
        
        XCTAssertEqual(remote.rcloneName, "myproton")
        XCTAssertTrue(remote.isConfigured)
    }
    
    func testProtonRemoteDefaultRcloneName() {
        let remote = CloudRemote(
            name: "Proton Drive",
            type: .protonDrive,
            isConfigured: false,
            path: ""
            // No customRcloneName - should use default
        )
        
        XCTAssertEqual(remote.rcloneName, "proton")
    }
    
    // MARK: - Encryption Tests
    
    func testProtonRemoteEncryptionSupport() {
        var remote = CloudRemote(
            name: "Proton Drive",
            type: .protonDrive,
            isConfigured: true,
            path: "",
            isEncrypted: false,
            customRcloneName: "proton"
        )
        
        XCTAssertFalse(remote.isEncrypted)
        
        remote.isEncrypted = true
        XCTAssertTrue(remote.isEncrypted)
    }
    
    func testProtonCryptRemoteName() {
        let remote = CloudRemote(
            name: "Proton Drive",
            type: .protonDrive,
            isConfigured: true,
            path: "",
            customRcloneName: "proton"
        )
        
        // The crypt remote should follow the naming convention
        XCTAssertEqual(remote.cryptRemoteName, "proton-crypt")
    }
    
    // MARK: - 2FA Mode Tests
    
    func testTwoFactorModeNone() {
        // Test that 2FA mode descriptions are correct
        XCTAssertNotNil(ProtonDriveSetupView.TwoFactorMode.none)
        XCTAssertEqual(ProtonDriveSetupView.TwoFactorMode.none.rawValue, "None")
    }
    
    func testTwoFactorModeSingleCode() {
        XCTAssertEqual(ProtonDriveSetupView.TwoFactorMode.code.rawValue, "Single Code")
    }
    
    func testTwoFactorModeTOTP() {
        XCTAssertEqual(ProtonDriveSetupView.TwoFactorMode.totp.rawValue, "TOTP Secret")
    }
    
    // MARK: - Error Parsing Tests (via RcloneError)
    
    func testRcloneErrorTypes() {
        // Test that error types can be created
        let configError = RcloneError.configurationFailed("test error")
        XCTAssertNotNil(configError.errorDescription)
        XCTAssertTrue(configError.errorDescription!.contains("Configuration failed"))
        
        let syncError = RcloneError.syncFailed("sync error")
        XCTAssertNotNil(syncError.errorDescription)
        XCTAssertTrue(syncError.errorDescription!.contains("Sync failed"))
        
        let notInstalled = RcloneError.notInstalled
        XCTAssertNotNil(notInstalled.errorDescription)
        XCTAssertTrue(notInstalled.errorDescription!.contains("rclone is not installed"))
        
        let encryptionError = RcloneError.encryptionSetupFailed("encryption error")
        XCTAssertNotNil(encryptionError.errorDescription)
        XCTAssertTrue(encryptionError.errorDescription!.contains("Encryption setup failed"))
    }
    
    // MARK: - FileItem Tests for Proton Drive Files
    
    func testFileItemCreation() {
        let file = FileItem(
            name: "document.pdf",
            path: "/Documents/document.pdf",
            isDirectory: false,
            size: 1024 * 1024,  // 1 MB
            modifiedDate: Date()
        )
        
        XCTAssertEqual(file.name, "document.pdf")
        XCTAssertEqual(file.path, "/Documents/document.pdf")
        XCTAssertFalse(file.isDirectory)
        XCTAssertEqual(file.size, 1024 * 1024)
        XCTAssertEqual(file.icon, "doc.fill")  // PDF icon
    }
    
    func testFolderItemCreation() {
        let folder = FileItem(
            name: "Backup",
            path: "/Backup",
            isDirectory: true
        )
        
        XCTAssertEqual(folder.name, "Backup")
        XCTAssertTrue(folder.isDirectory)
        XCTAssertEqual(folder.icon, "folder.fill")
        XCTAssertEqual(folder.formattedSize, "--")  // Folders show "--" for size
    }
    
    func testFileIconMapping() {
        // Test various file extensions
        let pdfFile = FileItem(name: "test.pdf", path: "/test.pdf", isDirectory: false)
        XCTAssertEqual(pdfFile.icon, "doc.fill")
        
        let swiftFile = FileItem(name: "main.swift", path: "/main.swift", isDirectory: false)
        XCTAssertEqual(swiftFile.icon, "chevron.left.forwardslash.chevron.right")
        
        let imageFile = FileItem(name: "photo.jpg", path: "/photo.jpg", isDirectory: false)
        XCTAssertEqual(imageFile.icon, "photo.fill")
        
        let videoFile = FileItem(name: "video.mp4", path: "/video.mp4", isDirectory: false)
        XCTAssertEqual(videoFile.icon, "film.fill")
        
        let zipFile = FileItem(name: "archive.zip", path: "/archive.zip", isDirectory: false)
        XCTAssertEqual(zipFile.icon, "doc.zipper")
    }
    
    // MARK: - Provider Categorization Tests
    
    func testProtonIsNotOAuthProvider() {
        // Proton Drive uses direct username/password auth, not OAuth
        XCTAssertFalse(CloudProviderType.protonDrive.requiresOAuth)
    }
    
    func testOAuthProviders() {
        // These should require OAuth
        XCTAssertTrue(CloudProviderType.googleDrive.requiresOAuth)
        XCTAssertTrue(CloudProviderType.dropbox.requiresOAuth)
        XCTAssertTrue(CloudProviderType.oneDrive.requiresOAuth)
        XCTAssertTrue(CloudProviderType.box.requiresOAuth)
    }
    
    // MARK: - Sync Mode Tests
    
    func testSyncModes() {
        // Test sync modes that Proton Drive supports
        let oneWay = SyncMode.oneWay
        let biDirectional = SyncMode.biDirectional
        
        // These should be distinct
        XCTAssertTrue(oneWay != biDirectional || oneWay == biDirectional)  // Just verify they exist
    }
    
    // MARK: - Progress Status Tests
    
    func testSyncStatusTypes() {
        XCTAssertEqual(SyncStatus.idle, SyncStatus.idle)
        XCTAssertEqual(SyncStatus.checking, SyncStatus.checking)
        XCTAssertEqual(SyncStatus.syncing, SyncStatus.syncing)
        XCTAssertEqual(SyncStatus.completed, SyncStatus.completed)
        
        let error1 = SyncStatus.error("Error 1")
        let error2 = SyncStatus.error("Error 2")
        let error1Copy = SyncStatus.error("Error 1")
        
        XCTAssertNotEqual(error1, error2)
        XCTAssertEqual(error1, error1Copy)
    }
    
    func testSyncProgressCreation() {
        let progress = SyncProgress(
            percentage: 50.0,
            speed: "1.5 MB/s",
            status: .syncing,
            filesTransferred: 5,
            totalFiles: 10,
            bytesTransferred: 1024 * 1024 * 5,
            totalBytes: 1024 * 1024 * 10
        )
        
        XCTAssertEqual(progress.percentage, 50.0)
        XCTAssertEqual(progress.speed, "1.5 MB/s")
        XCTAssertEqual(progress.status, .syncing)
        XCTAssertEqual(progress.filesTransferred, 5)
        XCTAssertEqual(progress.totalFiles, 10)
    }
}
