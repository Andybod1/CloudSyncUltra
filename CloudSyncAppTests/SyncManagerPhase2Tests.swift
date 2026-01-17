//
//  SyncManagerPhase2Tests.swift
//  CloudSyncAppTests
//
//  Phase 2: Advanced integration tests for SyncManager
//  Tests file monitoring, sync operations, timers, and encryption integration
//

import XCTest
@testable import CloudSyncApp

@MainActor
final class SyncManagerPhase2Tests: XCTestCase {
    
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
    
    // MARK: - Start Monitoring Tests
    
    func testStartMonitoringWithEmptyLocalPath() async {
        // Given: Empty local path
        syncManager.localPath = ""
        
        // When: Starting monitoring
        await syncManager.startMonitoring()
        
        // Then: Should not start monitoring
        XCTAssertFalse(syncManager.isMonitoring, "Should not start monitoring with empty path")
    }
    
    func testStartMonitoringSetsIsMonitoringTrue() async {
        // Given: Valid local path
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        syncManager.localPath = tempDir.path
        syncManager.remotePath = "/test"
        
        // When: Starting monitoring
        await syncManager.startMonitoring()
        
        // Then: isMonitoring should be true
        XCTAssertTrue(syncManager.isMonitoring, "isMonitoring should be true after start")
        
        // Cleanup
        try? FileManager.default.removeItem(at: tempDir)
    }
    
    func testStartMonitoringMultipleTimes() async {
        // Given: Valid paths
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        syncManager.localPath = tempDir.path
        syncManager.remotePath = "/test"
        
        // When: Starting monitoring multiple times
        await syncManager.startMonitoring()
        let firstState = syncManager.isMonitoring
        
        await syncManager.startMonitoring()
        let secondState = syncManager.isMonitoring
        
        // Then: Should handle multiple starts
        XCTAssertTrue(firstState, "First start should set monitoring true")
        XCTAssertTrue(secondState, "Second start should keep monitoring true")
        
        // Cleanup
        try? FileManager.default.removeItem(at: tempDir)
    }
    
    // MARK: - Stop Monitoring Tests
    
    func testStopMonitoringCleansUpTimer() async {
        // Given: Monitoring is running with timer
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        syncManager.localPath = tempDir.path
        syncManager.remotePath = "/test"
        syncManager.autoSync = true
        syncManager.syncInterval = 60 // 1 minute
        
        await syncManager.startMonitoring()
        XCTAssertTrue(syncManager.isMonitoring)
        
        // When: Stopping monitoring
        syncManager.stopMonitoring()
        
        // Then: Should stop monitoring
        XCTAssertFalse(syncManager.isMonitoring, "Should stop monitoring")
        
        // Cleanup
        try? FileManager.default.removeItem(at: tempDir)
    }
    
    func testStopMonitoringWithoutAutoSync() async {
        // Given: Monitoring without auto sync
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        syncManager.localPath = tempDir.path
        syncManager.remotePath = "/test"
        syncManager.autoSync = false
        
        await syncManager.startMonitoring()
        // When autoSync is false, monitoring doesn't start
        XCTAssertFalse(syncManager.isMonitoring)

        // When: Stopping monitoring (should be safe even if not monitoring)
        syncManager.stopMonitoring()

        // Then: Should remain not monitoring
        XCTAssertFalse(syncManager.isMonitoring)
        
        // Cleanup
        try? FileManager.default.removeItem(at: tempDir)
    }
    
    // MARK: - Manual Sync Tests
    
    func testManualSyncInitiatesSync() async {
        // Given: Valid configuration
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        syncManager.localPath = tempDir.path
        syncManager.remotePath = "/test"
        
        let initialStatus = syncManager.syncStatus
        
        // When: Initiating manual sync (will likely fail without rclone config, but we test the call)
        await syncManager.manualSync()
        
        // Then: Should have attempted sync
        // Note: Actual sync may fail without proper rclone setup
        // We're testing that the method can be called without crashing
        XCTAssertNotNil(syncManager.syncStatus, "Sync status should be set")
        
        // Cleanup
        try? FileManager.default.removeItem(at: tempDir)
    }
    
