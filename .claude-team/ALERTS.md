# Worker Alerts

> **Purpose:** Real-time alerts from workers to Strategic Partner
> **Check this file regularly during active sprints**

---

## Active Alerts

| Timestamp | Worker | Type | Description | Status |
|-----------|--------|------|-------------|--------|
| 2026-01-16 08:14 | Dev-2 | BLOCKED | #103 requires Dev-1 files (Views/) | ✅ Resolved - Reassigned |

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

---

*Strategic Partner: Clear resolved alerts weekly*
⚠️ 2026-01-16 10:09 | dev-1 | BLOCKED | #106 requires dev-3 files (Models/, Managers/)
✅ 2026-01-16 10:15 | SP | RESOLVED | Dev-1 granted one-time permission for #106 files
