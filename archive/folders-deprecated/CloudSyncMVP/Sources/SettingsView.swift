import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var syncManager: SyncManager
    @AppStorage("protonDriveEmail") private var protonEmail = ""
    @AppStorage("localSyncPath") private var localSyncPath = ""
    @AppStorage("syncInterval") private var syncInterval = 300
    @AppStorage("enableConflictResolution") private var enableConflictResolution = true
    
    @State private var protonPassword = ""
    @State private var showingFolderPicker = false
    @State private var isAuthenticating = false
    @State private var authError: String?
    
    var body: some View {
        TabView {
            // General Settings
            Form {
                Section("Local Sync Folder") {
                    HStack {
                        Text(localSyncPath.isEmpty ? "No folder selected" : localSyncPath)
                            .foregroundColor(localSyncPath.isEmpty ? .secondary : .primary)
                            .lineLimit(1)
                        Spacer()
                        Button("Choose...") {
                            showingFolderPicker = true
                        }
                    }
                }
                
                Section("Sync Settings") {
                    Picker("Sync Interval", selection: $syncInterval) {
