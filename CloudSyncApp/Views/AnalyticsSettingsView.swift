//
//  AnalyticsSettingsView.swift
//  CloudSyncApp
//
//  Settings UI for analytics preferences with user transparency
//

import SwiftUI

struct AnalyticsSettingsView: View {
    @StateObject private var analyticsManager = AnalyticsManager.shared

    @State private var showingStats = false
    @State private var showingExportSuccess = false
    @State private var showingClearConfirmation = false
    @State private var exportURL: URL?
    @State private var isExporting = false

    var body: some View {
        Form {
            // Privacy Settings
            Section {
                Toggle("Track local usage statistics", isOn: $analyticsManager.localTrackingEnabled)

                Toggle("Help improve CloudSync Ultra", isOn: $analyticsManager.telemetryEnabled)

                Text("When enabled, anonymized usage data helps us improve the app. No personal information is ever collected.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } header: {
                Label("Privacy Settings", systemImage: "hand.raised")
            }

            // Your Data
            Section {
                Button {
                    showingStats = true
                } label: {
                    Label("View My Statistics", systemImage: "chart.bar")
                }

                Button {
                    exportData()
                } label: {
                    HStack {
                        Label("Export My Data", systemImage: "square.and.arrow.up")
                        if isExporting {
                            Spacer()
                            ProgressView()
                                .controlSize(.small)
                        }
                    }
                }
                .disabled(isExporting)

                Button(role: .destructive) {
                    showingClearConfirmation = true
                } label: {
                    Label("Clear All Data", systemImage: "trash")
                        .foregroundColor(.red)
                }
            } header: {
                Label("Your Data", systemImage: "folder")
            } footer: {
                Text("All analytics data is stored locally on your Mac. You have full control over your data.")
            }

            // What We Track
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    TrackingInfoRow(icon: "arrow.left.arrow.right", title: "Transfer Statistics", description: "Number of transfers, success rate, total bytes")
                    TrackingInfoRow(icon: "cloud", title: "Provider Usage", description: "Which providers you use (anonymized)")
                    TrackingInfoRow(icon: "gearshape", title: "Feature Usage", description: "Which features you enable")
                    TrackingInfoRow(icon: "exclamationmark.triangle", title: "Error Rates", description: "Types of errors (no personal data)")
                }
            } header: {
                Label("What We Track", systemImage: "info.circle")
            }

            // What We Never Track
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    NeverTrackRow(text: "File names or paths")
                    NeverTrackRow(text: "File contents")
                    NeverTrackRow(text: "Passwords or credentials")
                    NeverTrackRow(text: "Personal information")
                    NeverTrackRow(text: "IP addresses")
                }
            } header: {
                Label("What We Never Track", systemImage: "lock.shield")
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 450, minHeight: 500)
        .sheet(isPresented: $showingStats) {
            StatsDetailView(stats: analyticsManager.stats)
        }
        .alert("Data Exported", isPresented: $showingExportSuccess) {
            Button("Show in Finder") {
                if let url = exportURL {
                    NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path)
                }
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your analytics data has been exported successfully.")
        }
        .alert("Clear All Data?", isPresented: $showingClearConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                analyticsManager.clearData()
            }
        } message: {
            Text("This will permanently delete all your local analytics data. This action cannot be undone.")
        }
    }

    private func exportData() {
        isExporting = true
        Task {
            do {
                let url = try await analyticsManager.exportData()
                exportURL = url
                showingExportSuccess = true
            } catch {
                // Handle error silently
            }
            isExporting = false
        }
    }
}

// MARK: - Supporting Views

private struct TrackingInfoRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct NeverTrackRow: View {
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 14))

            Text(text)
                .font(.subheadline)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Stats Detail View

private struct StatsDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let stats: AnalyticsStats

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Your Usage Statistics")
                    .font(.headline)
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .keyboardShortcut(.escape)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            // Stats Grid
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    AnalyticsStatCard(title: "Sessions", value: "\(stats.sessionCount)", icon: "play.circle")
                    AnalyticsStatCard(title: "Transfers", value: "\(stats.totalTransfers)", icon: "arrow.left.arrow.right")
                    AnalyticsStatCard(title: "Success Rate", value: String(format: "%.1f%%", stats.successRate), icon: "checkmark.circle")
                    AnalyticsStatCard(title: "Data Transferred", value: formatBytes(stats.totalBytesTransferred), icon: "externaldrive")
                    AnalyticsStatCard(title: "Avg Speed", value: formatSpeed(stats.averageTransferSpeed), icon: "speedometer")
                    AnalyticsStatCard(title: "Errors", value: "\(stats.errorCount)", icon: "exclamationmark.triangle")
                }
                .padding()

                // Feature Usage
                if !stats.featureUsage.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Feature Usage")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(stats.featureUsage.sorted(by: { $0.value > $1.value }), id: \.key) { feature, count in
                            HStack {
                                Text(feature.capitalized)
                                Spacer()
                                Text("\(count) times")
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(.bottom)
                }

                // Timeline
                VStack(alignment: .leading, spacing: 8) {
                    Text("Timeline")
                        .font(.headline)
                        .padding(.horizontal)

                    HStack {
                        Text("First seen:")
                        Spacer()
                        Text(stats.firstSeen, style: .date)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)

                    HStack {
                        Text("Last active:")
                        Spacer()
                        Text(stats.lastActive, style: .relative)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
        }
        .frame(width: 400, height: 500)
    }

    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }

    private func formatSpeed(_ bytesPerSecond: Double) -> String {
        guard bytesPerSecond > 0 else { return "N/A" }
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytesPerSecond)) + "/s"
    }
}

private struct AnalyticsStatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.blue)

            Text(value)
                .font(.title2)
                .fontWeight(.semibold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

// MARK: - Preview

#Preview {
    AnalyticsSettingsView()
}
