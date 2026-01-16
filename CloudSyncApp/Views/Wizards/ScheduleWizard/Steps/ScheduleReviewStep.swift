//
//  ScheduleReviewStep.swift
//  CloudSyncApp
//
//  Step 3: Review and confirm the schedule configuration
//

import SwiftUI

struct ScheduleReviewStep: View {
    @ObservedObject var state: ScheduleWizardState

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

                    Text("Review Your Schedule")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Confirm the details below and click Complete to create your schedule")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)

                // Schedule Summary Card
                VStack(alignment: .leading, spacing: AppTheme.spacingL) {
                    // Name
                    HStack {
                        Label("Name", systemImage: "tag")
                            .font(.headline)
                        Spacer()
                        Text(state.scheduleName.isEmpty ? "Unnamed Schedule" : state.scheduleName)
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
                                    Text(state.sourcePath.isEmpty ? "/" : state.sourcePath)
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
                        Image(systemName: "arrow.down")
                            .font(.title2)
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
                                    Text(state.destinationPath.isEmpty ? "/" : state.destinationPath)
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

                    // Sync Type
                    HStack {
                        Label("Sync Type", systemImage: state.syncType.icon)
                            .font(.headline)
                        Spacer()
                        Text(state.syncType.rawValue)
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    // Schedule
                    VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                        Label("Schedule", systemImage: "clock")
                            .font(.headline)

                        HStack(spacing: AppTheme.spacingM) {
                            Image(systemName: state.frequency.icon)
                                .foregroundColor(.accentColor)
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(state.frequency.rawValue)
                                    .fontWeight(.medium)
                                Text(formattedScheduleDescription)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(NSColor.windowBackgroundColor))
                        .cornerRadius(AppTheme.cornerRadiusSmall)
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(AppTheme.cornerRadius)

                // Info Note
                HStack(spacing: AppTheme.spacingS) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)

                    Text("Your schedule will be enabled immediately after creation. You can disable or modify it anytime from the Schedules view.")
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

    private var formattedScheduleDescription: String {
        switch state.frequency {
        case .hourly:
            return "Every hour at :\(String(format: "%02d", state.scheduledMinute))"

        case .daily:
            return "Every day at \(formatTime(hour: state.scheduledHour, minute: state.scheduledMinute))"

        case .weekly:
            let days = formattedDays
            return "\(days) at \(formatTime(hour: state.scheduledHour, minute: state.scheduledMinute))"

        case .custom:
            if state.customIntervalMinutes < 60 {
                return "Every \(state.customIntervalMinutes) minutes"
            } else {
                let hours = state.customIntervalMinutes / 60
                return "Every \(hours) hour\(hours > 1 ? "s" : "")"
            }
        }
    }

    private var formattedDays: String {
        let dayNames = ["", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let sortedDays = state.scheduledDays.sorted()

        if state.scheduledDays.count == 7 {
            return "Every day"
        } else if state.scheduledDays == Set([2, 3, 4, 5, 6]) {
            return "Weekdays"
        } else if state.scheduledDays == Set([1, 7]) {
            return "Weekends"
        } else {
            return sortedDays.map { dayNames[$0] }.joined(separator: ", ")
        }
    }

    private func formatTime(hour: Int, minute: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let date = Calendar.current.date(from: components) ?? Date()
        return formatter.string(from: date)
    }
}

#Preview {
    let state = ScheduleWizardState()
    state.scheduleName = "Daily Backup"
    state.sourceRemote = CloudRemote(name: "Local", type: .local, isConfigured: true, path: "/Users/test/Documents")
    state.destinationRemote = CloudRemote(name: "Google Drive", type: .googleDrive, isConfigured: true, path: "")
    state.encryptDestination = true
    state.frequency = .daily
    state.scheduledHour = 2
    state.scheduledMinute = 0

    return ScheduleReviewStep(state: state)
        .frame(width: 700, height: 600)
}
