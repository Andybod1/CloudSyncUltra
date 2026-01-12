# Workstream: Move Schedules to Main Window

> **Sprint Goal:** Elevate Schedules from Settings to main window sidebar
> **Started:** 2026-01-12
> **Status:** READY TO LAUNCH

---

## Overview

Move the Schedules management UI from Settings to the main application window as a primary navigation item. Schedules are a core feature and deserve main-level visibility.

**User Story:** As a user, I want to access my sync schedules directly from the main window so I don't have to dig through Settings.

---

## Task Assignments

| Worker | Task | Status | Files |
|--------|------|--------|-------|
| Dev-1 | Main Window UI | Ready | MainWindow.swift, SchedulesView.swift (new), SettingsView.swift |
| Dev-2 | (No changes) | N/A | - |
| Dev-3 | (No changes) | N/A | - |
| QA | Verification | Ready | Code review + manual testing |

---

## File Locks

| File | Locked By | Reason |
|------|-----------|--------|
| CloudSyncApp/Views/MainWindow.swift | Dev-1 | Adding schedules to sidebar |
| CloudSyncApp/Views/SchedulesView.swift | Dev-1 | Creating new view |
| CloudSyncApp/SettingsView.swift | Dev-1 | Removing Schedules tab |

---

## Dependencies

```
This is primarily a Dev-1 task:

Dev-1 (UI Changes) ──> QA (Verification) ──> Integration
```

Dev-2 and Dev-3 have no tasks this sprint.

---

## Acceptance Criteria

### Main Window (Dev-1)
- [ ] "Schedules" in sidebar between Tasks and History
- [ ] Icon: calendar.badge.clock
- [ ] SchedulesView shows full management UI
- [ ] Empty state when no schedules
- [ ] Menu bar "Manage Schedules..." opens main window

### Settings (Dev-1)
- [ ] Only 4 tabs: General, Accounts, Sync, About
- [ ] Schedules tab removed
- [ ] SelectSchedulesTab notification handler removed

### Verification (QA)
- [ ] Code review complete
- [ ] Manual testing passed
- [ ] Build succeeds

---

## Definition of Done

1. Schedules accessible from main window sidebar
2. Settings has 4 tabs (no Schedules)
3. Menu bar navigation works
4. Build succeeds
5. Lead Report submitted

---

## UI Reference

### Sidebar Order:
1. Dashboard
2. Transfer
3. Tasks
4. **Schedules** ← NEW
5. History
6. (Cloud Storage section)
7. (Local section)
8. Encryption
9. Settings

### SchedulesView Content:
- Header: "Schedules" with "Add Schedule" button
- List of schedules using ScheduleRowView
- Empty state when none
- Edit/Delete sheets using ScheduleEditorSheet

---

## Notes

- Reuse existing components: ScheduleRowView, ScheduleEditorSheet
- ScheduleSettingsView remains in project (for reference/future use)
- No changes to ScheduleManager or any services
