# CloudSync Ultra - Project Knowledge

> **For Claude Project Context** - Essential info for every conversation
> **Version:** 2.0.14 | **Updated:** 2026-01-13

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
- 12/24 hour time format preference

---

## Team Architecture (5 Workers)

```
Strategic Partner (This Claude - Opus 4.5)
    ├── Dev-1 (UI)       → Views, ViewModels, Components
    ├── Dev-2 (Engine)   → RcloneManager.swift
    ├── Dev-3 (Services) → Models, *Manager.swift
    ├── QA (Testing)     → CloudSyncAppTests/
    └── Dev-Ops (Integration) → Git, GitHub, Docs, Research
```

### Model Selection Rules
| Worker | Model Rule | Extended Thinking |
|--------|------------|-------------------|
| Dev-1, Dev-2, Dev-3 | Sonnet for XS/S, Opus for M/L/XL | M/L/XL tickets |
| QA | **ALWAYS Opus** | Always for test design |
| Dev-Ops | **ALWAYS Opus** | Always for critical ops |

### Strategic Partner Role
- **Plans and coordinates** - never implements directly
- **Delegates ALL work** to specialized workers
- **Creates tasks** in `.claude-team/tasks/TASK_*.md`
- **Monitors progress** via STATUS.md and output files

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
├── CloudSyncAppTests/            # QA (35 files, 616 tests)
├── docs/                         # User documentation
│   ├── CLEAN_BUILD_GUIDE.md
│   └── TEST_ACCOUNTS_GUIDE.md
├── .claude-team/
│   ├── STATUS.md                 # Worker status (live)
│   ├── WORKER_MODELS.conf        # Model assignments
│   ├── tasks/TASK_*.md           # Active worker tasks
│   ├── outputs/*_COMPLETE.md     # Worker reports
│   ├── templates/*_BRIEFING.md   # Worker briefings
│   └── planning/*.md             # Feature plans
└── CHANGELOG.md                  # Version history
```

---

## Essential Commands

```bash
# Build
cd /Users/antti/Claude && xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build 2>&1 | tail -10

# Test (616 tests, 0 failures)
cd /Users/antti/Claude && xcodebuild test -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -destination 'platform=macOS' 2>&1 | grep -E "Executed|passed|failed" | tail -5

# Launch app
open ~/Library/Developer/Xcode/DerivedData/CloudSyncApp-*/Build/Products/Debug/CloudSyncApp.app

# GitHub Issues
gh issue list
gh issue view <number>
```

---

## Worker Launch

```bash
# Single worker
~/Claude/.claude-team/scripts/launch_single_worker.sh [worker] [model]

# Examples
~/Claude/.claude-team/scripts/launch_single_worker.sh dev-2 opus
~/Claude/.claude-team/scripts/launch_single_worker.sh qa opus
```

### Startup Commands (paste into Claude Code)
```
Dev-1: Read /Users/antti/Claude/.claude-team/templates/DEV1_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV1.md. Update STATUS.md as you work.

Dev-2: Read /Users/antti/Claude/.claude-team/templates/DEV2_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV2.md. Update STATUS.md as you work.

Dev-3: Read /Users/antti/Claude/.claude-team/templates/DEV3_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV3.md. Update STATUS.md as you work.

QA: Read /Users/antti/Claude/.claude-team/templates/QA_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_QA.md. Update STATUS.md as you work.

Dev-Ops: Read /Users/antti/Claude/.claude-team/templates/DEVOPS_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEVOPS.md. Update STATUS.md as you work.
```

---

## Current State

### In Progress: v2.0.14 (Performance Sprint)
| # | Title | Worker | Status |
|---|-------|--------|--------|
| #10 | Transfer performance audit | Dev-2 | 🔄 Working |
| #20 | Crash reporting feasibility | Dev-3 | 🔄 Working |
| #34 | GitHub Actions setup | Dev-Ops | 🔄 Working |

### Last Completed: v2.0.13
- ✅ Schedule time display fixed (#32)
- ✅ 12/24 hour time setting (#33)
- ✅ All 616 tests passing (#35)
- ✅ Clean build guide, test accounts guide

### Open Issues
| # | Title | Priority | Size |
|---|-------|----------|------|
| #37 | Dropbox validation | Medium | M |
| #27 | UI test automation | High | L |
| #9 | iCloud integration | High | L |

---

## Key Reminders

1. **Always launch app** after building/updating code
2. **Ask Andy for clarifications** - never assume
3. **QA & Dev-Ops always use Opus** with extended thinking
4. **Delegate implementation** - Strategic Partner plans only
5. **Update GitHub** - commit, push, close issues
6. **Update CHANGELOG.md** after each sprint

---

## Quick Recovery

```bash
cat /Users/antti/Claude/.claude-team/STATUS.md
cat /Users/antti/Claude/CHANGELOG.md
gh issue list
```

---

*This file is optimized for Claude Project Knowledge*
