//
//  ProtonDriveManager.swift
//  CloudSyncApp
//
//  Dedicated manager for Proton Drive operations with credential storage,
//  session management, and connection health monitoring.
//

import Foundation
import Combine
import OSLog

/// Manages Proton Drive connection state, credentials, and operations
@MainActor
class ProtonDriveManager: ObservableObject {
    static let shared = ProtonDriveManager()
    
    // MARK: - Published State
    
    @Published var connectionState: ConnectionState = .disconnected
    @Published var lastConnectionCheck: Date?
    @Published var storageInfo: StorageInfo?
    @Published var errorMessage: String?
    
    // MARK: - Configuration
    
    private let rclone = RcloneManager.shared
    private let keychain = KeychainManager.shared
    private var healthCheckTimer: Timer?
    
    private let remoteName = "proton"
    
    // MARK: - Types
    
    enum ConnectionState: Equatable {
        case disconnected
        case connecting
        case connected
        case error(String)
        case sessionExpired
        
        var isConnected: Bool {
            if case .connected = self { return true }
            return false
        }
        
        var statusColor: String {
            switch self {
            case .connected: return "green"
            case .connecting: return "orange"
            case .disconnected: return "gray"
            case .error, .sessionExpired: return "red"
            }
        }
        
        var statusText: String {
            switch self {
            case .connected: return "Connected"
            case .connecting: return "Connecting..."
            case .disconnected: return "Not connected"
            case .error(let msg): return "Error: \(msg)"
            case .sessionExpired: return "Session expired"
            }
        }
    }
    
    struct StorageInfo {
        let used: Int64
        let total: Int64
        let free: Int64
        
        var usedFormatted: String {
            ByteCountFormatter.string(fromByteCount: used, countStyle: .file)
        }
        
        var totalFormatted: String {
            ByteCountFormatter.string(fromByteCount: total, countStyle: .file)
        }
        
        var freeFormatted: String {
            ByteCountFormatter.string(fromByteCount: free, countStyle: .file)
        }
        
        var usagePercentage: Double {
            guard total > 0 else { return 0 }
            return Double(used) / Double(total) * 100
        }
    }
    
    struct ProtonCredentials: Codable {
        let username: String
        let password: String  // Obscured password
        let otpSecretKey: String?
        let mailboxPassword: String?  // Obscured
        let savedAt: Date
        
        var hasOTPSecret: Bool {
            otpSecretKey != nil && !otpSecretKey!.isEmpty
        }
    }
    
    // MARK: - Initialization
    
    private init() {
        checkExistingConnection()
    }
    
    // MARK: - Connection Management
    
    /// Check if Proton Drive is already configured
    func checkExistingConnection() {
        if rclone.isRemoteConfigured(name: remoteName) {
            // Remote exists, verify it works
            Task {
                await verifyConnection()
            }
        } else {
            connectionState = .disconnected
        }
    }
    
    /// Verify the connection is still working
    func verifyConnection() async {
        guard rclone.isRemoteConfigured(name: remoteName) else {
            connectionState = .disconnected
            return
        }
        
        connectionState = .connecting
        
        do {
            // Try to list root to verify connection
            let files = try await rclone.listRemoteFiles(remotePath: "", remoteName: remoteName)
            
            connectionState = .connected
            lastConnectionCheck = Date()
            
            // Fetch storage info
            await fetchStorageInfo()
            
            Logger.sync.info("Proton Drive connection verified - \(files.count) items in root")
            
        } catch {
            let errorString = error.localizedDescription.lowercased()
            
            if errorString.contains("401") || errorString.contains("invalid access token") ||
               errorString.contains("refresh token") {
                connectionState = .sessionExpired
                Logger.sync.warning("Proton Drive session expired")
            } else {
                connectionState = .error(error.localizedDescription)
                Logger.sync.error("Proton Drive connection failed: \(error.localizedDescription)")
            }
        }
    }
    
