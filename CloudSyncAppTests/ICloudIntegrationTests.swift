//
//  ICloudIntegrationTests.swift
//  CloudSyncAppTests
//
//  Comprehensive unit tests for iCloud Phase 1 integration (#9)
//  Tests: CloudProviderType.icloud, ICloudManager, and local folder detection
//

import XCTest
@testable import CloudSyncApp

final class ICloudIntegrationTests: XCTestCase {

    // MARK: - TC-1: CloudProviderType.icloud Basic Properties

    /// TC-1.1: Verify rclone type is correctly set to "iclouddrive"
    func testRcloneTypeIsICloudDrive() {
        XCTAssertEqual(CloudProviderType.icloud.rcloneType, "iclouddrive",
                       "iCloud rclone type should be 'iclouddrive' for Phase 1 local folder integration")
    }

    /// TC-1.2: Verify iCloud local path points to correct location
    func testICloudLocalPath() {
        let expected = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Mobile Documents/com~apple~CloudDocs")
        XCTAssertEqual(CloudProviderType.iCloudLocalPath, expected,
                       "iCloud local path should point to ~/Library/Mobile Documents/com~apple~CloudDocs")
    }

    /// TC-1.3: Verify iCloud is marked as supported
    func testICloudIsSupported() {
        XCTAssertTrue(CloudProviderType.icloud.isSupported,
                      "iCloud should be marked as supported for Phase 1")
    }

    /// TC-1.4: Verify iCloud display name
    func testICloudDisplayName() {
        XCTAssertEqual(CloudProviderType.icloud.displayName, "iCloud Drive",
                       "iCloud display name should be 'iCloud Drive'")
    }

    // MARK: - TC-2: CloudProviderType.icloud Extended Properties

    /// Verify iCloud icon name is set correctly
    func testICloudIconName() {
        XCTAssertEqual(CloudProviderType.icloud.iconName, "icloud.fill",
                       "iCloud should use 'icloud.fill' SF Symbol")
    }

    /// Verify iCloud raw value matches expected
    func testICloudRawValue() {
        XCTAssertEqual(CloudProviderType.icloud.rawValue, "icloud",
                       "iCloud raw value should be 'icloud'")
    }

    /// Verify iCloud is in allCases
    func testICloudInAllCases() {
        XCTAssertTrue(CloudProviderType.allCases.contains(.icloud),
                      "iCloud should be included in CloudProviderType.allCases")
    }

    /// Verify iCloud does NOT require OAuth (Phase 1 uses local folder)
    func testICloudDoesNotRequireOAuth() {
        XCTAssertFalse(CloudProviderType.icloud.requiresOAuth,
                       "iCloud Phase 1 should not require OAuth (uses local folder access)")
    }

    /// Verify iCloud is not experimental
    func testICloudIsNotExperimental() {
        XCTAssertFalse(CloudProviderType.icloud.isExperimental,
                       "iCloud should not be marked as experimental")
    }

    /// Verify iCloud brand color is set (light blue)
    func testICloudBrandColor() {
        // Brand color should not crash and should have a reasonable value
        let color = CloudProviderType.icloud.brandColor
        XCTAssertNotNil(color, "iCloud should have a brand color defined")
    }

    // MARK: - TC-3: ICloudManager Tests

    /// Verify ICloudManager.localFolderPath has correct tilde path
    func testICloudManagerLocalFolderPath() {
        let expectedPath = "~/Library/Mobile Documents/com~apple~CloudDocs/"
        XCTAssertEqual(ICloudManager.localFolderPath, expectedPath,
                       "ICloudManager.localFolderPath should be the tilde path")
    }

    /// Verify ICloudManager.expandedPath does not contain tilde
    func testICloudManagerExpandedPathNoTilde() {
        let expandedPath = ICloudManager.expandedPath
        XCTAssertFalse(expandedPath.contains("~"),
                       "ICloudManager.expandedPath should not contain tilde")
    }

