//
//  AnalyticsManager.swift
//  CloudSyncApp
//
//  Privacy-focused analytics with opt-in telemetry
//  Pillar 6: Business Operations - Analytics Integration
//

import Foundation
import CryptoKit
import os

/// Manages privacy-focused analytics with opt-in telemetry
@MainActor
final class AnalyticsManager: ObservableObject {

    // MARK: - Singleton

    static let shared = AnalyticsManager()

    // MARK: - Published Properties

    /// Opt-in telemetry (sends anonymized data to improve the app)
    @Published var telemetryEnabled: Bool {
        didSet {
            UserDefaults.standard.set(telemetryEnabled, forKey: Keys.telemetryEnabled)
            logger.info("Telemetry \(self.telemetryEnabled ? "enabled" : "disabled")")
        }
    }

    /// Local tracking (always available, stored on device only)
    @Published var localTrackingEnabled: Bool {
        didSet {
            UserDefaults.standard.set(localTrackingEnabled, forKey: Keys.localTrackingEnabled)
        }
    }

    /// Current statistics (computed from stored data)
    @Published private(set) var stats: AnalyticsStats

    // MARK: - Private Properties

    private let logger = Logger(subsystem: "com.cloudsync.ultra", category: "analytics")
    private let fileManager = FileManager.default

    private lazy var analyticsDirectory: URL = {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("CloudSyncUltra/Analytics", isDirectory: true)
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        // Set restrictive permissions (owner read/write/execute only)
        try? fileManager.setAttributes([.posixPermissions: 0o700], ofItemAtPath: dir.path)
        return dir
    }()

    private lazy var eventsDirectory: URL = {
        let dir = analyticsDirectory.appendingPathComponent("events", isDirectory: true)
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        try? fileManager.setAttributes([.posixPermissions: 0o700], ofItemAtPath: dir.path)
        return dir
    }()

