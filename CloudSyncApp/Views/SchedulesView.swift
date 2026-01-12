//
//  SchedulesView.swift
//  CloudSyncApp
//
//  Main window view for managing scheduled sync jobs
//

import SwiftUI

struct SchedulesView: View {
    @StateObject private var scheduleManager = ScheduleManager.shared
    @State private var showingAddSchedule = false
    @State private var selectedSchedule: SyncSchedule?
    @State private var scheduleToDelete: SyncSchedule?
    @State private var showDeleteConfirmation = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Schedules")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Button(action: { showingAddSchedule = true }) {
                    Label("Add Schedule", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()

            Divider()

            // Content
            if scheduleManager.schedules.isEmpty {
                emptyState
            } else {
                scheduleList
            }
        }
        .sheet(isPresented: $showingAddSchedule) {
            ScheduleEditorSheet(schedule: nil) { newSchedule in
                scheduleManager.addSchedule(newSchedule)
            }
        }
        .sheet(item: $selectedSchedule) { schedule in
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

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No Scheduled Syncs")
                .font(.title3)
                .fontWeight(.medium)
            Text("Create a schedule to automatically sync your files.")
                .foregroundColor(.secondary)
            Button("Add Schedule") {
                showingAddSchedule = true
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var scheduleList: some View {
        VStack(spacing: 0) {
            // Next sync indicator
            if let next = scheduleManager.nextScheduledRun {
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
                .padding()
                .background(Color(NSColor.controlBackgroundColor))

                Divider()
            }

            // Schedule list
            List {
                ForEach(scheduleManager.schedules) { schedule in
                    ScheduleRowView(
                        schedule: schedule,
                        onToggle: { scheduleManager.toggleSchedule(id: schedule.id) },
                        onEdit: { selectedSchedule = schedule },
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
            }
            .listStyle(.inset)
        }
    }
}

#Preview {
    SchedulesView()
}
