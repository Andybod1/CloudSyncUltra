# QA Task: Post-Cleanup Verification & Test Suite Integration

**Created:** 2026-01-14 22:10
**RETRY:** 2026-01-14 22:35 - Quarantine issue fixed with `xattr -cr`
**Worker:** QA
**Model:** Opus with /think
**Priority:** High

---

## Context

Project cleanup was just completed - all unused files archived. All 743 unit tests pass. Need to verify app functionality and address high-priority test integration issue.

---

## Objectives

### Phase 1: Post-Cleanup Smoke Test (15 min)

1. **Build & Launch Verification**
   - Clean build the app: `xcodebuild clean build -scheme CloudSyncApp -destination 'platform=macOS'`
   - Launch CloudSyncApp and verify it opens correctly
   - Check Console.app for any errors on launch

2. **Core Feature Smoke Test**
   - Open Settings → verify all tabs load
   - Open Providers → verify list renders
   - Check Dashboard → verify no crashes
   - Verify menu bar icon appears

3. **Document any issues found**

### Phase 2: GitHub Issue #88 - UI Test Integration (Main Task)

**Issue:** [Feature] Integrate UI test suite into Xcode project
**Priority:** High
**Component:** Tests

**Background:**
We have UI tests in `CloudSyncAppUITests/` but need to verify they're properly integrated into the Xcode project and can run via `xcodebuild test`.

**Tasks:**
1. Verify CloudSyncAppUITests target exists in project
2. Check UI test files are included in target
3. Attempt to run UI tests: 
   ```bash
   xcodebuild test -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -destination 'platform=macOS' -only-testing:CloudSyncAppUITests
   ```
4. Document what works and what fails
5. If tests fail, investigate and fix configuration issues
6. Create/update test documentation

---

## Files You Own

```
CloudSyncAppTests/          # All test files
CloudSyncAppUITests/        # UI test files  
docs/TEST_*.md              # Test documentation
```

---

## Deliverables

1. **SMOKE_TEST_REPORT.md** in `.claude-team/outputs/`
   - Build status
   - Launch verification
   - Feature smoke test results
   - Issues found (if any)

2. **UI Test Integration Status**
   - Whether UI tests run successfully
   - Any fixes applied
   - Remaining issues

3. **Git commits** for any fixes made

---

## Commands Reference

```bash
# Build
xcodebuild clean build -scheme CloudSyncApp -destination 'platform=macOS'

# Run unit tests
xcodebuild test -scheme CloudSyncApp -destination 'platform=macOS' -only-testing:CloudSyncAppTests

# Run UI tests  
xcodebuild test -scheme CloudSyncApp -destination 'platform=macOS' -only-testing:CloudSyncAppUITests

# Launch app
open /Users/antti/Claude/CloudSyncApp.xcodeproj
# Then Cmd+R in Xcode
```

---

## Notes

- Use /think for complex debugging decisions
- Document everything - we maintain comprehensive records
- If UI tests need significant fixes, create follow-up tickets
- Update CHANGELOG.md if you make code changes
