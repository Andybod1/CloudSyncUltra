//
//  FirstSyncStepView.swift
//  CloudSyncApp
//
//  Step 2 of onboarding: Guide user through their first sync.
//  Explains sync vs copy and shows the dual-pane interface concept.
//

import SwiftUI

/// First sync walkthrough step shown during onboarding
struct FirstSyncStepView: View {
    @ObservedObject private var onboardingVM = OnboardingViewModel.shared
    @ObservedObject private var remotesVM = RemotesViewModel.shared
    @ObservedObject private var tasksVM = TasksViewModel.shared
    @StateObject private var transferState = TransferViewState()

    @State private var animateContent = false
    @State private var selectedConcept: SyncConcept? = nil
    @State private var showDualPane = false
    @State private var showTransferWizard = false

    var body: some View {
        VStack(spacing: AppTheme.spacingL) {
            Spacer()

            // Header
            headerSection

            // Sync concepts explanation
            conceptsSection

            // Dual-pane preview (animated)
            if showDualPane {
                dualPanePreview
            }

            // Try Sync Now button
            if showDualPane {
                trySyncNowButton
            }

            Spacer()

            // Navigation buttons
            navigationButtons
        }
        .onAppear {
            startAnimations()
        }
        .sheet(isPresented: $showTransferWizard, onDismiss: handleTransferWizardDismiss) {
            TransferWizardView(onComplete: handleTransferComplete)
                .environmentObject(remotesVM)
                .environmentObject(tasksVM)
                .environmentObject(transferState)
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: AppTheme.spacingM) {
            // Icon
            ZStack {
                Circle()
                    .fill(AppTheme.primaryGradient)
                    .frame(width: 80, height: 80)
                    .shadow(color: AppTheme.primaryIndigo.opacity(0.5), radius: 15, y: 8)

                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundColor(.white)
            }
            .opacity(animateContent ? 1 : 0)
            .offset(y: animateContent ? 0 : 20)

            // Title
            Text("Let's Sync Some Files!")
                .font(AppTheme.largeTitleFont)
                .foregroundColor(AppTheme.textOnDark)
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 15)

            // Subtitle
            Text("Understanding how CloudSync Ultra keeps your files in harmony")
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.textOnDarkSecondary)
                .multilineTextAlignment(.center)
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 10)
        }
    }

    // MARK: - Concepts Section

    private var conceptsSection: some View {
        HStack(spacing: AppTheme.spacingL) {
            ForEach(Array(SyncConcept.allCases.enumerated()), id: \.element) { index, concept in
                SyncConceptCard(
                    concept: concept,
                    isSelected: selectedConcept == concept
                ) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        selectedConcept = concept
                    }
                }
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 20)
                .animation(
                    .spring(response: 0.6, dampingFraction: 0.8)
                    .delay(Double(index) * 0.1 + 0.3),
                    value: animateContent
                )
            }
        }
        .padding(.horizontal, AppTheme.contentPaddingH)
    }

    // MARK: - Dual Pane Preview

    private var dualPanePreview: some View {
        VStack(spacing: AppTheme.spacingM) {
            Text("The Dual-Pane Interface")
                .font(AppTheme.headlineFont)
                .foregroundColor(AppTheme.textOnDark)

            HStack(spacing: AppTheme.spacingM) {
                // Source pane mockup
                PaneMockup(
                    title: "Source",
                    icon: "folder.fill",
                    files: ["Documents", "Photos", "Projects"],
                    color: AppTheme.primaryIndigo
                )

                // Arrow indicator
                VStack(spacing: AppTheme.spacingS) {
                    Image(systemName: "arrow.right")
                        .font(.title2)
                        .foregroundColor(AppTheme.primaryPurple)

                    Text("Sync")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.textOnDarkSecondary)
                }

                // Destination pane mockup
                PaneMockup(
                    title: "Destination",
                    icon: "cloud.fill",
                    files: ["Documents", "Photos", "Projects"],
                    color: AppTheme.primaryPurple
                )
            }
            .padding(AppTheme.spacingL)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusL)
                    .fill(AppTheme.cardBackgroundDark)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusL)
                            .stroke(AppTheme.cardBorderDark, lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal, AppTheme.contentPaddingH)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    // MARK: - Try Sync Now Button

    private var trySyncNowButton: some View {
        VStack(spacing: AppTheme.spacingS) {
            // Try Sync Now button
            Button {
                showTransferWizard = true
            } label: {
                HStack(spacing: AppTheme.spacingS) {
                    Image(systemName: "play.circle.fill")
                        .font(.headline)

                    Text("Try a Sync Now")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, AppTheme.spacingXL)
                .padding(.vertical, AppTheme.spacing)
                .background(
                    Capsule()
                        .fill(AppTheme.success)
                )
                .shadow(color: AppTheme.success.opacity(0.4), radius: 10, y: 5)
            }
            .buttonStyle(.plain)
            .disabled(!hasConfiguredRemotes)
            .opacity(hasConfiguredRemotes ? 1.0 : 0.5)

            // Help text or success indicator
            if onboardingVM.hasCompletedFirstSync {
                HStack(spacing: AppTheme.spacingXS) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.success)

                    Text("First sync completed!")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.success)
                }
            } else if !hasConfiguredRemotes {
                HStack(spacing: AppTheme.spacingXS) {
                    Image(systemName: "info.circle")
                        .foregroundColor(AppTheme.textOnDarkTertiary)

                    Text("Connect a provider first to try syncing")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.textOnDarkTertiary)
                }
            } else {
                Text("Start a transfer between your connected providers")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.textOnDarkSecondary)
            }
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    /// Check if there are configured remotes available for syncing
    private var hasConfiguredRemotes: Bool {
        remotesVM.remotes.contains { $0.isConfigured }
    }

    // MARK: - Transfer Wizard Handlers

    private func handleTransferComplete(
        source: CloudRemote,
        sourcePath: String,
        destination: CloudRemote,
        destinationPath: String,
        transferMode: TaskType
    ) {
        // Mark first sync as completed
        onboardingVM.firstSyncCompleted()
    }

    private func handleTransferWizardDismiss() {
        // Check if the user completed a transfer (by checking if tasks were created)
        // The transfer wizard creates a task when completed
        if tasksVM.tasks.count > 0 && !onboardingVM.hasCompletedFirstSync {
            onboardingVM.firstSyncCompleted()
        }
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack(spacing: AppTheme.spacing) {
            // Back button
            Button {
                onboardingVM.previousStep()
            } label: {
                HStack(spacing: AppTheme.spacingS) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.textOnDarkSecondary)
                .padding(.horizontal, AppTheme.spacingL)
                .padding(.vertical, AppTheme.spacingM)
            }
            .buttonStyle(.plain)

            Spacer()

            // Continue button
            Button {
                onboardingVM.nextStep()
            } label: {
                HStack(spacing: AppTheme.spacingS) {
                    Text("Continue")
                        .font(.headline)
                        .fontWeight(.semibold)

                    Image(systemName: "arrow.right")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding(.horizontal, AppTheme.spacingXL)
                .padding(.vertical, AppTheme.spacing)
                .background(
                    Capsule()
                        .fill(AppTheme.primaryGradient)
                )
                .shadow(color: AppTheme.primaryIndigo.opacity(0.5), radius: 10, y: 5)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, AppTheme.contentPaddingH)
        .padding(.bottom, AppTheme.spacingL)
    }

    // MARK: - Animations

    private func startAnimations() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            animateContent = true
        }

        // Show dual pane after concepts are visible
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showDualPane = true
            }
        }
    }
}

