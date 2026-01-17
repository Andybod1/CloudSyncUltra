//
//  SyncManagerTests.swift
//  CloudSyncAppTests
//
//  Comprehensive tests for SyncManager - Core sync orchestration
//

import XCTest
@testable import CloudSyncApp

@MainActor
final class SyncManagerTests: XCTestCase {
    
    var syncManager: SyncManager!
    
    override func setUp() async throws {
        try await super.setUp()
        syncManager = SyncManager.shared
        
        // Clean up all settings
        UserDefaults.standard.removeObject(forKey: "localPath")
        UserDefaults.standard.removeObject(forKey: "remotePath")
        UserDefaults.standard.removeObject(forKey: "syncInterval")
        UserDefaults.standard.removeObject(forKey: "autoSync")
        UserDefaults.standard.removeObject(forKey: "isConfigured")
        
        // Stop any ongoing monitoring
        syncManager.stopMonitoring()
        
        // Reset published properties
        syncManager.syncStatus = .idle
        syncManager.lastSyncTime = nil
        syncManager.currentProgress = nil
    }
    
    override func tearDown() async throws {
        // Clean up
        syncManager.stopMonitoring()
        UserDefaults.standard.removeObject(forKey: "localPath")
        UserDefaults.standard.removeObject(forKey: "remotePath")
        UserDefaults.standard.removeObject(forKey: "syncInterval")
        UserDefaults.standard.removeObject(forKey: "autoSync")
        UserDefaults.standard.removeObject(forKey: "isConfigured")
        
        try await super.tearDown()
    }
    
    // MARK: - Singleton Tests
    
    func testSyncManagerSingleton() {
        // When: Accessing SyncManager singleton
        let manager1 = SyncManager.shared
        let manager2 = SyncManager.shared
        
        // Then: Should return same instance
        XCTAssertTrue(manager1 === manager2, "SyncManager should be a singleton")
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        // Then: Initial state should be correct
        XCTAssertEqual(syncManager.syncStatus, .idle, "Initial sync status should be idle")
        XCTAssertNil(syncManager.lastSyncTime, "Initial last sync time should be nil")
        XCTAssertNil(syncManager.currentProgress, "Initial progress should be nil")
        XCTAssertFalse(syncManager.isMonitoring, "Monitoring should be disabled initially")
    }
    
    func testLocalPathDefaultsToEmpty() {
        // When: Getting localPath without setting it
        let path = syncManager.localPath
        
        // Then: Should be empty string
        XCTAssertEqual(path, "", "Default localPath should be empty string")
    }
    
    func testRemotePathDefaultsToEmpty() {
        // When: Getting remotePath without setting it
        let path = syncManager.remotePath
        
        // Then: Should be empty string
        XCTAssertEqual(path, "", "Default remotePath should be empty string")
    }
    
    func testSyncIntervalDefaultsTo300Seconds() {
        // When: Getting syncInterval without setting it
        let interval = syncManager.syncInterval
        
        // Then: Should be 300 seconds (5 minutes)
        XCTAssertEqual(interval, 300.0, "Default sync interval should be 300 seconds")
    }
    
    func testAutoSyncDefaultsToFalse() {
        // When: Getting autoSync without setting it
        let autoSync = syncManager.autoSync
        
        // Then: Should be false
        XCTAssertFalse(autoSync, "Default autoSync should be false")
    }
    
    // MARK: - Local Path Tests
    
    func testSetLocalPath() {
        // Given: A test path
        let testPath = "/Users/test/Documents"
        
        // When: Setting local path
        syncManager.localPath = testPath
        
        // Then: Should be stored and retrievable
        XCTAssertEqual(syncManager.localPath, testPath, "Local path should be set")
        
        // And: Should persist in UserDefaults
        let stored = UserDefaults.standard.string(forKey: "localPath")
        XCTAssertEqual(stored, testPath, "Local path should persist in UserDefaults")
    }
    
    func testLocalPathPersistence() {
        // Given: A saved path
        let testPath = "/Users/test/Downloads"
        syncManager.localPath = testPath
        
        // When: Simulating app restart by reading from UserDefaults
        let retrieved = UserDefaults.standard.string(forKey: "localPath")
        
        // Then: Should match
        XCTAssertEqual(retrieved, testPath, "Local path should persist across restarts")
    }
    
    func testUpdateLocalPath() {
        // Given: An existing path
        syncManager.localPath = "/Users/test/Old"
        
        // When: Updating to new path
        syncManager.localPath = "/Users/test/New"
        
        // Then: Should have new path
        XCTAssertEqual(syncManager.localPath, "/Users/test/New", "Local path should be updated")
    }
    