    /// Connect to Proton Drive with credentials
    func connect(
        username: String,
        password: String,
        twoFactorCode: String? = nil,
        otpSecretKey: String? = nil,
        mailboxPassword: String? = nil,
        saveCredentials: Bool = true
    ) async throws {
        connectionState = .connecting
        errorMessage = nil
        
        do {
            try await rclone.setupProtonDrive(
                username: username,
                password: password,
                twoFactorCode: twoFactorCode,
                otpSecretKey: otpSecretKey,
                mailboxPassword: mailboxPassword,
                remoteName: remoteName
            )
            
            // Verify the connection works
            _ = try await rclone.listRemoteFiles(remotePath: "", remoteName: remoteName)
            
            connectionState = .connected
            lastConnectionCheck = Date()
            
            // Save credentials for reconnection if requested
            if saveCredentials {
                await saveCredentialsToKeychain(
                    username: username,
                    password: password,
                    otpSecretKey: otpSecretKey,
                    mailboxPassword: mailboxPassword
                )
            }
            
            // Fetch storage info
            await fetchStorageInfo()
            
            // Start health monitoring
            startHealthMonitoring()
            
            Logger.sync.info("Proton Drive connected successfully")
            
        } catch {
            connectionState = .error(error.localizedDescription)
            errorMessage = error.localizedDescription
            Logger.sync.error("Proton Drive connection failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Reconnect using saved credentials
    func reconnect() async throws {
        guard let credentials = getSavedCredentials() else {
            throw ProtonDriveError.noSavedCredentials
        }
        
        connectionState = .connecting
        
        // For reconnection, we use the saved (already obscured) credentials
        // We need to pass them directly to rclone without re-obscuring
        try await reconnectWithSavedCredentials(credentials)
    }
    
    private func reconnectWithSavedCredentials(_ credentials: ProtonCredentials) async throws {
        // Create remote with pre-obscured passwords
        var params: [String: String] = [
            "username": credentials.username,
            "password": credentials.password  // Already obscured
        ]
        
        if let otpSecret = credentials.otpSecretKey, !otpSecret.isEmpty {
            params["otp_secret_key"] = otpSecret  // Already obscured
        }
        
        if let mailbox = credentials.mailboxPassword, !mailbox.isEmpty {
            params["mailbox_password"] = mailbox  // Already obscured
        }
        
        params["replace_existing_draft"] = "true"
        params["enable_caching"] = "true"
        
        // Delete and recreate the remote
        try? await rclone.deleteRemote(name: remoteName)
        
        // Use rclone config create directly with pre-obscured values
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/rclone")
        
        var args = ["config", "create", remoteName, "protondrive", "--non-interactive"]
        for (key, value) in params {
            args.append(key)
            args.append(value)
        }
        
        let configPath = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent("CloudSyncApp/rclone.conf").path
        
        args.append("--config")
        args.append(configPath)
        
        process.arguments = args
        
        let errorPipe = Pipe()
        process.standardError = errorPipe
        
        try process.run()
        process.waitUntilExit()
        
        if process.terminationStatus != 0 {
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorString = String(data: errorData, encoding: .utf8) ?? "Unknown error"
            throw RcloneError.configurationFailed(errorString)
        }
        
        // Verify connection
        _ = try await rclone.listRemoteFiles(remotePath: "", remoteName: remoteName)
        
        connectionState = .connected
        lastConnectionCheck = Date()
        
        await fetchStorageInfo()
        startHealthMonitoring()
        
        Logger.sync.info("Proton Drive reconnected successfully")
    }
    
    /// Disconnect from Proton Drive
    func disconnect() async {
        stopHealthMonitoring()
        
        do {
            try await rclone.deleteRemote(name: remoteName)
            deleteCredentialsFromKeychain()
        } catch {
            Logger.sync.error("Error disconnecting: \(error.localizedDescription)")
        }
        
        connectionState = .disconnected
        storageInfo = nil
        lastConnectionCheck = nil
        
        Logger.sync.info("Proton Drive disconnected")
    }
    
    // MARK: - Storage Info
    
    func fetchStorageInfo() async {
        // Proton Drive doesn't expose quota via rclone easily
        // We can try rclone about, but it may not work for all providers
        do {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/rclone")
            
            let configPath = FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            )[0].appendingPathComponent("CloudSyncApp/rclone.conf").path
            
            process.arguments = [
                "about", "\(remoteName):",
                "--config", configPath,
                "--json"
            ]
            
            let outputPipe = Pipe()
            process.standardOutput = outputPipe
            process.standardError = Pipe()
            
            try process.run()
            process.waitUntilExit()
            
            if process.terminationStatus == 0 {
                let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let used = json["used"] as? Int64 ?? 0
                    let total = json["total"] as? Int64 ?? 0
                    let free = json["free"] as? Int64 ?? (total - used)
                    
                    storageInfo = StorageInfo(used: used, total: total, free: free)
                    Logger.sync.debug("Storage info: \(self.storageInfo?.usedFormatted ?? "N/A") / \(self.storageInfo?.totalFormatted ?? "N/A")")
                }
            }
        } catch {
            Logger.sync.debug("Could not fetch storage info: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Health Monitoring
    
    func startHealthMonitoring() {
        stopHealthMonitoring()
        
        // Check connection every 5 minutes
        healthCheckTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.verifyConnection()
            }
        }
        
        Logger.sync.debug("Started Proton Drive health monitoring")
    }
    
    func stopHealthMonitoring() {
        healthCheckTimer?.invalidate()
        healthCheckTimer = nil
    }
    
    // MARK: - Credential Storage
    
    private func saveCredentialsToKeychain(
        username: String,
        password: String,
        otpSecretKey: String?,
        mailboxPassword: String?
    ) async {
        do {
            // Obscure passwords for storage
            let obscuredPassword = try await rclone.obscurePassword(password)
            var obscuredOTP: String? = nil
            var obscuredMailbox: String? = nil
            
            if let otp = otpSecretKey, !otp.isEmpty {
                obscuredOTP = try await rclone.obscurePassword(otp)
            }
            
            if let mailbox = mailboxPassword, !mailbox.isEmpty {
                obscuredMailbox = try await rclone.obscurePassword(mailbox)
            }
            
            let credentials = ProtonCredentials(
                username: username,
                password: obscuredPassword,
                otpSecretKey: obscuredOTP,
                mailboxPassword: obscuredMailbox,
                savedAt: Date()
            )
            
            try keychain.save(credentials, forKey: "proton_credentials")
            Logger.auth.info("Saved Proton credentials to keychain")
            
        } catch {
            Logger.auth.error("Failed to save Proton credentials: \(error.localizedDescription)")
        }
    }
    
    func getSavedCredentials() -> ProtonCredentials? {
        do {
            return try keychain.getObject(forKey: "proton_credentials")
        } catch {
            Logger.auth.debug("No saved Proton credentials found")
            return nil
        }
    }
    
    func hasSavedCredentials() -> Bool {
        return getSavedCredentials() != nil
    }
    
    private func deleteCredentialsFromKeychain() {
        do {
            try keychain.delete(forKey: "proton_credentials")
            Logger.auth.info("Deleted Proton credentials from keychain")
        } catch {
            Logger.auth.debug("No Proton credentials to delete")
        }
    }
    
    // MARK: - Test Connection
    
    func testConnection(
        username: String,
        password: String,
        twoFactorCode: String? = nil,
        mailboxPassword: String? = nil
    ) async -> (success: Bool, message: String) {
        do {
            return try await rclone.testProtonDriveConnection(
                username: username,
                password: password,
                twoFactorCode: twoFactorCode,
                mailboxPassword: mailboxPassword
            )
        } catch {
            return (false, error.localizedDescription)
        }
    }
}

// MARK: - RcloneManager Extension

extension RcloneManager {
    /// Public method to obscure a password (for credential storage)
    func obscurePasswordPublic(_ password: String) async throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/rclone")
        process.arguments = ["obscure", password]
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        try process.run()
        process.waitUntilExit()
        
        if process.terminationStatus != 0 {
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorString = String(data: errorData, encoding: .utf8) ?? "Unknown error"
            throw RcloneError.encryptionSetupFailed("Failed to obscure password: \(errorString)")
        }
        
        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let obscured = String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        return obscured
    }
}
