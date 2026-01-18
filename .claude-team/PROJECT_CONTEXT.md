# CloudSync Ultra - Project Context

> Single file containing everything needed to restore full context.
> Use this after computer crash or starting fresh session.
> **Version:** 2.0.40 | **Updated:** 2026-01-17

---

## Project Identity

| Key | Value |
|-----|-------|
| **Name** | CloudSync Ultra |
| **Type** | macOS Cloud Sync Application |
| **Tech** | SwiftUI + rclone |
| **Version** | 2.0.40 |
| **Location** | `/Users/antti/Claude/` |
| **GitHub** | https://github.com/andybod1-lang/CloudSyncUltra |
| **Project Board** | https://github.com/users/andybod1-lang/projects/1 |
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

## Ticket System (GitHub Issues)

All work is tracked via **GitHub Issues** - survives device/power failures.

```bash
# View issues
gh issue list                        # All open
gh issue list -l triage              # Needs planning
gh issue list -l ready               # Ready for workers
gh issue list -l in-progress         # Being worked

# Create issues
gh issue create                      # Interactive with templates

# View details
gh issue view <number>
```

**Full docs**: `.github/WORKFLOW.md`

---

## Development System

### Team Architecture (5 Workers)

```
Andy (Human) ─────────────────────────────────────────────────
        │ Creates GitHub Issues anytime
        ▼
┌─────────────────────────────────────────────────────────────┐
│  STRATEGIC PARTNER (Desktop Claude - Opus 4.5)              │
│  • Plans issues with QA input (shift-left testing)          │
│  • Creates task files referencing issues                    │
│  • Reviews completed work                                   │
│  • Coordinates integration                                  │
│  • DELEGATES ALL IMPLEMENTATION - never codes directly      │
└──────┬─────────┬─────────┬─────────┬─────────┬──────────────┘
       │         │         │         │         │
       ▼         ▼         ▼         ▼         ▼
   ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐  ┌───────┐
   │Dev-1 │  │Dev-2 │  │Dev-3 │  │  QA  │  │Dev-Ops│
   │ UI   │  │Engine│  │Svc   │  │Plan+ │  │ Git+  │
   │      │  │      │  │      │  │ Test │  │ Docs  │
   └──────┘  └──────┘  └──────┘  └──────┘  └───────┘
   Varies    Varies    Varies    ALWAYS    ALWAYS
                                 Opus      Opus
```

### Worker Model Selection Rules

| Worker | Model | Extended Thinking |
|--------|-------|-------------------|
| Dev-1 | Sonnet XS/S, Opus M/L/XL | M/L/XL tickets |
| Dev-2 | Sonnet XS/S, Opus M/L/XL | M/L/XL tickets |
| Dev-3 | Sonnet XS/S, Opus M/L/XL | M/L/XL tickets |
| QA | **ALWAYS Opus** | **ALWAYS** |
| Dev-Ops | **ALWAYS Opus** | **ALWAYS** |

Config: `.claude-team/WORKER_MODELS.conf`

### Worker Domains (Strict Separation)

| Worker | Owns | Never Touches |
|--------|------|---------------|
| Dev-1 | `Views/`, `ViewModels/`, `Components/` | RcloneManager, Models, Tests, Git |
| Dev-2 | `RcloneManager.swift` | Views, Models, Tests, Git |
| Dev-3 | `Models/`, `*Manager.swift` (except Rclone) | Views, RcloneManager, Tests, Git |
| QA | `CloudSyncAppTests/` | Source code, Git |
| Dev-Ops | Git, GitHub, CHANGELOG, README, Docs | Source code, Tests |

### Sprint Phases (Shift-Left Testing)

| Phase | Workers | Duration | Output |
|-------|---------|----------|--------|
| **1. Planning** | Strategic Partner + QA | 15-20 min | Test Plan, requirements |
| **2. Foundation** | Dev-3 (models) | 15-20 min | Model layer ready |
| **3. Implementation** | Dev-1, Dev-2, QA (parallel) | 30-45 min | Features + tests |
| **4. Integration** | Dev-Ops | 15-20 min | Commit, push, docs |

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
│   └── KeychainManager.swift         # Secrets (Dev-3)
├── CloudSyncAppTests/                # Unit tests (QA)
├── CLAUDE_PROJECT_KNOWLEDGE.md       # Claude context (repo root)
├── .github/
│   ├── ISSUE_TEMPLATE/               # Issue templates
│   └── WORKFLOW.md                   # Workflow docs
├── .claude-team/
│   ├── tasks/                        # Task files (TASK_*.md)
│   ├── outputs/                      # Completion reports (*_COMPLETE.md)
│   ├── templates/                    # Worker briefings (5 workers)
│   ├── scripts/                      # Launch scripts
│   ├── STATUS.md                     # Real-time worker status
│   ├── PROJECT_CONTEXT.md            # This file
│   ├── RECOVERY.md                   # Crash recovery guide
│   └── WORKER_MODELS.conf            # Model assignments
├── CHANGELOG.md                      # Version history
└── README.md                         # Project readme
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

### QA (Testing) - ALWAYS Opus
```
Read /Users/antti/Claude/.claude-team/templates/QA_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_QA.md. Update STATUS.md as you work.
```

### Dev-Ops (Integration) - ALWAYS Opus
```
Read /Users/antti/Claude/.claude-team/templates/DEVOPS_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEVOPS.md. Update STATUS.md as you work.
```

---

## Launch Commands

```bash
# Launch single worker
~/Claude/.claude-team/scripts/launch_single_worker.sh dev-1 sonnet
~/Claude/.claude-team/scripts/launch_single_worker.sh qa opus
~/Claude/.claude-team/scripts/launch_single_worker.sh devops opus

# Launch all workers (4 terminals)
~/Claude/.claude-team/scripts/launch_workers.sh
```

---

## Common Commands

```bash
# Build
cd /Users/antti/Claude && xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build 2>&1 | tail -10

# Run tests
cd /Users/antti/Claude && xcodebuild test -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -destination 'platform=macOS' 2>&1 | grep -E "Executed|passed|failed" | tail -5

# Launch app
open ~/Library/Developer/Xcode/DerivedData/CloudSyncApp-*/Build/Products/Debug/CloudSyncApp.app

# Git
cd /Users/antti/Claude && git status --short
cd /Users/antti/Claude && git log --oneline -10

# Issues
gh issue list
gh issue view <number>
```

---

## Recent History

### v2.0.40 - 2026-01-17 (Current)
- **Schedule Wizard Folder Browser** - Path picker for source/destination
- **Encryption Setup Integration** - Toggle prompts for password setup
- **Error Message Improvements** - Human-readable TransferError messages
- **Sync Progress Fixes** - "Already in sync" instead of "No data"

### v2.0.32 - 2026-01-16
- **Interactive Onboarding** (#83) - Wizards integrated into onboarding flow
- **Windows Port Research** (#65) - Architecture feasibility study

### v2.0.24 - 2026-01-15
- **Launch Ready Sprint** - StoreKit 2 subscriptions, security hardening
- Legal compliance (Privacy Policy, ToS, GDPR/CCPA)
- Marketing launch package, App Store assets
- 841 tests (831 passing, 10 expected failures)

### v2.0.22 - 2026-01-15
- Quick Actions Menu (#49) - Cmd+Shift+N
- Provider-Specific Chunk Sizes (#73)
- Transfer Preview (#55) - Dry-run support

### v2.0.21 - 2026-01-15
- Build fixes, onboarding infrastructure
- 841 tests total (772 unit + 69 UI)

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

*Last Updated: 2026-01-17*
*CloudSync Ultra v2.0.40*
