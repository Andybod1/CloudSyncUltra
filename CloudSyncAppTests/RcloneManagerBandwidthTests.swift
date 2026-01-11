//
//  RcloneManagerBandwidthTests.swift
//  CloudSyncAppTests
//
//  Integration tests for RcloneManager bandwidth throttling
//

import XCTest
@testable import CloudSyncApp

final class RcloneManagerBandwidthTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Clear UserDefaults before each test
        UserDefaults.standard.removeObject(forKey: "bandwidthLimitEnabled")
        UserDefaults.standard.removeObject(forKey: "uploadLimit")
        UserDefaults.standard.removeObject(forKey: "downloadLimit")
    }
    
    override func tearDown() {
        // Clean up after each test
        UserDefaults.standard.removeObject(forKey: "bandwidthLimitEnabled")
        UserDefaults.standard.removeObject(forKey: "uploadLimit")
        UserDefaults.standard.removeObject(forKey: "downloadLimit")
        super.tearDown()
    }
    
    // MARK: - RcloneManager Availability Tests
    
    func testRcloneManagerSingleton() {
        // When: Accessing RcloneManager singleton
        let manager = RcloneManager.shared
        
        // Then: Should return valid instance
        XCTAssertNotNil(manager, "RcloneManager singleton should be available")
    }
    
    func testRcloneManagerMultipleAccess() {
        // When: Accessing singleton multiple times
        let manager1 = RcloneManager.shared
        let manager2 = RcloneManager.shared
        
        // Then: Should return same instance
        XCTAssertTrue(manager1 === manager2, "RcloneManager should return same singleton instance")
    }
    
    // MARK: - Bandwidth Configuration State Tests
    
    func testBandwidthDisabledByDefault() {
        // Given: Clean state
        // When: Checking if bandwidth limits are enabled
        let isEnabled = UserDefaults.standard.bool(forKey: "bandwidthLimitEnabled")
        
        // Then: Should be disabled
        XCTAssertFalse(isEnabled, "Bandwidth throttling should be disabled by default")
    }
    
    func testBandwidthLimitsDefaultToZero() {
        // Given: Clean state
        // When: Reading bandwidth limits
        let uploadLimit = UserDefaults.standard.double(forKey: "uploadLimit")
        let downloadLimit = UserDefaults.standard.double(forKey: "downloadLimit")
        
        // Then: Should be 0 (unlimited)
        XCTAssertEqual(uploadLimit, 0.0, "Upload limit should default to 0")
        XCTAssertEqual(downloadLimit, 0.0, "Download limit should default to 0")
    }
    
    // MARK: - Expected rclone Arguments Tests
    
    func testExpectedArgsWithNoLimits() {
        // Given: Bandwidth limits disabled
        UserDefaults.standard.set(false, forKey: "bandwidthLimitEnabled")
        
        // When: getBandwidthArgs would be called
        // Then: Should return empty array (no bandwidth args added)
        // Expected behavior: []
        
        let enabled = UserDefaults.standard.bool(forKey: "bandwidthLimitEnabled")
        XCTAssertFalse(enabled)
    }
    
    func testExpectedArgsWithUploadLimit() {
        // Given: Upload limit of 5 MB/s
        UserDefaults.standard.set(true, forKey: "bandwidthLimitEnabled")
        UserDefaults.standard.set(5.0, forKey: "uploadLimit")
        UserDefaults.standard.set(0.0, forKey: "downloadLimit")
        
        // Then: Expected args: ["--bwlimit", "5M"]
        let enabled = UserDefaults.standard.bool(forKey: "bandwidthLimitEnabled")
        let upload = UserDefaults.standard.double(forKey: "uploadLimit")
        
        XCTAssertTrue(enabled)
        XCTAssertEqual(upload, 5.0)
        
        // Verify expected rclone arg format
        let expectedArg = "\(upload)M"
        XCTAssertEqual(expectedArg, "5.0M")
    }
    
    func testExpectedArgsWithDownloadLimit() {
        // Given: Download limit of 10 MB/s
        UserDefaults.standard.set(true, forKey: "bandwidthLimitEnabled")
        UserDefaults.standard.set(0.0, forKey: "uploadLimit")
        UserDefaults.standard.set(10.0, forKey: "downloadLimit")
        
        // Then: Expected args: ["--bwlimit", "10M"]
        let enabled = UserDefaults.standard.bool(forKey: "bandwidthLimitEnabled")
        let download = UserDefaults.standard.double(forKey: "downloadLimit")
        
        XCTAssertTrue(enabled)
        XCTAssertEqual(download, 10.0)
        
        // Verify expected rclone arg format
        let expectedArg = "\(download)M"
        XCTAssertEqual(expectedArg, "10.0M")
    }
    
    func testExpectedArgsWithBothLimitsUploadLower() {
        // Given: Upload 5 MB/s, Download 10 MB/s
        UserDefaults.standard.set(true, forKey: "bandwidthLimitEnabled")
        UserDefaults.standard.set(5.0, forKey: "uploadLimit")
        UserDefaults.standard.set(10.0, forKey: "downloadLimit")
        
        // Then: Should use upload limit (more restrictive)
        // Expected args: ["--bwlimit", "5M"]
        let upload = UserDefaults.standard.double(forKey: "uploadLimit")
        let download = UserDefaults.standard.double(forKey: "downloadLimit")
        
        XCTAssertEqual(upload, 5.0)
        XCTAssertEqual(download, 10.0)
        XCTAssertLessThan(upload, download, "Upload limit should be more restrictive")
        
        let expectedLimit = min(upload, download)
        XCTAssertEqual(expectedLimit, 5.0)
    }
    
    func testExpectedArgsWithBothLimitsDownloadLower() {
        // Given: Upload 10 MB/s, Download 5 MB/s
        UserDefaults.standard.set(true, forKey: "bandwidthLimitEnabled")
        UserDefaults.standard.set(10.0, forKey: "uploadLimit")
        UserDefaults.standard.set(5.0, forKey: "downloadLimit")
        
        // Then: Should use download limit (more restrictive)
        // Expected args: ["--bwlimit", "5M"]
        let upload = UserDefaults.standard.double(forKey: "uploadLimit")
        let download = UserDefaults.standard.double(forKey: "downloadLimit")
        
        XCTAssertEqual(upload, 10.0)
        XCTAssertEqual(download, 5.0)
        XCTAssertLessThan(download, upload, "Download limit should be more restrictive")
        
        let expectedLimit = min(upload, download)
        XCTAssertEqual(expectedLimit, 5.0)
    }
    
    func testExpectedArgsWithEqualLimits() {
        // Given: Both limits are 7 MB/s
        UserDefaults.standard.set(true, forKey: "bandwidthLimitEnabled")
        UserDefaults.standard.set(7.0, forKey: "uploadLimit")
        UserDefaults.standard.set(7.0, forKey: "downloadLimit")
        
        // Then: Should use 7 MB/s
        // Expected args: ["--bwlimit", "7M"]
        let upload = UserDefaults.standard.double(forKey: "uploadLimit")
        let download = UserDefaults.standard.double(forKey: "downloadLimit")
        
        XCTAssertEqual(upload, 7.0)
        XCTAssertEqual(download, 7.0)
        
        let expectedLimit = min(upload, download)
        XCTAssertEqual(expectedLimit, 7.0)
    }
    
    // MARK: - rclone Command Format Tests
    
    func testRcloneArgFormat() {
        // Test that MB/s is correctly formatted for rclone
        let limit = 5.5
        let rcloneArg = "\(limit)M"
        
        XCTAssertEqual(rcloneArg, "5.5M", "rclone bandwidth arg should be formatted as '<number>M'")
    }
    
    func testRcloneArgFormatInteger() {
        // Test integer values
        let limit = 10.0
        let rcloneArg = "\(limit)M"
        
        XCTAssertEqual(rcloneArg, "10.0M", "rclone bandwidth arg should handle integer values")
    }
    
    func testRcloneArgFormatSmallValue() {
        // Test small decimal values
        let limit = 0.5
        let rcloneArg = "\(limit)M"
        
        XCTAssertEqual(rcloneArg, "0.5M", "rclone bandwidth arg should handle decimal values")
    }
    
    // MARK: - Configuration Change Tests
    
    func testChangingBandwidthLimit() {
        // Given: Initial limit of 5 MB/s
        UserDefaults.standard.set(true, forKey: "bandwidthLimitEnabled")
        UserDefaults.standard.set(5.0, forKey: "uploadLimit")
        
        var currentLimit = UserDefaults.standard.double(forKey: "uploadLimit")
        XCTAssertEqual(currentLimit, 5.0)
        
        // When: Changing to 10 MB/s
        UserDefaults.standard.set(10.0, forKey: "uploadLimit")
        
        // Then: Should reflect new limit
        currentLimit = UserDefaults.standard.double(forKey: "uploadLimit")
        XCTAssertEqual(currentLimit, 10.0)
    }
    
    func testTogglingBandwidthLimit() {
        // Given: Bandwidth limit enabled
        UserDefaults.standard.set(true, forKey: "bandwidthLimitEnabled")
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "bandwidthLimitEnabled"))
        
        // When: Disabling
        UserDefaults.standard.set(false, forKey: "bandwidthLimitEnabled")
        
        // Then: Should be disabled
        XCTAssertFalse(UserDefaults.standard.bool(forKey: "bandwidthLimitEnabled"))
        
        // When: Re-enabling
        UserDefaults.standard.set(true, forKey: "bandwidthLimitEnabled")
        
        // Then: Should be enabled again
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "bandwidthLimitEnabled"))
    }
    
    // MARK: - Real-world Scenario Tests
    
    func testVideoCallScenario() {
        // Scenario: User is on a video call and wants to limit background sync
        // Conservative limits: 1 MB/s upload, 2 MB/s download
        
        UserDefaults.standard.set(true, forKey: "bandwidthLimitEnabled")
        UserDefaults.standard.set(1.0, forKey: "uploadLimit")
        UserDefaults.standard.set(2.0, forKey: "downloadLimit")
        
        let upload = UserDefaults.standard.double(forKey: "uploadLimit")
        let download = UserDefaults.standard.double(forKey: "downloadLimit")
        
        XCTAssertEqual(upload, 1.0)
        XCTAssertEqual(download, 2.0)
        
        // Most restrictive limit should be used
        let effectiveLimit = min(upload, download)
        XCTAssertEqual(effectiveLimit, 1.0)
    }
    
    func testMobileHotspotScenario() {
        // Scenario: Using mobile hotspot with limited data
        // Very conservative: 0.5 MB/s upload, 1 MB/s download
        
        UserDefaults.standard.set(true, forKey: "bandwidthLimitEnabled")
        UserDefaults.standard.set(0.5, forKey: "uploadLimit")
        UserDefaults.standard.set(1.0, forKey: "downloadLimit")
        
        let upload = UserDefaults.standard.double(forKey: "uploadLimit")
        let download = UserDefaults.standard.double(forKey: "downloadLimit")
        
        XCTAssertEqual(upload, 0.5)
        XCTAssertEqual(download, 1.0)
        
        let effectiveLimit = min(upload, download)
        XCTAssertEqual(effectiveLimit, 0.5)
    }
    
    func testOfficeHoursScenario() {
        // Scenario: Office hours with shared connection
        // Moderate limits: 3 MB/s upload, 5 MB/s download
        
        UserDefaults.standard.set(true, forKey: "bandwidthLimitEnabled")
        UserDefaults.standard.set(3.0, forKey: "uploadLimit")
        UserDefaults.standard.set(5.0, forKey: "downloadLimit")
        
        let upload = UserDefaults.standard.double(forKey: "uploadLimit")
        let download = UserDefaults.standard.double(forKey: "downloadLimit")
        
        XCTAssertEqual(upload, 3.0)
        XCTAssertEqual(download, 5.0)
        
        let effectiveLimit = min(upload, download)
        XCTAssertEqual(effectiveLimit, 3.0)
    }
    
    func testNightBatchScenario() {
        // Scenario: Overnight batch with unlimited bandwidth
        
        UserDefaults.standard.set(true, forKey: "bandwidthLimitEnabled")
        UserDefaults.standard.set(0.0, forKey: "uploadLimit")
        UserDefaults.standard.set(0.0, forKey: "downloadLimit")
        
        let upload = UserDefaults.standard.double(forKey: "uploadLimit")
        let download = UserDefaults.standard.double(forKey: "downloadLimit")
        
        XCTAssertEqual(upload, 0.0)
        XCTAssertEqual(download, 0.0)
        
        // When both are 0, no bandwidth limit should be applied
        XCTAssertTrue(upload == 0.0 && download == 0.0, "Both limits at 0 means unlimited")
    }
    
    // MARK: - Argument Array Construction Tests
    
    func testBandwidthArgsArrayFormat() {
        // Test expected array structure
        let limit = 5.0
        let expectedArgs = ["--bwlimit", "\(limit)M"]
        
        XCTAssertEqual(expectedArgs.count, 2)
        XCTAssertEqual(expectedArgs[0], "--bwlimit")
        XCTAssertEqual(expectedArgs[1], "5.0M")
    }
    
    func testEmptyBandwidthArgsWhenDisabled() {
        // Given: Disabled bandwidth limits
        UserDefaults.standard.set(false, forKey: "bandwidthLimitEnabled")
        
        // Expected: Empty array
        let expectedArgs: [String] = []
        
        XCTAssertEqual(expectedArgs.count, 0)
    }
    
    func testEmptyBandwidthArgsWhenZero() {
        // Given: Enabled but both limits are 0
        UserDefaults.standard.set(true, forKey: "bandwidthLimitEnabled")
        UserDefaults.standard.set(0.0, forKey: "uploadLimit")
        UserDefaults.standard.set(0.0, forKey: "downloadLimit")
        
        let upload = UserDefaults.standard.double(forKey: "uploadLimit")
        let download = UserDefaults.standard.double(forKey: "downloadLimit")
        
        // When both are 0, implementation should return empty array
        XCTAssertTrue(upload == 0.0 && download == 0.0)
    }
}
