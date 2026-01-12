# CloudSync Ultra - Project Context

> Single file containing everything needed to restore full context.
> Use this after computer crash or starting fresh session.

---

## Project Identity

| Key | Value |
|-----|-------|
| **Name** | CloudSync Ultra |
| **Type** | macOS Cloud Sync Application |
| **Tech** | SwiftUI + rclone |
| **Version** | 2.0.5 |
| **Location** | `/Users/antti/Claude/` |
| **GitHub** | https://github.com/andybod1-lang/CloudSyncUltra |
| **Human** | Andy |

---

## What This App Does

CloudSync Ultra syncs files between cloud services (Google Drive, Dropbox, Proton Drive, S3, etc.) with:
- Dual-pane file browser
- Drag & drop transfers
- Per-remote encryption
- Scheduled automatic sync
- Menu bar quick access
- 42 cloud provider support

---

## Development System

### Parallel Architecture

```
Andy (Human) ─────────────────────────────────────────────────
                    │
                    ▼
┌─────────────────────────────────────────────────────────────┐
│  STRATEGIC PARTNER (Desktop Claude - Opus 4.5)              │
│  • Architecture & planning                                  │
│  • Creates task files directly                              │
│  • Reviews completed work                                   │
│  • Integrates code, fixes builds                            │
│  • Updates CHANGELOG, commits to git                        │
└──────┬─────────┬─────────┬─────────┬────────────────────────┘
       │         │         │         │
       ▼         ▼         ▼         ▼
   ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐
   │Dev-1 │  │Dev-2 │  │Dev-3 │  │  QA  │
   │ UI   │  │Engine│  │Svc   │  │ Test │
   └──────┘  └──────┘  └──────┘  └──────┘
   Sonnet     Sonnet    Sonnet    Sonnet
```

### Worker Domains (Strict Separation)

| Worker | Owns | Never Touches |
|--------|------|---------------|
| Dev-1 | `Views/`, `ViewModels/`, `Components/`, `SettingsView.swift` | RcloneManager, Models, Tests |
| Dev-2 | `RcloneManager.swift` | Views, Models, Tests |
| Dev-3 | `Models/`, `*Manager.swift` (except Rclone) | Views, RcloneManager, Tests |
| QA | `CloudSyncAppTests/` | Source code |

---

## File Structure

```
/Users/antti/Claude/
├── CloudSyncApp/                     # Main app source
│   ├── Views/                        # SwiftUI views (Dev-1)
│   ├── ViewModels/                   # View models (Dev-1)
│   ├── Models/                       # Data models (Dev-3)
│   ├── RcloneManager.swift           # Core engine (Dev-2)
│   ├── ScheduleManager.swift         # Scheduling (Dev-3)
│   ├── EncryptionManager.swift       # Encryption (Dev-3)
│   ├── KeychainManager.swift         # Secrets (Dev-3)
│   └── CloudSyncAppApp.swift         # App entry
├── CloudSyncAppTests/                # Unit tests (QA)
├── .claude-team/
│   ├── tasks/                        # Task files for workers
│   ├── outputs/                      # Worker completion reports
│   ├── templates/                    # Worker role briefings
│   ├── scripts/                      # Launch scripts
│   ├── STATUS.md                     # Real-time worker status
│   ├── PROJECT_CONTEXT.md            # This file
│   └── RECOVERY.md                   # Crash recovery guide
├── CHANGELOG.md                      # Version history
└── README.md                         # Project readme
```

---

## Launch Workers

```bash
~/Claude/.claude-team/scripts/launch_workers.sh
```

---

## Worker Startup Commands

### Dev-1 (UI)
```
Read /Users/antti/Claude/.claude-team/templates/DEV1_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV1.md. Update STATUS.md as you work.
```

### Dev-2 (Engine)
```
Read /Users/antti/Claude/.claude-team/templates/DEV2_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV2.md. Update STATUS.md as you work.
```

### Dev-3 (Services)
```
Read /Users/antti/Claude/.claude-team/templates/DEV3_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV3.md. Update STATUS.md as you work.
```

### QA (Testing)
```
Read /Users/antti/Claude/.claude-team/templates/QA_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_QA.md. Update STATUS.md as you work.
```

---

## Workflow

1. **Andy + Strategic Partner** discuss feature
2. **Strategic Partner** creates task files directly
3. **Andy** launches workers: `~/Claude/.claude-team/scripts/launch_workers.sh`
4. **Andy** pastes startup commands in each terminal
5. **Workers** execute in parallel
6. **Andy** tells Strategic Partner "workers done"
7. **Strategic Partner** integrates, fixes builds, runs tests
8. **Strategic Partner** updates CHANGELOG, commits to git

---

## Common Commands

```bash
# Build
cd /Users/antti/Claude && xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build 2>&1 | tail -10

# Run tests
cd /Users/antti/Claude && xcodebuild test -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -destination 'platform=macOS' 2>&1 | tail -30

# Git status
cd /Users/antti/Claude && git status --short

# Git log
cd /Users/antti/Claude && git log --oneline -10

# Launch app
open "/Users/antti/Library/Developer/Xcode/DerivedData/CloudSyncApp-eqfknxkkaumskxbmezirpyltjfkf/Build/Products/Debug/CloudSyncApp.app"
```

---

## Recent History (Latest First)

### v2.0.5 - 2026-01-12
- **Move Schedules to Main Window** - Schedules now primary sidebar item
- Removed Schedules tab from Settings (now 4 tabs)

### v2.0.4 - 2026-01-12
- **Menu Bar Schedule Indicator** - See next sync at a glance
- **Two-Tier Architecture docs** - PROJECT_CONTEXT.md, RECOVERY.md, QUICK_START.md

### v2.0.3 - 2026-01-12
- **Scheduled Sync** - Hourly/daily/weekly/custom schedules

### v2.0.2 - 2026-01-12
- **Parallel Team System** - 4 workers, ~4x speedup

### v2.0.1 - 2026-01-12
- **Local Storage encryption fix** - Hide encryption UI for local

### v2.0.0 - 2026-01-11
- **Major release** - Complete SwiftUI rebuild

---

## Restore Context Prompt

After crash, start new Desktop Claude chat and say:

```
Read these files to restore context for CloudSync Ultra:

1. /Users/antti/Claude/.claude-team/PROJECT_CONTEXT.md
2. /Users/antti/Claude/.claude-team/STATUS.md
3. /Users/antti/Claude/CHANGELOG.md

Then tell me what state we're in and what needs to happen next.
```

---

*Last Updated: 2026-01-12*
*CloudSync Ultra v2.0.5*