// MARK: - Sync Concept

private enum SyncConcept: CaseIterable {
    case sync
    case copy
    case move

    var title: String {
        switch self {
        case .sync: return "Sync"
        case .copy: return "Copy"
        case .move: return "Move"
        }
    }

    var description: String {
        switch self {
        case .sync: return "Keep files identical in both locations"
        case .copy: return "Duplicate files to another location"
        case .move: return "Transfer files and remove from source"
        }
    }

    var icon: String {
        switch self {
        case .sync: return "arrow.triangle.2.circlepath"
        case .copy: return "doc.on.doc"
        case .move: return "arrow.right.doc.on.clipboard"
        }
    }

    var color: Color {
        switch self {
        case .sync: return AppTheme.primaryIndigo
        case .copy: return AppTheme.success
        case .move: return AppTheme.warning
        }
    }
}

// MARK: - Sync Concept Card

private struct SyncConceptCard: View {
    let concept: SyncConcept
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.spacingM) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? concept.color.opacity(0.3) : Color.white.opacity(0.1))
                        .frame(width: AppTheme.iconContainerMedium, height: AppTheme.iconContainerMedium)
                        .shadow(color: isSelected ? concept.color.opacity(0.4) : AppTheme.primaryPurple.opacity(0.2), radius: 8, y: 4)

                    Image(systemName: concept.icon)
                        .font(.title2)
                        .foregroundColor(isSelected ? concept.color : AppTheme.primaryPurple)
                }

                // Title
                Text(concept.title)
                    .font(AppTheme.headlineFont)
                    .foregroundColor(AppTheme.textOnDark)

                // Description
                Text(concept.description)
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.textOnDarkSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(width: 160, height: 150)
            .padding(AppTheme.spacing)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusL)
                    .fill(isSelected ? concept.color.opacity(0.1) : AppTheme.cardBackgroundDark)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusL)
                            .stroke(isSelected ? concept.color : AppTheme.cardBorderDark, lineWidth: isSelected ? 2 : 1)
                    )
            )
            .scaleEffect(isHovered && !isSelected ? AppTheme.hoverScale : 1.0)
            .animation(AppTheme.easeInOut, value: isHovered)
            .animation(AppTheme.easeInOut, value: isSelected)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Pane Mockup

private struct PaneMockup: View {
    let title: String
    let icon: String
    let files: [String]
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
            // Header
            HStack(spacing: AppTheme.spacingS) {
                Image(systemName: icon)
                    .foregroundColor(color)

                Text(title)
                    .font(AppTheme.subheadlineFont)
                    .foregroundColor(AppTheme.textOnDark)
            }
            .padding(.bottom, AppTheme.spacingXS)

            // File list mockup
            ForEach(files, id: \.self) { file in
                HStack(spacing: AppTheme.spacingS) {
                    Image(systemName: "folder.fill")
                        .font(.caption)
                        .foregroundColor(AppTheme.textOnDarkTertiary)

                    Text(file)
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.textOnDarkSecondary)

                    Spacer()
                }
                .padding(.vertical, AppTheme.spacingXS)
            }
        }
        .frame(width: 160)
        .padding(AppTheme.spacingM)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .fill(Color.white.opacity(0.05))
        )
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        AppTheme.backgroundGradient
            .ignoresSafeArea()

        FirstSyncStepView()
    }
    .frame(width: 800, height: 600)
}
