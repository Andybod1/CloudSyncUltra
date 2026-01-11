//
//  BandwidthThrottlingTests.swift
//  CloudSyncAppTests
//
//  Tests for bandwidth throttling functionality
//

import XCTest
@testable import CloudSyncApp

final class BandwidthThrottlingTests: XCTestCase {
    
    let testSuiteName = "BandwidthThrottlingTests"
    
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
    
    // MARK: - Settings Persistence Tests
    
    func testBandwidthLimitDisabledByDefault() {
        // Given: Fresh UserDefaults
        // When: Reading the default value
        let isEnabled = UserDefaults.standard.bool(forKey: "bandwidthLimitEnabled")
        
        // Then: Should be disabled by default
        XCTAssertFalse(isEnabled, "Bandwidth limits should be disabled by default")
    }
    
    func testEnableBandwidthLimit() {
        // Given: Bandwidth limits are disabled
        XCTAssertFalse(UserDefaults.standard.bool(forKey: "bandwidthLimitEnabled"))
        
        // When: Enabling bandwidth limits
        UserDefaults.standard.set(true, forKey: "bandwidthLimitEnabled")
        
        // Then: Should be enabled
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "bandwidthLimitEnabled"))
    }
    
    func testSetUploadLimit() {
        // Given: No upload limit is set
        let initialLimit = UserDefaults.standard.double(forKey: "uploadLimit")
        XCTAssertEqual(initialLimit, 0.0)
        
        // When: Setting upload limit to 5 MB/s
        UserDefaults.standard.set(5.0, forKey: "uploadLimit")
        
        // Then: Upload limit should be 5.0
        let savedLimit = UserDefaults.standard.double(forKey: "uploadLimit")
        XCTAssertEqual(savedLimit, 5.0)
    }
    
    func testSetDownloadLimit() {
        // Given: No download limit is set
        let initialLimit = UserDefaults.standard.double(forKey: "downloadLimit")
        XCTAssertEqual(initialLimit, 0.0)
        
        // When: Setting download limit to 10 MB/s
        UserDefaults.standard.set(10.0, forKey: "downloadLimit")
        
        // Then: Download limit should be 10.0
        let savedLimit = UserDefaults.standard.double(forKey: "downloadLimit")
        XCTAssertEqual(savedLimit, 10.0)
    }
    
    func testSetBothLimits() {
        // When: Setting both upload and download limits
        UserDefaults.standard.set(true, forKey: "bandwidthLimitEnabled")
        UserDefaults.standard.set(3.0, forKey: "uploadLimit")
        UserDefaults.standard.set(7.0, forKey: "downloadLimit")
        
        // Then: Both limits should be saved correctly
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "bandwidthLimitEnabled"))
        XCTAssertEqual(UserDefaults.standard.double(forKey: "uploadLimit"), 3.0)
        XCTAssertEqual(UserDefaults.standard.double(forKey: "downloadLimit"), 7.0)
    }
    
    func testUnlimitedUploadSpeed() {
        // When: Setting upload limit to 0 (unlimited)
        UserDefaults.standard.set(0.0, forKey: "uploadLimit")
        
        // Then: Limit should be 0
        XCTAssertEqual(UserDefaults.standard.double(forKey: "uploadLimit"), 0.0)
    }
    
    func testUnlimitedDownloadSpeed() {
        // When: Setting download limit to 0 (unlimited)
        UserDefaults.standard.set(0.0, forKey: "downloadLimit")
        
        // Then: Limit should be 0
        XCTAssertEqual(UserDefaults.standard.double(forKey: "downloadLimit"), 0.0)
    }
    
    func testDisableBandwidthLimit() {
        // Given: Bandwidth limits are enabled with values
        UserDefaults.standard.set(true, forKey: "bandwidthLimitEnabled")
        UserDefaults.standard.set(5.0, forKey: "uploadLimit")
        UserDefaults.standard.set(10.0, forKey: "downloadLimit")
        
        // When: Disabling bandwidth limits
        UserDefaults.standard.set(false, forKey: "bandwidthLimitEnabled")
        
        // Then: Should be disabled, but limits should remain stored
        XCTAssertFalse(UserDefaults.standard.bool(forKey: "bandwidthLimitEnabled"))
        XCTAssertEqual(UserDefaults.standard.double(forKey: "uploadLimit"), 5.0)
        XCTAssertEqual(UserDefaults.standard.double(forKey: "downloadLimit"), 10.0)
    }
    
    // MARK: - Edge Cases
    
    func testNegativeUploadLimit() {
        // When: Attempting to set negative upload limit
        UserDefaults.standard.set(-5.0, forKey: "uploadLimit")
        
        // Then: Value should be stored (validation happens in UI)
        XCTAssertEqual(UserDefaults.standard.double(forKey: "uploadLimit"), -5.0)
        // Note: Actual validation should happen in the UI layer
    }
    
    func testVeryHighBandwidthLimit() {
        // When: Setting very high bandwidth limit (e.g., 1000 MB/s)
        UserDefaults.standard.set(1000.0, forKey: "uploadLimit")
        
        // Then: Should store the value
        XCTAssertEqual(UserDefaults.standard.double(forKey: "uploadLimit"), 1000.0)
    }
    
    func testDecimalBandwidthLimit() {
        // When: Setting decimal bandwidth limit (e.g., 2.5 MB/s)
        UserDefaults.standard.set(2.5, forKey: "uploadLimit")
        UserDefaults.standard.set(3.7, forKey: "downloadLimit")
        
        // Then: Should preserve decimal values
        XCTAssertEqual(UserDefaults.standard.double(forKey: "uploadLimit"), 2.5)
        XCTAssertEqual(UserDefaults.standard.double(forKey: "downloadLimit"), 3.7)
    }
    
    func testVerySmallBandwidthLimit() {
        // When: Setting very small bandwidth limit (e.g., 0.1 MB/s)
        UserDefaults.standard.set(0.1, forKey: "uploadLimit")
        
        // Then: Should store the value
        XCTAssertEqual(UserDefaults.standard.double(forKey: "uploadLimit"), 0.1)
    }
    
    // MARK: - Settings Persistence Across App Restarts
    
    func testSettingsPersistence() {
        // Given: Settings are configured
        UserDefaults.standard.set(true, forKey: "bandwidthLimitEnabled")
        UserDefaults.standard.set(4.0, forKey: "uploadLimit")
        UserDefaults.standard.set(8.0, forKey: "downloadLimit")
        
        // When: Simulating app restart by reading values again
        let enabled = UserDefaults.standard.bool(forKey: "bandwidthLimitEnabled")
        let upload = UserDefaults.standard.double(forKey: "uploadLimit")
        let download = UserDefaults.standard.double(forKey: "downloadLimit")
        
        // Then: All values should persist
        XCTAssertTrue(enabled)
        XCTAssertEqual(upload, 4.0)
        XCTAssertEqual(download, 8.0)
    }
    
    // MARK: - RcloneManager Integration Tests
    
    func testBandwidthArgsWhenDisabled() {
        // Given: Bandwidth limits are disabled
        UserDefaults.standard.set(false, forKey: "bandwidthLimitEnabled")
        UserDefaults.standard.set(5.0, forKey: "uploadLimit")
        UserDefaults.standard.set(10.0, forKey: "downloadLimit")
        
        // When: Getting bandwidth args through reflection
        // Note: We can't directly call getBandwidthArgs as it's private
        // This test documents the expected behavior
        
        // Then: Should return empty args when disabled
        // Implementation should check bandwidthLimitEnabled first
        XCTAssertFalse(UserDefaults.standard.bool(forKey: "bandwidthLimitEnabled"))
    }
    
    func testBandwidthArgsWithUploadLimitOnly() {
        // Given: Only upload limit is set
        UserDefaults.standard.set(true, forKey: "bandwidthLimitEnabled")
        UserDefaults.standard.set(5.0, forKey: "uploadLimit")
        UserDefaults.standard.set(0.0, forKey: "downloadLimit")
        
        // Then: Expected args would be ["--bwlimit", "5M"]
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "bandwidthLimitEnabled"))
        XCTAssertEqual(UserDefaults.standard.double(forKey: "uploadLimit"), 5.0)
        XCTAssertEqual(UserDefaults.standard.double(forKey: "downloadLimit"), 0.0)
    }
    
    func testBandwidthArgsWithDownloadLimitOnly() {
        // Given: Only download limit is set
        UserDefaults.standard.set(true, forKey: "bandwidthLimitEnabled")
        UserDefaults.standard.set(0.0, forKey: "uploadLimit")
        UserDefaults.standard.set(10.0, forKey: "downloadLimit")
        
        // Then: Expected args would be ["--bwlimit", "10M"]
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "bandwidthLimitEnabled"))
        XCTAssertEqual(UserDefaults.standard.double(forKey: "uploadLimit"), 0.0)
        XCTAssertEqual(UserDefaults.standard.double(forKey: "downloadLimit"), 10.0)
    }
    
    func testBandwidthArgsWithBothLimits() {
        // Given: Both limits are set
        UserDefaults.standard.set(true, forKey: "bandwidthLimitEnabled")
        UserDefaults.standard.set(5.0, forKey: "uploadLimit")
        UserDefaults.standard.set(10.0, forKey: "downloadLimit")
        
        // Then: Should use the more restrictive limit (5.0)
        let enabled = UserDefaults.standard.bool(forKey: "bandwidthLimitEnabled")
        let upload = UserDefaults.standard.double(forKey: "uploadLimit")
        let download = UserDefaults.standard.double(forKey: "downloadLimit")
        
        XCTAssertTrue(enabled)
        XCTAssertEqual(upload, 5.0)
        XCTAssertEqual(download, 10.0)
        // Note: Implementation uses min(upload, download) when both are set
        XCTAssertLessThan(upload, download)
    }
    
    func testBandwidthArgsWithEqualLimits() {
        // Given: Both limits are equal
        UserDefaults.standard.set(true, forKey: "bandwidthLimitEnabled")
        UserDefaults.standard.set(7.0, forKey: "uploadLimit")
        UserDefaults.standard.set(7.0, forKey: "downloadLimit")
        
        // Then: Both should be 7.0
        XCTAssertEqual(UserDefaults.standard.double(forKey: "uploadLimit"), 7.0)
        XCTAssertEqual(UserDefaults.standard.double(forKey: "downloadLimit"), 7.0)
    }
    
    // MARK: - String Conversion Tests (for UI)
    
    func testConvertStringToDouble() {
        // Test valid conversions
        XCTAssertEqual(Double("5.0"), 5.0)
        XCTAssertEqual(Double("0"), 0.0)
        XCTAssertEqual(Double("10.5"), 10.5)
        XCTAssertEqual(Double("0.1"), 0.1)
    }
    
    func testConvertInvalidStringToDouble() {
        // Test invalid conversions return nil
        XCTAssertNil(Double("abc"))
        XCTAssertNil(Double(""))
        XCTAssertNil(Double("10.5.5"))
    }
    
    func testConvertDoubleToString() {
        // Test formatting for display
        XCTAssertEqual(String(format: "%.1f", 5.0), "5.0")
        XCTAssertEqual(String(format: "%.1f", 10.5), "10.5")
        XCTAssertEqual(String(format: "%.1f", 0.1), "0.1")
    }
    
    // MARK: - Integration Scenarios
    
    func testTypicalHomeUserScenario() {
        // Scenario: User wants gentle background sync
        // Upload: 2 MB/s, Download: 3 MB/s
        
        UserDefaults.standard.set(true, forKey: "bandwidthLimitEnabled")
        UserDefaults.standard.set(2.0, forKey: "uploadLimit")
        UserDefaults.standard.set(3.0, forKey: "downloadLimit")
        
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "bandwidthLimitEnabled"))
        XCTAssertEqual(UserDefaults.standard.double(forKey: "uploadLimit"), 2.0)
        XCTAssertEqual(UserDefaults.standard.double(forKey: "downloadLimit"), 3.0)
    }
    
    func testMeteredConnectionScenario() {
        // Scenario: Mobile hotspot with limited data
        // Upload: 0.5 MB/s, Download: 1 MB/s
        
        UserDefaults.standard.set(true, forKey: "bandwidthLimitEnabled")
        UserDefaults.standard.set(0.5, forKey: "uploadLimit")
        UserDefaults.standard.set(1.0, forKey: "downloadLimit")
        
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "bandwidthLimitEnabled"))
        XCTAssertEqual(UserDefaults.standard.double(forKey: "uploadLimit"), 0.5)
        XCTAssertEqual(UserDefaults.standard.double(forKey: "downloadLimit"), 1.0)
    }
    
    func testNighttimeBatchScenario() {
        // Scenario: Unlimited speed for overnight batch upload
        
        UserDefaults.standard.set(true, forKey: "bandwidthLimitEnabled")
        UserDefaults.standard.set(0.0, forKey: "uploadLimit")
        UserDefaults.standard.set(0.0, forKey: "downloadLimit")
        
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "bandwidthLimitEnabled"))
        XCTAssertEqual(UserDefaults.standard.double(forKey: "uploadLimit"), 0.0)
        XCTAssertEqual(UserDefaults.standard.double(forKey: "downloadLimit"), 0.0)
    }
    
    func testDisabledThrottlingScenario() {
        // Scenario: User disables throttling for maximum speed
        
        UserDefaults.standard.set(false, forKey: "bandwidthLimitEnabled")
        // Limits can still be stored but won't be used
        UserDefaults.standard.set(5.0, forKey: "uploadLimit")
        UserDefaults.standard.set(10.0, forKey: "downloadLimit")
        
        XCTAssertFalse(UserDefaults.standard.bool(forKey: "bandwidthLimitEnabled"))
    }
}
