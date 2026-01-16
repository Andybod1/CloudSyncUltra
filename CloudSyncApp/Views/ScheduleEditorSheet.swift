//
//  ScheduleEditorSheet.swift
//  CloudSyncApp
//
//  Sheet for creating/editing a sync schedule
//

import SwiftUI

struct ScheduleEditorSheet: View {
    let schedule: SyncSchedule?
    let onSave: (SyncSchedule) -> Void

    @Environment(\.dismiss) private var dismiss
    @StateObject private var remotesVM = RemotesViewModel.shared
    @AppStorage("use24HourTime") private var use24HourTime = false

    // Form state
    @State private var name: String = ""
    @State private var sourceRemote: String = ""
    @State private var sourcePath: String = "/"
    @State private var destinationRemote: String = ""
    @State private var destinationPath: String = "/"
    @State private var syncType: TaskType = .transfer
    @State private var encryptSource: Bool = false
    @State private var encryptDestination: Bool = false

    // Schedule state
    @State private var frequency: ScheduleFrequency = .daily
    @State private var scheduledHour: Int = 2
    @State private var scheduledMinute: Int = 0
    @State private var customIntervalMinutes: Int = 60
    @State private var selectedDays: Set<Int> = Set([2, 3, 4, 5, 6]) // Weekdays

    // Folder browser state
    @State private var showSourceFolderBrowser = false
    @State private var showDestinationFolderBrowser = false

    private var isEditing: Bool { schedule != nil }

    /// Look up rclone name for source remote
    private var sourceRcloneName: String {
        remotesVM.configuredRemotes.first { $0.name == sourceRemote }?.rcloneName ?? sourceRemote
    }

    /// Look up rclone name for destination remote
    private var destinationRcloneName: String {
        remotesVM.configuredRemotes.first { $0.name == destinationRemote }?.rcloneName ?? destinationRemote
    }

