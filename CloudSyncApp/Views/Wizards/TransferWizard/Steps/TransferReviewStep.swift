//
//  TransferReviewStep.swift
//  CloudSyncApp
//
//  Step 4: Review and confirm the transfer setup
//

import SwiftUI

struct TransferReviewStep: View {
    @ObservedObject var state: TransferWizardState

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacingXL) {
                // Header
                VStack(spacing: AppTheme.spacingS) {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.15))
                            .frame(width: 80, height: 80)

                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.green)
                    }

                    Text("Review Your Transfer")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Confirm the details below and click Complete to start")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)

                // Transfer Summary Card
                VStack(alignment: .leading, spacing: AppTheme.spacingL) {
                    // Name
                    HStack {
                        Label("Name", systemImage: "tag")
                            .font(.headline)
                        Spacer()
                        Text(state.transferName.isEmpty ? "Unnamed Transfer" : state.transferName)
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    // Source
                    VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                        Label("Source", systemImage: "folder")
                            .font(.headline)

                        if let remote = state.sourceRemote {
                            HStack(spacing: AppTheme.spacingM) {
                                Image(systemName: remote.displayIcon)
                                    .foregroundColor(remote.displayColor)
                                    .frame(width: 24)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(remote.name)
                                        .fontWeight(.medium)
                                    Text(state.sourcePath.isEmpty ? "/" : "/" + state.sourcePath)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                if state.encryptSource {
                                    Spacer()
                                    HStack(spacing: 4) {
                                        Image(systemName: "lock.fill")
                                        Text("Encrypted")
                                    }
                                    .font(.caption)
                                    .foregroundColor(.green)
                                }
                            }
                            .padding()
                            .background(Color(NSColor.windowBackgroundColor))
                            .cornerRadius(AppTheme.cornerRadiusSmall)
                        }
                    }

                    // Arrow
                    HStack {
                        Spacer()
                        VStack(spacing: 4) {
                            Image(systemName: "arrow.down")
                                .font(.title2)
                            Text(state.transferMode.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.accentColor)
                        Spacer()
                    }

                    // Destination
                    VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                        Label("Destination", systemImage: "externaldrive")
                            .font(.headline)

                        if let remote = state.destinationRemote {
                            HStack(spacing: AppTheme.spacingM) {
                                Image(systemName: remote.displayIcon)
                                    .foregroundColor(remote.displayColor)
                                    .frame(width: 24)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(remote.name)
                                        .fontWeight(.medium)
                                    Text(state.destinationPath.isEmpty ? "/" : "/" + state.destinationPath)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                if state.encryptDestination {
                                    Spacer()
                                    HStack(spacing: 4) {
                                        Image(systemName: "lock.fill")
                                        Text("Encrypted")
                                    }
                                    .font(.caption)
                                    .foregroundColor(.green)
                                }
                            }
                            .padding()
                            .background(Color(NSColor.windowBackgroundColor))
                            .cornerRadius(AppTheme.cornerRadiusSmall)
                        }
                    }

                    Divider()

                    // Options Summary
                    HStack {
                        Label("Start", systemImage: state.startImmediately ? "play.circle.fill" : "clock")
                            .font(.headline)
                        Spacer()
                        Text(state.startImmediately ? "Immediately" : "Queued for later")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(AppTheme.cornerRadius)

                // Info Note
                HStack(spacing: AppTheme.spacingS) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)

                    Text(state.startImmediately
                        ? "Your transfer will begin as soon as you click Complete. You can monitor progress in the Tasks view."
                        : "Your transfer will be added to the queue. Start it anytime from the Tasks view.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(AppTheme.cornerRadius)
            }
            .padding()
        }
    }
}

#Preview {
    let state = TransferWizardState()
    state.transferName = "Documents Backup"
    state.sourceRemote = CloudRemote(name: "Local", type: .local, isConfigured: true, path: "/Users/test/Documents")
    state.sourcePath = "Documents"
    state.destinationRemote = CloudRemote(name: "Google Drive", type: .googleDrive, isConfigured: true, path: "")
    state.destinationPath = "Backups/Documents"
    state.encryptDestination = true
    state.transferMode = .backup
    state.startImmediately = true

    return TransferReviewStep(state: state)
        .frame(width: 700, height: 600)
}
