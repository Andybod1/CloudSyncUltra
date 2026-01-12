# Task: Move Schedules to Main Window - Testing & Verification

**Assigned to:** QA (Testing)
**Priority:** High
**Status:** Ready
**Depends on:** Dev-1 completing UI changes

---

## Objective

Verify that moving Schedules from Settings to Main Window works correctly. This is primarily a verification task since existing schedule tests remain valid.

---

## Task 1: Code Review - Dev-1 Implementation

Review the following files for correctness:

### MainWindow.swift Changes
- [ ] `schedules` case added to `SidebarSection` enum
- [ ] Schedules sidebar item added with correct icon (`calendar.badge.clock`)
- [ ] Schedules appears between Tasks and History in sidebar
- [ ] `SchedulesView()` rendered for `.schedules` case in detailView
- [ ] `OpenScheduleSettings` notification navigates to `.schedules`

### SchedulesView.swift (New File)
- [ ] Uses `@StateObject` for ScheduleManager
- [ ] Header shows title and active schedule count
- [ ] "Add Schedule" button present
- [ ] Empty state displayed when no schedules
- [ ] Schedule list renders with ScheduleRowView
- [ ] Edit, Delete, Toggle, Run Now functionality works
- [ ] Alert for delete confirmation
- [ ] Sheets for add/edit

### SettingsView.swift Changes
- [ ] Schedules tab removed
- [ ] Only 4 tabs remain: General, Accounts, Sync, About
- [ ] About tab has correct tag (3)
- [ ] `SelectSchedulesTab` notification handler removed
- [ ] Frame height adjusted appropriately

---

## Task 2: Manual Verification Checklist

Test the following scenarios:

### Sidebar Navigation
- [ ] "Schedules" visible in main window sidebar
- [ ] Correct icon displayed (calendar.badge.clock)
- [ ] Click navigates to SchedulesView
- [ ] Selection highlight works correctly

### Schedule Management
- [ ] Empty state shows when no schedules
- [ ] "Add Schedule" button opens editor sheet
- [ ] Creating a schedule adds it to the list
- [ ] Editing a schedule opens pre-filled editor
- [ ] Delete confirmation appears before deletion
- [ ] Toggle enable/disable works
- [ ] "Run Now" triggers immediate sync

### Settings Verification
- [ ] Settings has exactly 4 tabs
- [ ] No "Schedules" tab in Settings
- [ ] All other tabs work correctly

### Menu Bar Integration
- [ ] "Manage Schedules..." in menu bar works
- [ ] Opens main window to Schedules section (not Settings)
- [ ] Window brought to front correctly

---

## Task 3: Build Verification

```bash
xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build 2>&1 | grep -E "(error:|BUILD)"
```

Expected: `** BUILD SUCCEEDED **`

---

## Task 4: Regression Check

Verify existing schedule functionality still works:
- [ ] Existing schedules display correctly in new location
- [ ] Schedule persistence works (schedules survive app restart)
- [ ] Schedule execution still triggers at correct times
- [ ] Menu bar schedule indicator still shows correct info

---

## Files to Review

| File | Type | What to Check |
|------|------|---------------|
| `Views/MainWindow.swift` | Modified | Sidebar, enum, detailView, notification |
| `Views/SchedulesView.swift` | New | Full implementation review |
| `SettingsView.swift` | Modified | Tab removal, cleanup |

---

## Acceptance Criteria

- [ ] Code review complete with no issues found
- [ ] Manual verification checklist passed
- [ ] Build succeeds
- [ ] No regressions in schedule functionality
- [ ] Menu bar integration works correctly

---

## When Complete

1. Update STATUS.md with completion status
2. Write QA_REPORT.md with:
   - Code review findings
   - Manual test results
   - Build verification
   - Any bugs found (with details)
   - Recommendations
