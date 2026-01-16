//
//  PerformanceSettingsView.swift
//  CloudSyncApp
//
//  Created by Dev-1 on 2026-01-15.
//

import SwiftUI

struct PerformanceSettingsView: View {
    // Profile selection
    @AppStorage("performanceProfile") private var selectedProfile = PerformanceProfile.balanced
    @AppStorage("showQuickToggle") private var showQuickToggle = true

    // Individual settings
    @AppStorage("parallelTransfers") private var parallelTransfers = 4
    @AppStorage("bandwidthLimit") private var bandwidthLimit = 5
    @AppStorage("chunkSizeMB") private var chunkSizeMB = 32
    @AppStorage("cpuPriority") private var cpuPriority = CPUPriority.normal
    @AppStorage("checkFrequency") private var checkFrequency = CheckFrequency.sampling

    @State private var showAdvanced = false
    @State private var currentSettings = PerformanceProfile.balanced.defaultSettings

    var body: some View {
        Form {
            // Profile Selection
            Section {
                VStack(alignment: .leading, spacing: AppTheme.spacing) {
                    Text("Performance Profile")
                        .font(AppTheme.headlineFont)

                    Picker("", selection: $selectedProfile) {
                        ForEach(PerformanceProfile.allCases, id: \.self) { profile in
                            Text(profile.displayName)
                                .tag(profile)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedProfile) { _, newProfile in
                        if newProfile != .custom {
                            applyProfile(newProfile)
                        }
                        // Auto-expand advanced settings when Custom is selected
                        if newProfile == .custom {
                            withAnimation {
                                showAdvanced = true
                            }
                        }
                    }

                    // Profile description
                    profileDescriptionView
                }
                .padding(.vertical, AppTheme.spacingS)
            } header: {
                Label("Profile", systemImage: "speedometer")
            }

            // Advanced Settings
            Section {
                DisclosureGroup("Advanced Settings", isExpanded: $showAdvanced) {
                    VStack(spacing: AppTheme.spacingL) {
                        // Parallel Transfers
                        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                            HStack {
                                Image(systemName: "arrow.left.and.right.square")
                                    .foregroundColor(AppTheme.accentColor)
                                Text("Parallel Transfers: \(parallelTransfers)")
                                    .font(AppTheme.bodyFont)
                            }
                            Slider(value: Binding(
                                get: { Double(parallelTransfers) },
                                set: { parallelTransfers = Int($0) }
                            ), in: 1...16, step: 1)
                            Text("Number of files to transfer simultaneously")
                                .font(AppTheme.captionFont)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .onChange(of: parallelTransfers) { _, _ in
                            updateProfileIfNeeded()
                        }

                        Divider()

                        // Bandwidth Limit
                        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                            HStack {
                                Image(systemName: "gauge")
                                    .foregroundColor(AppTheme.accentColor)
                                Text("Bandwidth Limit: \(bandwidthLimit == 0 ? "Unlimited" : "\(bandwidthLimit) MB/s")")
                                    .font(AppTheme.bodyFont)
                            }
                            Slider(value: Binding(
                                get: { Double(bandwidthLimit) },
                                set: { bandwidthLimit = Int($0) }
                            ), in: 0...100, step: 1)
                            Text("Maximum bandwidth usage (0 = unlimited)")
                                .font(AppTheme.captionFont)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .onChange(of: bandwidthLimit) { _, _ in
                            updateProfileIfNeeded()
                        }

                        Divider()

                        // Chunk Size
                        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                            HStack {
                                Image(systemName: "square.3.layers.3d")
                                    .foregroundColor(AppTheme.accentColor)
                                Text("Chunk Size")
                                    .font(AppTheme.bodyFont)
                            }
                            Picker("", selection: $chunkSizeMB) {
                                ForEach(PerformanceSettings.availableChunkSizes, id: \.self) { size in
                                    Text("\(size) MB").tag(size)
                                }
                            }
                            .pickerStyle(.menu)
                            Text("Size of data chunks for transfers")
                                .font(AppTheme.captionFont)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .onChange(of: chunkSizeMB) { _, _ in
                            updateProfileIfNeeded()
                        }

                        Divider()

                        // CPU Priority
                        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                            HStack {
                                Image(systemName: "cpu")
                                    .foregroundColor(AppTheme.accentColor)
                                Text("CPU Priority")
                                    .font(AppTheme.bodyFont)
                            }
                            Picker("", selection: $cpuPriority) {
                                ForEach(CPUPriority.allCases, id: \.self) { priority in
                                    Text(priority.displayName).tag(priority)
                                }
                            }
                            .pickerStyle(.menu)
                            Text("Process priority for transfers")
                                .font(AppTheme.captionFont)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .onChange(of: cpuPriority) { _, _ in
                            updateProfileIfNeeded()
                        }

                        Divider()

                        // Check Frequency
                        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                            HStack {
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(AppTheme.accentColor)
                                Text("File Verification")
                                    .font(AppTheme.bodyFont)
                            }
                            Picker("", selection: $checkFrequency) {
                                ForEach(CheckFrequency.allCases, id: \.self) { freq in
                                    Text(freq.displayName).tag(freq)
                                }
                            }
                            .pickerStyle(.menu)
                            Text(checkFrequency.description)
                                .font(AppTheme.captionFont)
                                .foregroundColor(AppTheme.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .onChange(of: checkFrequency) { _, _ in
                            updateProfileIfNeeded()
                        }
                    }
                    .padding(.top, AppTheme.spacingM)
                }
            } header: {
                Label("Customization", systemImage: "slider.horizontal.3")
            }

            // Provider-Specific Note
            Section {
                HStack(spacing: AppTheme.spacingS) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(AppTheme.infoColor)
                    VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                        Text("Provider Optimization")
                            .font(AppTheme.bodyFont.weight(.medium))
                        Text("Chunk sizes are automatically optimized per cloud provider. The profile setting acts as a maximum limit.")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.vertical, AppTheme.spacingXS)
            }

            // Quick Access (moved to bottom for less prominence)
            Section {
                Toggle(isOn: $showQuickToggle) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Show quick toggle in Transfer View")
                        Text("Allows temporary profile switching during transfers")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
            } header: {
                Label("Quick Access", systemImage: "bolt")
            }
        }
        .formStyle(.grouped)
        .padding()
        .onAppear {
            loadCurrentSettings()
        }
    }

    @ViewBuilder
    private var profileDescriptionView: some View {
        let description: String = {
            switch selectedProfile {
            case .conservative:
                return "Minimal resource usage, slower transfers. Ideal for background syncing."
            case .balanced:
                return "Good balance of speed and resource usage. Recommended for most users."
            case .performance:
                return "Maximum speed, higher resource usage. Best for large transfers."
            case .custom:
                return "Configure settings below. Expand Advanced Settings to customize."
            }
        }()

        Text(description)
            .font(AppTheme.captionFont)
            .foregroundColor(AppTheme.textSecondary)
            .padding(.top, AppTheme.spacingXS)
    }

    private func loadCurrentSettings() {
        currentSettings = PerformanceSettings(
            parallelTransfers: parallelTransfers,
            bandwidthLimit: bandwidthLimit,
            chunkSizeMB: chunkSizeMB,
            cpuPriority: cpuPriority,
            checkFrequency: checkFrequency
        )

        // Check if current settings match any profile
        let matchingProfile = currentSettings.matchingProfile()
        if selectedProfile != matchingProfile {
            selectedProfile = matchingProfile
        }
    }

    private func applyProfile(_ profile: PerformanceProfile) {
        let settings = profile.defaultSettings

        parallelTransfers = settings.parallelTransfers
        bandwidthLimit = settings.bandwidthLimit
        chunkSizeMB = settings.chunkSizeMB
        cpuPriority = settings.cpuPriority
        checkFrequency = settings.checkFrequency

        currentSettings = settings
    }

    private func updateProfileIfNeeded() {
        let newSettings = PerformanceSettings(
            parallelTransfers: parallelTransfers,
            bandwidthLimit: bandwidthLimit,
            chunkSizeMB: chunkSizeMB,
            cpuPriority: cpuPriority,
            checkFrequency: checkFrequency
        )

        // Check if settings match any predefined profile
        let matchingProfile = newSettings.matchingProfile()
        if selectedProfile != matchingProfile {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedProfile = matchingProfile
            }
        }

        currentSettings = newSettings
    }
}

#Preview {
    PerformanceSettingsView()
}
