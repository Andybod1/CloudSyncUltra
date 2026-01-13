# CloudSync Ultra - GitHub Issues Workflow

> **Recovery-Safe**: All tickets persist on GitHub, surviving device/power failures.

---

## Quick Reference

| Action | Command |
|--------|---------|
| View all issues | `gh issue list` |
| View ready issues | `gh issue list -l ready` |
| View by worker | `gh issue list -l worker:dev-1` |
| Create issue | `gh issue create` |
| View issue | `gh issue view <number>` |
| Close issue | `gh issue close <number>` |

---

## Issue Lifecycle

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                           GITHUB ISSUES WORKFLOW                              │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────┐    ┌─────────┐    ┌────────────┐    ┌────────────┐    ┌──────┐ │
│  │ TRIAGE  │───▶│  READY  │───▶│IN PROGRESS │───▶│NEEDS REVIEW│───▶│ DONE │ │
│  └─────────┘    └─────────┘    └────────────┘    └────────────┘    └──────┘ │
│       │              │               │                 │               │     │
│   Andy drops    Strategic      Workers           Strategic        Issue     │
│   raw idea      Partner        execute           Partner          closed    │
│                 plans it                         integrates                 │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## Labels System

### Status Labels
| Label | Meaning |
|-------|---------|
| `triage` | New issue, needs planning |
| `ready` | Planned, ready for workers |
| `in-progress` | Currently being worked |
| `needs-review` | Waiting for integration |
| `blocked` | Waiting on dependency |

### Worker Labels
| Label | Assigned To |
|-------|-------------|
| `worker:dev-1` | UI Layer (Views, ViewModels) |
| `worker:dev-2` | Core Engine (RcloneManager) |
| `worker:dev-3` | Services (Models, Managers) |
| `worker:qa` | Testing |
| `worker:strategic` | Strategic Partner handles directly |

### Component Labels
| Label | Domain |
|-------|--------|
| `component:ui` | Views, ViewModels, Components |
| `component:engine` | RcloneManager, transfers |
| `component:services` | Models, Managers |
| `component:tests` | Unit tests, UI tests |
| `component:encryption` | Encryption features |
| `component:scheduling` | Scheduled sync |
| `component:menu-bar` | Menu bar features |

### Priority Labels
| Label | Meaning |
|-------|---------|
| `priority:critical` | Fix immediately |
| `priority:high` | Do soon |
| `priority:medium` | Normal |
| `priority:low` | Nice to have |

### Size Labels
| Label | Time Estimate |
|-------|---------------|
| `size:xs` | < 30 minutes |
| `size:s` | 30 min - 1 hour |
| `size:m` | 1-2 hours |
| `size:l` | 2-4 hours |
| `size:xl` | 4+ hours (split it) |

---

## Workflow Details

### Sprint Workflow (Shift-Left Testing)

QA participates in planning to catch issues early. Each sprint has 4 phases:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SPRINT PHASES                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  PHASE 1          PHASE 2           PHASE 3            PHASE 4              │
│  ┌────────┐      ┌────────┐       ┌────────────┐      ┌──────────┐         │
│  │PLANNING│─────▶│FOUNDATION│─────▶│IMPLEMENTATION│───▶│INTEGRATION│        │
│  └────────┘      └────────┘       └────────────┘      └──────────┘         │
│       │               │                 │                   │               │
│   Strategic      Dev-3 builds      Dev-1, Dev-2        Strategic           │
│   Partner +      model layer       implement +         Partner             │
│   QA review                        QA writes tests     integrates          │
│                                                                              │
│   Output:         Output:           Output:             Output:             │
│   Test Plan      Models ready      Features + Tests    Commit + Push       │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

| Phase | Workers | Duration | Output |
|-------|---------|----------|--------|
| **1. Planning** | Strategic Partner + QA | 15-20 min | Test Plan, refined requirements |
| **2. Foundation** | Dev-3 | 15-20 min | Model layer ready |
| **3. Implementation** | Dev-1, Dev-2, QA (parallel) | 30-45 min | Features + tests |
| **4. Integration** | Strategic Partner | 15-20 min | Build, test, commit |

#### Phase 1: Planning with QA

QA reviews requirements and produces a **Test Plan** before implementation:

```bash
# Strategic Partner creates planning task for QA
# QA outputs: .claude-team/outputs/QA_TEST_PLAN.md
```

**Test Plan includes:**
- Happy path test scenarios
- Edge cases identified
- Error scenarios to handle
- Risks & questions for devs
- Recommendations

**Benefits:**
- Edge cases caught before code is written
- Ambiguous requirements clarified early
- Fewer rework cycles
- Tests ready when implementation completes

### 1. Andy Creates Issue
```bash
# Quick bug
gh issue create -t "[Bug]: Menu bar shows wrong time" -l bug,triage

# Quick feature idea
gh issue create -t "[Feature]: Add bandwidth throttling" -l enhancement,triage

# Or use web interface with templates
```

### 2. Strategic Partner Plans
- Reviews triage issues
- Adds: component, worker, priority, size labels
- Removes `triage`, adds `ready`
- Writes implementation notes in comment

### 3. Workers Execute
When Andy launches workers:
```bash
# Strategic Partner creates task files referencing issues
# Example: TASK_DEV2.md contains "Implements #47"

# After completion, worker adds comment to issue
gh issue comment 47 --body "Implementation complete. See commit abc123."
```

### 4. Strategic Partner Integrates
- Builds, tests, fixes any issues
- Updates CHANGELOG
- Commits with `Fixes #47` or `Closes #47`
- GitHub auto-closes issue

---

## Common Commands

```bash
# === View Issues ===
gh issue list                           # All open issues
gh issue list -l ready                  # Ready for workers
gh issue list -l triage                 # Needs planning
gh issue list -l "worker:dev-1"         # Dev-1's queue
gh issue list -l "priority:high"        # High priority
gh issue list -s closed                 # Closed issues

# === Create Issues ===
gh issue create                         # Interactive
gh issue create -t "Title" -b "Body"    # Quick create

# === Update Issues ===
gh issue edit 47 --add-label ready --remove-label triage
gh issue comment 47 --body "Started work"
gh issue close 47

# === View Details ===
gh issue view 47                        # View issue
gh issue view 47 --comments             # With comments
```

---

## Project Board

**URL**: https://github.com/users/andybod1-lang/projects/1

The board shows issues in columns:
- **Todo** - Ready for work
- **In Progress** - Currently being worked
- **Done** - Completed

---

## Recovery After Crash

Issues are on GitHub - they survive any local failure:

```bash
# Check current state
gh issue list

# See what was in progress
gh issue list -l in-progress

# Resume planning
gh issue list -l triage
```

---

## Integration with Worker System

When creating worker tasks, reference GitHub issues:

```markdown
# TASK_DEV2.md

## Issue Reference
Implements: #47 (Bandwidth Throttling)

## Objective
Add bandwidth limiting to RcloneManager...
```

Commits should reference issues:
```bash
git commit -m "feat(engine): Add bandwidth throttling

Implements #47"
```

---

*Last Updated: 2026-01-13*
