# Task: Scheduled Sync - Menu Bar Integration

**Assigned to:** Dev-2 (Core Engine)
**Priority:** Medium
**Status:** Ready
**Depends on:** Dev-3 completing ScheduleManager

---

## Objective

Add scheduled sync information to the menu bar, showing next scheduled sync time and allowing quick access to schedules.

---

## Task 1: Update MenuBarView

**File:** `CloudSyncApp/Views/MenuBarView.swift`

Add schedule information to the menu bar popup. Find the MenuBarView and add a section showing:

1. Next scheduled sync time
2. Quick toggle for enabling/disabling all schedules
3. Link to open Schedules settings

```swift
// Add to MenuBarView - find the appropriate section and add:

// MARK: - Scheduled Sync Section

@StateObject private var scheduleManager = ScheduleManager.shared

// Add this section to the menu bar view body:

Divider()

// Schedule Status
if scheduleManager.enabledSchedulesCount > 0 {
    if let next = scheduleManager.nextScheduledRun {
        HStack {
            Image(systemName: "calendar.badge.clock")
                .foregroundColor(.blue)
            VStack(alignment: .leading, spacing: 2) {
                Text("Next: \(next.schedule.name)")
                    .font(.caption)
                Text(next.schedule.formattedNextRun)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }
} else {
    HStack {
        Image(systemName: "calendar.badge.clock")
            .foregroundColor(.secondary)
        Text("No scheduled syncs")
            .font(.caption)
            .foregroundColor(.secondary)
        Spacer()
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 6)
}

// Schedules button
Button(action: {
    // Open settings to Schedules tab
    openSchedulesSettings()
}) {
    HStack {
        Text("Manage Schedules")
        Spacer()
        Text("\(scheduleManager.enabledSchedulesCount)")
            .font(.caption)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.blue.opacity(0.2))
            .cornerRadius(4)
    }
}
.buttonStyle(.plain)
.padding(.horizontal, 12)
.padding(.vertical, 4)
```

---

## Task 2: Add Menu Bar Icon Badge (Optional Enhancement)

If the app uses a status item icon, consider adding a small indicator when:
- A scheduled sync is currently running
- The next sync is due within 5 minutes

```swift
// In the NSStatusItem setup, update icon based on schedule state:

func updateMenuBarIcon() {
    let scheduleManager = ScheduleManager.shared
    
    if scheduleManager.currentlyExecutingScheduleId != nil {
        // Show syncing icon
        statusItem.button?.image = NSImage(systemSymbolName: "arrow.triangle.2.circlepath", accessibilityDescription: "Syncing")
    } else if let next = scheduleManager.nextScheduledRun,
              next.date.timeIntervalSince(Date()) < 300 {
        // Due soon - could add a badge or different icon
        statusItem.button?.image = NSImage(systemSymbolName: "cloud.fill", accessibilityDescription: "CloudSync")
    } else {
        // Normal icon
        statusItem.button?.image = NSImage(systemSymbolName: "cloud.fill", accessibilityDescription: "CloudSync")
    }
}
```

---

## Task 3: Add App Initialization for ScheduleManager

**File:** `CloudSyncApp/CloudSyncAppApp.swift`

Ensure ScheduleManager starts when app launches:

```swift
// In CloudSyncAppApp.swift, add to init() or the main App body:

import SwiftUI

@main
struct CloudSyncAppApp: App {
    @StateObject private var scheduleManager = ScheduleManager.shared
    
    init() {
        // Start the scheduler when app launches
        Task { @MainActor in
            ScheduleManager.shared.startScheduler()
        }
        
        // Request notification permissions for schedule alerts
        requestNotificationPermissions()
    }
    
    var body: some Scene {
        // ... existing code ...
    }
    
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("[App] Notification permissions granted")
            } else if let error = error {
                print("[App] Notification permission error: \(error)")
            }
        }
    }
}
```

---

## Task 4: Add Helper Function for Opening Settings

Add a function to open Settings directly to the Schedules tab:

```swift
// Add to a shared utility or in MenuBarView:

func openSchedulesSettings() {
    // Post notification to open settings
    NotificationCenter.default.post(name: .openSchedulesSettings, object: nil)
    
    // Or if using NSApp:
    if let window = NSApp.windows.first(where: { $0.title.contains("Settings") }) {
        window.makeKeyAndOrderFront(nil)
    } else {
        // Open settings window
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }
}

// Define notification name
extension Notification.Name {
    static let openSchedulesSettings = Notification.Name("openSchedulesSettings")
}
```

---

## Files to Modify

1. `CloudSyncApp/Views/MenuBarView.swift` - Add schedule section
2. `CloudSyncApp/CloudSyncAppApp.swift` - Initialize ScheduleManager
3. Any menu bar icon handling code

---

## Acceptance Criteria

- [ ] Menu bar shows "Next: [schedule name]" with time
- [ ] Menu bar shows "No scheduled syncs" when none exist
- [ ] "Manage Schedules" button opens Settings
- [ ] ScheduleManager starts automatically on app launch
- [ ] Notification permissions requested on first launch
- [ ] Build succeeds with zero errors

---

## When Complete

1. Update STATUS.md with completion
2. Write DEV2_COMPLETE.md with summary
3. Verify build: `xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build`
