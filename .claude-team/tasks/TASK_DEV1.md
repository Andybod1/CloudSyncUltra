# Dev-1 Task: Accessibility Support

**Sprint:** Maximum Productivity
**Priority:** Medium
**Worker:** Dev-1 (UI Layer)

---

## Objective

Add VoiceOver accessibility labels and keyboard shortcuts to main views for users with disabilities.

## Files to Modify

- `CloudSyncApp/Views/DashboardView.swift`
- `CloudSyncApp/Views/TransferView.swift`
- `CloudSyncApp/Views/FileBrowserView.swift`
- `CloudSyncApp/Views/TasksView.swift`
- `CloudSyncApp/Views/SettingsView.swift`

## Tasks

### 1. Add VoiceOver Labels

Add `.accessibilityLabel()` and `.accessibilityHint()` to all interactive elements:

```swift
// Example for buttons
Button(action: startTransfer) {
    Image(systemName: "arrow.right.circle.fill")
}
.accessibilityLabel("Start Transfer")
.accessibilityHint("Double-tap to begin transferring selected files")

// Example for status indicators
Circle()
    .fill(isConnected ? .green : .red)
.accessibilityLabel(isConnected ? "Connected" : "Disconnected")
.accessibilityValue(remoteName)
```

### 2. Add Keyboard Shortcuts

Create keyboard shortcuts for common actions:

```swift
// In main window or appropriate view
.keyboardShortcut("n", modifiers: .command)  // New folder
.keyboardShortcut("r", modifiers: .command)  // Refresh
.keyboardShortcut("t", modifiers: .command)  // Start transfer
.keyboardShortcut(",", modifiers: .command)  // Settings
.keyboardShortcut("d", modifiers: .command)  // Dashboard
```

### 3. Key Areas to Cover

**DashboardView:**
- Provider cards: accessibility label with provider name and status
- Quick action buttons: labels and hints
- Statistics: value descriptions

**TransferView:**
- Source/destination panes: accessibility labels
- File selection: announce selected count
- Transfer button: state-dependent label
- Progress indicator: announce percentage

**FileBrowserView:**
- File rows: label with name, size, type
- Navigation breadcrumbs: announce path
- Context menu items: clear labels
- Empty state: descriptive message

**TasksView:**
- Task cards: status, progress, name
- Action buttons: pause, resume, cancel labels
- Filter controls: current filter state

**SettingsView:**
- All toggles and pickers: clear labels
- Section headers: group accessibility

### 4. Add accessibilityElement Grouping

Group related elements:
```swift
HStack {
    Image(...)
    VStack {
        Text(fileName)
        Text(fileSize)
    }
}
.accessibilityElement(children: .combine)
.accessibilityLabel("\(fileName), \(fileSize)")
```

## Verification

1. Enable VoiceOver (⌘ + F5)
2. Navigate through each view
3. Verify all elements are announced properly
4. Test keyboard shortcuts work

## Output

Write completion report to: `/Users/antti/Claude/.claude-team/outputs/DEV1_COMPLETE.md`

Include:
- List of files modified
- Keyboard shortcuts added
- VoiceOver coverage summary

## Success Criteria

- [ ] All interactive elements have accessibility labels
- [ ] Keyboard shortcuts for common actions
- [ ] VoiceOver navigation works smoothly
- [ ] Build succeeds
