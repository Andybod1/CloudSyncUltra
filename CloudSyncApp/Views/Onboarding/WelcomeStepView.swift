//
//  WelcomeStepView.swift
//  CloudSyncApp
//
//  First step of the onboarding flow.
//  Welcomes new users and highlights key features of the app.
//

import SwiftUI

/// Welcome screen shown as the first step of onboarding
struct WelcomeStepView: View {
    @ObservedObject private var onboardingVM = OnboardingViewModel.shared

    @State private var animateIcon = false
    @State private var animateFeatures = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // App Icon and Title
            headerSection

            // Tagline
            taglineSection

            // Key Features
            featuresSection

            Spacer()

            // Get Started Button
            getStartedButton
        }
        .onAppear {
            startAnimations()
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 16) {
            // Animated Cloud Icon
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "6366F1").opacity(0.4),
                                Color(hex: "8B5CF6").opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 40,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(animateIcon ? 1.1 : 0.9)
                    .animation(
                        .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                        value: animateIcon
                    )

                // Main icon background
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: Color(hex: "6366F1").opacity(0.5), radius: 20, y: 10)

                // Cloud icon
                Image(systemName: "cloud.fill")
                    .font(.system(size: 56, weight: .medium))
                    .foregroundColor(.white)
                    .offset(y: animateIcon ? -2 : 2)
                    .animation(
                        .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                        value: animateIcon
                    )
            }

            // App Name
            Text("CloudSync Ultra")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }

    // MARK: - Tagline Section

    private var taglineSection: some View {
        VStack(spacing: 8) {
            Text("Your files, everywhere.")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.9))

            Text("The ultimate cloud backup and sync solution for macOS")
                .font(.body)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Features Section

    private var featuresSection: some View {
        HStack(spacing: 32) {
            ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                FeatureCard(feature: feature)
                    .opacity(animateFeatures ? 1 : 0)
                    .offset(y: animateFeatures ? 0 : 20)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.8)
                        .delay(Double(index) * 0.1 + 0.3),
                        value: animateFeatures
                    )
            }
        }
        .padding(.top, 16)
    }

    // MARK: - Features Data

    private var features: [Feature] {
        [
            Feature(
                icon: "arrow.triangle.2.circlepath",
                title: "Multi-Cloud Sync",
                description: "Connect to 40+ cloud services"
            ),
            Feature(
                icon: "lock.shield.fill",
                title: "End-to-End Encryption",
                description: "Your data, your keys"
            ),
            Feature(
                icon: "bolt.fill",
                title: "Blazing Fast",
                description: "Powered by rclone engine"
            ),
            Feature(
                icon: "calendar.badge.clock",
                title: "Smart Scheduling",
                description: "Automate your backups"
            )
        ]
    }

    // MARK: - Get Started Button

    private var getStartedButton: some View {
        Button {
            onboardingVM.nextStep()
        } label: {
            HStack(spacing: 8) {
                Text("Get Started")
                    .font(.headline)
                    .fontWeight(.semibold)

                Image(systemName: "arrow.right")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 40)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(Capsule())
            .shadow(color: Color(hex: "6366F1").opacity(0.5), radius: 10, y: 5)
        }
        .buttonStyle(.plain)
        .padding(.bottom, 24)
    }

    // MARK: - Animations

    private func startAnimations() {
        withAnimation {
            animateIcon = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation {
                animateFeatures = true
            }
        }
    }
}

// MARK: - Feature Model

private struct Feature {
    let icon: String
    let title: String
    let description: String
}

// MARK: - Feature Card

private struct FeatureCard: View {
    let feature: Feature

    @State private var isHovered = false

    var body: some View {
        VStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 56, height: 56)
                    .shadow(color: Color(hex: "8B5CF6").opacity(0.3), radius: 8, y: 4)

                Image(systemName: feature.icon)
                    .font(.title2)
                    .foregroundColor(Color(hex: "8B5CF6"))
            }

            // Title
            Text(feature.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            // Description
            Text(feature.description)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: 140)
        .padding(.vertical, 20)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(isHovered ? 0.12 : 0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
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

        WelcomeStepView()
    }
    .frame(width: 800, height: 600)
}
