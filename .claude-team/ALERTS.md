# Worker Alerts

> **Purpose:** Real-time alerts from workers to Strategic Partner
> **Check this file regularly during active sprints**

---

## Active Alerts

| Timestamp | Worker | Type | Description | Status |
|-----------|--------|------|-------------|--------|
| - | - | - | No active alerts | ✅ |

---

## Alert Format

Workers: Add alerts using this format:
```bash
echo "⚠️ $(date +%Y-%m-%d\ %H:%M) | [WORKER] | [TYPE] | [Description]" >> .claude-team/ALERTS.md
```

Types:
- `BLOCKED` - Cannot proceed, needs intervention
- `BUILD BROKEN` - Build fails, cannot fix
- `OWNERSHIP CONFLICT` - Task requires other worker's files
- `MISSING TYPE` - Need a type that doesn't exist
- `QUESTION` - Need clarification

---

## Resolution Log

| Date | Alert | Resolution |
|------|-------|------------|
| 2026-01-16 | Dev-2 blocked on #103 | Reassigned to Dev-1 |
| 2026-01-16 | Dev-1 blocked on #106 | SP granted one-time permission |
| 2026-01-16 | Dev-1 blocked on #113 | SP added files to Xcode project |

---

*Strategic Partner: Clear resolved alerts weekly*
