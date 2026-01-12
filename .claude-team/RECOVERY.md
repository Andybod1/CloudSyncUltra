# CloudSync Ultra - Crash Recovery Guide

> After computer crash, use this guide to restore context.

---

## Immediate Steps After Crash

### 1. Check Git Status
```bash
cd ~/Claude && git status
```

If there's uncommitted work:
```bash
git diff --stat
git add -A && git commit -m "WIP: Recovery after crash"
```

### 2. Verify Build Works
```bash
cd ~/Claude && xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build 2>&1 | tail -10
```

---

## Restore Strategic Partner Context

### In New Desktop Claude Chat, Say:

```
Read these files to restore context for CloudSync Ultra:

1. /Users/antti/Claude/.claude-team/PROJECT_CONTEXT.md
2. /Users/antti/Claude/.claude-team/STATUS.md
3. /Users/antti/Claude/CHANGELOG.md

Then tell me what state we're in and what needs to happen next.
```

---

## Resume Workers (if mid-task)

```bash
~/Claude/.claude-team/scripts/launch_workers.sh
```

Check which tasks exist:
```bash
ls ~/Claude/.claude-team/tasks/
```

---

## State Files to Check

| File | What It Tells You |
|------|-------------------|
| `STATUS.md` | What each worker was doing |
| `tasks/*.md` | What tasks were assigned |
| `outputs/*.md` | Which workers finished |
| `CHANGELOG.md` | Recent changes |

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
