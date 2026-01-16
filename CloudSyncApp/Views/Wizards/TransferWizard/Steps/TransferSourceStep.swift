//
//  TransferSourceStep.swift
//  CloudSyncApp
//
//  Step 1: Select source remote for the transfer
//

import SwiftUI

struct TransferSourceStep: View {
    @ObservedObject var state: TransferWizardState
    @EnvironmentObject var remotesVM: RemotesViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacingXL) {
                // Header
                VStack(spacing: AppTheme.spacingS) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.15))
                            .frame(width: 60, height: 60)

                        Image(systemName: "folder.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                    }

                    Text("Select Source Location")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Choose where you want to transfer files from")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)

                // Remote Selection
                VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                    Label("Source Remote", systemImage: "externaldrive")
                        .font(.headline)

                    if remotesVM.configuredRemotes.isEmpty {
                        emptyRemotesState
                    } else {
                        RemotePickerGrid(
                            selectedRemote: $state.sourceRemote,
                            remotes: remotesVM.configuredRemotes,
                            excludeRemote: nil
                        )
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(AppTheme.cornerRadius)

                // Path Input (shown when remote is selected)
                if state.sourceRemote != nil {
                    VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                        Label("Source Path", systemImage: "folder.badge.gearshape")
                            .font(.headline)

                        HStack {
                            Text("/")
                                .foregroundColor(.secondary)
                                .font(.system(.body, design: .monospaced))
                            TextField("path/to/files (optional)", text: $state.sourcePath)
                                .textFieldStyle(.roundedBorder)
                                .font(.system(.body, design: .monospaced))
                        }

                        Text("Leave empty to transfer from root, or specify a subfolder path")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        // Encryption toggle for non-local remotes
                        if let remote = state.sourceRemote, remote.type != .local {
                            Divider()

                            Toggle(isOn: $state.encryptSource) {
                                HStack(spacing: AppTheme.spacingXS) {
                                    Image(systemName: state.encryptSource ? "lock.fill" : "lock.open")
                                        .foregroundColor(state.encryptSource ? .green : .secondary)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Enable Encryption")
                                        Text("Files will be encrypted before transfer")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .accessibilityLabel("Enable encryption for source")
                            .accessibilityHint(state.encryptSource ? "Encryption is enabled" : "Encryption is disabled")
                        }
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(AppTheme.cornerRadius)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding()
            .animation(.default, value: state.sourceRemote)
        }
    }

    private var emptyRemotesState: some View {
        VStack(spacing: AppTheme.spacingM) {
            Image(systemName: "externaldrive.badge.exclamationmark")
                .font(.system(size: 40))
                .foregroundColor(.orange)

            Text("No Remotes Configured")
                .font(.headline)

            Text("You need to add a cloud storage provider before you can transfer files.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.spacingXL)
    }
}

#Preview {
    TransferSourceStep(state: TransferWizardState())
        .environmentObject(RemotesViewModel.shared)
        .frame(width: 700, height: 500)
}
