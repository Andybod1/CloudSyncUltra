# Dev-1 Task: Bug Fixes + UI Quick Wins

## Issues
- #28 (Critical): UI freezes in left pane
- #26 (High): Move schedules position
- #19 (Low): Remove seconds from completed tasks

---

## Task 1: Fix UI Freezing in Left Pane (#28)

### Problem
Left pane sidebar freezes intermittently when clicking cloud service items. Clicks don't register, but app otherwise works. Recovers after clicking elsewhere.

### Investigation
1. Check `MainWindow.swift` sidebar List selection binding
2. Look for state conflicts or async issues
3. Verify ForEach uses stable IDs

### Likely Fix
```swift
// Ensure selection binding is simple
@State private var selectedRemote: CloudRemote.ID?

// Use explicit button for selection (more reliable)
ForEach(remotes, id: \.id) { remote in
    Button {
        selectedRemote = remote.id
    } label: {
        RemoteRowView(remote: remote)
    }
    .buttonStyle(.plain)
}
```

### Files
- `CloudSyncApp/Views/MainWindow.swift`

---

## Task 2: Move Schedules Position (#26)

### Problem
Schedules should appear between Transfer and Tasks in sidebar.

### Fix
Reorder sidebar items:
```
Transfer
Schedules  ← move here
Tasks
History
```

### Files
- `CloudSyncApp/Views/MainWindow.swift` - Reorder enum or list

---

## Task 3: Remove Seconds from Completed Tasks (#19)

### Problem
Completed tasks show seconds counting up - too noisy. Minutes granularity is enough.

### Fix
```swift
func formatCompletionTime(_ date: Date) -> String {
    let interval = Date().timeIntervalSince(date)
    
    if interval < 60 {
        return "Just now"
    } else if interval < 3600 {
        let mins = Int(interval / 60)
        return "\(mins) min\(mins == 1 ? "" : "s") ago"
    } else if interval < 86400 {
        let hours = Int(interval / 3600)
        return "\(hours) hour\(hours == 1 ? "" : "s") ago"
    } else {
        return date.formatted(date: .abbreviated, time: .shortened)
    }
}
```

### Files
- `CloudSyncApp/Views/TasksView.swift`

---

## Completion Checklist
- [ ] #28: UI freezing fixed
- [ ] #26: Schedules moved in sidebar
- [ ] #19: Time format updated
- [ ] All changes compile
- [ ] Update STATUS.md when done

## Commits
Reference issues in commits:
```
git commit -m "fix(ui): Fix sidebar selection freezing - Fixes #28"
git commit -m "fix(ui): Move schedules between transfer and tasks - Fixes #26"
git commit -m "fix(ui): Show relative time without seconds - Fixes #19"
```
