//
//  SyncScheduleTests.swift
//  CloudSyncAppTests
//
//  Tests for SyncSchedule model
//

import XCTest
@testable import CloudSyncApp

final class SyncScheduleTests: XCTestCase {

    // MARK: - Initialization Tests

    func test_SyncSchedule_Init_SetsDefaultValues() {
        let schedule = SyncSchedule(
            name: "Test Schedule",
            sourceRemote: "gdrive",
            sourcePath: "/documents",
            destinationRemote: "proton",
            destinationPath: "/backup"
        )

        XCTAssertFalse(schedule.id.uuidString.isEmpty)
        XCTAssertEqual(schedule.name, "Test Schedule")
        XCTAssertTrue(schedule.isEnabled)
        XCTAssertEqual(schedule.sourceRemote, "gdrive")
        XCTAssertEqual(schedule.sourcePath, "/documents")
        XCTAssertEqual(schedule.destinationRemote, "proton")
        XCTAssertEqual(schedule.destinationPath, "/backup")
        XCTAssertEqual(schedule.syncType, .transfer)
        XCTAssertFalse(schedule.encryptSource)
        XCTAssertFalse(schedule.encryptDestination)
        XCTAssertEqual(schedule.frequency, .daily)
        XCTAssertEqual(schedule.scheduledHour, 2)
        XCTAssertEqual(schedule.scheduledMinute, 0)
        XCTAssertNil(schedule.lastRunAt)
        XCTAssertEqual(schedule.runCount, 0)
        XCTAssertEqual(schedule.failureCount, 0)
    }

    func test_SyncSchedule_Init_CustomValues() {
        let schedule = SyncSchedule(
            name: "Weekly Backup",
            sourceRemote: "dropbox",
            sourcePath: "/",
            destinationRemote: "s3",
            destinationPath: "/weekly",
            syncType: .backup,
            encryptSource: false,
            encryptDestination: true,
            frequency: .weekly,
            scheduledHour: 3,
            scheduledMinute: 30,
            scheduledDays: Set([1, 7]) // Weekends
        )

        XCTAssertEqual(schedule.syncType, .backup)
        XCTAssertTrue(schedule.encryptDestination)
        XCTAssertEqual(schedule.frequency, .weekly)
        XCTAssertEqual(schedule.scheduledHour, 3)
        XCTAssertEqual(schedule.scheduledMinute, 30)
        XCTAssertEqual(schedule.scheduledDays, Set([1, 7]))
    }

    // MARK: - Computed Properties Tests

    func test_SyncSchedule_HasEncryption_BothFalse() {
        let schedule = SyncSchedule(
            name: "Test",
            sourceRemote: "a",
            sourcePath: "/",
            destinationRemote: "b",
            destinationPath: "/",
            encryptSource: false,
            encryptDestination: false
        )

        XCTAssertFalse(schedule.hasEncryption)
    }

    func test_SyncSchedule_HasEncryption_SourceTrue() {
        let schedule = SyncSchedule(
            name: "Test",
            sourceRemote: "a",
            sourcePath: "/",
            destinationRemote: "b",
            destinationPath: "/",
            encryptSource: true,
            encryptDestination: false
        )

        XCTAssertTrue(schedule.hasEncryption)
    }

    func test_SyncSchedule_HasEncryption_DestinationTrue() {
        let schedule = SyncSchedule(
            name: "Test",
            sourceRemote: "a",
            sourcePath: "/",
            destinationRemote: "b",
            destinationPath: "/",
            encryptSource: false,
            encryptDestination: true
        )

        XCTAssertTrue(schedule.hasEncryption)
    }

    // MARK: - Next Run Calculation Tests

    func test_SyncSchedule_CalculateNextRun_Hourly() {
        let schedule = SyncSchedule(
            name: "Hourly Test",
            sourceRemote: "a",
            sourcePath: "/",
            destinationRemote: "b",
            destinationPath: "/",
            frequency: .hourly,
            scheduledMinute: 30
        )

        let now = Date()
        let calendar = Calendar.current

        guard let nextRun = schedule.calculateNextRun(from: now) else {
            XCTFail("calculateNextRun returned nil")
            return
        }

        // Should be at minute 30 of some hour
        let minute = calendar.component(.minute, from: nextRun)
        XCTAssertEqual(minute, 30)

        // Should be in the future
        XCTAssertGreaterThan(nextRun, now)

        // Should be within 1 hour
        let interval = nextRun.timeIntervalSince(now)
        XCTAssertLessThanOrEqual(interval, 3600)
    }

