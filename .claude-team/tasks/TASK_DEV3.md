# Task: Scheduled Sync - Core Infrastructure

**Assigned to:** Dev-3 (Services)
**Priority:** High
**Status:** Ready

---

## Objective

Build the core scheduling infrastructure: data model and ScheduleManager singleton.

---

## Task 1: Create SyncSchedule Model

**File:** `CloudSyncApp/Models/SyncSchedule.swift`

Create a new file with the SyncSchedule model:

```swift
//
//  SyncSchedule.swift
//  CloudSyncApp
//
//  Data model for scheduled sync jobs
//

import Foundation

enum ScheduleFrequency: String, Codable, CaseIterable {
    case hourly = "Hourly"
    case daily = "Daily"
    case weekly = "Weekly"
    case custom = "Custom Interval"
    
    var icon: String {
        switch self {
        case .hourly: return "clock"
        case .daily: return "calendar"
        case .weekly: return "calendar.badge.clock"
        case .custom: return "timer"
        }
    }
    
    var description: String {
        switch self {
        case .hourly: return "Every hour"
        case .daily: return "Once a day"
        case .weekly: return "Once a week"
        case .custom: return "Custom interval"
        }
    }
}

struct SyncSchedule: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var isEnabled: Bool
    
    // What to sync
    var sourceRemote: String
    var sourcePath: String
    var destinationRemote: String
    var destinationPath: String
    var syncType: TaskType
    var encryptSource: Bool
    var encryptDestination: Bool
    
    // When to sync
    var frequency: ScheduleFrequency
    var customIntervalMinutes: Int?      // For custom frequency (minimum 5 minutes)
    var scheduledHour: Int?              // 0-23 for daily/weekly
    var scheduledMinute: Int?            // 0-59 for daily/weekly
    var scheduledDays: Set<Int>?         // 1-7 for weekly (1=Sunday, 7=Saturday)
    
    // Status tracking
    var lastRunAt: Date?
    var lastRunSuccess: Bool?
    var lastRunError: String?
    var nextRunAt: Date?
    var runCount: Int
    var failureCount: Int
    
    // Metadata
    var createdAt: Date
    var modifiedAt: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        sourceRemote: String,
        sourcePath: String,
        destinationRemote: String,
        destinationPath: String,
        syncType: TaskType = .transfer,
        encryptSource: Bool = false,
        encryptDestination: Bool = false,
        frequency: ScheduleFrequency = .daily,
        customIntervalMinutes: Int? = nil,
        scheduledHour: Int? = 2,
        scheduledMinute: Int? = 0,
        scheduledDays: Set<Int>? = nil
    ) {
        self.id = id
        self.name = name
        self.isEnabled = true
        self.sourceRemote = sourceRemote
        self.sourcePath = sourcePath
        self.destinationRemote = destinationRemote
        self.destinationPath = destinationPath
        self.syncType = syncType
        self.encryptSource = encryptSource
        self.encryptDestination = encryptDestination
        self.frequency = frequency
        self.customIntervalMinutes = customIntervalMinutes
        self.scheduledHour = scheduledHour
        self.scheduledMinute = scheduledMinute
        self.scheduledDays = scheduledDays
        self.lastRunAt = nil
        self.lastRunSuccess = nil
        self.lastRunError = nil
        self.nextRunAt = nil
        self.runCount = 0
        self.failureCount = 0
        self.createdAt = Date()
        self.modifiedAt = Date()
    }
    
    // MARK: - Computed Properties
    
    var hasEncryption: Bool {
        encryptSource || encryptDestination
    }
    
    var formattedNextRun: String {
        guard let next = nextRunAt else { return "Not scheduled" }
        
        let now = Date()
        let interval = next.timeIntervalSince(now)
        
        if interval < 0 {
            return "Overdue"
        } else if interval < 60 {
            return "In less than a minute"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "In \(minutes) min"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "In \(hours) hr"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.string(from: next)
        }
    }
    
    var formattedLastRun: String {
        guard let last = lastRunAt else { return "Never" }
        
        let now = Date()
        let interval = now.timeIntervalSince(last)
        
        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes) min ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours) hr ago"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.string(from: last)
        }
    }
    
    var formattedSchedule: String {
        switch frequency {
        case .hourly:
            return "Every hour"
        case .daily:
            let hour = scheduledHour ?? 0
            let minute = scheduledMinute ?? 0
            return "Daily at \(formatTime(hour: hour, minute: minute))"
        case .weekly:
            let hour = scheduledHour ?? 0
            let minute = scheduledMinute ?? 0
            let days = formattedDays
            return "\(days) at \(formatTime(hour: hour, minute: minute))"
        case .custom:
            let minutes = customIntervalMinutes ?? 60
            if minutes < 60 {
                return "Every \(minutes) min"
            } else {
                let hours = minutes / 60
                return "Every \(hours) hr"
            }
        }
    }
    
    private var formattedDays: String {
        guard let days = scheduledDays, !days.isEmpty else { return "No days" }
        
        let dayNames = ["", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let sortedDays = days.sorted()
        
        if days.count == 7 {
            return "Every day"
        } else if days == Set([2, 3, 4, 5, 6]) {
            return "Weekdays"
        } else if days == Set([1, 7]) {
            return "Weekends"
        } else {
            return sortedDays.map { dayNames[$0] }.joined(separator: ", ")
        }
    }
    
    private func formatTime(hour: Int, minute: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let date = Calendar.current.date(from: components) ?? Date()
        return formatter.string(from: date)
    }
    
    // MARK: - Next Run Calculation
    
    func calculateNextRun(from date: Date = Date()) -> Date? {
        let calendar = Calendar.current
        
        switch frequency {
        case .hourly:
            var components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
            components.minute = scheduledMinute ?? 0
            components.second = 0
            
            guard var next = calendar.date(from: components) else { return nil }
            
            if next <= date {
                next = calendar.date(byAdding: .hour, value: 1, to: next) ?? next
            }
            return next
            
        case .daily:
            var components = calendar.dateComponents([.year, .month, .day], from: date)
            components.hour = scheduledHour ?? 2
            components.minute = scheduledMinute ?? 0
            components.second = 0
            
            guard var next = calendar.date(from: components) else { return nil }
            
            if next <= date {
                next = calendar.date(byAdding: .day, value: 1, to: next) ?? next
            }
            return next
            
        case .weekly:
            guard let days = scheduledDays, !days.isEmpty else { return nil }
            
            let hour = scheduledHour ?? 2
            let minute = scheduledMinute ?? 0
            
            var checkDate = date
            for _ in 0..<8 {
                let weekday = calendar.component(.weekday, from: checkDate)
                
                if days.contains(weekday) {
                    var components = calendar.dateComponents([.year, .month, .day], from: checkDate)
                    components.hour = hour
                    components.minute = minute
                    components.second = 0
                    
                    if let candidate = calendar.date(from: components), candidate > date {
                        return candidate
                    }
                }
                
                checkDate = calendar.date(byAdding: .day, value: 1, to: checkDate) ?? checkDate
            }
            return nil
            
        case .custom:
            let minutes = customIntervalMinutes ?? 60
            return calendar.date(byAdding: .minute, value: minutes, to: date)
        }
    }
}
```

