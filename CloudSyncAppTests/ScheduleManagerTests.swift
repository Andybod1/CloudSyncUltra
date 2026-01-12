//
//  ScheduleManagerTests.swift
//  CloudSyncAppTests
//
//  Tests for ScheduleManager
//

import XCTest
@testable import CloudSyncApp

@MainActor
final class ScheduleManagerTests: XCTestCase {

    var manager: ScheduleManager!

    override func setUp() async throws {
        manager = ScheduleManager.shared
        // Clear any existing schedules for clean test state
        for schedule in manager.schedules {
            manager.deleteSchedule(id: schedule.id)
        }
    }

    override func tearDown() async throws {
        // Clean up
        for schedule in manager.schedules {
            manager.deleteSchedule(id: schedule.id)
        }
        manager = nil
    }

    // MARK: - Add Schedule Tests

    func test_ScheduleManager_AddSchedule_IncreasesCount() async {
        let initialCount = manager.schedules.count

        let schedule = SyncSchedule(
            name: "Test Add",
            sourceRemote: "gdrive",
            sourcePath: "/",
            destinationRemote: "proton",
            destinationPath: "/"
        )

        manager.addSchedule(schedule)

        XCTAssertEqual(manager.schedules.count, initialCount + 1)
    }

    func test_ScheduleManager_AddSchedule_SetsNextRunAt() async {
        let schedule = SyncSchedule(
            name: "Test NextRun",
            sourceRemote: "gdrive",
            sourcePath: "/",
            destinationRemote: "proton",
            destinationPath: "/",
            frequency: .hourly
        )

        manager.addSchedule(schedule)

        let added = manager.schedules.first { $0.id == schedule.id }
        XCTAssertNotNil(added?.nextRunAt)
    }

    // MARK: - Update Schedule Tests

    func test_ScheduleManager_UpdateSchedule_ChangesValues() async {
        var schedule = SyncSchedule(
            name: "Original Name",
            sourceRemote: "gdrive",
            sourcePath: "/",
            destinationRemote: "proton",
            destinationPath: "/"
        )

        manager.addSchedule(schedule)

        schedule.name = "Updated Name"
        manager.updateSchedule(schedule)

        let updated = manager.schedules.first { $0.id == schedule.id }
        XCTAssertEqual(updated?.name, "Updated Name")
    }

    func test_ScheduleManager_UpdateSchedule_UpdatesModifiedAt() async {
        let schedule = SyncSchedule(
            name: "Test Modified",
            sourceRemote: "gdrive",
            sourcePath: "/",
            destinationRemote: "proton",
            destinationPath: "/"
        )

        manager.addSchedule(schedule)

        let originalModified = manager.schedules.first { $0.id == schedule.id }?.modifiedAt

        // Wait a tiny bit to ensure different timestamp
        try? await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds

        var toUpdate = schedule
        toUpdate.name = "Modified"
        manager.updateSchedule(toUpdate)

        let newModified = manager.schedules.first { $0.id == schedule.id }?.modifiedAt

        XCTAssertNotNil(originalModified)
        XCTAssertNotNil(newModified)
        if let orig = originalModified, let new = newModified {
            XCTAssertGreaterThanOrEqual(new, orig)
        }
    }

    // MARK: - Delete Schedule Tests

    func test_ScheduleManager_DeleteSchedule_RemovesFromList() async {
        let schedule = SyncSchedule(
            name: "Test Delete",
            sourceRemote: "gdrive",
            sourcePath: "/",
            destinationRemote: "proton",
            destinationPath: "/"
        )

        manager.addSchedule(schedule)
        XCTAssertTrue(manager.schedules.contains { $0.id == schedule.id })

        manager.deleteSchedule(id: schedule.id)
        XCTAssertFalse(manager.schedules.contains { $0.id == schedule.id })
    }

    // MARK: - Toggle Schedule Tests

