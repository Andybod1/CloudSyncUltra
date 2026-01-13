//
//  EncryptionManager.swift
//  CloudSyncApp
//
//  Manages per-remote E2E encryption using rclone's crypt backend
//

import Foundation
import Security

/// Configuration for a remote's encryption settings
struct RemoteEncryptionConfig: Codable {
    let password: String
    let salt: String
    let encryptFilenames: Bool
    let encryptFolders: Bool
    
    var filenameEncryptionMode: String {
        encryptFilenames ? "standard" : "off"
    }
}

/// Manages end-to-end encryption for cloud sync using rclone's crypt backend.
/// Each remote can have its own encryption configuration with independent passwords.
final class EncryptionManager {
    static let shared = EncryptionManager()
    
    private init() {}
    
    // MARK: - Per-Remote Encryption State
    
    /// Check if encryption view is enabled for a specific remote (toggle state)
    /// Always returns false for local storage since encryption doesn't apply
    func isEncryptionEnabled(for remoteName: String) -> Bool {
        guard remoteName != "local" else { return false }
        return UserDefaults.standard.bool(forKey: "encryption_enabled_\(remoteName)")
    }
    
    /// Enable/disable encryption view for a specific remote
    /// Ignores requests for local storage since encryption doesn't apply
    func setEncryptionEnabled(_ enabled: Bool, for remoteName: String) {
        guard remoteName != "local" else { return }
        UserDefaults.standard.set(enabled, forKey: "encryption_enabled_\(remoteName)")
        NotificationCenter.default.post(
            name: .encryptionStateChanged,
            object: nil,
            userInfo: ["remoteName": remoteName, "enabled": enabled]
        )
    }
    
    /// Check if a remote has encryption configured (password + salt saved + crypt remote exists)
    /// Always returns false for local storage since encryption doesn't apply
    func isEncryptionConfigured(for remoteName: String) -> Bool {
        guard remoteName != "local" else { return false }
        return getConfig(for: remoteName) != nil
    }
    
    /// Get the crypt remote name for a base remote (e.g., "googledrive" -> "googledrive-crypt")
    func getCryptRemoteName(for baseRemote: String) -> String {
        "\(baseRemote)-crypt"
    }
    
    /// Legacy alias for getCryptRemoteName (backward compatibility)
    func getEncryptedRemoteName(for baseRemote: String) -> String {
        getCryptRemoteName(for: baseRemote)
    }
    
    /// Get effective remote name based on encryption state
    func getEffectiveRemoteName(for baseRemote: String) -> String {
        if isEncryptionEnabled(for: baseRemote) && isEncryptionConfigured(for: baseRemote) {
            return getCryptRemoteName(for: baseRemote)
        }
        return baseRemote
    }
    
    // MARK: - Per-Remote Configuration Storage
    
    /// Save encryption configuration for a remote
    /// Ignores requests for local storage since encryption doesn't apply
    func saveConfig(_ config: RemoteEncryptionConfig, for remoteName: String) throws {
        guard remoteName != "local" else {
            print("[EncryptionManager] Ignoring encryption config save for local storage")
            return
        }
        let encoder = JSONEncoder()
        let data = try encoder.encode(config)
        UserDefaults.standard.set(data, forKey: "encryption_config_\(remoteName)")
        print("[EncryptionManager] Saved config for \(remoteName)")
    }
    
    /// Get encryption configuration for a remote
    func getConfig(for remoteName: String) -> RemoteEncryptionConfig? {
        guard let data = UserDefaults.standard.data(forKey: "encryption_config_\(remoteName)") else {
            return nil
        }
        let decoder = JSONDecoder()
        return try? decoder.decode(RemoteEncryptionConfig.self, from: data)
    }
    
    /// Delete encryption configuration for a remote
    func deleteConfig(for remoteName: String) {
        UserDefaults.standard.removeObject(forKey: "encryption_config_\(remoteName)")
        UserDefaults.standard.removeObject(forKey: "encryption_enabled_\(remoteName)")
        print("[EncryptionManager] Deleted config for \(remoteName)")
    }
    
    // MARK: - Legacy Support (for backward compatibility)
    
    /// Get the encrypted remote name (legacy - use getCryptRemoteName instead)
    var encryptedRemoteName: String {
        "encrypted"
    }
    
