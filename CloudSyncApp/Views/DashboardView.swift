//
//  DashboardView.swift
//  CloudSyncApp
//
//  Main dashboard with overview cards and quick actions
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var syncManager: SyncManager
    @EnvironmentObject var remotesVM: RemotesViewModel
    @EnvironmentObject var tasksVM: TasksViewModel
    
    @State private var showAddRemote = false
    @State private var remoteToConnect: CloudRemote?
    @State private var selectedRemoteToOpen: CloudRemote?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection
                
                // Quick Stats
                statsSection
                
                // Connected Services
                connectedServicesSection
                
                // Recent Activity
                recentActivitySection
                
                // Quick Actions
                quickActionsSection
            }
            .padding(24)
        }
        .background(Color(NSColor.windowBackgroundColor))
        .navigationTitle("Dashboard")
        .sheet(isPresented: $showAddRemote) {
            AddRemoteSheet(onRemoteAdded: { remote in
                remoteToConnect = remote
            })
        }
        .sheet(item: $remoteToConnect) { remote in
            ConnectRemoteSheet(remote: remote)
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome to CloudSync Ultra")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Manage your cloud storage and sync files seamlessly")
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Sync Status Indicator
            SyncStatusBadge(status: syncManager.syncStatus)
        }
    }
    
    // MARK: - Stats
    
    private var statsSection: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Connected",
                value: "\(remotesVM.cloudRemotes.count)",
                subtitle: "cloud services",
                icon: "cloud.fill",
                color: Color(red: 0.7, green: 0.9, blue: 1.0),  // Very bright sky blue
                action: nil  // No action for connected count
            )
            
            StatCard(
                title: "Active",
                value: "\(tasksVM.runningTasksCount)",
                subtitle: "sync tasks",
                icon: "arrow.triangle.2.circlepath",
                color: .green,
                action: {
                    NotificationCenter.default.post(name: .navigateToTasks, object: nil)
                }
            )
            
            StatCard(
                title: "Pending",
                value: "\(tasksVM.pendingTasksCount)",
                subtitle: "in queue",
                icon: "clock.fill",
                color: .orange,
                action: {
                    NotificationCenter.default.post(name: .navigateToTasks, object: nil)
                }
            )
            
            StatCard(
                title: "Completed",
                value: "\(tasksVM.taskHistory.count)",
                subtitle: "transfers",
                icon: "checkmark.circle.fill",
                color: .purple,
                action: {
                    NotificationCenter.default.post(name: .navigateToHistory, object: nil)
                }
            )
        }
    }
    
    // MARK: - Connected Services
    
    private var connectedServicesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Connected Services")
                    .font(.headline)
                
                Spacer()
                
                Button {
                    showAddRemote = true
                } label: {
                    Label("Add New", systemImage: "plus")
                }
                .buttonStyle(.bordered)
            }
            
            let cloudServices = remotesVM.remotes.filter { $0.type != .local }
            if cloudServices.isEmpty {
                emptyServicesCard
            } else {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 200, maximum: 280), spacing: 16)
                ], spacing: 16) {
                    ForEach(cloudServices) { remote in
                        ConnectedServiceCard(
                            remote: remote,
                            onTap: {
                                if remote.isConfigured {
                                    // Navigate to the remote - post notification
                                    NotificationCenter.default.post(
                                        name: .navigateToRemote,
                                        object: remote
                                    )
                                } else {
                                    remoteToConnect = remote
                                }
                            },
                            onConnect: {
                                remoteToConnect = remote
                            }
                        )
                    }
                }
            }
        }
        .cardStyle()
    }
    
    private var emptyServicesCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "cloud.fill")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("No cloud services connected")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Connect your cloud storage to start syncing files")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                showAddRemote = true
            } label: {
                Label("Add Cloud Storage", systemImage: "plus")
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .frame(maxWidth: .infinity)
        .padding(32)
    }
    
    // MARK: - Recent Activity
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Activity")
                    .font(.headline)
                
                Spacer()
                
                Button("View All") {
                    NotificationCenter.default.post(name: .navigateToHistory, object: nil)
                }
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)
            }
            
            if tasksVM.taskHistory.isEmpty {
                Text("No recent activity")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                VStack(spacing: 8) {
                    ForEach(tasksVM.taskHistory.prefix(5)) { task in
                        ActivityRow(task: task)
                    }
                }
            }
        }
        .cardStyle()
    }
    
    // MARK: - Quick Actions
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
            
            HStack(spacing: 16) {
                QuickActionButton(
                    icon: "arrow.left.arrow.right",
                    title: "Transfer Files",
                    subtitle: "Move files between clouds",
                    color: .blue
                ) {
                    NotificationCenter.default.post(name: .navigateToTransfer, object: nil)
                }
                
                QuickActionButton(
                    icon: "list.bullet.clipboard",
                    title: "View Tasks",
                    subtitle: "Manage sync tasks",
                    color: .green
                ) {
                    NotificationCenter.default.post(name: .navigateToTasks, object: nil)
                }
                
                QuickActionButton(
                    icon: "clock.arrow.circlepath",
                    title: "History",
                    subtitle: "View past transfers",
                    color: .purple
                ) {
                    NotificationCenter.default.post(name: .navigateToHistory, object: nil)
                }
                
                QuickActionButton(
                    icon: "gearshape.fill",
                    title: "Settings",
                    subtitle: "Configure app",
                    color: .gray
                ) {
                    NotificationCenter.default.post(name: .navigateToSettings, object: nil)
                }
            }
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let navigateToRemote = Notification.Name("navigateToRemote")
    static let navigateToTransfer = Notification.Name("navigateToTransfer")
    static let navigateToTasks = Notification.Name("navigateToTasks")
    static let navigateToHistory = Notification.Name("navigateToHistory")
    static let navigateToSettings = Notification.Name("navigateToSettings")
}

