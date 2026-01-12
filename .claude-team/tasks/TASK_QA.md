# Task: Scheduled Sync - Test Coverage

**Assigned to:** QA (Testing)
**Priority:** High
**Status:** Ready

---

## Objective

Write comprehensive unit tests for the SyncSchedule model and ScheduleManager.

---

## Task 1: Create SyncScheduleTests

**File:** `CloudSyncAppTests/SyncScheduleTests.swift`

```swift
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
        
        XCTAssertEqual(schedule1, schedule2)
    }
}
```

---

## Task 2: Create ScheduleManagerTests

**File:** `CloudSyncAppTests/ScheduleManagerTests.swift`

```swift
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
```

---

## Task 3: Create ScheduleFrequencyTests

**File:** `CloudSyncAppTests/ScheduleFrequencyTests.swift`

```swift
//
//  ScheduleFrequencyTests.swift
//  CloudSyncAppTests
//
//  Tests for ScheduleFrequency enum
//

import XCTest
@testable import CloudSyncApp

final class ScheduleFrequencyTests: XCTestCase {
    
    func test_ScheduleFrequency_AllCases() {
        let allCases = ScheduleFrequency.allCases
        XCTAssertEqual(allCases.count, 4)
        XCTAssertTrue(allCases.contains(.hourly))
        XCTAssertTrue(allCases.contains(.daily))
        XCTAssertTrue(allCases.contains(.weekly))
        XCTAssertTrue(allCases.contains(.custom))
    }
    
    func test_ScheduleFrequency_RawValues() {
        XCTAssertEqual(ScheduleFrequency.hourly.rawValue, "Hourly")
        XCTAssertEqual(ScheduleFrequency.daily.rawValue, "Daily")
        XCTAssertEqual(ScheduleFrequency.weekly.rawValue, "Weekly")
        XCTAssertEqual(ScheduleFrequency.custom.rawValue, "Custom Interval")
    }
    
    func test_ScheduleFrequency_Icons() {
        XCTAssertEqual(ScheduleFrequency.hourly.icon, "clock")
        XCTAssertEqual(ScheduleFrequency.daily.icon, "calendar")
        XCTAssertEqual(ScheduleFrequency.weekly.icon, "calendar.badge.clock")
        XCTAssertEqual(ScheduleFrequency.custom.icon, "timer")
    }
    
    func test_ScheduleFrequency_Descriptions() {
        XCTAssertEqual(ScheduleFrequency.hourly.description, "Every hour")
        XCTAssertEqual(ScheduleFrequency.daily.description, "Once a day")
        XCTAssertEqual(ScheduleFrequency.weekly.description, "Once a week")
        XCTAssertEqual(ScheduleFrequency.custom.description, "Custom interval")
    }
    
    func test_ScheduleFrequency_Codable() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        for frequency in ScheduleFrequency.allCases {
            let data = try encoder.encode(frequency)
            let decoded = try decoder.decode(ScheduleFrequency.self, from: data)
            XCTAssertEqual(decoded, frequency)
        }
    }
}
```

---

## Acceptance Criteria

- [ ] All SyncScheduleTests pass
- [ ] All ScheduleManagerTests pass
- [ ] All ScheduleFrequencyTests pass
- [ ] Test coverage for:
  - Model initialization
  - Computed properties
  - Next run calculations (all frequencies)
  - Codable encoding/decoding
  - Manager CRUD operations
  - Toggle functionality
  - Persistence
- [ ] Build and test succeed: `xcodebuild test -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -destination 'platform=macOS'`

---

## When Complete

1. Update STATUS.md with completion
2. Write QA_REPORT.md with:
   - Number of tests added
   - All test results
   - Any issues found
3. Run full test suite and report results
