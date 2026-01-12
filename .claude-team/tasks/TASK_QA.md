# Task: Move Schedules to Main Window - QA Verification

**Assigned to:** QA (Testing)
**Priority:** Medium
**Status:** Ready
**Depends on:** Dev-1 completing UI changes

---

## Objective

Verify the Schedules UI migration works correctly and review Dev-1's code.

---

## Task 1: Code Review

Review Dev-1's changes for:
- Clean SwiftUI patterns
- Proper state management
- No memory leaks (@StateObject vs @ObservedObject usage)
- Correct navigation handling

---

## Task 2: Manual Verification Checklist

After Dev-1 completes, verify:

- [ ] Schedules appears in main window sidebar
- [ ] Clicking Schedules shows schedule list
- [ ] Add Schedule button works
- [ ] Edit schedule works (tap on schedule)
- [ ] Delete schedule works (context menu)
- [ ] Enable/disable works (context menu)
- [ ] Run Now works (context menu)
- [ ] Empty state shows when no schedules
- [ ] Settings has only 4 tabs (no Schedules)
- [ ] Menu bar "Manage Schedules..." opens main window to Schedules

---

## Task 3: Build Verification

```bash
cd /Users/antti/Claude && xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build 2>&1 | tail -10
```

---

## When Complete

Update STATUS.md and write report to `outputs/QA_REPORT.md`

---

## Report Template

```markdown
# QA Report

**Feature:** Move Schedules to Main Window
**Status:** COMPLETE

## Code Review
- Dev-1 implementation reviewed: [PASS/ISSUES]
- Issues found: [None or list]

## Verification
- All checklist items: [PASS/FAIL]
- Issues found: [None or list]

## Build Status
BUILD SUCCEEDED
```
