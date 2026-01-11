//
//  SettingsView.swift
//  CloudSyncApp
//
//  Redesigned settings with modern UI
//

import SwiftUI

struct SettingsView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(0)
            
            AccountSettingsView()
                .tabItem {
                    Label("Accounts", systemImage: "person.circle")
                }
                .tag(1)
            
            SyncSettingsView()
                .tabItem {
                    Label("Sync", systemImage: "arrow.triangle.2.circlepath")
                }
                .tag(2)
            
            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
                .tag(3)
        }
        .frame(width: 600, height: 500)
    }
}

// MARK: - General Settings

struct GeneralSettingsView: View {
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("showDockIcon") private var showDockIcon = false
    @AppStorage("showNotifications") private var showNotifications = true
    @AppStorage("soundEffects") private var soundEffects = true
    
    var body: some View {
        Form {
            Section {
                Toggle("Launch at Login", isOn: $launchAtLogin)
                Toggle("Show in Dock", isOn: $showDockIcon)
                    .onChange(of: showDockIcon) { _, newValue in
                        NSApp.setActivationPolicy(newValue ? .regular : .accessory)
                    }
            } header: {
                Label("Startup", systemImage: "power")
            }
            
            Section {
                Toggle("Show Notifications", isOn: $showNotifications)
                Toggle("Sound Effects", isOn: $soundEffects)
            } header: {
                Label("Notifications", systemImage: "bell")
            }
            
            Section {
                HStack {
                    Text("Config Location")
                    Spacer()
                    Text("~/Library/Application Support/CloudSyncApp")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    
                    Button("Open") {
                        openConfigFolder()
                    }
                    .buttonStyle(.bordered)
                }
                
                HStack {
                    Text("Cache")
                    Spacer()
                    Text("0 MB")
                        .foregroundColor(.secondary)
                    
                    Button("Clear") {
                        // Clear cache
                    }
                    .buttonStyle(.bordered)
                }
            } header: {
                Label("Storage", systemImage: "externaldrive")
            }
        }
        .formStyle(.grouped)
        .padding()
    }
    
    private func openConfigFolder() {
        let path = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent("CloudSyncApp")
        NSWorkspace.shared.open(path)
    }
}

// MARK: - Sync Settings

struct SyncSettingsView: View {
    @EnvironmentObject var syncManager: SyncManager
    @State private var localPath: String = ""
    @State private var remotePath: String = ""
    @State private var autoSync: Bool = true
    @State private var syncInterval: Double = 300
    @State private var conflictResolution: String = "newer"
    @State private var deleteMode: String = "trash"
    
