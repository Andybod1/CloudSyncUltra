//
//  ButtonStyles.swift
//  CloudSyncApp
//
//  Shared button styles matching the onboarding experience.
//  Provides consistent button appearance across the entire app.
//

import SwiftUI

// MARK: - Primary Button Style

/// Primary action button with gradient background (matches onboarding "Get Started")
struct PrimaryButtonStyle: ButtonStyle {
    var isCompact: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(isCompact ? .subheadline.weight(.semibold) : .headline.weight(.semibold))
            .foregroundColor(.white)
            .padding(.horizontal, isCompact ? AppTheme.spacing : AppTheme.spacingL)
            .padding(.vertical, isCompact ? AppTheme.spacingS : AppTheme.spacingM)
            .background(AppTheme.primaryGradientHorizontal)
            .clipShape(Capsule())
            .shadow(
                color: AppTheme.iconGlow(color: AppTheme.primaryIndigo),
                radius: configuration.isPressed ? 5 : AppTheme.iconGlowRadius,
                y: configuration.isPressed ? 2 : 5
            )
            .scaleEffect(configuration.isPressed ? AppTheme.pressScale : 1.0)
            .animation(AppTheme.fast, value: configuration.isPressed)
    }
}

/// Pill-shaped primary button (alternative style)
struct PrimaryPillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(AppTheme.primaryGradientHorizontal)
            .clipShape(Capsule())
            .shadow(
                color: AppTheme.iconGlow(color: AppTheme.primaryIndigo),
                radius: 10,
                y: 5
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Secondary Button Style

/// Secondary button with border (for less prominent actions)
struct SecondaryButtonStyle: ButtonStyle {
    var color: Color = AppTheme.primaryIndigo

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(color)
            .padding(.horizontal, AppTheme.spacing)
            .padding(.vertical, AppTheme.spacingS)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM)
                    .fill(configuration.isPressed ? color.opacity(0.1) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM)
                    .stroke(color.opacity(0.5), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? AppTheme.pressScale : 1.0)
            .animation(AppTheme.fast, value: configuration.isPressed)
    }
}

// MARK: - Tertiary Button Style

/// Tertiary button (text-only with subtle hover)
struct TertiaryButtonStyle: ButtonStyle {
    var color: Color = .accentColor

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(color)
            .padding(.horizontal, AppTheme.spacingS)
            .padding(.vertical, AppTheme.spacingXS)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusS)
                    .fill(configuration.isPressed ? color.opacity(0.1) : Color.clear)
            )
            .scaleEffect(configuration.isPressed ? AppTheme.pressScale : 1.0)
            .animation(AppTheme.fast, value: configuration.isPressed)
    }
}

// MARK: - Icon Button Style

/// Circular icon button (matches onboarding icon styling)
struct IconButtonStyle: ButtonStyle {
    var color: Color = AppTheme.primaryPurple
    var size: CGFloat = AppTheme.iconContainerMedium

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Circle()
                .fill(color.opacity(configuration.isPressed ? 0.2 : 0.1))
                .frame(width: size, height: size)

            configuration.label
                .font(.title2)
                .foregroundColor(color)
        }
        .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
        .animation(AppTheme.fast, value: configuration.isPressed)
    }
}

// MARK: - Card Action Button Style

/// Button style for actions within cards
struct CardActionButtonStyle: ButtonStyle {
    var color: Color = .accentColor

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption.weight(.medium))
            .foregroundColor(color)
            .padding(.horizontal, AppTheme.spacingS)
            .padding(.vertical, AppTheme.spacingXS)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusS)
                    .fill(color.opacity(configuration.isPressed ? 0.15 : 0.1))
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(AppTheme.fast, value: configuration.isPressed)
    }
}

// MARK: - Danger Button Style

/// Danger/destructive action button
struct DangerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, AppTheme.spacing)
            .padding(.vertical, AppTheme.spacingS)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM)
                    .fill(configuration.isPressed ? AppTheme.error.opacity(0.8) : AppTheme.error)
            )
            .scaleEffect(configuration.isPressed ? AppTheme.pressScale : 1.0)
            .animation(AppTheme.fast, value: configuration.isPressed)
    }
}

