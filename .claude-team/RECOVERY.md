# CloudSync Ultra - Crash Recovery Guide

> **All work is tracked via GitHub Issues** - survives any crash automatically.
> **Current Version:** v2.0.13
> **Last Updated:** 2026-01-13

---

## Quick Recovery (Copy-Paste Ready)

### For Strategic Partner (New Desktop Claude Chat)
```
Read these files to restore context for CloudSync Ultra:

1. /Users/antti/Claude/.claude-team/PROJECT_CONTEXT.md
2. /Users/antti/Claude/.claude-team/STATUS.md  
3. /Users/antti/Claude/CHANGELOG.md
4. /Users/antti/Claude/.claude-team/RECOVERY.md

Then tell me what state we're in and what needs to happen next.
```

---

## Immediate Steps After Crash

### 1. Check GitHub Issues (Your Work Queue)
```bash
cd ~/Claude

# What's in progress?
gh issue list -l in-progress

# What's ready to work?
gh issue list -l ready

# All open issues
gh issue list
```

### 2. Check Git Status
```bash
cd ~/Claude && git status --short

# If uncommitted work:
git add -A && git commit -m "WIP: Recovery after crash"
git push origin main
```

### 3. Verify Build Works
```bash
cd ~/Claude && xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build 2>&1 | tail -10
```

### 4. Run Tests (Optional)
```bash
cd ~/Claude && xcodebuild test -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -destination 'platform=macOS' 2>&1 | grep -E "Executed|passed|failed" | tail -5
```

---

## Current Project State (v2.0.13)

### What's Working
- ✅ 42 cloud providers supported
- ✅ Dual-pane file browser with drag & drop
- ✅ Per-remote encryption
- ✅ Scheduled sync (hourly/daily/weekly/custom)
- ✅ Menu bar integration with schedule indicator
- ✅ Drag & drop sidebar reordering
- ✅ Bandwidth throttling controls
- ✅ Comprehensive error handling system
- ✅ 617 unit tests (35 test files)