    // Bandwidth throttling
    @AppStorage("bandwidthLimitEnabled") private var bandwidthLimitEnabled = false
    @AppStorage("uploadLimit") private var uploadLimit: Double = 0
    @AppStorage("downloadLimit") private var downloadLimit: Double = 0
    @State private var uploadLimitText = ""
    @State private var downloadLimitText = ""
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Local Folder")
                    Spacer()
                    TextField("Choose folder...", text: $localPath)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 250)
                        .disabled(true)
                    
                    Button("Choose...") {
                        selectFolder()
                    }
                }
                
                HStack {
                    Text("Remote Path")
                    Spacer()
                    TextField("/Documents", text: $remotePath)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 250)
                }
            } header: {
                Label("Sync Folder", systemImage: "folder")
            }
            
            Section {
                Toggle("Automatic Sync", isOn: $autoSync)
                
                if autoSync {
                    Picker("Interval", selection: $syncInterval) {
                        Text("Every minute").tag(60.0)
                        Text("Every 5 minutes").tag(300.0)
                        Text("Every 15 minutes").tag(900.0)
                        Text("Every hour").tag(3600.0)
                    }
                }
                
                Picker("Conflict Resolution", selection: $conflictResolution) {
                    Text("Keep newer file").tag("newer")
                    Text("Keep local file").tag("local")
                    Text("Keep remote file").tag("remote")
                    Text("Keep both").tag("both")
                }
                
                Picker("When files are deleted", selection: $deleteMode) {
                    Text("Move to Trash").tag("trash")
                    Text("Delete permanently").tag("delete")
                    Text("Keep files").tag("keep")
                }
            } header: {
                Label("Behavior", systemImage: "gearshape.2")
            }
            
            Section {
                Toggle("Enable Bandwidth Limits", isOn: $bandwidthLimitEnabled)
                
                if bandwidthLimitEnabled {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Upload Limit")
                                .frame(width: 100, alignment: .leading)
                            TextField("MB/s", text: $uploadLimitText)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 80)
                            Text("MB/s")
                                .foregroundColor(.secondary)
                            Text("(0 = unlimited)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Download Limit")
                                .frame(width: 100, alignment: .leading)
                            TextField("MB/s", text: $downloadLimitText)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 80)
                            Text("MB/s")
                                .foregroundColor(.secondary)
                            Text("(0 = unlimited)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text("Bandwidth limits help prevent saturating your connection during sync operations.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } header: {
                Label("Bandwidth Throttling", systemImage: "gauge")
            }
            
            Section {
                HStack {
                    Spacer()
                    Button("Save Settings") {
                        saveSettings()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .formStyle(.grouped)
        .padding()
        .onAppear {
            loadSettings()
        }
    }
    
    private func selectFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true
        
        if panel.runModal() == .OK {
            localPath = panel.url?.path ?? ""
        }
    }
    
    private func loadSettings() {
        localPath = syncManager.localPath
        remotePath = syncManager.remotePath
        autoSync = syncManager.autoSync
        syncInterval = syncManager.syncInterval
        
        // Load bandwidth limits
        uploadLimitText = uploadLimit > 0 ? String(format: "%.1f", uploadLimit) : ""
        downloadLimitText = downloadLimit > 0 ? String(format: "%.1f", downloadLimit) : ""
    }
    
    private func saveSettings() {
        syncManager.localPath = localPath
        syncManager.remotePath = remotePath
        syncManager.autoSync = autoSync
        syncManager.syncInterval = syncInterval
        
        // Save bandwidth limits
        uploadLimit = Double(uploadLimitText) ?? 0
        downloadLimit = Double(downloadLimitText) ?? 0
        
        Task {
            if syncManager.isMonitoring {
                syncManager.stopMonitoring()
            }
            if autoSync && !localPath.isEmpty {
                await syncManager.startMonitoring()
            }
        }
    }
}

// MARK: - Account Settings

struct AccountSettingsView: View {
    @EnvironmentObject var remotesVM: RemotesViewModel
    @State private var selectedRemote: CloudRemote?
    @State private var showAddSheet = false
    
    var body: some View {
        HSplitView {
            // Remote List
            List(selection: $selectedRemote) {
                Section("Cloud Services") {
                    ForEach(remotesVM.remotes.filter { $0.type != .local }) { remote in
                        RemoteListItem(remote: remote)
                            .tag(remote)
                    }
                }
            }
            .listStyle(.sidebar)
            .frame(minWidth: 180, maxWidth: 220)
            
            // Detail View
            if let remote = selectedRemote {
                RemoteDetailView(remote: remote)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "cloud")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("Select a cloud service")
                        .foregroundColor(.secondary)
                    
                    Button("Add Cloud Storage") {
                        showAddSheet = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddRemoteSheet()
        }
    }
}

struct RemoteListItem: View {
    let remote: CloudRemote
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: remote.displayIcon)
                .foregroundColor(remote.displayColor)
            
            Text(remote.name)
                .lineLimit(1)
            
            Spacer()
            
            Circle()
                .fill(remote.isConfigured ? Color.green : Color.orange)
                .frame(width: 8, height: 8)
        }
    }
}

