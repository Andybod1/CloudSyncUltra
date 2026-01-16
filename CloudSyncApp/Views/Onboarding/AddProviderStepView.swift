//
//  AddProviderStepView.swift
//  CloudSyncApp
//
//  Step 1 of onboarding: Guide user to connect their first cloud provider.
//  Shows a grid of popular providers with OAuth/manual config indication.
//

import SwiftUI

/// Provider selection step shown during onboarding
struct AddProviderStepView: View {
    @ObservedObject private var onboardingVM = OnboardingViewModel.shared
    @ObservedObject private var remotesVM = RemotesViewModel.shared

    @State private var selectedProvider: CloudProviderType?
    @State private var showAllProviders = false
    @State private var isConnecting = false
    @State private var connectionError: String?
    @State private var animateContent = false
    @State private var showConnectionWizard = false

    /// Popular providers shown by default
    private let popularProviders: [CloudProviderType] = [
        .googleDrive,
        .dropbox,
        .oneDrive,
        .icloud,
        .protonDrive
    ]

    /// All supported providers (excluding local)
    private var allProviders: [CloudProviderType] {
        CloudProviderType.allCases.filter { $0.isSupported && $0 != .local }
    }

    /// Providers to display based on expansion state
    private var displayedProviders: [CloudProviderType] {
        showAllProviders ? allProviders : popularProviders
    }

    var body: some View {
        VStack(spacing: 0) {
            // Scrollable content area
            ScrollView {
                VStack(spacing: AppTheme.spacingL) {
                    // Header
                    headerSection
                        .padding(.top, AppTheme.spacingL)

                    // Provider Grid
                    providerGrid

                    // Show All / Show Less toggle
                    showAllToggle

                    // Connect Now button - launches full wizard
                    connectNowButton

                    // Error message
                    if let error = connectionError {
                        errorView(error)
                    }
                }
                .padding(.bottom, AppTheme.spacingL)
            }
            .scrollIndicators(.automatic)
            .sheet(isPresented: $showConnectionWizard, onDismiss: handleWizardDismiss) {
                ProviderConnectionWizardView()
                    .environmentObject(remotesVM)
            }

            // Navigation buttons (fixed at bottom)
            navigationButtons
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                animateContent = true
            }
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

                Image(systemName: "cloud.fill")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundColor(.white)
            }
            .opacity(animateContent ? 1 : 0)
            .offset(y: animateContent ? 0 : 20)

