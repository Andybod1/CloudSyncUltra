# QA Task: Parallel Test Development for Phase 2

## Model: Opus (parallel with Dev-2 and Dev-1)

## Sprint Context
**PARALLEL EXECUTION with Phase 2**
While Dev-2 and Dev-1 are implementing error handling, you're writing tests for their work.

---

## Objective
Write tests for TransferError (Phase 1 complete) and prepare integration tests for Phase 2 work (RcloneManager + ErrorBanner).

## Phase 2a: TransferError Tests (Start Immediately)

Dev-3 just finished TransferError.swift. Write comprehensive tests NOW.

### Create: TransferErrorTests.swift

**Location:** `/Users/antti/Claude/CloudSyncAppTests/TransferErrorTests.swift`

**Tests to write (15-20 tests):**

1. **User Message Tests** (5 tests)
   - Test quota exceeded message
   - Test rate limit with retry-after
   - Test authentication failed message
   - Test connection timeout message
   - Test file too large message

2. **Title Tests** (5 tests)
   - Verify all error types have titles
   - Test title consistency

3. **Retryable Classification** (5 tests)
   - Test retryable errors (timeout, rate limit)
   - Test non-retryable errors (quota, auth)

4. **Critical Classification** (3 tests)
   - Test critical errors
   - Test non-critical errors

5. **Pattern Parsing** (10 tests)
   - Parse Google Drive quota error
   - Parse Dropbox storage error
   - Parse OneDrive quota error
   - Parse rate limit with retry-after
   - Parse connection timeout
   - Parse token expired
   - Parse authentication failed
   - Parse DNS failure
   - Parse checksum mismatch
   - Parse generic error

6. **Codable Tests** (2 tests)
   - Test encoding/decoding various error types

**Time estimate:** 60-90 minutes

---

## Phase 2b: Integration Test Preparation

While Dev-2 and Dev-1 work, prepare test scaffolding:

### Create: RcloneManagerErrorTests.swift

**Location:** `/Users/antti/Claude/CloudSyncAppTests/RcloneManagerErrorTests.swift`

**Test scaffolding for Dev-2's work:**
```swift
import XCTest
@testable import CloudSyncApp

final class RcloneManagerErrorTests: XCTestCase {
    
    var manager: RcloneManager!
    
    override func setUp() {
        super.setUp()
        manager = RcloneManager.shared
    }
    
    // Test: SyncProgress has error fields
    func testSyncProgressHasErrorFields() {
        var progress = RcloneManager.SyncProgress()
        progress.error = .connectionTimeout
        progress.failedFiles = ["file1.txt"]
        progress.partialSuccess = true
        
        XCTAssertNotNil(progress.error)
        XCTAssertEqual(progress.failedFiles.count, 1)
        XCTAssertTrue(progress.partialSuccess)
    }
    
    // Test: Partial success detection
    func testPartialSuccessDetection() {
        var progress = RcloneManager.SyncProgress()
        progress.totalFiles = 10
        progress.filesTransferred = 7
        progress.failedFiles = ["file8.txt", "file9.txt", "file10.txt"]
        
        progress.partialSuccess = progress.filesTransferred > 0 && 
                                  progress.filesTransferred < progress.totalFiles
        
        XCTAssertTrue(progress.partialSuccess)
    }
    
    // More tests will be added as Dev-2 implements...
}
```

**Time estimate:** 30 minutes

---

## Phase 2c: UI Test Preparation

### Create: ErrorNotificationManagerTests.swift

**Location:** `/Users/antti/Claude/CloudSyncAppTests/ErrorNotificationManagerTests.swift`

**Test scaffolding for Dev-1's work:**
```swift
import XCTest
@testable import CloudSyncApp

@MainActor
final class ErrorNotificationManagerTests: XCTestCase {
    
    var manager: ErrorNotificationManager!
    
    override func setUp() {
        super.setUp()
        manager = ErrorNotificationManager()
    }
    
    // Test: Show error adds to active errors
    func testShowErrorAddsToActiveErrors() {
        let error = TransferError.connectionTimeout
        manager.show(error)
        
        XCTAssertEqual(manager.activeErrors.count, 1)
        XCTAssertEqual(manager.activeErrors[0].error, error)
    }
    
    // Test: Dismiss removes error
    func testDismissRemovesError() {
        let error = TransferError.connectionTimeout
        manager.show(error)
        
        let notificationId = manager.activeErrors[0].id
        manager.dismiss(notificationId)
        
        XCTAssertEqual(manager.activeErrors.count, 0)
    }
    
    // More tests will be added as Dev-1 implements...
}
```

**Time estimate:** 30 minutes

---

## Execution Strategy

**Hour 1: TransferError Tests (Immediate)**
- Write all TransferError tests
- These can run NOW since Phase 1 is complete
- Verify Dev-3's implementation quality

**Hour 2: Integration Test Scaffolding**
- Prepare RcloneManager test file
- Prepare ErrorNotificationManager test file
- Write basic tests based on specs

**When Dev-2 Completes:**
- Add comprehensive RcloneManager tests
- Test error parsing logic
- Test progress stream error handling

**When Dev-1 Completes:**
- Add comprehensive ErrorNotificationManager tests
- Test auto-dismiss
- Test retry functionality

---

## Deliverables

By end of Phase 2, you should have:
- ✅ TransferErrorTests.swift (20+ tests)
- ✅ RcloneManagerErrorTests.swift (scaffolding + 5+ tests)
- ✅ ErrorNotificationManagerTests.swift (scaffolding + 5+ tests)
- ✅ All tests pass
- ✅ Build succeeds

## Completion Report

Create: `/Users/antti/Claude/.claude-team/outputs/QA_PHASE2_REPORT.md`

```markdown
# QA Phase 2 Report

**Task:** Parallel Test Development
**Status:** COMPLETE

## Tests Created

### TransferErrorTests.swift (20+ tests)
- User message tests
- Pattern parsing tests
- Classification tests
- Codable tests

### RcloneManagerErrorTests.swift (5+ tests)
- SyncProgress field tests
- Partial success detection
- Error field validation

### ErrorNotificationManagerTests.swift (5+ tests)
- Show/dismiss functionality
- Active errors tracking
- Basic state management

## Build Status
BUILD SUCCEEDED

## Coverage
- TransferError: 90%+
- Foundation for Phase 3 tests

## Ready for Phase 3
✅ Test foundation solid
✅ Can expand as implementations complete
```

---

## Time Estimate
2 hours parallel with Dev-2 and Dev-1

**START IMMEDIATELY - don't wait for Phase 2 to complete!**
