//
//  TransferDestinationStep.swift
//  CloudSyncApp
//
//  Step 2: Select destination remote for the transfer
//

import SwiftUI

struct TransferDestinationStep: View {
    @ObservedObject var state: TransferWizardState
    @EnvironmentObject var remotesVM: RemotesViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacingXL) {
                // Header
                VStack(spacing: AppTheme.spacingS) {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.15))
                            .frame(width: 60, height: 60)

                        Image(systemName: "externaldrive.fill")
                            .font(.title)
                            .foregroundColor(.green)
                    }

                    Text("Select Destination Location")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Choose where you want to transfer files to")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)

                // Show source summary
                if let source = state.sourceRemote {
                    HStack(spacing: AppTheme.spacingM) {
                        Image(systemName: source.displayIcon)
                            .foregroundColor(source.displayColor)
                            .frame(width: 24)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("From: \(source.name)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(state.sourcePath.isEmpty ? "/" : "/" + state.sourcePath)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Image(systemName: "arrow.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(AppTheme.cornerRadius)
                }

                // Remote Selection
                VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                    Label("Destination Remote", systemImage: "externaldrive.badge.plus")
                        .font(.headline)

                    RemotePickerGrid(
                        selectedRemote: $state.destinationRemote,
                        remotes: remotesVM.configuredRemotes,
                        excludeRemote: state.sourceRemote
                    )

                    if state.destinationRemote?.id == state.sourceRemote?.id {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("Source and destination cannot be the same")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(AppTheme.cornerRadius)

                // Path Input (shown when remote is selected)
                if state.destinationRemote != nil {
                    VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                        Label("Destination Path", systemImage: "folder.badge.plus")
                            .font(.headline)

                        HStack {
                            Text("/")
                                .foregroundColor(.secondary)
                                .font(.system(.body, design: .monospaced))
                            TextField("path/to/destination (optional)", text: $state.destinationPath)
                                .textFieldStyle(.roundedBorder)
                                .font(.system(.body, design: .monospaced))
                        }

                        Text("Leave empty to transfer to root, or specify a destination folder")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        // Encryption toggle for non-local remotes
                        if let remote = state.destinationRemote, remote.type != .local {
                            Divider()

                            Toggle(isOn: $state.encryptDestination) {
                                HStack(spacing: AppTheme.spacingXS) {
                                    Image(systemName: state.encryptDestination ? "lock.fill" : "lock.open")
                                        .foregroundColor(state.encryptDestination ? .green : .secondary)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Enable Encryption")
                                        Text("Files will be encrypted at destination")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .accessibilityLabel("Enable encryption for destination")
                            .accessibilityHint(state.encryptDestination ? "Encryption is enabled" : "Encryption is disabled")
                        }
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(AppTheme.cornerRadius)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding()
            .animation(.default, value: state.destinationRemote)
        }
    }
}

#Preview {
    let state = TransferWizardState()
    state.sourceRemote = CloudRemote(name: "Local", type: .local, isConfigured: true, path: "/Users/test")

    return TransferDestinationStep(state: state)
        .environmentObject(RemotesViewModel.shared)
        .frame(width: 700, height: 500)
}
