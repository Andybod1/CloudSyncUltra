# Task: Phase 2 UI Fixes (#109, #112, #110, #104)

## Worker: Dev-1 (UI)
## Priority: MEDIUM
## Size: M (1-2 hrs total)

---

## Overview

All Phase 2 tasks involve Views/ files which are Dev-1's domain.

Complete these in order:

1. ✅ #101 - Onboarding Connect (COMPLETED)
2. ✅ #103 - Custom Performance Profile (COMPLETED)
3. 🎯 #109 + #112 - Encryption Terminology
4. ⚪ #110 - Remote Name Auto-Update
5. ⚪ #104 - Duplicate Progress Bars

---

## Task 1: Fix Encryption Terminology (#109 + #112)

### Files to Modify

1. **CloudSyncApp/Views/FileBrowserView.swift**
   - Line ~186: `"Enable Decryption"` → `"Enable Encryption"`
   - Line ~191: accessibilityLabel `"Enable Decryption"` → `"Enable Encryption"`
   - Line ~192: accessibilityHint - update to match

2. **CloudSyncApp/SettingsView.swift**
   - Line ~1125: Update encryption toggle description

### Specific Changes

```swift
// FileBrowserView.swift line ~186
// BEFORE: Button("Enable Decryption")
// AFTER:  Button("Enable Encryption")

// FileBrowserView.swift line ~191-192
// BEFORE: .accessibilityLabel("Enable Decryption")
// AFTER:  .accessibilityLabel("Enable Encryption")
// BEFORE: .accessibilityHint("Switches to decrypted view...")
// AFTER:  .accessibilityHint("Enables encryption to protect your files")

// SettingsView.swift line ~1125
// BEFORE: Label("Toggle ON to see decrypted, OFF to see raw", systemImage: "eye")
// AFTER:  Label("Toggle ON to encrypt files, OFF to view raw", systemImage: "eye")
```

---

## Task 2: Remote Name Auto-Update (#110)

### Issue
When selecting a cloud provider, the "Remote Name" field doesn't update.

### File to Modify
Find the Add Cloud dialog in Views/ (likely AddCloudView.swift or AddRemoteSheet.swift)

### Solution
```swift
.onChange(of: selectedProvider) { _, newProvider in
    if let provider = newProvider {
        remoteName = provider.displayName
    }
}
```

---

## Task 3: Remove Duplicate Progress Bars (#104)

### Issue
Tasks view shows running task twice - in RunningTaskIndicator AND in Active section.

### File to Modify
**CloudSyncApp/Views/TasksView.swift** line ~158

### Solution
```swift
// BEFORE:
ForEach(tasksVM.tasks) { task in

// AFTER:
ForEach(tasksVM.tasks.filter { $0.state != .running }) { task in
```

---

## Quality Requirements

Before marking each task complete:
1. Run `./scripts/worker-qa.sh`
2. Build must SUCCEED
3. Test the specific fix manually if possible

## Constraints

- Only modify files in YOUR domain (Views/, ViewModels/, Components/)
- DO NOT create new types - use existing ones from TYPE_INVENTORY.md
- DO NOT refactor beyond the specific fixes

---

*Last Updated: 2026-01-16*
