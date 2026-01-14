# QA Task: Fix 11 Failing Unit Tests

**Sprint:** Maximum Productivity
**Priority:** CRITICAL
**Worker:** QA (Opus recommended for debugging)

---

## Objective

Identify and fix all 11 failing unit tests. Currently 743 tests run with 11 failures.

## Context

Recent changes:
- Added OnboardingManager, OnboardingView, WelcomeStepView
- Added HelpManager, HelpCategory, HelpTopic
- Modified TransferOptimizer to require `fileCount == 1` for multi-threading
- Changed `@AppStorage` from Int64 to Int for multiThreadThreshold

## Tasks

1. **Run tests and capture failures:**
   ```bash
   cd /Users/antti/Claude && ./run_tests.sh 2>&1 | grep -E "error:|failed|XCTAssert"
   ```

2. **Identify each failing test** - Note test class and method name

3. **Analyze root cause** for each failure:
   - Is it a test expectation issue?
   - Is it a code bug?
   - Is it a missing dependency?

4. **Fix each failure** - Either:
   - Update test expectations to match correct behavior
   - Fix code bugs
   - Add missing implementations

5. **Verify all tests pass:**
   ```bash
   cd /Users/antti/Claude && ./run_tests.sh
   ```

## Known Areas to Check

- `MultiThreadDownloadTests` - Recent changes to multi-threading logic
- `TransferOptimizerTests` - Thread count expectations
- `OnboardingManagerTests` - New singleton pattern
- `HelpSystemTests` - New help system

## Output

Write completion report to: `/Users/antti/Claude/.claude-team/outputs/QA_TEST_FIXES.md`

Include:
- List of all 11 failing tests
- Root cause for each
- Fix applied
- Final test results (should show 743 passed, 0 failed)

## Success Criteria

- All 743 tests pass
- Zero failures
- No test skips or disables (fix properly)
