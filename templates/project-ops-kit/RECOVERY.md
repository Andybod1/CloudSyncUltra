# {{PROJECT_NAME}} - Crash Recovery Guide

> **All work is tracked via GitHub Issues** - survives any crash automatically.
> This guide helps you restore the development environment after restart.
> **Version:** {{VERSION}} | **Tests:** {{TEST_COUNT}} passing

---

## 🚀 Quick Recovery (3 Steps)

### Step 1: Check Project Health
```bash
cd {{PROJECT_PATH}}
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
{{BUILD_COMMAND}} 2>&1 | tail -10
```

---

## 📋 Current State

### Sprint {{VERSION}}

See STATUS.md for current work in progress. Recent completed work:
<!-- Update with recent accomplishments -->
- Feature 1
- Feature 2
- {{TEST_COUNT}} automated tests passing

### Key Files
- Sprint Status: `.claude-team/SPRINT_STATUS.md`
- Worker Status: `.claude-team/STATUS.md`
- Current Tasks: `.claude-team/tasks/`

---

## 🔄 Resume Workers (If Mid-Sprint)

> ⚠️ **IMPORTANT:** Always use the launch script below - never launch workers manually via `claude` command directly. The script handles Terminal setup, briefing injection, and task assignment automatically.

### Launch Commands
```bash
# Core Workers
{{PROJECT_PATH}}/.claude-team/scripts/launch_single_worker.sh dev-1 opus
{{PROJECT_PATH}}/.claude-team/scripts/launch_single_worker.sh dev-2 opus
{{PROJECT_PATH}}/.claude-team/scripts/launch_single_worker.sh dev-3 opus
{{PROJECT_PATH}}/.claude-team/scripts/launch_single_worker.sh devops opus

# Specialized Agents
{{PROJECT_PATH}}/.claude-team/scripts/launch_single_worker.sh qa opus
{{PROJECT_PATH}}/.claude-team/scripts/launch_single_worker.sh ux-designer opus
{{PROJECT_PATH}}/.claude-team/scripts/launch_single_worker.sh product-manager opus
{{PROJECT_PATH}}/.claude-team/scripts/launch_single_worker.sh architect opus
{{PROJECT_PATH}}/.claude-team/scripts/launch_single_worker.sh security-auditor opus
```

### Startup Prompts

| Worker | Prompt |
|--------|--------|
| Dev-1 | `Read {{PROJECT_PATH}}/.claude-team/templates/DEV1_BRIEFING.md then read and execute {{PROJECT_PATH}}/.claude-team/tasks/TASK_DEV1.md. Update STATUS.md as you work.` |
| Dev-2 | `Read {{PROJECT_PATH}}/.claude-team/templates/DEV2_BRIEFING.md then read and execute {{PROJECT_PATH}}/.claude-team/tasks/TASK_DEV2.md. Update STATUS.md as you work.` |
| Dev-3 | `Read {{PROJECT_PATH}}/.claude-team/templates/DEV3_BRIEFING.md then read and execute {{PROJECT_PATH}}/.claude-team/tasks/TASK_DEV3.md. Update STATUS.md as you work.` |
| Dev-Ops | `Read {{PROJECT_PATH}}/.claude-team/templates/DEVOPS_BRIEFING.md then read and execute {{PROJECT_PATH}}/.claude-team/tasks/TASK_DEVOPS.md. Update STATUS.md as you work.` |

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
Read these files to restore context for {{PROJECT_NAME}}:

1. {{PROJECT_PATH}}/CLAUDE_PROJECT_KNOWLEDGE.md
2. {{PROJECT_PATH}}/.claude-team/STATUS.md
3. {{PROJECT_PATH}}/.claude-team/planning/SPRINT_PLAN.md

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
rm -rf ~/Library/Developer/Xcode/DerivedData/{{PROJECT_DIR}}-*
{{BUILD_COMMAND}}
```

### Permission Denied on Scripts
```bash
chmod +x scripts/*.sh
chmod +x .claude-team/scripts/*.sh
```

---

## 🆘 Emergency: Full Reset

```bash
cd {{PROJECT_PATH}}
git checkout -- .
rm -rf ~/Library/Developer/Xcode/DerivedData/{{PROJECT_DIR}}-*
{{BUILD_COMMAND}}
```

---

## ✅ What Survives Crash

| Component | Status | Notes |
|-----------|--------|-------|
| **GitHub Issues** | ✅ Safe | All work tracking on GitHub |
| Git repo | ✅ Safe | All committed code |
| Team infrastructure | ✅ Safe | In Git |
| Build artifacts | ❌ Lost | Rebuild with build command |
| Terminal sessions | ❌ Lost | Relaunch workers |
| Uncommitted changes | ❌ Lost | Commit frequently! |

---

## 📞 Quick Reference

| Action | Command |
|--------|---------|
| Project health | `./scripts/dashboard.sh` |
| View all issues | `gh issue list` |
| In-progress issues | `gh issue list -l in-progress` |
| Launch single worker | `{{PROJECT_PATH}}/.claude-team/scripts/launch_single_worker.sh <worker> opus` |
| Check worker status | `cat .claude-team/STATUS.md` |
| Build app | `{{BUILD_COMMAND}} 2>&1 \| tail -5` |
| Run tests | `{{TEST_COMMAND}} 2>&1 \| grep Executed` |

---

*Last Updated: {{DATE}}*
*Current Version: {{VERSION}}*
