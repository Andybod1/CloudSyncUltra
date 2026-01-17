//
//  AnalyticsEvent.swift
//  CloudSyncApp
//
//  Analytics event and statistics models for privacy-focused telemetry
//

import Foundation

/// Category of analytics events
enum AnalyticsCategory: String, Codable {
    case session = "session"
    case transfer = "transfer"
    case provider = "provider"
    case schedule = "schedule"
    case feature = "feature"
    case error = "error"
}

/// Actions within each category
enum AnalyticsAction: String, Codable {
    // Session
    case sessionStart = "start"
    case sessionEnd = "end"

    // Transfer
    case transferStart = "transfer_start"
    case transferComplete = "transfer_complete"
    case transferFail = "transfer_fail"

    // Provider
    case providerConnect = "connect"
    case providerDisconnect = "disconnect"

    // Schedule
    case scheduleCreate = "create"
    case scheduleRun = "run"
    case scheduleDelete = "delete"

    // Feature
    case featureEnable = "enable"
    case featureDisable = "disable"

    // Error
    case errorOccur = "occur"
}

/// A single analytics event (stored locally)
struct AnalyticsEvent: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let category: AnalyticsCategory
    let action: AnalyticsAction
    let label: String?      // Anonymized context (e.g., hashed provider name)
    let value: Int64?       // Numeric value (bytes, duration, count)

    init(
        category: AnalyticsCategory,
        action: AnalyticsAction,
        label: String? = nil,
        value: Int64? = nil
    ) {
        self.id = UUID()
        self.timestamp = Date()
        self.category = category
        self.action = action
        self.label = label
        self.value = value
    }
}

/// Aggregated analytics statistics (for display to user)
struct AnalyticsStats: Codable {
    var sessionCount: Int
    var totalTransfers: Int
    var successfulTransfers: Int
    var failedTransfers: Int
    var totalBytesTransferred: Int64
    var totalTransferDuration: TimeInterval
    var featureUsage: [String: Int]
    var providerUsage: [String: Int]  // Hashed provider names
    var errorCount: Int
    var firstSeen: Date
    var lastActive: Date

    /// Success rate as a percentage
    var successRate: Double {
        guard totalTransfers > 0 else { return 100.0 }
        return Double(successfulTransfers) / Double(totalTransfers) * 100.0
    }

    /// Average transfer speed in bytes per second
    var averageTransferSpeed: Double {
        guard totalTransferDuration > 0 else { return 0 }
        return Double(totalBytesTransferred) / totalTransferDuration
    }

    /// Error rate as a percentage
    var errorRate: Double {
        guard totalTransfers > 0 else { return 0 }
        return Double(failedTransfers) / Double(totalTransfers) * 100.0
    }

    /// Empty stats for new installations
    static var empty: AnalyticsStats {
        AnalyticsStats(
            sessionCount: 0,
            totalTransfers: 0,
            successfulTransfers: 0,
            failedTransfers: 0,
            totalBytesTransferred: 0,
            totalTransferDuration: 0,
            featureUsage: [:],
            providerUsage: [:],
            errorCount: 0,
            firstSeen: Date(),
            lastActive: Date()
        )
    }
}

/// Daily event log container
struct DailyEventLog: Codable {
    let date: String  // Format: "yyyy-MM-dd"
    var events: [AnalyticsEvent]

    init(date: Date = Date()) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.date = formatter.string(from: date)
        self.events = []
    }
}
