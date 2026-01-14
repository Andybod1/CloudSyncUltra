//
//  OnboardingManager.swift
//  CloudSyncApp
//
//  Manages onboarding state and flow for new users.
//  Persists completion status using @AppStorage/UserDefaults.
//

import SwiftUI
import Combine

/// Represents the different steps in the onboarding flow
enum OnboardingStep: Int, CaseIterable, Identifiable {
    case welcome = 0
    // Future steps can be added here:
    // case cloudSetup = 1
    // case folderSelection = 2
    // case complete = 3

    var id: Int { rawValue }

    /// The title for each step (used for progress indicators)
    var title: String {
        switch self {
        case .welcome: return "Welcome"
        }
    }
}

/// Manages the onboarding flow state and persistence
@MainActor
class OnboardingManager: ObservableObject {

    // MARK: - Singleton

    static let shared = OnboardingManager()

    // MARK: - Published Properties

    /// Whether onboarding has been completed (persisted in UserDefaults)
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false

    /// The current step in the onboarding flow
    @Published var currentStep: OnboardingStep = .welcome

    /// Whether onboarding should be shown
    @Published var shouldShowOnboarding: Bool = false

    /// Animation state for transitions between steps
    @Published var isTransitioning: Bool = false

    // MARK: - Computed Properties

    /// Total number of steps in the onboarding flow
    var totalSteps: Int {
        OnboardingStep.allCases.count
    }

    /// Current step number (1-based for display)
    var currentStepNumber: Int {
        currentStep.rawValue + 1
    }

    /// Progress as a percentage (0.0 to 1.0)
    var progress: Double {
        Double(currentStep.rawValue + 1) / Double(totalSteps)
    }

    /// Whether we're on the last step
    var isLastStep: Bool {
        currentStep.rawValue == totalSteps - 1
    }

    /// Whether we're on the first step
    var isFirstStep: Bool {
        currentStep.rawValue == 0
    }

    // MARK: - Initialization

    private init() {
        // Determine if onboarding should be shown on launch
        shouldShowOnboarding = !hasCompletedOnboarding
    }

    // MARK: - Navigation Methods

    /// Advances to the next step in the onboarding flow
    func nextStep() {
        guard !isLastStep else {
            completeOnboarding()
            return
        }

        withAnimation(.easeInOut(duration: 0.3)) {
            isTransitioning = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            guard let self = self else { return }
            if let nextCase = OnboardingStep(rawValue: self.currentStep.rawValue + 1) {
                self.currentStep = nextCase
            }
            withAnimation(.easeInOut(duration: 0.3)) {
                self.isTransitioning = false
            }
        }
    }

    /// Goes back to the previous step
    func previousStep() {
        guard !isFirstStep else { return }

        withAnimation(.easeInOut(duration: 0.3)) {
            isTransitioning = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            guard let self = self else { return }
            if let prevCase = OnboardingStep(rawValue: self.currentStep.rawValue - 1) {
                self.currentStep = prevCase
            }
            withAnimation(.easeInOut(duration: 0.3)) {
                self.isTransitioning = false
            }
        }
    }

    /// Skips to a specific step
    func goToStep(_ step: OnboardingStep) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = step
        }
    }

    /// Completes the onboarding flow and marks it as finished
    func completeOnboarding() {
        withAnimation(.easeInOut(duration: 0.3)) {
            hasCompletedOnboarding = true
            shouldShowOnboarding = false
        }

        // Post notification for any listeners
        NotificationCenter.default.post(name: .onboardingCompleted, object: nil)
    }

    /// Skips the onboarding entirely
    func skipOnboarding() {
        completeOnboarding()
    }

    // MARK: - Reset Methods (for testing/settings)

    /// Resets the onboarding state to show it again
    func resetOnboarding() {
        hasCompletedOnboarding = false
        currentStep = .welcome
        shouldShowOnboarding = true

        // Post notification for any listeners
        NotificationCenter.default.post(name: .onboardingReset, object: nil)
    }
}

// MARK: - Notification Names

extension Notification.Name {
    /// Posted when onboarding is completed
    static let onboardingCompleted = Notification.Name("onboardingCompleted")

    /// Posted when onboarding is reset
    static let onboardingReset = Notification.Name("onboardingReset")
}
