# Task: Scheduled Sync - User Interface

**Assigned to:** Dev-1 (UI Layer)
**Priority:** High
**Status:** Ready
**Depends on:** Dev-3 completing ScheduleManager (can work in parallel on UI structure)

---

## Objective

Build all UI components for the scheduled sync feature: settings tab, list view, editor sheet.

---

## Task 1: Add Schedules Tab to SettingsView

**File:** `CloudSyncApp/SettingsView.swift`

Add a new tab for Schedules:

```swift
// In SettingsView, add new tab after "Sync" tab:

ScheduleSettingsView()
    .tabItem {
        Label("Schedules", systemImage: "calendar.badge.clock")
    }
    .tag(3)

// Update AboutView tag to 4
AboutView()
    .tabItem {
        Label("About", systemImage: "info.circle")
    }
    .tag(4)

// Increase frame height to accommodate new content
.frame(width: 600, height: 580)
```

---

## Task 2: Create ScheduleSettingsView

**File:** `CloudSyncApp/Views/ScheduleSettingsView.swift`

```swift
//
//  ScheduleSettingsView.swift
//  CloudSyncApp
//
//  Settings view for managing scheduled sync jobs
//

import SwiftUI

struct ScheduleSettingsView: View {
    @StateObject private var scheduleManager = ScheduleManager.shared
    @State private var showingAddSheet = false
    @State private var editingSchedule: SyncSchedule?
    @State private var scheduleToDelete: SyncSchedule?
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        Form {
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Scheduled Sync")
                            .font(.headline)
                        Text("\(scheduleManager.enabledSchedulesCount) active schedule\(scheduleManager.enabledSchedulesCount == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: { showingAddSheet = true }) {
                        Label("Add Schedule", systemImage: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            
            if scheduleManager.schedules.isEmpty {
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        
                        Text("No Scheduled Syncs")
                            .font(.headline)
                        
                        Text("Create a schedule to automatically sync your files at regular intervals.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
            } else {
                Section {
                    ForEach(scheduleManager.schedules) { schedule in
                        ScheduleRowView(
                            schedule: schedule,
                            onToggle: { scheduleManager.toggleSchedule(id: schedule.id) },
                            onEdit: { editingSchedule = schedule },
                            onDelete: {
                                scheduleToDelete = schedule
                                showDeleteConfirmation = true
                            },
                            onRunNow: {
                                Task {
                                    await scheduleManager.runNow(id: schedule.id)
                                }
                            }
                        )
                    }
                } header: {
                    Text("Schedules")
                }
            }
            
            if let next = scheduleManager.nextScheduledRun {
                Section {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text("Next Sync")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(next.schedule.name)
                                .font(.subheadline)
                        }
                        Spacer()
                        Text(next.schedule.formattedNextRun)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Upcoming")
                }
            }
        }
        .formStyle(.grouped)
        .sheet(isPresented: $showingAddSheet) {
            ScheduleEditorSheet(schedule: nil) { newSchedule in
                scheduleManager.addSchedule(newSchedule)
            }
        }
        .sheet(item: $editingSchedule) { schedule in
            ScheduleEditorSheet(schedule: schedule) { updatedSchedule in
                scheduleManager.updateSchedule(updatedSchedule)
            }
        }
        .alert("Delete Schedule", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let schedule = scheduleToDelete {
                    scheduleManager.deleteSchedule(id: schedule.id)
                }
            }
        } message: {
            Text("Are you sure you want to delete '\(scheduleToDelete?.name ?? "")'? This cannot be undone.")
        }
    }
}
```

---

## Task 3: Create ScheduleRowView

**File:** `CloudSyncApp/Views/ScheduleRowView.swift`

