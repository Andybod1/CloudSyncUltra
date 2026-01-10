//
//  MainWindow.swift
//  CloudSyncApp
//
//  Main application window with sidebar navigation
//

import SwiftUI

struct MainWindow: View {
    @StateObject private var syncManager = SyncManager.shared
    @StateObject private var remotesVM = RemotesViewModel.shared
    @StateObject private var tasksVM = TasksViewModel.shared
    
    @State private var selectedSection: SidebarSection = .dashboard
    @State private var selectedRemote: CloudRemote?
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    enum SidebarSection: Hashable {
        case dashboard
        case transfer
        case tasks
        case history
        case settings
        case remote(CloudRemote)
    }
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView(
                selectedSection: $selectedSection,
                selectedRemote: $selectedRemote,
                remotes: remotesVM.remotes,
                runningTasks: tasksVM.runningTasksCount
            )
            .navigationSplitViewColumnWidth(min: 200, ideal: 240, max: 300)
        } detail: {
            detailView
        }
        .navigationSplitViewStyle(.balanced)
        .frame(minWidth: 1000, minHeight: 600)
        .environmentObject(syncManager)
        .environmentObject(remotesVM)
        .environmentObject(tasksVM)
        .onReceive(NotificationCenter.default.publisher(for: .navigateToRemote)) { notification in
            if let remote = notification.object as? CloudRemote {
                selectedSection = .remote(remote)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToTransfer)) { _ in
            selectedSection = .transfer
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToTasks)) { _ in
            selectedSection = .tasks
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToHistory)) { _ in
            selectedSection = .history
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToSettings)) { _ in
            selectedSection = .settings
        }
    }
    
    @ViewBuilder
    private var detailView: some View {
        switch selectedSection {
        case .dashboard:
            DashboardView()
        case .transfer:
            TransferView()
        case .tasks:
            TasksView()
        case .history:
            HistoryView()
        case .settings:
            SettingsView()
        case .remote(let remote):
            FileBrowserView(remote: remote)
                .id(remote.id)  // Force recreation when remote changes
        }
    }
}

// MARK: - Sidebar

struct SidebarView: View {
    @Binding var selectedSection: MainWindow.SidebarSection
    @Binding var selectedRemote: CloudRemote?
    let remotes: [CloudRemote]
    let runningTasks: Int
    
    @State private var isAddingRemote = false
    @State private var remoteToConnect: CloudRemote?
    
    var body: some View {
        List(selection: $selectedSection) {
            // Main Navigation
            Section {
                sidebarItem(
                    icon: "square.grid.2x2",
                    title: "Dashboard",
                    section: .dashboard
                )
                
                sidebarItem(
                    icon: "arrow.left.arrow.right",
                    title: "Transfer",
                    section: .transfer
                )
                
                sidebarItem(
                    icon: "list.bullet.clipboard",
                    title: "Tasks",
                    section: .tasks,
                    badge: runningTasks > 0 ? runningTasks : nil
                )
                
                sidebarItem(
                    icon: "clock.arrow.circlepath",
                    title: "History",
                    section: .history
                )
            }
            
            // Cloud Remotes
            Section("Cloud Storage") {
                ForEach(remotes.filter { $0.type != .local }) { remote in
                    remoteSidebarItem(remote)
                        .contextMenu {
                            if !remote.isConfigured {
                                Button("Connect...") {
                                    remoteToConnect = remote
                                }
                            } else {
                                Button("Reconnect...") {
                                    remoteToConnect = remote
                                }
                            }
                            Button("Remove", role: .destructive) {
                                RemotesViewModel.shared.removeRemote(remote)
                            }
                        }
                }
                
                Button {
                    isAddingRemote = true
                } label: {
                    Label("Add Cloud...", systemImage: "plus.circle")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .padding(.vertical, 4)
            }
            
            // Local Storage
            Section("Local") {
                ForEach(remotes.filter { $0.type == .local }) { remote in
                    remoteSidebarItem(remote)
                }
            }
            
            Spacer()
            
            // Settings at bottom
            Section {
                sidebarItem(
                    icon: "gearshape",
                    title: "Settings",
                    section: .settings
                )
            }
        }
        .listStyle(.sidebar)
        .sheet(isPresented: $isAddingRemote) {
            AddRemoteSheet(onRemoteAdded: { remote in
                // After adding, prompt to connect
                remoteToConnect = remote
            })
        }
        .sheet(item: $remoteToConnect) { remote in
            ConnectRemoteSheet(remote: remote)
        }
    }
    
    private func sidebarItem(
        icon: String,
        title: String,
        section: MainWindow.SidebarSection,
        badge: Int? = nil
    ) -> some View {
        HStack {
            Label(title, systemImage: icon)
            Spacer()
            if let badge = badge {
                Text("\(badge)")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.accentColor)
                    .clipShape(Capsule())
            }
        }
        .tag(section)
    }
    
