//
//  MainWindow.swift
//  CloudSyncApp
//
//  Main application window with sidebar navigation
//

import SwiftUI
import Foundation

// MARK: - Transfer View State

class TransferViewState: ObservableObject {
    @Published var sourceRemoteId: UUID?
    @Published var destRemoteId: UUID?
    @Published var sourcePath: String = ""
    @Published var destPath: String = ""
    @Published var selectedSourceFiles: Set<UUID> = []
    @Published var selectedDestFiles: Set<UUID> = []
    @Published var transferMode: TaskType = .transfer
}

struct MainWindow: View {
    @StateObject private var syncManager = SyncManager.shared
    @StateObject private var remotesVM = RemotesViewModel.shared
    @StateObject private var tasksVM = TasksViewModel.shared
    @StateObject private var transferState = TransferViewState()

    @State private var selectedSection: SidebarSection = .dashboard
    @State private var selectedRemote: CloudRemote?
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    enum SidebarSection: Hashable {
        case dashboard
        case transfer
        case encryption
        case tasks
        case history
        case schedules
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
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenSettings"))) { _ in
            selectedSection = .settings
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenDashboard"))) { _ in
            selectedSection = .dashboard
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenScheduleSettings"))) { _ in
            selectedSection = .schedules
        }
    }
    
    @ViewBuilder
    private var detailView: some View {
        switch selectedSection {
        case .dashboard:
            DashboardView()
        case .transfer:
            TransferView()
                .environmentObject(transferState)
        case .encryption:
            EncryptionSettingsView()
        case .tasks:
            TasksView()
        case .history:
            HistoryView()
        case .schedules:
            SchedulesView()
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
                    icon: "calendar.badge.clock",
                    title: "Schedules",
                    section: .schedules
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
                .onMove(perform: moveCloudRemotes)
                
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
                    icon: "lock.shield.fill",
                    title: "Encryption",
                    section: .encryption
                )
                
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

    private func moveCloudRemotes(from source: IndexSet, to destination: Int) {
        RemotesViewModel.shared.moveCloudRemotes(from: source, to: destination)
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
        // Only show encryption status for cloud remotes, not local storage
        let isCloudRemote = remote.type != .local
        let hasEncryption = isCloudRemote && EncryptionManager.shared.isEncryptionConfigured(for: remote.rcloneName)
        let isEncryptionOn = isCloudRemote && EncryptionManager.shared.isEncryptionEnabled(for: remote.rcloneName)

        return HStack(spacing: 8) {
            Image(systemName: remote.displayIcon)
                .foregroundColor(remote.displayColor)
                .frame(width: 20)

            RemoteNameWithHover(name: remote.name)

            Spacer()
            
            // Show encryption status (only for cloud remotes, not local storage)
            if hasEncryption {
                Image(systemName: isEncryptionOn ? "lock.fill" : "lock.open")
                    .font(.caption)
                    .foregroundColor(isEncryptionOn ? .green : .orange)
                    .help(isEncryptionOn ? "Encryption enabled" : "Encryption configured but disabled")
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
    }
}

// MARK: - Remote Name with Hover

struct RemoteNameWithHover: View {
    let name: String
    @State private var isHoveringUsername = false

    var body: some View {
        Text(name)
            .lineLimit(1)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(isHoveringUsername ? Color.accentColor.opacity(0.1) : Color.clear)
            .cornerRadius(4)
            .onHover { hovering in
                isHoveringUsername = hovering
            }
    }
}

// MARK: - Add Remote Sheet

struct AddRemoteSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var remotesVM: RemotesViewModel

    var onRemoteAdded: ((CloudRemote) -> Void)?

    @State private var selectedProvider: CloudProviderType?
    @State private var remoteName: String = ""
    @State private var searchText = ""

    let supportedProviders = CloudProviderType.allCases.filter { $0.isSupported && $0 != .local }

    var filteredProviders: [CloudProviderType] {
        if searchText.isEmpty {
            return supportedProviders
        }
        return supportedProviders.filter { provider in
            provider.displayName.localizedCaseInsensitiveContains(searchText)
        }
    }
    
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

            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search providers...", text: $searchText)
                    .textFieldStyle(.plain)
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(Color(.textBackgroundColor))
            .cornerRadius(8)
            .padding()

            // Provider Grid
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 140, maximum: 180), spacing: 12)
                ], spacing: 12) {
                    ForEach(filteredProviders) { provider in
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
            
            // Name field - only after provider selected
            if selectedProvider != nil {
                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Remote Name")
                        .font(.headline)
                    TextField("Enter a name for this remote", text: $remoteName)
                        .textFieldStyle(.roundedBorder)
                }
                .padding()
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            Divider()

            // Footer
            HStack {
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.escape)

                Spacer()

                // Continue button
                if selectedProvider != nil && !remoteName.isEmpty {
                    Button("Add & Connect") {
                        addRemote()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
        .frame(width: 600, height: 500)
        .animation(.default, value: selectedProvider)
    }
    
    private func addRemote() {
        guard let provider = selectedProvider else { return }
        let remote = CloudRemote(
            name: remoteName,
            type: provider,
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
                        // Hide username field for Jottacloud (only needs token)
                        if remote.type != .jottacloud {
                            TextField("Username / Email", text: $username)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        // Use appropriate label based on provider
                        if remote.type == .jottacloud {
                            SecureField("Personal Login Token", text: $password)
                                .textFieldStyle(.roundedBorder)
                        } else {
                            SecureField("Password", text: $password)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        if needsTwoFactor {
                            TextField("2FA Code (6 digits)", text: $twoFactorCode)
                                .textFieldStyle(.roundedBorder)
                        }
                    } header: {
                        if remote.type == .jottacloud {
                            Text("Authentication Token")
                        } else {
                            Text("Credentials")
                        }
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
        // Jottacloud only needs the token (stored in password field)
        if remote.type == .jottacloud {
            return !password.isEmpty
        }
        
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
        case .jottacloud:
            VStack(alignment: .leading, spacing: 4) {
                Text("Jottacloud requires a Personal Login Token (not your password).")
                Text("1. Click the link below to open Jottacloud settings")
                Text("2. Scroll to 'Personal login token' and click 'Generate'")
                Text("3. Copy and paste the token into the Password field above")
                Link("Open Jottacloud Security Settings →", destination: URL(string: "https://www.jottacloud.com/web/secure")!)
                    .font(.caption)
            }
            .font(.caption2)
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
            try await rclone.setupPCloud(remoteName: rcloneName)
        case .webdav:
            try await rclone.setupWebDAV(remoteName: rcloneName, url: username, password: password)
        case .sftp:
            try await rclone.setupSFTP(remoteName: rcloneName, host: username, password: password)
        case .ftp:
            try await rclone.setupFTP(remoteName: rcloneName, host: username, password: password)
        case .jottacloud:
            // Password field contains the personal login token (not account password)
            try await rclone.setupJottacloud(remoteName: rcloneName, personalLoginToken: password)
        
        // OAuth Expansion: Media & Consumer
        case .flickr:
            try await rclone.setupFlickr(remoteName: rcloneName)
        case .sugarsync:
            try await rclone.setupSugarSync(remoteName: rcloneName)
        case .opendrive:
            try await rclone.setupOpenDrive(remoteName: rcloneName)
        
        // OAuth Expansion: Specialized & Enterprise
        case .putio:
            try await rclone.setupPutio(remoteName: rcloneName)
        case .premiumizeme:
            try await rclone.setupPremiumizeme(remoteName: rcloneName)
        case .quatrix:
            try await rclone.setupQuatrix(remoteName: rcloneName)
        case .filefabric:
            try await rclone.setupFileFabric(remoteName: rcloneName)
        
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
            VStack(spacing: 8) {
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
                
                if provider.isExperimental {
                    Text("EXPERIMENTAL")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
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
