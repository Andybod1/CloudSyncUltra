# CloudSync Ultra - Ticket System Guide

> **Robust ticket management using GitHub Issues + local git backup**

---

## Overview

This system uses GitHub Issues as the primary ticket tracker with local git-backed files as failsafe. All ticket data survives:
- Device crashes/power failures (git-backed)
- Session restarts (persisted files)
- GitHub outages (local backup)
- Auth token expiration (local backup)

---

## Quick Start

### Creating Tickets

**Option A: GitHub (Preferred)**
```bash
# Bug report
gh issue create --template bug_report.yml

# Feature request  
gh issue create --template feature_request.yml

# Quick issue
gh issue create --title "[Feature]: Bandwidth throttling" --label "enhancement,component:engine"
```

**Option B: Quick Local (For Andy)**
```bash
# Just drop a note - Strategic Partner will process
echo "Add bandwidth throttling settings" >> ~/Claude/.claude-team/tickets/INBOX.md
```

### Viewing Tickets

```bash
# All open issues
gh issue list

# By label
gh issue list --label "ready"
gh issue list --label "worker:dev-2"

# Local backup
cat ~/Claude/.claude-team/tickets/ACTIVE.md
```

---

## Workflow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           TICKET LIFECYCLE                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   1. CREATED                                                                │
│      └─ Andy creates issue on GitHub OR drops note in INBOX.md              │
│         Labels: triage                                                      │
│                                                                             │
│   2. PLANNED                                                                │
│      └─ Strategic Partner reviews, adds details, estimates                  │
│         Labels: ready, worker:*, size:*, priority:*                         │
│                                                                             │
│   3. IN PROGRESS                                                            │
│      └─ Workers executing (task files reference issue #)                    │
│         Labels: in-progress                                                 │
│                                                                             │
│   4. REVIEW                                                                 │
│      └─ Strategic Partner integrates, tests, polishes                       │
│         Labels: needs-review                                                │
│                                                                             │
│   5. DONE                                                                   │
│      └─ Closed with summary, linked to commits                              │
│         Issue closed, referenced in CHANGELOG                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Label Reference

### Status Labels
| Label | Meaning |
|-------|---------|
| `triage` | Needs review and planning |
| `ready` | Planned and ready for workers |
| `in-progress` | Currently being worked on |
| `blocked` | Blocked by dependency |
| `needs-review` | Waiting for Strategic Partner review |

### Component Labels
| Label | Domain |
|-------|--------|
| `component:ui` | Views, ViewModels (Dev-1) |
| `component:engine` | RcloneManager (Dev-2) |
| `component:services` | Models, Managers (Dev-3) |
| `component:tests` | Test files (QA) |
| `component:encryption` | Encryption features |
| `component:scheduling` | Scheduled sync |
| `component:menu-bar` | Menu bar |

### Worker Labels
| Label | Assignment |
|-------|------------|
| `worker:dev-1` | UI Layer worker |
| `worker:dev-2` | Core Engine worker |
| `worker:dev-3` | Services worker |
| `worker:qa` | Testing worker |
| `worker:strategic` | Strategic Partner handles directly |

### Priority Labels
| Label | Meaning |
|-------|---------|
| `priority:critical` | Must fix immediately |
| `priority:high` | Important, do soon |
| `priority:medium` | Normal priority |
| `priority:low` | Nice to have |

### Size Labels
| Label | Estimate |
|-------|----------|
| `size:xs` | < 30 minutes |
| `size:s` | 30 min - 1 hour |
| `size:m` | 1-2 hours |
| `size:l` | 2-4 hours |
| `size:xl` | 4+ hours (split it) |

---

## Strategic Partner Commands

### Planning a Ticket
```bash
# Add labels after reviewing
gh issue edit 42 --add-label "ready,worker:dev-2,size:m,priority:high,component:engine"
gh issue edit 42 --remove-label "triage"
```

### Starting Work
```bash
gh issue edit 42 --add-label "in-progress" --remove-label "ready"
```

### Completing Work
```bash
gh issue close 42 --comment "Implemented in commit abc123. See CHANGELOG v2.0.5"
```

### Sync to Local Backup
```bash
# Export active issues to local file
gh issue list --state open --json number,title,labels,body > ~/Claude/.claude-team/tickets/issues_backup.json
```

---

## Recovery Procedures

### After Device Crash
1. Issues are safe on GitHub
2. Check local backup: `cat ~/Claude/.claude-team/tickets/ACTIVE.md`
3. Restore context: `gh issue list --label "in-progress"`

### After GitHub Outage
1. Use local ACTIVE.md for current state
2. Continue work normally
3. Sync when GitHub returns

### After Auth Expiration
```bash
gh auth refresh -s read:project -s project --hostname github.com
```

---

## Integration with Workers

When creating worker tasks, reference GitHub issues:

```markdown
# TASK_DEV2.md

## Issue Reference
GitHub Issue: #42 - Bandwidth Throttling

## Objective
Implement bandwidth limiting in RcloneManager...
```

Commits should reference issues:
```bash
git commit -m "feat(engine): Add bandwidth throttling

Implements #42"
```

---

## File Structure

```
.claude-team/
├── tickets/
│   ├── INBOX.md           # Quick notes from Andy
│   ├── ACTIVE.md          # Currently active tickets (local backup)
│   └── issues_backup.json # GitHub issues export
└── TICKETS.md             # This guide
```

---

*Last Updated: 2026-01-12*
