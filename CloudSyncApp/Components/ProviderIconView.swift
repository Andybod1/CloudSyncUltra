//
//  ProviderIconView.swift
//  CloudSyncApp
//
//  Reusable component for displaying provider icons with brand colors.
//  Supports multiple sizes and styles for consistent visual appearance.
//

import SwiftUI

// MARK: - Provider Icon View

/// Displays a provider icon with its brand color in a consistent style.
/// Supports multiple size presets and optional background containers.
struct ProviderIconView: View {
    let providerType: CloudProviderType
    let size: IconSize
    let showBackground: Bool

    /// Predefined icon sizes for consistency across the app
    enum IconSize {
        case small      // 16pt icon
        case medium     // 20pt icon
        case large      // 32pt icon
        case hero       // 56pt icon (for headers/onboarding)
        case custom(CGFloat)

        var iconFont: CGFloat {
            switch self {
            case .small: return AppTheme.iconSizeS
            case .medium: return AppTheme.iconSize
            case .large: return AppTheme.iconSizeL
            case .hero: return AppTheme.iconSizeHero
            case .custom(let size): return size
            }
        }

        var containerSize: CGFloat {
            switch self {
            case .small: return AppTheme.iconContainerSmall
            case .medium: return AppTheme.iconContainerMedium
            case .large: return AppTheme.iconContainerMedium
            case .hero: return AppTheme.iconContainerLarge
            case .custom(let size): return size * 2.5
            }
        }
    }

    init(
        _ providerType: CloudProviderType,
        size: IconSize = .medium,
        showBackground: Bool = true
    ) {
        self.providerType = providerType
        self.size = size
        self.showBackground = showBackground
    }

    var body: some View {
        if showBackground {
            iconWithBackground
        } else {
            plainIcon
        }
    }

    // MARK: - Icon Variants

    private var plainIcon: some View {
        Image(systemName: providerType.iconName)
            .font(.system(size: size.iconFont))
            .foregroundColor(providerType.brandColor)
            .accessibilityLabel("\(providerType.displayName) icon")
    }

    private var iconWithBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM)
                .fill(providerType.brandColor.opacity(AppTheme.iconBackgroundOpacity))
                .frame(width: size.containerSize, height: size.containerSize)

            Image(systemName: providerType.iconName)
                .font(.system(size: size.iconFont))
                .foregroundColor(providerType.brandColor)
        }
        .accessibilityLabel("\(providerType.displayName) icon")
    }
}

// MARK: - Provider Icon with Label

/// Icon with provider name label, useful for lists and selection views
struct ProviderIconLabel: View {
    let providerType: CloudProviderType
    let size: ProviderIconView.IconSize

    init(_ providerType: CloudProviderType, size: ProviderIconView.IconSize = .small) {
        self.providerType = providerType
        self.size = size
    }

    var body: some View {
        Label {
            Text(providerType.displayName)
        } icon: {
            ProviderIconView(providerType, size: size, showBackground: false)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(providerType.displayName)
    }
}

// MARK: - Remote Icon View

/// Displays an icon for a CloudRemote instance (uses its type's icon and color)
struct RemoteIconView: View {
    let remote: CloudRemote
    let size: ProviderIconView.IconSize
    let showBackground: Bool

    init(
        _ remote: CloudRemote,
        size: ProviderIconView.IconSize = .medium,
        showBackground: Bool = true
    ) {
        self.remote = remote
        self.size = size
        self.showBackground = showBackground
    }

    var body: some View {
        ProviderIconView(remote.type, size: size, showBackground: showBackground)
    }
}

// MARK: - Convenience Extensions

extension CloudProviderType {
    /// Returns a ProviderIconView for this provider type
    @ViewBuilder
    func iconView(size: ProviderIconView.IconSize = .medium, showBackground: Bool = true) -> some View {
        ProviderIconView(self, size: size, showBackground: showBackground)
    }
}

extension CloudRemote {
    /// Returns a RemoteIconView for this remote
    @ViewBuilder
    func iconView(size: ProviderIconView.IconSize = .medium, showBackground: Bool = true) -> some View {
        RemoteIconView(self, size: size, showBackground: showBackground)
    }
}

// MARK: - Preview

#if DEBUG
struct ProviderIconView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            Text("Provider Icons")
                .font(.headline)

            // Size comparison
            HStack(spacing: 16) {
                VStack {
                    ProviderIconView(.googleDrive, size: .small)
                    Text("Small").font(.caption)
                }
                VStack {
                    ProviderIconView(.googleDrive, size: .medium)
                    Text("Medium").font(.caption)
                }
                VStack {
                    ProviderIconView(.googleDrive, size: .large)
                    Text("Large").font(.caption)
                }
                VStack {
                    ProviderIconView(.googleDrive, size: .hero)
                    Text("Hero").font(.caption)
                }
            }

            Divider()

            // Sample providers
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 16) {
                ForEach([CloudProviderType.googleDrive, .dropbox, .oneDrive, .s3, .protonDrive, .icloud, .box, .mega, .pcloud, .backblazeB2], id: \.self) { provider in
                    VStack(spacing: 8) {
                        ProviderIconView(provider, size: .medium)
                        Text(provider.displayName)
                            .font(.caption2)
                            .lineLimit(1)
                    }
                }
            }

            Divider()

            // Without background
            HStack(spacing: 16) {
                ForEach([CloudProviderType.googleDrive, .dropbox, .oneDrive], id: \.self) { provider in
                    ProviderIconView(provider, size: .medium, showBackground: false)
                }
            }
        }
        .padding()
        .frame(width: 500)
    }
}
#endif