    func test_SyncSchedule_CalculateNextRun_Daily() {
        let schedule = SyncSchedule(
            name: "Daily Test",
            sourceRemote: "a",
            sourcePath: "/",
            destinationRemote: "b",
            destinationPath: "/",
            frequency: .daily,
            scheduledHour: 14,
            scheduledMinute: 30
        )

        let now = Date()
        let calendar = Calendar.current

        guard let nextRun = schedule.calculateNextRun(from: now) else {
            XCTFail("calculateNextRun returned nil")
            return
        }

        // Should be at 14:30
        let hour = calendar.component(.hour, from: nextRun)
        let minute = calendar.component(.minute, from: nextRun)
        XCTAssertEqual(hour, 14)
        XCTAssertEqual(minute, 30)

        // Should be in the future
        XCTAssertGreaterThan(nextRun, now)
    }

    func test_SyncSchedule_CalculateNextRun_Weekly() {
        let schedule = SyncSchedule(
            name: "Weekly Test",
            sourceRemote: "a",
            sourcePath: "/",
            destinationRemote: "b",
            destinationPath: "/",
            frequency: .weekly,
            scheduledHour: 2,
            scheduledMinute: 0,
            scheduledDays: Set([2]) // Monday only
        )

        let now = Date()
        let calendar = Calendar.current

        guard let nextRun = schedule.calculateNextRun(from: now) else {
            XCTFail("calculateNextRun returned nil")
            return
        }

        // Should be on a Monday (weekday 2)
        let weekday = calendar.component(.weekday, from: nextRun)
        XCTAssertEqual(weekday, 2)

        // Should be in the future
        XCTAssertGreaterThan(nextRun, now)
    }

    func test_SyncSchedule_CalculateNextRun_Weekly_NoDays_ReturnsNil() {
        let schedule = SyncSchedule(
            name: "Weekly Test",
            sourceRemote: "a",
            sourcePath: "/",
            destinationRemote: "b",
            destinationPath: "/",
            frequency: .weekly,
            scheduledDays: Set<Int>() // Empty
        )

        let nextRun = schedule.calculateNextRun()
        XCTAssertNil(nextRun)
    }

    func test_SyncSchedule_CalculateNextRun_Custom() {
        let schedule = SyncSchedule(
            name: "Custom Test",
            sourceRemote: "a",
            sourcePath: "/",
            destinationRemote: "b",
            destinationPath: "/",
            frequency: .custom,
            customIntervalMinutes: 30
        )

        let now = Date()

        guard let nextRun = schedule.calculateNextRun(from: now) else {
            XCTFail("calculateNextRun returned nil")
            return
        }

        // Should be 30 minutes from now
        let interval = nextRun.timeIntervalSince(now)
        XCTAssertEqual(interval, 30 * 60, accuracy: 1)
    }

    // MARK: - Formatted Properties Tests

    func test_SyncSchedule_FormattedSchedule_Hourly() {
        let schedule = SyncSchedule(
            name: "Test",
            sourceRemote: "a",
            sourcePath: "/",
            destinationRemote: "b",
            destinationPath: "/",
            frequency: .hourly
        )

        XCTAssertEqual(schedule.formattedSchedule, "Every hour")
    }

    func test_SyncSchedule_FormattedSchedule_Custom() {
        var schedule = SyncSchedule(
            name: "Test",
            sourceRemote: "a",
            sourcePath: "/",
            destinationRemote: "b",
            destinationPath: "/",
            frequency: .custom,
            customIntervalMinutes: 30
        )

        XCTAssertEqual(schedule.formattedSchedule, "Every 30 min")

        schedule.customIntervalMinutes = 120
        XCTAssertEqual(schedule.formattedSchedule, "Every 2 hr")
    }

