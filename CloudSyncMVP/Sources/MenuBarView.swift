import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var syncManager: SyncManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "cloud.fill")
                    .font(.title2)
                Text("CloudSync")
                    .font(.headline)
                Spacer()
                syncStatusIcon
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            
            Divider()
            
            // Sync Status
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Status:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(syncManager.syncStatus.displayName)
                        .foregroundColor(syncManager.syncStatus.color)
                }
                
                if syncManager.isSyncing {
                    ProgressView(value: syncManager.syncProgress, total: 1.0)
                    
                    Text("\(Int(syncManager.syncProgress * 100))% - \(syncManager.currentFile)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                HStack {
                    Text("Last Sync:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(syncManager.lastSyncTime)
                        .font(.caption)
                }
            }
            .padding()
            
            Divider()
            
            // Recent Activity
            VStack(alignment: .leading, spacing: 8) {
                Text("Recent Activity")
                    .font(.headline)
                    .padding(.bottom, 4)
                
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(syncManager.recentActivities) { activity in
                            ActivityRow(activity: activity)
                        }
                    }
                }
                .frame(height: 200)
            }
            .padding()
            
            Divider()
            
            // Actions
            VStack(spacing: 8) {
                Button(action: { syncManager.forceSyncNow() }) {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Sync Now")
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                
                Button(action: { NSApp.sendAction(#selector(NSApplication.showPreferences(_:)), to: nil, from: nil) }) {
                    HStack {
                        Image(systemName: "gearshape")
                        Text("Settings")
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                
                Divider()
                
                Button(action: { NSApp.terminate(nil) }) {
                    HStack {
                        Image(systemName: "power")
                        Text("Quit CloudSync")
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
        }
        .frame(width: 350, height: 500)
    }
    
    var syncStatusIcon: some View {
        Group {
            switch syncManager.syncStatus {
            case .idle:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            case .syncing:
                ProgressView()
                    .scaleEffect(0.7)
            case .error:
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
            case .paused:
                Image(systemName: "pause.circle.fill")
                    .foregroundColor(.orange)
            }
        }
    }
}

struct ActivityRow: View {
    let activity: SyncActivity
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: activity.icon)
                .foregroundColor(activity.color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.fileName)
                    .font(.caption)
                    .lineLimit(1)
                Text(activity.action)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(activity.timeAgo)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}
