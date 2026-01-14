//
//  CompletionStepView.swift
//  CloudSyncApp
//
//  Final step of onboarding: Celebration and quick tips.
//  Shows success animation and power user tips.
//

import SwiftUI

/// Completion step shown at the end of onboarding
struct CompletionStepView: View {
    @ObservedObject private var onboardingVM = OnboardingViewModel.shared

    @State private var animateCheckmark = false
    @State private var animateContent = false
    @State private var showConfetti = false
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: AppTheme.spacingL) {
            Spacer()

            // Celebration animation
            celebrationSection

            // Success message
            successMessage

            // Quick tips
            quickTipsSection

            Spacer()

            // Open Dashboard button
            openDashboardButton
        }
        .onAppear {
            startAnimations()
        }
        .overlay {
            if showConfetti {
                ConfettiView()
                    .allowsHitTesting(false)
            }
        }
    }

    // MARK: - Celebration Section

    private var celebrationSection: some View {
        ZStack {
            // Outer pulsing ring
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            AppTheme.success.opacity(0.4),
                            AppTheme.success.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 120
                    )
                )
                .frame(width: 240, height: 240)
                .scaleEffect(pulseScale)

            // Inner circle with checkmark
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.success, AppTheme.success.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: AppTheme.success.opacity(0.5), radius: 20, y: 10)

                // Animated checkmark
                Image(systemName: "checkmark")
                    .font(.system(size: 56, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(animateCheckmark ? 1.0 : 0.0)
                    .opacity(animateCheckmark ? 1.0 : 0.0)
            }
        }
    }

    // MARK: - Success Message

    private var successMessage: some View {
        VStack(spacing: AppTheme.spacingM) {
            Text("You're All Set!")
                .font(AppTheme.heroTitleFont)
                .foregroundColor(AppTheme.textOnDark)
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 20)

            if let providerName = onboardingVM.connectedProviderName {
                Text("\(providerName) is ready to sync")
                    .font(AppTheme.titleFont)
                    .foregroundColor(AppTheme.textOnDarkSecondary)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 15)
            } else {
                Text("CloudSync Ultra is ready to use")
                    .font(AppTheme.titleFont)
                    .foregroundColor(AppTheme.textOnDarkSecondary)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 15)
            }
        }
    }

    // MARK: - Quick Tips Section

    private var quickTipsSection: some View {
        VStack(spacing: AppTheme.spacingM) {
            Text("Quick Tips")
                .font(AppTheme.headlineFont)
                .foregroundColor(AppTheme.textOnDark)
                .opacity(animateContent ? 1 : 0)

            HStack(spacing: AppTheme.spacingL) {
                ForEach(Array(powerUserTips.enumerated()), id: \.offset) { index, tip in
                    QuickTipCard(tip: tip)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.8)
                            .delay(Double(index) * 0.1 + 0.5),
                            value: animateContent
                        )
                }
            }
        }
        .padding(.horizontal, AppTheme.contentPaddingH)
    }

    private var powerUserTips: [PowerUserTip] {
        [
            PowerUserTip(
                icon: "keyboard",
                title: "Keyboard Shortcuts",
                description: "Cmd+N for new task"
            ),
            PowerUserTip(
                icon: "calendar.badge.clock",
                title: "Scheduled Syncs",
                description: "Automate your backups"
            ),
            PowerUserTip(
                icon: "lock.shield.fill",
                title: "Encryption",
                description: "Enable end-to-end encryption"
            )
        ]
    }

    // MARK: - Open Dashboard Button

    private var openDashboardButton: some View {
        Button {
            onboardingVM.completeOnboarding()
        } label: {
            HStack(spacing: AppTheme.spacingS) {
                Text("Open Dashboard")
                    .font(.headline)
                    .fontWeight(.semibold)

                Image(systemName: "arrow.right")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .padding(.horizontal, AppTheme.spacingXL * 1.5)
            .padding(.vertical, AppTheme.spacing)
            .background(
                Capsule()
                    .fill(AppTheme.primaryGradient)
            )
            .shadow(color: AppTheme.primaryIndigo.opacity(0.5), radius: 15, y: 8)
        }
        .buttonStyle(.plain)
        .scaleEffect(animateContent ? 1.0 : 0.9)
        .opacity(animateContent ? 1 : 0)
        .padding(.bottom, AppTheme.spacingXL)
    }

    // MARK: - Animations

    private func startAnimations() {
        // Checkmark animation
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.3)) {
            animateCheckmark = true
        }

        // Content animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5)) {
            animateContent = true
        }

        // Confetti
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            showConfetti = true
        }

        // Pulsing animation
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseScale = 1.1
        }
    }
}

// MARK: - Power User Tip Model

private struct PowerUserTip {
    let icon: String
    let title: String
    let description: String
}

// MARK: - Quick Tip Card

private struct QuickTipCard: View {
    let tip: PowerUserTip

    @State private var isHovered = false

    var body: some View {
        VStack(spacing: AppTheme.spacingS) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: AppTheme.iconContainerSmall, height: AppTheme.iconContainerSmall)

                Image(systemName: tip.icon)
                    .font(.body)
                    .foregroundColor(AppTheme.primaryPurple)
            }

            // Title
            Text(tip.title)
                .font(AppTheme.captionFont)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.textOnDark)

            // Description
            Text(tip.description)
                .font(.caption2)
                .foregroundColor(AppTheme.textOnDarkTertiary)
        }
        .frame(width: 130)
        .padding(AppTheme.spacingM)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM)
                .fill(isHovered ? AppTheme.cardBackgroundDarkHover : AppTheme.cardBackgroundDark)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM)
                        .stroke(AppTheme.cardBorderDark, lineWidth: 1)
                )
        )
        .scaleEffect(isHovered ? AppTheme.hoverScale : 1.0)
        .animation(AppTheme.easeInOut, value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Confetti View

private struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(confettiPieces) { piece in
                    ConfettiPieceView(piece: piece)
                }
            }
            .onAppear {
                createConfetti(in: geometry.size)
            }
        }
    }

    private func createConfetti(in size: CGSize) {
        let colors: [Color] = [
            AppTheme.primaryIndigo,
            AppTheme.primaryPurple,
            AppTheme.success,
            .yellow,
            .orange,
            .pink
        ]

        for i in 0..<50 {
            let piece = ConfettiPiece(
                id: i,
                color: colors.randomElement()!,
                x: CGFloat.random(in: 0...size.width),
                y: -20,
                rotation: Double.random(in: 0...360),
                scale: CGFloat.random(in: 0.5...1.0)
            )
            confettiPieces.append(piece)
        }
    }
}

private struct ConfettiPiece: Identifiable {
    let id: Int
    let color: Color
    let x: CGFloat
    let y: CGFloat
    let rotation: Double
    let scale: CGFloat
}

private struct ConfettiPieceView: View {
    let piece: ConfettiPiece

    @State private var offsetY: CGFloat = 0
    @State private var opacity: Double = 1.0
    @State private var rotation: Double = 0

    var body: some View {
        Rectangle()
            .fill(piece.color)
            .frame(width: 8 * piece.scale, height: 8 * piece.scale)
            .rotationEffect(.degrees(rotation))
            .position(x: piece.x, y: piece.y + offsetY)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: Double.random(in: 2...4))) {
                    offsetY = 700
                    opacity = 0
                }
                withAnimation(.linear(duration: Double.random(in: 1...3)).repeatForever(autoreverses: false)) {
                    rotation = piece.rotation + 360
                }
            }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        AppTheme.backgroundGradient
            .ignoresSafeArea()

        CompletionStepView()
    }
    .frame(width: 800, height: 600)
}
