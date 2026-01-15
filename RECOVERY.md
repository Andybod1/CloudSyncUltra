# CloudSync Ultra - Crash Recovery Guide

> **All work is tracked via GitHub Issues** - survives any crash automatically.
> This guide helps you restore the development environment after restart.
> **Version:** 2.0.23 | **Tests:** 743 passing | **Providers:** 42

---

## 🚀 Quick Recovery (3 Steps)

### Step 1: Check Project Health
```bash
cd ~/Claude
./scripts/dashboard.sh
```

### Step 2: Check Git Status
```bash
git status
git log --oneline -5

# If uncommitted work exists:
git add -A && git commit -m "WIP: Recovery after crash"
```

### Step 3: Verify Build
```bash
xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build 2>&1 | tail -10
```

---

## 📋 Current State (2026-01-15)

### Sprint v2.0.23 "Launch Ready" IN PROGRESS

| Worker | Task | Ticket | Status |
|--------|------|--------|--------|
| Dev-1 | Transfer Progress Counter | #96 | 🟢 Active |
| Dev-2 | Dropbox Support | #37 | 🟢 Active |
| Dev-3 | Security Hardening | #74 | 🟢 Active |
| Dev-Ops | App Store Assets | #78 | 🟢 Active |
| Revenue-Engineer | StoreKit 2 | #46 | 🟢 Active |
| Legal-Advisor | Compliance Package | NEW | 🟢 Active |
| Marketing-Lead | Launch Package | NEW | 🟢 Active |

**Phase 2 (Queued):** QA testing after Revenue-Engineer + Dev-3 complete

### Key Files
- Sprint Plan: `.claude-team/planning/SPRINT_2.0.23_PLAN.md`
- Worker Status: `.claude-team/STATUS.md`
- QA Phase 2 Task: `.claude-team/tasks/TASK_QA_PHASE2.md`

---

## 🔄 Resume Workers (If Mid-Sprint)

### Launch Commands
```bash
# Core Workers
~/Claude/.claude-team/scripts/launch_single_worker.sh dev-1 opus
~/Claude/.claude-team/scripts/launch_single_worker.sh dev-2 opus
~/Claude/.claude-team/scripts/launch_single_worker.sh dev-3 opus
~/Claude/.claude-team/scripts/launch_single_worker.sh devops opus

# Specialized Agents
~/Claude/.claude-team/scripts/launch_single_worker.sh revenue-engineer opus
~/Claude/.claude-team/scripts/launch_single_worker.sh legal-advisor opus
~/Claude/.claude-team/scripts/launch_single_worker.sh marketing-lead opus
```

### Startup Prompts

| Worker | Prompt |
|--------|--------|
| Dev-1 | `Read /Users/antti/Claude/.claude-team/templates/DEV1_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV1.md. Update STATUS.md as you work.` |
| Dev-2 | `Read /Users/antti/Claude/.claude-team/templates/DEV2_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV2.md. Update STATUS.md as you work.` |
| Dev-3 | `Read /Users/antti/Claude/.claude-team/templates/DEV3_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV3.md. Update STATUS.md as you work.` |
| Dev-Ops | `Read /Users/antti/Claude/.claude-team/templates/DEVOPS_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEVOPS.md. Update STATUS.md as you work.` |
| Revenue-Engineer | `Read /Users/antti/Claude/.claude-team/templates/REVENUE_ENGINEER_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_REVENUE_ENGINEER.md. Update STATUS.md as you work.` |
| Legal-Advisor | `Read /Users/antti/Claude/.claude-team/templates/LEGAL_ADVISOR_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_LEGAL_ADVISOR.md. Update STATUS.md as you work.` |
| Marketing-Lead | `Read /Users/antti/Claude/.claude-team/templates/MARKETING_LEAD_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_MARKETING_LEAD.md. Update STATUS.md as you work.` |

---

## 📊 State Recovery Sources

| Source | What It Shows | Command |
|--------|---------------|---------|
| **Dashboard** | Full health overview | `./scripts/dashboard.sh` |
| **GitHub Issues** | All tracked work | `gh issue list` |
| STATUS.md | Worker status | `cat .claude-team/STATUS.md` |
| tasks/*.md | Assigned tasks | `ls .claude-team/tasks/` |
| outputs/*.md | Completed work | `ls .claude-team/outputs/` |
| CHANGELOG.md | Recent releases | `head -60 CHANGELOG.md` |
| Git log | Recent commits | `git log --oneline -10` |

---

## 📋 Restore Strategic Partner Context

In a new Desktop Claude chat, say:

```
Read these files to restore context for CloudSync Ultra:

1. /Users/antti/Claude/CLAUDE_PROJECT_KNOWLEDGE.md
2. /Users/antti/Claude/.claude-team/STATUS.md
3. /Users/antti/Claude/.claude-team/planning/SPRINT_2.0.23_PLAN.md

Then tell me what state we're in and what needs to happen next.
```

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
chmod +x scripts/*.sh
chmod +x .claude-team/scripts/*.sh
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
| Project health | `./scripts/dashboard.sh` |
| View all issues | `gh issue list` |
| In-progress issues | `gh issue list -l in-progress` |
| Launch single worker | `~/Claude/.claude-team/scripts/launch_single_worker.sh <worker> opus` |
| Check worker status | `cat .claude-team/STATUS.md` |
| Build app | `xcodebuild build 2>&1 \| tail -5` |
| Run tests | `xcodebuild test -destination 'platform=macOS' 2>&1 \| grep Executed` |

---

*Last Updated: 2026-01-15*
*Sprint: v2.0.23 "Launch Ready" in progress*
