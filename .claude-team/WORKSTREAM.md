# Workstream: Menu Bar Schedule Indicator

> **Sprint Goal:** Add visual indicator in menu bar showing next scheduled sync
> **Started:** 2026-01-12
> **Status:** READY TO LAUNCH

---

## Overview

Add a schedule information section to the menu bar popup showing the next scheduled sync time. This provides at-a-glance visibility into scheduled syncs without opening the app.

**Note:** This is a small feature building on the Scheduled Sync infrastructure completed in the previous sprint.

---

## Task Assignments

| Worker | Task | Status | Files |
|--------|------|--------|-------|
| Dev-1 | Menu Bar UI | Ready | StatusBarController.swift, ContentView.swift, SettingsView.swift |
| Dev-2 | (No changes) | N/A | - |
| Dev-3 | (No changes) | N/A | - |
| QA | Test Coverage | Ready | MenuBarScheduleTests.swift |

---

## File Locks

| File | Locked By | Reason |
|------|-----------|--------|
| CloudSyncApp/StatusBarController.swift | Dev-1 | Adding schedule section |
| CloudSyncApp/ContentView.swift | Dev-1 | Adding notification handler |
| CloudSyncApp/SettingsView.swift | Dev-1 | Adding tab selection |
| CloudSyncAppTests/MenuBarScheduleTests.swift | QA | Creating tests |

---

## Dependencies

```
Previous Sprint (Complete):
- SyncSchedule.swift
- ScheduleManager.swift
- Schedule UI Components

This Sprint:
Dev-1 (Menu Bar UI) ──> QA (Tests) ──> Integration
```

Dev-1 is the primary worker. Dev-2 and Dev-3 have no tasks.

---

## Acceptance Criteria

### Menu Bar UI (Dev-1)
- [ ] Menu bar shows "Next: [schedule name]" with countdown
- [ ] Menu bar shows "No scheduled syncs" when none exist
- [ ] "Manage Schedules..." button opens Settings to Schedules tab
- [ ] Build succeeds

### Tests (QA)
- [ ] MenuBarScheduleTests cover display logic
- [ ] All tests pass

---

## Definition of Done

1. Menu bar shows schedule info
2. Build succeeds
3. Tests pass
4. Lead Report submitted

---

## Notes

- Uses existing ScheduleManager.nextScheduledRun API
- No core engine or service changes required
- Focus on getting the two-tier workflow right
