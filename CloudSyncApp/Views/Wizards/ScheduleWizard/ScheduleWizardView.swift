//
//  ScheduleWizardView.swift
//  CloudSyncApp
//
//  Multi-step wizard for creating sync schedules
//

import SwiftUI

/// State management for the schedule creation wizard
class ScheduleWizardState: ObservableObject {
    @Published var currentStep = 0

    // Step 1: Source/Destination selection
    @Published var sourceRemote: CloudRemote?
    @Published var sourcePath: String = ""
    @Published var destinationRemote: CloudRemote?
    @Published var destinationPath: String = ""
    @Published var syncType: TaskType = .sync
    @Published var encryptSource = false
    @Published var encryptDestination = false

    // Step 2: Schedule configuration
    @Published var scheduleName: String = ""
    @Published var frequency: ScheduleFrequency = .daily
    @Published var customIntervalMinutes: Int = 60
    @Published var scheduledHour: Int = 2
    @Published var scheduledMinute: Int = 0
    @Published var scheduledDays: Set<Int> = [2, 3, 4, 5, 6] // Weekdays by default

    // Validation
    var canProceedFromStep1: Bool {
        sourceRemote != nil && destinationRemote != nil
    }

    var canProceedFromStep2: Bool {
        !scheduleName.isEmpty
    }

    func reset() {
        currentStep = 0
        sourceRemote = nil
        sourcePath = ""
        destinationRemote = nil
        destinationPath = ""
        syncType = .sync
        encryptSource = false
        encryptDestination = false
        scheduleName = ""
        frequency = .daily
        customIntervalMinutes = 60
        scheduledHour = 2
        scheduledMinute = 0
        scheduledDays = [2, 3, 4, 5, 6]
    }

    /// Build the SyncSchedule from wizard state
    func buildSchedule() -> SyncSchedule {
        SyncSchedule(
            name: scheduleName,
            sourceRemote: sourceRemote?.name ?? "",
            sourcePath: sourcePath,
            destinationRemote: destinationRemote?.name ?? "",
            destinationPath: destinationPath,
            syncType: syncType,
            encryptSource: encryptSource,
            encryptDestination: encryptDestination,
            frequency: frequency,
            customIntervalMinutes: frequency == .custom ? customIntervalMinutes : nil,
            scheduledHour: scheduledHour,
            scheduledMinute: scheduledMinute,
            scheduledDays: frequency == .weekly ? scheduledDays : nil
        )
    }
}

/// Main wizard view for schedule creation
struct ScheduleWizardView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var remotesVM: RemotesViewModel
    @StateObject private var wizardState = ScheduleWizardState()

    private let steps = ["Select Remotes", "Configure Schedule", "Review"]

    var body: some View {
        WizardView(
            steps: steps,
            currentStep: .init(get: { wizardState.currentStep }, set: { wizardState.currentStep = $0 }),
            onCancel: {
                dismiss()
            },
            onComplete: {
                // Create the schedule
                let schedule = wizardState.buildSchedule()
                ScheduleManager.shared.addSchedule(schedule)
                dismiss()
            }
        ) {
            // Content for current step
            switch wizardState.currentStep {
            case 0:
                SelectRemotesStep(state: wizardState)
                    .environmentObject(remotesVM)
            case 1:
                ConfigureScheduleStep(state: wizardState)
            case 2:
                ScheduleReviewStep(state: wizardState)
            default:
                EmptyView()
            }
        }
    }
}

#Preview {
    ScheduleWizardView()
        .environmentObject(RemotesViewModel.shared)
}