struct RemoteDetailView: View {
    let remote: CloudRemote
    @EnvironmentObject var remotesVM: RemotesViewModel
    @State private var username = ""
    @State private var password = ""
    @State private var isConfiguring = false
    @State private var errorMessage: String?
    @State private var showProtonSetup = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(remote.displayColor.opacity(0.15))
                            .frame(width: 64, height: 64)
                        
                        Image(systemName: remote.displayIcon)
                            .font(.system(size: 28))
                            .foregroundColor(remote.displayColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(remote.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(remote.isConfigured ? Color.green : Color.orange)
                                .frame(width: 8, height: 8)
                            
                            Text(remote.isConfigured ? "Connected" : "Not configured")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                
                Divider()
                
                // Configuration
                if remote.isConfigured {
                    connectedView
                } else {
                    configurationForm
                }
            }
            .padding()
        }
    }
    
    private var connectedView: some View {
        VStack(alignment: .leading, spacing: 16) {
            GroupBox {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Status")
                        Spacer()
                        Text("Connected")
                            .foregroundColor(.green)
                    }
                    
                    if remote.isEncrypted {
                        HStack {
                            Text("Encryption")
                            Spacer()
                            HStack(spacing: 4) {
                                Image(systemName: "lock.fill")
                                Text("Enabled")
                            }
                            .foregroundColor(.green)
                        }
                    }
                }
                .padding(8)
            }
            
            HStack {
                Button("Test Connection") {
                    // Test
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Disconnect") {
                    disconnect()
                }
                .foregroundColor(.red)
            }
        }
    }
    
    private var configurationForm: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Provider-specific setup
            if remote.type == .protonDrive {
                protonDriveSetup
            } else if remote.type.requiresOAuth {
                oauthSetup
            } else {
                genericCredentialsForm
            }
        }
        .sheet(isPresented: $showProtonSetup) {
            ProtonDriveSetupView(remote: remote) { updatedRemote in
                remotesVM.updateRemote(updatedRemote)
            }
            .environmentObject(remotesVM)
        }
    }
    
    // MARK: - Proton Drive Setup
    
    private var protonDriveSetup: some View {
        VStack(alignment: .leading, spacing: 16) {
            GroupBox {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "shield.checkered")
                            .foregroundColor(Color(red: 0.42, green: 0.31, blue: 0.78))
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("End-to-End Encrypted Storage")
                                .fontWeight(.semibold)
                            Text("Proton Drive requires special setup for 2FA and encryption keys")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Supports two-factor authentication", systemImage: "lock.fill")
                        Label("TOTP secret for persistent auth", systemImage: "key.fill")
                        Label("Mailbox password support", systemImage: "envelope.fill")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding(8)
            }
            
            Button {
                showProtonSetup = true
            } label: {
                HStack {
                    Image(systemName: "gearshape.fill")
                    Text("Open Setup Wizard")
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            Text("The setup wizard will guide you through connecting to Proton Drive.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - OAuth Setup
    
    private var oauthSetup: some View {
        VStack(alignment: .leading, spacing: 16) {
            GroupBox {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "safari")
                            .foregroundColor(.blue)
                        Text("Browser Authentication")
                            .fontWeight(.semibold)
                    }
                    
                    Text("This service uses OAuth. Clicking Connect will open your browser to authenticate.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(8)
            }
            
            Button {
                Task { await connectOAuth() }
            } label: {
                HStack {
                    if isConfiguring {
                        ProgressView()
                            .scaleEffect(0.7)
                    }
                    Text("Connect with \(remote.type.displayName)")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isConfiguring)
            
            if let error = errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text(error)
                        .foregroundColor(.red)
                }
                .font(.caption)
            }
        }
    }
    
    // MARK: - Generic Credentials Form
    
    private var genericCredentialsForm: some View {
        VStack(alignment: .leading, spacing: 16) {
            GroupBox("Credentials") {
                VStack(spacing: 12) {
                    HStack {
                        Text("Username")
                            .frame(width: 80, alignment: .trailing)
                        TextField("user@example.com", text: $username)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    HStack {
                        Text("Password")
                            .frame(width: 80, alignment: .trailing)
                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                .padding(8)
            }
            
            if let error = errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text(error)
                        .foregroundColor(.red)
                }
                .font(.caption)
            }
            
            HStack {
                Spacer()
                
                if isConfiguring {
                    ProgressView()
                        .scaleEffect(0.8)
                }
                
                Button("Connect") {
                    Task { await connect() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(username.isEmpty || password.isEmpty || isConfiguring)
            }
            
            Text("Your credentials are stored securely in the macOS Keychain.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private func connect() async {
        isConfiguring = true
        errorMessage = nil
        
        do {
            try await SyncManager.shared.configureProtonDrive(
                username: username,
                password: password
            )
            
            var updated = remote
            updated.isConfigured = true
            remotesVM.updateRemote(updated)
            
            username = ""
            password = ""
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isConfiguring = false
    }
    
    private func connectOAuth() async {
        isConfiguring = true
        errorMessage = nil
        
        do {
            let remoteName = remote.type.defaultRcloneName
            
            switch remote.type {
            case .googleDrive:
                try await RcloneManager.shared.setupGoogleDrive(remoteName: remoteName)
            case .dropbox:
                try await RcloneManager.shared.setupDropbox(remoteName: remoteName)
            case .oneDrive, .oneDriveBusiness:
                try await RcloneManager.shared.setupOneDrive(remoteName: remoteName)
            case .box:
                try await RcloneManager.shared.setupBox(remoteName: remoteName)
            case .pcloud:
                try await RcloneManager.shared.setupPCloud(remoteName: remoteName)
            case .yandexDisk:
                try await RcloneManager.shared.setupYandexDisk(remoteName: remoteName)
            case .googlePhotos:
                try await RcloneManager.shared.setupGooglePhotos(remoteName: remoteName)
            case .flickr:
                try await RcloneManager.shared.setupFlickr(remoteName: remoteName)
            case .putio:
                try await RcloneManager.shared.setupPutio(remoteName: remoteName)
            default:
                throw RcloneError.configurationFailed("OAuth not supported for \(remote.type.displayName)")
            }
            
            var updated = remote
            updated.isConfigured = true
            updated.customRcloneName = remoteName
            remotesVM.updateRemote(updated)
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isConfiguring = false
    }
    
    private func disconnect() {
        let configPath = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent("CloudSyncApp/rclone.conf")
        
        try? FileManager.default.removeItem(at: configPath)
        UserDefaults.standard.set(false, forKey: "isConfigured")
        
        var updated = remote
        updated.isConfigured = false
        remotesVM.updateRemote(updated)
    }
}

// MARK: - Encryption Settings (Per-Remote)

struct EncryptionSettingsView: View {
    @EnvironmentObject var remotesVM: RemotesViewModel
    @State private var showEncryptionModal = false
    @State private var selectedRemoteForSetup: CloudRemote?
    @State private var showDisableConfirmation = false
    @State private var remoteToDisable: CloudRemote?
    @State private var showExportConfirmation = false
    @State private var errorMessage: String?
    @State private var refreshTrigger = false
    
    private let encryptionManager = EncryptionManager.shared
    
    private var configuredRemotes: [CloudRemote] {
        remotesVM.remotes.filter { $0.isConfigured && $0.type != .local }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.15))
                            .frame(width: 64, height: 64)
                        
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("End-to-End Encryption")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Per-remote encryption with independent passwords")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                Divider()
                
                // Per-Remote Encryption Status
                VStack(alignment: .leading, spacing: 16) {
                    Text("Cloud Storage Encryption")
                        .font(.headline)
                    
                    if configuredRemotes.isEmpty {
                        GroupBox {
                            HStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                    .font(.title2)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("No Cloud Providers Configured")
                                        .fontWeight(.semibold)
                                    Text("Add a cloud provider first to enable encryption")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding(8)
                        }
                    } else {
                        ForEach(configuredRemotes) { remote in
                            remoteEncryptionRow(remote)
                        }
                    }
                }
                
                if let error = errorMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.red)
                        Text(error)
                            .foregroundColor(.red)
                    }
                    .font(.caption)
                    .padding(8)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(6)
                }
                
                Divider()
                
                // Config export/import
                VStack(alignment: .leading, spacing: 12) {
                    Text("Configuration Backup")
                        .font(.headline)
                    
                    GroupBox {
                        VStack(spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Export Configuration")
                                        .fontWeight(.medium)
                                    Text("Backup rclone config including encryption settings")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Button("Export...") {
                                    showExportConfirmation = true
                                }
                                .buttonStyle(.bordered)
                            }
                            
                            Divider()
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Import Configuration")
                                        .fontWeight(.medium)
                                    Text("Restore settings from a backup file")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Button("Import...") {
                                    importRcloneConfig()
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .padding(8)
                    }
                }
                
                Divider()
                
                // Info
                VStack(alignment: .leading, spacing: 12) {
                    Text("About E2E Encryption")
                        .font(.headline)
                    
                    GroupBox {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Zero-knowledge encryption - only you can decrypt", systemImage: "shield.checkered")
                            Label("AES-256 encryption standard", systemImage: "key.fill")
                            Label("Each cloud has independent password", systemImage: "lock.rotation")
                            Label("Toggle ON to see decrypted, OFF to see raw", systemImage: "eye")
                            Label("No password recovery possible - save passwords!", systemImage: "exclamationmark.triangle")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(8)
                    }
                }
            }
            .padding()
        }
        .id(refreshTrigger)
        .sheet(item: $selectedRemoteForSetup) { remote in
            EncryptionModal { config in
                Task {
                    await setupEncryption(for: remote, config: config)
                }
            }
        }
        .alert("Disable Encryption?", isPresented: $showDisableConfirmation) {
            Button("Disable", role: .destructive) {
                if let remote = remoteToDisable {
                    Task { await disableEncryption(for: remote) }
                }
            }
            Button("Cancel", role: .cancel) {
                remoteToDisable = nil
            }
        } message: {
            Text("This will remove the encryption configuration for \(remoteToDisable?.name ?? "this remote"). Existing encrypted files will remain encrypted but you won't be able to decrypt them without reconfiguring.")
        }
        .alert("Export Configuration?", isPresented: $showExportConfirmation) {
            Button("Export", role: .destructive) {
                exportRcloneConfig()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("The rclone config file contains sensitive credentials. Store it securely.")
        }
        .onReceive(NotificationCenter.default.publisher(for: .encryptionStateChanged)) { _ in
            refreshTrigger.toggle()
        }
    }
    
    @ViewBuilder
    private func remoteEncryptionRow(_ remote: CloudRemote) -> some View {
        let isConfigured = encryptionManager.isEncryptionConfigured(for: remote.rcloneName)
        let isEnabled = encryptionManager.isEncryptionEnabled(for: remote.rcloneName)
        
        GroupBox {
            HStack(spacing: 12) {
                Image(systemName: remote.displayIcon)
                    .foregroundColor(remote.displayColor)
                    .font(.title2)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(remote.name)
                        .fontWeight(.semibold)
                    
                    if isConfigured {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            Text("Encryption configured")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "circle")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            Text("Not configured")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                if isConfigured {
                    // Toggle for enabling/disabling encryption view
                    Toggle("", isOn: Binding(
                        get: { isEnabled },
                        set: { newValue in
                            encryptionManager.setEncryptionEnabled(newValue, for: remote.rcloneName)
                            refreshTrigger.toggle()
                        }
                    ))
                    .toggleStyle(.switch)
                    .labelsHidden()
                    .help(isEnabled ? "Encryption ON - viewing decrypted" : "Encryption OFF - viewing raw")
                    
                    Button {
                        remoteToDisable = remote
                        showDisableConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.borderless)
                    .help("Remove encryption")
                } else {
                    Button("Setup") {
                        selectedRemoteForSetup = remote
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(8)
        }
    }
    
    private func setupEncryption(for remote: CloudRemote, config: EncryptionConfig) async {
        errorMessage = nil
        
        do {
            let remoteName = remote.rcloneName
            let salt = encryptionManager.generateSecureSalt()
            
            // Create the encryption config
            let remoteConfig = RemoteEncryptionConfig(
                password: config.password,
                salt: salt,
                encryptFilenames: config.encryptFilenames,
                encryptFolders: config.encryptFolders
            )
            
            // Setup crypt remote
            try await RcloneManager.shared.setupCryptRemote(
                for: remoteName,
                config: remoteConfig
            )
            
            // Enable encryption by default after setup
            encryptionManager.setEncryptionEnabled(true, for: remoteName)
            
            await MainActor.run {
                refreshTrigger.toggle()
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func disableEncryption(for remote: CloudRemote) async {
        do {
            try await RcloneManager.shared.deleteCryptRemote(for: remote.rcloneName)
            await MainActor.run {
                remoteToDisable = nil
                refreshTrigger.toggle()
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func exportRcloneConfig() {
        let panel = NSSavePanel()
        panel.title = "Export rclone Configuration"
        panel.nameFieldStringValue = "rclone.conf"
        panel.allowedContentTypes = [.text]
        panel.canCreateDirectories = true
        
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            
            let configPath = FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            )[0].appendingPathComponent("CloudSyncApp/rclone.conf")
            
            do {
                try FileManager.default.copyItem(at: configPath, to: url)
                NSWorkspace.shared.activateFileViewerSelecting([url])
            } catch {
                print("Export failed: \(error)")
            }
        }
    }
    
    private func importRcloneConfig() {
        let panel = NSOpenPanel()
        panel.title = "Import rclone Configuration"
        panel.allowedContentTypes = [.text]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            
            let configPath = FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            )[0].appendingPathComponent("CloudSyncApp/rclone.conf")
            
            do {
                // Backup existing config
                let backupPath = configPath.deletingLastPathComponent().appendingPathComponent("rclone.conf.backup")
                if FileManager.default.fileExists(atPath: configPath.path) {
                    try? FileManager.default.removeItem(at: backupPath)
                    try FileManager.default.copyItem(at: configPath, to: backupPath)
                }
                
                // Import new config
                try? FileManager.default.removeItem(at: configPath)
                try FileManager.default.copyItem(at: url, to: configPath)
                
                // Reload remotes
                RemotesViewModel.shared.loadRemotes()
            } catch {
                print("Import failed: \(error)")
            }
        }
    }
}

// MARK: - About View

struct AboutView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Logo
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: "cloud.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 8) {
                Text("CloudSync Ultra")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Version 2.0.0")
                    .foregroundColor(.secondary)
            }
            
            Text("The ultimate cloud backup and sync solution")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // Features
            HStack(spacing: 32) {
                featureItem(icon: "arrow.triangle.2.circlepath", title: "Sync")
                featureItem(icon: "arrow.left.arrow.right", title: "Transfer")
                featureItem(icon: "lock.shield", title: "Encrypt")
                featureItem(icon: "externaldrive.fill.badge.timemachine", title: "Backup")
            }
            
            Divider()
                .frame(width: 200)
            
            VStack(spacing: 8) {
                Text("Powered by rclone")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 16) {
                    Link("Website", destination: URL(string: "https://rclone.org")!)
                    Link("Documentation", destination: URL(string: "https://rclone.org/docs/")!)
                }
                .font(.caption)
            }
            
            Spacer()
            
            Text("© 2026 CloudSync Ultra. All rights reserved.")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    private func featureItem(icon: String, title: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// Note: EncryptionModal and EncryptionConfig are defined in Views/EncryptionModal.swift

#Preview {
    SettingsView()
        .environmentObject(SyncManager.shared)
        .environmentObject(RemotesViewModel.shared)
}
