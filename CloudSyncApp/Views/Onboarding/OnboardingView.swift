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
    @ObservedObject private var onboardingVM = OnboardingViewModel.shared

    var body: some View {
        ZStack {
            // Background gradient
            backgroundGradient

            VStack(spacing: 0) {
                // Skip button (top-right) - hidden on completion step
                if onboardingVM.currentStep != .completion {
                    skipButton
                } else {
                    Spacer()
                        .frame(height: 40)
                }

                // Main content area
                stepContent
                    .opacity(onboardingVM.isTransitioning ? 0.5 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: onboardingVM.isTransitioning)

                // Progress indicator (at bottom) - hidden on completion step
                if onboardingVM.currentStep != .completion {
                    progressIndicator
                }
            }
            .padding(.horizontal, AppTheme.contentPaddingH)
            .padding(.vertical, AppTheme.contentPaddingV)
        }
        .frame(minWidth: 700, minHeight: 500)
        .frame(idealWidth: 800, idealHeight: 600)
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        AppTheme.backgroundGradient
            .ignoresSafeArea()
    }

    // MARK: - Skip Button

    private var skipButton: some View {
        HStack {
            Spacer()

            Button {
                onboardingVM.skipOnboarding()
            } label: {
                Text("Skip")
                    .font(AppTheme.subheadlineFont)
                    .foregroundColor(AppTheme.textOnDarkSecondary)
            }
            .buttonStyle(.plain)
            .padding(.top, AppTheme.spacingS)
        }
    }

    // MARK: - Step Content

    @ViewBuilder
    private var stepContent: some View {
        switch onboardingVM.currentStep {
        case .welcome:
            WelcomeStepView()
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

        case .addProvider:
            AddProviderStepView()
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

        case .firstSync:
            FirstSyncStepView()
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

        case .completion:
            CompletionStepView()
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
        }
    }

    // MARK: - Progress Indicator

    private var progressIndicator: some View {
        VStack(spacing: AppTheme.spacingM) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusS)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 4)

                    // Progress fill
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusS)
                        .fill(AppTheme.primaryGradient)
                        .frame(width: geometry.size.width * onboardingVM.progress, height: 4)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: onboardingVM.progress)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, AppTheme.spacingXL)

            // Step dots with labels (clickable)
            HStack(spacing: 0) {
                ForEach(OnboardingStep.allCases) { step in
                    VStack(spacing: AppTheme.spacingXS) {
                        // Dot
                        ZStack {
                            Circle()
                                .fill(step.rawValue <= onboardingVM.currentStep.rawValue
                                      ? Color.white
                                      : Color.white.opacity(0.3))
                                .frame(width: 10, height: 10)

                            if step == onboardingVM.currentStep {
                                Circle()
                                    .stroke(Color.white.opacity(0.5), lineWidth: 2)
                                    .frame(width: 18, height: 18)
                            }
                        }
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: onboardingVM.currentStep)

                        // Label
                        Text(step.title)
                            .font(AppTheme.caption2Font)
                            .foregroundColor(step == onboardingVM.currentStep
                                             ? AppTheme.textOnDark
                                             : AppTheme.textOnDarkTertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onboardingVM.goToStep(step)
                    }
                    .accessibilityLabel("Go to \(step.title)")
                    .accessibilityHint("Step \(step.rawValue + 1) of \(OnboardingStep.allCases.count)")
                }
            }

            // Step counter
            Text("Step \(onboardingVM.currentStepNumber) of \(onboardingVM.totalSteps)")
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.textOnDarkTertiary)
        }
        .padding(.bottom, AppTheme.spacing)
    }
}

// MARK: - Preview

#Preview {
    OnboardingView()
        .frame(width: 800, height: 600)
}
