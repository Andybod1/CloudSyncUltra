# Parallel Development Team

CloudSync Ultra uses a **parallel development system** where the Strategic Partner (Desktop Claude) directly coordinates 4 workers.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              ANDY (Human)                                   │
│                        Vision • Decisions • Direction                       │
│                        Creates GitHub Issues anytime                        │
└─────────────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│              STRATEGIC PARTNER (Desktop Claude - Opus 4.5)                  │
│                                                                             │
│   Plans Issues • Creates Tasks • Integrates • Reviews • Commits             │
│                                                                             │
└──────┬──────────────┬──────────────┬──────────────┬─────────────────────────┘
       │              │              │              │
       ▼              ▼              ▼              ▼
   ┌───────┐      ┌───────┐      ┌───────┐      ┌───────┐
   │ Dev-1 │      │ Dev-2 │      │ Dev-3 │      │  QA   │
   │Sonnet │      │Sonnet │      │Sonnet │      │Sonnet │
   │  UI   │      │Engine │      │Service│      │ Test  │
   └───────┘      └───────┘      └───────┘      └───────┘
```

---

## GitHub Issues Integration

**All tickets live on GitHub** - survives device/power failures.

### Quick Commands
```bash
# View issues
gh issue list                    # All open
gh issue list -l ready           # Ready for workers
gh issue list -l triage          # Needs planning

# Create issue
gh issue create -t "[Feature]: Idea" -l enhancement,triage
```

### Issue Lifecycle
```
TRIAGE → READY → IN PROGRESS → NEEDS REVIEW → DONE
  │         │          │             │           │
 Andy    Strategic   Workers    Strategic     Auto-
 drops    Partner    execute     Partner     closed
 idea     plans                 integrates
```

### Labels
| Type | Labels |
|------|--------|
| **Status** | `triage`, `ready`, `in-progress`, `needs-review`, `blocked` |
| **Worker** | `worker:dev-1`, `worker:dev-2`, `worker:dev-3`, `worker:qa` |
| **Priority** | `priority:critical`, `priority:high`, `priority:medium`, `priority:low` |
| **Size** | `size:xs`, `size:s`, `size:m`, `size:l`, `size:xl` |

See `.github/WORKFLOW.md` for complete details.

---

## Workflow

1. **Andy** creates GitHub Issue (anytime, from anywhere)
2. **Strategic Partner** plans: adds labels, writes implementation notes
3. **Strategic Partner** creates task files referencing issues
4. **Andy** runs: `~/Claude/.claude-team/scripts/launch_workers.sh`
5. **Andy** pastes startup commands (provided by Strategic Partner)
6. **Workers** execute in parallel, reference issues in commits
7. **Andy** says "workers done"
8. **Strategic Partner** integrates, tests, commits with `Fixes #XX`
9. **GitHub** auto-closes issues

---

## Worker Domains

| Worker | Role | Files Owned |
|--------|------|-------------|
| Dev-1 | UI Layer | `Views/`, `ViewModels/`, `Components/`, `SettingsView.swift` |
| Dev-2 | Core Engine | `RcloneManager.swift` |
| Dev-3 | Services | `Models/`, `*Manager.swift` (except Rclone) |
| QA | Testing | `CloudSyncAppTests/` |

---

## File Structure

```
.github/
├── ISSUE_TEMPLATE/              # Issue templates
│   ├── bug_report.yml
│   ├── feature_request.yml
│   ├── task.yml
│   └── config.yml
└── WORKFLOW.md                  # Complete workflow docs

.claude-team/
├── tasks/                       # Worker task files
├── outputs/                     # Worker completion reports
├── templates/                   # Worker role briefings
├── scripts/
│   └── launch_workers.sh
├── STATUS.md                    # Real-time worker status
├── PROJECT_CONTEXT.md           # Full project context
└── RECOVERY.md                  # Crash recovery guide
```

---

## Quick Reference

### GitHub Issues
```bash
gh issue list                    # View all
gh issue create                  # Create new
gh issue view 47                 # View details
```

### Launch Workers
```bash
~/Claude/.claude-team/scripts/launch_workers.sh
```

### Build
```bash
cd ~/Claude && xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build 2>&1 | tail -10
```

---

## Project Board

**URL**: https://github.com/users/andybod1-lang/projects/1

Kanban view of all issues: Todo → In Progress → Done

---

*Last Updated: 2025-01-12*