    private var isValid: Bool {
        !name.isEmpty &&
        !sourceRemote.isEmpty &&
        !destinationRemote.isEmpty &&
        sourceRemote != destinationRemote
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(isEditing ? "Edit Schedule" : "New Schedule")
                    .font(.headline)
                Spacer()
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.escape)
            }
            .padding()

            Divider()

            // Form content
            Form {
                // Name
                Section {
                    TextField("Schedule Name", text: $name)
                        .textFieldStyle(.roundedBorder)
                } header: {
                    Text("Name")
                }

                // Source
                Section {
                    Picker("Remote", selection: $sourceRemote) {
                        Text("Select...").tag("")
                        ForEach(remotesVM.configuredRemotes) { remote in
                            Text(remote.name).tag(remote.name)
                        }
                    }

                    HStack {
                        Text("Path")
                        Spacer()
                        Button(action: { showSourceFolderBrowser = true }) {
                            HStack {
                                Text(sourcePath.isEmpty || sourcePath == "/" ? "/ (root)" : sourcePath)
                                    .foregroundColor(.primary)
                                Image(systemName: "folder")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .buttonStyle(.bordered)
                        .disabled(sourceRemote.isEmpty)
                        .popover(isPresented: $showSourceFolderBrowser) {
                            RemoteFolderBrowser(
                                remoteName: sourceRcloneName,
                                selectedPath: Binding(
                                    get: { sourcePath == "/" ? "" : sourcePath },
                                    set: { sourcePath = $0.isEmpty ? "/" : $0 }
                                ),
                                onDismiss: { showSourceFolderBrowser = false }
                            )
                        }
                    }

                    if EncryptionManager.shared.isEncryptionConfigured(for: sourceRcloneName) {
                        Toggle("Decrypt from source", isOn: $encryptSource)
                    }
                } header: {
                    Text("Source")
                }

                // Destination
                Section {
                    Picker("Remote", selection: $destinationRemote) {
                        Text("Select...").tag("")
                        ForEach(remotesVM.configuredRemotes) { remote in
                            Text(remote.name).tag(remote.name)
                        }
                    }

                    HStack {
                        Text("Path")
                        Spacer()
                        Button(action: { showDestinationFolderBrowser = true }) {
                            HStack {
                                Text(destinationPath.isEmpty || destinationPath == "/" ? "/ (root)" : destinationPath)
                                    .foregroundColor(.primary)
                                Image(systemName: "folder")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .buttonStyle(.bordered)
                        .disabled(destinationRemote.isEmpty)
                        .popover(isPresented: $showDestinationFolderBrowser) {
                            RemoteFolderBrowser(
                                remoteName: destinationRcloneName,
                                selectedPath: Binding(
                                    get: { destinationPath == "/" ? "" : destinationPath },
                                    set: { destinationPath = $0.isEmpty ? "/" : $0 }
                                ),
                                onDismiss: { showDestinationFolderBrowser = false }
                            )
                        }
                    }

                    if EncryptionManager.shared.isEncryptionConfigured(for: destinationRcloneName) {
                        Toggle("Encrypt at destination", isOn: $encryptDestination)
                    }
                } header: {
                    Text("Destination")
                }

                // Schedule
                Section {
                    Picker("Frequency", selection: $frequency) {
                        ForEach(ScheduleFrequency.allCases, id: \.self) { freq in
                            Label(freq.rawValue, systemImage: freq.icon).tag(freq)
                        }
                    }

                    switch frequency {
                    case .hourly:
                        Picker("At minute", selection: $scheduledMinute) {
                            ForEach([0, 15, 30, 45], id: \.self) { min in
                                Text(":\(String(format: "%02d", min))").tag(min)
                            }
                        }

                    case .daily:
                        HStack {
                            Picker("Hour", selection: $scheduledHour) {
                                ForEach(0..<24, id: \.self) { hour in
                                    Text(formatHour(hour)).tag(hour)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(width: 120)

                            Picker("Minute", selection: $scheduledMinute) {
                                ForEach([0, 15, 30, 45], id: \.self) { min in
                                    Text(":\(String(format: "%02d", min))").tag(min)
                                }
                            }
                            .frame(width: 80)
                        }

                    case .weekly:
                        HStack {
                            Picker("Hour", selection: $scheduledHour) {
                                ForEach(0..<24, id: \.self) { hour in
                                    Text(formatHour(hour)).tag(hour)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(width: 120)

                            Picker("Minute", selection: $scheduledMinute) {
                                ForEach([0, 15, 30, 45], id: \.self) { min in
                                    Text(":\(String(format: "%02d", min))").tag(min)
                                }
                            }
                            .frame(width: 80)
                        }

                        DayPicker(selectedDays: $selectedDays)

                    case .custom:
                        Picker("Interval", selection: $customIntervalMinutes) {
                            Text("5 minutes").tag(5)
                            Text("10 minutes").tag(10)
                            Text("15 minutes").tag(15)
                            Text("30 minutes").tag(30)
                            Text("1 hour").tag(60)
                            Text("2 hours").tag(120)
                            Text("4 hours").tag(240)
                            Text("6 hours").tag(360)
                            Text("12 hours").tag(720)
                        }
                    }
                } header: {
                    Text("Schedule")
                }

                // Sync Type
                Section {
                    Picker("Type", selection: $syncType) {
                        Label("Transfer (one-way)", systemImage: "arrow.right").tag(TaskType.transfer)
                        Label("Sync (bidirectional)", systemImage: "arrow.triangle.2.circlepath").tag(TaskType.sync)
                        Label("Backup (preserve deleted)", systemImage: "externaldrive.fill.badge.timemachine").tag(TaskType.backup)
                    }
                    .pickerStyle(.radioGroup)
                } header: {
                    Text("Sync Type")
                }
            }
            .formStyle(.grouped)

            Divider()

            // Footer
            HStack {
                if !isValid {
                    Text("Please fill in all required fields")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button("Save") {
                    saveSchedule()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isValid)
                .keyboardShortcut(.return)
            }
            .padding()
        }
        .frame(width: 500, height: 650)
        .onAppear {
            if let schedule = schedule {
                loadSchedule(schedule)
            }
        }
    }

    private func formatHour(_ hour: Int) -> String {
        if use24HourTime {
            return String(format: "%02d:00", hour)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "h a"
            var components = DateComponents()
            components.hour = hour
            let date = Calendar.current.date(from: components) ?? Date()
            return formatter.string(from: date)
        }
    }

    private func loadSchedule(_ schedule: SyncSchedule) {
        name = schedule.name
        sourceRemote = schedule.sourceRemote
        sourcePath = schedule.sourcePath
        destinationRemote = schedule.destinationRemote
        destinationPath = schedule.destinationPath
        syncType = schedule.syncType
        encryptSource = schedule.encryptSource
        encryptDestination = schedule.encryptDestination
        frequency = schedule.frequency
        scheduledHour = schedule.scheduledHour ?? 2
        scheduledMinute = schedule.scheduledMinute ?? 0
        customIntervalMinutes = schedule.customIntervalMinutes ?? 60
        selectedDays = schedule.scheduledDays ?? Set([2, 3, 4, 5, 6])
    }

    private func saveSchedule() {
        var newSchedule = SyncSchedule(
            id: schedule?.id ?? UUID(),
            name: name,
            sourceRemote: sourceRemote,
            sourcePath: sourcePath,
            destinationRemote: destinationRemote,
            destinationPath: destinationPath,
            syncType: syncType,
            encryptSource: encryptSource,
            encryptDestination: encryptDestination,
            frequency: frequency,
            customIntervalMinutes: frequency == .custom ? customIntervalMinutes : nil,
            scheduledHour: [.daily, .weekly, .hourly].contains(frequency) ? scheduledHour : nil,
            scheduledMinute: scheduledMinute,
            scheduledDays: frequency == .weekly ? selectedDays : nil
        )

        // Preserve existing stats if editing
        if let existing = schedule {
            newSchedule.runCount = existing.runCount
            newSchedule.failureCount = existing.failureCount
            newSchedule.lastRunAt = existing.lastRunAt
            newSchedule.lastRunSuccess = existing.lastRunSuccess
            newSchedule.createdAt = existing.createdAt
        }

        onSave(newSchedule)
        dismiss()
    }
}

// MARK: - Day Picker Component

struct DayPicker: View {
    @Binding var selectedDays: Set<Int>

    private let days = [
        (1, "S"), (2, "M"), (3, "T"), (4, "W"), (5, "T"), (6, "F"), (7, "S")
    ]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(days, id: \.0) { day, label in
                Button(action: { toggleDay(day) }) {
                    Text(label)
                        .font(.caption)
                        .fontWeight(.medium)
                        .frame(width: 28, height: 28)
                        .background(selectedDays.contains(day) ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(selectedDays.contains(day) ? .white : .primary)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }

            Spacer()

            Button("Weekdays") {
                selectedDays = Set([2, 3, 4, 5, 6])
            }
            .buttonStyle(.bordered)
            .controlSize(.small)

            Button("Every day") {
                selectedDays = Set(1...7)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
    }

    private func toggleDay(_ day: Int) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
    }
}
