//
//  SyncManager.swift
//  CloudSyncApp
//
//  Coordinates file monitoring and synchronization
//

import Foundation
import Combine

@MainActor
class SyncManager: ObservableObject {
    static let shared = SyncManager()
    
    @Published var syncStatus: SyncStatus = .idle
    @Published var lastSyncTime: Date?
    @Published var currentProgress: SyncProgress?
    @Published var isMonitoring = false
    @Published var scheduleSyncDisabledReason: String?
    @Published var showPaywallForScheduledSync = false
    
    private let rclone = RcloneManager.shared
    private let encryption = EncryptionManager.shared
    private var fileMonitor: FileMonitor?
    private var syncTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    var localPath: String {
        get { UserDefaults.standard.string(forKey: "localPath") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "localPath") }
    }
    
    var remotePath: String {
        get { UserDefaults.standard.string(forKey: "remotePath") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "remotePath") }
    }
    
    var syncInterval: TimeInterval {
        get { UserDefaults.standard.double(forKey: "syncInterval") != 0
            ? UserDefaults.standard.double(forKey: "syncInterval")
            : 300 } // Default 5 minutes
        set { UserDefaults.standard.set(newValue, forKey: "syncInterval") }
    }
    
    var autoSync: Bool {
        get { UserDefaults.standard.bool(forKey: "autoSync") }
        set { UserDefaults.standard.set(newValue, forKey: "autoSync") }
    }
    
    private init() {}
    
    // MARK: - Monitoring
    
    func startMonitoring() async {
        guard let validatedLocalPath = SecurityManager.sanitizePath(localPath) else {
            print("Error: Invalid or unsafe local path for monitoring")
            return
        }

        // Check if user can use scheduled sync based on subscription
        guard StoreKitManager.shared.currentTier.hasScheduledSync else {
            print("Scheduled sync requires Pro or Team subscription")
            // Still allow manual sync for free users
            return
        }

        isMonitoring = true

        // Setup file system monitoring
        fileMonitor = FileMonitor(path: validatedLocalPath) { [weak self] in
            Task { @MainActor in
                guard let self = self, self.autoSync else { return }
                // Debounce: wait 3 seconds after changes before syncing
                self.scheduleSync(delay: 3.0)
            }
        }

        // Setup periodic sync
        if autoSync {
            syncTimer = Timer.scheduledTimer(withTimeInterval: syncInterval, repeats: true) { [weak self] _ in
                guard let strongSelf = self else { return }
                Task { @MainActor in
                    await strongSelf.performSync()
                }
            }
        }
        
        // Do initial sync
        await performSync()
    }
    
    func stopMonitoring() {
        isMonitoring = false
        fileMonitor?.stop()
        fileMonitor = nil
        syncTimer?.invalidate()
        syncTimer = nil
        rclone.stopCurrentSync()
    }
    
    private var scheduledSyncTask: Task<Void, Never>?
    
    private func scheduleSync(delay: TimeInterval) {
        scheduledSyncTask?.cancel()
        scheduledSyncTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            guard !Task.isCancelled else { return }
            await performSync()
        }
    }
    
    // MARK: - Sync Operations
    
    func performSync(mode: SyncMode = .oneWay) async {
        guard syncStatus != .syncing else { return }

        // Validate paths before syncing
        guard let validatedLocalPath = SecurityManager.sanitizePath(localPath),
              !remotePath.isEmpty else {
            syncStatus = .error("Invalid or unsafe paths specified")
            return
        }

        let useEncryption = encryption.isEncryptionEnabled && encryption.isEncryptionConfigured

        syncStatus = .syncing
        let statusMessage = useEncryption ? "Starting encrypted sync..." : "Starting..."
        currentProgress = SyncProgress(speed: "", percent: 0)

        do {
            let progressStream = try await rclone.sync(
                localPath: validatedLocalPath,
                remotePath: remotePath,
                mode: mode,
                encrypted: useEncryption
            )
            
            for await progress in progressStream {
                currentProgress = progress
                syncStatus = progress.status
            }
            
            syncStatus = .completed
            lastSyncTime = Date()
            
            // Reset to idle after 3 seconds
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            if syncStatus == .completed {
                syncStatus = .idle
            }
        } catch {
            syncStatus = .error(error.localizedDescription)
            print("Sync error: \(error)")
        }
    }
    
    func manualSync() async {
        await performSync()
    }
    
    // MARK: - Configuration
    
    /// Configure Proton Drive with full authentication support
    /// - Parameters:
    ///   - username: Proton account email
    ///   - password: Account password
    ///   - twoFactorCode: Single-use 2FA code (optional)
    ///   - otpSecretKey: TOTP secret for persistent 2FA (recommended)
    ///   - mailboxPassword: For two-password accounts (optional)
    ///   - remoteName: Remote name in rclone config (default: "proton")
    func configureProtonDrive(
        username: String,
        password: String,
        twoFactorCode: String? = nil,
        otpSecretKey: String? = nil,
        mailboxPassword: String? = nil,
        remoteName: String = "proton"
    ) async throws {
        try await rclone.setupProtonDrive(
            username: username,
            password: password,
            twoFactorCode: twoFactorCode,
            otpSecretKey: otpSecretKey,
            mailboxPassword: mailboxPassword,
            remoteName: remoteName
        )
        UserDefaults.standard.set(true, forKey: "isConfigured")
    }
    
    /// Test Proton Drive connection before full setup
    func testProtonDriveConnection(
        username: String,
        password: String,
        twoFactorCode: String? = nil,
        mailboxPassword: String? = nil
    ) async throws -> (success: Bool, message: String) {
        return try await rclone.testProtonDriveConnection(
            username: username,
            password: password,
            twoFactorCode: twoFactorCode,
            mailboxPassword: mailboxPassword
        )
    }
    
    func isConfigured() -> Bool {
        rclone.isConfigured()
    }
    
    // MARK: - Encryption Configuration
    
    /// Enables E2E encryption for cloud sync.
    /// Files will be encrypted locally before upload using AES-256.
    func configureEncryption(
        password: String,
        salt: String,
        filenameEncryption: String = "standard",
        encryptDirectories: Bool = true,
        wrappedRemote: String,
        wrappedPath: String = "/encrypted"
    ) async throws {
        // Save credentials securely to Keychain
        try encryption.savePassword(password)
        try encryption.saveSalt(salt)
        
        // Setup the encrypted remote in rclone
        try await rclone.setupEncryptedRemote(
            password: password,
            salt: salt,
            encryptFilenames: filenameEncryption,
            encryptDirectories: encryptDirectories,
            wrappedRemote: wrappedRemote,
            wrappedPath: wrappedPath
        )
        
        encryption.encryptFilenames = (filenameEncryption != "off")
        encryption.isEncryptionEnabled = true
    }
    
    /// Disables E2E encryption and removes configuration.
    func disableEncryption() async throws {
        try await rclone.removeEncryptedRemote()
        encryption.deleteEncryptionCredentials()
        encryption.isEncryptionEnabled = false
    }
    
    /// Checks if encryption is properly configured and enabled.
    var isEncryptionActive: Bool {
        encryption.isEncryptionEnabled &&
        encryption.isEncryptionConfigured &&
        rclone.isEncryptedRemoteConfigured()
    }

    // MARK: - Transfer Preview (Dry-Run)

    /// Generate a preview of what sync will do without executing (dry-run)
    /// - Parameter task: The sync task to preview
    /// - Returns: A TransferPreview showing what operations would be performed
    func previewSync(task: SyncTask) async throws -> TransferPreview {
        let rclonePath = findRclonePath()
        guard FileManager.default.fileExists(atPath: rclonePath) else {
            throw PreviewError.rcloneNotFound
        }

        // Build source and destination paths
        let source = "\(task.effectiveSourceRemote):\(task.sourcePath)"
        let destination = "\(task.effectiveDestinationRemote):\(task.destinationPath)"

        // Build rclone command with --dry-run
        var arguments = [
            task.type == .sync ? "sync" : "copy",
            source,
            destination,
            "--dry-run",
            "-v",
            "--config", getConfigPath()
        ]

        // Add verbose logging for better parsing
        arguments.append("--log-format")
        arguments.append("date,time,level,file")

        let output = try await runRcloneDryRun(path: rclonePath, arguments: arguments)
        return parsePreviewOutput(output)
    }

    /// Preview sync using source/destination paths directly
    func previewSync(source: String, destination: String, mode: SyncMode = .oneWay) async throws -> TransferPreview {
        let rclonePath = findRclonePath()
        guard FileManager.default.fileExists(atPath: rclonePath) else {
            throw PreviewError.rcloneNotFound
        }

        let operation = mode == .biDirectional ? "bisync" : "sync"

        var arguments = [
            operation,
            source,
            destination,
            "--dry-run",
            "-v",
            "--config", getConfigPath()
        ]

        arguments.append("--log-format")
        arguments.append("date,time,level,file")

        let output = try await runRcloneDryRun(path: rclonePath, arguments: arguments)
        return parsePreviewOutput(output)
    }

    // MARK: - Private Dry-Run Helpers

    /// Find the rclone binary path
    private func findRclonePath() -> String {
        // Check for bundled rclone first
        if let bundledPath = Bundle.main.path(forResource: "rclone", ofType: nil) {
            return bundledPath
        }
        // Fall back to homebrew location
        return "/opt/homebrew/bin/rclone"
    }

    /// Get the rclone config path
    private func getConfigPath() -> String {
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0]
        return appSupport
            .appendingPathComponent("CloudSyncApp", isDirectory: true)
            .appendingPathComponent("rclone.conf")
            .path
    }

    /// Execute rclone with dry-run and return output
    private func runRcloneDryRun(path: String, arguments: [String]) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let process = Process()
            let pipe = Pipe()
            let errorPipe = Pipe()

            process.executableURL = URL(fileURLWithPath: path)
            process.arguments = arguments
            process.standardOutput = pipe
            process.standardError = errorPipe

            do {
                try process.run()
                process.waitUntilExit()

                let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

                let output = String(data: outputData, encoding: .utf8) ?? ""
                let errorOutput = String(data: errorData, encoding: .utf8) ?? ""

                // Combine stdout and stderr (rclone logs to stderr)
                let combinedOutput = output + "\n" + errorOutput

                if process.terminationStatus != 0 && !combinedOutput.contains("NOTICE:") {
                    continuation.resume(throwing: PreviewError.executionFailed(errorOutput))
                } else {
                    continuation.resume(returning: combinedOutput)
                }
            } catch {
                continuation.resume(throwing: PreviewError.executionFailed(error.localizedDescription))
            }
        }
    }

    /// Parse rclone dry-run output into TransferPreview
    private func parsePreviewOutput(_ output: String) -> TransferPreview {
        var transfers: [PreviewItem] = []
        var deletes: [PreviewItem] = []
        var updates: [PreviewItem] = []
        var totalSize: Int64 = 0

        let lines = output.components(separatedBy: "\n")
        for line in lines {
            let lowercaseLine = line.lowercased()

            // Parse transfer/copy operations
            if lowercaseLine.contains("copied") || lowercaseLine.contains(": copy ") ||
               lowercaseLine.contains("would copy") {
                if let item = parsePreviewLine(line, operation: .transfer) {
                    transfers.append(item)
                    totalSize += item.size
                }
            }
            // Parse delete operations
            else if lowercaseLine.contains("deleted") || lowercaseLine.contains(": delete ") ||
                    lowercaseLine.contains("would delete") {
                if let item = parsePreviewLine(line, operation: .delete) {
                    deletes.append(item)
                }
            }
            // Parse update operations
            else if lowercaseLine.contains("updated") || lowercaseLine.contains(": update ") ||
                    lowercaseLine.contains("would update") {
                if let item = parsePreviewLine(line, operation: .update) {
                    updates.append(item)
                    totalSize += item.size
                }
            }
        }

        return TransferPreview(
            filesToTransfer: transfers,
            filesToDelete: deletes,
            filesToUpdate: updates,
            totalSize: totalSize,
            estimatedTime: nil
        )
    }

    /// Parse a single line from dry-run output into a PreviewItem
    private func parsePreviewLine(_ line: String, operation: PreviewOperation) -> PreviewItem? {
        // Try to extract file path from rclone output
        // Format examples:
        // "2026/01/15 12:00:00 NOTICE: file.txt: Skipped copy..."
        // "NOTICE: path/to/file.txt: Not copying..."

        var path = ""
        var size: Int64 = 0

        // Extract path between NOTICE: and the next colon
        if let noticeRange = line.range(of: "NOTICE:") {
            let afterNotice = String(line[noticeRange.upperBound...]).trimmingCharacters(in: .whitespaces)
            if let colonIndex = afterNotice.firstIndex(of: ":") {
                path = String(afterNotice[..<colonIndex]).trimmingCharacters(in: .whitespaces)
            }
        } else if let infoRange = line.range(of: "INFO:") {
            let afterInfo = String(line[infoRange.upperBound...]).trimmingCharacters(in: .whitespaces)
            if let colonIndex = afterInfo.firstIndex(of: ":") {
                path = String(afterInfo[..<colonIndex]).trimmingCharacters(in: .whitespaces)
            }
        }

        // Try to extract size if present (format: "size 1234" or "1234 bytes")
        let sizePatterns = [
            #"size[:\s]+(\d+)"#,
            #"(\d+)\s*bytes"#,
            #"(\d+)\s*B\b"#
        ]
        for pattern in sizePatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: line, options: [], range: NSRange(line.startIndex..., in: line)),
               let sizeRange = Range(match.range(at: 1), in: line) {
                size = Int64(line[sizeRange]) ?? 0
                break
            }
        }

        // Only return if we found a path
        guard !path.isEmpty else { return nil }

        return PreviewItem(
            path: path,
            size: size,
            operation: operation,
            modifiedDate: nil
        )
    }

    // MARK: - Subscription Feature Gating

    /// Check if user can use scheduled sync based on subscription
    var canUseScheduledSync: Bool {
        StoreKitManager.shared.currentTier.hasScheduledSync
    }

    /// Attempt to enable scheduled sync with feature gating
    func enableScheduledSync() -> Bool {
        if !canUseScheduledSync {
            scheduleSyncDisabledReason = StoreKitManager.shared.currentTier.limitMessage(for: "scheduling")
            showPaywallForScheduledSync = true
            return false
        }
        return true
    }

    /// Get a user-friendly message about scheduled sync availability
    func getScheduledSyncStatus() -> String {
        if canUseScheduledSync {
            return isMonitoring ? "Scheduled sync active" : "Scheduled sync available"
        } else {
            return "Scheduled sync requires Pro subscription"
        }
    }
}

