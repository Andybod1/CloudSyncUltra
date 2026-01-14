# TASK: Fix 11 Failing Unit Tests

**Worker:** QA
**Model:** Opus + /think (mandatory)
**Issue:** #87
**Priority:** Critical

---

## Objective

Fix the 11 failing unit tests to achieve 100% pass rate (743/743).

---

## Steps

### 1. Run Tests & Capture Failures
```bash
cd /Users/antti/Claude
xcodebuild test -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -destination 'platform=macOS' 2>&1 | tee test-output.txt
```

### 2. Identify Failing Tests
```bash
grep -E "failed|error:|FAILED" test-output.txt
```

### 3. Analyze Each Failure
Use /think to analyze:
- What is the test testing?
- Why is it failing?
- Is it a test bug or code bug?

### 4. Fix Each Test
For each failing test:
- If test is outdated → Update test expectations
- If code is wrong → Fix the code (coordinate with Dev-1/2/3 if needed)
- If test is flaky → Make it deterministic

### 5. Verify All Pass
```bash
xcodebuild test -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -destination 'platform=macOS' 2>&1 | grep -E "Executed|passed|failed"
```

Expected output: `Executed 743 tests, with 0 failures`

---

## Deliverables

1. All 743 tests passing
2. Output file: `.claude-team/outputs/QA_TEST_FIX_COMPLETE.md`
   - List of tests fixed
   - Root cause for each
   - Changes made
3. Update STATUS.md when done

---

## Completion

When done:
```bash
# Update status
# Commit changes
cd /Users/antti/Claude
git add -A
git commit -m "fix: Resolve 11 failing unit tests (#87)"

# Mark issue
gh issue comment 87 -b "Fixed all 11 failing tests. See QA_TEST_FIX_COMPLETE.md for details."
```

Then notify Strategic Partner that task is complete.
