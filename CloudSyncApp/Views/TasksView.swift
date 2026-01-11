//
//  TasksView.swift
//  CloudSyncApp
//
//  Active and scheduled tasks management
//

import SwiftUI

struct TasksView: View {
    @EnvironmentObject var tasksVM: TasksViewModel
    @State private var showNewTaskSheet = false
    @State private var selectedTask: SyncTask?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            taskHeader
            
            Divider()
            
            if tasksVM.tasks.isEmpty {
                emptyState
            } else {
                taskList
            }
        }
        .background(Color(NSColor.windowBackgroundColor))
        .navigationTitle("Tasks")
        .sheet(isPresented: $showNewTaskSheet) {
            NewTaskSheet()
        }
        .sheet(item: $selectedTask) { task in
            TaskDetailSheet(task: task)
        }
    }
    
    private var taskHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Active Tasks")
                    .font(.headline)
                Text("\(tasksVM.tasks.count) tasks • \(tasksVM.runningTasksCount) running")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button {
                showNewTaskSheet = true
            } label: {
                Label("New Task", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 64))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("No Active Tasks")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Create a new sync, transfer, or backup task to get started")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                showNewTaskSheet = true
            } label: {
                Label("Create Task", systemImage: "plus")
            }
            .buttonStyle(PrimaryButtonStyle())
            
            Spacer()
        }
        .padding()
    }
    
    private var taskList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(tasksVM.tasks) { task in
                    TaskCard(task: task) {
                        selectedTask = task
                    } onStart: {
                        Task { await tasksVM.startTask(task) }
                    } onPause: {
                        tasksVM.pauseTask(task)
                    } onCancel: {
                        tasksVM.cancelTask(task)
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Task Card

struct TaskCard: View {
    let task: SyncTask
    let onTap: () -> Void
    let onStart: () -> Void
    let onPause: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Image(systemName: task.type.icon)
                    .font(.title2)
                    .foregroundColor(statusColor)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(task.name)
                            .font(.headline)
                        
                        // Encryption badge
                        if task.hasEncryption {
                            HStack(spacing: 2) {
                                Image(systemName: "lock.fill")
                                    .font(.caption2)
                                Text("E2E Encrypted")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.green)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.15))
                            .cornerRadius(4)
                        }
                    }
                    
                    HStack(spacing: 4) {
                        // Source with encryption indicator
                        HStack(spacing: 2) {
                            if task.encryptSource {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(.green)
                            }
                            Text(task.sourceRemote)
                        }
                        
                        Image(systemName: "arrow.right")
                            .font(.caption)
                        
                        // Destination with encryption indicator
                        HStack(spacing: 2) {
                            if task.encryptDestination {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(.green)
                            }
                            Text(task.destinationRemote)
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Status Badge
                StatusBadge(state: task.state)
                
                // Actions
                taskActions
            }
            
            // Progress
            if task.state == .running {
                VStack(spacing: 8) {
                    ProgressView(value: task.progress)
                        .progressViewStyle(.linear)
                    
                    HStack {
                        Text(task.formattedProgress)
                        Spacer()
                        if !task.speed.isEmpty {
                            Text(task.speed)
                        }
                        if !task.eta.isEmpty {
                            Text("ETA: \(task.eta)")
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            
            // Details
            if task.state == .running || task.totalFiles > 0 {
                Divider()
                
                HStack {
                    Label(task.formattedFilesTransferred, systemImage: "doc.fill")
                    Spacer()
                    Label(task.formattedBytesTransferred, systemImage: "arrow.up.arrow.down")
                    Spacer()
                    Label(task.formattedDuration, systemImage: "clock")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            // Error
            if case .failed = task.state, let error = task.errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .padding(8)
                .background(Color.red.opacity(0.1))
                .cornerRadius(6)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(AppDimensions.cornerRadius)
        .onTapGesture(perform: onTap)
    }
    
    private var taskActions: some View {
        HStack(spacing: 8) {
            switch task.state {
            case .pending:
                Button(action: onStart) {
                    Image(systemName: "play.fill")
                }
                .buttonStyle(.bordered)
                
            case .running:
                Button(action: onPause) {
                    Image(systemName: "pause.fill")
                }
                .buttonStyle(.bordered)
                
            case .paused:
                Button(action: onStart) {
                    Image(systemName: "play.fill")
                }
                .buttonStyle(.bordered)
                
            default:
                EmptyView()
            }
            
            if task.state != .completed && task.state != .cancelled {
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)
            }
        }
    }
    
    private var statusColor: Color {
        switch task.state {
        case .pending: return .gray
        case .running: return .blue
        case .completed: return .green
        case .failed: return .red
        case .paused: return .orange
        case .cancelled: return .gray
        }
    }
}

struct StatusBadge: View {
    let state: TaskState
    
    var body: some View {
        Text(state.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .cornerRadius(4)
    }
    
    private var color: Color {
        switch state {
        case .pending: return .gray
        case .running: return .blue
        case .completed: return .green
        case .failed: return .red
        case .paused: return .orange
        case .cancelled: return .gray
        }
    }
}

// MARK: - New Task Sheet

struct NewTaskSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var remotesVM: RemotesViewModel
    @EnvironmentObject var tasksVM: TasksViewModel
    
    @State private var taskName = ""
    @State private var taskType: TaskType = .transfer
    @State private var sourceRemote: CloudRemote?
    @State private var sourcePath = ""
    @State private var destRemote: CloudRemote?
    @State private var destPath = ""
    @State private var isScheduled = false
    @State private var scheduleInterval: Double = 3600
    
    // Encryption
    @State private var encryptSource = false
    @State private var encryptDestination = false
    @State private var showSourceEncryptionSetup = false
    @State private var showDestEncryptionSetup = false
    
    private var sourceHasEncryption: Bool {
        guard let remote = sourceRemote else { return false }
        return EncryptionManager.shared.isEncryptionConfigured(for: remote.rcloneName)
    }
    
    private var destHasEncryption: Bool {
        guard let remote = destRemote else { return false }
        return EncryptionManager.shared.isEncryptionConfigured(for: remote.rcloneName)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("New Task")
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
            
            Form {
                Section("Task Details") {
                    TextField("Task Name", text: $taskName)
                    
                    Picker("Type", selection: $taskType) {
                        ForEach(TaskType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                }
                
                Section("Source") {
                    Picker("Remote", selection: $sourceRemote) {
                        Text("Select...").tag(nil as CloudRemote?)
                        ForEach(remotesVM.configuredRemotes) { remote in
                            Label(remote.name, systemImage: remote.displayIcon)
                                .tag(remote as CloudRemote?)
                        }
                    }
                    .onChange(of: sourceRemote) { _, newValue in
                        // Auto-enable encryption if configured
                        if let remote = newValue {
                            encryptSource = EncryptionManager.shared.isEncryptionEnabled(for: remote.rcloneName)
                        }
                    }
                    
                    TextField("Path", text: $sourcePath)
                    
                    // Encryption toggle for source
                    if sourceRemote != nil {
                        HStack {
                            Toggle(isOn: $encryptSource) {
                                HStack(spacing: 6) {
                                    Image(systemName: encryptSource ? "lock.fill" : "lock.open")
                                        .foregroundColor(encryptSource ? .green : .secondary)
                                    Text("Encrypt Source")
                                }
                            }
                            .disabled(!sourceHasEncryption)
                            
                            if !sourceHasEncryption {
                                Button("Setup") {
                                    showSourceEncryptionSetup = true
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                            }
                        }
                    }
                }
                
                Section("Destination") {
                    Picker("Remote", selection: $destRemote) {
                        Text("Select...").tag(nil as CloudRemote?)
                        ForEach(remotesVM.configuredRemotes) { remote in
                            Label(remote.name, systemImage: remote.displayIcon)
                                .tag(remote as CloudRemote?)
                        }
                    }
                    .onChange(of: destRemote) { _, newValue in
                        // Auto-enable encryption if configured
                        if let remote = newValue {
                            encryptDestination = EncryptionManager.shared.isEncryptionEnabled(for: remote.rcloneName)
                        }
                    }
                    
                    TextField("Path", text: $destPath)
                    
                    // Encryption toggle for destination
                    if destRemote != nil {
                        HStack {
                            Toggle(isOn: $encryptDestination) {
                                HStack(spacing: 6) {
                                    Image(systemName: encryptDestination ? "lock.fill" : "lock.open")
                                        .foregroundColor(encryptDestination ? .green : .secondary)
                                    Text("Encrypt Destination")
                                }
                            }
                            .disabled(!destHasEncryption)
                            
                            if !destHasEncryption {
                                Button("Setup") {
                                    showDestEncryptionSetup = true
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                            }
                        }
                    }
                }
                
                // Encryption info banner
                if encryptSource || encryptDestination {
                    Section {
                        HStack(spacing: 8) {
                            Image(systemName: "lock.shield.fill")
                                .foregroundColor(.green)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("End-to-End Encryption Enabled")
                                    .fontWeight(.medium)
                                Text(encryptionDescription)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Section("Schedule") {
                    Toggle("Enable Schedule", isOn: $isScheduled)
                    
                    if isScheduled {
                        Picker("Interval", selection: $scheduleInterval) {
                            Text("Every 15 minutes").tag(900.0)
                            Text("Every hour").tag(3600.0)
                            Text("Every 6 hours").tag(21600.0)
                            Text("Daily").tag(86400.0)
                        }
                    }
                }
            }
            .formStyle(.grouped)
            
            Divider()
            
            HStack {
                Spacer()
                
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.escape)
                
                Button("Create Task") {
                    createTask()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isValid)
            }
            .padding()
        }
        .frame(width: 500, height: 620)
        .sheet(isPresented: $showSourceEncryptionSetup) {
            if let remote = sourceRemote {
                EncryptionSetupSheet(remote: remote) {
                    encryptSource = true
                }
            }
        }
        .sheet(isPresented: $showDestEncryptionSetup) {
            if let remote = destRemote {
                EncryptionSetupSheet(remote: remote) {
                    encryptDestination = true
                }
            }
        }
    }
    
    private var encryptionDescription: String {
        if encryptSource && encryptDestination {
            return "Files will be decrypted from source and encrypted to destination"
        } else if encryptSource {
            return "Files will be decrypted from encrypted source"
        } else {
            return "Files will be encrypted before uploading to destination"
        }
    }
    
    private var isValid: Bool {
        !taskName.isEmpty && sourceRemote != nil && destRemote != nil
    }
    
    private func createTask() {
        guard let source = sourceRemote, let dest = destRemote else { return }
        
        var task = tasksVM.createTask(
            name: taskName,
            type: taskType,
            sourceRemote: source.name,
            sourcePath: sourcePath.isEmpty ? "/" : sourcePath,
            destinationRemote: dest.name,
            destinationPath: destPath.isEmpty ? "/" : destPath
        )
        
        // Set encryption flags
        task.encryptSource = encryptSource
        task.encryptDestination = encryptDestination
        
        if isScheduled {
            task.isScheduled = true
            task.scheduleInterval = scheduleInterval
        }
        
        tasksVM.updateTask(task)
        dismiss()
    }
}

// MARK: - Encryption Setup Sheet (for Tasks)

struct EncryptionSetupSheet: View {
    let remote: CloudRemote
    let onComplete: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: remote.displayIcon)
                    .foregroundColor(remote.displayColor)
                Text("Setup Encryption for \(remote.name)")
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
            
            EncryptionModal { config in
                Task {
                    await setupEncryption(config: config)
                }
            }
        }
    }
    
    private func setupEncryption(config: EncryptionConfig) async {
        do {
            let remoteName = remote.rcloneName
            let salt = EncryptionManager.shared.generateSecureSalt()
            
            let remoteConfig = RemoteEncryptionConfig(
                password: config.password,
                salt: salt,
                encryptFilenames: config.encryptFilenames,
                encryptFolders: config.encryptFolders
            )
            
            try await RcloneManager.shared.setupCryptRemote(
                for: remoteName,
                config: remoteConfig
            )
            
            EncryptionManager.shared.setEncryptionEnabled(true, for: remoteName)
            
            await MainActor.run {
                onComplete()
                dismiss()
            }
        } catch {
            print("[EncryptionSetupSheet] Setup failed: \(error)")
        }
    }
}

// MARK: - Task Detail Sheet

struct TaskDetailSheet: View {
    let task: SyncTask
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var tasksVM: TasksViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: task.type.icon)
                    .font(.title2)
                
                VStack(alignment: .leading) {
                    HStack(spacing: 6) {
                        Text(task.name)
                            .font(.headline)
                        
                        if task.hasEncryption {
                            HStack(spacing: 2) {
                                Image(systemName: "lock.fill")
                                    .font(.caption2)
                                Text("E2E Encrypted")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.green)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.15))
                            .cornerRadius(4)
                        }
                    }
                    Text(task.type.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                StatusBadge(state: task.state)
                
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Route
                    GroupBox("Route") {
                        HStack {
                            VStack(alignment: .leading) {
                                HStack(spacing: 4) {
                                    Text("Source")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    if task.encryptSource {
                                        Image(systemName: "lock.fill")
                                            .font(.caption2)
                                            .foregroundColor(.green)
                                    }
                                }
                                Text(task.sourceRemote)
                                    .fontWeight(.medium)
                                Text(task.sourcePath)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.right")
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                HStack(spacing: 4) {
                                    if task.encryptDestination {
                                        Image(systemName: "lock.fill")
                                            .font(.caption2)
                                            .foregroundColor(.green)
                                    }
                                    Text("Destination")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Text(task.destinationRemote)
                                    .fontWeight(.medium)
                                Text(task.destinationPath)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(8)
                    }
                    
                    // Encryption info
                    if task.hasEncryption {
                        GroupBox("Encryption") {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 8) {
                                    Image(systemName: "lock.shield.fill")
                                        .foregroundColor(.green)
                                    Text("End-to-End Encryption Active")
                                        .fontWeight(.medium)
                                }
                                
                                if task.encryptSource {
                                    Label("Source is encrypted (decrypting on read)", systemImage: "arrow.down.circle")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                if task.encryptDestination {
                                    Label("Destination is encrypted (encrypting on write)", systemImage: "arrow.up.circle")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(8)
                        }
                    }
                    
                    // Progress
                    if task.state == .running || task.state == .completed {
                        GroupBox("Progress") {
                            VStack(spacing: 12) {
                                ProgressView(value: task.progress)
                                    .progressViewStyle(.linear)
                                
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 16) {
                                    StatItem(label: "Files", value: task.formattedFilesTransferred)
                                    StatItem(label: "Transferred", value: task.formattedBytesTransferred)
                                    StatItem(label: "Duration", value: task.formattedDuration)
                                }
                                
                                // Show average speed for completed tasks
                                if task.state == .completed && task.bytesTransferred > 0 {
                                    Divider()
                                    HStack {
                                        Image(systemName: "speedometer")
                                            .foregroundColor(.secondary)
                                        Text("Average Speed:")
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text(task.averageSpeed)
                                            .fontWeight(.medium)
                                    }
                                    .font(.caption)
                                }
                            }
                            .padding(8)
                        }
                    }
                    
                    // Logs
                    GroupBox("Logs") {
                        let logs = tasksVM.logsForTask(task.id)
                        if logs.isEmpty {
                            Text("No logs yet")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            ScrollView {
                                LazyVStack(alignment: .leading, spacing: 4) {
                                    ForEach(logs) { log in
                                        LogRow(log: log)
                                    }
                                }
                            }
                            .frame(maxHeight: 200)
                            .padding(8)
                        }
                    }
                }
                .padding()
            }
        }
        .frame(width: 500, height: 500)
    }
}

struct StatItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct LogRow: View {
    let log: TaskLog
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(log.timestamp, style: .time)
                .font(.caption2)
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .leading)
            
            Text(log.level.rawValue)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(levelColor)
                .frame(width: 50)
            
            Text(log.message)
                .font(.caption)
        }
    }
    
    private var levelColor: Color {
        switch log.level {
        case .info: return .blue
        case .warning: return .orange
        case .error: return .red
        case .debug: return .gray
        }
    }
}

#Preview {
    TasksView()
        .environmentObject(TasksViewModel.shared)
        .environmentObject(RemotesViewModel.shared)
        .frame(width: 800, height: 600)
}
