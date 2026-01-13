# Dev-1 Task: Error Banner Enhancement - Phase 2

## Issue Reference
GitHub Issue: #15 - Error handling - Error banner/toast component
Parent Issue: #8 - Comprehensive error handling with clear user feedback

## Model: Sonnet (S ticket - UI component enhancement)

## Sprint Context
**PHASE 2 of coordinated Error Handling Sprint**
Dependency: Requires #11 (TransferError model) - should be COMPLETE before you start
Parallel work: Dev-2 is adding error parsing to RcloneManager simultaneously

---

## Objective
Enhance the existing ErrorBanner component to support the comprehensive TransferError system. Add severity levels, auto-dismiss, retry functionality, and multi-error stacking.

## Prerequisites
✅ TransferError.swift must exist (created by Dev-3 in Phase 1)
✅ Existing ErrorBanner exists at `CloudSyncApp/Components/Components.swift` line ~125

---

## Current State Analysis

**Existing ErrorBanner** (simplified version):
```swift
struct ErrorBanner: View {
    let error: String         // Just a string message
    let onDismiss: () -> Void
    
    var body: some View {
        // Basic yellow warning triangle + message + dismiss button
    }
}
```

**What's Missing:**
- No support for TransferError enum
- No severity levels (error vs warning vs info)
- No auto-dismiss functionality
- No retry button for retryable errors
- No multi-error stacking
- No error notification management

---

## Implementation Tasks

### Task 1: Create ErrorNotificationManager

**Create new file:** `CloudSyncApp/ViewModels/ErrorNotificationManager.swift`

```swift
import Foundation
import SwiftUI

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
    ///   - error: The TransferError to display
    ///   - context: Additional context (e.g., filename, remote name)
    func show(_ error: TransferError, context: String? = nil) {
        let notification = ErrorNotification(
            id: UUID(),
            error: error,
            context: context,
            timestamp: Date()
        )
        
        // Add to active errors
        activeErrors.insert(notification, at: 0)
        
        // Trim to max if needed
        if activeErrors.count > maxErrors {
            activeErrors = Array(activeErrors.prefix(maxErrors))
        }
        
        // Auto-dismiss non-critical errors
        if !error.isCritical {
            Task {
                try? await Task.sleep(nanoseconds: UInt64(autoDismissDelay * 1_000_000_000))
                dismiss(notification.id)
            }
        }
        
        log("Error notification shown: \(error.title)")
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
    let error: TransferError
    let context: String?
    let timestamp: Date
    
    static func == (lhs: ErrorNotification, rhs: ErrorNotification) -> Bool {
        lhs.id == rhs.id
    }
}
```

### Task 2: Create Enhanced ErrorBanner Component

**Option A: Replace existing ErrorBanner in Components.swift**

Find the current ErrorBanner (around line 125) and REPLACE it with:

```swift
// MARK: - Error Display

/// Professional error banner with full TransferError support
struct ErrorBanner: View {
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
                Text(notification.error.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                // Error message
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Retry button if retryable
                if notification.error.isRetryable, let retry = onRetry {
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
    
    private var errorMessage: String {
        if let context = notification.context {
            return "\(notification.error.userMessage)\n\(context)"
        }
        return notification.error.userMessage
    }
    
    private var icon: Image {
        if notification.error.isCritical {
            return Image(systemName: "exclamationmark.octagon.fill")
        } else if notification.error.isRetryable {
            return Image(systemName: "exclamationmark.triangle.fill")
        } else {
            return Image(systemName: "info.circle.fill")
        }
    }
    
    private var iconColor: Color {
        if notification.error.isCritical {
            return .red
        } else if notification.error.isRetryable {
            return .orange
        } else {
            return .blue
        }
    }
    
    private var backgroundColor: Color {
        if notification.error.isCritical {
            return Color.red.opacity(0.1)
        } else if notification.error.isRetryable {
            return Color.orange.opacity(0.1)
        } else {
            return Color.blue.opacity(0.1)
        }
    }
    
    private var borderColor: Color {
        if notification.error.isCritical {
            return .red.opacity(0.3)
        } else if notification.error.isRetryable {
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
                ErrorBanner(
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
```

