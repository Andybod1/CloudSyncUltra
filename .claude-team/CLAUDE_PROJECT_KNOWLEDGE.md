# CloudSync Ultra - Project Knowledge

> **For Claude Project Context** - Essential info for every conversation
> **Version:** 2.0.12 | **Updated:** 2026-01-13

---

## Project Identity

| Key | Value |
|-----|-------|
| **App** | CloudSync Ultra - macOS cloud sync with 42 providers |
| **Tech** | SwiftUI + rclone |
| **Location** | `/Users/antti/Claude/` |
| **GitHub** | https://github.com/andybod1-lang/CloudSyncUltra |
| **Human** | Andy |

---

## What It Does

Syncs files between cloud services (Google Drive, Dropbox, Proton Drive, S3, etc.):
- Dual-pane file browser with drag & drop
- Per-remote encryption
- Scheduled sync (hourly/daily/weekly)
- Menu bar integration
- Bandwidth throttling

---

## Team Architecture

```
Strategic Partner (This Claude - Opus 4.5)
    ├── Dev-1 (UI)       → Views, ViewModels, Components
    ├── Dev-2 (Engine)   → RcloneManager.swift
    ├── Dev-3 (Services) → Models, *Manager.swift
    └── QA (Testing)     → CloudSyncAppTests/
```

### Model Selection
- **Dev-1/2/3:** Sonnet for XS/S tickets, Opus for M/L/XL
- **QA:** Always Opus (thorough coverage)

### Sprint Phases (Shift-Left Testing)
| Phase | Workers | Output |
|-------|---------|--------|
| 1. Planning | Strategic Partner + QA | Test Plan |
| 2. Foundation | Dev-3 | Models ready |
| 3. Implementation | Dev-1, Dev-2, QA parallel | Features + Tests |
| 4. Integration | Strategic Partner | Commit & push |

---

## File Structure

```
/Users/antti/Claude/
├── CloudSyncApp/                 # Source (SwiftUI)
│   ├── Views/                    # Dev-1
│   ├── ViewModels/               # Dev-1
│   ├── Models/                   # Dev-3
│   ├── RcloneManager.swift       # Dev-2
│   └── *Manager.swift            # Dev-3
├── CloudSyncAppTests/            # QA (35 files, 617 tests)
├── .claude-team/
│   ├── PROJECT_CONTEXT.md        # Full context
│   ├── STATUS.md                 # Worker status
│   ├── RECOVERY.md               # Recovery guide
│   ├── WORKER_MODELS.conf        # Model assignments
│   ├── tasks/TASK_*.md           # Worker tasks
│   ├── outputs/*_COMPLETE.md     # Worker reports
│   └── templates/*_BRIEFING.md   # Worker briefings
├── .github/WORKFLOW.md           # Workflow docs
└── CHANGELOG.md                  # Version history
```

---

## Essential Commands

```bash
# Build
cd /Users/antti/Claude && xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build 2>&1 | tail -10

# Test
cd /Users/antti/Claude && xcodebuild test -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -destination 'platform=macOS' 2>&1 | grep -E "Executed|passed|failed" | tail -5

# Launch app
open ~/Library/Developer/Xcode/DerivedData/CloudSyncApp-*/Build/Products/Debug/CloudSyncApp.app

# Git
cd /Users/antti/Claude && git status --short
cd /Users/antti/Claude && git log --oneline -5

# GitHub Issues
gh issue list
gh issue list -l ready
gh issue view <number>
```

---

## Worker Management

### Launch Workers
```bash
~/Claude/.claude-team/scripts/launch_workers.sh
# Or single: ~/Claude/.claude-team/scripts/launch_single_worker.sh dev-1 sonnet
```

### Worker Startup Commands
```
Dev-1: Read /Users/antti/Claude/.claude-team/templates/DEV1_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV1.md. Update STATUS.md as you work.

Dev-2: Read /Users/antti/Claude/.claude-team/templates/DEV2_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV2.md. Update STATUS.md as you work.

Dev-3: Read /Users/antti/Claude/.claude-team/templates/DEV3_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV3.md. Update STATUS.md as you work.

QA: Read /Users/antti/Claude/.claude-team/templates/QA_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_QA.md. Update STATUS.md as you work.
```

---

## Current State

### Last Completed: v2.0.12 (Quick Wins Sprint)
- ✅ Drag & drop sidebar reordering (#14)
- ✅ Account name in encryption view (#25)
- ✅ Bandwidth throttling controls (#1)
- ✅ Test target configured (617 tests)
- ✅ Shift-left testing workflow

### Open Issues
| # | Title | Priority |
|---|-------|----------|
| #35 | Fix 23 pre-existing test failures | Medium |
| #30 | Google Photos folders empty | Critical |
| #10 | Transfer performance poor | High |
| #27 | UI test automation | High |
| #9 | iCloud integration | High |

---

## Key Reminders

1. **Always launch app** after building/updating code
2. **Ask Andy for clarifications** - never assume requirements
3. **QA always uses Opus** regardless of ticket size
4. **QA participates in planning** (shift-left testing)
5. **Extended thinking** for M/L/XL tickets
6. **Update GitHub** - commit, push, close issues
7. **Update CHANGELOG.md** after each sprint

---

## Quick Recovery

If context is lost, read these files:
```bash
cat /Users/antti/Claude/.claude-team/STATUS.md
cat /Users/antti/Claude/CHANGELOG.md
gh issue list
```

---

*This file is optimized for Claude Project Knowledge*
