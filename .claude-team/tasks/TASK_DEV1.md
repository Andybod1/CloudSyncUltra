# Task: Move Schedules to Main Window - UI Layer

**Assigned to:** Dev-1 (UI Layer)
**Priority:** High
**Status:** Ready
**Depends on:** None

---

## Objective

Move the Schedules management UI from Settings to the main application window as a primary navigation item. This elevates Schedules to a first-class feature with direct sidebar access.

---

## Task 1: Add Schedules to MainWindow Sidebar

**File:** `CloudSyncApp/Views/MainWindow.swift`

### Step 1.1: Add `schedules` case to SidebarSection enum (around line 19)

Find the `SidebarSection` enum and add the `schedules` case:

```swift
enum SidebarSection: Hashable {
    case dashboard
    case transfer
    case encryption
    case tasks
    case schedules  // ADD THIS LINE
    case history
    case settings
    case remote(CloudRemote)
}
```

### Step 1.2: Add Schedules to sidebar navigation (around line 138)

In `SidebarView`, find the first `Section` with Dashboard, Transfer, Tasks, History items. Add Schedules between Tasks and History:

```swift
sidebarItem(
    icon: "list.bullet.clipboard",
    title: "Tasks",
    section: .tasks,
    badge: runningTasks > 0 ? runningTasks : nil
)

// ADD THIS BLOCK
sidebarItem(
    icon: "calendar.badge.clock",
    title: "Schedules",
    section: .schedules
)

sidebarItem(
    icon: "clock.arrow.circlepath",
    title: "History",
    section: .history
)
```

### Step 1.3: Add SchedulesView case to detailView (around line 88)

In the `detailView` computed property, add a case for `.schedules`:

```swift
case .tasks:
    TasksView()
case .schedules:  // ADD THIS CASE
    SchedulesView()
case .history:
    HistoryView()
```

### Step 1.4: Update OpenScheduleSettings notification handler (around line 69)

Change the handler to navigate to `.schedules` instead of `.settings`:

**Replace lines 69-75 with:**
```swift
.onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenScheduleSettings"))) { _ in
    selectedSection = .schedules
}
```

---

## Task 2: Create SchedulesView for Main Window

**File:** `CloudSyncApp/Views/SchedulesView.swift` (NEW FILE)

Create a new view that presents schedules as a main content area.

```swift
//
//  SchedulesView.swift
//  CloudSyncApp
//
//  Main window view for managing scheduled sync jobs
//

import SwiftUI

struct SchedulesView: View {
    @StateObject private var scheduleManager = ScheduleManager.shared
    @State private var showingAddSheet = false
    @State private var editingSchedule: SyncSchedule?
    @State private var scheduleToDelete: SyncSchedule?
    @State private var showDeleteConfirmation = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Schedules")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("\(scheduleManager.enabledSchedulesCount) active schedule\(scheduleManager.enabledSchedulesCount == 1 ? "" : "s")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: { showingAddSheet = true }) {
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
        .sheet(isPresented: $showingAddSheet) {
            ScheduleEditorSheet(schedule: nil) { newSchedule in
                scheduleManager.addSchedule(newSchedule)
            }
        }
        .sheet(item: $editingSchedule) { schedule in
            ScheduleEditorSheet(schedule: schedule) { updatedSchedule in
                scheduleManager.updateSchedule(updatedSchedule)
            }
        }
        .alert("Delete Schedule", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let schedule = scheduleToDelete {
                    scheduleManager.deleteSchedule(id: schedule.id)
                }
            }
        } message: {
            Text("Are you sure you want to delete '\(scheduleToDelete?.name ?? "")'? This cannot be undone.")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            Text("No Scheduled Syncs")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Create a schedule to automatically sync your files at regular intervals.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)

            Button(action: { showingAddSheet = true }) {
                Label("Create Schedule", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var scheduleList: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Next sync info
                if let next = scheduleManager.nextScheduledRun {
                    GroupBox {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Next Sync")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(next.schedule.name)
                                    .fontWeight(.medium)
                            }
                            Spacer()
                            Text(next.schedule.formattedNextRun)
                                .foregroundColor(.secondary)
                        }
                        .padding(4)
                    }
                    .padding(.horizontal)
                }

                // Schedule list
                ForEach(scheduleManager.schedules) { schedule in
                    ScheduleRowView(
                        schedule: schedule,
                        onToggle: { scheduleManager.toggleSchedule(id: schedule.id) },
                        onEdit: { editingSchedule = schedule },
                        onDelete: {
                            scheduleToDelete = schedule
                            showDeleteConfirmation = true
                        },
                        onRunNow: {
                            Task {
                                await scheduleManager.runNow(id: schedule.id)
                            }
                        }
                    )
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
}

#Preview {
    SchedulesView()
}
```

---

## Task 3: Remove Schedules Tab from SettingsView

**File:** `CloudSyncApp/SettingsView.swift`

### Step 3.1: Remove Schedules tab (delete lines 34-38)

Remove the entire ScheduleSettingsView tab:

```swift
// DELETE THIS ENTIRE BLOCK (lines 34-38)
ScheduleSettingsView()
    .tabItem {
        Label("Schedules", systemImage: "calendar.badge.clock")
    }
    .tag(3)
```

### Step 3.2: Update About tab tag (line 40 after deletion)

Change About's tag from 4 to 3:

```swift
AboutView()
    .tabItem {
        Label("About", systemImage: "info.circle")
    }
    .tag(3)  // CHANGE FROM 4 to 3
```

### Step 3.3: Remove SelectSchedulesTab notification handler (delete lines 55-57)

Remove the entire `.onReceive` block for SelectSchedulesTab:

```swift
// DELETE THIS ENTIRE BLOCK
.onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SelectSchedulesTab"))) { _ in
    selectedTab = 3  // Schedules tab
}
```

### Step 3.4: Adjust frame height (line 54)

Reduce the height since we have fewer tabs:

```swift
.frame(width: 600, height: 540)  // CHANGE FROM 580 to 540
```

---

## Task 4: Add SchedulesView to Xcode Project

After creating `SchedulesView.swift`, the Lead Agent will add it to the Xcode project's build sources during integration.

---

## Files Summary

| File | Action | Changes |
|------|--------|---------|
| `Views/MainWindow.swift` | Modify | Add schedules to enum, sidebar, detailView, update notification |
| `Views/SchedulesView.swift` | Create | New main window schedules view |
| `SettingsView.swift` | Modify | Remove Schedules tab, update tag numbers, remove notification handler |

---

## Acceptance Criteria

- [ ] "Schedules" appears in main window sidebar (between Tasks and History)
- [ ] Clicking Schedules shows schedule management UI in main content area
- [ ] Settings has 4 tabs: General, Accounts, Sync, About
- [ ] Menu bar "Manage Schedules..." opens main window to Schedules section
- [ ] Add/Edit/Delete schedule functionality works
- [ ] Empty state shows when no schedules
- [ ] Build succeeds with zero errors

---

## When Complete

1. Update STATUS.md with completion status
2. Write DEV1_COMPLETE.md with:
   - Files modified/created
   - Summary of changes
   - Build verification result
3. Verify build: `xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build`