// MARK: - File Monitor

class FileMonitor {
    private var eventStream: FSEventStreamRef?
    private let path: String
    private let onChange: () -> Void
    
    init(path: String, onChange: @escaping () -> Void) {
        self.path = path
        self.onChange = onChange
        start()
    }
    
    private func start() {
        var context = FSEventStreamContext(
            version: 0,
            info: Unmanaged.passUnretained(self).toOpaque(),
            retain: nil,
            release: nil,
            copyDescription: nil
        )
        
        let callback: FSEventStreamCallback = { _, clientCallBackInfo, _, _, _, _ in
            guard let info = clientCallBackInfo else { return }
            let monitor = Unmanaged<FileMonitor>.fromOpaque(info).takeUnretainedValue()
            monitor.onChange()
        }
        
        let pathsToWatch = [path] as CFArray
        let flags = UInt32(kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagFileEvents)
        
        eventStream = FSEventStreamCreate(
            kCFAllocatorDefault,
            callback,
            &context,
            pathsToWatch,
            FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
            0.5, // latency
            flags
        )
        
        if let stream = eventStream {
            FSEventStreamSetDispatchQueue(stream, DispatchQueue.main)
            FSEventStreamStart(stream)
        }
    }
    
    func stop() {
        if let stream = eventStream {
            FSEventStreamStop(stream)
            FSEventStreamInvalidate(stream)
            FSEventStreamRelease(stream)
            eventStream = nil
        }
    }
    
    deinit {
        stop()
    }
}
