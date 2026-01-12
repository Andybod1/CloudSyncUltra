# CloudSync Ultra - Crash Recovery Guide

> **All work is tracked via GitHub Issues** - survives any crash automatically.

---

## Immediate Steps After Crash

### 1. Check GitHub Issues (Your Work Queue)
```bash
cd ~/Claude

# Quick dashboard
./.github/dashboard.sh

# Or check specific states
gh issue list -l in-progress    # What was being worked on
gh issue list -l ready          # What's ready to work on
gh issue list -l triage         # What needs planning
```

### 2. Check Git Status
```bash
git status

# If uncommitted work:
git add -A && git commit -m "WIP: Recovery after crash"
```

### 3. Verify Build Works
```bash
xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build 2>&1 | tail -10
```

---

## Restore Strategic Partner Context

In a new Desktop Claude chat, say:

```
Read these files to restore context for CloudSync Ultra:

1. /Users/antti/Claude/.claude-team/PROJECT_CONTEXT.md
2. /Users/antti/Claude/.claude-team/STATUS.md
3. /Users/antti/Claude/CHANGELOG.md

Then tell me what state we're in and what needs to happen next.
```

---

## Resume Workers (If Mid-Task)

```bash
~/Claude/.claude-team/scripts/launch_workers.sh
```

Check which tasks exist:
```bash
ls ~/Claude/.claude-team/tasks/
```

---

## State Recovery Sources

| Source | What It Shows | Command |
|--------|---------------|---------|
| **GitHub Issues** | All tracked work (crash-proof) | `gh issue list` |
| STATUS.md | Worker status at crash | `cat .claude-team/STATUS.md` |
| tasks/*.md | Assigned tasks | `ls .claude-team/tasks/` |
| outputs/*.md | Completed work | `ls .claude-team/outputs/` |
| CHANGELOG.md | Recent releases | `head -60 ~/Claude/CHANGELOG.md` |

---

## Emergency: Full Reset

```bash
cd ~/Claude
git checkout -- .
rm -rf ~/Library/Developer/Xcode/DerivedData/CloudSyncApp-*
xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build
```

---

*Last Updated: 2026-01-12*
