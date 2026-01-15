# Worker Status

> Last Updated: {DATE}
> Version: {VERSION}

## Current State: {STATE}

---

## 🛑 INTEGRATION CHECKLIST (When Sprint Complete)

> **STOP! Before celebrating "done", run this:**

```bash
# Option A: Automated (PREFERRED)
./scripts/release.sh X.X.X

# Option B: Manual - READ THE CHECKLIST FIRST
cat {PROJECT_ROOT}/CLAUDE_PROJECT_KNOWLEDGE.md | grep -A 80 "MANDATORY: Post-Sprint"
```

**The checklist exists because we WILL forget steps. Use the system!**

| Step | Command | Verify |
|------|---------|--------|
| 0. Health check | `./scripts/dashboard.sh` | Score noted |
| 1. Build & Test | Build + test + launch app | App works |
| 2. Version update | `./scripts/update-version.sh X.X.X` | `./scripts/version-check.sh` passes ✅ |
| 3. Update docs | CHANGELOG, STATUS, RECOVERY, PROJECT_KNOWLEDGE | All have new version |
| 4. GitHub | `gh issue close <numbers>` | Issues closed |
| 5. Archive tasks | Move TASK_*.md to archive | Tasks cleared |
| 6. Git | `git commit`, `git tag`, `git push --tags` | Tagged & pushed |
| 7. Ops review | `./scripts/dashboard.sh` | Health maintained |

---

## Active Sprint: {SPRINT_NAME}

| Worker | Status | Task | ETA |
|--------|--------|------|-----|
| Dev-1 | ⚪ Idle | - | - |
| Dev-2 | ⚪ Idle | - | - |
| Dev-3 | ⚪ Idle | - | - |
| QA | ⚪ Idle | - | - |
| Dev-Ops | ⚪ Idle | - | - |

---

## File Ownership

```
Dev-1   → Views/, ViewModels/, Components/
Dev-2   → Core engine files
Dev-3   → Models/, *Manager.swift, Services/
QA      → *Tests/
Dev-Ops → docs/, scripts/, .github/
```

---

## Sprint Progress

```
[░░░░░░░░░░░░░░░░░░░░] 0%
```

---

## Quick Commands

```bash
# Launch workers
{PROJECT_ROOT}/.claude-team/scripts/launch_all_workers.sh

# Check health
./scripts/dashboard.sh

# Post-sprint (ALWAYS USE THIS)
./scripts/release.sh X.X.X
```

---

*Status maintained by Strategic Partner*
