# Task: Remove Duplicate Progress Bars in Tasks View (#104)

## Worker: Dev-3 (Services)
## Priority: MEDIUM
## Size: S (30 min - 1 hr)

---

## Issue

The Tasks view shows the same running task TWICE:
1. At the top in `RunningTaskIndicator` (compact view)
2. In the "Active" section as a full `TaskCard`

This is confusing - users may think there are 2 tasks running.

## File to Modify

**CloudSyncApp/Views/TasksView.swift**

## Root Cause

Lines 46-51 show `RunningTaskIndicator` for the running task:
```swift
if let task = runningTask {
    RunningTaskIndicator(task: task) { ... }
    Divider()
}
```

Lines 158-169 show ALL tasks (including running ones) in the Active section:
```swift
ForEach(tasksVM.tasks) { task in
    TaskCard(task: task) { ... }
}
```

## Solution Options

### Option A: Filter out running task from Active section (Recommended)
```swift
// Line ~158, change from:
ForEach(tasksVM.tasks) { task in

// To:
ForEach(tasksVM.tasks.filter { $0.state != .running }) { task in
```

### Option B: Remove RunningTaskIndicator entirely
- Delete lines 46-51
- Show all tasks only in the Active section
- Less preferred as the compact indicator is useful

### Option C: Only show RunningTaskIndicator, hide Active section when task is running
- More complex, not recommended

## Recommended: Option A

The `RunningTaskIndicator` provides a nice compact summary at top. The Active section should show pending/paused tasks but not duplicate the running one.

## Verification Steps

1. Build passes
2. Start a file transfer
3. Go to Tasks view
4. **Expected**: Running task appears ONCE at top (compact indicator)
5. **Expected**: Active section shows only pending/paused tasks (not the running one)
6. **Expected**: When task completes, it moves to Recently Completed

## Constraints

- Keep `RunningTaskIndicator` functionality
- Keep `TaskCard` for non-running tasks
- Run `./scripts/worker-qa.sh` before marking complete

## Existing Types (from TYPE_INVENTORY.md)

```swift
struct SyncTask: Identifiable, Codable
enum TaskState: String, Codable  // .running, .pending, .paused, etc.
class TasksViewModel: ObservableObject
```
