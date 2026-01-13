# TASK: iCloud Phase 1 - Local Folder Integration (#9)

## Worker: Dev-3 (Services)
## Size: S
## Model: Sonnet (S-sized)
## Ticket: #9 (Phase 1)

---

## Objective

Enable iCloud Drive access via local folder for macOS users.

---

## Task 1: Fix rclone Type Mapping

In `CloudSyncApp/Models/CloudProvider.swift`, change:
```swift
case .icloud: return "icloud"
```
To:
```swift
case .icloud: return "iclouddrive"
```

---

## Task 2: Create ICloudManager.swift

Create `CloudSyncApp/ICloudManager.swift`:

```swift
import Foundation

class ICloudManager {
    static let localFolderPath = "~/Library/Mobile Documents/com~apple~CloudDocs/"
    
    static var expandedPath: String {
        NSString(string: localFolderPath).expandingTildeInPath
    }
    
    static var isLocalFolderAvailable: Bool {
        FileManager.default.fileExists(atPath: expandedPath)
    }
    
    static var localFolderURL: URL? {
        guard isLocalFolderAvailable else { return nil }
        return URL(fileURLWithPath: expandedPath)
    }
}
```

---

## Task 3: Add Tests

Create `CloudSyncAppTests/ICloudManagerTests.swift` with basic tests.

---

## Output

Write to `/Users/antti/Claude/.claude-team/outputs/DEV3_COMPLETE.md`
