# Task: Move Schedules to Main Window

**Assigned to:** Dev-1 (UI Layer)
**Priority:** High
**Status:** Ready

---

## Objective

Move the Schedules management UI from Settings to the main application window as a primary sidebar navigation item.

---

## Task 1: Create SchedulesView.swift

**File:** `CloudSyncApp/Views/SchedulesView.swift`

Create a new view that adapts the content from ScheduleSettingsView for the main window:

```swift
import SwiftUI

struct SchedulesView: View {
    @StateObject private var scheduleManager = ScheduleManager.shared
    @State private var showingAddSchedule = false
    @State private var selectedSchedule: SyncSchedule?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Schedules")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: { showingAddSchedule = true }) {
                    Label("Add Schedule", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            
            Divider()
            
            // Content
            if scheduleManager.schedules.isEmpty {
                emptyState
            } else {
                scheduleList
            }
        }
        .sheet(isPresented: $showingAddSchedule) {
            ScheduleEditorSheet(schedule: nil)
        }
        .sheet(item: $selectedSchedule) { schedule in
            ScheduleEditorSheet(schedule: schedule)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No Scheduled Syncs")
                .font(.title3)
                .fontWeight(.medium)
            Text("Create a schedule to automatically sync your files.")
                .foregroundColor(.secondary)
            Button("Add Schedule") {
                showingAddSchedule = true
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var scheduleList: some View {
        List {
            ForEach(scheduleManager.schedules) { schedule in
                ScheduleRowView(schedule: schedule)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedSchedule = schedule
                    }
                    .contextMenu {
                        Button(schedule.isEnabled ? "Disable" : "Enable") {
                            scheduleManager.toggleSchedule(schedule)
                        }
                        Button("Edit") {
                            selectedSchedule = schedule
                        }
                        Divider()
                        Button("Run Now") {
                            scheduleManager.runScheduleNow(schedule)
                        }
                        Divider()
                        Button("Delete", role: .destructive) {
                            scheduleManager.deleteSchedule(schedule)
                        }
                    }
            }
        }
        .listStyle(.inset)
    }
}
```

---

## Task 2: Add Schedules to MainWindow Sidebar

**File:** `CloudSyncApp/Views/MainWindow.swift`

Add Schedules to the sidebar navigation. Find the sidebar NavigationLink items and add:

```swift
// Add after existing sidebar items (Dashboard, Files, Transfer, Tasks, History)
NavigationLink(value: "schedules") {
    Label("Schedules", systemImage: "calendar.badge.clock")
}
```

Add the destination in the NavigationSplitView detail section:

```swift
case "schedules":
    SchedulesView()
```

Also update the `handleOpenScheduleSettings` notification to navigate to schedules:

```swift
// Change from opening Settings to selecting schedules in sidebar
selectedItem = "schedules"
```

---

## Task 3: Remove Schedules Tab from SettingsView

**File:** `CloudSyncApp/SettingsView.swift`

Remove the Schedules tab. The SettingsView should go back to having only these tabs:
1. General
2. Accounts  
3. Sync
4. About

Remove:
- The ScheduleSettingsView tab item
- Any related tag adjustments
- The SelectSchedulesTab notification handler (schedules now in main window)

---

## Task 4: Update StatusBarController

**File:** `CloudSyncApp/StatusBarController.swift`

Update "Manage Schedules..." button to open main window to Schedules view instead of Settings:

The notification should now just open the main window and select schedules. The handler is already in MainWindow - just verify it works.

---

## Files to Create
- `CloudSyncApp/Views/SchedulesView.swift`

## Files to Modify
- `CloudSyncApp/Views/MainWindow.swift`
- `CloudSyncApp/SettingsView.swift`
- `CloudSyncApp/StatusBarController.swift` (verify notification works)

---

## Acceptance Criteria
- [ ] SchedulesView.swift created
- [ ] Schedules appears in main window sidebar
- [ ] Clicking Schedules shows schedule management UI
- [ ] Settings has 4 tabs (General, Accounts, Sync, About)
- [ ] Menu bar "Manage Schedules..." opens main window to Schedules
- [ ] Build succeeds

---

## When Complete

Update STATUS.md and write completion report to `outputs/DEV1_COMPLETE.md`