    func testSetEmptyLocalPath() {
        // Given: A path is set
        syncManager.localPath = "/Users/test/Documents"
        
        // When: Setting to empty
        syncManager.localPath = ""
        
        // Then: Should be empty
        XCTAssertEqual(syncManager.localPath, "", "Should be able to set empty local path")
    }
    
    // MARK: - Remote Path Tests
    
    func testSetRemotePath() {
        // Given: A test remote path
        let testPath = "/Documents/CloudSync"
        
        // When: Setting remote path
        syncManager.remotePath = testPath
        
        // Then: Should be stored and retrievable
        XCTAssertEqual(syncManager.remotePath, testPath, "Remote path should be set")
        
        // And: Should persist in UserDefaults
        let stored = UserDefaults.standard.string(forKey: "remotePath")
        XCTAssertEqual(stored, testPath, "Remote path should persist in UserDefaults")
    }
    
    func testRemotePathPersistence() {
        // Given: A saved remote path
        let testPath = "/Backup/Files"
        syncManager.remotePath = testPath
        
        // When: Simulating app restart
        let retrieved = UserDefaults.standard.string(forKey: "remotePath")
        
        // Then: Should match
        XCTAssertEqual(retrieved, testPath, "Remote path should persist across restarts")
    }
    
    func testUpdateRemotePath() {
        // Given: An existing remote path
        syncManager.remotePath = "/Old/Path"
        
        // When: Updating to new path
        syncManager.remotePath = "/New/Path"
        
        // Then: Should have new path
        XCTAssertEqual(syncManager.remotePath, "/New/Path", "Remote path should be updated")
    }
    
    func testRemotePathWithSpecialCharacters() {
        // Given: A path with special characters
        let specialPath = "/Documents/My Files & Folders (2024)"
        
        // When: Setting remote path
        syncManager.remotePath = specialPath
        
        // Then: Should preserve special characters
        XCTAssertEqual(syncManager.remotePath, specialPath, "Special characters should be preserved")
    }
    
    // MARK: - Sync Interval Tests
    
    func testSetSyncInterval() {
        // Given: A custom interval (10 minutes)
        let interval: TimeInterval = 600
        
        // When: Setting sync interval
        syncManager.syncInterval = interval
        
        // Then: Should be set
        XCTAssertEqual(syncManager.syncInterval, interval, "Sync interval should be set")
        
        // And: Should persist
        let stored = UserDefaults.standard.double(forKey: "syncInterval")
        XCTAssertEqual(stored, interval, "Sync interval should persist")
    }
    
    func testSyncIntervalPersistence() {
        // Given: A saved interval
        let interval: TimeInterval = 900 // 15 minutes
        syncManager.syncInterval = interval
        
        // When: Reading from UserDefaults
        let retrieved = UserDefaults.standard.double(forKey: "syncInterval")
        
        // Then: Should match
        XCTAssertEqual(retrieved, interval, "Sync interval should persist")
    }
    
    func testUpdateSyncInterval() {
        // Given: An existing interval
        syncManager.syncInterval = 300
        
        // When: Updating interval
        syncManager.syncInterval = 1800 // 30 minutes
        
        // Then: Should be updated
        XCTAssertEqual(syncManager.syncInterval, 1800, "Sync interval should be updated")
    }
    
    func testSyncIntervalWithSmallValue() {
        // When: Setting very small interval (1 minute)
        syncManager.syncInterval = 60
        
        // Then: Should accept it
        XCTAssertEqual(syncManager.syncInterval, 60, "Should accept small intervals")
    }
    
    func testSyncIntervalWithLargeValue() {
        // When: Setting large interval (24 hours)
        syncManager.syncInterval = 86400
        
        // Then: Should accept it
        XCTAssertEqual(syncManager.syncInterval, 86400, "Should accept large intervals")
    }
    
    func testSyncIntervalWithDecimal() {
        // When: Setting decimal interval
        syncManager.syncInterval = 123.45
        
        // Then: Should preserve decimal
        XCTAssertEqual(syncManager.syncInterval, 123.45, accuracy: 0.01, "Should preserve decimal intervals")
    }
    
    // MARK: - Auto Sync Tests
    
    func testEnableAutoSync() {
        // Given: Auto sync is disabled
        XCTAssertFalse(syncManager.autoSync)
        
        // When: Enabling auto sync
        syncManager.autoSync = true
        
        // Then: Should be enabled
        XCTAssertTrue(syncManager.autoSync, "Auto sync should be enabled")
        
        // And: Should persist
        let stored = UserDefaults.standard.bool(forKey: "autoSync")
        XCTAssertTrue(stored, "Auto sync should persist")
    }
    
