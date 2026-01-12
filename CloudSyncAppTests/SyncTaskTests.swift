//
//  SyncTaskTests.swift
//  CloudSyncAppTests
//
//  Tests for SyncTask model
//

import XCTest
@testable import CloudSyncApp

final class SyncTaskTests: XCTestCase {
    
    // MARK: - TaskType Tests
    
    func testTaskTypeRawValues() {
        XCTAssertEqual(TaskType.sync.rawValue, "Sync")
        XCTAssertEqual(TaskType.transfer.rawValue, "Transfer")
        XCTAssertEqual(TaskType.backup.rawValue, "Backup")
    }
    
    func testTaskTypeIcons() {
        XCTAssertEqual(TaskType.sync.icon, "arrow.triangle.2.circlepath")
        XCTAssertEqual(TaskType.transfer.icon, "arrow.right")
        XCTAssertEqual(TaskType.backup.icon, "externaldrive.fill.badge.timemachine")
    }
    
    // MARK: - TaskState Tests
    
    func testTaskStateRawValues() {
        XCTAssertEqual(TaskState.pending.rawValue, "Pending")
        XCTAssertEqual(TaskState.running.rawValue, "Running")
        XCTAssertEqual(TaskState.completed.rawValue, "Completed")
        XCTAssertEqual(TaskState.failed.rawValue, "Failed")
        XCTAssertEqual(TaskState.paused.rawValue, "Paused")
        XCTAssertEqual(TaskState.cancelled.rawValue, "Cancelled")
    }
    
    func testTaskStateColors() {
        // Just verify colors exist and are non-empty
        XCTAssertFalse(TaskState.pending.color.isEmpty)
        XCTAssertFalse(TaskState.running.color.isEmpty)
        XCTAssertFalse(TaskState.completed.color.isEmpty)
        XCTAssertFalse(TaskState.failed.color.isEmpty)
        XCTAssertFalse(TaskState.paused.color.isEmpty)
        XCTAssertFalse(TaskState.cancelled.color.isEmpty)
    }
    
    // MARK: - SyncTask Creation Tests
    
    func testSyncTaskCreation() {
        // Given
        let task = SyncTask(
            name: "Test Backup",
            type: .backup,
            sourceRemote: "local",
            sourcePath: "/Users/test/Documents",
            destinationRemote: "Google Drive",
            destinationPath: "/Backups"
        )
        
        // Then
        XCTAssertEqual(task.name, "Test Backup")
        XCTAssertEqual(task.type, .backup)
        XCTAssertEqual(task.sourceRemote, "local")
        XCTAssertEqual(task.sourcePath, "/Users/test/Documents")
        XCTAssertEqual(task.destinationRemote, "Google Drive")
        XCTAssertEqual(task.destinationPath, "/Backups")
        XCTAssertEqual(task.state, .pending)
        XCTAssertEqual(task.progress, 0)
    }
    
    func testSyncTaskDefaultState() {
        // Given
        let task = SyncTask(
            name: "Test Task",
            type: .sync,
            sourceRemote: "local",
            sourcePath: "/test",
            destinationRemote: "Remote",
            destinationPath: "/backup"
        )
        
        // Then: Default state should be pending
        XCTAssertEqual(task.state, .pending)
        XCTAssertEqual(task.progress, 0)
        XCTAssertEqual(task.bytesTransferred, 0)
        XCTAssertEqual(task.totalBytes, 0)
    }
    
    func testSyncTaskWithEncryption() {
        // Given
        let task = SyncTask(
            name: "Encrypted Backup",
            type: .backup,
            sourceRemote: "local",
            sourcePath: "/sensitive",
            destinationRemote: "Google Drive",
            destinationPath: "/encrypted",
            encryptSource: false,
            encryptDestination: true
        )
        
        // Then
        XCTAssertFalse(task.encryptSource)
        XCTAssertTrue(task.encryptDestination)
    }
    
    // MARK: - Identifiable Tests
    
    func testSyncTaskIsIdentifiable() {
        // Given
        let task1 = SyncTask(
            name: "Task 1",
            type: .sync,
            sourceRemote: "local",
            sourcePath: "/a",
            destinationRemote: "Remote",
            destinationPath: "/b"
        )
        let task2 = SyncTask(
            name: "Task 2",
            type: .sync,
            sourceRemote: "local",
            sourcePath: "/c",
            destinationRemote: "Remote",
            destinationPath: "/d"
        )
        
        // Then: Each task should have unique ID
        XCTAssertNotEqual(task1.id, task2.id)
    }
    
    // MARK: - Codable Tests
    
    func testSyncTaskIsCodable() throws {
        // Given
        let task = SyncTask(
            name: "Codable Test",
            type: .transfer,
            sourceRemote: "pCloud",
            sourcePath: "/photos",
            destinationRemote: "Google Drive",
            destinationPath: "/archive"
        )
        
        // When
        let encoded = try JSONEncoder().encode(task)
        let decoded = try JSONDecoder().decode(SyncTask.self, from: encoded)
        
        // Then
        XCTAssertEqual(decoded.name, task.name)
        XCTAssertEqual(decoded.type, task.type)
        XCTAssertEqual(decoded.sourceRemote, task.sourceRemote)
        XCTAssertEqual(decoded.destinationRemote, task.destinationRemote)
    }
    
    func testTaskTypeIsCodable() throws {
        // Given
        let types: [TaskType] = [.sync, .transfer, .backup]
        
        // When/Then
        for type in types {
            let encoded = try JSONEncoder().encode(type)
            let decoded = try JSONDecoder().decode(TaskType.self, from: encoded)
            XCTAssertEqual(decoded, type)
        }
    }
    
    func testTaskStateIsCodable() throws {
        // Given
        let states: [TaskState] = [.pending, .running, .completed, .failed, .paused, .cancelled]
        
        // When/Then
        for state in states {
            let encoded = try JSONEncoder().encode(state)
            let decoded = try JSONDecoder().decode(TaskState.self, from: encoded)
            XCTAssertEqual(decoded, state)
        }
    }
}
