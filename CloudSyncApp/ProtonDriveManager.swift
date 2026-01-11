//
//  ProtonDriveManager.swift
//  CloudSyncApp
//
//  Dedicated manager for Proton Drive operations with
//  session management and connection health monitoring.
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
        } else if hasSavedCredentials {
            // Has saved credentials but not configured - try to reconnect
            connectionState = .sessionExpired
            Logger.sync.info("Found saved Proton credentials, session may need refresh")
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
            
            // Save credentials to Keychain if requested
            if saveCredentials {
                do {
                    try KeychainManager.shared.saveProtonCredentials(
                        username: username,
                        password: password,
                        otpSecretKey: otpSecretKey,
                        mailboxPassword: mailboxPassword
                    )
                    Logger.auth.info("Proton Drive credentials saved to Keychain")
                } catch {
                    Logger.auth.warning("Failed to save credentials to Keychain: \(error.localizedDescription)")
                }
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
    
    /// Disconnect from Proton Drive
    func disconnect(clearCredentials: Bool = true) async {
        stopHealthMonitoring()
        
        do {
            try await rclone.deleteRemote(name: remoteName)
        } catch {
            Logger.sync.error("Error disconnecting: \(error.localizedDescription)")
        }
        
        // Clear saved credentials if requested
        if clearCredentials {
            do {
                try KeychainManager.shared.deleteProtonCredentials()
                Logger.auth.info("Proton Drive credentials cleared from Keychain")
            } catch {
                Logger.auth.warning("Failed to clear credentials: \(error.localizedDescription)")
            }
        }
        
        connectionState = .disconnected
        storageInfo = nil
        lastConnectionCheck = nil
        
        Logger.sync.info("Proton Drive disconnected")
    }
    
    /// Check if saved credentials exist in Keychain
    var hasSavedCredentials: Bool {
        KeychainManager.shared.hasProtonCredentials
    }
    
    /// Get saved credentials (for display purposes - username only)
    func getSavedUsername() -> String? {
        do {
            return try KeychainManager.shared.getProtonCredentials()?.username
        } catch {
            return nil
        }
    }
    
    /// Reconnect using saved credentials from Keychain
    func reconnect() async throws {
        guard let credentials = try KeychainManager.shared.getProtonCredentials() else {
            throw ProtonDriveError.noSavedCredentials
        }
        
        connectionState = .connecting
        errorMessage = nil
        
        do {
            try await rclone.setupProtonDrive(
                username: credentials.username,
                password: credentials.password,
                twoFactorCode: nil, // Can't use single code for reconnect
                otpSecretKey: credentials.otpSecretKey,
                mailboxPassword: credentials.mailboxPassword,
                remoteName: remoteName
            )
            
            // Verify the connection works
            _ = try await rclone.listRemoteFiles(remotePath: "", remoteName: remoteName)
            
            connectionState = .connected
            lastConnectionCheck = Date()
            
            await fetchStorageInfo()
            startHealthMonitoring()
            
            Logger.sync.info("Proton Drive reconnected using saved credentials")
            
        } catch {
            connectionState = .error(error.localizedDescription)
            errorMessage = error.localizedDescription
            
            // If session expired, we need fresh credentials
            if error.localizedDescription.contains("401") || 
               error.localizedDescription.contains("invalid") {
                connectionState = .sessionExpired
            }
            
            Logger.sync.error("Proton Drive reconnect failed: \(error.localizedDescription)")
            throw error
        }
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
