# Parallel Development Team

CloudSync Ultra uses a **parallel development system** where the Strategic Partner (Desktop Claude) directly coordinates 4 workers.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              ANDY (Human)                                   │
│                        Vision • Decisions • Direction                       │
└─────────────────────────────────┬───────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│              STRATEGIC PARTNER (Desktop Claude - Opus 4.5)                  │
│                                                                             │
│   Architecture • Planning • Task Creation • Integration • Review            │
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

## Workflow

1. **Andy + Strategic Partner** discuss feature
2. **Strategic Partner** writes task files directly
3. **Andy** runs: `~/Claude/.claude-team/scripts/launch_workers.sh`
4. **Andy** pastes startup commands (provided by Strategic Partner)
5. **Workers** execute in parallel
6. **Andy** says "workers done"
7. **Strategic Partner** integrates code, fixes builds, runs tests
8. **Strategic Partner** updates CHANGELOG, commits to git

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
