//
//  Components.swift
//  CloudSyncApp
//
//  Reusable SwiftUI components following Apple's design guidelines
//  Includes accessibility support, performance optimization, and consistent styling
//

import SwiftUI
import Foundation

// MARK: - Loading States

/// Professional loading indicator with message
struct LoadingView: View {
    let message: String
    
    init(_ message: String = "Loading...") {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message)
    }
}

/// Skeleton loading view for content placeholders
struct SkeletonView: View {
    @State private var isAnimating = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.gray.opacity(0.2))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.3), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: isAnimating ? 200 : -200)
            )
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
            .accessibilityHidden(true)
    }
}

// MARK: - Empty States

/// Professional empty state view
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(message)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .fontWeight(.medium)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(message)")
        .accessibilityAddTraits(actionTitle != nil ? [.isButton] : [])
    }
}

// MARK: - Error Display

/// Manages error notifications and their lifecycle
@MainActor
class ErrorNotificationManager: ObservableObject {

    /// Active errors currently displayed
    @Published var activeErrors: [ErrorNotification] = []

    /// Maximum errors to show simultaneously
    private let maxErrors = 3

    /// Auto-dismiss timeout for non-critical errors (seconds)
    private let autoDismissDelay: TimeInterval = 10

    /// Show an error notification
    /// - Parameters:
    ///   - message: The error message to display
    ///   - context: Additional context (e.g., filename, remote name)
    ///   - isCritical: Whether this is a critical error
    ///   - isRetryable: Whether this error can be retried
    func show(_ message: String, context: String? = nil, isCritical: Bool = false, isRetryable: Bool = false) {
        let notification = ErrorNotification(
            id: UUID(),
            message: message,
            context: context,
            timestamp: Date(),
            isCritical: isCritical,
            isRetryable: isRetryable
        )

        // Add to active errors
        activeErrors.insert(notification, at: 0)

        // Trim to max if needed
        if activeErrors.count > maxErrors {
            activeErrors = Array(activeErrors.prefix(maxErrors))
        }

        // Auto-dismiss non-critical errors
        if !isCritical {
            Task {
                try? await Task.sleep(nanoseconds: UInt64(autoDismissDelay * 1_000_000_000))
                dismiss(notification.id)
            }
        }

        log("Error notification shown: \(message)")
    }

    /// Dismiss a specific error notification
    func dismiss(_ id: UUID) {
        activeErrors.removeAll { $0.id == id }
    }

    /// Dismiss all errors
    func dismissAll() {
        activeErrors.removeAll()
    }

    /// Log helper
    private func log(_ message: String) {
        print("🔔 ErrorNotificationManager: \(message)")
    }
}

/// Represents a single error notification
struct ErrorNotification: Identifiable, Equatable {
    let id: UUID
    let message: String
    let context: String?
    let timestamp: Date
    let isCritical: Bool
    let isRetryable: Bool

    static func == (lhs: ErrorNotification, rhs: ErrorNotification) -> Bool {
        lhs.id == rhs.id
    }
}

/// Professional error banner - basic version
struct ErrorBanner: View {
    let error: String
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)

            Text(error)
                .font(.subheadline)
                .foregroundStyle(.primary)

            Spacer()

            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Dismiss error")
        }
        .padding()
        .background(.red.opacity(0.1))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Error: \(error)")
    }
}

/// Enhanced error banner with full TransferError support
struct EnhancedErrorBanner: View {
    let notification: ErrorNotification
    let onDismiss: () -> Void
    let onRetry: (() -> Void)?

