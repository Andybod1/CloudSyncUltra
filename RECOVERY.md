# CloudSync Ultra - Crash Recovery Guide

> **All work is tracked via GitHub Issues** - survives any crash automatically.
> This guide helps you restore the development environment after restart.
> **Version:** 2.0.17 | **Tests:** 743 passing | **Providers:** 41

---

## 🚀 Quick Recovery (3 Steps)

### Step 1: Check GitHub Issues (Your Work Queue)
```bash
cd ~/Claude

# See what was in progress
gh issue list -l in-progress

# See what's ready to work on
gh issue list -l ready

# Full dashboard
./.github/dashboard.sh
```

### Step 2: Check Git Status
```bash
git status

# If uncommitted work exists:
git add -A && git commit -m "WIP: Recovery after crash"
```

### Step 3: Verify Build
```bash
xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build 2>&1 | tail -10
```

---

## 📋 Restore Strategic Partner Context

In a new Desktop Claude chat, say:

```
Read these files to restore context for CloudSync Ultra:

1. /Users/antti/Claude/.claude-team/PROJECT_CONTEXT.md
2. /Users/antti/Claude/.claude-team/STATUS.md
3. /Users/antti/Claude/CHANGELOG.md

Then tell me what state we're in and what needs to happen next.
```

---

## 🔄 Resume Workers (If Mid-Task)

### Launch Workers
```bash
~/Claude/.claude-team/scripts/launch_workers.sh
```

### Startup Commands

**Dev-1 (UI)**
```
Read /Users/antti/Claude/.claude-team/templates/DEV1_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV1.md. Update STATUS.md as you work.
```

**Dev-2 (Engine)**
```
Read /Users/antti/Claude/.claude-team/templates/DEV2_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV2.md. Update STATUS.md as you work.
```

**Dev-3 (Services)**
```
Read /Users/antti/Claude/.claude-team/templates/DEV3_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV3.md. Update STATUS.md as you work.
```

**QA (Testing)**
```
Read /Users/antti/Claude/.claude-team/templates/QA_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_QA.md. Update STATUS.md as you work.
```

---

## 📊 State Recovery Sources

| Source | What It Shows | Command |
|--------|---------------|---------|
| **GitHub Issues** | All tracked work (crash-proof) | `gh issue list` |
| STATUS.md | Worker status at crash | `cat .claude-team/STATUS.md` |
| tasks/*.md | Assigned tasks | `ls .claude-team/tasks/` |
| outputs/*.md | Completed work | `ls .claude-team/outputs/` |
| CHANGELOG.md | Recent releases | `head -60 CHANGELOG.md` |
| Git log | Recent commits | `git log --oneline -10` |

---

## 🛠️ Troubleshooting

### Claude Code Not Found
```bash
npm install -g @anthropic-ai/claude-code
```

### gh (GitHub CLI) Not Found
```bash
brew install gh
gh auth login
```

### Build Fails
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/CloudSyncApp-*
xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build
```

### Permission Denied on Scripts
```bash
chmod +x .claude-team/scripts/*.sh
chmod +x .github/dashboard.sh
```

---

## 🆘 Emergency: Full Reset

```bash
cd ~/Claude
git checkout -- .
rm -rf ~/Library/Developer/Xcode/DerivedData/CloudSyncApp-*
xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build
```

---

## ✅ What Survives Crash

| Component | Status | Notes |
|-----------|--------|-------|
| **GitHub Issues** | ✅ Safe | All work tracking on GitHub |
| Git repo | ✅ Safe | All committed code |
| Team infrastructure | ✅ Safe | In Git |
| Build artifacts | ❌ Lost | Rebuild with xcodebuild |
| Terminal sessions | ❌ Lost | Relaunch workers |
| Uncommitted changes | ❌ Lost | Commit frequently! |

---

## 📞 Quick Reference

| Action | Command |
|--------|---------|
| Issue dashboard | `./.github/dashboard.sh` |
| View all issues | `gh issue list` |
| In-progress issues | `gh issue list -l in-progress` |
| Launch workers | `./.claude-team/scripts/launch_workers.sh` |
| Check worker status | `cat .claude-team/STATUS.md` |
| Build app | `xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build` |

---

*Last Updated: 2026-01-12*
*CloudSync Ultra v2.0.6*
