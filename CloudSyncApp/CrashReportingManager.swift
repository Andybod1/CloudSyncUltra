import Foundation
import OSLog

/// Manages crash reporting and log collection for CloudSync Ultra
/// Privacy-first: All data stays local, user controls sharing
final class CrashReportingManager {
    static let shared = CrashReportingManager()

    private let logger = Logger(subsystem: "com.cloudsync.ultra", category: "CrashReporting")
    private let logDirectory: URL

    private init() {
        // Store logs in Application Support
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        logDirectory = appSupport.appendingPathComponent("CloudSyncUltra/Logs", isDirectory: true)

        // Ensure directory exists with restrictive permissions
        try? FileManager.default.createDirectory(at: logDirectory, withIntermediateDirectories: true)
        // Set restrictive permissions on the log directory (owner read/write/execute only)
        try? FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: logDirectory.path)
    }

    // MARK: - Setup

    /// Call this at app launch to install crash handlers
    func setup() {
        installExceptionHandler()
        installSignalHandlers()
        logger.info("Crash reporting initialized")
    }

    // MARK: - Exception Handling

    private func installExceptionHandler() {
        NSSetUncaughtExceptionHandler { exception in
            CrashReportingManager.shared.handleException(exception)
        }
    }

    private func installSignalHandlers() {
        // Handle common crash signals
        signal(SIGABRT) { _ in CrashReportingManager.shared.handleSignal("SIGABRT") }
        signal(SIGILL) { _ in CrashReportingManager.shared.handleSignal("SIGILL") }
        signal(SIGSEGV) { _ in CrashReportingManager.shared.handleSignal("SIGSEGV") }
        signal(SIGBUS) { _ in CrashReportingManager.shared.handleSignal("SIGBUS") }
    }

    private func handleException(_ exception: NSException) {
        let crashLog = """
        === CRASH REPORT ===
        Date: \(Date())
        Exception: \(exception.name.rawValue)
        Reason: \(exception.reason ?? "Unknown")

        Call Stack:
        \(exception.callStackSymbols.joined(separator: "\n"))
        """

        saveCrashLog(crashLog)
    }

    private func handleSignal(_ signal: String) {
        let crashLog = """
        === CRASH REPORT ===
        Date: \(Date())
        Signal: \(signal)

        Thread: \(Thread.current)
        """

        saveCrashLog(crashLog)
    }

    private func saveCrashLog(_ content: String) {
        let filename = "crash_\(ISO8601DateFormatter().string(from: Date())).log"
        let fileURL = logDirectory.appendingPathComponent(filename)

        try? content.write(to: fileURL, atomically: true, encoding: .utf8)
        // Set restrictive permissions on crash log files (owner read/write only)
        try? FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: fileURL.path)
    }

    // MARK: - Log Export

    /// Returns URL to zip file containing all logs
    /// Security: Uses secure temporary directory creation with restrictive permissions
    func exportLogs() throws -> URL {
        // Collect system logs
        let systemLogs = collectSystemLogs()

        // Collect crash logs
        let crashLogs = try FileManager.default.contentsOfDirectory(at: logDirectory, includingPropertiesForKeys: nil)

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

        for crashLog in crashLogs {
            let dest = exportDir.appendingPathComponent(crashLog.lastPathComponent)
            try? FileManager.default.copyItem(at: crashLog, to: dest)
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
        logs += "macOS: \(ProcessInfo.processInfo.operatingSystemVersionString)\n\n"

        // Note: Actual OSLog retrieval requires OSLogStore (macOS 12+)
        // For now, include basic system info
        logs += "Memory: \(ProcessInfo.processInfo.physicalMemory / 1024 / 1024) MB\n"
        logs += "Processors: \(ProcessInfo.processInfo.processorCount)\n"

        return logs
    }

    /// Clears all stored crash logs
    func clearLogs() {
        let files = try? FileManager.default.contentsOfDirectory(at: logDirectory, includingPropertiesForKeys: nil)
        files?.forEach { try? FileManager.default.removeItem(at: $0) }
        logger.info("Crash logs cleared")
    }
}