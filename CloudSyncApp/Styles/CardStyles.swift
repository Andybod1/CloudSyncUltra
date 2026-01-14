//
//  CardStyles.swift
//  CloudSyncApp
//
//  Shared card and container styles matching the onboarding experience.
//  Provides consistent card appearance across the entire app.
//

import SwiftUI

// MARK: - Card Container

/// Reusable card container that matches onboarding feature card styling
struct CardContainer<Content: View>: View {
    let content: Content
    var padding: CGFloat = AppTheme.spacing
    var cornerRadius: CGFloat = AppTheme.cornerRadiusL

    init(
        padding: CGFloat = AppTheme.spacing,
        cornerRadius: CGFloat = AppTheme.cornerRadiusL,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.padding = padding
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(AppTheme.controlBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(AppTheme.cardBorderLight, lineWidth: 1)
            )
            .shadow(
                color: AppTheme.cardShadowColor,
                radius: AppTheme.cardShadowRadius,
                y: AppTheme.cardShadowY
            )
    }
}

// MARK: - Feature Card (Onboarding Style)

/// Feature card matching the onboarding FeatureCard design
struct FeatureCardContainer<Content: View>: View {
    let content: Content
    var width: CGFloat = 140
    @State private var isHovered = false

    init(width: CGFloat = 140, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.width = width
    }

    var body: some View {
        content
            .frame(width: width)
            .padding(.vertical, 20)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusL)
                    .fill(isHovered ? AppTheme.cardBackgroundDarkHover : AppTheme.cardBackgroundDark)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusL)
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

// MARK: - Stat Card Container

/// Container for dashboard stat cards with hover effects
struct StatCardContainer<Content: View>: View {
    let content: Content
    var color: Color = .accentColor
    var hasAction: Bool = false
    @State private var isHovered = false

    init(color: Color = .accentColor, hasAction: Bool = false, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.color = color
        self.hasAction = hasAction
    }

    var body: some View {
        content
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .fill(isHovered && hasAction ? color.opacity(0.15) : color.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(isHovered && hasAction ? color.opacity(0.3) : Color.clear, lineWidth: 1)
            )
            .onHover { hovering in
                guard hasAction else { return }
                withAnimation(AppTheme.easeInOut) {
                    isHovered = hovering
                }
            }
    }
}

// MARK: - Glass Card (Dark Mode)

/// Glass-effect card for dark backgrounds (like onboarding)
struct GlassCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = AppTheme.spacing
    @State private var isHovered = false

    init(padding: CGFloat = AppTheme.spacing, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.padding = padding
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusL)
                    .fill(.ultraThinMaterial)
                    .opacity(0.8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusL)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
}

// MARK: - Info Card

/// Information/notice card with icon
struct InfoCard<Content: View>: View {
    let icon: String
    let iconColor: Color
    let content: Content

    init(icon: String, iconColor: Color = .blue, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.iconColor = iconColor
        self.content = content()
    }

    var body: some View {
        HStack(spacing: AppTheme.spacingM) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 32)

            content
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .fill(iconColor.opacity(0.1))
        )
    }
}

// MARK: - Service Card Container

/// Container for connected service cards with hover and selection states
struct ServiceCardContainer<Content: View>: View {
    let content: Content
    var isSelected: Bool = false
    @State private var isHovered = false

    init(isSelected: Bool = false, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.isSelected = isSelected
    }

    var body: some View {
        content
            .padding(AppTheme.spacingM)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .fill(
                        isHovered
                            ? Color(NSColor.selectedControlColor).opacity(0.3)
                            : AppTheme.controlBackground
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(
                        isHovered ? Color.accentColor.opacity(0.5) : Color.clear,
                        lineWidth: 1
                    )
            )
            .onHover { hovering in
                withAnimation(AppTheme.easeInOut) {
                    isHovered = hovering
                }
            }
    }
}

// MARK: - Section Card

/// Section container with header and content
struct SectionCard<Header: View, Content: View>: View {
    let header: Header
    let content: Content

    init(@ViewBuilder header: () -> Header, @ViewBuilder content: () -> Content) {
        self.header = header()
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing) {
            header
            content
        }
        .padding(AppTheme.spacing)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .fill(AppTheme.controlBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(AppTheme.cardBorderLight, lineWidth: 1)
        )
    }
}

// MARK: - Icon Container

/// Circular icon container matching onboarding style
struct IconContainer: View {
    let icon: String
    var color: Color = AppTheme.primaryPurple
    var size: IconContainerSize = .medium
    var hasGlow: Bool = false

    enum IconContainerSize {
        case small, medium, large, hero

        var containerSize: CGFloat {
            switch self {
            case .small: return AppTheme.iconContainerSmall
            case .medium: return AppTheme.iconContainerMedium
            case .large: return AppTheme.iconContainerLarge
            case .hero: return 200
            }
        }

        var iconFont: Font {
            switch self {
            case .small: return .title3
            case .medium: return .title2
            case .large: return .system(size: 48)
            case .hero: return .system(size: AppTheme.iconSizeHero)
            }
        }
    }

