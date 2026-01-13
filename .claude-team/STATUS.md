# Worker Status

> Last Updated: 2026-01-13 16:45 UTC
> Version: v2.0.13 (in progress)

## Current State: Sprint Active 🚀

**Sprint:** Test Health + Issue Cleanup (v2.0.13)

| Worker | Model | Status | Current Task |
|--------|-------|--------|--------------|
| Dev-1 | - | 💤 IDLE | - |
| Dev-2 | - | 💤 IDLE | - |
| Dev-3 | - | 💤 IDLE | - |
| QA | Opus | 🔄 ASSIGNED | Fix 23 test failures (#35) |
| Dev-Ops | Opus | 🔄 ASSIGNED | Close #30, update docs |

---

## Active Sprint Tasks

| Ticket | Title | Worker | Size |
|--------|-------|--------|------|
| #30 | Close Google Photos issue | Dev-Ops | XS |
| #35 | Fix 23 test failures | QA | M |

---

## Team Structure

| Worker | Domain | Model Rule |
|--------|--------|------------|
| Dev-1 | UI (Views, ViewModels) | Sonnet XS/S, Opus M/L/XL |
| Dev-2 | Engine (RcloneManager) | Sonnet XS/S, Opus M/L/XL |
| Dev-3 | Services (Models, Managers) | Sonnet XS/S, Opus M/L/XL |
| QA | Testing | **ALWAYS Opus** |
| Dev-Ops | Git, GitHub, Docs | **ALWAYS Opus + /think** |

---

## Worker Launch Commands

```bash
# Launch single worker
~/Claude/.claude-team/scripts/launch_single_worker.sh [worker] [model]

# Examples:
~/Claude/.claude-team/scripts/launch_single_worker.sh qa opus
~/Claude/.claude-team/scripts/launch_single_worker.sh devops opus
~/Claude/.claude-team/scripts/launch_single_worker.sh dev-1 sonnet
```

### Startup Commands (paste into Claude Code terminal)

```
Dev-1: Read /Users/antti/Claude/.claude-team/templates/DEV1_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV1.md. Update STATUS.md as you work.

Dev-2: Read /Users/antti/Claude/.claude-team/templates/DEV2_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV2.md. Update STATUS.md as you work.

Dev-3: Read /Users/antti/Claude/.claude-team/templates/DEV3_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEV3.md. Update STATUS.md as you work.

QA: Read /Users/antti/Claude/.claude-team/templates/QA_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_QA.md. Update STATUS.md as you work.

Dev-Ops: Read /Users/antti/Claude/.claude-team/templates/DEVOPS_BRIEFING.md then read and execute /Users/antti/Claude/.claude-team/tasks/TASK_DEVOPS.md. Update STATUS.md as you work.
```

---

## Task & Output Locations

| Type | Location |
|------|----------|
| Tasks | `.claude-team/tasks/TASK_*.md` |
| Outputs | `.claude-team/outputs/*_COMPLETE.md` |
| Briefings | `.claude-team/templates/*_BRIEFING.md` |
| Worker Models | `.claude-team/WORKER_MODELS.conf` |

---

## Previous Sprint: Quick Wins + Polish (v2.0.12) ✅

- #14 Drag & drop sidebar reordering ✅
- #25 Account name in encryption view ✅
- #1 Bandwidth throttling controls ✅
- 19 new tests added

---

*Status maintained by Strategic Partner*
