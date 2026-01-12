# CloudSync Ultra - Parallel Team Recovery Guide

> **One document with everything needed to restore the parallel development team after restart or crash.**

---

## 🚀 Quick Start (After Restart)

### Option 1: One-Click Launch
```bash
cd ~/Claude
./.claude-team/scripts/quick_launch.sh
```

### Option 2: Manual Launch
```bash
# Open 4 Terminal windows, in each run:
cd ~/Claude && claude
```

---

## 📋 Startup Commands for Each Worker

Copy and paste these into each Claude Code terminal:

### Terminal 1 — Dev-1 (UI Layer)
```
Read /Users/antti/Claude/.claude-team/templates/DEV1_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV1.md. Update STATUS.md as you work.
```

### Terminal 2 — Dev-2 (Core Engine)
```
Read /Users/antti/Claude/.claude-team/templates/DEV2_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV2.md. Update STATUS.md as you work.
```

### Terminal 3 — Dev-3 (Services)
```
Read /Users/antti/Claude/.claude-team/templates/DEV3_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV3.md. Update STATUS.md as you work.
```

### Terminal 4 — QA (Testing)
```
Read /Users/antti/Claude/.claude-team/templates/QA_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_QA.md. Update STATUS.md as you work.
```

---

## ⚙️ If Something Is Missing

### Claude Code Not Found
```bash
npm install -g @anthropic-ai/claude-code
```

### Node.js Not Found
```bash
brew install node
```

### Team Infrastructure Not Found
```bash
cd ~/Claude && git pull origin main
```

### Full Recovery Check
```bash
~/.claude-team/scripts/restore_team.sh
```

---

## 🏗️ Team Structure

```
┌─────────────────────────────────────────────────────────────────┐
│                        Andy (Human)                             │
│                   Decisions • Direction                         │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│              Lead Claude (Opus 4.5 - Desktop App)               │
│         Architecture • Task Breakdown • Integration             │
└──────┬──────────┬──────────┬──────────┬─────────────────────────┘
       │          │          │          │
       ▼          ▼          ▼          ▼
   ┌───────┐  ┌───────┐  ┌───────┐  ┌───────┐
   │ Dev-1 │  │ Dev-2 │  │ Dev-3 │  │  QA   │
   │Sonnet │  │Sonnet │  │Sonnet │  │Sonnet │
   │  UI   │  │Engine │  │Service│  │ Test  │
   └───────┘  └───────┘  └───────┘  └───────┘
```

---

## 📁 Worker Domain Assignments

| Worker | Role | Files Owned |
|--------|------|-------------|
| Dev-1 | UI Layer | `Views/`, `ViewModels/`, `Components/`, `ContentView.swift`, `SettingsView.swift` |
| Dev-2 | Core Engine | `RcloneManager.swift` |
| Dev-3 | Services | `SyncManager.swift`, `EncryptionManager.swift`, `KeychainManager.swift`, `ProtonDriveManager.swift`, `Models/` |
| QA | Testing | `CloudSyncAppTests/` |

---

## 📂 File Structure

```
/Users/antti/Claude/
├── .claude-team/
│   ├── WORKSTREAM.md              # Current sprint overview
│   ├── STATUS.md                  # Real-time worker status
│   ├── QUICKSTART.md              # Detailed guide
│   ├── tasks/
│   │   ├── TASK_DEV1.md           # Dev-1 current task
│   │   ├── TASK_DEV2.md           # Dev-2 current task
│   │   ├── TASK_DEV3.md           # Dev-3 current task
│   │   └── TASK_QA.md             # QA current task
│   ├── outputs/
│   │   ├── DEV1_COMPLETE.md       # Dev-1 completion reports
│   │   ├── DEV2_COMPLETE.md       # Dev-2 completion reports
│   │   ├── DEV3_COMPLETE.md       # Dev-3 completion reports
│   │   └── QA_REPORT.md           # QA test reports
│   ├── templates/
│   │   ├── DEV1_BRIEFING.md       # Dev-1 role instructions
│   │   ├── DEV2_BRIEFING.md       # Dev-2 role instructions
│   │   ├── DEV3_BRIEFING.md       # Dev-3 role instructions
│   │   └── QA_BRIEFING.md         # QA role instructions
│   └── scripts/
│       ├── quick_launch.sh        # Opens 4 terminals
│       ├── restore_team.sh        # Full recovery check
│       ├── launch_dev1.sh
│       ├── launch_dev2.sh
│       ├── launch_dev3.sh
│       ├── launch_qa.sh
│       └── launch_team.sh
├── PARALLEL_TEAM.md               # Team documentation
├── RECOVERY.md                    # This file
└── CloudSyncApp/                  # Main application code
```

---

## 🔄 Typical Workflow

1. **You tell Lead Claude** (Desktop App) what you want to build
2. **Lead creates task files** in `.claude-team/tasks/`
3. **You launch workers** using quick_launch.sh or manually
4. **Paste startup commands** in each terminal
5. **Select "Yes, allow all edits"** when prompted for permissions
6. **Workers execute in parallel** and update STATUS.md
7. **Lead monitors and integrates** completed work
8. **Commit frequently** to preserve progress

---

## 📊 Monitoring Progress

### Check Status
```bash
cat ~/.claude-team/STATUS.md
```

### View Completion Reports
```bash
ls ~/.claude-team/outputs/
cat ~/.claude-team/outputs/DEV1_COMPLETE.md
```

### Ask Lead Claude
Just ask: "What's the team status?"

---

## ✅ What Survives Restart

| Component | Location | Status |
|-----------|----------|--------|
| Team infrastructure | `.claude-team/` | ✅ In Git |
| Node.js | `/opt/homebrew/bin/node` | ✅ Installed |
| Claude Code | `/opt/homebrew/bin/claude` | ✅ Installed |
| Auth credentials | Claude Code config | ✅ Persisted |
| Documentation | `PARALLEL_TEAM.md`, `RECOVERY.md` | ✅ In Git |

## ❌ What Needs Restoration

| Component | Action |
|-----------|--------|
| Terminal windows | Run `quick_launch.sh` |
| Worker sessions | Paste startup commands |
| Uncommitted work | Lost — commit frequently! |

---

## 🛠️ Software Versions

| Component | Version | Install Command |
|-----------|---------|-----------------|
| Node.js | v25.2.1 | `brew install node` |
| npm | v11.6.2 | (comes with Node.js) |
| Claude Code | v2.1.5 | `npm install -g @anthropic-ai/claude-code` |

---

## 🆘 Troubleshooting

### "claude: command not found"
```bash
npm install -g @anthropic-ai/claude-code
```

### "node: command not found"
```bash
brew install node
```

### Workers not finding task files
```bash
cd ~/Claude && git pull origin main
```

### Permission denied on scripts
```bash
chmod +x ~/.claude-team/scripts/*.sh
```

### Need to re-authenticate Claude Code
```bash
claude
# Follow browser prompts to log in
```

---

## 📞 Quick Reference

| Action | Command |
|--------|---------|
| Launch all workers | `~/.claude-team/scripts/quick_launch.sh` |
| Check status | `cat ~/.claude-team/STATUS.md` |
| Full recovery | `~/.claude-team/scripts/restore_team.sh` |
| View outputs | `ls ~/.claude-team/outputs/` |
| Update from Git | `cd ~/Claude && git pull` |

---

*Last Updated: January 12, 2026*
*CloudSync Ultra v2.0.2*
