# TASK: Fix Schedule Time Display + Add 12/24 Hour Setting

## Worker: Dev-1 (UI)
## Size: S
## Model: Sonnet
## Tickets: #32, #33

---

## Overview

Two related UI fixes for schedule time handling:
1. **#32 (Bug):** Time not displaying when selecting in schedule editor
2. **#33 (Feature):** Add 12/24 hour time format toggle in Settings

---

## Task 1: Fix Time Display in Schedule Editor (#32)

### Problem
In `ScheduleEditorSheet.swift`, when user selects a time from the Hour picker dropdown, the selected value doesn't display properly.

### File
`/Users/antti/Claude/CloudSyncApp/Views/ScheduleEditorSheet.swift`

### Investigation
The current code (lines 117-124):
```swift
Picker("Hour", selection: $scheduledHour) {
    ForEach(0..<24, id: \.self) { hour in
        Text(formatHour(hour)).tag(hour)
    }
}
.frame(width: 100)
```

### Likely Fixes
1. Try adding `.pickerStyle(.menu)` to ensure proper display
2. Or use `.labelsHidden()` if label is interfering
3. Or increase frame width if text is being truncated

### Test
1. Open app → Schedules → New Schedule
2. Select "Daily" frequency
3. Click Hour dropdown
4. Select any hour
5. Verify the selected hour displays in the picker field

---

## Task 2: Add 12/24 Hour Setting (#33)

### Requirements
Add a toggle in Settings → General to switch between 12-hour (2 PM) and 24-hour (14:00) time format.

### Files to Modify

**1. SettingsView.swift** - Add toggle in GeneralSettingsView
```swift
// Add to existing @AppStorage properties (around line 54):
@AppStorage("use24HourTime") private var use24HourTime = false

// Add in the Notifications section or create new section:
Section {
    Toggle("Use 24-Hour Time", isOn: $use24HourTime)
} header: {
    Label("Time Format", systemImage: "clock")
}
```

**2. ScheduleEditorSheet.swift** - Update formatHour function
```swift
// Add at top of struct:
@AppStorage("use24HourTime") private var use24HourTime = false

// Update formatHour function (line 212):
private func formatHour(_ hour: Int) -> String {
    if use24HourTime {
        return String(format: "%02d:00", hour)
    } else {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        var components = DateComponents()
        components.hour = hour
        let date = Calendar.current.date(from: components) ?? Date()
        return formatter.string(from: date)
    }
}
```

**3. ScheduleRowView.swift** - Update any time displays (if applicable)
Check if this file displays times and update similarly.

**4. SchedulesView.swift** - Update any time displays (if applicable)
Check if this file displays times and update similarly.

### Test
1. Open Settings → General
2. Find "Use 24-Hour Time" toggle
3. Toggle OFF: Schedule times should show "2 AM", "3 PM" etc.
4. Toggle ON: Schedule times should show "02:00", "15:00" etc.
5. Create a new schedule and verify time picker respects the setting

---

## Acceptance Criteria

- [ ] #32: Hour picker displays selected value correctly
- [ ] #33: Toggle exists in Settings → General
- [ ] #33: 12-hour format shows "2 AM", "11 PM" style
- [ ] #33: 24-hour format shows "02:00", "23:00" style
- [ ] #33: Setting persists across app restarts
- [ ] #33: All time displays in schedule UI respect the setting
- [ ] Build succeeds with no warnings

---

## Commands

```bash
# Build
cd /Users/antti/Claude && xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build 2>&1 | tail -10

# Launch app for testing
open ~/Library/Developer/Xcode/DerivedData/CloudSyncApp-*/Build/Products/Debug/CloudSyncApp.app
```

---

## Output

Write completion report to `/Users/antti/Claude/.claude-team/outputs/DEV1_COMPLETE.md`
