# CloudSync Ultra - Project Knowledge

> **For Claude Project Context** - Essential info for every conversation
> **Version:** 2.0.19 | **Updated:** 2026-01-14

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
├── CloudSyncAppTests/            # Tests (743 passing)
├── CloudSyncAppUITests/          # UI Tests (69 tests)
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

### Just Completed: v2.0.19
- ✅ **Build Fix** - cornerRadiusSmall alias added to AppTheme
- ✅ **All 743 tests passing**

### v2.0.18 (9-Worker Sprint)
- ✅ **#72 Multi-Thread Downloads** - Already implemented, 30+ tests
- ✅ **#77 App Icon** - SVG template, generation script ready
- ✅ **#84 UI Visual Refresh** - AppTheme applied to 5 views
- ✅ **#85 Pricing Strategy** - $29 one-time recommended
- ✅ **#86 Marketing Channels** - Report + launch checklist
- ✅ **#88 UI Tests** - 69 XCUITests integrated
- ✅ **#90 Notifications** - NotificationManager verified
- ✅ **#92 CONTRIBUTING.md** - 450+ lines
- ✅ **#94 Publishing Guide** - ~650 lines

### Key Docs Created
- `docs/PUBLISHING_GUIDE.md` - Code signing, notarization, App Store
- `docs/pdfs/` - 5 professional PDFs for stakeholders
- `CONTRIBUTING.md` - Contributor guidelines
- `.claude-team/outputs/PRICING_STRATEGY.md` - Full market analysis

### Recent: v2.0.15-v2.0.17
- v2.0.17: Accessibility (VoiceOver + keyboard), OSLog, Help system
- v2.0.16: TransferOptimizer, App Sandbox, Security hardening
- v2.0.15: iCloud Phase 1, Crash reporting infrastructure

---

## Key Reminders

1. **Triage tickets** → Use TRIAGE_GUIDE.md to assign core team OR specialized agents
2. **Delegate ALL implementation** to workers
3. **QA = Opus + /think | Specialized = Opus + /think hard**
4. **Ask Andy** if requirements unclear

### ⚠️ MANDATORY: Post-Sprint Documentation

**After EVERY sprint, update ALL of these and push to git:**

| File | What to Update |
|------|----------------|
| `CHANGELOG.md` | New version entry with features/fixes |
| `STATUS.md` | Version, completed items, test count, worker status |
| `RECOVERY.md` | Version, current state, test count, open issues |
| `CLAUDE_PROJECT_KNOWLEDGE.md` | Version, test count, current state |

```bash
# After updates:
cd ~/Claude && git add -A && git commit -m "docs: Update documentation to vX.X.X" && git push origin main
```

**Do this immediately after each sprint - don't wait to be asked!**

---

## Quick Recovery

```bash
cat /Users/antti/Claude/.claude-team/STATUS.md
gh issue list
```

---

*Optimized for Claude Project Knowledge*