// MARK: - Supporting Views

struct SyncStatusBadge: View {
    let status: SyncStatus
    
    var body: some View {
        HStack(spacing: 8) {
            statusIcon
            
            VStack(alignment: .leading, spacing: 2) {
                Text(statusText)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let subtitle = statusSubtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(statusColor.opacity(0.1))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private var statusIcon: some View {
        switch status {
        case .idle:
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        case .checking, .syncing:
            ProgressView()
                .scaleEffect(0.8)
        case .completed:
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        case .error:
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
        }
    }
    
    private var statusText: String {
        switch status {
        case .idle: return "All synced"
        case .checking: return "Checking..."
        case .syncing: return "Syncing..."
        case .completed: return "Completed"
        case .error: return "Error"
        }
    }
    
    private var statusSubtitle: String? {
        switch status {
        case .error(let msg): return msg
        default: return nil
        }
    }
    
    private var statusColor: Color {
        switch status {
        case .idle, .completed: return .green
        case .checking, .syncing: return .blue
        case .error: return .red
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    var action: (() -> Void)?
    
    @State private var isHovered = false
    
    var body: some View {
        Button {
            action?()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                    
                    Spacer()
                    
                    if action != nil {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .opacity(isHovered ? 1 : 0.5)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(value)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(color)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: AppDimensions.cornerRadius)
                    .fill(isHovered && action != nil ? color.opacity(0.15) : color.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppDimensions.cornerRadius)
                    .stroke(isHovered && action != nil ? color.opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

struct ConnectedServiceCard: View {
    let remote: CloudRemote
    let onTap: () -> Void
    let onConnect: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(remote.displayColor.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: remote.displayIcon)
                        .font(.title3)
                        .foregroundColor(remote.displayColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(remote.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(remote.isConfigured ? Color.green : Color.orange)
                            .frame(width: 6, height: 6)
                        
                        Text(remote.isConfigured ? "Connected" : "Setup required")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if remote.isEncrypted {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if remote.isConfigured {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Button {
                        onConnect()
                    } label: {
                        Text("Connect")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isHovered ? Color(NSColor.selectedControlColor).opacity(0.3) : Color(NSColor.controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isHovered ? Color.accentColor.opacity(0.5) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

struct ActivityRow: View {
    let task: SyncTask
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: task.type.icon)
                .foregroundColor(stateColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(task.name)
                    .font(.subheadline)
                
                Text("\(task.sourceRemote) → \(task.destinationRemote)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(task.state.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(stateColor)
                
                if let date = task.completedAt {
                    Text(date, style: .relative)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private var stateColor: Color {
        switch task.state {
        case .completed: return .green
        case .failed: return .red
        case .running: return .blue
        case .paused: return .orange
        default: return .secondary
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                }
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: AppDimensions.cornerRadius)
                    .fill(isHovered ? Color(NSColor.selectedControlColor).opacity(0.3) : Color(NSColor.controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppDimensions.cornerRadius)
                    .stroke(isHovered ? color.opacity(0.5) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(SyncManager.shared)
        .environmentObject(RemotesViewModel.shared)
        .environmentObject(TasksViewModel.shared)
        .frame(width: 900, height: 700)
}
