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
