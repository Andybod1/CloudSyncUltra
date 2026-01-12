# CloudSync Ultra - Crash Recovery Guide

> After computer crash, use this guide to restore context.
> **All tickets are on GitHub** - they survive any crash automatically.

---

## Immediate Steps After Crash

### 1. Check GitHub Issues (Your Work Queue)
```bash
# View issue dashboard - shows what was in progress
/Users/antti/Claude/.github/dashboard.sh

# Or check specific states
gh issue list --label "in-progress"   # What was being worked on
gh issue list --label "ready"         # What's ready to work on
```

### 2. Check Git Status
```bash
cd ~/Claude && git status
```

If there's uncommitted work:
```bash
git diff --stat
git add -A && git commit -m "WIP: Recovery after crash"
```

### 3. Verify Build Works
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

| Source | What It Tells You | Command |
|--------|-------------------|---------|
| **GitHub Issues** | All tracked work (crash-proof) | `gh issue list` |
| `STATUS.md` | What each worker was doing | `cat ~/.claude-team/STATUS.md` |
| `tasks/*.md` | What tasks were assigned | `ls ~/.claude-team/tasks/` |
| `outputs/*.md` | Which workers finished | `ls ~/.claude-team/outputs/` |
| `CHANGELOG.md` | Recent changes | `head -50 ~/Claude/CHANGELOG.md` |

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