    private var statsFile: URL {
        analyticsDirectory.appendingPathComponent("stats.json")
    }

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }()

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    // MARK: - Keys

    private enum Keys {
        static let telemetryEnabled = "analytics.telemetryEnabled"
        static let localTrackingEnabled = "analytics.localTrackingEnabled"
    }

    // MARK: - Initialization

    private init() {
        // Load preferences (telemetry is opt-in, default false)
        self.telemetryEnabled = UserDefaults.standard.bool(forKey: Keys.telemetryEnabled)

        // Local tracking is opt-out, default true
        if UserDefaults.standard.object(forKey: Keys.localTrackingEnabled) == nil {
            UserDefaults.standard.set(true, forKey: Keys.localTrackingEnabled)
        }
        self.localTrackingEnabled = UserDefaults.standard.bool(forKey: Keys.localTrackingEnabled)

        // Load existing stats
        self.stats = AnalyticsStats.empty
        loadStats()

        // Track session start
        trackEvent(category: .session, action: .sessionStart)

        // Clean up old events (keep 30 days)
        cleanupOldEvents()

        logger.info("AnalyticsManager initialized (telemetry: \(self.telemetryEnabled), local: \(self.localTrackingEnabled))")
    }

    // MARK: - Public Methods

    /// Track a generic event
    func trackEvent(
        category: AnalyticsCategory,
        action: AnalyticsAction,
        label: String? = nil,
        value: Int64? = nil
    ) {
        guard localTrackingEnabled else { return }

        let event = AnalyticsEvent(
            category: category,
            action: action,
            label: label,
            value: value
        )

        saveEvent(event)
        updateStats(with: event)

        logger.debug("Event tracked: \(category.rawValue).\(action.rawValue)")
    }

    /// Track a transfer event with details
    func trackTransfer(
        provider: String,
        bytes: Int64,
        duration: TimeInterval,
        success: Bool
    ) {
        guard localTrackingEnabled else { return }

        let hashedProvider = hashString(provider)
        let action: AnalyticsAction = success ? .transferComplete : .transferFail

        trackEvent(
            category: .transfer,
            action: action,
            label: hashedProvider,
            value: bytes
        )

        // Update transfer stats
        stats.totalTransfers += 1
        if success {
            stats.successfulTransfers += 1
            stats.totalBytesTransferred += bytes
            stats.totalTransferDuration += duration
        } else {
            stats.failedTransfers += 1
        }
        stats.lastActive = Date()

        // Update provider usage
        stats.providerUsage[hashedProvider, default: 0] += 1

        saveStats()
    }

    /// Track feature usage
    func trackFeatureUsage(_ feature: String, enabled: Bool) {
        guard localTrackingEnabled else { return }

        trackEvent(
            category: .feature,
            action: enabled ? .featureEnable : .featureDisable,
            label: feature
        )

        stats.featureUsage[feature, default: 0] += 1
        saveStats()
    }

    /// Track an error occurrence
    func trackError(category: String) {
        guard localTrackingEnabled else { return }

        trackEvent(
            category: .error,
            action: .errorOccur,
            label: category
        )

        stats.errorCount += 1
        saveStats()
    }

    /// Get current statistics
    func getStats() -> AnalyticsStats {
        return stats
    }

    /// Export all analytics data to a file
    func exportData() async throws -> URL {
        let exportDir = fileManager.temporaryDirectory
            .appendingPathComponent("CloudSyncAnalytics_\(UUID().uuidString)")
        try fileManager.createDirectory(at: exportDir, withIntermediateDirectories: true)

        // Export stats
        let statsData = try encoder.encode(stats)
        let statsExport = exportDir.appendingPathComponent("stats.json")
        try statsData.write(to: statsExport)

        // Export events
        let eventsExport = exportDir.appendingPathComponent("events")
        try fileManager.createDirectory(at: eventsExport, withIntermediateDirectories: true)

        let eventFiles = try fileManager.contentsOfDirectory(at: eventsDirectory, includingPropertiesForKeys: nil)
        for file in eventFiles where file.pathExtension == "json" {
            let destination = eventsExport.appendingPathComponent(file.lastPathComponent)
            try fileManager.copyItem(at: file, to: destination)
        }

        // Create info file
        let info = """
        CloudSync Ultra Analytics Export
        ================================
        Exported: \(ISO8601DateFormatter().string(from: Date()))
        Telemetry Enabled: \(telemetryEnabled)
        Local Tracking: \(localTrackingEnabled)

        This export contains:
        - stats.json: Aggregated usage statistics
        - events/: Daily event logs

        All data is stored locally on your device.
        No personal information is collected.
        """
        let infoFile = exportDir.appendingPathComponent("README.txt")
        try info.write(to: infoFile, atomically: true, encoding: .utf8)

        logger.info("Analytics data exported to: \(exportDir.path, privacy: .private)")
        return exportDir
    }

    /// Clear all analytics data
    func clearData() {
        // Remove events directory
        try? fileManager.removeItem(at: eventsDirectory)
        try? fileManager.createDirectory(at: eventsDirectory, withIntermediateDirectories: true)

        // Reset stats
        stats = AnalyticsStats.empty
        saveStats()

        logger.info("All analytics data cleared")
    }

    // MARK: - Private Methods

    private func saveEvent(_ event: AnalyticsEvent) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: event.timestamp)

        let eventFile = eventsDirectory.appendingPathComponent("\(dateString).json")

        var dailyLog: DailyEventLog

        if fileManager.fileExists(atPath: eventFile.path),
           let data = try? Data(contentsOf: eventFile),
           let existingLog = try? decoder.decode(DailyEventLog.self, from: data) {
            dailyLog = existingLog
        } else {
            dailyLog = DailyEventLog(date: event.timestamp)
        }

        dailyLog.events.append(event)

        if let data = try? encoder.encode(dailyLog) {
            try? data.write(to: eventFile, options: .atomic)
            // Set restrictive permissions
            try? fileManager.setAttributes([.posixPermissions: 0o600], ofItemAtPath: eventFile.path)
        }
    }

    private func updateStats(with event: AnalyticsEvent) {
        switch event.category {
        case .session:
            if event.action == .sessionStart {
                stats.sessionCount += 1
            }
        case .schedule:
            // Tracked separately
            break
        default:
            break
        }

        stats.lastActive = Date()
        saveStats()
    }

    private func loadStats() {
        guard fileManager.fileExists(atPath: statsFile.path),
              let data = try? Data(contentsOf: statsFile),
              let loadedStats = try? decoder.decode(AnalyticsStats.self, from: data) else {
            stats = AnalyticsStats.empty
            return
        }
        stats = loadedStats
    }

    private func saveStats() {
        guard let data = try? encoder.encode(stats) else { return }
        try? data.write(to: statsFile, options: .atomic)
        try? fileManager.setAttributes([.posixPermissions: 0o600], ofItemAtPath: statsFile.path)
    }

    private func cleanupOldEvents() {
        let calendar = Calendar.current
        let cutoffDate = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        guard let files = try? fileManager.contentsOfDirectory(at: eventsDirectory, includingPropertiesForKeys: nil) else {
            return
        }

        for file in files where file.pathExtension == "json" {
            let filename = file.deletingPathExtension().lastPathComponent
            if let fileDate = dateFormatter.date(from: filename), fileDate < cutoffDate {
                try? fileManager.removeItem(at: file)
                logger.debug("Cleaned up old event log: \(filename)")
            }
        }
    }

    /// Hash a string for privacy (e.g., provider names)
    private func hashString(_ input: String) -> String {
        let data = Data(input.utf8)
        let hash = SHA256.hash(data: data)
        return hash.prefix(8).map { String(format: "%02x", $0) }.joined()
    }
}