---

## Task 2: Create ScheduleManager

**File:** `CloudSyncApp/ScheduleManager.swift`

Create ScheduleManager singleton:

```swift
//
//  ScheduleManager.swift
//  CloudSyncApp
//
//  Manages scheduled sync jobs
//

import Foundation
import Combine
import UserNotifications

@MainActor
class ScheduleManager: ObservableObject {
    static let shared = ScheduleManager()
    
    @Published var schedules: [SyncSchedule] = []
    @Published var isRunning = false
    @Published var currentlyExecutingScheduleId: UUID?
    
    private var timers: [UUID: Timer] = [:]
    private var backgroundCheckTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private let storageKey = "syncSchedules"
    
    private init() {
        loadSchedules()
    }
    
    // MARK: - Persistence
    
    func loadSchedules() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let saved = try? JSONDecoder().decode([SyncSchedule].self, from: data) {
            schedules = saved
            // Recalculate next run times for enabled schedules
            for i in schedules.indices {
                if schedules[i].isEnabled {
                    schedules[i].nextRunAt = schedules[i].calculateNextRun()
                }
            }
            saveSchedules()
        }
    }
    
    func saveSchedules() {
        if let data = try? JSONEncoder().encode(schedules) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    // MARK: - Schedule CRUD
    
    func addSchedule(_ schedule: SyncSchedule) {
        var newSchedule = schedule
        newSchedule.nextRunAt = newSchedule.calculateNextRun()
        schedules.append(newSchedule)
        saveSchedules()
        
        if newSchedule.isEnabled && isRunning {
            scheduleTimer(for: newSchedule)
        }
    }
    
    func updateSchedule(_ schedule: SyncSchedule) {
        guard let index = schedules.firstIndex(where: { $0.id == schedule.id }) else { return }
        
        var updated = schedule
        updated.modifiedAt = Date()
        updated.nextRunAt = updated.isEnabled ? updated.calculateNextRun() : nil
        schedules[index] = updated
        saveSchedules()
        
        // Reschedule timer
        cancelTimer(for: schedule.id)
        if updated.isEnabled && isRunning {
            scheduleTimer(for: updated)
        }
    }
    
    func deleteSchedule(id: UUID) {
        cancelTimer(for: id)
        schedules.removeAll { $0.id == id }
        saveSchedules()
    }
    
    func toggleSchedule(id: UUID) {
        guard let index = schedules.firstIndex(where: { $0.id == id }) else { return }
        
        schedules[index].isEnabled.toggle()
        schedules[index].modifiedAt = Date()
        
        if schedules[index].isEnabled {
            schedules[index].nextRunAt = schedules[index].calculateNextRun()
            if isRunning {
                scheduleTimer(for: schedules[index])
            }
        } else {
            schedules[index].nextRunAt = nil
            cancelTimer(for: id)
        }
        
        saveSchedules()
    }
    
    // MARK: - Scheduler Control
    
    func startScheduler() {
        guard !isRunning else { return }
        isRunning = true
        
        // Schedule timers for all enabled schedules
        for schedule in schedules where schedule.isEnabled {
            scheduleTimer(for: schedule)
        }
        
        // Background check every minute to catch any missed schedules
        backgroundCheckTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkForDueSchedules()
            }
        }
        
        print("[ScheduleManager] Scheduler started with \(schedules.filter { $0.isEnabled }.count) active schedules")
    }
    
    func stopScheduler() {
        isRunning = false
        
        // Cancel all timers
        for id in timers.keys {
            cancelTimer(for: id)
        }
        
        backgroundCheckTimer?.invalidate()
        backgroundCheckTimer = nil
        
        print("[ScheduleManager] Scheduler stopped")
    }
    
    // MARK: - Timer Management
    
    private func scheduleTimer(for schedule: SyncSchedule) {
        guard let nextRun = schedule.nextRunAt else { return }
        
        let interval = nextRun.timeIntervalSince(Date())
        
        if interval <= 0 {
            // Already due, execute now
            Task {
                await executeSchedule(schedule)
            }
            return
        }
        
        // Cancel existing timer if any
        cancelTimer(for: schedule.id)
        
        // Create new timer
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                if let current = self.schedules.first(where: { $0.id == schedule.id }), current.isEnabled {
                    await self.executeSchedule(current)
                }
            }
        }
        
        timers[schedule.id] = timer
        print("[ScheduleManager] Scheduled '\(schedule.name)' to run in \(Int(interval)) seconds")
    }
    
    private func cancelTimer(for id: UUID) {
        timers[id]?.invalidate()
        timers.removeValue(forKey: id)
    }
    
    private func checkForDueSchedules() {
        let now = Date()
        
        for schedule in schedules where schedule.isEnabled {
            if let nextRun = schedule.nextRunAt, nextRun <= now {
                if currentlyExecutingScheduleId != schedule.id {
                    Task {
                        await executeSchedule(schedule)
                    }
                }
            }
        }
    }
    
    // MARK: - Execution
    
    func executeSchedule(_ schedule: SyncSchedule) async {
        guard let index = schedules.firstIndex(where: { $0.id == schedule.id }) else { return }
        guard currentlyExecutingScheduleId == nil else {
            print("[ScheduleManager] Skipping '\(schedule.name)' - another schedule is running")
            return
        }
        
        print("[ScheduleManager] Executing '\(schedule.name)'")
        currentlyExecutingScheduleId = schedule.id
        
        // Create task
        let task = SyncTask(
            name: "Scheduled: \(schedule.name)",
            type: schedule.syncType,
            sourceRemote: schedule.sourceRemote,
            sourcePath: schedule.sourcePath,
            destinationRemote: schedule.destinationRemote,
            destinationPath: schedule.destinationPath,
            encryptSource: schedule.encryptSource,
            encryptDestination: schedule.encryptDestination
        )
        
        // Execute via TasksViewModel
        let tasksVM = TasksViewModel.shared
        tasksVM.tasks.append(task)
        tasksVM.saveTasks()
        
        await tasksVM.startTask(task)
        
        // Check result
        let completedTask = tasksVM.taskHistory.first(where: { $0.id == task.id })
        let success = completedTask?.state == .completed
        
        // Update schedule status
        schedules[index].lastRunAt = Date()
        schedules[index].lastRunSuccess = success
        schedules[index].runCount += 1
        
        if !success {
            schedules[index].failureCount += 1
            schedules[index].lastRunError = completedTask?.errorMessage
        } else {
            schedules[index].lastRunError = nil
        }
        
        // Calculate next run
        schedules[index].nextRunAt = schedules[index].calculateNextRun()
        saveSchedules()
        
        // Schedule next execution
        if schedules[index].isEnabled {
            scheduleTimer(for: schedules[index])
        }
        
        currentlyExecutingScheduleId = nil
        
        // Send notification
        await sendNotification(for: schedule, success: success)
        
        print("[ScheduleManager] Completed '\(schedule.name)' - Success: \(success)")
    }
    
    /// Run a schedule immediately (manual trigger)
    func runNow(id: UUID) async {
        guard let schedule = schedules.first(where: { $0.id == id }) else { return }
        await executeSchedule(schedule)
    }
    
    // MARK: - Notifications
    
    private func sendNotification(for schedule: SyncSchedule, success: Bool) async {
        let content = UNMutableNotificationContent()
        content.title = success ? "Sync Completed" : "Sync Failed"
        content.body = success 
            ? "'\(schedule.name)' completed successfully"
            : "'\(schedule.name)' failed. Check the app for details."
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("[ScheduleManager] Failed to send notification: \(error)")
        }
    }
    
    // MARK: - Helpers
    
    var enabledSchedulesCount: Int {
        schedules.filter { $0.isEnabled }.count
    }
    
    var nextScheduledRun: (schedule: SyncSchedule, date: Date)? {
        schedules
            .filter { $0.isEnabled && $0.nextRunAt != nil }
            .compactMap { schedule -> (SyncSchedule, Date)? in
                guard let next = schedule.nextRunAt else { return nil }
                return (schedule, next)
            }
            .min { $0.1 < $1.1 }
    }
    
    var formattedNextRun: String {
        guard let next = nextScheduledRun else { return "No schedules" }
        return "\(next.schedule.name): \(next.schedule.formattedNextRun)"
    }
}
```

---

## Task 3: Initialize ScheduleManager in App

**File:** `CloudSyncApp/CloudSyncAppApp.swift`

Add to the app's init or onAppear:

```swift
// In the main App struct, add:
ScheduleManager.shared.startScheduler()
```

---

## Acceptance Criteria

- [ ] `SyncSchedule.swift` model compiles with all properties
- [ ] `ScheduleManager.swift` compiles and initializes
- [ ] Schedules persist to UserDefaults
- [ ] `calculateNextRun()` returns correct dates for all frequency types
- [ ] Timers fire at correct times
- [ ] Schedule execution creates tasks in TasksViewModel
- [ ] Build succeeds with zero errors

---

## When Complete

1. Update STATUS.md with completion
2. Write DEV3_COMPLETE.md with summary
3. Verify build: `xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build`
