# TASK: iCloud Phase 1 - UI Integration (#9)

## Worker: Dev-1 (UI)
## Size: S
## Model: Sonnet (S-sized)
## Ticket: #9 (Phase 1)

**Depends on:** Dev-3 completing ICloudManager

---

## Objective

Add UI support for local iCloud Drive folder access.

---

## Task 1: Update Add Remote Flow

In `MainWindow.swift`, update the iCloud case in the setup switch:

```swift
case .icloud:
    // Check if local iCloud folder available
    if ICloudManager.isLocalFolderAvailable {
        // Setup as alias to local folder
        try await rclone.setupLocalAlias(
            remoteName: rcloneName,
            path: ICloudManager.expandedPath
        )
    } else {
        throw CloudSyncError.iCloudNotAvailable
    }
```

---

## Task 2: Add Helper Text

Update the helper text for iCloud in the setup dialog:

```swift
case .icloud:
    if ICloudManager.isLocalFolderAvailable {
        Text("iCloud Drive will sync via your local iCloud folder.")
            .foregroundColor(.secondary)
    } else {
        Text("iCloud Drive is not available. Please sign in to iCloud in System Settings.")
            .foregroundColor(.red)
    }
```

---

## Task 3: Add Error Type

In appropriate error file, add:

```swift
enum CloudSyncError: Error {
    case iCloudNotAvailable
    // ...
}

extension CloudSyncError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .iCloudNotAvailable:
            return "iCloud Drive is not available on this Mac. Please sign in to iCloud in System Settings."
        // ...
        }
    }
}
```

---

## Task 4: Verify Provider Shows Correctly

1. iCloud should appear in provider list
2. If iCloud folder exists → setup should work
3. If iCloud folder missing → show clear error

---

## Verification

1. Build succeeds
2. Add iCloud remote works (if signed into iCloud)
3. Browse local iCloud folder contents
4. Error shown if iCloud not available

---

## Output

Write to `/Users/antti/Claude/.claude-team/outputs/DEV1_COMPLETE.md`
