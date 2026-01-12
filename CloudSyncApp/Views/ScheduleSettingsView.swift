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
