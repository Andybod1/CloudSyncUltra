//
//  TransferWizardView.swift
//  CloudSyncApp
//
//  Multi-step wizard for setting up file transfers
//

import SwiftUI

/// State management for the transfer setup wizard
class TransferWizardState: ObservableObject {
    @Published var currentStep = 0

    // Step 1: Source selection
    @Published var sourceRemote: CloudRemote?
    @Published var sourcePath: String = ""
    @Published var encryptSource = false

    // Step 2: Destination selection
    @Published var destinationRemote: CloudRemote?
    @Published var destinationPath: String = ""
    @Published var encryptDestination = false

    // Step 3: Transfer options
    @Published var transferMode: TaskType = .transfer
    @Published var startImmediately = true
    @Published var transferName: String = ""

    // Validation
    var canProceedFromStep1: Bool {
        sourceRemote != nil
    }

    var canProceedFromStep2: Bool {
        destinationRemote != nil && destinationRemote?.id != sourceRemote?.id
    }

    var canProceedFromStep3: Bool {
        !transferName.isEmpty
    }

    func reset() {
        currentStep = 0
        sourceRemote = nil
        sourcePath = ""
        encryptSource = false
        destinationRemote = nil
        destinationPath = ""
        encryptDestination = false
        transferMode = .transfer
        startImmediately = true
        transferName = ""
    }

    /// Generate a default transfer name
    func generateDefaultName() {
        if let source = sourceRemote, let dest = destinationRemote {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d"
            let dateStr = dateFormatter.string(from: Date())
            transferName = "\(source.name) to \(dest.name) - \(dateStr)"
        }
    }
}

/// Main wizard view for transfer setup
struct TransferWizardView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var remotesVM: RemotesViewModel
    @EnvironmentObject var tasksVM: TasksViewModel
    @EnvironmentObject var transferState: TransferViewState
    @StateObject private var wizardState = TransferWizardState()

    var onComplete: ((CloudRemote, String, CloudRemote, String, TaskType) -> Void)?

    private let steps = ["Select Source", "Select Destination", "Configure Transfer", "Review"]

    var body: some View {
        WizardView(
            steps: steps,
            currentStep: .init(get: { wizardState.currentStep }, set: { wizardState.currentStep = $0 }),
            onCancel: {
                dismiss()
            },
            onComplete: {
                completeTransfer()
            }
        ) {
            // Content for current step
            switch wizardState.currentStep {
            case 0:
                TransferSourceStep(state: wizardState)
                    .environmentObject(remotesVM)
            case 1:
                TransferDestinationStep(state: wizardState)
                    .environmentObject(remotesVM)
            case 2:
                TransferOptionsStep(state: wizardState)
            case 3:
                TransferReviewStep(state: wizardState)
            default:
                EmptyView()
            }
        }
        .onChange(of: wizardState.currentStep) { _, newStep in
            // Auto-generate name when reaching options step
            if newStep == 2 && wizardState.transferName.isEmpty {
                wizardState.generateDefaultName()
            }
        }
    }

    private func completeTransfer() {
        guard let source = wizardState.sourceRemote,
              let dest = wizardState.destinationRemote else { return }

        if let onComplete = onComplete {
            // Use custom completion handler
            onComplete(source, wizardState.sourcePath, dest, wizardState.destinationPath, wizardState.transferMode)
        } else {
            // Set the transfer state to navigate to the Transfer view with remotes selected
            transferState.sourceRemoteId = source.id
            transferState.destRemoteId = dest.id
            transferState.transferMode = wizardState.transferMode

            // Create a task for tracking
            let _ = tasksVM.createTask(
                name: wizardState.transferName,
                type: wizardState.transferMode,
                sourceRemote: source.rcloneName,
                sourcePath: wizardState.sourcePath,
                destinationRemote: dest.rcloneName,
                destinationPath: wizardState.destinationPath
            )
        }

        dismiss()
    }
}

#Preview {
    TransferWizardView()
        .environmentObject(RemotesViewModel.shared)
        .environmentObject(TasksViewModel.shared)
        .environmentObject(TransferViewState())
}
