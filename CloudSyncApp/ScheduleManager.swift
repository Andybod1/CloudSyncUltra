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
            guard let strongSelf = self else { return }
            Task { @MainActor in
                strongSelf.checkForDueSchedules()
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
            guard let strongSelf = self else { return }
            Task { @MainActor in
                if let current = strongSelf.schedules.first(where: { $0.id == schedule.id }), current.isEnabled {
                    await strongSelf.executeSchedule(current)
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

    /// Look up rclone config name from display name
    private func rcloneName(for displayName: String) -> String {
        let remotesVM = RemotesViewModel.shared
        return remotesVM.configuredRemotes.first { $0.name == displayName }?.rcloneName ?? displayName
    }

    func executeSchedule(_ schedule: SyncSchedule) async {
        guard let index = schedules.firstIndex(where: { $0.id == schedule.id }) else { return }
        guard currentlyExecutingScheduleId == nil else {
            print("[ScheduleManager] Skipping '\(schedule.name)' - another schedule is running")
            return
        }

        print("[ScheduleManager] Executing '\(schedule.name)'")
        currentlyExecutingScheduleId = schedule.id

        // Look up actual rclone config names from display names
        let sourceRcloneName = rcloneName(for: schedule.sourceRemote)
        let destRcloneName = rcloneName(for: schedule.destinationRemote)
        print("[ScheduleManager] Source: \(schedule.sourceRemote) -> \(sourceRcloneName)")
        print("[ScheduleManager] Dest: \(schedule.destinationRemote) -> \(destRcloneName)")

        // Create task with rclone config names
        let task = SyncTask(
            name: "Scheduled: \(schedule.name)",
            type: schedule.syncType,
            sourceRemote: sourceRcloneName,
            sourcePath: schedule.sourcePath,
            destinationRemote: destRcloneName,
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