// MARK: - Ghost Button Style

/// Ghost button (minimal styling, for toolbars)
struct GhostButtonStyle: ButtonStyle {
    @State private var isHovered = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? .accentColor : .secondary)
            .padding(AppTheme.spacingS)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusS)
                    .fill(configuration.isPressed ? Color.accentColor.opacity(0.1) : Color.clear)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(AppTheme.fast, value: configuration.isPressed)
    }
}

// MARK: - Navigation Button Style

/// Navigation/link button style
struct NavigationButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: AppTheme.spacingS) {
            configuration.label
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .foregroundColor(.accentColor)
        .opacity(configuration.isPressed ? 0.7 : 1.0)
        .animation(AppTheme.fast, value: configuration.isPressed)
    }
}

// MARK: - Sidebar Button Style

/// Sidebar navigation item style
struct SidebarButtonStyle: ButtonStyle {
    var isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .foregroundColor(isSelected ? .accentColor : .primary)
            .padding(.horizontal, AppTheme.spacingS)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusS)
                    .fill(
                        isSelected
                            ? Color.accentColor.opacity(0.15)
                            : (configuration.isPressed ? Color.primary.opacity(0.05) : Color.clear)
                    )
            )
            .animation(AppTheme.fast, value: configuration.isPressed)
    }
}

// MARK: - Quick Action Button Style

/// Style for dashboard quick action buttons (matches QuickActionButton design)
struct QuickActionButtonStyle: ButtonStyle {
    var color: Color = .blue
    @State private var isHovered = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .fill(configuration.isPressed || isHovered
                          ? Color(NSColor.selectedControlColor).opacity(0.3)
                          : AppTheme.controlBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(
                        configuration.isPressed || isHovered ? color.opacity(0.5) : Color.clear,
                        lineWidth: 1
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(AppTheme.easeInOut, value: configuration.isPressed)
            .onHover { hovering in
                withAnimation(AppTheme.easeInOut) {
                    isHovered = hovering
                }
            }
    }
}

// MARK: - View Extension

extension View {
    /// Apply primary button style
    func primaryButtonStyle(compact: Bool = false) -> some View {
        self.buttonStyle(PrimaryButtonStyle(isCompact: compact))
    }

    /// Apply secondary button style
    func secondaryButtonStyle(color: Color = AppTheme.primaryIndigo) -> some View {
        self.buttonStyle(SecondaryButtonStyle(color: color))
    }

    /// Apply tertiary button style
    func tertiaryButtonStyle(color: Color = .accentColor) -> some View {
        self.buttonStyle(TertiaryButtonStyle(color: color))
    }

    /// Apply icon button style
    func iconButtonStyle(color: Color = AppTheme.primaryPurple, size: CGFloat = AppTheme.iconContainerMedium) -> some View {
        self.buttonStyle(IconButtonStyle(color: color, size: size))
    }
}

// MARK: - Preview

#Preview("Button Styles") {
    VStack(spacing: 24) {
        // Primary
        Button("Get Started") {}
            .buttonStyle(PrimaryButtonStyle())

        // Primary Compact
        Button("Compact") {}
            .buttonStyle(PrimaryButtonStyle(isCompact: true))

        // Secondary
        Button("Learn More") {}
            .buttonStyle(SecondaryButtonStyle())

        // Tertiary
        Button("Skip") {}
            .buttonStyle(TertiaryButtonStyle())

        // Icon
        Button {} label: {
            Image(systemName: "plus")
        }
        .buttonStyle(IconButtonStyle())

        // Danger
        Button("Delete") {}
            .buttonStyle(DangerButtonStyle())

        // Card Action
        Button("View Details") {}
            .buttonStyle(CardActionButtonStyle())
    }
    .padding(40)
    .background(Color(NSColor.windowBackgroundColor))
}
