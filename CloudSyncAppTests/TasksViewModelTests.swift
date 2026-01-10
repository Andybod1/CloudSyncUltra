//
//  TasksViewModelTests.swift
//  CloudSyncAppTests
//
//  Unit tests for TasksViewModel
//

import XCTest
@testable import CloudSyncApp

@MainActor
final class TasksViewModelTests: XCTestCase {
    
    var viewModel: TasksViewModel!
    
    override func setUp() async throws {
        viewModel = TasksViewModel()
        viewModel.tasks.removeAll()
    }
    
    override func tearDown() async throws {
        viewModel = nil
    }
    
    // MARK: - Add Task Tests
    
    func testAddTask() {
        let task = SyncTask(
            name: "Test Task",
            type: .sync,
            sourcePath: "/source",
            destPath: "/dest",
            sourceRemote: "local",
            destRemote: "google"
        )
        
        viewModel.addTask(task)
        
        XCTAssertEqual(viewModel.tasks.count, 1)
        XCTAssertEqual(viewModel.tasks[0].name, "Test Task")
    }
    
    func testAddMultipleTasks() {
        let task1 = SyncTask(name: "Task 1", type: .sync, sourcePath: "/src1", destPath: "/dst1", sourceRemote: "local", destRemote: "google")
        let task2 = SyncTask(name: "Task 2", type: .backup, sourcePath: "/src2", destPath: "/dst2", sourceRemote: "local", destRemote: "dropbox")
        
        viewModel.addTask(task1)
        viewModel.addTask(task2)
        
        XCTAssertEqual(viewModel.tasks.count, 2)
    }
    
    // MARK: - Remove Task Tests
    
    func testRemoveTask() {
        let task = SyncTask(name: "To Remove", type: .sync, sourcePath: "/src", destPath: "/dst", sourceRemote: "local", destRemote: "google")
        viewModel.addTask(task)
        
        viewModel.removeTask(task)
        
        XCTAssertEqual(viewModel.tasks.count, 0)
    }
    
    func testRemoveTask_ByID() {
        let task = SyncTask(name: "To Remove", type: .sync, sourcePath: "/src", destPath: "/dst", sourceRemote: "local", destRemote: "google")
        viewModel.addTask(task)
        
        viewModel.tasks.removeAll { $0.id == task.id }
        
        XCTAssertTrue(viewModel.tasks.isEmpty)
    }
    
    // MARK: - Filter Tests
    
    func testActiveTasks() {
        let activeTask = SyncTask(name: "Active", type: .sync, sourcePath: "/src", destPath: "/dst", sourceRemote: "local", destRemote: "google", status: .active)
        let pendingTask = SyncTask(name: "Pending", type: .sync, sourcePath: "/src", destPath: "/dst", sourceRemote: "local", destRemote: "google", status: .pending)
        
        viewModel.addTask(activeTask)
        viewModel.addTask(pendingTask)
        
        let active = viewModel.tasks.filter { $0.status == .active }
        XCTAssertEqual(active.count, 1)
        XCTAssertEqual(active[0].name, "Active")
    }
    
    func testPendingTasks() {
        let activeTask = SyncTask(name: "Active", type: .sync, sourcePath: "/src", destPath: "/dst", sourceRemote: "local", destRemote: "google", status: .active)
        let pendingTask = SyncTask(name: "Pending", type: .sync, sourcePath: "/src", destPath: "/dst", sourceRemote: "local", destRemote: "google", status: .pending)
        
        viewModel.addTask(activeTask)
        viewModel.addTask(pendingTask)
        
        let pending = viewModel.tasks.filter { $0.status == .pending }
        XCTAssertEqual(pending.count, 1)
        XCTAssertEqual(pending[0].name, "Pending")
    }
    
    func testCompletedTasks() {
        let completedTask = SyncTask(name: "Completed", type: .sync, sourcePath: "/src", destPath: "/dst", sourceRemote: "local", destRemote: "google", status: .completed)
        let pendingTask = SyncTask(name: "Pending", type: .sync, sourcePath: "/src", destPath: "/dst", sourceRemote: "local", destRemote: "google", status: .pending)
        
        viewModel.addTask(completedTask)
        viewModel.addTask(pendingTask)
        
        let completed = viewModel.tasks.filter { $0.status == .completed }
        XCTAssertEqual(completed.count, 1)
        XCTAssertEqual(completed[0].name, "Completed")
    }
    
    // MARK: - Update Task Tests
    
    func testUpdateTaskStatus() {
        var task = SyncTask(name: "Test", type: .sync, sourcePath: "/src", destPath: "/dst", sourceRemote: "local", destRemote: "google", status: .pending)
        viewModel.addTask(task)
        
        // Find and update
        if let index = viewModel.tasks.firstIndex(where: { $0.id == task.id }) {
            viewModel.tasks[index].status = .active
        }
        
        XCTAssertEqual(viewModel.tasks[0].status, .active)
    }
    
    func testToggleTaskEnabled() {
        var task = SyncTask(name: "Test", type: .sync, sourcePath: "/src", destPath: "/dst", sourceRemote: "local", destRemote: "google", isEnabled: true)
        viewModel.addTask(task)
        
        if let index = viewModel.tasks.firstIndex(where: { $0.id == task.id }) {
            viewModel.tasks[index].isEnabled.toggle()
        }
        
        XCTAssertFalse(viewModel.tasks[0].isEnabled)
    }
    
    // MARK: - Task Type Filter Tests
    
    func testFilterByType_Sync() {
        let syncTask = SyncTask(name: "Sync", type: .sync, sourcePath: "/src", destPath: "/dst", sourceRemote: "local", destRemote: "google")
        let backupTask = SyncTask(name: "Backup", type: .backup, sourcePath: "/src", destPath: "/dst", sourceRemote: "local", destRemote: "google")
        
        viewModel.addTask(syncTask)
        viewModel.addTask(backupTask)
        
        let syncTasks = viewModel.tasks.filter { $0.type == .sync }
        XCTAssertEqual(syncTasks.count, 1)
        XCTAssertEqual(syncTasks[0].name, "Sync")
    }
    
    func testFilterByType_Backup() {
        let syncTask = SyncTask(name: "Sync", type: .sync, sourcePath: "/src", destPath: "/dst", sourceRemote: "local", destRemote: "google")
        let backupTask = SyncTask(name: "Backup", type: .backup, sourcePath: "/src", destPath: "/dst", sourceRemote: "local", destRemote: "google")
        
        viewModel.addTask(syncTask)
        viewModel.addTask(backupTask)
        
        let backupTasks = viewModel.tasks.filter { $0.type == .backup }
        XCTAssertEqual(backupTasks.count, 1)
        XCTAssertEqual(backupTasks[0].name, "Backup")
    }
    
    // MARK: - Enabled Tasks Tests
    
    func testEnabledTasks() {
        let enabledTask = SyncTask(name: "Enabled", type: .sync, sourcePath: "/src", destPath: "/dst", sourceRemote: "local", destRemote: "google", isEnabled: true)
        let disabledTask = SyncTask(name: "Disabled", type: .sync, sourcePath: "/src", destPath: "/dst", sourceRemote: "local", destRemote: "google", isEnabled: false)
        
        viewModel.addTask(enabledTask)
        viewModel.addTask(disabledTask)
        
        let enabled = viewModel.tasks.filter { $0.isEnabled }
        XCTAssertEqual(enabled.count, 1)
        XCTAssertEqual(enabled[0].name, "Enabled")
    }
}
