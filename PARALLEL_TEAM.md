# CloudSync Ultra - Two-Tier Parallel Development Team

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              ANDY (Human)                                   │
│                        Vision • Decisions • Direction                       │
└─────────────────────────────────┬───────────────────────────────────────────┘
                                  │ Conversation
                                  ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                    STRATEGIC PARTNER (Desktop App - Opus 4.5)               │
│                                                                             │
│   • Architecture & system design    • Web research when needed              │
│   • Feature planning                • Quality standards                     │
│   • Technical decisions             • Final review & commit                 │
│                                                                             │
│   Writes: DIRECTIVE.md, ARCHITECTURE.md, SPRINT.md, CHANGELOG.md            │
│   Reads: LEAD_REPORT.md, STATUS.md                                          │
└─────────────────────────────────┬───────────────────────────────────────────┘
                                  │ DIRECTIVE.md
                                  ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                      LEAD AGENT (Claude Code CLI - Opus)                    │
│                                                                             │
│   • Break down features into tasks  • Fix build/integration errors          │
│   • Write task files for workers    • Run tests                             │
│   • Monitor worker progress         • Report completion                     │
│                                                                             │
│   Writes: TASK_*.md, WORKSTREAM.md, LEAD_REPORT.md                          │
│   Reads: DIRECTIVE.md, STATUS.md, DEV*_COMPLETE.md                          │
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

## Quick Start

### Full Workflow

1. **Tell Strategic Partner** (Desktop App) what you want to build
2. **Strategic Partner** writes `DIRECTIVE.md`
3. **Launch Lead Agent:**
   ```bash
   ~/.claude-team/scripts/launch_lead.sh
   ```
4. **Lead creates tasks** and says "Launch workers"
5. **Launch Workers:**
   ```bash
   ~/.claude-team/scripts/launch_workers.sh
   ```
6. **Lead monitors, integrates, writes LEAD_REPORT.md**
7. **Strategic Partner** reviews, updates CHANGELOG, commits

### One-Click Launch (Full Team)

```bash
~/.claude-team/scripts/launch_full_team.sh
```

---

## Startup Commands

### Lead Agent (Terminal 1)
```
Read /Users/antti/Claude/.claude-team/LEAD/LEAD_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/STRATEGIC/DIRECTIVE.md. Create task files, update WORKSTREAM.md, and output worker launch commands.
```

### Dev-1 (Terminal 2)
```
Read /Users/antti/Claude/.claude-team/templates/DEV1_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV1.md. Update STATUS.md as you work.
```

### Dev-2 (Terminal 3)
```
Read /Users/antti/Claude/.claude-team/templates/DEV2_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV2.md. Update STATUS.md as you work.
```

### Dev-3 (Terminal 4)
```
Read /Users/antti/Claude/.claude-team/templates/DEV3_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV3.md. Update STATUS.md as you work.
```

### QA (Terminal 5)
```
Read /Users/antti/Claude/.claude-team/templates/QA_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_QA.md. Update STATUS.md as you work.
```

---

## File Structure

```
.claude-team/
├── STRATEGIC/                     # Strategic Partner's domain
│   ├── DIRECTIVE.md               # Current feature spec (SP writes)
│   ├── DIRECTIVE_TEMPLATE.md      # Template for new directives
│   ├── ARCHITECTURE.md            # System design decisions
│   └── SPRINT.md                  # Sprint goals and backlog
│
├── LEAD/                          # Lead Agent's domain
│   ├── LEAD_BRIEFING.md           # Lead's role instructions
│   ├── LEAD_REPORT.md             # Completion report (Lead writes)
│   ├── LEAD_REPORT_TEMPLATE.md    # Template for reports
│   └── INTEGRATION_LOG.md         # Build/test fix history
│
├── tasks/                         # Worker task files
│   ├── TASK_DEV1.md               # UI Layer task
│   ├── TASK_DEV2.md               # Core Engine task
│   ├── TASK_DEV3.md               # Services task
│   └── TASK_QA.md                 # Testing task
│
├── outputs/                       # Worker completion reports
│   ├── DEV1_COMPLETE.md
│   ├── DEV2_COMPLETE.md
│   ├── DEV3_COMPLETE.md
│   └── QA_REPORT.md
│
├── templates/                     # Worker briefings
│   ├── DEV1_BRIEFING.md
│   ├── DEV2_BRIEFING.md
│   ├── DEV3_BRIEFING.md
│   └── QA_BRIEFING.md
│
├── scripts/
│   ├── launch_lead.sh             # Launch Lead Agent
│   ├── launch_workers.sh          # Launch all 4 workers
│   └── launch_full_team.sh        # Launch Lead + Workers
│
├── COMMUNICATION_PROTOCOL.md      # Full protocol documentation
├── STATUS.md                      # Real-time worker status
└── WORKSTREAM.md                  # Current sprint tasks
```

---

## Worker Domains

| Worker | Role | Files Owned |
|--------|------|-------------|
| Dev-1 | UI Layer | `Views/`, `ViewModels/`, `Components/`, `ContentView`, `SettingsView` |
| Dev-2 | Core Engine | `RcloneManager.swift` |
| Dev-3 | Services | `*Manager.swift` (except Rclone), `Models/` |
| QA | Testing | `CloudSyncAppTests/` |

---

## Communication Flow

```
Andy: "Build conflict resolution"
         │
         ▼
Strategic Partner:
  • Discusses requirements
  • Makes architecture decisions
  • Writes DIRECTIVE.md
  • Says: "Launch Lead"
         │
         ▼
Lead Agent:
  • Reads DIRECTIVE.md
  • Creates TASK_DEV1/2/3.md, TASK_QA.md
  • Says: "Launch workers"
         │
         ▼
Workers (parallel):
  • Execute tasks
  • Update STATUS.md
  • Write completion reports
         │
         ▼
Lead Agent:
  • Monitors STATUS.md
  • Integrates code
  • Fixes build errors
  • Runs tests
  • Writes LEAD_REPORT.md
         │
         ▼
Strategic Partner:
  • Reviews LEAD_REPORT.md
  • Updates CHANGELOG.md
  • Commits to git
  • Reports: "Feature complete!"
```

---

## Timing Expectations

| Phase | Duration | Who |
|-------|----------|-----|
| Planning | 5-15 min | Strategic + Andy |
| Task Breakdown | 5-10 min | Lead |
| Execution | 15-30 min | Workers (parallel) |
| Integration | 5-15 min | Lead |
| Review & Commit | 5-10 min | Strategic |
| **Total** | **35-80 min** | |

---

## Benefits

- **~4x speedup** on parallelizable work
- **Zero conflicts** via domain separation
- **Two-tier quality** - Lead integrates, Strategic reviews
- **Clear accountability** - Each tier has defined outputs
- **Autonomous execution** - Workers don't need babysitting

---

## Recovery

After restart:
1. Check `STATUS.md` for any in-progress work
2. Check `DIRECTIVE.md` for current feature
3. Re-launch agents as needed

See `RECOVERY.md` for detailed instructions.

---

*Last Updated: 2026-01-12*
