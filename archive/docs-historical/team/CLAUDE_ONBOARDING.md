# CloudSync Ultra - Claude Onboarding Brief

> **Purpose:** If Claude crashes or you start a new session, paste this document to get Claude up to speed immediately.

---

## 🎯 Project Overview

**CloudSync Ultra** is a macOS cloud synchronization application built with SwiftUI. It's designed to be "the best cloud sync app for macOS" with support for 42+ cloud providers via rclone.

**Repository:** `https://github.com/andybod1-lang/CloudSyncUltra`
**Location:** `/Users/antti/Claude/`
**Version:** 2.0.2

---

## 🏗️ Your Role

You are **Lead Claude** — the architect and coordinator for a parallel development team.

**Your responsibilities:**
- Discuss features and architecture with Andy
- Break down work into parallel tasks
- Write task files for worker Claudes
- Monitor progress via STATUS.md
- Integrate completed work
- Maintain code quality and documentation
- Commit changes to Git

---

## 👥 Parallel Team System

You coordinate 4 worker Claudes running in Claude Code CLI:

```
┌─────────────────────────────────────────────────────────────────┐
│                        Andy (Human)                             │
│                   Decisions • Direction                         │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                   YOU (Lead Claude - Opus)                      │
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

### Worker Domains (No Conflicts)

| Worker | Role | Files Owned |
|--------|------|-------------|
| Dev-1 | UI Layer | `Views/`, `ViewModels/`, `Components/`, `ContentView.swift`, `SettingsView.swift` |
| Dev-2 | Core Engine | `RcloneManager.swift` (2,036 lines) |
| Dev-3 | Services | `SyncManager.swift`, `EncryptionManager.swift`, `KeychainManager.swift`, `ProtonDriveManager.swift`, `Models/` |
| QA | Testing | `CloudSyncAppTests/` |

---

## 📂 Key File Locations

```
/Users/antti/Claude/
├── CloudSyncApp/                  # Main application source
│   ├── Views/                     # SwiftUI views (Dev-1)
│   ├── ViewModels/                # View models (Dev-1)
│   ├── Components/                # Reusable components (Dev-1)
│   ├── Models/                    # Data models (Dev-3)
│   ├── RcloneManager.swift        # Core rclone operations (Dev-2)
│   ├── SyncManager.swift          # Sync orchestration (Dev-3)
│   ├── EncryptionManager.swift    # Encryption (Dev-3)
│   ├── KeychainManager.swift      # Credential storage (Dev-3)
│   └── ProtonDriveManager.swift   # Proton Drive (Dev-3)
├── CloudSyncAppTests/             # Unit tests (QA)
├── .claude-team/                  # Team coordination
│   ├── STATUS.md                  # Real-time worker status
│   ├── WORKSTREAM.md              # Current sprint overview
│   ├── tasks/                     # Task files for workers
│   │   ├── TASK_DEV1.md
│   │   ├── TASK_DEV2.md
│   │   ├── TASK_DEV3.md
│   │   └── TASK_QA.md
│   ├── outputs/                   # Worker completion reports
│   └── templates/                 # Worker briefings
├── CHANGELOG.md                   # Version history
├── README.md                      # Project documentation
├── PARALLEL_TEAM.md               # Team system docs
└── RECOVERY.md                    # Recovery instructions
```

---

## 🔄 How to Dispatch Work

### Step 1: Create Task Files
Write specific tasks to:
- `/Users/antti/Claude/.claude-team/tasks/TASK_DEV1.md`
- `/Users/antti/Claude/.claude-team/tasks/TASK_DEV2.md`
- `/Users/antti/Claude/.claude-team/tasks/TASK_DEV3.md`
- `/Users/antti/Claude/.claude-team/tasks/TASK_QA.md`

### Step 2: Update WORKSTREAM.md
Update `/Users/antti/Claude/.claude-team/WORKSTREAM.md` with current tasks.

### Step 3: Tell Andy to Launch Workers
Andy opens 4 Terminal windows, runs `claude` in each, and pastes:

**Dev-1:**
```
Read /Users/antti/Claude/.claude-team/templates/DEV1_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV1.md. Update STATUS.md as you work.
```

**Dev-2:**
```
Read /Users/antti/Claude/.claude-team/templates/DEV2_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV2.md. Update STATUS.md as you work.
```

**Dev-3:**
```
Read /Users/antti/Claude/.claude-team/templates/DEV3_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV3.md. Update STATUS.md as you work.
```

**QA:**
```
Read /Users/antti/Claude/.claude-team/templates/QA_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_QA.md. Update STATUS.md as you work.
```

### Step 4: Monitor Progress
Read `/Users/antti/Claude/.claude-team/STATUS.md` to see worker progress.

### Step 5: Integrate & Commit
Once workers complete, verify build, update docs, commit to Git.

---

## 🛠️ Common Commands

### Build the App
```bash
cd /Users/antti/Claude && xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build
```

### Run Tests
```bash
cd /Users/antti/Claude && xcodebuild test -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -destination 'platform=macOS'
```

### Check Team Status
```bash
cat /Users/antti/Claude/.claude-team/STATUS.md
```

### Git Commit Pattern
```bash
git add -A && git commit -m "type: Description

PROBLEM: What issue this solves
SOLUTION: What was done

IMPACT: What this changes"
```

### Launch App After Changes
Always launch the app after building to verify changes work.

---

## 📋 Key Facts

- **42+ cloud providers** supported via rclone
- **Dual-pane file browser** for source/destination
- **Per-remote encryption** with toggle controls
- **Keychain storage** for credentials
- **Real-time progress tracking** for transfers
- **173+ automated tests** with 98.7% pass rate
- **Menu bar integration** for quick access

---

## ⚠️ Important Conventions

1. **Always commit after completing work** with descriptive messages
2. **Update CHANGELOG.md** for any new features or fixes
3. **Run tests** before committing significant changes
4. **Launch the app** after code changes to verify
5. **Update documentation** alongside code changes
6. **Workers don't touch each other's files** — domain separation prevents conflicts

---

## 🚀 Quick Recovery Checklist

When starting fresh:

1. ✅ Read this document
2. ✅ Check current STATUS.md for any in-progress work
3. ✅ Check WORKSTREAM.md for current sprint goals
4. ✅ Check git status for uncommitted changes
5. ✅ Ask Andy what they want to work on

---

## 📞 Access

- **Desktop Commander:** Full filesystem access to `/Users/antti/Claude/`
- **Git:** Configured and authenticated
- **Build tools:** Xcode and xcodebuild available

---

*This document is stored in Git at `/Users/antti/Claude/CLAUDE_ONBOARDING.md`*
*Last Updated: January 12, 2026*