**Option B: Keep old ErrorBanner, add new one**

If you want to keep backward compatibility, rename old one to `LegacyErrorBanner` and add the new `ErrorBanner` above.

### Task 3: Integrate into TransferView

**Location:** `CloudSyncApp/Views/TransferView.swift`

1. Add ErrorNotificationManager as environment object or state object:

```swift
@StateObject private var errorManager = ErrorNotificationManager()
```

2. Add error banner stack to the view:

```swift
var body: some View {
    VStack(spacing: 0) {
        // Existing transfer UI...
        
        // Error banner stack at top
        if !errorManager.activeErrors.isEmpty {
            ScrollView {
                ErrorBannerStack(
                    errorManager: errorManager,
                    onRetry: { notification in
                        handleRetry(notification)
                    }
                )
                .padding()
            }
            .frame(maxHeight: 300)
        }
        
        // ... rest of transfer UI
    }
}

private func handleRetry(_ notification: ErrorNotification) {
    errorManager.dismiss(notification.id)
    
    // Retry the transfer
    Task {
        do {
            // Re-attempt the transfer that failed
            // (This will be implemented more fully in Phase 3)
            log("Retrying transfer after error: \(notification.error.title)")
        } catch {
            log("Retry failed: \(error)")
        }
    }
}
```

3. Monitor transfer progress for errors:

```swift
// In your upload/download task:
for try await progress in rclone.uploadWithProgress(...) {
    // Update progress UI
    
    // Check for errors
    if let error = progress.error {
        errorManager.show(error, context: progress.currentFile)
    }
}
```

### Task 4: Add Global ErrorManager to App

**Location:** `CloudSyncApp/CloudSyncApp.swift` (main app file)

```swift
@StateObject private var errorManager = ErrorNotificationManager()

var body: some Scene {
    WindowGroup {
        MainWindow()
            .environmentObject(errorManager)
    }
}
```

### Task 5: Integration Points

Add error display to these views:

1. **TransferView** - Show errors during transfers (PRIMARY)
2. **TasksView** - Show errors for failed tasks (Phase 3 - Dev-1/Dev-3)
3. **MainWindow** - Show errors for background operations (if needed)

---

## Visual Design Reference

**Critical Error Example:**
```
┌────────────────────────────────────────────────────┐
│ 🛑 Storage Full                               ✕   │
│ Google Drive is full. Free up space or upgrade    │
│ storage plan.                                      │
│ File: vacation_video.mp4                          │
└────────────────────────────────────────────────────┘
Red background, red border
```

**Retryable Error Example:**
```
┌────────────────────────────────────────────────────┐
│ ⚠️  Connection Error                          ✕   │
│ Connection timed out. Check your internet         │
│ connection and try again.                          │
│                                                    │
│ [↻ Retry]                                          │
└────────────────────────────────────────────────────┘
Orange background, orange border
```

**Info/Warning Example:**
```
┌────────────────────────────────────────────────────┐
│ ℹ️  Partial Success                           ✕   │
│ 8 of 10 files transferred successfully.           │
│ 2 files failed: quota exceeded.                   │
└────────────────────────────────────────────────────┘
Blue background, blue border
```

---

## Validation Checklist

Before marking complete:

