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
| **Version** | 2.0.6 |
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
gh issue create -t "[Bug]: desc" -l bug,triage
gh issue create -t "[Feature]: desc" -l enhancement,triage

# View details
gh issue view <number>
```

**Full docs**: `.github/WORKFLOW.md`

---

## Development System

### Parallel Architecture

```
Andy (Human) ─────────────────────────────────────────────────
        │ Creates GitHub Issues anytime
        ▼
┌─────────────────────────────────────────────────────────────┐
│  STRATEGIC PARTNER (Desktop Claude - Opus 4.5)              │
│  • Plans issues with QA input (shift-left testing)          │
│  • Creates task files referencing issues                    │
│  • Reviews completed work                                   │
│  • Integrates code, fixes builds                            │
│  • Closes issues, updates CHANGELOG, commits                │
└──────┬─────────┬─────────┬─────────┬────────────────────────┘
       │         │         │         │
       ▼         ▼         ▼         ▼
   ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐
   │Dev-1 │  │Dev-2 │  │Dev-3 │  │  QA  │
   │ UI   │  │Engine│  │Svc   │  │Plan+ │
   │      │  │      │  │      │  │ Test │
   └──────┘  └──────┘  └──────┘  └──────┘
   Sonnet     Sonnet    Sonnet    Opus
```

### Worker Model Selection

| Worker | Model | Rationale |
|--------|-------|-----------|
| Dev-1/2/3 | Sonnet | Fast for implementation tasks |
| QA | **Always Opus** | Thorough test design, edge case discovery |

Config: `.claude-team/WORKER_MODELS.conf`

### Extended Thinking

Strategic Partner specifies in task files when workers should use `/think`:

| Ticket Size | Extended Thinking |
|-------------|-------------------|
| XS/S | Standard (not required) |
| M/L/XL | ENABLED for complex decisions |

Use extended thinking for:
- Architecture decisions
- Complex algorithm design
- Tricky edge case handling
- Integration impact analysis

Example in task file:
```markdown
## Configuration
- **Model:** Opus
- **Extended Thinking:** ENABLED - Use /think before designing the sync algorithm
```

### Extended Thinking

Strategic Partner specifies in task files when workers should use `/think`:

| Ticket Size | Extended Thinking |
|-------------|-------------------|
| XS/S | Standard (not required) |
| M/L/XL | ENABLED for complex decisions |

Use extended thinking for:
- Architecture decisions
- Complex algorithm design
- Tricky edge case handling
- Integration impact analysis

Example in task file:
```markdown
## Configuration
- **Model:** Opus
- **Extended Thinking:** ENABLED - Use /think before designing the sync algorithm
```

### Sprint Phases (Shift-Left Testing)

QA participates in planning to catch issues early:

| Phase | Workers | Duration | Output |
|-------|---------|----------|--------|
| **1. Planning** | Strategic Partner + QA | 15-20 min | Test Plan, refined requirements |
| **2. Foundation** | Dev-3 (models) | 15-20 min | Model layer ready |
| **3. Implementation** | Dev-1, Dev-2, QA (parallel) | 30-45 min | Features + tests |
| **4. Integration** | Strategic Partner | 15-20 min | Build, test, commit |

**QA Planning Output:** `outputs/QA_TEST_PLAN.md`
- Happy path tests
- Edge cases identified
- Error scenarios
- Risks & questions for devs

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
├── .github/
│   ├── ISSUE_TEMPLATE/               # Issue templates
│   │   ├── bug_report.yml            # Bug report form
│   │   ├── feature_request.yml       # Feature request form
│   │   └── task.yml                  # Internal task form
│   └── WORKFLOW.md                   # Complete workflow docs
├── .claude-team/
│   ├── tasks/                        # Task files for workers
│   ├── outputs/                      # Worker completion reports
│   ├── templates/                    # Worker role briefings
│   ├── scripts/
│   │   └── launch_workers.sh
│   ├── STATUS.md                     # Real-time worker status
│   ├── PROJECT_CONTEXT.md            # This file
│   └── RECOVERY.md                   # Crash recovery guide
├── CHANGELOG.md                      # Version history
└── README.md                         # Project readme
```

---

## Workflow

1. **Andy** creates GitHub Issue (anytime, from anywhere)
2. **Strategic Partner** plans: adds labels, writes implementation notes
3. **Strategic Partner** creates task files referencing issue numbers
4. **Andy** launches workers: `~/Claude/.claude-team/scripts/launch_workers.sh`
5. **Andy** pastes startup commands in each terminal
6. **Workers** execute in parallel
7. **Andy** says "workers done"
8. **Strategic Partner** integrates, tests, commits with `Fixes #XX`
9. **GitHub** auto-closes issues

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

## Common Commands

```bash
# Build
cd /Users/antti/Claude && xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build 2>&1 | tail -10

# Run tests
cd /Users/antti/Claude && xcodebuild test -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -destination 'platform=macOS' 2>&1 | tail -30

# Git
cd /Users/antti/Claude && git status --short
cd /Users/antti/Claude && git log --oneline -10

# Launch app
open "/Users/antti/Library/Developer/Xcode/DerivedData/CloudSyncApp-eqfknxkkaumskxbmezirpyltjfkf/Build/Products/Debug/CloudSyncApp.app"

# Issues
gh issue list
gh issue view <number>
```

---

## Recent History (Latest First)

### v2.0.6 - 2026-01-12
- **GitHub Issues Ticket System** - Crash-proof work tracking
- Issue templates (bug, feature, task)
- 30+ labels for status, workers, priority, components
- Project board for Kanban view

### v2.0.5 - 2026-01-12
- **Move Schedules to Main Window** - Primary sidebar item

### v2.0.4 - 2026-01-12
- **Menu Bar Schedule Indicator** - See next sync at a glance

### v2.0.3 - 2026-01-12
- **Scheduled Sync** - Hourly/daily/weekly/custom schedules

### v2.0.2 - 2026-01-12
- **Parallel Team System** - 4 workers, ~4x speedup

### v2.0.1 - 2026-01-12
- **Local Storage encryption fix**

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
*CloudSync Ultra v2.0.6*
