# Dev-3 Task: User Notifications for Transfer Completion

**Sprint:** Maximum Productivity
**Priority:** Medium
**Worker:** Dev-3 (Services Layer)

---

## Objective

Add macOS notifications when transfers complete or fail, and show progress in the Dock icon.

## Files to Create

- `CloudSyncApp/NotificationManager.swift`

## Files to Modify

- `CloudSyncApp/CloudSyncApp.swift` (initialize notification manager)
- `CloudSyncApp/RcloneManager.swift` (trigger notifications)
- `CloudSyncApp/SyncManager.swift` (trigger notifications)

## Tasks

### 1. Create NotificationManager.swift

```swift
import Foundation
import UserNotifications
import AppKit

/// Manages macOS notifications for CloudSync Ultra
final class NotificationManager: NSObject {
    static let shared = NotificationManager()

    private override init() {
        super.init()
    }

    // MARK: - Setup

    /// Request notification permissions
    func requestPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permissions granted")
            }
        }
        UNUserNotificationCenter.current().delegate = self
    }

    // MARK: - Transfer Notifications

    /// Notify when transfer completes successfully
    func notifyTransferComplete(
        source: String,
        destination: String,
        fileCount: Int,
        bytesTransferred: Int64
    ) {
        let content = UNMutableNotificationContent()
        content.title = "Transfer Complete"
        content.body = "\(fileCount) file(s) transferred to \(destination)"
        content.sound = .default
        content.categoryIdentifier = "TRANSFER_COMPLETE"

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)

        // Clear dock badge
        updateDockBadge(nil)
    }

    /// Notify when transfer fails
    func notifyTransferFailed(
        source: String,
        destination: String,
        error: String
    ) {
        let content = UNMutableNotificationContent()
        content.title = "Transfer Failed"
        content.body = "Could not transfer to \(destination): \(error)"
        content.sound = .defaultCritical
        content.categoryIdentifier = "TRANSFER_FAILED"

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)

        // Clear dock badge
        updateDockBadge(nil)
    }

    /// Notify partial success
    func notifyTransferPartial(
        succeeded: Int,
        failed: Int,
        destination: String
    ) {
        let content = UNMutableNotificationContent()
        content.title = "Transfer Partially Complete"
        content.body = "\(succeeded) files transferred, \(failed) failed"
        content.sound = .default
        content.categoryIdentifier = "TRANSFER_PARTIAL"

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Dock Badge

    /// Update dock badge with progress or count
    func updateDockBadge(_ value: String?) {
        DispatchQueue.main.async {
            NSApp.dockTile.badgeLabel = value
        }
    }

    /// Update dock progress indicator
    func updateDockProgress(_ progress: Double) {
        DispatchQueue.main.async {
            // Show percentage as badge during transfer
            if progress > 0 && progress < 1 {
                let percentage = Int(progress * 100)
                NSApp.dockTile.badgeLabel = "\(percentage)%"
            } else {
                NSApp.dockTile.badgeLabel = nil
            }
        }
    }

    // MARK: - Scheduled Sync Notifications

    func notifyScheduledSyncStarting(taskName: String) {
        let content = UNMutableNotificationContent()
        content.title = "Scheduled Sync Starting"
        content.body = taskName
        content.sound = nil  // Silent for scheduled

        let request = UNNotificationRequest(
            identifier: "scheduled_\(taskName)",
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    func notifyScheduledSyncComplete(taskName: String, fileCount: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Scheduled Sync Complete"
        content.body = "\(taskName): \(fileCount) files synced"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Handle notification tap - bring app to front
        NSApp.activate(ignoringOtherApps: true)
        completionHandler()
    }
}
```

### 2. Initialize in CloudSyncApp.swift

```swift
// Add to app init or onAppear
NotificationManager.shared.requestPermissions()
```

### 3. Integrate with RcloneManager

In transfer completion handlers:

```swift
// On success
NotificationManager.shared.notifyTransferComplete(
    source: source,
    destination: destination,
    fileCount: fileCount,
    bytesTransferred: bytesTransferred
)

// On failure
NotificationManager.shared.notifyTransferFailed(
    source: source,
    destination: destination,
    error: error.localizedDescription
)

// During transfer - update dock
NotificationManager.shared.updateDockProgress(progress)
```

### 4. Add Preference Toggle

In SettingsView, add option to enable/disable notifications:

```swift
@AppStorage("notificationsEnabled") private var notificationsEnabled = true

Toggle("Show notifications for transfers", isOn: $notificationsEnabled)
```

## Verification

1. Start a transfer
2. Minimize app
3. Wait for completion
4. Verify notification appears
5. Verify dock badge shows progress during transfer
6. Test failure notification

## Output

Write completion report to: `/Users/antti/Claude/.claude-team/outputs/DEV3_COMPLETE.md`

Include:
- Files created/modified
- Integration points
- Testing notes

## Success Criteria

- [ ] NotificationManager.swift created
- [ ] Permissions requested at launch
- [ ] Success notification works
- [ ] Failure notification works
- [ ] Dock badge shows progress
- [ ] Preference toggle in Settings
- [ ] Build succeeds
