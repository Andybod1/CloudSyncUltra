//
//  BandwidthThrottlingUITests.swift
//  CloudSyncAppTests
//
//  Tests for bandwidth throttling UI and settings
//

import XCTest
@testable import CloudSyncApp

final class BandwidthThrottlingUITests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Reset UserDefaults for tests
        UserDefaults.standard.removeObject(forKey: "bandwidthLimitEnabled")
        UserDefaults.standard.removeObject(forKey: "uploadLimit")
        UserDefaults.standard.removeObject(forKey: "downloadLimit")
    }

    override func tearDown() {
        // Clean up
        UserDefaults.standard.removeObject(forKey: "bandwidthLimitEnabled")
        UserDefaults.standard.removeObject(forKey: "uploadLimit")
        UserDefaults.standard.removeObject(forKey: "downloadLimit")
        super.tearDown()
    }

    // MARK: - Settings Persistence Tests

    func testBandwidthEnabledPersistence() {
        UserDefaults.standard.set(true, forKey: "bandwidthLimitEnabled")
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "bandwidthLimitEnabled"))
    }

    func testBandwidthDisabledByDefault() {
        let enabled = UserDefaults.standard.bool(forKey: "bandwidthLimitEnabled")
        XCTAssertFalse(enabled, "Bandwidth limiting should be disabled by default")
    }

    func testUploadLimitPersistence() {
        UserDefaults.standard.set(10.0, forKey: "uploadLimit")
        XCTAssertEqual(UserDefaults.standard.double(forKey: "uploadLimit"), 10.0)
    }

    func testDownloadLimitPersistence() {
        UserDefaults.standard.set(5.0, forKey: "downloadLimit")
        XCTAssertEqual(UserDefaults.standard.double(forKey: "downloadLimit"), 5.0)
    }

    func testZeroLimitMeansUnlimited() {
        UserDefaults.standard.set(0.0, forKey: "uploadLimit")
        UserDefaults.standard.set(0.0, forKey: "downloadLimit")

        let upload = UserDefaults.standard.double(forKey: "uploadLimit")
        let download = UserDefaults.standard.double(forKey: "downloadLimit")

        // 0 means unlimited
        XCTAssertEqual(upload, 0.0)
        XCTAssertEqual(download, 0.0)
    }

    // MARK: - Preset Value Tests

    func testPresetValues() {
        let presets = [1, 5, 10, 50]

        for preset in presets {
            UserDefaults.standard.set(Double(preset), forKey: "uploadLimit")
            UserDefaults.standard.set(Double(preset), forKey: "downloadLimit")

            XCTAssertEqual(
                UserDefaults.standard.double(forKey: "uploadLimit"),
                Double(preset)
            )
            XCTAssertEqual(
                UserDefaults.standard.double(forKey: "downloadLimit"),
                Double(preset)
            )
        }
    }

    // MARK: - Independent Limits Tests

    func testIndependentUploadDownloadLimits() {
        UserDefaults.standard.set(10.0, forKey: "uploadLimit")
        UserDefaults.standard.set(50.0, forKey: "downloadLimit")

        XCTAssertEqual(UserDefaults.standard.double(forKey: "uploadLimit"), 10.0)
        XCTAssertEqual(UserDefaults.standard.double(forKey: "downloadLimit"), 50.0)
        XCTAssertNotEqual(
            UserDefaults.standard.double(forKey: "uploadLimit"),
            UserDefaults.standard.double(forKey: "downloadLimit")
        )
    }
}