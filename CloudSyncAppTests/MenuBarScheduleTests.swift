//
//  MenuBarScheduleTests.swift
//  CloudSyncAppTests
//
//  Tests for menu bar schedule indicator display
//

import XCTest
@testable import CloudSyncApp

@MainActor
final class MenuBarScheduleTests: XCTestCase {

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

    // MARK: - Empty State Tests

    func test_NoSchedules_ReturnsNil() async {
        // No schedules added
        XCTAssertNil(manager.nextScheduledRun)
    }

    func test_NoEnabledSchedules_ReturnsNil() async {
        let schedule = SyncSchedule(
            name: "Disabled Schedule",
            sourceRemote: "gdrive",
            sourcePath: "/",
            destinationRemote: "proton",
            destinationPath: "/"
        )
        manager.addSchedule(schedule)

        // Disable it
        manager.toggleSchedule(id: schedule.id)

        XCTAssertNil(manager.nextScheduledRun)
    }

    // MARK: - Display Format Tests

    func test_FormattedNextRun_NoSchedules() async {
        XCTAssertEqual(manager.formattedNextRun, "No schedules")
    }

    func test_FormattedNextRun_WithSchedule() async {
        let schedule = SyncSchedule(
            name: "Daily Backup",
            sourceRemote: "gdrive",
            sourcePath: "/",
            destinationRemote: "proton",
            destinationPath: "/",
            frequency: .daily,
            scheduledHour: 14,
            scheduledMinute: 30
        )
        manager.addSchedule(schedule)

        let formatted = manager.formattedNextRun

        // Should contain the schedule name
        XCTAssertTrue(formatted.contains("Daily Backup"))
    }

    // MARK: - Next Schedule Selection Tests

    func test_NextScheduledRun_ReturnsSoonest() async {
        // Add schedule running in 2 hours
        let later = SyncSchedule(
            name: "Later Schedule",
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
            name: "Sooner Schedule",
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
        XCTAssertEqual(next?.schedule.name, "Sooner Schedule")
    }

    func test_NextScheduledRun_IgnoresDisabledSchedules() async {
        // Add enabled schedule running in 2 hours
        let enabled = SyncSchedule(
            name: "Enabled Schedule",
            sourceRemote: "a",
            sourcePath: "/",
            destinationRemote: "b",
            destinationPath: "/",
            frequency: .custom,
            customIntervalMinutes: 120
        )
        manager.addSchedule(enabled)

        // Add disabled schedule that would run sooner
        let disabled = SyncSchedule(
            name: "Disabled Schedule",
            sourceRemote: "a",
            sourcePath: "/",
            destinationRemote: "b",
            destinationPath: "/",
            frequency: .custom,
            customIntervalMinutes: 10
        )
        manager.addSchedule(disabled)
        manager.toggleSchedule(id: disabled.id) // Disable it

        let next = manager.nextScheduledRun
        XCTAssertNotNil(next)
        XCTAssertEqual(next?.schedule.name, "Enabled Schedule")
    }

    // MARK: - Time Formatting Tests

    func test_FormattedNextRun_LessThanOneMinute() async {
        var schedule = SyncSchedule(
            name: "Imminent",
            sourceRemote: "a",
            sourcePath: "/",
            destinationRemote: "b",
            destinationPath: "/",
            frequency: .custom,
            customIntervalMinutes: 5
        )

        // Manually set nextRunAt to 30 seconds from now
        schedule.nextRunAt = Date().addingTimeInterval(30)

        let formatted = schedule.formattedNextRun
        XCTAssertEqual(formatted, "In less than a minute")
    }

    func test_FormattedNextRun_Minutes() async {
        var schedule = SyncSchedule(
            name: "Soon",
            sourceRemote: "a",
            sourcePath: "/",
            destinationRemote: "b",
            destinationPath: "/",
            frequency: .custom,
            customIntervalMinutes: 5
        )

        // Set nextRunAt to 15 minutes from now
        schedule.nextRunAt = Date().addingTimeInterval(15 * 60)

        let formatted = schedule.formattedNextRun
        // Allow for timing edge cases (14-15 min)
        XCTAssertTrue(formatted == "In 14 min" || formatted == "In 15 min",
                      "Expected 'In 14 min' or 'In 15 min', got '\(formatted)'")
    }

    func test_FormattedNextRun_Hours() async {
        var schedule = SyncSchedule(
            name: "Later",
            sourceRemote: "a",
            sourcePath: "/",
            destinationRemote: "b",
            destinationPath: "/",
            frequency: .custom,
            customIntervalMinutes: 60
        )

        // Set nextRunAt to 3 hours + 30 minutes from now (to avoid boundary issues)
        schedule.nextRunAt = Date().addingTimeInterval(3 * 3600 + 1800)

        let formatted = schedule.formattedNextRun
        XCTAssertEqual(formatted, "In 3 hr")
    }

    func test_FormattedNextRun_Overdue() async {
        var schedule = SyncSchedule(
            name: "Overdue",
            sourceRemote: "a",
            sourcePath: "/",
            destinationRemote: "b",
            destinationPath: "/",
            frequency: .custom,
            customIntervalMinutes: 5
        )

        // Set nextRunAt to 5 minutes ago
        schedule.nextRunAt = Date().addingTimeInterval(-5 * 60)

        let formatted = schedule.formattedNextRun
        XCTAssertEqual(formatted, "Overdue")
    }

    func test_FormattedNextRun_NotScheduled() async {
        var schedule = SyncSchedule(
            name: "Not Scheduled",
            sourceRemote: "a",
            sourcePath: "/",
            destinationRemote: "b",
            destinationPath: "/"
        )
        schedule.nextRunAt = nil

        let formatted = schedule.formattedNextRun
        XCTAssertEqual(formatted, "Not scheduled")
    }
}
