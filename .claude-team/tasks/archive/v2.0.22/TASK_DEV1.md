# TASK_DEV1.md - Quick Actions Menu

**Worker:** Dev-1 (UI Layer)
**Status:** ✅ COMPLETE
**Priority:** Medium  
**Size:** M (Medium - ~1.5 hours)  
**Issue:** #49

---

## Objective

Add a Quick Actions Menu accessible via Cmd+Shift+N that provides fast access to common operations.

## Features

1. **Keyboard Shortcut:** Cmd+Shift+N opens the menu
2. **Quick Actions:**
   - New Sync Task
   - New Remote
   - Open File Browser
   - View Transfers
   - Open Settings
3. **Modern Design:** Match app's visual style

## Implementation

### 1. Create QuickActionsView.swift

```swift
// CloudSyncApp/Views/QuickActionsView.swift
import SwiftUI

struct QuickActionsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    private let actions: [QuickAction] = [
        QuickAction(title: "New Sync Task", icon: "plus.circle", shortcut: "N"),
        QuickAction(title: "Add Remote", icon: "externaldrive.badge.plus", shortcut: "R"),
        QuickAction(title: "Open File Browser", icon: "folder", shortcut: "F"),
        QuickAction(title: "View Transfers", icon: "arrow.left.arrow.right", shortcut: "T"),
        QuickAction(title: "Settings", icon: "gear", shortcut: ","),
    ]
    
    var filteredActions: [QuickAction] {
        if searchText.isEmpty { return actions }
        return actions.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search actions...", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Actions list
            ScrollView {
                VStack(spacing: 4) {
                    ForEach(filteredActions) { action in
                        QuickActionRow(action: action) {
                            performAction(action)
                        }
                    }
                }
                .padding(8)
            }
        }
        .frame(width: 320, height: 280)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(12)
        .shadow(radius: 20)
    }
    
    private func performAction(_ action: QuickAction) {
        dismiss()
        // Handle action...
    }
}

struct QuickAction: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let shortcut: String
}

struct QuickActionRow: View {
    let action: QuickAction
    let onTap: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: action.icon)
                    .frame(width: 24)
                Text(action.title)
                Spacer()
                Text("⌘\(action.shortcut)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isHovered ? Color.accentColor.opacity(0.1) : Color.clear)
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}
```

### 2. Add Keyboard Shortcut to MainWindow

In `MainWindow.swift` or `CloudSyncAppApp.swift`:

```swift
.keyboardShortcut("n", modifiers: [.command, .shift])
```

### 3. Add Window/Sheet Presentation

Use a sheet or popover to present the quick actions.

## Files to Create

1. `/Users/antti/Claude/CloudSyncApp/Views/QuickActionsView.swift`

## Files to Modify

1. `/Users/antti/Claude/CloudSyncApp/MainWindow.swift` or App file - Add shortcut

## Acceptance Criteria

- [x] Cmd+Shift+N opens Quick Actions menu
- [x] Search filters actions
- [x] Clicking action performs it
- [x] ESC closes menu (sheet default behavior)
- [x] Visual style matches app theme
- [x] Build succeeds

## Testing

```bash
cd /Users/antti/Claude
xcodebuild build 2>&1 | tail -10
```

## Completion Protocol

1. Create QuickActionsView.swift
2. Add keyboard shortcut binding
3. Build and test
4. Commit: `feat(ui): Add Quick Actions menu with Cmd+Shift+N (#49)`

---

**Use /think for implementation planning.**
