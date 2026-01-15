# {PROJECT_NAME} - Crash Recovery Guide

> **All work is tracked via GitHub Issues** - survives any crash automatically.
> This guide helps you restore the development environment after restart.
> **Version:** {VERSION} | **Tests:** {TEST_COUNT} | **Last Updated:** {DATE}

---

## 🚀 Quick Recovery (3 Steps)

### Step 1: Check GitHub Issues (Your Work Queue)
```bash
cd {PROJECT_ROOT}

# See what was in progress
gh issue list -l in-progress

# See what's ready to work on
gh issue list -l ready

# Full dashboard (if available)
./scripts/dashboard.sh
```

### Step 2: Check Git Status
```bash
git status

# If uncommitted work exists:
git add -A && git commit -m "WIP: Recovery after crash"
```

### Step 3: Verify Build
```bash
# Run your project's build command
npm run build  # OR: make build, cargo build, etc.

# Run tests to verify everything works
npm test  # OR: pytest, go test, cargo test, etc.
```

---

## 📋 Restore Strategic Partner Context

In a new Desktop Claude chat, say:

```
Read these files to restore context for {PROJECT_NAME}:

1. {PROJECT_ROOT}/.claude-team/PROJECT_CONTEXT.md
2. {PROJECT_ROOT}/.claude-team/STATUS.md
3. {PROJECT_ROOT}/CHANGELOG.md

Then tell me what state we're in and what needs to happen next.
```

---

## 🔄 Resume Workers (If Mid-Task)

### Launch Workers
```bash
{PROJECT_ROOT}/.claude-team/scripts/launch_workers.sh
```

### Startup Commands

**Dev-1 Worker**
```
Read {PROJECT_ROOT}/.claude-team/templates/DEV1_BRIEFING.md then read and execute {PROJECT_ROOT}/.claude-team/tasks/TASK_DEV1.md. Update STATUS.md as you work.
```

**Dev-2 Worker**
```
Read {PROJECT_ROOT}/.claude-team/templates/DEV2_BRIEFING.md then read and execute {PROJECT_ROOT}/.claude-team/tasks/TASK_DEV2.md. Update STATUS.md as you work.
```

**Dev-3 Worker**
```
Read {PROJECT_ROOT}/.claude-team/templates/DEV3_BRIEFING.md then read and execute {PROJECT_ROOT}/.claude-team/tasks/TASK_DEV3.md. Update STATUS.md as you work.
```

**QA Worker**
```
Read {PROJECT_ROOT}/.claude-team/templates/QA_BRIEFING.md then read and execute {PROJECT_ROOT}/.claude-team/tasks/TASK_QA.md. Update STATUS.md as you work.
```

**Dev-Ops Worker**
```
Read {PROJECT_ROOT}/.claude-team/templates/DEVOPS_BRIEFING.md then read and execute {PROJECT_ROOT}/.claude-team/tasks/TASK_DEVOPS.md. Update STATUS.md as you work.
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
# macOS
brew install gh
gh auth login

# Linux
type -p curl >/dev/null || sudo apt install curl -y
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh -y
gh auth login
```

### Build Fails
```bash
# Clean build artifacts (adjust for your project)
rm -rf node_modules/ dist/ build/  # Node.js
rm -rf target/                      # Rust/Java
rm -rf __pycache__/ *.pyc          # Python

# Reinstall dependencies
npm install    # OR: pip install -r requirements.txt, cargo build, etc.

# Rebuild
npm run build  # OR your build command
```

### Permission Denied on Scripts
```bash
chmod +x .claude-team/scripts/*.sh
chmod +x scripts/*.sh
```

---

## 🆘 Emergency: Full Reset

```bash
cd {PROJECT_ROOT}
git checkout -- .
# Clean all build artifacts (customize for your project)
git clean -fdx  # WARNING: Removes all untracked files!
# Reinstall and rebuild
npm install && npm run build  # OR your commands
```

---

## ✅ What Survives Crash

| Component | Status | Notes |
|-----------|--------|-------|
| **GitHub Issues** | ✅ Safe | All work tracking on GitHub |
| Git repo | ✅ Safe | All committed code |
| Team infrastructure | ✅ Safe | In Git |
| Build artifacts | ❌ Lost | Rebuild needed |
| Terminal sessions | ❌ Lost | Relaunch workers |
| Uncommitted changes | ❌ Lost | Commit frequently! |

---

## 📞 Quick Reference

| Action | Command |
|--------|---------|
| Issue dashboard | `./scripts/dashboard.sh` |
| View all issues | `gh issue list` |
| In-progress issues | `gh issue list -l in-progress` |
| Launch workers | `./.claude-team/scripts/launch_workers.sh` |
| Check worker status | `cat .claude-team/STATUS.md` |
| Build project | `npm run build` # OR your build command |
| Run tests | `npm test` # OR your test command |

---

## ⚡ Emergency Commands

```bash
# Quick status check
cd {PROJECT_ROOT} && pwd && git status --short && gh issue list -l in-progress

# Build and test
npm run build && npm test  # OR your commands

# See recent activity
git log --oneline -5 && echo "---" && gh issue list --limit 5
```

---

*Last Updated: {DATE}*
*{PROJECT_NAME} {VERSION}*