            // Title
            Text("Connect Your First Cloud")
                .font(AppTheme.largeTitleFont)
                .foregroundColor(AppTheme.textOnDark)
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 15)

            // Subtitle
            Text("Choose a cloud storage provider to get started")
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.textOnDarkSecondary)
                .multilineTextAlignment(.center)
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 10)
        }
    }

    // MARK: - Provider Grid

    private var providerGrid: some View {
        let columns = Array(repeating: GridItem(.fixed(130), spacing: AppTheme.spacingM), count: min(displayedProviders.count, 5))
        
        return LazyVGrid(columns: columns, spacing: AppTheme.spacingM) {
            ForEach(displayedProviders, id: \.id) { provider in
                OnboardingProviderCard(
                    provider: provider,
                    isSelected: selectedProvider == provider,
                    isOAuth: provider.requiresOAuth
                ) {
                    selectedProvider = provider
                    connectionError = nil
                }
            }
        }
        .padding(.horizontal, AppTheme.spacingXL)
        .opacity(animateContent ? 1 : 0)
        .animation(.easeInOut(duration: 0.3).delay(0.2), value: animateContent)
    }

    // MARK: - Show All Toggle

    private var showAllToggle: some View {
        HStack(spacing: AppTheme.spacingS) {
            Text(showAllProviders ? "Show Less" : "Show All 40+ Providers")
                .font(AppTheme.subheadlineFont)

            Image(systemName: showAllProviders ? "chevron.up" : "chevron.down")
                .font(.caption)
        }
        .foregroundColor(AppTheme.primaryPurple)
        .padding(.vertical, AppTheme.spacingS)
        .padding(.horizontal, AppTheme.spacingM)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showAllProviders.toggle()
            }
        }
        .opacity(animateContent ? 1 : 0)
    }

    // MARK: - Connect Now Button

    private var connectNowButton: some View {
        VStack(spacing: AppTheme.spacingS) {
            // Divider with "or" text
            HStack {
                Rectangle()
                    .fill(AppTheme.cardBorderDark)
                    .frame(height: 1)

                Text("or use our guided wizard")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.textOnDarkTertiary)
                    .padding(.horizontal, AppTheme.spacingM)

                Rectangle()
                    .fill(AppTheme.cardBorderDark)
                    .frame(height: 1)
            }
            .padding(.horizontal, AppTheme.spacingXL)

            // Connect Now button
            Button {
                showConnectionWizard = true
            } label: {
                HStack(spacing: AppTheme.spacingS) {
                    Image(systemName: "wand.and.stars")
                        .font(.headline)

                    Text("Connect a Provider Now")
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

            // Success indicator if already connected
            if onboardingVM.hasConnectedProvider {
                HStack(spacing: AppTheme.spacingXS) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.success)

                    if let providerName = onboardingVM.connectedProviderName {
                        Text("\(providerName) connected!")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.success)
                    } else {
                        Text("Provider connected!")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.success)
                    }
                }
                .padding(.top, AppTheme.spacingXS)
            }
        }
        .opacity(animateContent ? 1 : 0)
        .animation(.easeInOut(duration: 0.3).delay(0.4), value: animateContent)
    }

    // MARK: - Wizard Dismiss Handler

    private func handleWizardDismiss() {
        // Check if a new remote was added during the wizard
        // The wizard adds remotes when completing, so check if we have any configured remotes
        let configuredRemotes = remotesVM.remotes.filter { $0.isConfigured && $0.type != .local }
        if !configuredRemotes.isEmpty && !onboardingVM.hasConnectedProvider {
            // A provider was connected via the wizard
            if let latestRemote = configuredRemotes.last {
                onboardingVM.hasConnectedProvider = true
                onboardingVM.connectedProviderName = latestRemote.name
            }
        }
    }

    // MARK: - Error View

    private func errorView(_ error: String) -> some View {
        HStack(spacing: AppTheme.spacingS) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(AppTheme.warning)

            Text(error)
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.warning)
        }
        .padding(AppTheme.spacingM)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .fill(AppTheme.warning.opacity(0.15))
        )
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

            // Skip button
            Button {
                onboardingVM.skipCurrentStep()
            } label: {
                Text("Skip for now")
                    .font(AppTheme.bodyFont)
                    .foregroundColor(AppTheme.textOnDarkTertiary)
            }
            .buttonStyle(.plain)
            .padding(.trailing, AppTheme.spacing)

            // Connect button
            Button {
                connectProvider()
            } label: {
                HStack(spacing: AppTheme.spacingS) {
                    if isConnecting {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.white)
                    } else {
                        Text("Connect")
                            .font(.headline)
                            .fontWeight(.semibold)

                        Image(systemName: "arrow.right")
                            .font(.headline)
                    }
                }
                .foregroundColor(.white)
                .padding(.horizontal, AppTheme.spacingXL)
                .padding(.vertical, AppTheme.spacing)
                .background(
                    Capsule()
                        .fill(selectedProvider != nil ? AppTheme.primaryGradient : LinearGradient(colors: [Color.gray], startPoint: .leading, endPoint: .trailing))
                )
                .shadow(color: selectedProvider != nil ? AppTheme.primaryIndigo.opacity(0.5) : Color.clear, radius: 10, y: 5)
            }
            .buttonStyle(.plain)
            .disabled(selectedProvider == nil || isConnecting)
        }
        .padding(.horizontal, AppTheme.contentPaddingH)
        .padding(.bottom, AppTheme.spacingL)
    }

    // MARK: - Actions

    private func connectProvider() {
        guard let provider = selectedProvider else { return }

        isConnecting = true
        connectionError = nil

        Task {
            do {
                // Use the provider's display name as the rclone remote name
                let remoteName = provider.displayName.replacingOccurrences(of: " ", with: "")

                // Call the appropriate setup method based on provider type
                switch provider {
                case .googleDrive:
                    try await RcloneManager.shared.setupGoogleDrive(remoteName: remoteName)
                case .dropbox:
                    try await RcloneManager.shared.setupDropbox(remoteName: remoteName)
                case .oneDrive:
                    try await RcloneManager.shared.setupOneDrive(remoteName: remoteName)
                case .box:
                    try await RcloneManager.shared.setupBox(remoteName: remoteName)
                case .pcloud:
                    try await RcloneManager.shared.setupPCloud(remoteName: remoteName)
                default:
                    // For non-OAuth providers or unsupported ones, fall back to the old behavior
                    await MainActor.run {
                        connectionError = "\(provider.displayName) setup is not yet implemented in onboarding. Please use the main app to add this provider."
                        isConnecting = false
                    }
                    return
                }

                // If setup succeeded, create and add the configured remote
                let remote = CloudRemote(
                    name: provider.displayName,
                    type: provider,
                    isConfigured: true,
                    path: "",
                    customRcloneName: remoteName
                )

                await MainActor.run {
                    _ = remotesVM.addRemote(remote)
                    isConnecting = false
                    onboardingVM.providerConnected(name: provider.displayName)
                }

            } catch {
                await MainActor.run {
                    isConnecting = false
                    connectionError = "Failed to connect \(provider.displayName): \(error.localizedDescription)"
                }
            }
        }
    }
}

// MARK: - Provider Card for Onboarding

private struct OnboardingProviderCard: View {
    let provider: CloudProviderType
    let isSelected: Bool
    let isOAuth: Bool
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        VStack(spacing: AppTheme.spacingS) {
            // Icon
            ZStack {
                Circle()
                    .fill(isSelected ? provider.brandColor.opacity(0.3) : Color.white.opacity(0.1))
                    .frame(width: AppTheme.iconContainerMedium, height: AppTheme.iconContainerMedium)
                    .shadow(color: isSelected ? provider.brandColor.opacity(0.4) : AppTheme.primaryPurple.opacity(0.2), radius: 8, y: 4)

                Image(systemName: provider.iconName)
                    .font(.title2)
                    .foregroundColor(isSelected ? provider.brandColor : AppTheme.primaryPurple)
            }

            // Provider name
            Text(provider.displayName)
                .font(AppTheme.captionFont)
                .fontWeight(.medium)
                .foregroundColor(AppTheme.textOnDark)
                .lineLimit(1)

            // OAuth indicator
            if isOAuth {
                Text("OAuth")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(AppTheme.textOnDarkTertiary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                    )
            }
        }
        .frame(width: 120, height: 110)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusL)
                .fill(isSelected ? provider.brandColor.opacity(0.15) : AppTheme.cardBackgroundDark)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusL)
                        .stroke(isSelected ? provider.brandColor : AppTheme.cardBorderDark, lineWidth: isSelected ? 2 : 1)
                )
        )
        .contentShape(Rectangle())
        .scaleEffect(isHovered && !isSelected ? AppTheme.hoverScale : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
        .onTapGesture {
            action()
        }
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        AppTheme.backgroundGradient
            .ignoresSafeArea()

        AddProviderStepView()
    }
    .frame(width: 800, height: 600)
}