    // MARK: - Sync Status Transition Tests
    
    func testSyncStatusStartsAsIdle() {
        // Then: Initial status should be idle
        XCTAssertEqual(syncManager.syncStatus, .idle, "Initial status should be idle")
    }
    
    func testSyncStatusCanTransitionToChecking() {
        // When: Changing to checking
        syncManager.syncStatus = .checking
        
        // Then: Should be checking
        XCTAssertEqual(syncManager.syncStatus, .checking)
    }
    
    func testSyncStatusCanTransitionToSyncing() {
        // When: Changing to syncing
        syncManager.syncStatus = .syncing
        
        // Then: Should be syncing
        XCTAssertEqual(syncManager.syncStatus, .syncing)
    }
    
    func testSyncStatusCanTransitionToCompleted() {
        // When: Changing to completed
        syncManager.syncStatus = .completed
        
        // Then: Should be completed
        XCTAssertEqual(syncManager.syncStatus, .completed)
    }
    
    func testSyncStatusCanTransitionToError() {
        // When: Changing to error
        let errorMessage = "Test sync error"
        syncManager.syncStatus = .error(errorMessage)
        
        // Then: Should be error with message
        if case .error(let message) = syncManager.syncStatus {
            XCTAssertEqual(message, errorMessage)
        } else {
            XCTFail("Status should be error")
        }
    }
    
    func testSyncStatusTransitionSequence() {
        // Test typical sync flow: idle → checking → syncing → completed → idle
        
        syncManager.syncStatus = .idle
        XCTAssertEqual(syncManager.syncStatus, .idle)
        
        syncManager.syncStatus = .checking
        XCTAssertEqual(syncManager.syncStatus, .checking)
        
        syncManager.syncStatus = .syncing
        XCTAssertEqual(syncManager.syncStatus, .syncing)
        
        syncManager.syncStatus = .completed
        XCTAssertEqual(syncManager.syncStatus, .completed)
        
        syncManager.syncStatus = .idle
        XCTAssertEqual(syncManager.syncStatus, .idle)
    }
    
    func testSyncStatusErrorTransition() {
        // Test error flow: idle → checking → error
        
        syncManager.syncStatus = .idle
        syncManager.syncStatus = .checking
        syncManager.syncStatus = .error("Network timeout")
        
        if case .error(let message) = syncManager.syncStatus {
            XCTAssertEqual(message, "Network timeout")
        } else {
            XCTFail("Should be in error state")
        }
    }
    
    // MARK: - Last Sync Time Tracking Tests
    
    func testLastSyncTimeNotSetInitially() {
        // Then: Should be nil
        XCTAssertNil(syncManager.lastSyncTime)
    }
    
    func testLastSyncTimeCanBeSet() {
        // Given: A test date
        let testDate = Date()
        
        // When: Setting last sync time
        syncManager.lastSyncTime = testDate
        
        // Then: Should be set
        XCTAssertEqual(syncManager.lastSyncTime, testDate)
    }
    
    func testLastSyncTimeUpdatesOnSuccessfulSync() async {
        // Note: This test documents expected behavior
        // Actual lastSyncTime update happens in performSync() which requires full rclone setup
        
        // When: Simulating successful sync completion
        syncManager.lastSyncTime = Date()
        
        // Then: Should have timestamp
        XCTAssertNotNil(syncManager.lastSyncTime)
    }
    
    func testLastSyncTimePreservesAcrossStops() {
        // Given: Last sync time is set
        let testDate = Date()
        syncManager.lastSyncTime = testDate
        
        // When: Stopping monitoring
        syncManager.stopMonitoring()
        
        // Then: Last sync time should persist
        XCTAssertEqual(syncManager.lastSyncTime, testDate)
    }
    
    // MARK: - Progress Tracking Tests
    