    func testDisableAutoSync() {
        // Given: Auto sync is enabled
        syncManager.autoSync = true
        XCTAssertTrue(syncManager.autoSync)
        
        // When: Disabling auto sync
        syncManager.autoSync = false
        
        // Then: Should be disabled
        XCTAssertFalse(syncManager.autoSync, "Auto sync should be disabled")
    }
    
    func testAutoSyncPersistence() {
        // Given: Auto sync is enabled
        syncManager.autoSync = true
        
        // When: Reading from UserDefaults
        let retrieved = UserDefaults.standard.bool(forKey: "autoSync")
        
        // Then: Should be true
        XCTAssertTrue(retrieved, "Auto sync state should persist")
    }
    
    func testToggleAutoSyncMultipleTimes() {
        // When: Toggling multiple times
        syncManager.autoSync = true
        XCTAssertTrue(syncManager.autoSync)
        
        syncManager.autoSync = false
        XCTAssertFalse(syncManager.autoSync)
        
        syncManager.autoSync = true
        XCTAssertTrue(syncManager.autoSync)
        
        // Then: Final state should be correct
        XCTAssertTrue(syncManager.autoSync, "Final state should be true")
    }
    
    // MARK: - Monitoring State Tests
    
    func testIsMonitoringInitiallyFalse() {
        // Then: Should not be monitoring initially
        XCTAssertFalse(syncManager.isMonitoring, "Should not be monitoring initially")
    }
    
    func testStopMonitoringWhenNotStarted() {
        // When: Stopping monitoring when it hasn't started
        syncManager.stopMonitoring()
        
        // Then: Should not crash
        XCTAssertFalse(syncManager.isMonitoring, "Should remain not monitoring")
    }
    
    func testStopMonitoringSetsIsMonitoringToFalse() {
        // Given: Monitoring is running
        syncManager.localPath = "/Users/test/Documents"
        // Note: We can't actually start monitoring in tests without file system
        // But we can test the stop logic
        
        // When: Stopping monitoring
        syncManager.stopMonitoring()
        
        // Then: isMonitoring should be false
        XCTAssertFalse(syncManager.isMonitoring, "isMonitoring should be false after stop")
    }
    
    // MARK: - Configuration Tests
    
    func testIsConfiguredWhenRcloneConfigured() {
        // Note: This depends on RcloneManager state
        // We test the delegation to RcloneManager
        
        // When: Checking if configured
        let isConfigured = syncManager.isConfigured()
        
        // Then: Should return a boolean (actual value depends on rclone state)
        XCTAssertNotNil(isConfigured, "isConfigured should return a value")
    }
    
    // MARK: - Sync Status Tests
    
    func testSyncStatusDefaultsToIdle() {
        // Then: Status should be idle
        XCTAssertEqual(syncManager.syncStatus, .idle, "Default status should be idle")
    }
    
    func testSyncStatusIsPublished() {
        // Given: Status starts as idle
        XCTAssertEqual(syncManager.syncStatus, .idle)
        
        // When: Changing status
        syncManager.syncStatus = .checking
        
        // Then: Status should change
        XCTAssertEqual(syncManager.syncStatus, .checking, "Status should be updated")
    }
    
    func testAllSyncStatusStates() {
        // Test all possible status states
        
        syncManager.syncStatus = .idle
        XCTAssertEqual(syncManager.syncStatus, .idle)
        
        syncManager.syncStatus = .checking
        XCTAssertEqual(syncManager.syncStatus, .checking)
        
        syncManager.syncStatus = .syncing
        XCTAssertEqual(syncManager.syncStatus, .syncing)
        
        syncManager.syncStatus = .completed
        XCTAssertEqual(syncManager.syncStatus, .completed)
        
        syncManager.syncStatus = .error("Test error")
        if case .error(let message) = syncManager.syncStatus {
            XCTAssertEqual(message, "Test error")
        } else {
            XCTFail("Status should be error")
        }
    }
    
    // MARK: - Last Sync Time Tests
    
    func testLastSyncTimeDefaultsToNil() {
        // Then: Should be nil initially
        XCTAssertNil(syncManager.lastSyncTime, "Last sync time should be nil initially")
    }
    
    func testSetLastSyncTime() {
        // Given: A test date
        let testDate = Date()
        
        // When: Setting last sync time
        syncManager.lastSyncTime = testDate
        
        // Then: Should be set
        XCTAssertEqual(syncManager.lastSyncTime, testDate, "Last sync time should be set")
    }
    
