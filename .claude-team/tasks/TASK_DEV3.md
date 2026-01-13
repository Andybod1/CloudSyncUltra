# TASK: iCloud Local Folder Support - Foundation (#9 Phase 1)

## Worker: Dev-3 (Services)
## Size: S
## Model: Sonnet
## Ticket: #9

---

## Objective

Fix rclone type mapping and add local iCloud folder detection.

---

## Task 1: Fix rclone Type Mapping

### File: `CloudSyncApp/Models/CloudProvider.swift`

Find the `rcloneType` property and change:
```swift
// FROM:
case .icloud: return "icloud"

// TO:
case .icloud: return "iclouddrive"
```

---

## Task 2: Add Local iCloud Detection

### File: `CloudSyncApp/Models/CloudProvider.swift` or new `ICloudManager.swift`

Add helper for detecting local iCloud folder:

```swift
// Add to CloudProvider extension or create ICloudManager.swift

extension CloudProvider {
    /// Path to local iCloud Drive folder on macOS
    static let iCloudLocalPath: URL = {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Mobile Documents/com~apple~CloudDocs")
    }()
    
    /// Check if iCloud Drive is available locally
    static var isLocalICloudAvailable: Bool {
        FileManager.default.fileExists(atPath: iCloudLocalPath.path)
    }
    
    /// Get iCloud Drive status message
    static var iCloudStatusMessage: String {
        if isLocalICloudAvailable {
            return "iCloud Drive folder detected"
        } else {
            return "iCloud Drive not found. Make sure you're signed into iCloud on this Mac."
        }
    }
}
```

---

## Task 3: Update isSupported Property

Make sure iCloud shows as supported:

```swift
var isSupported: Bool {
    switch self {
    case .icloud: return true  // Enable iCloud
    // ... other cases
    }
}
```

---

## Verification

1. Build succeeds
2. `CloudProvider.isLocalICloudAvailable` returns correct value
3. `CloudProvider.iCloudLocalPath` points to correct location

---

## Output

Write completion report to:
`/Users/antti/Claude/.claude-team/outputs/DEV3_COMPLETE.md`

Update STATUS.md when starting and completing.

---

## Acceptance Criteria

- [ ] rclone type changed to `iclouddrive`
- [ ] Local iCloud detection working
- [ ] iCloud shows as supported provider
- [ ] Build succeeds
