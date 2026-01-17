//
//  SelectRemotesStep.swift
//  CloudSyncApp
//
//  Step 1: Select source and destination remotes for the schedule
//

import SwiftUI

struct SelectRemotesStep: View {
    @ObservedObject var state: ScheduleWizardState
    @EnvironmentObject var remotesVM: RemotesViewModel
    @State private var showSourceFolderBrowser = false
    @State private var showDestinationFolderBrowser = false
    @State private var showSourceEncryptionSetup = false
    @State private var showDestinationEncryptionSetup = false

    private func selectLocalFolder(for binding: Binding<String>) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = "Select a folder"
        panel.prompt = "Select"

        if panel.runModal() == .OK, let url = panel.url {
            binding.wrappedValue = url.path
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacingXL) {
                // Header
                VStack(spacing: AppTheme.spacingS) {
                    Text("Select Source and Destination")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Choose which locations to sync between")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)

                // Source Selection
                VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                    Label("Source", systemImage: "folder")
                        .font(.headline)

                    RemotePickerGrid(
                        selectedRemote: $state.sourceRemote,
                        remotes: remotesVM.configuredRemotes,
                        excludeRemote: state.destinationRemote
                    )

                    if let sourceRemote = state.sourceRemote {
                        HStack {
                            Text("Path:")
                                .foregroundColor(.secondary)
                            TextField("/ (root)", text: $state.sourcePath)
                                .textFieldStyle(.roundedBorder)
                            Button(action: {
                                if sourceRemote.type == .local {
                                    selectLocalFolder(for: $state.sourcePath)
                                } else {
                                    showSourceFolderBrowser = true
                                }
                            }) {
                                Image(systemName: "folder")
                            }
                            .buttonStyle(.bordered)
                            .help("Browse folders")
                        }
                        .padding(.horizontal)
                        .sheet(isPresented: $showSourceFolderBrowser) {
                            RemoteFolderBrowser(
                                remoteName: sourceRemote.rcloneName,
                                isLocal: false,
                                selectedPath: $state.sourcePath,
                                onDismiss: { showSourceFolderBrowser = false }
                            )
                        }

                        // Encryption toggle for non-local remotes
                        if sourceRemote.type != .local {
                            Toggle(isOn: Binding(
                                get: { state.encryptSource },
                                set: { newValue in
                                    if newValue && !EncryptionManager.shared.isEncryptionConfigured(for: sourceRemote.rcloneName) {
                                        showSourceEncryptionSetup = true
                                    } else {
                                        state.encryptSource = newValue
                                    }
                                }
                            )) {
                                HStack(spacing: AppTheme.spacingXS) {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(state.encryptSource ? .green : .secondary)
                                    Text("Enable encryption for source")
                                }
                            }
                            .padding(.horizontal)
                            .sheet(isPresented: $showSourceEncryptionSetup) {
                                EncryptionSetupSheet(remote: sourceRemote) {
                                    state.encryptSource = true
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(AppTheme.cornerRadius)

                // Arrow indicator
                Image(systemName: "arrow.down.circle.fill")
                    .font(.title)
                    .foregroundColor(.accentColor)

                // Destination Selection
                VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                    Label("Destination", systemImage: "externaldrive")
                        .font(.headline)

                    RemotePickerGrid(
                        selectedRemote: $state.destinationRemote,
                        remotes: remotesVM.configuredRemotes,
                        excludeRemote: state.sourceRemote
                    )

                    if let destRemote = state.destinationRemote {
                        HStack {
                            Text("Path:")
                                .foregroundColor(.secondary)
                            TextField("/ (root)", text: $state.destinationPath)
                                .textFieldStyle(.roundedBorder)
                            Button(action: {
                                if destRemote.type == .local {
                                    selectLocalFolder(for: $state.destinationPath)
                                } else {
                                    showDestinationFolderBrowser = true
                                }
                            }) {
                                Image(systemName: "folder")
                            }
                            .buttonStyle(.bordered)
                            .help("Browse folders")
                        }
                        .padding(.horizontal)
                        .sheet(isPresented: $showDestinationFolderBrowser) {
                            RemoteFolderBrowser(
                                remoteName: destRemote.rcloneName,
                                isLocal: false,
                                selectedPath: $state.destinationPath,
                                onDismiss: { showDestinationFolderBrowser = false }
                            )
                        }

                        // Encryption toggle for non-local remotes
                        if destRemote.type != .local {
                            Toggle(isOn: Binding(
                                get: { state.encryptDestination },
                                set: { newValue in
                                    if newValue && !EncryptionManager.shared.isEncryptionConfigured(for: destRemote.rcloneName) {
                                        showDestinationEncryptionSetup = true
                                    } else {
                                        state.encryptDestination = newValue
                                    }
                                }
                            )) {
                                HStack(spacing: AppTheme.spacingXS) {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(state.encryptDestination ? .green : .secondary)
                                    Text("Enable encryption for destination")
                                }
                            }
                            .padding(.horizontal)
                            .sheet(isPresented: $showDestinationEncryptionSetup) {
                                EncryptionSetupSheet(remote: destRemote) {
                                    state.encryptDestination = true
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(AppTheme.cornerRadius)

                // Sync Type Selection
                VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                    Label("Sync Type", systemImage: "arrow.triangle.2.circlepath")
                        .font(.headline)

                    Picker("Type", selection: $state.syncType) {
                        ForEach(TaskType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)

                    Text(syncTypeDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(AppTheme.cornerRadius)
            }
            .padding()
        }
    }

    private var syncTypeDescription: String {
        switch state.syncType {
        case .sync:
            return "Two-way sync: keeps both locations identical"
        case .transfer:
            return "Transfer: one-way copy of new/changed files"
        case .backup:
            return "Backup: creates a backup copy with versioning"
        }
    }
}

/// Grid of remote options for selection
struct RemotePickerGrid: View {
    @Binding var selectedRemote: CloudRemote?
    let remotes: [CloudRemote]
    var excludeRemote: CloudRemote?

    private var availableRemotes: [CloudRemote] {
        remotes.filter { $0.id != excludeRemote?.id }
    }

    var body: some View {
        if availableRemotes.isEmpty {
            VStack(spacing: AppTheme.spacingM) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                    .foregroundColor(.orange)
                Text("No configured remotes available")
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
        } else {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 120, maximum: 150), spacing: AppTheme.spacingM)
            ], spacing: AppTheme.spacingM) {
                ForEach(availableRemotes) { remote in
                    RemoteSelectionCard(
                        remote: remote,
                        isSelected: selectedRemote?.id == remote.id
                    ) {
                        selectedRemote = remote
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

/// Card for selecting a remote
struct RemoteSelectionCard: View {
    let remote: CloudRemote
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.spacingS) {
                ZStack {
                    Circle()
                        .fill(remote.displayColor.opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: remote.displayIcon)
                        .font(.title2)
                        .foregroundColor(remote.displayColor)
                }

                Text(remote.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text(remote.type.displayName)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.spacingM)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .fill(isSelected ? remote.displayColor.opacity(0.1) : Color(NSColor.controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(isSelected ? remote.displayColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(remote.name)
        .accessibilityHint(isSelected ? "Selected" : "Tap to select")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    SelectRemotesStep(state: ScheduleWizardState())
        .environmentObject(RemotesViewModel.shared)
        .frame(width: 700, height: 600)
}