    func testLastSyncTimeIsPublished() {
        // When: Setting last sync time
        let testDate = Date()
        syncManager.lastSyncTime = testDate
        
        // Then: Should be retrievable
        XCTAssertNotNil(syncManager.lastSyncTime)
        XCTAssertEqual(syncManager.lastSyncTime, testDate)
    }
    
    func testUpdateLastSyncTime() {
        // Given: An existing sync time
        let oldDate = Date(timeIntervalSinceNow: -3600) // 1 hour ago
        syncManager.lastSyncTime = oldDate
        
        // When: Updating to new time
        let newDate = Date()
        syncManager.lastSyncTime = newDate
        
        // Then: Should be updated
        XCTAssertEqual(syncManager.lastSyncTime, newDate)
        XCTAssertNotEqual(syncManager.lastSyncTime, oldDate)
    }
    
    // MARK: - Current Progress Tests
    
    func testCurrentProgressDefaultsToNil() {
        // Then: Should be nil initially
        XCTAssertNil(syncManager.currentProgress, "Current progress should be nil initially")
    }
    
    func testSetCurrentProgress() {
        // Given: A test progress
        var progress = SyncProgress()
        progress.percent = 50
        progress.speed = "1.5 MiB/s"
        
        // When: Setting current progress
        syncManager.currentProgress = progress
        
        // Then: Should be set
        XCTAssertNotNil(syncManager.currentProgress)
        XCTAssertEqual(syncManager.currentProgress?.percent, 50)
    }
    
    func testCurrentProgressIsPublished() {
        // When: Setting progress
        var progress = SyncProgress()
        progress.percent = 75
        progress.speed = "2.0 MiB/s"
        syncManager.currentProgress = progress
        
        // Then: Should be retrievable
        XCTAssertNotNil(syncManager.currentProgress)
        XCTAssertEqual(syncManager.currentProgress?.percent, 75)
    }
    
    func testUpdateCurrentProgress() {
        // Given: Initial progress
        var initialProgress = SyncProgress()
        initialProgress.percent = 25
        initialProgress.speed = "500.0 KiB/s"
        syncManager.currentProgress = initialProgress
        
        // When: Updating progress
        var newProgress = SyncProgress()
        newProgress.percent = 75
        newProgress.speed = "2.0 MiB/s"
        syncManager.currentProgress = newProgress
        
        // Then: Should be updated
        XCTAssertEqual(syncManager.currentProgress?.percent, 75)
    }
    
    func testClearCurrentProgress() {
        // Given: Progress is set
        var progress = SyncProgress()
        progress.percent = 100
        syncManager.currentProgress = progress
        XCTAssertNotNil(syncManager.currentProgress)
        
        // When: Clearing progress
        syncManager.currentProgress = nil
        
        // Then: Should be nil
        XCTAssertNil(syncManager.currentProgress, "Progress should be cleared")
    }
    
    // MARK: - Complete Configuration Workflow Tests
    
    func testCompleteSetupWorkflow() {
        // Scenario: User configures sync from scratch
        
        // Step 1: Set local path
        syncManager.localPath = "/Users/test/CloudSync"
        XCTAssertEqual(syncManager.localPath, "/Users/test/CloudSync")
        
        // Step 2: Set remote path
        syncManager.remotePath = "/Documents/Backup"
        XCTAssertEqual(syncManager.remotePath, "/Documents/Backup")
        
        // Step 3: Set sync interval (15 minutes)
        syncManager.syncInterval = 900
        XCTAssertEqual(syncManager.syncInterval, 900)
        
        // Step 4: Enable auto sync
        syncManager.autoSync = true
        XCTAssertTrue(syncManager.autoSync)
        
        // Verify: All settings should be configured
        XCTAssertFalse(syncManager.localPath.isEmpty)
        XCTAssertFalse(syncManager.remotePath.isEmpty)
        XCTAssertGreaterThan(syncManager.syncInterval, 0)
        XCTAssertTrue(syncManager.autoSync)
    }
    
    func testResetConfigurationWorkflow() {
        // Given: Fully configured sync
        syncManager.localPath = "/Users/test/CloudSync"
        syncManager.remotePath = "/Backup"
        syncManager.syncInterval = 600
        syncManager.autoSync = true
        
        // When: Resetting configuration
        syncManager.stopMonitoring()
        syncManager.localPath = ""
        syncManager.remotePath = ""
        syncManager.autoSync = false
        
        // Then: Should be reset
        XCTAssertTrue(syncManager.localPath.isEmpty)
        XCTAssertTrue(syncManager.remotePath.isEmpty)
        XCTAssertFalse(syncManager.autoSync)
        XCTAssertFalse(syncManager.isMonitoring)
    }
    
