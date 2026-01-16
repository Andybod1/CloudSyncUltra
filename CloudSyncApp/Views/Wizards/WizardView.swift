//
//  WizardView.swift
//  CloudSyncApp
//
//  Generic wizard container for multi-step flows
//

import SwiftUI

/// Generic wizard container that manages navigation between steps
struct WizardView<Content: View>: View {
    let steps: [String]
    @Binding var currentStep: Int
    let onCancel: () -> Void
    let onComplete: () -> Void
    @ViewBuilder let content: () -> Content

    // Computed properties for navigation
    private var canGoBack: Bool {
        currentStep > 0
    }

    private var canGoNext: Bool {
        currentStep < steps.count - 1
    }

    private var isLastStep: Bool {
        currentStep == steps.count - 1
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with title
            HStack {
                Text("Setup Wizard")
                    .font(.headline)
                Spacer()
                Button {
                    onCancel()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            // Progress indicator
            WizardProgressView(
                steps: steps,
                currentStep: currentStep
            )
            .padding(.horizontal, AppTheme.spacing)
            .padding(.bottom, AppTheme.spacing)

            Divider()

            // Content area - constrained to available space
            content()
                .frame(maxWidth: .infinity)
                .layoutPriority(1)

            Spacer(minLength: 0)

            Divider()

            // Navigation buttons
            HStack {
                Button("Cancel") {
                    onCancel()
                }
                .keyboardShortcut(.escape)

                Spacer()

                if canGoBack {
                    Button("Back") {
                        withAnimation {
                            currentStep -= 1
                        }
                    }
                }

                if isLastStep {
                    Button("Complete") {
                        onComplete()
                    }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.return)
                } else {
                    Button("Next") {
                        withAnimation {
                            currentStep += 1
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.return)
                }
            }
            .padding()
        }
        .frame(width: 700, height: 600)
    }
}

/// Navigation control for wizard steps
struct WizardNavigationControls: View {
    @Binding var currentStep: Int
    let totalSteps: Int
    let canProceed: Bool
    let onNext: () -> Void
    let onBack: () -> Void
    let onComplete: () -> Void

    private var isLastStep: Bool {
        currentStep == totalSteps - 1
    }

    var body: some View {
        HStack {
            if currentStep > 0 {
                Button("Back") {
                    onBack()
                }
            }

            Spacer()

            if isLastStep {
                Button("Complete") {
                    onComplete()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canProceed)
            } else {
                Button("Next") {
                    onNext()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canProceed)
            }
        }
    }
}

#Preview {
    @State var currentStep = 0

    return WizardView(
        steps: ["Choose Provider", "Configure", "Test", "Success"],
        currentStep: $currentStep,
        onCancel: { },
        onComplete: { }
    ) {
        VStack {
            Spacer()
            Text("Step \(currentStep + 1)")
                .font(.largeTitle)
            Spacer()
        }
    }
}