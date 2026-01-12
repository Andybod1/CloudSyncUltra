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
