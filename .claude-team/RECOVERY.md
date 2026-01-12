# CloudSync Ultra - Crash Recovery Guide

> After computer crash, use this guide to restore context.
> Location: `/Users/antti/Claude/.claude-team/RECOVERY.md`

---

## Immediate Steps After Crash

### 1. Check Git Status
```bash
cd ~/Claude && git status
```

If there's uncommitted work:
```bash
# See what changed
git diff --stat

# Either commit it
git add -A && git commit -m "WIP: Recovery after crash"

# Or discard if broken
git checkout -- .
```

### 2. Check for Running Processes
```bash
# Kill any stuck Claude processes
pkill -f "claude"

# Kill any stuck Xcode builds
pkill -f "xcodebuild"
```

### 3. Verify Build Still Works
```bash
cd ~/Claude && xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build 2>&1 | tail -10
```

---

## Restore Strategic Partner Context

### In New Desktop Claude Chat, Say:

```
I'm working on CloudSync Ultra. Please read these files to get up to speed:

1. /Users/antti/Claude/.claude-team/STRATEGIC/QUICK_START.md
2. /Users/antti/Claude/.claude-team/STRATEGIC/ARCHITECTURE.md
3. /Users/antti/Claude/.claude-team/STRATEGIC/DIRECTIVE.md
4. /Users/antti/Claude/.claude-team/STATUS.md
5. /Users/antti/Claude/CHANGELOG.md

Then tell me where we left off.
```

---

## Restore Lead Agent

### Launch Lead:
```bash
~/Claude/.claude-team/scripts/launch_lead.sh
```

### Paste Recovery Command:
```
Read /Users/antti/Claude/.claude-team/LEAD/LEAD_BRIEFING.md then check STATUS.md and STRATEGIC/DIRECTIVE.md to understand current state. Resume work or report status.
```

---

## Restore Workers

If workers were mid-task:

### Launch Workers:
```bash
~/Claude/.claude-team/scripts/launch_workers.sh
```

### Check Which Tasks Exist:
```bash
ls ~/Claude/.claude-team/tasks/
```

### Workers Will Resume from Task Files

---

## State Files to Check

| File | What It Tells You |
|------|-------------------|
| `STATUS.md` | What each worker was doing |
| `DIRECTIVE.md` | Current feature being built |
| `WORKSTREAM.md` | Sprint progress |
| `LEAD_REPORT.md` | If Lead completed (needs review) |
| `outputs/*.md` | Which workers finished |
| `tasks/*.md` | What tasks were assigned |

---

## Common Recovery Scenarios

### Scenario 1: Workers Were Running
```bash
# Check status
cat ~/Claude/.claude-team/STATUS.md

# Check outputs
ls ~/Claude/.claude-team/outputs/

# If incomplete, relaunch workers
~/Claude/.claude-team/scripts/launch_workers.sh
```

### Scenario 2: Lead Was Integrating
```bash
# Check if Lead wrote report
cat ~/Claude/.claude-team/LEAD/LEAD_REPORT.md

# If not, relaunch Lead
~/Claude/.claude-team/scripts/launch_lead.sh
```

### Scenario 3: Waiting for Strategic Review
```bash
# Check Lead report
cat ~/Claude/.claude-team/LEAD/LEAD_REPORT.md

# In Desktop Claude, review and commit
```

### Scenario 4: Build Broken
```bash
# Check build errors
cd ~/Claude && xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build 2>&1 | grep error:

# Common fix: restore project file
git checkout -- CloudSyncApp.xcodeproj/project.pbxproj

# Re-add new files via Lead Agent
```

---

## Emergency: Full Reset

If everything is broken:

```bash
cd ~/Claude

# Discard all local changes
git checkout -- .

# Clean build artifacts
rm -rf ~/Library/Developer/Xcode/DerivedData/CloudSyncApp-*

# Rebuild
xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build
```

---

## Key Contacts

- **Project:** CloudSync Ultra
- **GitHub:** https://github.com/andybod1-lang/CloudSyncUltra
- **Human:** Andy
- **Strategic Partner:** Desktop Claude (Opus 4.5)
- **Lead Agent:** CLI Claude (Opus via `claude --model opus`)
- **Workers:** CLI Claude (Sonnet via `claude`)

---

## Memory Joggers

### Recent Features Built:
- Scheduled Sync (v2.0.3)
- Parallel Team System (v2.0.2)
- Local Storage encryption fix (v2.0.1)

### Current Architecture:
- SwiftUI + rclone backend
- 4 workers: Dev-1 (UI), Dev-2 (Engine), Dev-3 (Services), QA
- Two-tier: Strategic Partner → Lead Agent → Workers

### Test Count:
- 170+ unit tests
- ~98% pass rate

---

*Last Updated: 2026-01-12*
