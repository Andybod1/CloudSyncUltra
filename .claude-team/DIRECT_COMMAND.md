# CloudSync Ultra - Direct Command Structure

> Strategic Partner (Desktop Claude) directly manages 4 workers.
> No Lead Agent needed.

---

## Architecture

```
Andy (Human)
    │ "I want feature X"
    ▼
Strategic Partner (Desktop Opus 4.5)
    │
    ├── Writes task files directly
    ├── Monitors STATUS.md
    ├── Integrates code
    ├── Fixes builds
    ├── Runs tests
    ├── Commits to git
    │
    ├──▶ Dev-1 (UI) ────────▶ Sonnet
    ├──▶ Dev-2 (Engine) ────▶ Sonnet
    ├──▶ Dev-3 (Services) ──▶ Sonnet
    └──▶ QA (Testing) ──────▶ Sonnet
```

---

## Workflow

### 1. You Request a Feature
```
"I want conflict resolution"
```

### 2. I Create Task Files
I write directly to:
- `tasks/TASK_DEV1.md`
- `tasks/TASK_DEV2.md`
- `tasks/TASK_DEV3.md`
- `tasks/TASK_QA.md`

Then I say: **"Tasks ready. Launch workers."**

### 3. You Launch Workers
```bash
~/Claude/.claude-team/scripts/launch_workers.sh
```

Paste startup commands in each terminal.

### 4. Workers Execute
Workers read their task files, write code, update STATUS.md.

### 5. You Tell Me When Done
```
"Workers done"
```

### 6. I Integrate
- Check STATUS.md and outputs/
- Add new files to Xcode project
- Fix any build errors
- Run tests
- Commit to git
- Launch app

### 7. Done
I report completion and you test the feature.

---

## File Structure

```
.claude-team/
├── tasks/                    # I write these
│   ├── TASK_DEV1.md
│   ├── TASK_DEV2.md
│   ├── TASK_DEV3.md
│   └── TASK_QA.md
│
├── outputs/                  # Workers write these
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
├── scripts/
│   └── launch_workers.sh     # Only script needed
│
├── STATUS.md                 # Workers update, I monitor
├── PROJECT_CONTEXT.md        # Recovery file
├── RECOVERY.md               # Crash recovery
└── QUICK_START.md            # Quick context restore
```

---

## Worker Domains

| Worker | Owns | Never Touches |
|--------|------|---------------|
| Dev-1 | `Views/`, `ViewModels/`, `SettingsView.swift` | RcloneManager, Models, Tests |
| Dev-2 | `RcloneManager.swift` | Views, Models, Tests |
| Dev-3 | `Models/`, `*Manager.swift` (except Rclone) | Views, RcloneManager, Tests |
| QA | `CloudSyncAppTests/` | Source code |

---

## Startup Commands

### Dev-1 (UI)
```
Read /Users/antti/Claude/.claude-team/templates/DEV1_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV1.md. Update STATUS.md as you work.
```

### Dev-2 (Engine)
```
Read /Users/antti/Claude/.claude-team/templates/DEV2_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV2.md. Update STATUS.md as you work.
```

### Dev-3 (Services)
```
Read /Users/antti/Claude/.claude-team/templates/DEV3_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV3.md. Update STATUS.md as you work.
```

### QA (Testing)
```
Read /Users/antti/Claude/.claude-team/templates/QA_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_QA.md. Update STATUS.md as you work.
```

---

## Benefits Over Two-Tier

| Aspect | Two-Tier (with Lead) | Direct Command |
|--------|---------------------|----------------|
| Terminals needed | 5 (Lead + 4 workers) | 4 (workers only) |
| API quota | Higher (Lead uses Opus) | Lower (only Sonnet workers) |
| Coordination | Through Lead | Direct from me |
| Speed | Lead adds latency | Faster |
| Complexity | More moving parts | Simpler |

---

## Quick Reference

### To Build a Feature:
1. Tell me what you want
2. I write task files → "Tasks ready. Launch workers."
3. You run: `~/Claude/.claude-team/scripts/launch_workers.sh`
4. Paste startup commands
5. Tell me: "Workers done"
6. I integrate and commit
7. Test the feature

---

*Last Updated: 2026-01-12*
