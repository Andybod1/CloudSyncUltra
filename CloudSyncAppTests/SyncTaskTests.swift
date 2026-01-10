//
//  SyncTaskTests.swift
//  CloudSyncAppTests
//
//  Unit tests for SyncTask model
//

import XCTest
@testable import CloudSyncApp

final class SyncTaskTests: XCTestCase {
    
    // MARK: - TaskType Tests
    
    func testTaskType_Icons() {
        XCTAssertEqual(TaskType.sync.icon, "arrow.triangle.2.circlepath")
        XCTAssertEqual(TaskType.backup.icon, "arrow.clockwise.icloud")
        XCTAssertEqual(TaskType.transfer.icon, "arrow.right.arrow.left")
    }
    
    func testTaskType_AllCases() {
        XCTAssertEqual(TaskType.allCases.count, 3)
        XCTAssertTrue(TaskType.allCases.contains(.sync))
        XCTAssertTrue(TaskType.allCases.contains(.backup))
        XCTAssertTrue(TaskType.allCases.contains(.transfer))
    }
    
    // MARK: - TaskStatus Tests
    
    func testTaskStatus_Color() {
        // Active should be blue/accent
        // Pending should be orange
        // Completed should be green
        // Failed should be red
        // These are visual tests, just ensure they don't crash
        _ = TaskStatus.active.color
        _ = TaskStatus.pending.color
        _ = TaskStatus.completed.color
        _ = TaskStatus.failed.color
    }
    
    func testTaskStatus_Icon() {
        XCTAssertEqual(TaskStatus.active.icon, "play.circle.fill")
        XCTAssertEqual(TaskStatus.pending.icon, "clock.fill")
        XCTAssertEqual(TaskStatus.completed.icon, "checkmark.circle.fill")
        XCTAssertEqual(TaskStatus.failed.icon, "xmark.circle.fill")
    }
    
    // MARK: - SyncTask Creation Tests
    
    func testSyncTask_Creation() {
        let task = SyncTask(
            name: "Test Backup",
            type: .backup,
            sourcePath: "/source",
            destPath: "/dest",
            sourceRemote: "local",
            destRemote: "proton"
        )
        
        XCTAssertEqual(task.name, "Test Backup")
        XCTAssertEqual(task.type, .backup)
        XCTAssertEqual(task.sourcePath, "/source")
        XCTAssertEqual(task.destPath, "/dest")
        XCTAssertEqual(task.sourceRemote, "local")
        XCTAssertEqual(task.destRemote, "proton")
        XCTAssertEqual(task.status, .pending)
        XCTAssertTrue(task.isEnabled)
    }
    
    func testSyncTask_DefaultValues() {
        let task = SyncTask(
            name: "Default Task",
            type: .sync,
            sourcePath: "/src",
            destPath: "/dst",
            sourceRemote: "google",
            destRemote: "dropbox"
        )
        
        XCTAssertEqual(task.status, .pending)
        XCTAssertTrue(task.isEnabled)
        XCTAssertNil(task.lastRun)
        XCTAssertNil(task.nextRun)
        XCTAssertNil(task.schedule)
    }
    
    func testSyncTask_WithSchedule() {
        let nextRun = Date().addingTimeInterval(3600)
        let task = SyncTask(
            name: "Scheduled Task",
            type: .sync,
            sourcePath: "/src",
            destPath: "/dst",
            sourceRemote: "local",
            destRemote: "google",
            schedule: "hourly",
            nextRun: nextRun
        )
        
        XCTAssertEqual(task.schedule, "hourly")
        XCTAssertEqual(task.nextRun, nextRun)
    }
    
    // MARK: - Equality Tests
    
    func testSyncTask_Equality() {
        let id = UUID()
        let task1 = SyncTask(
            id: id,
            name: "Task 1",
            type: .sync,
            sourcePath: "/src",
            destPath: "/dst",
            sourceRemote: "local",
            destRemote: "google"
        )
        let task2 = SyncTask(
            id: id,
            name: "Different Name",
            type: .backup,
            sourcePath: "/different",
            destPath: "/also-different",
            sourceRemote: "dropbox",
            destRemote: "onedrive"
        )
        
        XCTAssertEqual(task1, task2) // Same ID means equal
    }
    
    // MARK: - Codable Tests
    
    func testSyncTask_Codable() throws {
        let task = SyncTask(
            name: "Codable Test",
            type: .transfer,
            sourcePath: "/source/path",
            destPath: "/dest/path",
            sourceRemote: "google",
            destRemote: "proton",
            status: .completed,
            isEnabled: false
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(task)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(SyncTask.self, from: data)
        
        XCTAssertEqual(decoded.id, task.id)
        XCTAssertEqual(decoded.name, task.name)
        XCTAssertEqual(decoded.type, task.type)
        XCTAssertEqual(decoded.sourcePath, task.sourcePath)
        XCTAssertEqual(decoded.destPath, task.destPath)
        XCTAssertEqual(decoded.sourceRemote, task.sourceRemote)
        XCTAssertEqual(decoded.destRemote, task.destRemote)
        XCTAssertEqual(decoded.status, task.status)
        XCTAssertEqual(decoded.isEnabled, task.isEnabled)
    }
}
