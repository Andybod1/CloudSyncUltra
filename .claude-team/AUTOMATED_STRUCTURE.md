# CloudSync Ultra - Fully Automated Structure

> Strategic Partner (Desktop Claude) runs everything directly.
> No manual terminal launching needed.

---

## Architecture

```
Andy (Human)
    │ "I want feature X"
    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│              STRATEGIC PARTNER (Desktop Opus 4.5)                           │
│                                                                             │
│   1. Discuss & design with Andy                                             │
│   2. Write task files                                                       │
│   3. Launch workers via: claude -p "execute task"                           │
│   4. Monitor completion                                                     │
│   5. Integrate code                                                         │
│   6. Fix builds, add files to Xcode                                         │
│   7. Run tests                                                              │
│   8. Commit to git                                                          │
│   9. Launch app                                                             │
└──────┬──────────────┬──────────────┬──────────────┬─────────────────────────┘
       │              │              │              │
       ▼              ▼              ▼              ▼
   ┌───────┐      ┌───────┐      ┌───────┐      ┌───────┐
   │ Dev-1 │      │ Dev-2 │      │ Dev-3 │      │  QA   │
   │Sonnet │      │Sonnet │      │Sonnet │      │Sonnet │
   │  UI   │      │Engine │      │Service│      │ Test  │
   └───────┘      └───────┘      └───────┘      └───────┘
   claude -p      claude -p      claude -p      claude -p
```

---

## How It Works

### You Say:
```
"I want drag and drop reordering for schedules"
```

### I Do Everything:
1. Design the feature
2. Write task files (TASK_DEV1.md, etc.)
3. Run workers in parallel:
   ```bash
   claude -p "Read and execute /path/to/TASK_DEV1.md" &
   claude -p "Read and execute /path/to/TASK_DEV2.md" &
   claude -p "Read and execute /path/to/TASK_DEV3.md" &
   claude -p "Read and execute /path/to/TASK_QA.md" &
   ```
4. Wait for completion
5. Add new files to Xcode
6. Fix any build errors
7. Run tests
8. Commit to git
9. Launch app
10. Report: "Done! Test the feature."

### You Do:
- Request features
- Test the results
- Give feedback

---

## Worker Domains

| Worker | Role | Files Owned |
|--------|------|-------------|
| Dev-1 | UI | `Views/`, `ViewModels/`, `SettingsView.swift` |
| Dev-2 | Engine | `RcloneManager.swift` |
| Dev-3 | Services | `Models/`, `*Manager.swift` (except Rclone) |
| QA | Testing | `CloudSyncAppTests/` |

---

## File Structure

```
.claude-team/
├── tasks/                    # Task assignments
│   ├── TASK_DEV1.md
│   ├── TASK_DEV2.md
│   ├── TASK_DEV3.md
│   └── TASK_QA.md
│
├── outputs/                  # Worker reports
│   ├── DEV1_COMPLETE.md
│   ├── DEV2_COMPLETE.md
│   ├── DEV3_COMPLETE.md
│   └── QA_REPORT.md
│
├── templates/                # Worker briefings
│   ├── DEV1_BRIEFING.md
│   ├── DEV2_BRIEFING.md
│   ├── DEV3_BRIEFING.md
│   └── QA_BRIEFING.md
│
└── STATUS.md                 # Completion tracking
```

---

## Benefits

| Aspect | Old Way | New Way |
|--------|---------|---------|
| Terminals | 4-5 manual | 0 (I run them) |
| Your involvement | Launch + paste commands | Just request features |
| Coordination | You relay messages | I handle everything |
| Speed | Wait for humans | Fully automated |

---

## Workflow Summary

```
You: "Add feature X"
Me:  [designs, writes tasks, runs workers, integrates, tests, commits]
Me:  "Done! App launched. Test the feature."
You: [tests]
You: "Looks good" or "Change Y"
```

---

*Last Updated: 2026-01-12*