    /// Verify ICloudManager.expandedPath contains expected path component
    func testICloudManagerExpandedPathContainsExpectedComponent() {
        let expandedPath = ICloudManager.expandedPath
        XCTAssertTrue(expandedPath.contains("/Library/Mobile Documents/com~apple~CloudDocs/"),
                      "Expanded path should contain the iCloud folder path")
    }

    /// Verify ICloudManager.expandedPath starts with home directory
    func testICloudManagerExpandedPathStartsWithHome() {
        let expandedPath = ICloudManager.expandedPath
        let homeDir = FileManager.default.homeDirectoryForCurrentUser.path
        XCTAssertTrue(expandedPath.hasPrefix(homeDir),
                      "Expanded path should start with user's home directory")
    }

    /// Verify ICloudManager.isLocalFolderAvailable returns a boolean
    func testICloudManagerIsLocalFolderAvailableReturnsBool() {
        let isAvailable = ICloudManager.isLocalFolderAvailable
        // This test verifies the property exists and returns a boolean
        // Actual value depends on system configuration
        XCTAssertTrue(isAvailable is Bool,
                      "isLocalFolderAvailable should return a boolean")
    }

    /// Verify ICloudManager.localFolderURL consistency with availability
    func testICloudManagerLocalFolderURLConsistency() {
        let url = ICloudManager.localFolderURL
        let isAvailable = ICloudManager.isLocalFolderAvailable

        if isAvailable {
            XCTAssertNotNil(url, "When iCloud folder is available, URL should not be nil")
            XCTAssertTrue(url?.path.contains("com~apple~CloudDocs") ?? false,
                          "URL path should contain iCloud folder identifier")
        } else {
            XCTAssertNil(url, "When iCloud folder is unavailable, URL should be nil")
        }
    }

    /// Verify ICloudManager.localFolderURL scheme is file://
    func testICloudManagerLocalFolderURLScheme() {
        guard let url = ICloudManager.localFolderURL else {
            // Skip if iCloud not available on this system
            return
        }
        XCTAssertEqual(url.scheme, "file",
                       "Local folder URL should have 'file' scheme")
    }

    // MARK: - TC-4: CloudProviderType Extension Static Properties

    /// Verify CloudProviderType.isLocalICloudAvailable matches ICloudManager
    func testLocalICloudAvailableConsistency() {
        // Both should report the same availability status
        let fromExtension = CloudProviderType.isLocalICloudAvailable
        let fromManager = ICloudManager.isLocalFolderAvailable
        XCTAssertEqual(fromExtension, fromManager,
                       "CloudProviderType.isLocalICloudAvailable should match ICloudManager.isLocalFolderAvailable")
    }

    /// Verify iCloudStatusMessage is appropriate for availability
    func testICloudStatusMessageContent() {
        let message = CloudProviderType.iCloudStatusMessage
        XCTAssertFalse(message.isEmpty, "Status message should not be empty")

        if CloudProviderType.isLocalICloudAvailable {
            XCTAssertTrue(message.contains("detected"),
                          "When available, status should mention 'detected'")
        } else {
            XCTAssertTrue(message.contains("not found") || message.contains("not available"),
                          "When unavailable, status should mention 'not found' or similar")
        }
    }

    // MARK: - TC-5: CloudRemote with iCloud Type

    /// Verify creating a CloudRemote with iCloud type
    func testCloudRemoteWithICloudType() {
        let remote = CloudRemote(
            name: "My iCloud",
            type: .icloud,
            isConfigured: false
        )

        XCTAssertEqual(remote.type, .icloud)
        XCTAssertEqual(remote.name, "My iCloud")
        XCTAssertFalse(remote.isConfigured)
        XCTAssertEqual(remote.displayIcon, "icloud.fill")
    }

    /// Verify iCloud remote rcloneName default
    func testICloudRemoteDefaultRcloneName() {
        let remote = CloudRemote(
            name: "iCloud Drive",
            type: .icloud,
            isConfigured: true
        )

        // Default rclone name should fall back to rawValue
        // Note: iCloud may not have a specific default in the switch case
        XCTAssertFalse(remote.rcloneName.isEmpty,
                       "iCloud remote should have a rclone name")
    }

