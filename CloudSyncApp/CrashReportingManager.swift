import Foundation
import OSLog

/// Manages crash reporting and log collection for CloudSync Ultra
/// Privacy-first: All data stays local, user controls sharing
final class CrashReportingManager {
    static let shared = CrashReportingManager()

    private let logger = Logger(subsystem: "com.cloudsync.ultra", category: "CrashReporting")
    private let logDirectory: URL
    private let crashReportsDirectory: URL

    // Keys for UserDefaults
    private let previousCrashKey = "com.cloudsync.previousCrashDetected"
    private let lastCrashDateKey = "com.cloudsync.lastCrashDate"

    private init() {
        // Store logs in Application Support
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        logDirectory = appSupport.appendingPathComponent("CloudSyncUltra/Logs", isDirectory: true)
        crashReportsDirectory = appSupport.appendingPathComponent("CloudSyncUltra/CrashReports", isDirectory: true)

        // Ensure directories exist with restrictive permissions
        try? FileManager.default.createDirectory(at: logDirectory, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: crashReportsDirectory, withIntermediateDirectories: true)

        // Set restrictive permissions on the directories (owner read/write/execute only)
        try? FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: logDirectory.path)
        try? FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: crashReportsDirectory.path)
    }

    // MARK: - Setup

    /// Call this at app launch to install crash handlers
    func setup() {
        // Check for previous crashes
        checkForPreviousCrashes()

        // Install handlers
        installExceptionHandler()
        installSignalHandlers()
        logger.info("Crash reporting initialized")
    }

    // MARK: - Previous Crash Detection

    /// Checks if there was a crash in the previous session
    func hasPreviousCrash() -> Bool {
        return UserDefaults.standard.bool(forKey: previousCrashKey)
    }

    /// Gets the date of the last crash if available
    func lastCrashDate() -> Date? {
        return UserDefaults.standard.object(forKey: lastCrashDateKey) as? Date
    }

    /// Clears the previous crash flag
    func clearPreviousCrashFlag() {
        UserDefaults.standard.removeObject(forKey: previousCrashKey)
        UserDefaults.standard.removeObject(forKey: lastCrashDateKey)
    }

    private func checkForPreviousCrashes() {
        // Check if there are any crash reports
        let crashReports = getAllCrashReports()
        if !crashReports.isEmpty {
            // Find the most recent crash
            let mostRecent = crashReports.max(by: { $0.date < $1.date })
            if let crash = mostRecent {
                UserDefaults.standard.set(true, forKey: previousCrashKey)
                UserDefaults.standard.set(crash.date, forKey: lastCrashDateKey)
                logger.warning("Previous crash detected from: \(crash.date)")
            }
        }
    }

    // MARK: - Exception Handling

    private func installExceptionHandler() {
        NSSetUncaughtExceptionHandler { exception in
            // swiftlint:disable:next prefer_self_in_static_references
            CrashReportingManager.shared.handleException(exception)
        }
    }

    private func installSignalHandlers() {
        // Handle common crash signals
        // C function pointers cannot capture Self - must use explicit type name
        // swiftlint:disable:next prefer_self_in_static_references
        signal(SIGABRT) { sig in CrashReportingManager.shared.handleSignal("SIGABRT", signal: sig) }
        // swiftlint:disable:next prefer_self_in_static_references
        signal(SIGILL) { sig in CrashReportingManager.shared.handleSignal("SIGILL", signal: sig) }
        // swiftlint:disable:next prefer_self_in_static_references
        signal(SIGSEGV) { sig in CrashReportingManager.shared.handleSignal("SIGSEGV", signal: sig) }
        // swiftlint:disable:next prefer_self_in_static_references
        signal(SIGBUS) { sig in CrashReportingManager.shared.handleSignal("SIGBUS", signal: sig) }
        // swiftlint:disable:next prefer_self_in_static_references
        signal(SIGTRAP) { sig in CrashReportingManager.shared.handleSignal("SIGTRAP", signal: sig) }
    }

    private func handleException(_ exception: NSException) {
        let reason = "\(exception.name.rawValue): \(exception.reason ?? "Unknown")"
        let stackTrace = exception.callStackSymbols

        let crashReport = CrashReport(
            type: .exception,
            reason: reason,
            stackTrace: stackTrace
        )

        saveCrashReport(crashReport)

        // Also save as legacy log format for compatibility
        saveCrashLog(crashReport.formattedDescription)
    }

    private func handleSignal(_ signalName: String, signal: Int32) {
        // Get current thread's call stack
        let stackTrace = Thread.callStackSymbols

        let crashReport = CrashReport(
            type: .signal,
            reason: "Signal \(signalName) (\(signal))",
            stackTrace: stackTrace
        )

        saveCrashReport(crashReport)

        // Also save as legacy log format for compatibility
        saveCrashLog(crashReport.formattedDescription)
    }

    // MARK: - Crash Report Storage

    private func saveCrashReport(_ report: CrashReport) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        do {
            let data = try encoder.encode(report)
            let filename = "crash_\(ISO8601DateFormatter().string(from: report.date)).json"
            let fileURL = crashReportsDirectory.appendingPathComponent(filename)

            try data.write(to: fileURL)

            // Set restrictive permissions on crash report files (owner read/write only)
            try? FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: fileURL.path)

            logger.error("Crash report saved: \(filename)")
        } catch {
            logger.error("Failed to save crash report: \(error)")
        }
    }

    private func saveCrashLog(_ content: String) {
        let filename = "crash_\(ISO8601DateFormatter().string(from: Date())).log"
        let fileURL = logDirectory.appendingPathComponent(filename)

        try? content.write(to: fileURL, atomically: true, encoding: .utf8)
        // Set restrictive permissions on crash log files (owner read/write only)
        try? FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: fileURL.path)
    }

    // MARK: - Crash Report Retrieval

    /// Gets all stored crash reports
    func getAllCrashReports() -> [CrashReport] {
        var reports: [CrashReport] = []

        do {
            let files = try FileManager.default.contentsOfDirectory(
                at: crashReportsDirectory,
                includingPropertiesForKeys: nil
            )

            let decoder = JSONDecoder()

            for file in files where file.pathExtension == "json" {
                do {
                    let data = try Data(contentsOf: file)
                    let report = try decoder.decode(CrashReport.self, from: data)
                    reports.append(report)
                } catch {
                    logger.error("Failed to decode crash report \(file.lastPathComponent): \(error)")
                }
            }
        } catch {
            logger.error("Failed to read crash reports directory: \(error)")
        }

        // Sort by date, newest first
        return reports.sorted { $0.date > $1.date }
    }

    /// Gets the count of stored crash reports
    func getCrashReportCount() -> Int {
        return getAllCrashReports().count
    }

    /// Deletes a specific crash report
    func deleteCrashReport(_ report: CrashReport) {
        let filename = "crash_\(ISO8601DateFormatter().string(from: report.date)).json"
        let fileURL = crashReportsDirectory.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: fileURL)
    }

    // MARK: - Log Export

    /// Returns URL to zip file containing all logs
    /// Security: Uses secure temporary directory creation with restrictive permissions
    func exportLogs() throws -> URL {
        // Collect system logs
        let systemLogs = collectSystemLogs()

        // Collect crash logs
        let crashLogs = try FileManager.default.contentsOfDirectory(at: logDirectory, includingPropertiesForKeys: nil)

        // Collect crash reports
        let crashReportFiles = try FileManager.default.contentsOfDirectory(at: crashReportsDirectory, includingPropertiesForKeys: nil)

        // Create export directory securely using unique random identifier
        // This prevents predictable path attacks (TOCTOU vulnerabilities)
        let uniqueId = UUID().uuidString
        let exportDir = FileManager.default.temporaryDirectory.appendingPathComponent("CloudSyncLogs_\(uniqueId)")
        try FileManager.default.createDirectory(at: exportDir, withIntermediateDirectories: true)

        // Set restrictive permissions on the export directory (owner read/write/execute only)
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o700],
            ofItemAtPath: exportDir.path
        )

        // Copy logs with restrictive permissions
        let systemLogURL = exportDir.appendingPathComponent("system.log")
        try systemLogs.write(to: systemLogURL, atomically: true, encoding: .utf8)
        try? FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: systemLogURL.path)

        // Create subdirectory for crash logs
        let crashLogsDir = exportDir.appendingPathComponent("crash_logs")
        try FileManager.default.createDirectory(at: crashLogsDir, withIntermediateDirectories: true)

        for crashLog in crashLogs {
            let dest = crashLogsDir.appendingPathComponent(crashLog.lastPathComponent)
            try? FileManager.default.copyItem(at: crashLog, to: dest)
            try? FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: dest.path)
        }

        // Create subdirectory for crash reports
        let crashReportsDir = exportDir.appendingPathComponent("crash_reports")
        try FileManager.default.createDirectory(at: crashReportsDir, withIntermediateDirectories: true)

        for crashReport in crashReportFiles {
            let dest = crashReportsDir.appendingPathComponent(crashReport.lastPathComponent)
            try? FileManager.default.copyItem(at: crashReport, to: dest)
            try? FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: dest.path)
        }

        // Create zip with unique name
        let zipURL = FileManager.default.temporaryDirectory.appendingPathComponent("CloudSyncLogs_\(uniqueId).zip")
        try? FileManager.default.removeItem(at: zipURL)

        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/zip")
        task.arguments = ["-r", zipURL.path, exportDir.lastPathComponent]
        task.currentDirectoryURL = exportDir.deletingLastPathComponent()
        try task.run()
        task.waitUntilExit()

        // Set restrictive permissions on the zip file
        try? FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: zipURL.path)

        // Clean up the export directory after zipping
        try? FileManager.default.removeItem(at: exportDir)

        return zipURL
    }

    private func collectSystemLogs() -> String {
        // Use OSLog to get recent app logs
        var logs = "=== SYSTEM LOGS ===\n"
        logs += "Date: \(Date())\n"
        logs += "App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "Unknown")\n"
        logs += "Build: \(Bundle.main.infoDictionary?["CFBundleVersion"] ?? "Unknown")\n"
        logs += "macOS: \(ProcessInfo.processInfo.operatingSystemVersionString)\n\n"

        // Note: Actual OSLog retrieval requires OSLogStore (macOS 12+)
        // For now, include basic system info
        logs += "Memory: \(ProcessInfo.processInfo.physicalMemory / 1024 / 1024 / 1024) GB\n"
        logs += "Processors: \(ProcessInfo.processInfo.processorCount)\n"
        logs += "Architecture: "
        #if arch(x86_64)
        logs += "x86_64\n"
        #elseif arch(arm64)
        logs += "arm64\n"
        #else
        logs += "unknown\n"
        #endif

        return logs
    }

    /// Clears all stored crash logs and reports
    func clearLogs() {
        // Clear crash logs
        let logFiles = try? FileManager.default.contentsOfDirectory(at: logDirectory, includingPropertiesForKeys: nil)
        logFiles?.forEach { try? FileManager.default.removeItem(at: $0) }

        // Clear crash reports
        let reportFiles = try? FileManager.default.contentsOfDirectory(at: crashReportsDirectory, includingPropertiesForKeys: nil)
        reportFiles?.forEach { try? FileManager.default.removeItem(at: $0) }

        // Clear crash flags
        clearPreviousCrashFlag()

        logger.info("Crash logs and reports cleared")
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension CrashReportingManager {
    /// Intentionally causes a crash for testing purposes (debug builds only)
    func testCrash(type: TestCrashType) {
        switch type {
        case .exception:
            NSException(name: .genericException, reason: "Test crash - Exception", userInfo: nil).raise()
        case .segmentationFault:
            // Intentional null pointer dereference
            let nullPointer: UnsafeMutablePointer<Int>? = nil
            nullPointer?.pointee = 42
        case .abort:
            abort()
        }
    }

    enum TestCrashType {
        case exception
        case segmentationFault
        case abort
    }
}
#endif
