# Task: Menu Bar Schedule Indicator - UI Layer

**Assigned to:** Dev-1 (UI Layer)
**Priority:** High
**Status:** Ready
**Depends on:** None (ScheduleManager already exists)

---

## Objective

Add a schedule information section to the menu bar popup showing the next scheduled sync time. This provides at-a-glance visibility into scheduled syncs without opening the app.

---

## Task 1: Add Schedule Section to StatusBarController Menu

**File:** `CloudSyncApp/StatusBarController.swift`

Modify the `updateMenu()` method to add a schedule indicator section. Insert this code after the last sync time section (around line 150) and before the "Open main window" section.

### Implementation

Find this line in `updateMenu()`:
```swift
menu.addItem(NSMenuItem.separator())

// Open main window
```

Add this schedule section BEFORE the separator that precedes "Open main window":

```swift
// Schedule indicator section
menu.addItem(NSMenuItem.separator())

let scheduleManager = ScheduleManager.shared
if let nextRun = scheduleManager.nextScheduledRun {
    let scheduleItem = NSMenuItem(title: "Next: \(nextRun.schedule.name)", action: nil, keyEquivalent: "")
    scheduleItem.isEnabled = false
    menu.addItem(scheduleItem)

    let timeItem = NSMenuItem(title: "  \(nextRun.schedule.formattedNextRun)", action: nil, keyEquivalent: "")
    timeItem.isEnabled = false
    menu.addItem(timeItem)
} else {
    let noScheduleItem = NSMenuItem(title: "No scheduled syncs", action: nil, keyEquivalent: "")
    noScheduleItem.isEnabled = false
    menu.addItem(noScheduleItem)
}

// Manage Schedules button
let manageItem = NSMenuItem(title: "Manage Schedules...", action: #selector(openScheduleSettings), keyEquivalent: "")
manageItem.target = self
menu.addItem(manageItem)

menu.addItem(NSMenuItem.separator())
```

---

## Task 2: Add openScheduleSettings Action Method

**File:** `CloudSyncApp/StatusBarController.swift`

Add a new action method to handle the "Manage Schedules..." button. Add this near the other `@objc` action methods (around line 255-274).

### Implementation

```swift
@objc private func openScheduleSettings() {
    // Bring app to front
    NSApp.activate(ignoringOtherApps: true)

    // Post notification to open settings with Schedules tab selected
    NotificationCenter.default.post(name: NSNotification.Name("OpenScheduleSettings"), object: nil)

    // Bring main window to front
    DispatchQueue.main.async {
        for window in NSApp.windows {
            if window.contentView != nil && !window.title.isEmpty {
                window.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
                break
            }
        }
    }

    updateMenu()
}
```

---

## Task 3: Handle OpenScheduleSettings Notification in ContentView

**File:** `CloudSyncApp/ContentView.swift`

Add a notification observer to navigate to the Schedules tab in Settings when the menu bar button is clicked.

### Find existing notification observers

Look for `.onReceive(NotificationCenter.default.publisher(for:` patterns and add a new one:

```swift
.onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenScheduleSettings"))) { _ in
    showSettings = true
    // Small delay to ensure settings view is loaded, then select Schedules tab
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        NotificationCenter.default.post(name: NSNotification.Name("SelectSchedulesTab"), object: nil)
    }
}
```

---

## Task 4: Handle Tab Selection in SettingsView

**File:** `CloudSyncApp/SettingsView.swift`

Add a notification observer to switch to the Schedules tab when requested.

### Implementation

1. Add a `@State` variable for tab selection if not already present:
```swift
@State private var selectedTab: Int = 0
```

2. Update the TabView to use the selection binding:
```swift
TabView(selection: $selectedTab) {
    // ... existing tabs with .tag(0), .tag(1), etc.
    // Ensure Schedules tab has .tag(3)
}
```

3. Add the notification observer:
```swift
.onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SelectSchedulesTab"))) { _ in
    selectedTab = 3  // Schedules tab
}
```

---

## Files to Modify

1. `CloudSyncApp/StatusBarController.swift` - Add schedule section and action
2. `CloudSyncApp/ContentView.swift` - Add notification handler
3. `CloudSyncApp/SettingsView.swift` - Add tab selection handler

---

## Acceptance Criteria

- [ ] Menu bar popup shows schedule section after status info
- [ ] "Next: [schedule name]" displays with countdown time when schedules exist
- [ ] "No scheduled syncs" displays when no enabled schedules
- [ ] "Manage Schedules..." button opens Settings to Schedules tab
- [ ] Build succeeds with zero errors
- [ ] Code follows existing patterns in StatusBarController.swift

---

## When Complete

1. Update STATUS.md with completion status
2. Write DEV1_COMPLETE.md with summary
3. Verify build: `xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build`