    init(
        notification: ErrorNotification,
        onDismiss: @escaping () -> Void,
        onRetry: (() -> Void)? = nil
    ) {
        self.notification = notification
        self.onDismiss = onDismiss
        self.onRetry = onRetry
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon based on severity
            icon
                .font(.title3)
                .foregroundStyle(iconColor)

            VStack(alignment: .leading, spacing: 4) {
                // Error title
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                // Error message
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                // Retry button if retryable
                if notification.isRetryable, let retry = onRetry {
                    Button(action: retry) {
                        Label("Retry", systemImage: "arrow.clockwise")
                            .font(.caption.weight(.medium))
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .padding(.top, 4)
                }
            }

            Spacer(minLength: 0)

            // Dismiss button
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Dismiss error")
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(borderColor, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    // MARK: - Computed Properties

    private var title: String {
        if notification.isCritical {
            return "Critical Error"
        } else if notification.isRetryable {
            return "Connection Error"
        } else {
            return "Error"
        }
    }

    private var errorMessage: String {
        if let context = notification.context {
            return "\(notification.message)\n\(context)"
        }
        return notification.message
    }

    private var icon: Image {
        if notification.isCritical {
            return Image(systemName: "exclamationmark.octagon.fill")
        } else if notification.isRetryable {
            return Image(systemName: "exclamationmark.triangle.fill")
        } else {
            return Image(systemName: "info.circle.fill")
        }
    }

    private var iconColor: Color {
        if notification.isCritical {
            return .red
        } else if notification.isRetryable {
            return .orange
        } else {
            return .blue
        }
    }

    private var backgroundColor: Color {
        if notification.isCritical {
            return Color.red.opacity(0.1)
        } else if notification.isRetryable {
            return Color.orange.opacity(0.1)
        } else {
            return Color.blue.opacity(0.1)
        }
    }

    private var borderColor: Color {
        if notification.isCritical {
            return .red.opacity(0.3)
        } else if notification.isRetryable {
            return .orange.opacity(0.3)
        } else {
            return .blue.opacity(0.3)
        }
    }
}

/// Container for displaying multiple error banners
struct ErrorBannerStack: View {
    @ObservedObject var errorManager: ErrorNotificationManager
    let onRetry: ((ErrorNotification) -> Void)?

    init(
        errorManager: ErrorNotificationManager,
        onRetry: ((ErrorNotification) -> Void)? = nil
    ) {
        self.errorManager = errorManager
        self.onRetry = onRetry
    }

    var body: some View {
        VStack(spacing: 8) {
            ForEach(errorManager.activeErrors) { notification in
                EnhancedErrorBanner(
                    notification: notification,
                    onDismiss: { errorManager.dismiss(notification.id) },
                    onRetry: onRetry != nil ? { onRetry?(notification) } : nil
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3), value: errorManager.activeErrors)
    }
}

// MARK: - Progress Indicators

/// Circular progress view with percentage
struct CircularProgressView: View {
    let progress: Double // 0.0 to 1.0
    let size: CGFloat
    let lineWidth: CGFloat
    
    init(progress: Double, size: CGFloat = 80, lineWidth: CGFloat = 8) {
        self.progress = progress
        self.size = size
        self.lineWidth = lineWidth
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.accentColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: progress)
            
            // Percentage text
            Text("\(Int(progress * 100))%")
                .font(.system(size: size * 0.25, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
        }
        .frame(width: size, height: size)
        .accessibilityLabel("Progress: \(Int(progress * 100))%")
        .accessibilityValue(progress == 1.0 ? "Complete" : "In progress")
    }
}

/// Linear progress bar with label
struct LinearProgressBar: View {
    let progress: Double
    let label: String?
    
    init(progress: Double, label: String? = nil) {
        self.progress = progress
        self.label = label
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let label = label {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.accentColor)
                        .frame(width: geometry.size.width * progress)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 8)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label ?? "Progress")
        .accessibilityValue("\(Int(progress * 100))%")
    }
}

// MARK: - Cards & Containers

/// Material card container
struct CardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.background)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
    }
}

/// Info row for settings or details
struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    let iconColor: Color
    
    init(icon: String, title: String, value: String, iconColor: Color = .accentColor) {
        self.icon = icon
        self.title = title
        self.value = value
        self.iconColor = iconColor
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(iconColor)
                .frame(width: 24)
            
            Text(title)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}

// MARK: - Status Indicators

/// Connection status badge
struct StatusBadge: View {
    let status: ConnectionStatus
    
    enum ConnectionStatus {
        case connected
        case disconnected
        case syncing
        case error
        
        var color: Color {
            switch self {
            case .connected: return .green
            case .disconnected: return .gray
            case .syncing: return .blue
            case .error: return .red
            }
        }
        
        var icon: String {
            switch self {
            case .connected: return "checkmark.circle.fill"
            case .disconnected: return "circle"
            case .syncing: return "arrow.triangle.2.circlepath"
            case .error: return "exclamationmark.triangle.fill"
            }
        }
        
        var label: String {
            switch self {
            case .connected: return "Connected"
            case .disconnected: return "Disconnected"
            case .syncing: return "Syncing"
            case .error: return "Error"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: status.icon)
                .font(.caption)
            
            Text(status.label)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundStyle(status.color)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(status.color.opacity(0.15))
        )
        .accessibilityLabel("Status: \(status.label)")
    }
}

// MARK: - File Size Formatter

struct FileSizeText: View {
    let bytes: Int64
    
    private var formatted: String {
        ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }
    
    var body: some View {
        Text(formatted)
            .accessibilityLabel("File size: \(formatted)")
    }
}

// MARK: - Search Bar

struct SearchBar: View {
    @Binding var text: String
    let placeholder: String
    
    init(text: Binding<String>, placeholder: String = "Search") {
        self._text = text
        self.placeholder = placeholder
    }
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.1))
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Search field")
    }
}

// MARK: - Context Menu Button

struct ContextMenuButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
        }
        .accessibilityLabel(title)
    }
}

// MARK: - Toast Notification

/// Toast notification that auto-dismisses
struct ToastView: View {
    let message: String
    let type: ToastType
    
    enum ToastType {
        case success
        case error
        case info
        
        var color: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            case .info: return .blue
            }
        }
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            case .info: return "info.circle.fill"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: type.icon)
                .foregroundStyle(type.color)
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .shadow(radius: 10)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message)
    }
}

// MARK: - Preview Helpers

#if DEBUG
struct Components_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            LoadingView("Loading files...")
            
            EmptyStateView(
                icon: "folder",
                title: "No Files",
                message: "Upload some files to get started",
                actionTitle: "Upload",
                action: {}
            )
            
            CircularProgressView(progress: 0.65)
            
            StatusBadge(status: .connected)
            
            SearchBar(text: .constant(""), placeholder: "Search files")
        }
        .padding()
    }
}
#endif
