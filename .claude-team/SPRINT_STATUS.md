# Sprint: v2.0.29 - Clean-up Sprint

**Started:** 2026-01-16
**Target Version:** 2.0.29
**Status:** 🟢 COMPLETE

---

## Sprint Goals

Remove Team Plan from all views and code (#106):
- Clean up subscription model
- Remove dead-end features
- Simplify UI

---

## Worker Status

| Worker | Status | Issues | Task File |
|--------|--------|--------|-----------|
| **Dev-1** | 🟢 Running | #106 | TASK_DEV1.md |

---

## Phase 1 - Clean-up

| # | Title | Worker | Size | Status |
|---|-------|--------|------|--------|
| 106 | Remove Team Plan from all views | Dev-1 | M | ✅ Complete |

---

## Files to Modify

| File | Changes |
|------|---------|
| `Models/SubscriptionTier.swift` | Remove `.team` case from enum |
| `Views/PaywallView.swift` | Remove team from tier list |
| `Views/SubscriptionView.swift` | Remove team case handling |
| `Managers/StoreKitManager.swift` | Remove team product ID |
| `Configuration.storekit` | Remove team product config |

---

## Launch Command

```bash
# Launch Dev-1 worker
.claude-team/scripts/launch_single_worker.sh dev-1 sonnet
```

---

## Definition of Done

- [x] #106: No Team Plan visible anywhere in app
- [x] No orphaned code related to Team Plan
- [x] Build passes
- [x] QA verification complete
- [x] Issue closed on GitHub

---

## Previous Sprint

**v2.0.28** - Completed 2026-01-16
- Fixed: #111, #108, #107, #105, #99
- UI Polish Sprint

---

*Last Updated: 2026-01-16*
