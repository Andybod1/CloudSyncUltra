# Sprint: "Launch Ready" - Parallel Execution

**Started:** 2026-01-15
**Target Version:** 2.0.24
**Status:** 🟡 IN PROGRESS

---

## Worker Status

| Worker | Status | Issues | Task File |
|--------|--------|--------|-----------|
| **QA** | 🟢 Running | #88 | TASK_QA.md |
| **Dev-1** | 🟢 Running | #80, #81, #82 | TASK_DEV1.md |
| **Dev-2** | 🟢 Running | #70, #71 | TASK_DEV2.md |
| **Dev-3** | 🟢 Running | #95, #84 | TASK_DEV3.md |
| **Dev-Ops** | 🟢 Running | #57, #47, close issues | TASK_DEVOPS.md |

---

## Issue Tracker

| # | Title | Worker | Status |
|---|-------|--------|--------|
| 88 | UI Test Integration | QA | 🟡 In Progress |
| 80 | Onboarding Step 1: Infrastructure | Dev-1 | ⚪ Ready |
| 81 | Onboarding Step 2: Add Provider | Dev-1 | ⚪ Ready |
| 82 | Onboarding Step 3: First Sync | Dev-1 | ⚪ Ready |
| 70 | Dynamic Parallelism | Dev-2 | ⚪ Ready |
| 71 | Fast-List Support | Dev-2 | ⚪ Ready |
| 95 | Provider Logos | Dev-3 | ⚪ Ready |
| 84 | Visual Polish | Dev-3 | ⚪ Ready |
| 57 | GitHub Templates | Dev-Ops | ⚪ Ready |
| 47 | Component Labels | Dev-Ops | ⚪ Ready |
| 72 | Multi-Thread Downloads | - | ✅ Done (close) |
| 90 | Notifications | - | ✅ Done (close) |
| 91 | CHANGELOG.md | - | ✅ Done (close) |
| 92 | CONTRIBUTING.md | - | ✅ Done (close) |

---

## Launch Commands

### Terminal 1 - QA (Already Running)
```
Already running
```

### Terminal 2 - Dev-1 (Onboarding)
```bash
cd /Users/antti/Claude && claude
# Then paste:
You are Dev-1 (UI worker). Read .claude-team/tasks/TASK_DEV1.md and implement the onboarding flow. Use /think for complex decisions. You own Views/ and ViewModels/.
```

### Terminal 3 - Dev-2 (Performance)
```bash
cd /Users/antti/Claude && claude
# Then paste:
You are Dev-2 (Engine worker). Read .claude-team/tasks/TASK_DEV2.md and implement performance optimizations. Use /think for algorithm decisions. You own RcloneManager.swift and TransferOptimizer.swift.
```

### Terminal 4 - Dev-3 (Assets)
```bash
cd /Users/antti/Claude && claude
# Then paste:
You are Dev-3 (Services worker). Read .claude-team/tasks/TASK_DEV3.md and implement provider icons and visual polish. Use /think for design decisions. You own Models/, Services/*Manager.swift (except Rclone), and Assets.xcassets/.
```

### Terminal 5 - Dev-Ops (Housekeeping)
```bash
cd /Users/antti/Claude && claude
# Then paste:
You are Dev-Ops worker. Read .claude-team/tasks/TASK_DEVOPS.md and execute. Close completed issues, add GitHub templates. Use /think. You own .github/, CHANGELOG.md, and docs/.
```

---

## Integration Checklist (After Workers Complete)

- [ ] All workers report completion
- [ ] Run full test suite: `xcodebuild test -scheme CloudSyncApp -destination 'platform=macOS'`
- [ ] Build and launch app
- [ ] Verify onboarding flow works
- [ ] Verify performance settings apply
- [ ] Verify provider icons display correctly
- [ ] Check GitHub templates work
- [ ] Update CHANGELOG.md with final entries
- [ ] Update version to 2.0.20
- [ ] Commit, tag, push

---

## Notes

- No file conflicts between workers (domains separated)
- QA started first to validate post-cleanup state
- Dev-Ops can help with integration after completing housekeeping
- Strategic Partner monitors and integrates

---

*Last Updated: 2026-01-14 22:25*