    var body: some View {
        ZStack {
            if hasGlow {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                color.opacity(0.4),
                                color.opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: size.containerSize * 0.3,
                            endRadius: size.containerSize * 0.8
                        )
                    )
                    .frame(width: size.containerSize * 1.5, height: size.containerSize * 1.5)
            }

            Circle()
                .fill(color.opacity(AppTheme.iconBackgroundOpacity))
                .frame(width: size.containerSize, height: size.containerSize)

            Image(systemName: icon)
                .font(size.iconFont)
                .foregroundColor(color)
        }
        .shadow(
            color: hasGlow ? AppTheme.iconGlow(color: color) : Color.clear,
            radius: hasGlow ? AppTheme.iconGlowRadius : 0,
            y: hasGlow ? AppTheme.iconGlowY : 0
        )
    }
}

// MARK: - Animated Icon Container (Hero)

/// Hero icon container with animated glow (matches onboarding header)
struct HeroIconContainer: View {
    let icon: String
    var primaryColor: Color = AppTheme.primaryIndigo
    var secondaryColor: Color = AppTheme.primaryPurple
    @State private var animateGlow = false
    @State private var animateIcon = false

    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            primaryColor.opacity(0.4),
                            secondaryColor.opacity(0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 40,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .scaleEffect(animateGlow ? 1.1 : 0.9)
                .animation(
                    .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                    value: animateGlow
                )

            // Main icon background
            Circle()
                .fill(
                    LinearGradient(
                        colors: [primaryColor, secondaryColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 120, height: 120)
                .shadow(color: AppTheme.iconGlow(color: primaryColor), radius: 20, y: 10)

            // Icon
            Image(systemName: icon)
                .font(.system(size: 56, weight: .medium))
                .foregroundColor(.white)
                .offset(y: animateIcon ? -2 : 2)
                .animation(
                    .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                    value: animateIcon
                )
        }
        .onAppear {
            animateGlow = true
            animateIcon = true
        }
    }
}

// MARK: - View Modifiers

/// Card style modifier (legacy compatibility)
struct CardStyle: ViewModifier {
    var padding: CGFloat = AppTheme.spacing

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(AppTheme.controlBackground)
            .cornerRadius(AppTheme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(AppTheme.cardBorderLight, lineWidth: 1)
            )
    }
}

/// Sidebar item style modifier (legacy compatibility)
struct SidebarItemStyle: ViewModifier {
    var isSelected: Bool
    var isHovered: Bool

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, AppTheme.spacingS)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusS)
                    .fill(
                        isSelected
                            ? Color.accentColor.opacity(0.15)
                            : (isHovered ? Color.primary.opacity(0.05) : Color.clear)
                    )
            )
    }
}

// MARK: - View Extensions

extension View {
    /// Apply card style
    func cardStyle(padding: CGFloat = AppTheme.spacing) -> some View {
        modifier(CardStyle(padding: padding))
    }

    /// Apply sidebar item style
    func sidebarItemStyle(isSelected: Bool, isHovered: Bool = false) -> some View {
        modifier(SidebarItemStyle(isSelected: isSelected, isHovered: isHovered))
    }

    /// Wrap in a card container
    func inCard(padding: CGFloat = AppTheme.spacing) -> some View {
        CardContainer(padding: padding) {
            self
        }
    }

    /// Apply hover effect
    func hoverEffect(
        isHovered: Binding<Bool>,
        scaleAmount: CGFloat = AppTheme.hoverScale
    ) -> some View {
        self
            .scaleEffect(isHovered.wrappedValue ? scaleAmount : 1.0)
            .animation(AppTheme.easeInOut, value: isHovered.wrappedValue)
            .onHover { hovering in
                isHovered.wrappedValue = hovering
            }
    }
}

// MARK: - Preview

#Preview("Card Styles") {
    ScrollView {
        VStack(spacing: 24) {
            // Card Container
            CardContainer {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Card Container")
                        .font(.headline)
                    Text("This is a standard card container with border and shadow.")
                        .foregroundColor(.secondary)
                }
            }

            // Stat Card
            StatCardContainer(color: .blue, hasAction: true) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "cloud.fill")
                            .foregroundColor(.blue)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    Text("42")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.blue)
                    Text("cloud services")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Info Card
            InfoCard(icon: "info.circle.fill", iconColor: .blue) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Information")
                        .fontWeight(.semibold)
                    Text("This is an info card with an icon.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Icon Containers
            HStack(spacing: 24) {
                IconContainer(icon: "cloud.fill", size: .small)
                IconContainer(icon: "cloud.fill", size: .medium)
                IconContainer(icon: "cloud.fill", size: .large, hasGlow: true)
            }

            // Service Card
            ServiceCardContainer {
                HStack(spacing: 12) {
                    IconContainer(icon: "externaldrive.fill", color: .blue, size: .small)
                    VStack(alignment: .leading) {
                        Text("Google Drive")
                            .fontWeight(.medium)
                        Text("Connected")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    Spacer()
                }
            }
        }
        .padding(40)
    }
    .frame(width: 500, height: 700)
    .background(Color(NSColor.windowBackgroundColor))
}