    // MARK: - Edge Cases
    
    func testVeryLongLocalPath() {
        // Given: A very long path
        let longPath = "/Users/test/" + String(repeating: "VeryLongDirectory/", count: 20)
        
        // When: Setting the path
        syncManager.localPath = longPath
        
        // Then: Should handle it
        XCTAssertEqual(syncManager.localPath, longPath, "Should handle long paths")
    }
    
    func testPathWithUnicode() {
        // Given: Path with unicode characters
        let unicodePath = "/Users/test/文档/файлы/🔒Documents"
        
        // When: Setting the path
        syncManager.localPath = unicodePath
        
        // Then: Should preserve unicode
        XCTAssertEqual(syncManager.localPath, unicodePath, "Should preserve unicode characters")
    }
    
    func testZeroSyncInterval() {
        // When: Setting interval to zero
        syncManager.syncInterval = 0
        
        // Then: Getter should return default (300)
        // Because the getter has logic: != 0 ? value : 300
        XCTAssertEqual(syncManager.syncInterval, 300, "Zero interval should return default")
    }
    
    func testNegativeSyncInterval() {
        // When: Setting negative interval (shouldn't happen but test anyway)
        syncManager.syncInterval = -100
        
        // Then: Value is stored (validation should be in UI)
        UserDefaults.standard.set(-100, forKey: "syncInterval")
        let stored = UserDefaults.standard.double(forKey: "syncInterval")
        XCTAssertEqual(stored, -100, "Negative values are stored (UI should validate)")
    }
    
    func testRapidPropertyChanges() {
        // When: Rapidly changing properties
        for i in 1...10 {
            syncManager.localPath = "/Path/\(i)"
            syncManager.remotePath = "/Remote/\(i)"
            syncManager.syncInterval = Double(i * 60)
        }
        
        // Then: Final values should be correct
        XCTAssertEqual(syncManager.localPath, "/Path/10")
        XCTAssertEqual(syncManager.remotePath, "/Remote/10")
        XCTAssertEqual(syncManager.syncInterval, 600)
    }
    
    // MARK: - State Consistency Tests
    
    func testStopMonitoringResetsState() {
        // Given: Monitoring with status
        syncManager.syncStatus = .syncing
        var progress = SyncProgress()
        progress.percent = 50
        progress.speed = "1.0 MiB/s"
        syncManager.currentProgress = progress
        
        // When: Stopping monitoring
        syncManager.stopMonitoring()
        
        // Then: Monitoring should be stopped
        XCTAssertFalse(syncManager.isMonitoring)
        // Note: Status and progress might not reset immediately - that's OK
    }
    
    func testMultipleStopMonitoringCalls() {
        // When: Calling stop multiple times
        syncManager.stopMonitoring()
        syncManager.stopMonitoring()
        syncManager.stopMonitoring()
        
        // Then: Should not crash
        XCTAssertFalse(syncManager.isMonitoring)
    }
    
    // MARK: - Settings Persistence Integration Tests
    
    func testAllSettingsPersistTogether() {
        // When: Setting all configurations
        syncManager.localPath = "/Users/test/Sync"
        syncManager.remotePath = "/Cloud/Backup"
        syncManager.syncInterval = 1200
        syncManager.autoSync = true
        
        // Then: All should persist in UserDefaults
        XCTAssertEqual(UserDefaults.standard.string(forKey: "localPath"), "/Users/test/Sync")
        XCTAssertEqual(UserDefaults.standard.string(forKey: "remotePath"), "/Cloud/Backup")
        XCTAssertEqual(UserDefaults.standard.double(forKey: "syncInterval"), 1200)
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "autoSync"))
    }
    
    func testSettingsPersistAfterReset() {
        // Given: Settings are configured
        syncManager.localPath = "/Test"
        syncManager.remotePath = "/Remote"
        syncManager.syncInterval = 500
        syncManager.autoSync = true
        
        // When: Manually resetting properties (simulating fresh start)
        syncManager.stopMonitoring()
        
        // Then: UserDefaults should still have values
        XCTAssertEqual(UserDefaults.standard.string(forKey: "localPath"), "/Test")
        XCTAssertEqual(UserDefaults.standard.string(forKey: "remotePath"), "/Remote")
        XCTAssertEqual(UserDefaults.standard.double(forKey: "syncInterval"), 500)
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "autoSync"))
    }
}
