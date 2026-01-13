# CloudSync Ultra - Project Knowledge

> **For Claude Project Context** - Essential info for every conversation
> **Version:** 2.0.15 | **Updated:** 2026-01-13

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

## Team Architecture

### Core Team (5 Workers)
```
Strategic Partner (This Claude - Opus 4.5)
    ├── Dev-1 (UI)       → Views, ViewModels, Components
    ├── Dev-2 (Engine)   → RcloneManager.swift
    ├── Dev-3 (Services) → Models, *Manager.swift
    ├── QA (Testing)     → CloudSyncAppTests/
    └── Dev-Ops          → Git, GitHub, Docs, Research
```

### Specialized Agents (On-Demand)
```
    ├── UX-Designer      → UI/UX analysis, user flows
    ├── Product-Manager  → Strategy, requirements, roadmap
    ├── Architect        → System design, refactoring
    ├── Security-Auditor → Security review, vulnerabilities
    ├── Performance-Eng  → Deep optimization analysis
    └── Tech-Writer      → Documentation, guides
```

### Model Rules
| Agent Type | Model Rule |
|------------|------------|
| Dev-1, Dev-2, Dev-3 | Sonnet XS/S, Opus M/L/XL |
| QA, Dev-Ops | **ALWAYS Opus + /think** |
| All Specialized | **ALWAYS Opus + /think hard** |

### Ticket Triage Process
When evaluating tickets, Strategic Partner decides assignment:
- **Implementation work** → Core team (Dev-1/2/3, QA, Dev-Ops)
- **Analysis/strategy/review** → Specialized agents

See `.claude-team/TRIAGE_GUIDE.md` for decision tree and examples.

---

## Worker Launch

```bash
# Core team
~/Claude/.claude-team/scripts/launch_single_worker.sh dev-1 sonnet
~/Claude/.claude-team/scripts/launch_single_worker.sh qa opus

# Specialized agents
~/Claude/.claude-team/scripts/launch_single_worker.sh ux-designer opus
~/Claude/.claude-team/scripts/launch_single_worker.sh product-manager opus
~/Claude/.claude-team/scripts/launch_single_worker.sh architect opus
~/Claude/.claude-team/scripts/launch_single_worker.sh security-auditor opus
```

---

## File Structure

```
/Users/antti/Claude/
├── CloudSyncApp/                 # Source (SwiftUI)
├── CloudSyncAppTests/            # Tests (616 passing)
├── docs/                         # User documentation
├── .claude-team/
│   ├── STATUS.md                 # Live worker status
│   ├── TRIAGE_GUIDE.md           # Ticket assignment decisions
│   ├── SPECIALIZED_AGENTS.md     # Agent roster & usage
│   ├── tasks/TASK_*.md           # Active tasks
│   ├── outputs/*_COMPLETE.md     # Reports
│   ├── templates/*_BRIEFING.md   # Briefings
│   └── planning/*.md             # Feature plans
└── CHANGELOG.md
```

---

## Essential Commands

```bash
# Build & Launch
cd /Users/antti/Claude && xcodebuild build 2>&1 | tail -5
open ~/Library/Developer/Xcode/DerivedData/CloudSyncApp-*/Build/Products/Debug/CloudSyncApp.app

# Tests
xcodebuild test -destination 'platform=macOS' 2>&1 | grep "Executed"

# GitHub
gh issue list
gh issue view <number>
```

---

## Current State

### In Progress: iCloud Phase 1 (#9)
- Dev-3 ✅ Foundation (rclone type fix, local detection)
- Dev-1 🔄 UI (local folder option)
- QA ⏳ Testing (waiting)

### Recent: v2.0.14 (Performance)
- ✅ 2x transfer speed improvement (#10)
- ✅ Crash reporting recommendation (#20)
- ✅ GitHub Actions workflow (#34)

### Open Issues
| # | Title | Priority |
|---|-------|----------|
| #9 | iCloud integration | High |
| #10 | Transfer performance | High (done) |
| #27 | UI test automation | High |
| #40 | Performance Settings UI | Medium |

---

## Key Reminders

1. **Triage tickets** → Use TRIAGE_GUIDE.md to assign core team OR specialized agents
2. **Delegate ALL implementation** to workers
3. **QA = Opus + /think | Specialized = Opus + /think hard**
4. **Ask Andy** if requirements unclear
5. **Update GitHub** after each sprint

---

## Quick Recovery

```bash
cat /Users/antti/Claude/.claude-team/STATUS.md
gh issue list
```

---

*Optimized for Claude Project Knowledge*
