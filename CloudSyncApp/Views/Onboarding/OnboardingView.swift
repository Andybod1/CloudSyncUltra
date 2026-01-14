//
//  OnboardingView.swift
//  CloudSyncApp
//
//  Container view for the onboarding flow.
//  Displays the current onboarding step with navigation controls.
//

import SwiftUI

/// Main container view for the onboarding experience
struct OnboardingView: View {
    @ObservedObject private var onboardingManager = OnboardingManager.shared

    var body: some View {
        ZStack {
            // Background gradient
            backgroundGradient

            VStack(spacing: 0) {
                // Skip button (top-right)
                skipButton

                // Main content area
                stepContent
                    .opacity(onboardingManager.isTransitioning ? 0.5 : 1.0)

                // Progress indicator (at bottom)
                if onboardingManager.totalSteps > 1 {
                    progressIndicator
                }
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 24)
        }
        .frame(minWidth: 700, minHeight: 500)
        .frame(idealWidth: 800, idealHeight: 600)
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(hex: "1a1a2e"),
                Color(hex: "16213e"),
                Color(hex: "0f3460")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    // MARK: - Skip Button

    private var skipButton: some View {
        HStack {
            Spacer()

            Button {
                onboardingManager.skipOnboarding()
            } label: {
                Text("Skip")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
        }
    }

    // MARK: - Step Content

    @ViewBuilder
    private var stepContent: some View {
        switch onboardingManager.currentStep {
        case .welcome:
            WelcomeStepView()
        }
    }

    // MARK: - Progress Indicator

    private var progressIndicator: some View {
        VStack(spacing: 12) {
            // Step dots
            HStack(spacing: 8) {
                ForEach(OnboardingStep.allCases) { step in
                    Circle()
                        .fill(step == onboardingManager.currentStep
                              ? Color.white
                              : Color.white.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut(duration: 0.2), value: onboardingManager.currentStep)
                }
            }

            // Step label
            Text("Step \(onboardingManager.currentStepNumber) of \(onboardingManager.totalSteps)")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.bottom, 16)
    }
}

// MARK: - Preview

#Preview {
    OnboardingView()
        .frame(width: 800, height: 600)
}
