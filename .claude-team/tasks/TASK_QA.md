# TASK: iCloud Phase 1 Testing (#9)

## Worker: QA
## Size: S
## Model: Opus (always for QA)
## Ticket: #9

**Use extended thinking (`/think`) for test design.**

**Wait for Dev-1 and Dev-3 to complete first.**

---

## Objective

Test iCloud local folder integration (Phase 1).

---

## Test Cases

### TC-1: Local iCloud Detection (Dev-3 work)

| Test | Steps | Expected |
|------|-------|----------|
| TC-1.1 | Check `CloudProvider.isLocalICloudAvailable` on Mac with iCloud | Returns `true` |
| TC-1.2 | Check `CloudProvider.iCloudLocalPath` | Points to `~/Library/Mobile Documents/com~apple~CloudDocs` |
| TC-1.3 | Check rclone type for iCloud | Returns `iclouddrive` |

### TC-2: UI Flow (Dev-1 work)

| Test | Steps | Expected |
|------|-------|----------|
| TC-2.1 | Open Add Cloud Storage → Select iCloud | Shows connection method options |
| TC-2.2 | Check Local Folder option availability | Green checkmark if iCloud folder exists |
| TC-2.3 | Check Apple ID option | Shows "Coming soon", disabled |
| TC-2.4 | Click Local Folder option | Creates remote successfully |

### TC-3: Local iCloud Browsing

| Test | Steps | Expected |
|------|-------|----------|
| TC-3.1 | Add iCloud local → Browse root | Shows iCloud Drive contents |
| TC-3.2 | Navigate into subfolder | Can enter and list subfolders |
| TC-3.3 | View file details | Shows size, date correctly |

### TC-4: Local iCloud Sync

| Test | Steps | Expected |
|------|-------|----------|
| TC-4.1 | Upload file to iCloud | File appears in Finder iCloud folder |
| TC-4.2 | Download file from iCloud | File saves to local destination |
| TC-4.3 | Delete file from iCloud | File removed (if supported) |

### TC-5: Edge Cases

| Test | Steps | Expected |
|------|-------|----------|
| TC-5.1 | Test on Mac without iCloud signed in | Shows error message, option disabled |
| TC-5.2 | Cancel during setup | Returns to provider list cleanly |
| TC-5.3 | Add iCloud twice | Handles duplicate gracefully |

---

## Unit Tests to Add

Create test file: `CloudSyncAppTests/ICloudIntegrationTests.swift`

```swift
import XCTest
@testable import CloudSyncApp

final class ICloudIntegrationTests: XCTestCase {
    
    func testRcloneTypeIsICloudDrive() {
        XCTAssertEqual(CloudProvider.icloud.rcloneType, "iclouddrive")
    }
    
    func testICloudLocalPath() {
        let expected = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Mobile Documents/com~apple~CloudDocs")
        XCTAssertEqual(CloudProvider.iCloudLocalPath, expected)
    }
    
    func testICloudIsSupported() {
        XCTAssertTrue(CloudProvider.icloud.isSupported)
    }
    
    func testICloudDisplayName() {
        XCTAssertEqual(CloudProvider.icloud.displayName, "iCloud Drive")
    }
}
```

---

## Output

Write test results to:
`/Users/antti/Claude/.claude-team/outputs/QA_COMPLETE.md`

Include:
- Test results table (Pass/Fail)
- Any bugs found
- Screenshots if relevant
- Unit test results

Update STATUS.md when starting and completing.

---

## Acceptance Criteria

- [ ] All manual tests executed
- [ ] Unit tests created and passing
- [ ] Any bugs reported as GitHub issues
- [ ] Test report written