    private func remoteSidebarItem(_ remote: CloudRemote) -> some View {
        HStack(spacing: 8) {
            Image(systemName: remote.displayIcon)
                .foregroundColor(remote.displayColor)
                .frame(width: 20)
            
            Text(remote.name)
                .lineLimit(1)
            
            Spacer()
            
            if remote.isEncrypted {
                Image(systemName: "lock.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if !remote.isConfigured {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .help("Not connected - click to configure")
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .tag(MainWindow.SidebarSection.remote(remote))
        .onTapGesture(count: 2) {
            if !remote.isConfigured {
                remoteToConnect = remote
            }
        }
    }
}

// MARK: - Add Remote Sheet

struct AddRemoteSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var remotesVM: RemotesViewModel
    
    var onRemoteAdded: ((CloudRemote) -> Void)?
    
    @State private var selectedProvider: CloudProviderType = .googleDrive
    @State private var remoteName: String = ""
    
    let supportedProviders = CloudProviderType.allCases.filter { $0.isSupported && $0 != .local }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Add Cloud Storage")
                    .font(.headline)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()
            
            Divider()
            
            // Provider Grid
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 140, maximum: 180), spacing: 12)
                ], spacing: 12) {
                    ForEach(supportedProviders) { provider in
                        ProviderCard(
                            provider: provider,
                            isSelected: selectedProvider == provider
                        ) {
                            selectedProvider = provider
                            if remoteName.isEmpty {
                                remoteName = provider.displayName
                            }
                        }
                    }
                }
                .padding()
            }
            
            Divider()
            
            // Footer
            HStack {
                TextField("Remote Name", text: $remoteName)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 200)
                
                Spacer()
                
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.escape)
                
                Button("Add & Connect") {
                    addRemote()
                }
                .buttonStyle(.borderedProminent)
                .disabled(remoteName.isEmpty)
            }
            .padding()
        }
        .frame(width: 600, height: 500)
    }
    
    private func addRemote() {
        let remote = CloudRemote(
            name: remoteName,
            type: selectedProvider,
            isConfigured: false,
            path: ""
        )
        remotesVM.addRemote(remote)
        dismiss()
        onRemoteAdded?(remote)
    }
}

// MARK: - Connect Remote Sheet

