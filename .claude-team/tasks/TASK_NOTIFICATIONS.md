# Feature Task: User Notifications for Completed Transfers

**Issue:** #90
**Sprint:** Next Sprint
**Priority:** Medium
**Worker:** Dev-3 (System Integration)
**Model:** Opus + Extended Thinking

---

## Objective

Add macOS notifications when transfers complete and progress indicator in Dock icon.

## Files to Create

- `CloudSyncApp/NotificationManager.swift`

## Files to Modify

- `CloudSyncApp/CloudSyncAppApp.swift` - Initialize notification manager
- `CloudSyncApp/RcloneManager.swift` - Send notifications on transfer complete/error
- `CloudSyncApp/SettingsView.swift` - Add notification preferences

## Tasks

### 1. Create NotificationManager.swift

```swift
import Foundation
import UserNotifications
import AppKit
import os

/// Manages macOS notifications and Dock badge progress
@MainActor
final class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()

    private let logger = Logger(subsystem: "com.cloudsync.ultra", category: "notifications")

    @Published var notificationsEnabled = true
    @Published var soundEnabled = true

    private override init() {
        super.init()
    }

    // MARK: - Permission Request

    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            logger.info("Notification permission: \(granted ? "granted" : "denied")")
            return granted
        } catch {
            logger.error("Failed to request notification permission: \(error)")
            return false
        }
    }

    // MARK: - Send Notifications

    func sendTransferComplete(fileName: String, destination: String) {
        guard notificationsEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "Transfer Complete"
        content.body = "\(fileName) transferred to \(destination)"
        content.sound = soundEnabled ? .default : nil
        content.categoryIdentifier = "TRANSFER_COMPLETE"

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                self.logger.error("Failed to send notification: \(error)")
            }
        }
    }

    func sendTransferError(fileName: String, error: String) {
        guard notificationsEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "Transfer Failed"
        content.body = "\(fileName): \(error)"
        content.sound = soundEnabled ? .defaultCritical : nil
        content.categoryIdentifier = "TRANSFER_ERROR"

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    func sendBatchComplete(count: Int, destination: String) {
        guard notificationsEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "Batch Transfer Complete"
        content.body = "\(count) files transferred to \(destination)"
        content.sound = soundEnabled ? .default : nil

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Dock Badge Progress

    func updateDockProgress(_ progress: Double) {
        // Progress: 0.0 to 1.0
        DispatchQueue.main.async {
            if progress >= 1.0 || progress <= 0.0 {
                // Clear progress
                NSApp.dockTile.badgeLabel = nil
                NSApp.dockTile.contentView = nil
            } else {
                // Show percentage
                let percent = Int(progress * 100)
                NSApp.dockTile.badgeLabel = "\(percent)%"
            }
            NSApp.dockTile.display()
        }
    }

    func clearDockProgress() {
        DispatchQueue.main.async {
            NSApp.dockTile.badgeLabel = nil
            NSApp.dockTile.contentView = nil
            NSApp.dockTile.display()
        }
    }
}
```

### 2. Initialize in App

In `CloudSyncAppApp.swift`:

```swift
.onAppear {
    Task {
        await NotificationManager.shared.requestPermission()
    }
}
```

### 3. Integrate with RcloneManager

After transfer completes in RcloneManager:

```swift
// On success
await NotificationManager.shared.sendTransferComplete(
    fileName: fileName,
    destination: remoteName
)

// On error
await NotificationManager.shared.sendTransferError(
    fileName: fileName,
    error: errorMessage
)

// Update progress during transfer
await NotificationManager.shared.updateDockProgress(progress)

// Clear on complete
await NotificationManager.shared.clearDockProgress()
```

### 4. Add Settings UI

In `SettingsView.swift`, add notification preferences:

```swift
Section("Notifications") {
    Toggle("Enable Notifications", isOn: $notificationManager.notificationsEnabled)
    Toggle("Play Sound", isOn: $notificationManager.soundEnabled)
        .disabled(!notificationManager.notificationsEnabled)

    Button("Test Notification") {
        notificationManager.sendTransferComplete(
            fileName: "Test File.txt",
            destination: "Google Drive"
        )
    }
}
```

### 5. Persist Settings

Use @AppStorage for persistence:

```swift
@AppStorage("notificationsEnabled") var notificationsEnabled = true
@AppStorage("notificationSoundEnabled") var soundEnabled = true
```

## Verification

1. Build and run app
2. Grant notification permission when prompted
3. Start a file transfer
4. Verify:
   - Dock icon shows progress percentage
   - Notification appears when transfer completes
   - Error notification appears on failure
   - Settings toggle works
   - Sound plays (if enabled)

## Output

Write completion report to: `/Users/antti/Claude/.claude-team/outputs/NOTIFICATIONS_COMPLETE.md`

## Success Criteria

- [ ] NotificationManager.swift created
- [ ] Permission request on first launch
- [ ] Notification on transfer complete
- [ ] Notification on transfer error
- [ ] Dock icon progress indicator
- [ ] Sound effects (optional)
- [ ] Settings to disable notifications
- [ ] Build succeeds
- [ ] Existing tests pass
