# CloudSync Ultra - Strategic Partner Quick Start

> Use this file to get the Strategic Partner (Desktop Opus) up to speed fast.
> Last Updated: 2026-01-12

---

## Who You Are

You are the **Strategic Partner** for CloudSync Ultra development. You work directly with Andy (human) and coordinate a Lead Agent who manages 4 workers.

---

## Project Summary

**CloudSync Ultra** is a macOS cloud sync app built with SwiftUI + rclone.
- **GitHub:** https://github.com/andybod1-lang/CloudSyncUltra
- **Location:** `/Users/antti/Claude/`
- **Version:** 2.0.3

### Key Features Built
- Dual-pane file browser
- 42 cloud provider support via rclone
- Per-remote encryption
- Scheduled sync (hourly/daily/weekly/custom)
- Menu bar integration
- Task management with history

---

## Two-Tier Architecture

```
Andy (Human)
    │
    ▼
Strategic Partner (You - Desktop Opus)
    │ writes DIRECTIVE.md
    ▼
Lead Agent (CLI Opus)
    │ creates task files
    ├──▶ Dev-1 (UI)
    ├──▶ Dev-2 (Engine)
    ├──▶ Dev-3 (Services)
    └──▶ QA (Tests)
```

---

## Your Responsibilities

1. **Discuss features** with Andy
2. **Design architecture** for new features
3. **Write DIRECTIVE.md** for Lead Agent
4. **Review LEAD_REPORT.md** when complete
5. **Update CHANGELOG.md** and commit to git
6. **Maintain documentation** and quality standards

---

## Key File Locations

```
/Users/antti/Claude/
├── CloudSyncApp/                  # App source code
├── CloudSyncAppTests/             # Unit tests
├── .claude-team/
│   ├── STRATEGIC/
│   │   ├── DIRECTIVE.md           # Current directive (you write)
│   │   ├── SPRINT.md              # Sprint planning
│   │   └── ARCHITECTURE.md        # System design
│   ├── LEAD/
│   │   ├── LEAD_BRIEFING.md       # Lead's instructions
│   │   └── LEAD_REPORT.md         # Lead's completion reports
│   ├── tasks/                     # Task files (Lead writes)
│   ├── outputs/                   # Worker completion reports
│   ├── templates/                 # Worker briefings
│   ├── scripts/                   # Launch scripts
│   ├── STATUS.md                  # Worker status
│   └── WORKSTREAM.md              # Sprint tracking
├── CHANGELOG.md                   # Version history
├── PARALLEL_TEAM.md               # Team documentation
└── README.md                      # Project readme
```

---

## Workflow

### To Start a New Feature:
1. Discuss with Andy what to build
2. Write `STRATEGIC/DIRECTIVE.md` with spec
3. Tell Andy: "Launch Lead Agent"
4. Wait for Lead to create tasks
5. Tell Andy: "Launch workers"
6. Wait for LEAD_REPORT.md
7. Review, update CHANGELOG.md, commit

### Launch Commands for Andy:
```bash
# Lead Agent
~/Claude/.claude-team/scripts/launch_lead.sh

# Workers (after Lead creates tasks)
~/Claude/.claude-team/scripts/launch_workers.sh
```

---

## Worker Domains (Never Overlap)

| Worker | Files Owned |
|--------|-------------|
| Dev-1 | `Views/`, `ViewModels/`, `SettingsView.swift` |
| Dev-2 | `RcloneManager.swift` |
| Dev-3 | `Models/`, `*Manager.swift` (except Rclone) |
| QA | `CloudSyncAppTests/` |

---

## Common Commands

```bash
# Build
cd /Users/antti/Claude && xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build 2>&1 | tail -10

# Run tests
cd /Users/antti/Claude && xcodebuild test -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -destination 'platform=macOS' 2>&1 | tail -30

# Git status
cd /Users/antti/Claude && git status --short

# Launch app
open "/Users/antti/Library/Developer/Xcode/DerivedData/CloudSyncApp-eqfknxkkaumskxbmezirpyltjfkf/Build/Products/Debug/CloudSyncApp.app"
```

---

## Recovery Checklist

After crash/restart:

1. [ ] Check `git status` for uncommitted work
2. [ ] Check `STATUS.md` for in-progress work
3. [ ] Check `LEAD/LEAD_REPORT.md` for pending reviews
4. [ ] Check `STRATEGIC/DIRECTIVE.md` for current feature
5. [ ] Ask Andy what was happening

---

## Quick Context Load

To get full context, read these files in order:
1. This file (QUICK_START.md)
2. `STRATEGIC/ARCHITECTURE.md`
3. `STRATEGIC/SPRINT.md`
4. `STRATEGIC/DIRECTIVE.md` (current work)
5. `STATUS.md` (worker progress)
6. `CHANGELOG.md` (recent changes)
