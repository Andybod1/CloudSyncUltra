//
//  AppTheme.swift
//  CloudSyncApp
//
//  Centralized design system matching the onboarding experience.
//  All design tokens extracted from OnboardingView and WelcomeStepView.
//

import SwiftUI

// MARK: - App Theme

/// Centralized theme constants for visual consistency across the app
struct AppTheme {

    // MARK: - Primary Colors (from Onboarding)

    /// Primary indigo color from onboarding gradient
    static let primaryIndigo = Color(hex: "6366F1")

    /// Secondary purple color from onboarding gradient
    static let primaryPurple = Color(hex: "8B5CF6")

    /// Primary gradient used throughout the app (matches onboarding buttons/icons)
    static let primaryGradient = LinearGradient(
        colors: [primaryIndigo, primaryPurple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Horizontal primary gradient (for buttons)
    static let primaryGradientHorizontal = LinearGradient(
        colors: [primaryIndigo, primaryPurple],
        startPoint: .leading,
        endPoint: .trailing
    )

    // MARK: - Background Colors (from Onboarding)

    /// Dark background gradient colors (for immersive screens)
    static let backgroundDark1 = Color(hex: "1a1a2e")
    static let backgroundDark2 = Color(hex: "16213e")
    static let backgroundDark3 = Color(hex: "0f3460")

    /// Full dark background gradient (onboarding style)
    static let backgroundGradient = LinearGradient(
        colors: [backgroundDark1, backgroundDark2, backgroundDark3],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Light Mode Colors (for main app views)

    /// Standard window background
    static let windowBackground = Color(NSColor.windowBackgroundColor)

    /// Control/card background
    static let controlBackground = Color(NSColor.controlBackgroundColor)

    /// Subtle background for sections
    static let sectionBackground = Color(NSColor.underPageBackgroundColor)

    // MARK: - Card Styling (from Onboarding FeatureCard)

    /// Card background for dark mode (glass effect)
    static let cardBackgroundDark = Color.white.opacity(0.08)

    /// Card background on hover (dark mode)
    static let cardBackgroundDarkHover = Color.white.opacity(0.12)

    /// Card border (dark mode)
    static let cardBorderDark = Color.white.opacity(0.1)

    /// Card background for light mode
    static let cardBackgroundLight = Color(NSColor.controlBackgroundColor)

    /// Card border for light mode
    static let cardBorderLight = Color.primary.opacity(0.1)

    // MARK: - Accent Colors for Features/Icons

    /// Feature icon background opacity
    static let iconBackgroundOpacity: Double = 0.15

    /// Icon container size (small)
    static let iconContainerSmall: CGFloat = 44

    /// Icon container size (medium, from feature cards)
    static let iconContainerMedium: CGFloat = 56

    /// Icon container size (large, from welcome header)
    static let iconContainerLarge: CGFloat = 120

    // MARK: - Status Colors

    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    static let info = Color.blue

    // Aliases for compatibility
    static let successColor = success
    static let warningColor = warning
    static let errorColor = error
    static let infoColor = info
    static let accentColor = Color.accentColor

    // MARK: - Text Colors

    /// Primary text on dark background
    static let textOnDark = Color.white

    /// Secondary text on dark background
    static let textOnDarkSecondary = Color.white.opacity(0.7)

    /// Tertiary text on dark background
    static let textOnDarkTertiary = Color.white.opacity(0.6)

    /// Primary text (standard)
    static let textPrimary = Color.primary

    /// Secondary text (standard)
    static let textSecondary = Color.secondary

    // MARK: - Typography (from Onboarding)

    /// Hero title font (app name on onboarding)
    static let heroTitleFont = Font.system(size: 40, weight: .bold, design: .rounded)

    /// Large title font
    static let largeTitleFont = Font.largeTitle.weight(.bold)

    /// Title font
    static let titleFont = Font.title2.weight(.medium)

    /// Title2 font (alias)
    static let title2Font = Font.title2

    /// Headline font
    static let headlineFont = Font.headline.weight(.semibold)

    /// Subheadline font
    static let subheadlineFont = Font.subheadline.weight(.semibold)

    /// Body font
    static let bodyFont = Font.body

    /// Caption font
    static let captionFont = Font.caption

    /// Small caption font
    static let caption2Font = Font.caption2

    // MARK: - Spacing (from Onboarding)

    /// Extra small spacing
    static let spacingXS: CGFloat = 4

    /// Small spacing
    static let spacingS: CGFloat = 8

    /// Medium spacing (between elements)
    static let spacingM: CGFloat = 12

    /// Standard spacing
    static let spacing: CGFloat = 16

    /// Large spacing (between sections)
    static let spacingL: CGFloat = 24

    /// Extra large spacing (major sections)
    static let spacingXL: CGFloat = 32

    /// Content horizontal padding (from onboarding)
    static let contentPaddingH: CGFloat = 40

    /// Content vertical padding
    static let contentPaddingV: CGFloat = 24

    // MARK: - Corner Radius (from Onboarding)

    /// Small corner radius
    static let cornerRadiusS: CGFloat = 6

    /// Standard corner radius
    static let cornerRadius: CGFloat = 10

    /// Medium corner radius
    static let cornerRadiusM: CGFloat = 12

    /// Large corner radius (cards from onboarding)
    static let cornerRadiusL: CGFloat = 16

    /// Extra large corner radius
    static let cornerRadiusXL: CGFloat = 20

    // MARK: - Shadows

    /// Card shadow (from onboarding)
    static let cardShadowColor = Color.black.opacity(0.1)
    static let cardShadowRadius: CGFloat = 8
    static let cardShadowY: CGFloat = 4

    /// Icon glow shadow (from onboarding)
    static func iconGlow(color: Color) -> Color {
        color.opacity(0.5)
    }
    static let iconGlowRadius: CGFloat = 20
    static let iconGlowY: CGFloat = 10

    // MARK: - Animation (from Onboarding)

    /// Standard easing animation
    static let easeInOut = Animation.easeInOut(duration: 0.2)

    /// Fast animation for interactions
    static let fast = Animation.easeInOut(duration: 0.1)

    /// Spring animation for elements
    static let spring = Animation.spring(response: 0.6, dampingFraction: 0.8)

    /// Hover scale effect
    static let hoverScale: CGFloat = 1.02

    /// Press scale effect
    static let pressScale: CGFloat = 0.98

    // MARK: - Dimensions

    /// Sidebar width
    static let sidebarWidth: CGFloat = 240
    static let sidebarMinWidth: CGFloat = 200
    static let sidebarMaxWidth: CGFloat = 300

    /// Row height
    static let rowHeight: CGFloat = 36

    /// Button height
    static let buttonHeight: CGFloat = 32

    /// Large button height
    static let buttonHeightLarge: CGFloat = 44

    /// Icon size (small)
    static let iconSizeS: CGFloat = 16

    /// Icon size (standard)
    static let iconSize: CGFloat = 20

    /// Icon size (large)
    static let iconSizeL: CGFloat = 32

    /// Icon size (hero, from onboarding)
    static let iconSizeHero: CGFloat = 56
}

// MARK: - Legacy Compatibility

/// Legacy AppColors for backward compatibility
struct AppColors {
    static let primary = Color.accentColor
    static let primaryGradient = AppTheme.primaryGradient

    static let background = AppTheme.windowBackground
    static let secondaryBackground = AppTheme.controlBackground
    static let tertiaryBackground = AppTheme.sectionBackground

    static let sidebarBackground = AppTheme.controlBackground
    static let sidebarSelected = Color.accentColor.opacity(0.15)
    static let sidebarHover = Color.primary.opacity(0.05)

    static let cardBackground = AppTheme.cardBackgroundLight
    static let cardBorder = AppTheme.cardBorderLight

    static let success = AppTheme.success
    static let warning = AppTheme.warning
    static let error = AppTheme.error
    static let info = AppTheme.info

    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let textTertiary = Color(NSColor.tertiaryLabelColor)
}

/// Legacy AppDimensions for backward compatibility
struct AppDimensions {
    static let sidebarWidth: CGFloat = AppTheme.sidebarWidth
    static let sidebarMinWidth: CGFloat = AppTheme.sidebarMinWidth
    static let sidebarMaxWidth: CGFloat = AppTheme.sidebarMaxWidth

    static let cornerRadius: CGFloat = AppTheme.cornerRadius
    static let cornerRadiusSmall: CGFloat = AppTheme.cornerRadiusS
    static let cornerRadiusLarge: CGFloat = AppTheme.cornerRadiusL

    static let padding: CGFloat = AppTheme.spacing
    static let paddingSmall: CGFloat = AppTheme.spacingS
    static let paddingLarge: CGFloat = AppTheme.spacingL

    static let iconSize: CGFloat = AppTheme.iconSize
    static let iconSizeSmall: CGFloat = AppTheme.iconSizeS
    static let iconSizeLarge: CGFloat = AppTheme.iconSizeL

    static let rowHeight: CGFloat = AppTheme.rowHeight
    static let buttonHeight: CGFloat = AppTheme.buttonHeight
}

// MARK: - Color Extension (if not already defined)

extension Color {
    /// Initialize Color from hex string (supports 3, 6, and 8 character hex)
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
