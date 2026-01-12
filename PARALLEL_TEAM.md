# Parallel Development Team

CloudSync Ultra uses a **parallel development system** where the Strategic Partner (Desktop Claude) directly coordinates 4 workers.

**All work is tracked via GitHub Issues** for crash-proof persistence.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              ANDY (Human)                                   │
│                   Vision • Decisions • Direction • Issues                   │
└─────────────────────────────────┬───────────────────────────────────────────┘
                                  │
                        Creates GitHub Issues
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│              STRATEGIC PARTNER (Desktop Claude - Opus 4.5)                  │
│                                                                             │
│   Reviews Issues • Plans • Assigns Workers • Integrates • Closes Issues     │
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

## GitHub Issues Workflow

```bash
# View issue dashboard
/Users/antti/Claude/.github/dashboard.sh

# Create issues
gh issue create --title "[Bug]: description" --label "bug,triage"
gh issue create --title "[Feature]: description" --label "enhancement,triage"

# View by status
gh issue list --label "ready"        # Planned, ready for workers
gh issue list --label "in-progress"  # Currently being worked
```

See `.github/WORKFLOW.md` for complete documentation.

---

## Workflow

1. **Andy** creates GitHub Issue (bug, feature, or idea)
2. **Strategic Partner** reviews, adds labels (`ready`, `worker:*`, `size:*`)
3. **Strategic Partner** writes task files referencing issue number
4. **Andy** runs: `~/Claude/.claude-team/scripts/launch_workers.sh`
5. **Andy** pastes startup commands (provided by Strategic Partner)
6. **Workers** execute in parallel
7. **Andy** says "workers done"
8. **Strategic Partner** integrates code, fixes builds, runs tests
9. **Strategic Partner** closes issue, updates CHANGELOG, commits to git

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
├── ISSUE_TEMPLATE/            # Issue templates (bug, feature, task)
├── WORKFLOW.md                # Complete workflow documentation
└── dashboard.sh               # Issue dashboard script

.claude-team/
├── tasks/                     # Task files (Strategic Partner writes)
│   ├── TASK_DEV1.md
│   ├── TASK_DEV2.md
│   ├── TASK_DEV3.md
│   └── TASK_QA.md
├── outputs/                   # Worker completion reports
├── templates/                 # Worker role briefings
├── scripts/
│   └── launch_workers.sh      # Launch 4 worker terminals
├── STATUS.md                  # Real-time worker status
├── PROJECT_CONTEXT.md         # Full project context
└── RECOVERY.md                # Crash recovery guide
```

---

## Quick Reference

### View Issues Dashboard
```bash
/Users/antti/Claude/.github/dashboard.sh
```

### Launch Workers
```bash
~/Claude/.claude-team/scripts/launch_workers.sh
```

### Check Status
```bash
cat ~/Claude/.claude-team/STATUS.md
```

### Build
```bash
cd ~/Claude && xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build 2>&1 | tail -10
```

---

*Last Updated: 2026-01-12*