```swift
//
//  ScheduleRowView.swift
//  CloudSyncApp
//
//  Row component for displaying a schedule in the list
//

import SwiftUI

struct ScheduleRowView: View {
    let schedule: SyncSchedule
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onRunNow: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Enable toggle
            Toggle("", isOn: Binding(
                get: { schedule.isEnabled },
                set: { _ in onToggle() }
            ))
            .labelsHidden()
            .toggleStyle(.switch)
            .controlSize(.small)
            
            // Schedule info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(schedule.name)
                        .font(.headline)
                        .foregroundColor(schedule.isEnabled ? .primary : .secondary)
                    
                    if schedule.hasEncryption {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                HStack(spacing: 4) {
                    Text(schedule.sourceRemote)
                        .font(.caption)
                    
                    Image(systemName: schedule.syncType == .sync ? "arrow.left.arrow.right" : "arrow.right")
                        .font(.caption2)
                    
                    Text(schedule.destinationRemote)
                        .font(.caption)
                }
                .foregroundColor(.secondary)
                
                // Schedule timing
                HStack(spacing: 8) {
                    Label(schedule.formattedSchedule, systemImage: schedule.frequency.icon)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Status and next run
            VStack(alignment: .trailing, spacing: 4) {
                if schedule.isEnabled {
                    Text(schedule.formattedNextRun)
                        .font(.caption)
                        .foregroundColor(.blue)
                } else {
                    Text("Disabled")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let lastRun = schedule.lastRunAt {
                    HStack(spacing: 4) {
                        if schedule.lastRunSuccess == true {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else if schedule.lastRunSuccess == false {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                        Text(schedule.formattedLastRun)
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary)
                }
            }
            
            // Action buttons (show on hover)
            if isHovering {
                HStack(spacing: 4) {
                    Button(action: onRunNow) {
                        Image(systemName: "play.fill")
                    }
                    .buttonStyle(.borderless)
                    .help("Run Now")
                    .disabled(!schedule.isEnabled)
                    
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                    }
                    .buttonStyle(.borderless)
                    .help("Edit")
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.borderless)
                    .foregroundColor(.red)
                    .help("Delete")
                }
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
        .contextMenu {
            Button(action: onRunNow) {
                Label("Run Now", systemImage: "play.fill")
            }
            .disabled(!schedule.isEnabled)
            
            Divider()
            
            Button(action: onToggle) {
                Label(schedule.isEnabled ? "Disable" : "Enable", 
                      systemImage: schedule.isEnabled ? "pause.circle" : "play.circle")
            }
            
            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }
            
            Divider()
            
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
```

---

## Task 4: Create ScheduleEditorSheet

**File:** `CloudSyncApp/Views/ScheduleEditorSheet.swift`

```swift
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
    @StateObject private var rclone = RcloneManager.shared
    
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
    
    private var isEditing: Bool { schedule != nil }
    
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
                        ForEach(rclone.configuredRemotes, id: \.self) { remote in
                            Text(remote).tag(remote)
                        }
                    }
                    
                    TextField("Path", text: $sourcePath)
                        .textFieldStyle(.roundedBorder)
                    
                    if EncryptionManager.shared.isEncryptionConfigured(for: sourceRemote.lowercased()) {
                        Toggle("Decrypt from source", isOn: $encryptSource)
                    }
                } header: {
                    Text("Source")
                }
                
                // Destination
                Section {
                    Picker("Remote", selection: $destinationRemote) {
                        Text("Select...").tag("")
                        ForEach(rclone.configuredRemotes, id: \.self) { remote in
                            Text(remote).tag(remote)
                        }
                    }
                    
                    TextField("Path", text: $destinationPath)
                        .textFieldStyle(.roundedBorder)
                    
                    if EncryptionManager.shared.isEncryptionConfigured(for: destinationRemote.lowercased()) {
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
                            .frame(width: 100)
                            
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
                            .frame(width: 100)
                            
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
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        var components = DateComponents()
        components.hour = hour
        let date = Calendar.current.date(from: components) ?? Date()
        return formatter.string(from: date)
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
```

---

## Acceptance Criteria

- [ ] New "Schedules" tab appears in SettingsView
- [ ] ScheduleSettingsView shows list of schedules or empty state
- [ ] ScheduleRowView displays all schedule info correctly
- [ ] Enable/disable toggle works
- [ ] Edit button opens editor with existing values
- [ ] Delete button shows confirmation and deletes
- [ ] "Run Now" triggers immediate execution
- [ ] ScheduleEditorSheet creates valid SyncSchedule objects
- [ ] All frequency options work correctly in editor
- [ ] Day picker works for weekly schedules
- [ ] Build succeeds with zero errors

---

## When Complete

1. Update STATUS.md with completion
2. Write DEV1_COMPLETE.md with summary
3. Verify build: `xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build`
