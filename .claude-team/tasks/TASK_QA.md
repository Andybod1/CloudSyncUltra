# TASK: Fix 23 Pre-existing Test Failures (#35)

## Worker: QA
## Size: M
## Model: Opus (ALWAYS for QA)
## Extended Thinking: ENABLED (ALWAYS for QA)

---

## Problem
Running `xcodebuild test` shows 617 tests with 23 failures. These are pre-existing issues from outdated expectations.

## Failing Tests Analysis

### Category 1: Provider Count Tests (5 tests)
**Root cause:** Provider count increased from 19→27→33→42
**Files:** `Phase1Week1ProvidersTests.swift`, `Phase1Week2ProvidersTests.swift`, `Phase1Week3ProvidersTests.swift`
**Fix:** Update expected counts to 42

### Category 2: Experimental Provider Tests (4 tests)
**Root cause:** Jottacloud no longer marked experimental
**Files:** `CloudSyncUltraIntegrationTests.swift`
**Fix:** Update or remove experimental provider expectations

### Category 3: File Formatting Tests (5 tests)
**Root cause:** Locale-dependent formatting ("500 bytes" vs "500 B", "5,2 MB" vs "5 MB")
**Files:** `FileItemTests.swift`
**Fix:** Use locale-independent assertions or mock formatters

### Category 4: Timing Tests (2 tests)
**Root cause:** Off-by-one timing edge cases
**Files:** `MenuBarScheduleTests.swift`
**Fix:** Add tolerance to timing comparisons

### Category 5: Other Failures (7 tests)
- `AddRemoteViewTests.testProviderSearchCoverage`
- `EncryptionManagerTests.testEncryptedRemoteName`
- `RemotesViewModelTests.testInitialState_HasLocalStorage`
- `RemotesViewModelTests.testFindRemote_ByType`
- `SyncManagerPhase2Tests.testStopMonitoringWithoutAutoSync`
- `TransferErrorTests.testParseOneDriveQuotaExceeded`

**Fix:** Investigate each individually and update expectations

## Commands

### Run all tests
```bash
cd /Users/antti/Claude && xcodebuild test -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -destination 'platform=macOS' 2>&1 | grep -E "Test Case|passed|failed|error:"
```

### Run specific test file
```bash
cd /Users/antti/Claude && xcodebuild test -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -destination 'platform=macOS' -only-testing:CloudSyncAppTests/FileItemTests 2>&1
```

## Acceptance Criteria
- [ ] All 617 tests pass
- [ ] No skipped tests without documentation
- [ ] Test run completes in < 60 seconds
- [ ] Changes committed with clear message

## Process
1. Run full test suite to identify current failures
2. Fix Category 1 (provider counts) - easiest wins
3. Fix Category 2 (experimental flags)
4. Fix Category 3 (formatting) - may need locale handling
5. Fix Category 4 (timing) - add tolerances
6. Fix Category 5 (other) - investigate individually
7. Run full suite again to verify all pass
8. Commit changes

## Output
Write completion report to `/Users/antti/Claude/.claude-team/outputs/QA_COMPLETE.md`
