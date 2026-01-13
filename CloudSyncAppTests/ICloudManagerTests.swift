import XCTest
@testable import CloudSyncApp

final class ICloudManagerTests: XCTestCase {

    func testLocalFolderPath() {
        let expectedPath = "~/Library/Mobile Documents/com~apple~CloudDocs/"
        XCTAssertEqual(ICloudManager.localFolderPath, expectedPath)
    }

    func testExpandedPath() {
        let expandedPath = ICloudManager.expandedPath
        XCTAssertFalse(expandedPath.contains("~"), "Expanded path should not contain tilde")
        XCTAssertTrue(expandedPath.contains("/Library/Mobile Documents/com~apple~CloudDocs/"))
    }

    func testIsLocalFolderAvailable() {
        // This test simply verifies the method returns a boolean
        // Actual availability depends on the system setup
        let isAvailable = ICloudManager.isLocalFolderAvailable
        XCTAssertTrue(isAvailable is Bool)
    }

    func testLocalFolderURL() {
        let url = ICloudManager.localFolderURL

        if ICloudManager.isLocalFolderAvailable {
            XCTAssertNotNil(url)
            XCTAssertEqual(url?.absoluteString, "file://" + ICloudManager.expandedPath)
        } else {
            XCTAssertNil(url)
        }
    }
}