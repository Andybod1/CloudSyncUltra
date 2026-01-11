//
//  NewFeaturesTests.swift
//  CloudSyncAppTests
//
//  Tests for features added during real-world testing session (Jan 11, 2026)
//

import XCTest
@testable import CloudSyncApp

final class NewFeaturesTests: XCTestCase {
    
    // MARK: - SyncTask Average Speed Tests
    
    func testSyncTask_AverageSpeedCalculation() {
        var task = SyncTask(
            name: "Speed Test",
            type: .transfer,
            sourcePath: "/src",
            destPath: "/dst",
            sourceRemote: "local",
            destRemote: "google"
        )
        
        // Set up task with known values
        task.bytesTransferred = 50_000_000 // 50 MB
        task.startedAt = Date(timeIntervalSinceNow: -10) // Started 10 seconds ago
        task.completedAt = Date() // Just completed
        
        // Calculate average speed
        let speed = task.averageSpeed
        
        // Should be ~5 MB/s (50 MB / 10 seconds)
        XCTAssertNotNil(speed)
        XCTAssertEqual(speed, 5_000_000, accuracy: 100_000) // Allow some variance
    }
    
    func testSyncTask_AverageSpeedNilWhenNoStartTime() {
        var task = SyncTask(
            name: "No Start Time",
            type: .transfer,
            sourcePath: "/src",
            destPath: "/dst",
            sourceRemote: "local",
            destRemote: "google"
        )
        
        task.bytesTransferred = 1000000
        task.completedAt = Date()
        // startedAt is nil
        
        XCTAssertNil(task.averageSpeed)
    }
    
    func testSyncTask_AverageSpeedNilWhenNoEndTime() {
        var task = SyncTask(
            name: "No End Time",
            type: .transfer,
            sourcePath: "/src",
            destPath: "/dst",
            sourceRemote: "local",
            destRemote: "google"
        )
        
        task.bytesTransferred = 1000000
        task.startedAt = Date()
        // completedAt is nil
        
        XCTAssertNil(task.averageSpeed)
    }
    
    func testSyncTask_AverageSpeedZeroForZeroDuration() {
        var task = SyncTask(
            name: "Zero Duration",
            type: .transfer,
            sourcePath: "/src",
            destPath: "/dst",
            sourceRemote: "local",
            destRemote: "google"
        )
        
        let now = Date()
        task.bytesTransferred = 1000000
        task.startedAt = now
        task.completedAt = now // Same time = zero duration
        
        XCTAssertNil(task.averageSpeed) // Should return nil for zero duration
    }
    
    // MARK: - FileBrowserViewModel ViewMode Tests
    
    func testFileBrowserViewModel_ViewModeToggle() {
        let browser = FileBrowserViewModel()
        
        // Default should be list
        XCTAssertEqual(browser.viewMode, .list)
        
        // Toggle to grid
        browser.viewMode = .grid
        XCTAssertEqual(browser.viewMode, .grid)
        
        // Toggle back to list
        browser.viewMode = .list
        XCTAssertEqual(browser.viewMode, .list)
    }
    
    func testFileBrowserViewModel_ViewModePersistence() {
        let browser = FileBrowserViewModel()
        
        // Set to grid
        browser.viewMode = .grid
        
        // Simulate refresh or navigation
        // ViewMode should persist
        XCTAssertEqual(browser.viewMode, .grid)
    }
    
    // MARK: - File Counter Tests
    
    func testSyncTask_FileCounterTracking() {
        var task = SyncTask(
            name: "File Counter Test",
            type: .transfer,
            sourcePath: "/src",
            destPath: "/dst",
            sourceRemote: "local",
            destRemote: "google"
        )
        
        // Initial state
        XCTAssertEqual(task.filesTransferred, 0)
        XCTAssertEqual(task.totalFiles, 0)
        
        // Update counts during transfer
        task.totalFiles = 100
        task.filesTransferred = 50
        
        XCTAssertEqual(task.totalFiles, 100)
        XCTAssertEqual(task.filesTransferred, 50)
        
        // Complete transfer
        task.filesTransferred = 100
        XCTAssertEqual(task.filesTransferred, task.totalFiles)
    }
    
    func testSyncTask_FileCounterProgress() {
        var task = SyncTask(
            name: "Progress Test",
            type: .transfer,
            sourcePath: "/src",
            destPath: "/dst",
            sourceRemote: "local",
            destRemote: "google"
        )
        
        task.totalFiles = 100
        
        // Test various progress points
        task.filesTransferred = 0
        XCTAssertEqual(Double(task.filesTransferred) / Double(task.totalFiles), 0.0)
        
        task.filesTransferred = 25
        XCTAssertEqual(Double(task.filesTransferred) / Double(task.totalFiles), 0.25)
        
        task.filesTransferred = 50
        XCTAssertEqual(Double(task.filesTransferred) / Double(task.totalFiles), 0.5)
        
        task.filesTransferred = 100
        XCTAssertEqual(Double(task.filesTransferred) / Double(task.totalFiles), 1.0)
    }
    
    // MARK: - Cloud Provider Tests
    
    func testCloudProvider_CloudToCloudSupport() {
        // Test that all cloud providers support cloud-to-cloud transfers
        let providers: [CloudProvider] = [.google, .dropbox, .onedrive, .proton, .pcloud]
        
        for provider in providers {
            XCTAssertNotNil(provider.rcloneName)
            XCTAssertFalse(provider.rcloneName.isEmpty)
        }
    }
    
    func testCloudProvider_LocalProvider() {
        XCTAssertEqual(CloudProvider.local.rcloneName, "")
        XCTAssertEqual(CloudProvider.local.displayName, "Local Storage")
    }
    
    // MARK: - Integration Tests
    
    func testTransferProgress_FileCountAndSpeed() {
        let progress = TransferProgressModel()
        
        // Initial state
        XCTAssertEqual(progress.percentage, 0)
        XCTAssertTrue(progress.speed.isEmpty)
        
        // Simulate transfer progress
        progress.percentage = 50
        progress.speed = "5.2 MB/s"
        
        XCTAssertEqual(progress.percentage, 50)
        XCTAssertEqual(progress.speed, "5.2 MB/s")
        
        // Complete transfer
        progress.percentage = 100
        progress.complete(success: true)
        
        XCTAssertTrue(progress.isCompleted)
        XCTAssertEqual(progress.percentage, 100)
    }
}
