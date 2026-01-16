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

                    if state.sourceRemote != nil {
                        HStack {
                            Text("Path:")
                                .foregroundColor(.secondary)
                            TextField("/ (root)", text: $state.sourcePath)
                                .textFieldStyle(.roundedBorder)
                        }
                        .padding(.horizontal)

                        // Encryption toggle for non-local remotes
                        if let remote = state.sourceRemote, remote.type != .local {
                            Toggle(isOn: $state.encryptSource) {
                                HStack(spacing: AppTheme.spacingXS) {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(state.encryptSource ? .green : .secondary)
                                    Text("Enable encryption for source")
                                }
                            }
                            .padding(.horizontal)
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

                    if state.destinationRemote != nil {
                        HStack {
                            Text("Path:")
                                .foregroundColor(.secondary)
                            TextField("/ (root)", text: $state.destinationPath)
                                .textFieldStyle(.roundedBorder)
                        }
                        .padding(.horizontal)

                        // Encryption toggle for non-local remotes
                        if let remote = state.destinationRemote, remote.type != .local {
                            Toggle(isOn: $state.encryptDestination) {
                                HStack(spacing: AppTheme.spacingXS) {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(state.encryptDestination ? .green : .secondary)
                                    Text("Enable encryption for destination")
                                }
                            }
                            .padding(.horizontal)
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