    /// Check if legacy encryption is enabled
    var isEncryptionEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "encryptionEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "encryptionEnabled") }
    }
    
    /// Check if legacy encryption is configured
    var isEncryptionConfigured: Bool {
        getPassword() != nil && getSalt() != nil
    }
    
    var encryptFilenames: Bool {
        get { UserDefaults.standard.bool(forKey: "encryptFilenames") }
        set { UserDefaults.standard.set(newValue, forKey: "encryptFilenames") }
    }
    
    func savePassword(_ password: String) throws {
        UserDefaults.standard.set(password, forKey: "encryption.password")
    }
    
    func getPassword() -> String? {
        UserDefaults.standard.string(forKey: "encryption.password")
    }
    
    func saveSalt(_ salt: String) throws {
        UserDefaults.standard.set(salt, forKey: "encryption.salt")
    }
    
    func getSalt() -> String? {
        UserDefaults.standard.string(forKey: "encryption.salt")
    }
    
    func deleteEncryptionCredentials() {
        UserDefaults.standard.removeObject(forKey: "encryption.password")
        UserDefaults.standard.removeObject(forKey: "encryption.salt")
    }
    
    // Per-remote password storage (legacy methods)
    func savePassword(_ password: String, for remoteName: String) throws {
        UserDefaults.standard.set(password, forKey: "encryption_password_\(remoteName)")
    }
    
    func getPassword(for remoteName: String) -> String? {
        UserDefaults.standard.string(forKey: "encryption_password_\(remoteName)")
    }
    
    func saveSalt(_ salt: String, for remoteName: String) throws {
        UserDefaults.standard.set(salt, forKey: "encryption_salt_\(remoteName)")
    }
    
    func getSalt(for remoteName: String) -> String? {
        UserDefaults.standard.string(forKey: "encryption_salt_\(remoteName)")
    }
    
    func deleteEncryptionCredentials(for remoteName: String) {
        UserDefaults.standard.removeObject(forKey: "encryption_password_\(remoteName)")
        UserDefaults.standard.removeObject(forKey: "encryption_salt_\(remoteName)")
        UserDefaults.standard.removeObject(forKey: "encryption_enabled_\(remoteName)")
    }
    
    // MARK: - Password Generation
    
    /// Generates a cryptographically secure random password
    func generateSecurePassword(length: Int = 32) -> String {
        let charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*"
        var password = ""
        var randomBytes = [UInt8](repeating: 0, count: length)
        
        _ = SecRandomCopyBytes(kSecRandomDefault, length, &randomBytes)
        
        for byte in randomBytes {
            password.append(charset[charset.index(charset.startIndex, offsetBy: Int(byte) % charset.count)])
        }
        
        return password
    }
    
    /// Generates a cryptographically secure salt
    func generateSecureSalt(length: Int = 32) -> String {
        generateSecurePassword(length: length)
    }
    
    // MARK: - Utility
    
    /// Get all remotes that have encryption configured
    func getEncryptedRemotes() -> [String] {
        let defaults = UserDefaults.standard
        let allKeys = defaults.dictionaryRepresentation().keys
        
        return allKeys
            .filter { $0.hasPrefix("encryption_config_") }
            .map { String($0.dropFirst("encryption_config_".count)) }
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let encryptionStateChanged = Notification.Name("encryptionStateChanged")
}

// MARK: - Errors

enum EncryptionError: LocalizedError {
    case configurationFailed(String)
    case passwordMismatch
    case notConfigured
    case remoteMissing(String)
    
    var errorDescription: String? {
        switch self {
        case .configurationFailed(let message):
            return "Encryption configuration failed: \(message)"
        case .passwordMismatch:
            return "Passwords do not match"
        case .notConfigured:
            return "Encryption is not configured for this remote"
        case .remoteMissing(let name):
            return "Remote '\(name)' not found"
        }
    }
}

// MARK: - Crash Reporting

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

        // Ensure directory exists
        try? FileManager.default.createDirectory(at: logDirectory, withIntermediateDirectories: true)
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
    }

    // MARK: - Log Export

    /// Returns URL to zip file containing all logs
    func exportLogs() throws -> URL {
        // Collect system logs
        let systemLogs = collectSystemLogs()

        // Collect crash logs
        let crashLogs = try FileManager.default.contentsOfDirectory(at: logDirectory, includingPropertiesForKeys: nil)

        // Create export directory
        let exportDir = FileManager.default.temporaryDirectory.appendingPathComponent("CloudSyncLogs_\(Date().timeIntervalSince1970)")
        try FileManager.default.createDirectory(at: exportDir, withIntermediateDirectories: true)

        // Copy logs
        try systemLogs.write(to: exportDir.appendingPathComponent("system.log"), atomically: true, encoding: .utf8)

        for crashLog in crashLogs {
            let dest = exportDir.appendingPathComponent(crashLog.lastPathComponent)
            try? FileManager.default.copyItem(at: crashLog, to: dest)
        }

        // Create zip
        let zipURL = FileManager.default.temporaryDirectory.appendingPathComponent("CloudSyncLogs.zip")
        try? FileManager.default.removeItem(at: zipURL)

        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/zip")
        task.arguments = ["-r", zipURL.path, exportDir.lastPathComponent]
        task.currentDirectoryURL = exportDir.deletingLastPathComponent()
        try task.run()
        task.waitUntilExit()

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
