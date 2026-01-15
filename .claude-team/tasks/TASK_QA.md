# QA Task: Test Automation & Onboarding Validation

**Sprint:** Launch Ready (v2.0.21)
**Created:** 2026-01-15
**Worker:** QA
**Model:** Opus (always use /think)
**Issues:** #27, Onboarding validation

---

## Context

We just fixed several onboarding UX issues (click detection, scrolling, card sizing). These need validation. Additionally, test automation (#27) is HIGH priority for sustainable quality.

---

## Your Files (Exclusive Ownership)

```
CloudSyncAppTests/
CloudSyncAppUITests/
```

---

## Objectives

### Priority 1: Onboarding Validation (Immediate)

**Test the fixes from yesterday:**

| View | Test Case | Expected |
|------|-----------|----------|
| AddProviderStepView | Click provider card | Card highlights, Connect button activates |
| AddProviderStepView | Click "Show All 40+ Providers" | Grid expands, scrollable |
| AddProviderStepView | Scroll expanded grid | Navigation buttons stay fixed at bottom |
| AddProviderStepView | Select provider + Click Connect | Advances to next step |
| CompletionStepView | Quick Tips cards | All 3 same size |
| Full Flow | Welcome → Provider → Sync → Complete | No crashes, all transitions work |

**Report any issues found immediately.**

### Priority 2: Issue #27 - Test Automation

**Current State:**
- 762 unit tests passing
- 69 UI tests integrated
- UI tests require Xcode GUI (Gatekeeper limitation)

**Goals:**
1. Expand unit test coverage for critical paths
2. Add tests for recently added features:
   - Onboarding flow
   - Dynamic parallelism
   - Provider icons
3. Document test gaps
4. Create test plan for #10, #20 (other sprint work)

**Test Coverage Priorities:**
1. OnboardingViewModel - state transitions, persistence
2. TransferOptimizer - parallelism calculations
3. ProviderIconView - all provider types
4. Error handling paths

---

## Deliverables

1. [ ] Onboarding validation report
2. [ ] New tests for onboarding
3. [ ] Test gap analysis
4. [ ] Test plans for #10, #20
5. [ ] Tests pass (target: maintain 762+)
6. [ ] Commit with descriptive message

---

## Commands

```bash
# Run all tests
cd ~/Claude && xcodebuild test -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -destination 'platform=macOS' 2>&1 | grep -E "Executed|passed|failed"

# Run specific test file
xcodebuild test -only-testing:CloudSyncAppTests/OnboardingViewModelTests -destination 'platform=macOS'

# Check test coverage
find CloudSyncAppTests -name "*.swift" | xargs wc -l
```

---

*Report onboarding validation results first, then proceed with #27*