    func test_ScheduleManager_ToggleSchedule_DisablesEnabled() async {
        var schedule = SyncSchedule(
            name: "Test Toggle",
            sourceRemote: "gdrive",
            sourcePath: "/",
            destinationRemote: "proton",
            destinationPath: "/"
        )
        schedule.isEnabled = true

        manager.addSchedule(schedule)
        manager.toggleSchedule(id: schedule.id)

        let toggled = manager.schedules.first { $0.id == schedule.id }
        XCTAssertFalse(toggled?.isEnabled ?? true)
    }

    func test_ScheduleManager_ToggleSchedule_EnablesDisabled() async {
        var schedule = SyncSchedule(
            name: "Test Toggle",
            sourceRemote: "gdrive",
            sourcePath: "/",
            destinationRemote: "proton",
            destinationPath: "/"
        )

        manager.addSchedule(schedule)

        // Disable first
        manager.toggleSchedule(id: schedule.id)
        let disabled = manager.schedules.first { $0.id == schedule.id }
        XCTAssertFalse(disabled?.isEnabled ?? true)

        // Enable again
        manager.toggleSchedule(id: schedule.id)
        let enabled = manager.schedules.first { $0.id == schedule.id }
        XCTAssertTrue(enabled?.isEnabled ?? false)
    }

    func test_ScheduleManager_ToggleSchedule_ClearsNextRunWhenDisabled() async {
        let schedule = SyncSchedule(
            name: "Test Toggle NextRun",
            sourceRemote: "gdrive",
            sourcePath: "/",
            destinationRemote: "proton",
            destinationPath: "/"
        )

        manager.addSchedule(schedule)

        // Should have nextRunAt when enabled
        let added = manager.schedules.first { $0.id == schedule.id }
        XCTAssertNotNil(added?.nextRunAt)

        // Disable
        manager.toggleSchedule(id: schedule.id)

        let disabled = manager.schedules.first { $0.id == schedule.id }
        XCTAssertNil(disabled?.nextRunAt)
    }

    // MARK: - Helper Property Tests

    func test_ScheduleManager_EnabledSchedulesCount() async {
        // Add 3 schedules
        for i in 1...3 {
            let schedule = SyncSchedule(
                name: "Schedule \(i)",
                sourceRemote: "gdrive",
                sourcePath: "/",
                destinationRemote: "proton",
                destinationPath: "/"
            )
            manager.addSchedule(schedule)
        }

        XCTAssertEqual(manager.enabledSchedulesCount, 3)

        // Disable one
        if let first = manager.schedules.first {
            manager.toggleSchedule(id: first.id)
        }

        XCTAssertEqual(manager.enabledSchedulesCount, 2)
    }

    func test_ScheduleManager_NextScheduledRun_ReturnsEarliest() async {
        // Add schedule running in 2 hours
        let later = SyncSchedule(
            name: "Later",
            sourceRemote: "a",
            sourcePath: "/",
            destinationRemote: "b",
            destinationPath: "/",
            frequency: .custom,
            customIntervalMinutes: 120
        )
        manager.addSchedule(later)

        // Add schedule running in 30 minutes
        let sooner = SyncSchedule(
            name: "Sooner",
            sourceRemote: "a",
            sourcePath: "/",
            destinationRemote: "b",
            destinationPath: "/",
            frequency: .custom,
            customIntervalMinutes: 30
        )
        manager.addSchedule(sooner)

        let next = manager.nextScheduledRun
        XCTAssertNotNil(next)
        XCTAssertEqual(next?.schedule.name, "Sooner")
    }

    // MARK: - Persistence Tests

    func test_ScheduleManager_SaveAndLoad_PersistsSchedules() async {
        let schedule = SyncSchedule(
            name: "Persistence Test",
            sourceRemote: "gdrive",
            sourcePath: "/test",
            destinationRemote: "proton",
            destinationPath: "/backup"
        )

        manager.addSchedule(schedule)
        manager.saveSchedules()

        // Reload
        manager.loadSchedules()

        let loaded = manager.schedules.first { $0.id == schedule.id }
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.name, "Persistence Test")
        XCTAssertEqual(loaded?.sourceRemote, "gdrive")
    }
}