    func test_SyncSchedule_FormattedLastRun_Never() {
        let schedule = SyncSchedule(
            name: "Test",
            sourceRemote: "a",
            sourcePath: "/",
            destinationRemote: "b",
            destinationPath: "/"
        )

        XCTAssertEqual(schedule.formattedLastRun, "Never")
    }

    func test_SyncSchedule_FormattedNextRun_NotScheduled() {
        var schedule = SyncSchedule(
            name: "Test",
            sourceRemote: "a",
            sourcePath: "/",
            destinationRemote: "b",
            destinationPath: "/"
        )
        schedule.nextRunAt = nil

        XCTAssertEqual(schedule.formattedNextRun, "Not scheduled")
    }

    // MARK: - Codable Tests

    func test_SyncSchedule_Codable_EncodesAndDecodes() throws {
        let original = SyncSchedule(
            name: "Codable Test",
            sourceRemote: "gdrive",
            sourcePath: "/docs",
            destinationRemote: "proton",
            destinationPath: "/backup",
            syncType: .sync,
            encryptDestination: true,
            frequency: .weekly,
            scheduledHour: 3,
            scheduledMinute: 15,
            scheduledDays: Set([2, 4, 6])
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(SyncSchedule.self, from: data)

        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.name, original.name)
        XCTAssertEqual(decoded.sourceRemote, original.sourceRemote)
        XCTAssertEqual(decoded.destinationRemote, original.destinationRemote)
        XCTAssertEqual(decoded.syncType, original.syncType)
        XCTAssertEqual(decoded.encryptDestination, original.encryptDestination)
        XCTAssertEqual(decoded.frequency, original.frequency)
        XCTAssertEqual(decoded.scheduledHour, original.scheduledHour)
        XCTAssertEqual(decoded.scheduledDays, original.scheduledDays)
    }

    // MARK: - Equatable Tests

    func test_SyncSchedule_Equatable() {
        let id = UUID()

        let schedule1 = SyncSchedule(
            id: id,
            name: "Test",
            sourceRemote: "a",
            sourcePath: "/",
            destinationRemote: "b",
            destinationPath: "/"
        )

        let schedule2 = SyncSchedule(
            id: id,
            name: "Test",
            sourceRemote: "a",
            sourcePath: "/",
            destinationRemote: "b",
            destinationPath: "/"
        )

        // Compare all properties except the timestamp fields which are auto-generated
        XCTAssertEqual(schedule1.id, schedule2.id)
        XCTAssertEqual(schedule1.name, schedule2.name)
        XCTAssertEqual(schedule1.isEnabled, schedule2.isEnabled)
        XCTAssertEqual(schedule1.sourceRemote, schedule2.sourceRemote)
        XCTAssertEqual(schedule1.sourcePath, schedule2.sourcePath)
        XCTAssertEqual(schedule1.destinationRemote, schedule2.destinationRemote)
        XCTAssertEqual(schedule1.destinationPath, schedule2.destinationPath)
        XCTAssertEqual(schedule1.syncType, schedule2.syncType)
        XCTAssertEqual(schedule1.encryptSource, schedule2.encryptSource)
        XCTAssertEqual(schedule1.encryptDestination, schedule2.encryptDestination)
        XCTAssertEqual(schedule1.frequency, schedule2.frequency)
        XCTAssertEqual(schedule1.customIntervalMinutes, schedule2.customIntervalMinutes)
        XCTAssertEqual(schedule1.scheduledHour, schedule2.scheduledHour)
        XCTAssertEqual(schedule1.scheduledMinute, schedule2.scheduledMinute)
        XCTAssertEqual(schedule1.scheduledDays, schedule2.scheduledDays)
        XCTAssertEqual(schedule1.lastRunAt, schedule2.lastRunAt)
        XCTAssertEqual(schedule1.lastRunSuccess, schedule2.lastRunSuccess)
        XCTAssertEqual(schedule1.lastRunError, schedule2.lastRunError)
        XCTAssertEqual(schedule1.nextRunAt, schedule2.nextRunAt)
        XCTAssertEqual(schedule1.runCount, schedule2.runCount)
        XCTAssertEqual(schedule1.failureCount, schedule2.failureCount)
        // Note: Not comparing createdAt and modifiedAt as they are auto-generated with current time
    }
}
