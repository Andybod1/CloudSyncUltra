# QA Task: Verify Bug Fixes Batch + Add Test Coverage

## Issues to Verify
- #28: Sidebar selection freeze fix
- #26: Schedules position change
- #19: Time format change
- #24: Jottacloud experimental badge removal

---

## Task 1: Manual Verification

### #28 - Sidebar Selection
- [ ] Click each cloud service in sidebar rapidly
- [ ] Switch between cloud services 10+ times
- [ ] Verify no freezing or unresponsive clicks
- [ ] Test with different numbers of configured remotes

### #26 - Schedules Position
- [ ] Verify sidebar order: Dashboard → Transfer → Schedules → Tasks → History
- [ ] Verify Schedules icon and label correct
- [ ] Test navigation to/from Schedules

### #19 - Time Format
- [ ] Verify completed task shows "Just now" (< 1 min)
- [ ] Wait 1-2 minutes, verify shows "1 min ago", "2 mins ago"
- [ ] Check older tasks show hours/date correctly

### #24 - Jottacloud Badge
- [ ] Open Add Cloud Storage view
- [ ] Find Jottacloud - verify NO "Experimental" badge
- [ ] If Jottacloud configured, verify no badge in sidebar

---

## Task 2: Add Unit Tests

### Test: Time Formatting (#19)
Create in `CloudSyncAppTests/TasksViewTests.swift`:

```swift
import XCTest
@testable import CloudSyncApp

class TimeFormattingTests: XCTestCase {
    
    func testJustNow() {
        let now = Date()
        let result = formatCompletionTime(now)
        XCTAssertEqual(result, "Just now")
    }
    
    func testMinutesAgo() {
        let fiveMinutesAgo = Date().addingTimeInterval(-300)
        let result = formatCompletionTime(fiveMinutesAgo)
        XCTAssertEqual(result, "5 mins ago")
    }
    
    func testOneMinuteAgo() {
        let oneMinuteAgo = Date().addingTimeInterval(-60)
        let result = formatCompletionTime(oneMinuteAgo)
        XCTAssertEqual(result, "1 min ago")
    }
    
    func testHoursAgo() {
        let twoHoursAgo = Date().addingTimeInterval(-7200)
        let result = formatCompletionTime(twoHoursAgo)
        XCTAssertEqual(result, "2 hours ago")
    }
    
    func testOneHourAgo() {
        let oneHourAgo = Date().addingTimeInterval(-3600)
        let result = formatCompletionTime(oneHourAgo)
        XCTAssertEqual(result, "1 hour ago")
    }
}
```

### Test: Jottacloud Not Experimental (#24)
Add to `CloudSyncAppTests/CloudProviderTests.swift`:

```swift
func testJottacloudNotExperimental() {
    let jottacloud = CloudProviderType.jottacloud
    XCTAssertFalse(jottacloud.isExperimental, "Jottacloud should not be marked as experimental")
}
```

### Test: Sidebar Order (#26)
Add to `CloudSyncAppTests/MainWindowTests.swift` (create if needed):

```swift
func testSidebarOrder() {
    let expectedOrder = ["Dashboard", "Transfer", "Schedules", "Tasks", "History"]
    let actualOrder = SidebarItem.allCases.map { $0.rawValue }
    XCTAssertEqual(actualOrder, expectedOrder, "Sidebar items should be in correct order")
}
```

---

## Task 3: Run All Tests

```bash
cd /Users/antti/Claude && xcodebuild test -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -destination 'platform=macOS' 2>&1 | grep -E "(Test Case|passed|failed|error:)"
```

---

## Completion Checklist
- [ ] All manual verifications pass
- [ ] Time formatting tests added and pass
- [ ] Jottacloud experimental test added and passes
- [ ] Sidebar order test added and passes
- [ ] Full test suite runs without failures
- [ ] Update STATUS.md when done

## Files to Create/Modify
- `CloudSyncAppTests/TimeFormattingTests.swift` (new)
- `CloudSyncAppTests/CloudProviderTests.swift` (add test)
- `CloudSyncAppTests/MainWindowTests.swift` (new or add test)

## Output
Write results to `/Users/antti/Claude/.claude-team/outputs/QA_REPORT.md`