### Known Issues
- 23 pre-existing test failures (Issue #35) - in progress
- Transfer performance poor (Issue #10)
- iCloud integration (Issue #9)

### Recent Sprints
1. **Error Handling Sprint (v2.0.11)** - TransferError types, notification manager
2. **Quick Wins Sprint (v2.0.12)** - Reordering, account names, bandwidth
3. **Test Health Sprint (v2.0.13)** - Fix pre-existing test failures, team restructure

---

## Development System

### Team Structure (5 Workers)
```
Strategic Partner (Desktop Claude - Opus 4.5)
    ├── Dev-1 (UI)       - Views, ViewModels, Components
    ├── Dev-2 (Engine)   - RcloneManager.swift
    ├── Dev-3 (Services) - Models, *Manager.swift
    ├── QA (Testing)     - CloudSyncAppTests/
    └── Dev-Ops (Integration) - Git, GitHub, Docs, Research
```

### Model Selection Rules
| Worker | Model | Extended Thinking |
|--------|-------|-------------------|
| Dev-1 | Sonnet XS/S, Opus M/L/XL | M/L/XL tickets |
| Dev-2 | Sonnet XS/S, Opus M/L/XL | M/L/XL tickets |
| Dev-3 | Sonnet XS/S, Opus M/L/XL | M/L/XL tickets |
| QA | **ALWAYS Opus** | Always |
| Dev-Ops | **ALWAYS Opus** | Always |

### Sprint Phases (Shift-Left Testing)
| Phase | Workers | Duration |
|-------|---------|----------|
| 1. Planning | Strategic Partner + QA | 15-20 min |
| 2. Foundation | Dev-3 (models) | 15-20 min |
| 3. Implementation | Dev-1, Dev-2, QA (parallel) | 30-45 min |
| 4. Integration | Dev-Ops | 15-20 min |

---

## Resume Workers (If Mid-Sprint)

### Check Task Files
```bash
ls ~/Claude/.claude-team/tasks/
cat ~/Claude/.claude-team/tasks/TASK_DEV1.md  # Check what was assigned
```

### Check Worker Status
```bash
cat ~/Claude/.claude-team/STATUS.md
```

### Launch Workers
```bash
# Launch all workers
~/Claude/.claude-team/scripts/launch_workers.sh

# Or launch single worker
~/Claude/.claude-team/scripts/launch_single_worker.sh dev-1 sonnet
~/Claude/.claude-team/scripts/launch_single_worker.sh qa opus
~/Claude/.claude-team/scripts/launch_single_worker.sh devops opus
```

### Worker Startup Commands
```
Dev-1: Read /Users/antti/Claude/.claude-team/templates/DEV1_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV1.md. Update STATUS.md as you work.

Dev-2: Read /Users/antti/Claude/.claude-team/templates/DEV2_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV2.md. Update STATUS.md as you work.

Dev-3: Read /Users/antti/Claude/.claude-team/templates/DEV3_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV3.md. Update STATUS.md as you work.

QA: Read /Users/antti/Claude/.claude-team/templates/QA_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_QA.md. Update STATUS.md as you work.

Dev-Ops: Read /Users/antti/Claude/.claude-team/templates/DEVOPS_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEVOPS.md. Update STATUS.md as you work.
```

---

## State Recovery Sources

| Source | What It Shows | Command |
|--------|---------------|---------|
| **GitHub Issues** | All tracked work (crash-proof) | `gh issue list` |
| **STATUS.md** | Worker status at crash | `cat .claude-team/STATUS.md` |
| **tasks/*.md** | Assigned tasks | `ls .claude-team/tasks/` |
| **outputs/*.md** | Completed work | `ls .claude-team/outputs/` |
| **CHANGELOG.md** | Version history | `head -80 CHANGELOG.md` |
| **PROJECT_CONTEXT.md** | Full project context | `cat .claude-team/PROJECT_CONTEXT.md` |

---

## Key File Locations

```
/Users/antti/Claude/
├── CloudSyncApp/                 # Source code
├── CloudSyncAppTests/            # Unit tests (35 files)
├── CloudSyncApp.xcodeproj/       # Xcode project
├── CLAUDE_PROJECT_KNOWLEDGE.md   # Claude context (repo root)
├── .claude-team/
│   ├── PROJECT_CONTEXT.md        # Full project context
│   ├── STATUS.md                 # Worker status
│   ├── RECOVERY.md               # This file
│   ├── WORKER_MODELS.conf        # Model assignments
│   ├── tasks/                    # Worker task files
│   ├── outputs/                  # Worker completion reports
│   ├── templates/                # Worker briefings (5 workers)
│   └── scripts/                  # Launch scripts
├── .github/
│   ├── WORKFLOW.md               # Complete workflow docs
│   └── ISSUE_TEMPLATE/           # Issue templates
├── CHANGELOG.md                  # Version history
└── README.md                     # Project readme
```

---

## Common Commands

```bash
# Build
cd ~/Claude && xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build 2>&1 | tail -10

# Test
cd ~/Claude && xcodebuild test -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -destination 'platform=macOS' 2>&1 | grep "Executed" | tail -3

# Launch app
open ~/Library/Developer/Xcode/DerivedData/CloudSyncApp-*/Build/Products/Debug/CloudSyncApp.app

# Git status
cd ~/Claude && git log --oneline -5

# Issues
gh issue list
gh issue view <number>
```

---

## Emergency: Full Reset

```bash
cd ~/Claude
git fetch origin
git reset --hard origin/main
rm -rf ~/Library/Developer/Xcode/DerivedData/CloudSyncApp-*
xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build
```

---

## Memory Reminders for Strategic Partner

These are stored in Claude's memory system:
1. Always launch CloudSyncApp after building/updating code
2. Ask Andy for clarifications - never assume
3. Dev workers: Sonnet for XS/S, Opus for M/L/XL
4. **QA: Always Opus** regardless of ticket size
5. **Dev-Ops: Always Opus** with extended thinking
6. Extended thinking (`/think`) for M/L/XL tickets
7. QA participates in Phase 1 planning (shift-left testing)
8. **Delegate implementation** - Strategic Partner plans only

---

*Last Updated: 2026-01-13*
*CloudSync Ultra v2.0.13*
