//
//  AppTheme.swift
//  CloudSyncApp
//
//  Design system and theme constants
//

import SwiftUI

// MARK: - Theme Colors

struct AppColors {
    // Primary
    static let primary = Color.accentColor
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Background
    static let background = Color(NSColor.windowBackgroundColor)
    static let secondaryBackground = Color(NSColor.controlBackgroundColor)
    static let tertiaryBackground = Color(NSColor.underPageBackgroundColor)
    
    // Sidebar
    static let sidebarBackground = Color(NSColor.controlBackgroundColor)
    static let sidebarSelected = Color.accentColor.opacity(0.15)
    static let sidebarHover = Color.primary.opacity(0.05)
    
    // Cards
    static let cardBackground = Color(NSColor.controlBackgroundColor)
    static let cardBorder = Color.primary.opacity(0.1)
    
    // Status
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    static let info = Color.blue
    
    // Text
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let textTertiary = Color(NSColor.tertiaryLabelColor)
}

// MARK: - Theme Dimensions

struct AppDimensions {
    static let sidebarWidth: CGFloat = 240
    static let sidebarMinWidth: CGFloat = 200
    static let sidebarMaxWidth: CGFloat = 300
    
    static let cornerRadius: CGFloat = 10
    static let cornerRadiusSmall: CGFloat = 6
    static let cornerRadiusLarge: CGFloat = 16
    
    static let padding: CGFloat = 16
    static let paddingSmall: CGFloat = 8
    static let paddingLarge: CGFloat = 24
    
    static let iconSize: CGFloat = 20
    static let iconSizeSmall: CGFloat = 16
    static let iconSizeLarge: CGFloat = 32
    
    static let rowHeight: CGFloat = 36
    static let buttonHeight: CGFloat = 32
}

// MARK: - Color Extension

extension Color {
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

// MARK: - View Modifiers

struct CardStyle: ViewModifier {
    var padding: CGFloat = AppDimensions.padding
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(AppColors.cardBackground)
            .cornerRadius(AppDimensions.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppDimensions.cornerRadius)
                    .stroke(AppColors.cardBorder, lineWidth: 1)
            )
    }
}

struct SidebarItemStyle: ViewModifier {
    var isSelected: Bool
    var isHovered: Bool
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, AppDimensions.paddingSmall)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: AppDimensions.cornerRadiusSmall)
                    .fill(isSelected ? AppColors.sidebarSelected : (isHovered ? AppColors.sidebarHover : Color.clear))
            )
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, AppDimensions.padding)
            .padding(.vertical, AppDimensions.paddingSmall)
            .background(AppColors.primaryGradient)
            .foregroundColor(.white)
            .cornerRadius(AppDimensions.cornerRadiusSmall)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, AppDimensions.padding)
            .padding(.vertical, AppDimensions.paddingSmall)
            .background(Color.secondary.opacity(0.1))
            .foregroundColor(.primary)
            .cornerRadius(AppDimensions.cornerRadiusSmall)
            .overlay(
                RoundedRectangle(cornerRadius: AppDimensions.cornerRadiusSmall)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - View Extensions

extension View {
    func cardStyle(padding: CGFloat = AppDimensions.padding) -> some View {
        modifier(CardStyle(padding: padding))
    }
    
    func sidebarItemStyle(isSelected: Bool, isHovered: Bool = false) -> some View {
        modifier(SidebarItemStyle(isSelected: isSelected, isHovered: isHovered))
    }
}
