# Task: Fix Encryption Terminology (#109 + #112)

## Worker: Dev-1 (UI)
## Priority: MEDIUM
## Size: XS (< 30 min)

---

## Issue

Button says "Enable Decryption" when it should say "Enable Encryption". Also some help text uses "decrypted" incorrectly.

## Files to Modify

1. **CloudSyncApp/Views/FileBrowserView.swift**
   - Line 186: `"Enable Decryption"` → `"Enable Encryption"`
   - Line 191: accessibilityLabel `"Enable Decryption"` → `"Enable Encryption"`
   - Line 192: accessibilityHint - update to match

2. **CloudSyncApp/SettingsView.swift**
   - Line 1125: `"Toggle ON to see decrypted, OFF to see raw"` → Better wording needed

## DO NOT Change (These are correct)

- `TasksView.swift` lines 837, 839 - These correctly describe decrypting FROM an encrypted source
- `HelpManager.swift` line 383 - Correctly describes decryption process
- `FileBrowserView.swift` line 42 comment - Internal documentation is fine
- `FileBrowserView.swift` line 567 help text - This is explaining the toggle behavior

## Specific Changes

### FileBrowserView.swift line ~186
```swift
// BEFORE:
Button("Enable Decryption") {

// AFTER:
Button("Enable Encryption") {
```

### FileBrowserView.swift line ~191-192
```swift
// BEFORE:
.accessibilityLabel("Enable Decryption")
.accessibilityHint("Switches to decrypted view to see readable filenames")

// AFTER:
.accessibilityLabel("Enable Encryption")
.accessibilityHint("Enables encryption to protect your files")
```

### SettingsView.swift line ~1125
```swift
// BEFORE:
Label("Toggle ON to see decrypted, OFF to see raw", systemImage: "eye")

// AFTER:
Label("Toggle ON to encrypt files, OFF to view raw", systemImage: "eye")
```

## Verification

1. Build passes
2. Search for "Enable Decryption" - should find 0 results
3. Check FileBrowserView encryption button text
4. Check SettingsView encryption toggle description

## Constraints

- Only change the specific lines listed
- DO NOT refactor or change logic
- Run `./scripts/worker-qa.sh` before marking complete