- [ ] ErrorNotificationManager.swift created
- [ ] ErrorNotification struct defined
- [ ] Enhanced ErrorBanner component created/updated
- [ ] ErrorBannerStack component created
- [ ] Supports TransferError enum (not just strings)
- [ ] Shows different icons for critical/retryable/info
- [ ] Shows different colors for severity levels
- [ ] Auto-dismisses non-critical errors after 10 seconds
- [ ] Manual dismiss button works
- [ ] Retry button appears for retryable errors
- [ ] Retry button triggers callback
- [ ] Multiple errors stack properly (max 3)
- [ ] Smooth animations for show/dismiss
- [ ] Integrated into TransferView
- [ ] ErrorManager available as environment object
- [ ] Code compiles without errors
- [ ] Build succeeds

---

## Build & Test

```bash
cd /Users/antti/Claude

# Build
xcodebuild -project CloudSyncApp.xcodeproj \
  -scheme CloudSyncApp \
  -configuration Debug \
  build 2>&1 | grep -E '(error|warning|BUILD SUCCEEDED|BUILD FAILED)'
```

Expected: **BUILD SUCCEEDED**

---

## Testing

Test these scenarios manually:

1. **Show Critical Error:**
```swift
// In TransferView or test code
errorManager.show(.quotaExceeded(provider: "Google Drive"), context: "vacation_video.mp4")
```

2. **Show Retryable Error:**
```swift
errorManager.show(.connectionTimeout)
```

3. **Multiple Errors:**
```swift
errorManager.show(.quotaExceeded(provider: "Dropbox"))
errorManager.show(.connectionTimeout)
errorManager.show(.tokenExpired(provider: "OneDrive"))
```

4. **Auto-Dismiss:**
- Show a non-critical error
- Wait 10 seconds
- Should auto-dismiss

5. **Retry Button:**
- Show retryable error
- Click retry
- Should trigger callback and dismiss

---

## Completion Report

When done, create: `/Users/antti/Claude/.claude-team/outputs/DEV1_COMPLETE.md`

```markdown
# Dev-1 Completion Report

**Task:** Error Banner Enhancement (#15)
**Status:** COMPLETE  
**Sprint:** Error Handling Phase 2

## Implementation Summary
Enhanced error notification system with:
- Full TransferError enum support
- Severity-based styling (critical/warning/info)
- Auto-dismiss for non-critical errors
- Retry functionality for transient errors
- Multi-error stacking (max 3)
- Smooth animations

## Files Created
- `CloudSyncApp/ViewModels/ErrorNotificationManager.swift`

## Files Modified
- `CloudSyncApp/Components/Components.swift` - Enhanced ErrorBanner
- `CloudSyncApp/Views/TransferView.swift` - Integrated error display
- `CloudSyncApp/CloudSyncApp.swift` - Added global ErrorManager

## Components Added
1. `ErrorNotificationManager` - State management for errors
2. `ErrorNotification` - Notification model
3. `ErrorBanner` - Enhanced display component
4. `ErrorBannerStack` - Multi-error container

## Key Features
- ✅ Severity-based visual design
- ✅ Auto-dismiss after 10s (non-critical)
- ✅ Retry button for retryable errors
- ✅ Stack up to 3 errors
- ✅ Smooth show/hide animations
- ✅ Context support (filename, remote, etc.)

## Build Status
BUILD SUCCEEDED

## Testing Notes
[Add manual testing results]

## Ready for Phase 3
✅ Error display system complete
✅ Can show errors from RcloneManager
✅ Ready to integrate with SyncTask in Phase 3

## Commit
```bash
git add CloudSyncApp/ViewModels/ErrorNotificationManager.swift
git add CloudSyncApp/Components/Components.swift
git add CloudSyncApp/Views/TransferView.swift
git commit -m "feat(ui): Enhanced error notification system

- Full TransferError support with severity levels
- Auto-dismiss for non-critical errors
- Retry functionality for transient errors
- Multi-error stacking with animations
- Implements #15

Part of Error Handling Sprint (Phase 2/2 complete)"
```
```

---

## Time Estimate
45-60 minutes for implementation + testing

**WAIT for Dev-3 to complete Phase 1 before starting!**
Check STATUS.md for Dev-3 completion status.