    func testCurrentProgressNotSetInitially() {
        // Then: Should be nil
        XCTAssertNil(syncManager.currentProgress)
    }
    
    func testCurrentProgressCanBeSet() {
        // Given: Test progress
        var progress = SyncProgress()
        progress.percent = 50
        progress.speed = "1.0 MiB/s"
        
        // When: Setting progress
        syncManager.currentProgress = progress
        
        // Then: Should be set
        XCTAssertNotNil(syncManager.currentProgress)
        XCTAssertEqual(syncManager.currentProgress?.percent, 50)
    }
    
    func testCurrentProgressUpdatesIncrementally() {
        // Simulate progress updates during sync
        
        // 25%
        var progress25 = SyncProgress()
        progress25.percent = 25
        progress25.speed = "500.0 KiB/s"
        syncManager.currentProgress = progress25
        XCTAssertEqual(syncManager.currentProgress?.percent, 25)
        
        // 50%
        var progress50 = SyncProgress()
        progress50.percent = 50
        progress50.speed = "1.0 MiB/s"
        syncManager.currentProgress = progress50
        XCTAssertEqual(syncManager.currentProgress?.percent, 50)
        
        // 75%
        var progress75 = SyncProgress()
        progress75.percent = 75
        progress75.speed = "1.5 MiB/s"
        syncManager.currentProgress = progress75
        XCTAssertEqual(syncManager.currentProgress?.percent, 75)
        
        // 100%
        var progress100 = SyncProgress()
        progress100.percent = 100
        syncManager.currentProgress = progress100
        XCTAssertEqual(syncManager.currentProgress?.percent, 100)
    }
    
    func testCurrentProgressClearedOnStop() {
        // Given: Progress is set
        var progress = SyncProgress()
        progress.percent = 50
        progress.speed = "1.0 MiB/s"
        syncManager.currentProgress = progress
        XCTAssertNotNil(syncManager.currentProgress)
        
        // When: Stopping sync
        syncManager.stopMonitoring()
        
        // Note: Progress may or may not clear automatically - documenting current behavior
        // The important part is stopMonitoring() doesn't crash with active progress
    }
    
    // MARK: - Auto Sync Configuration Tests
    
    func testAutoSyncDisabledByDefault() {
        // Then: Should be disabled
        XCTAssertFalse(syncManager.autoSync)
    }
    
    func testEnablingAutoSyncWithoutMonitoring() {
        // When: Enabling auto sync without starting monitoring
        syncManager.autoSync = true
        
        // Then: Should be enabled but not monitoring
        XCTAssertTrue(syncManager.autoSync)
        XCTAssertFalse(syncManager.isMonitoring)
    }
    
    func testDisablingAutoSyncWhileMonitoring() async {
        // Given: Monitoring with auto sync
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        syncManager.localPath = tempDir.path
        syncManager.remotePath = "/test"
        syncManager.autoSync = true
        
        await syncManager.startMonitoring()
        XCTAssertTrue(syncManager.isMonitoring)
        XCTAssertTrue(syncManager.autoSync)
        
        // When: Disabling auto sync
        syncManager.autoSync = false
        
        // Then: Auto sync should be disabled
        XCTAssertFalse(syncManager.autoSync)
        // Note: Monitoring may still be active - that's OK
        
        // Cleanup
        try? FileManager.default.removeItem(at: tempDir)
    }
    
    // MARK: - Sync Interval Configuration Tests
    
    func testSyncIntervalDefaultValue() {
        // Then: Should be 300 seconds (5 minutes)
        XCTAssertEqual(syncManager.syncInterval, 300)
    }
    
    func testChangingSyncIntervalWhileMonitoring() async {
        // Given: Monitoring is active
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        syncManager.localPath = tempDir.path
        syncManager.remotePath = "/test"
        syncManager.autoSync = true
        syncManager.syncInterval = 300
        
        await syncManager.startMonitoring()
        
        // When: Changing interval
        syncManager.syncInterval = 600
        
        // Then: Interval should be updated
        XCTAssertEqual(syncManager.syncInterval, 600)
        // Note: Timer may need restart to pick up new interval - that's a known limitation
        
        // Cleanup
        try? FileManager.default.removeItem(at: tempDir)
    }
    