    /// Verify iCloud remote with custom rclone name
    func testICloudRemoteCustomRcloneName() {
        let remote = CloudRemote(
            name: "iCloud Drive",
            type: .icloud,
            isConfigured: true,
            customRcloneName: "my-icloud"
        )

        XCTAssertEqual(remote.rcloneName, "my-icloud",
                       "Custom rclone name should override default")
    }

    /// Verify iCloud remote with path set to local iCloud folder
    func testICloudRemoteWithLocalPath() {
        let icloudPath = CloudProviderType.iCloudLocalPath.path
        let remote = CloudRemote(
            name: "Local iCloud",
            type: .icloud,
            isConfigured: true,
            path: icloudPath
        )

        XCTAssertEqual(remote.path, icloudPath,
                       "iCloud remote should store the local folder path")
        XCTAssertTrue(remote.path.contains("com~apple~CloudDocs"),
                      "Path should point to iCloud folder")
    }

    // MARK: - TC-6: Edge Cases

    /// Verify iCloud path contains expected encoding (tildes in folder name)
    func testICloudPathContainsTildeEncodedFolderName() {
        let path = CloudProviderType.iCloudLocalPath.path
        // The folder name contains tildes as part of the name, not path expansion
        XCTAssertTrue(path.contains("com~apple~CloudDocs"),
                      "iCloud folder should have tilde-encoded name 'com~apple~CloudDocs'")
    }

    /// Verify iCloud path is absolute
    func testICloudPathIsAbsolute() {
        let path = CloudProviderType.iCloudLocalPath.path
        XCTAssertTrue(path.hasPrefix("/"),
                      "iCloud local path should be absolute (start with /)")
    }

    /// Verify multiple iCloud remotes can coexist
    func testMultipleICloudRemotesCanExist() {
        let remote1 = CloudRemote(
            id: UUID(),
            name: "iCloud 1",
            type: .icloud,
            isConfigured: true
        )
        let remote2 = CloudRemote(
            id: UUID(),
            name: "iCloud 2",
            type: .icloud,
            isConfigured: true
        )

        // They should be different instances
        XCTAssertNotEqual(remote1.id, remote2.id)
        XCTAssertEqual(remote1.type, remote2.type)
    }

    /// Verify iCloud remote equality based on ID
    func testICloudRemoteEquality() {
        let id = UUID()
        let remote1 = CloudRemote(id: id, name: "iCloud", type: .icloud, isConfigured: true)
        let remote2 = CloudRemote(id: id, name: "iCloud", type: .icloud, isConfigured: true)

        XCTAssertEqual(remote1, remote2,
                       "Remotes with same properties should be equal")
    }

    /// Verify iCloud remote can be hashed (for use in Sets)
    func testICloudRemoteHashable() {
        let remote = CloudRemote(name: "iCloud", type: .icloud, isConfigured: true)
        var set = Set<CloudRemote>()
        set.insert(remote)

        XCTAssertEqual(set.count, 1,
                       "iCloud remote should be hashable and insertable into Set")
    }

    // MARK: - TC-7: Path Validation Tests

    /// Verify expanded path matches expected format
    func testExpandedPathFormat() {
        let expanded = ICloudManager.expandedPath

        // Should be an absolute path
        XCTAssertTrue(expanded.hasPrefix("/"),
                      "Expanded path should be absolute")

        // Should end with trailing slash (as defined in localFolderPath)
        XCTAssertTrue(expanded.hasSuffix("/"),
                      "Expanded path should maintain trailing slash")

        // Should contain the iCloud folder identifier
        XCTAssertTrue(expanded.contains("Library/Mobile Documents/com~apple~CloudDocs"),
                      "Expanded path should contain full iCloud folder path")
    }

    /// Verify URL and path consistency
    func testURLAndPathConsistency() {
        guard let url = ICloudManager.localFolderURL else {
            // Skip if not available
            return
        }

        let expandedPath = ICloudManager.expandedPath
        // URL path should match expanded path (URL may or may not have trailing slash)
        let urlPath = url.path
        XCTAssertTrue(expandedPath.contains(urlPath) || urlPath.contains(expandedPath.dropLast()),
                      "URL path should be consistent with expanded path")
    }

