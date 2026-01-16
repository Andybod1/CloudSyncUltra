//
//  ConfigureScheduleStep.swift
//  CloudSyncApp
//
//  Step 2: Configure schedule frequency and timing
//

import SwiftUI

struct ConfigureScheduleStep: View {
    @ObservedObject var state: ScheduleWizardState

    private let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    private let dayNumbers = [1, 2, 3, 4, 5, 6, 7] // Sunday=1, Saturday=7

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacingXL) {
                // Header
                VStack(spacing: AppTheme.spacingS) {
                    Text("Configure Schedule")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Set when and how often to sync")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)

                // Schedule Name
                VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                    Label("Schedule Name", systemImage: "tag")
                        .font(.headline)

                    TextField("My Backup Schedule", text: $state.scheduleName)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityLabel("Schedule Name")
                        .accessibilityHint("Enter a name for this schedule")

                    if state.scheduleName.isEmpty {
                        Text("Please enter a name for this schedule")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(AppTheme.cornerRadius)

                // Frequency Selection
                VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                    Label("Frequency", systemImage: "clock")
                        .font(.headline)

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: AppTheme.spacingM) {
                        ForEach(ScheduleFrequency.allCases, id: \.self) { frequency in
                            FrequencyCard(
                                frequency: frequency,
                                isSelected: state.frequency == frequency
                            ) {
                                state.frequency = frequency
                            }
                        }
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(AppTheme.cornerRadius)

                // Timing Configuration (based on frequency)
                timingConfiguration
            }
            .padding()
        }
    }

    @ViewBuilder
    private var timingConfiguration: some View {
        switch state.frequency {
        case .hourly:
            hourlyConfig
        case .daily:
            dailyConfig
        case .weekly:
            weeklyConfig
        case .custom:
            customConfig
        }
    }

    private var hourlyConfig: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingM) {
            Label("Timing", systemImage: "clock.arrow.circlepath")
                .font(.headline)

            HStack {
                Text("Run at minute:")
                Picker("Minute", selection: $state.scheduledMinute) {
                    ForEach([0, 15, 30, 45], id: \.self) { minute in
                        Text(":\(String(format: "%02d", minute))").tag(minute)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 80)

                Text("of every hour")
                    .foregroundColor(.secondary)
            }

            Text("Example: Will run at 1:\(String(format: "%02d", state.scheduledMinute)), 2:\(String(format: "%02d", state.scheduledMinute)), 3:\(String(format: "%02d", state.scheduledMinute)), etc.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(AppTheme.cornerRadius)
    }

    private var dailyConfig: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingM) {
            Label("Time of Day", systemImage: "sun.max")
                .font(.headline)

            HStack(spacing: AppTheme.spacingM) {
                Text("Run at:")

                Picker("Hour", selection: $state.scheduledHour) {
                    ForEach(0..<24, id: \.self) { hour in
                        Text(formatHour(hour)).tag(hour)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 100)

                Text(":")

                Picker("Minute", selection: $state.scheduledMinute) {
                    ForEach([0, 15, 30, 45], id: \.self) { minute in
                        Text(String(format: "%02d", minute)).tag(minute)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 60)
            }

            // Quick presets
            HStack(spacing: AppTheme.spacingS) {
                Text("Presets:")
                    .foregroundColor(.secondary)

                Button("2:00 AM") {
                    state.scheduledHour = 2
                    state.scheduledMinute = 0
                }
                .buttonStyle(.bordered)

                Button("6:00 AM") {
                    state.scheduledHour = 6
                    state.scheduledMinute = 0
                }
                .buttonStyle(.bordered)

                Button("Noon") {
                    state.scheduledHour = 12
                    state.scheduledMinute = 0
                }
                .buttonStyle(.bordered)

                Button("6:00 PM") {
                    state.scheduledHour = 18
                    state.scheduledMinute = 0
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(AppTheme.cornerRadius)
    }

    private var weeklyConfig: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingM) {
            Label("Days and Time", systemImage: "calendar")
                .font(.headline)

            // Day selection
            VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                Text("Run on:")
                    .foregroundColor(.secondary)

                HStack(spacing: AppTheme.spacingS) {
                    ForEach(Array(zip(dayNumbers, dayNames)), id: \.0) { dayNum, dayName in
                        DayToggleButton(
                            dayName: dayName,
                            isSelected: state.scheduledDays.contains(dayNum)
                        ) {
                            if state.scheduledDays.contains(dayNum) {
                                state.scheduledDays.remove(dayNum)
                            } else {
                                state.scheduledDays.insert(dayNum)
                            }
                        }
                    }
                }

                // Quick presets
                HStack(spacing: AppTheme.spacingS) {
                    Button("Weekdays") {
                        state.scheduledDays = [2, 3, 4, 5, 6]
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)

                    Button("Weekends") {
                        state.scheduledDays = [1, 7]
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)

                    Button("Every Day") {
                        state.scheduledDays = Set(1...7)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }

            Divider()

            // Time selection
            HStack(spacing: AppTheme.spacingM) {
                Text("At:")

                Picker("Hour", selection: $state.scheduledHour) {
                    ForEach(0..<24, id: \.self) { hour in
                        Text(formatHour(hour)).tag(hour)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 100)

                Text(":")

                Picker("Minute", selection: $state.scheduledMinute) {
                    ForEach([0, 15, 30, 45], id: \.self) { minute in
                        Text(String(format: "%02d", minute)).tag(minute)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 60)
            }

            if state.scheduledDays.isEmpty {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Please select at least one day")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(AppTheme.cornerRadius)
    }

    private var customConfig: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingM) {
            Label("Custom Interval", systemImage: "timer")
                .font(.headline)

            HStack {
                Text("Run every:")

                Picker("Interval", selection: $state.customIntervalMinutes) {
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
                .pickerStyle(.menu)
                .frame(width: 150)
            }

            Text("The schedule will run repeatedly at this interval")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(AppTheme.cornerRadius)
    }

    private func formatHour(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        var components = DateComponents()
        components.hour = hour
        let date = Calendar.current.date(from: components) ?? Date()
        return formatter.string(from: date)
    }
}

/// Card for selecting frequency
struct FrequencyCard: View {
    let frequency: ScheduleFrequency
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.spacingM) {
                Image(systemName: frequency.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .accentColor : .secondary)
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 2) {
                    Text(frequency.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    Text(frequency.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentColor)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color(NSColor.windowBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(isSelected ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(frequency.rawValue)
        .accessibilityHint(frequency.description)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// Toggle button for day selection
struct DayToggleButton: View {
    let dayName: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(dayName)
                .font(.caption)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(isSelected ? Color.accentColor : Color(NSColor.controlBackgroundColor))
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(dayName)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    ConfigureScheduleStep(state: ScheduleWizardState())
        .frame(width: 700, height: 600)
}