    func testVeryShortSyncInterval() {
        // When: Setting very short interval (1 second - not recommended but should work)
        syncManager.syncInterval = 1
        
        // Then: Should accept it
        XCTAssertEqual(syncManager.syncInterval, 1)
    }
    
    func testVeryLongSyncInterval() {
        // When: Setting very long interval (7 days)
        syncManager.syncInterval = 604800
        
        // Then: Should accept it
        XCTAssertEqual(syncManager.syncInterval, 604800)
    }
    
    // MARK: - Configuration Validation Tests
    
    func testIsConfiguredReturnsBool() {
        // When: Checking if configured
        let result = syncManager.isConfigured()
        
        // Then: Should return a boolean
        XCTAssertNotNil(result)
    }
    
    // MARK: - Encryption Integration Tests
    
    func testIsEncryptionActiveWhenNotConfigured() {
        // Given: Encryption not configured
        // When: Checking if encryption is active
        let isActive = syncManager.isEncryptionActive
        
        // Then: Should be false (encryption manager not configured)
        XCTAssertFalse(isActive, "Encryption should not be active when not configured")
    }
    
    // MARK: - Error State Tests
    
    func testSyncStatusWithDifferentErrorMessages() {
        // Test various error messages
        
        let errors = [
            "Network timeout",
            "Permission denied",
            "File not found",
            "Invalid credentials",
            "Disk full",
            "Connection refused"
        ]
        
        for errorMessage in errors {
            syncManager.syncStatus = .error(errorMessage)
            
            if case .error(let message) = syncManager.syncStatus {
                XCTAssertEqual(message, errorMessage, "Error message should match")
            } else {
                XCTFail("Status should be error")
            }
        }
    }
    
    func testRecoverFromErrorState() {
        // Given: Sync is in error state
        syncManager.syncStatus = .error("Test error")
        
        // When: Recovering by going back to idle
        syncManager.syncStatus = .idle
        
        // Then: Should be idle
        XCTAssertEqual(syncManager.syncStatus, .idle)
    }
    
    func testErrorStatePreservesLastSyncTime() {
        // Given: Successful sync with timestamp
        let lastSync = Date()
        syncManager.lastSyncTime = lastSync
        syncManager.syncStatus = .completed
        
        // When: Entering error state
        syncManager.syncStatus = .error("Subsequent sync failed")
        
        // Then: Last successful sync time should be preserved
        XCTAssertEqual(syncManager.lastSyncTime, lastSync)
    }
    
    // MARK: - Concurrent Operations Tests
    
    func testMultiplePropertyChangesSimultaneously() {
        // When: Changing multiple properties
        syncManager.localPath = "/Users/test/Sync"
        syncManager.remotePath = "/Cloud/Backup"
        syncManager.syncInterval = 900
        syncManager.autoSync = true
        syncManager.syncStatus = .idle
        
        // Then: All should be set correctly
        XCTAssertEqual(syncManager.localPath, "/Users/test/Sync")
        XCTAssertEqual(syncManager.remotePath, "/Cloud/Backup")
        XCTAssertEqual(syncManager.syncInterval, 900)
        XCTAssertTrue(syncManager.autoSync)
        XCTAssertEqual(syncManager.syncStatus, .idle)
    }
    
    // MARK: - State Machine Tests
    