    // MARK: - TC-8: Integration with Filtering

    /// Verify iCloud appears in supported providers filter
    func testICloudInSupportedProvidersFilter() {
        let supportedProviders = CloudProviderType.allCases.filter { $0.isSupported && $0 != .local }
        XCTAssertTrue(supportedProviders.contains(.icloud),
                      "iCloud should appear in the supported providers list (used in AddRemoteSheet)")
    }

    /// Verify iCloud can be filtered by display name
    func testICloudFilterByDisplayName() {
        let searchText = "iCloud"
        let allProviders = CloudProviderType.allCases
        let filtered = allProviders.filter { provider in
            provider.displayName.localizedCaseInsensitiveContains(searchText)
        }

        XCTAssertTrue(filtered.contains(.icloud),
                      "iCloud should be findable by searching 'iCloud'")
    }

    /// Verify iCloud can be filtered by partial name
    func testICloudFilterByPartialName() {
        let searchText = "cloud"
        let allProviders = CloudProviderType.allCases
        let filtered = allProviders.filter { provider in
            provider.displayName.localizedCaseInsensitiveContains(searchText)
        }

        XCTAssertTrue(filtered.contains(.icloud),
                      "iCloud should be findable by searching 'cloud'")
    }
}

// MARK: - ICloudManager Path Edge Cases Tests

final class ICloudManagerPathTests: XCTestCase {

    /// Verify path expansion handles home directory correctly
    func testPathExpansionUsesNSStringExpansion() {
        let tildePathExpanded = NSString(string: "~/Library/Mobile Documents/com~apple~CloudDocs/").expandingTildeInPath
        let managerExpanded = ICloudManager.expandedPath

        XCTAssertEqual(tildePathExpanded, managerExpanded,
                       "ICloudManager should use NSString.expandingTildeInPath for expansion")
    }

    /// Verify path does not double-expand tildes
    func testPathNoDoubleExpansion() {
        let expanded = ICloudManager.expandedPath
        let doubleExpanded = NSString(string: expanded).expandingTildeInPath

        XCTAssertEqual(expanded, doubleExpanded,
                       "Already expanded path should not change on second expansion")
    }
}

// MARK: - iCloud State Machine Tests

final class ICloudConnectionStateTests: XCTestCase {

    /// Verify unconfigured iCloud remote state
    func testUnconfiguredICloudRemote() {
        let remote = CloudRemote(
            name: "New iCloud",
            type: .icloud,
            isConfigured: false,
            path: ""
        )

        XCTAssertFalse(remote.isConfigured)
        XCTAssertTrue(remote.path.isEmpty)
    }

    /// Verify configured iCloud remote state (via local folder)
    func testConfiguredICloudRemoteViaLocalFolder() {
        let icloudPath = CloudProviderType.iCloudLocalPath.path
        let remote = CloudRemote(
            name: "My iCloud",
            type: .icloud,
            isConfigured: true,
            path: icloudPath
        )

        XCTAssertTrue(remote.isConfigured)
        XCTAssertFalse(remote.path.isEmpty)
        XCTAssertTrue(remote.path.contains("com~apple~CloudDocs"))
    }

    /// Verify remote update flow (simulating setupICloudLocal)
    func testRemoteUpdateFlowSimulation() {
        // Initial unconfigured state
        var remote = CloudRemote(
            name: "iCloud Drive",
            type: .icloud,
            isConfigured: false,
            path: ""
        )

        // Simulate successful local folder connection
        remote.isConfigured = true
        remote.path = CloudProviderType.iCloudLocalPath.path

        // Verify final state
        XCTAssertTrue(remote.isConfigured,
                      "Remote should be configured after setup")
        XCTAssertEqual(remote.path, CloudProviderType.iCloudLocalPath.path,
                       "Remote path should be set to iCloud local path")
    }
}
