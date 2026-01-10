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
            
            EncryptionSettingsView()
                .tabItem {
                    Label("Security", systemImage: "lock.shield")
                }
                .tag(2)
            
            SyncSettingsView()
                .tabItem {
                    Label("Sync", systemImage: "arrow.triangle.2.circlepath")
                }
                .tag(3)
            
            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
                .tag(4)
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
    }
    
    private func saveSettings() {
        syncManager.localPath = localPath
        syncManager.remotePath = remotePath
        syncManager.autoSync = autoSync
        syncManager.syncInterval = syncInterval
        
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

// MARK: - Encryption Settings (kept from original)

struct EncryptionSettingsView: View {
    @State private var isEncryptionEnabled = false
    @State private var isConfigured = false
    @State private var encryptFilenames = true
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var salt = ""
    @State private var isConfiguring = false
    @State private var errorMessage: String?
    @State private var showPasswordWarning = false
    @State private var showDisableConfirmation = false
    
    private let encryptionManager = EncryptionManager.shared
    
    var body: some View {
        Form {
            Section {
                encryptionStatusView
            } header: {
                Label("End-to-End Encryption", systemImage: "lock.shield")
            }
            
            if !isConfigured {
                Section {
                    setupFormView
                } header: {
                    Label("Setup Encryption", systemImage: "key")
                }
            }
            
            Section {
                encryptionInfoView
            } header: {
                Label("About E2E Encryption", systemImage: "info.circle")
            }
        }
        .formStyle(.grouped)
        .padding()
        .onAppear {
            loadState()
        }
        .alert("Important: Save Your Password", isPresented: $showPasswordWarning) {
            Button("I Understand", role: .destructive) {
                Task { await setupEncryption() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your encryption password cannot be recovered. If you lose it, your encrypted files will be permanently inaccessible.")
        }
        .alert("Disable Encryption?", isPresented: $showDisableConfirmation) {
            Button("Disable", role: .destructive) {
                Task { await disableEncryption() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Disabling encryption will not decrypt existing encrypted files.")
        }
    }
    
    @ViewBuilder
    private var encryptionStatusView: some View {
        HStack {
            if isConfigured && isEncryptionEnabled {
                Image(systemName: "lock.shield.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                VStack(alignment: .leading, spacing: 4) {
                    Text("E2E Encryption Active")
                        .fontWeight(.semibold)
                    Text("Your files are encrypted before upload")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button("Disable") {
                    showDisableConfirmation = true
                }
                .foregroundColor(.red)
            } else {
                Image(systemName: "lock.open")
                    .foregroundColor(.orange)
                    .font(.title2)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Encryption Not Configured")
                        .fontWeight(.semibold)
                    Text("Files are synced without client-side encryption")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private var setupFormView: some View {
        VStack(alignment: .leading, spacing: 12) {
            SecureField("Encryption Password", text: $password)
            SecureField("Confirm Password", text: $confirmPassword)
            TextField("Salt (optional)", text: $salt)
            
            Toggle("Encrypt file and folder names", isOn: $encryptFilenames)
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            HStack {
                Spacer()
                Button("Enable Encryption") {
                    validateAndShowWarning()
                }
                .buttonStyle(.borderedProminent)
                .disabled(password.isEmpty || confirmPassword.isEmpty || isConfiguring)
            }
        }
    }
    
    @ViewBuilder
    private var encryptionInfoView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Zero-knowledge encryption", systemImage: "shield.checkered")
            Label("AES-256 encryption standard", systemImage: "key.fill")
            Label("No password recovery possible", systemImage: "exclamationmark.triangle")
        }
        .font(.caption)
        .foregroundColor(.secondary)
    }
    
    private func loadState() {
        isEncryptionEnabled = encryptionManager.isEncryptionEnabled
        isConfigured = encryptionManager.isEncryptionConfigured
        encryptFilenames = encryptionManager.encryptFilenames
    }
    
    private func validateAndShowWarning() {
        errorMessage = nil
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }
        
        guard password.count >= 8 else {
            errorMessage = "Password must be at least 8 characters"
            return
        }
        
        showPasswordWarning = true
    }
    
    private func setupEncryption() async {
        isConfiguring = true
        let finalSalt = salt.isEmpty ? encryptionManager.generateSecureSalt() : salt
        
        do {
            try await SyncManager.shared.configureEncryption(
                password: password,
                salt: finalSalt,
                encryptFilenames: encryptFilenames
            )
            isConfigured = true
            isEncryptionEnabled = true
            password = ""
            confirmPassword = ""
            salt = ""
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isConfiguring = false
    }
    
    private func disableEncryption() async {
        do {
            try await SyncManager.shared.disableEncryption()
            isConfigured = false
            isEncryptionEnabled = false
        } catch {
            errorMessage = error.localizedDescription
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

#Preview {
    SettingsView()
        .environmentObject(SyncManager.shared)
        .environmentObject(RemotesViewModel.shared)
}
