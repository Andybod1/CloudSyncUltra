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
        guard !localPath.isEmpty else { return }
        
        isMonitoring = true
        
        // Setup file system monitoring
        fileMonitor = FileMonitor(path: localPath) { [weak self] in
            Task { @MainActor in
                guard let self = self, self.autoSync else { return }
                // Debounce: wait 3 seconds after changes before syncing
                self.scheduleSync(delay: 3.0)
            }
        }
        
        // Setup periodic sync
        if autoSync {
            syncTimer = Timer.scheduledTimer(withTimeInterval: syncInterval, repeats: true) { [weak self] _ in
                Task { @MainActor in
                    await self?.performSync()
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
        
        let useEncryption = encryption.isEncryptionEnabled && encryption.isEncryptionConfigured
        
        syncStatus = .syncing
        let statusMessage = useEncryption ? "Starting encrypted sync..." : "Starting..."
        currentProgress = SyncProgress(speed: 0, percent: 0)
        
        do {
            let progressStream = try await rclone.sync(
                localPath: localPath,
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
        
        let callback: FSEventStreamCallback = { streamRef, clientCallBackInfo, numEvents, eventPaths, eventFlags, eventIds in
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