struct ConnectRemoteSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var remotesVM: RemotesViewModel
    
    let remote: CloudRemote
    
    @State private var username = ""
    @State private var password = ""
    @State private var twoFactorCode = ""
    @State private var isConnecting = false
    @State private var errorMessage: String?
    @State private var isConnected = false
    
    private var needsTwoFactor: Bool {
        remote.type == .protonDrive
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: remote.displayIcon)
                    .foregroundColor(remote.displayColor)
                    .font(.title2)
                
                VStack(alignment: .leading) {
                    Text("Connect to \(remote.name)")
                        .font(.headline)
                    Text(remote.type.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()
            
            Divider()
            
            if isConnected {
                // Success state
                VStack(spacing: 20) {
                    Spacer()
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.green)
                    
                    Text("Connected Successfully!")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("\(remote.name) is now ready to use")
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button("Done") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else {
                // Credentials form
                Form {
                    Section {
                        TextField("Username / Email", text: $username)
                            .textFieldStyle(.roundedBorder)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)
                        
                        if needsTwoFactor {
                            TextField("2FA Code (6 digits)", text: $twoFactorCode)
                                .textFieldStyle(.roundedBorder)
                        }
                    } header: {
                        Text("Credentials")
                    } footer: {
                        credentialsHelp
                    }
                    
                    if let error = errorMessage {
                        Section {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text(error)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                .formStyle(.grouped)
                .padding()
                
                Divider()
                
                // Footer
                HStack {
                    Button("Cancel") { dismiss() }
                        .keyboardShortcut(.escape)
                    
                    Spacer()
                    
                    if isConnecting {
                        ProgressView()
                            .scaleEffect(0.8)
                            .padding(.trailing, 8)
                    }
                    
                    Button("Connect") {
                        connect()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!canConnect || isConnecting)
                }
                .padding()
            }
        }
        .frame(width: 450, height: needsTwoFactor ? 450 : 400)
    }
    
    private var canConnect: Bool {
        if username.isEmpty || password.isEmpty {
            return false
        }
        if needsTwoFactor && twoFactorCode.isEmpty {
            return false
        }
        return true
    }
    
    @ViewBuilder
    private var credentialsHelp: some View {
        switch remote.type {
        case .protonDrive:
            Text("Enter your Proton account email, password, and 2FA code from your authenticator app.")
        case .googleDrive:
            Text("Enter your Google account credentials. You may be redirected to authorize access.")
        case .dropbox:
            Text("Enter your Dropbox email and password.")
        case .oneDrive:
            Text("Enter your Microsoft account credentials.")
        case .s3:
            Text("Enter your AWS Access Key ID and Secret Access Key.")
        case .mega:
            Text("Enter your MEGA email and password.")
        default:
            Text("Enter your account credentials for \(remote.type.displayName).")
        }
    }
    
    private func connect() {
        isConnecting = true
        errorMessage = nil
        
        Task {
            do {
                // Configure the remote via rclone using rcloneName
                try await configureRemote()
                
                // Update the remote as configured
                var updatedRemote = remote
                updatedRemote.isConfigured = true
                remotesVM.updateRemote(updatedRemote)
                
                isConnected = true
            } catch {
                errorMessage = error.localizedDescription
            }
            isConnecting = false
        }
    }
    
    private func configureRemote() async throws {
        let rclone = RcloneManager.shared
        let rcloneName = remote.rcloneName
        
        switch remote.type {
        case .protonDrive:
            try await rclone.setupProtonDrive(
                username: username,
                password: password,
                twoFactorCode: twoFactorCode.isEmpty ? nil : twoFactorCode
            )
        case .googleDrive:
            try await rclone.setupGoogleDrive(remoteName: rcloneName)
        case .dropbox:
            try await rclone.setupDropbox(remoteName: rcloneName)
        case .oneDrive:
            try await rclone.setupOneDrive(remoteName: rcloneName)
        case .s3:
            try await rclone.setupS3(remoteName: rcloneName, accessKey: username, secretKey: password)
        case .mega:
            try await rclone.setupMega(remoteName: rcloneName, username: username, password: password)
        case .box:
            try await rclone.setupBox(remoteName: rcloneName)
        case .pcloud:
            try await rclone.setupPCloud(remoteName: rcloneName, username: username, password: password)
        case .webdav:
            try await rclone.setupWebDAV(remoteName: rcloneName, url: username, password: password)
        case .sftp:
            try await rclone.setupSFTP(remoteName: rcloneName, host: username, password: password)
        case .ftp:
            try await rclone.setupFTP(remoteName: rcloneName, host: username, password: password)
        default:
            throw RcloneError.configurationFailed("Provider \(remote.type.displayName) not yet supported")
        }
    }
}

struct ProviderCard: View {
    let provider: CloudProviderType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(provider.brandColor.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: provider.iconName)
                        .font(.title2)
                        .foregroundColor(provider.brandColor)
                }
                
                Text(provider.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? provider.brandColor.opacity(0.1) : Color(NSColor.controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? provider.brandColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MainWindow()
}