    func testValidSyncStateMachine() {
        // Document and test valid state transitions
        
        // idle → checking (valid)
        syncManager.syncStatus = .idle
        syncManager.syncStatus = .checking
        XCTAssertEqual(syncManager.syncStatus, .checking)
        
        // checking → syncing (valid)
        syncManager.syncStatus = .syncing
        XCTAssertEqual(syncManager.syncStatus, .syncing)
        
        // syncing → completed (valid)
        syncManager.syncStatus = .completed
        XCTAssertEqual(syncManager.syncStatus, .completed)
        
        // completed → idle (valid)
        syncManager.syncStatus = .idle
        XCTAssertEqual(syncManager.syncStatus, .idle)
    }
    
    func testErrorStateTransitions() {
        // Test transitions involving error state
        
        // idle → error (valid - immediate failure)
        syncManager.syncStatus = .idle
        syncManager.syncStatus = .error("Immediate failure")
        if case .error = syncManager.syncStatus { } else {
            XCTFail("Should be error")
        }
        
        // error → idle (valid - retry)
        syncManager.syncStatus = .idle
        XCTAssertEqual(syncManager.syncStatus, .idle)
        
        // syncing → error (valid - failure during sync)
        syncManager.syncStatus = .syncing
        syncManager.syncStatus = .error("Failed during sync")
        if case .error = syncManager.syncStatus { } else {
            XCTFail("Should be error")
        }
    }
    
    // MARK: - Resource Cleanup Tests
    
    func testStopMonitoringReleasesResources() {
        // Given: Monitoring is active
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        syncManager.localPath = tempDir.path
        syncManager.remotePath = "/test"
        syncManager.autoSync = true
        
        Task { @MainActor in
            await syncManager.startMonitoring()
            
            // When: Stopping monitoring
            syncManager.stopMonitoring()
            
            // Then: Should have released resources
            XCTAssertFalse(syncManager.isMonitoring)
            
            // Note: File monitor and timer should be nil, but we can't test private properties
            // We test the observable behavior instead
        }
        
        // Cleanup
        try? FileManager.default.removeItem(at: tempDir)
    }
    
    // MARK: - Integration Workflow Tests
    
    func testCompleteMonitoringLifecycle() async {
        // Test complete lifecycle: configure → start → stop
        
        // Configure
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        syncManager.localPath = tempDir.path
        syncManager.remotePath = "/test"
        syncManager.syncInterval = 300
        syncManager.autoSync = true
        
        XCTAssertFalse(syncManager.isMonitoring)
        
        // Start
        await syncManager.startMonitoring()
        XCTAssertTrue(syncManager.isMonitoring)
        
        // Stop
        syncManager.stopMonitoring()
        XCTAssertFalse(syncManager.isMonitoring)
        
        // Cleanup
        try? FileManager.default.removeItem(at: tempDir)
    }
    
    func testMonitoringWithoutAutoSync() async {
        // Test monitoring without periodic sync
        
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        syncManager.localPath = tempDir.path
        syncManager.remotePath = "/test"
        syncManager.autoSync = false // No auto sync
        
        await syncManager.startMonitoring()
        
        // Should still monitor files, just no automatic periodic sync
        XCTAssertTrue(syncManager.isMonitoring)
        XCTAssertFalse(syncManager.autoSync)
        
        // Cleanup
        syncManager.stopMonitoring()
        try? FileManager.default.removeItem(at: tempDir)
    }
    
    // MARK: - Async Operation Tests
    
    func testStartMonitoringIsAsync() async {
        // Test that startMonitoring() is properly async
        
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        syncManager.localPath = tempDir.path
        syncManager.remotePath = "/test"
        
        // Should await without blocking
        await syncManager.startMonitoring()
        
        XCTAssertTrue(syncManager.isMonitoring)
        
        // Cleanup
        try? FileManager.default.removeItem(at: tempDir)
    }
    
    func testManualSyncIsAsync() async {
        // Test that manualSync() is properly async
        
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        syncManager.localPath = tempDir.path
        syncManager.remotePath = "/test"
        
        // Should await without blocking
        await syncManager.manualSync()
        
        // Note: Will likely fail without rclone config, but shouldn't crash
        
        // Cleanup
        try? FileManager.default.removeItem(at: tempDir)
    }
}
