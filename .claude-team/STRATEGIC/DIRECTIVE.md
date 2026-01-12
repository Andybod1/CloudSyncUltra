# Strategic Directive

> Written by: Strategic Partner (Desktop Opus)
> For: Lead Agent
> Date: 2026-01-12

---

## Feature: Move Schedules to Main Window

### Overview
Move the Schedules management UI from Settings to the main application window as a primary navigation item. Schedules are a core feature and deserve main-level visibility.

### User Story
As a user, I want to access my sync schedules directly from the main window so I don't have to dig through Settings.

---

## Architecture Decisions

### Approach
1. Add "Schedules" as a new sidebar item in MainWindow
2. Create a dedicated SchedulesView for the main content area
3. Remove the Schedules tab from SettingsView
4. Keep "Manage Schedules..." menu bar button but have it navigate to main window

### Key Design Choices
1. Schedules appears in sidebar alongside Dashboard, Files, Transfer, Tasks, History
2. Reuse existing ScheduleSettingsView content (list, add/edit sheets)
3. SettingsView returns to 4 tabs: General, Accounts, Sync, About

---

## Task Breakdown

### Dev-1 (UI Layer)
**Files to modify:**
- [ ] `Views/MainWindow.swift` - Add Schedules to sidebar navigation
- [ ] `SettingsView.swift` - Remove Schedules tab, revert to 4 tabs
- [ ] `StatusBarController.swift` - Update "Manage Schedules..." to open main window

**Files to create:**
- [ ] `Views/SchedulesView.swift` - Main window schedules view (adapt from ScheduleSettingsView)

**Key requirements:**
- Sidebar icon: "calendar.badge.clock"
- Schedules view shows full schedule management UI
- Empty state when no schedules
- Add Schedule button prominent
- Menu bar "Manage Schedules..." opens main window to Schedules tab

### Dev-2 (Core Engine)
**No changes needed.**

### Dev-3 (Services)
**No changes needed.**

### QA (Testing)
**Files to update:**
- [ ] Verify existing schedule tests still pass
- [ ] Manual test: sidebar navigation works
- [ ] Manual test: menu bar button navigates correctly

---

## Acceptance Criteria

- [ ] "Schedules" appears in main window sidebar
- [ ] Clicking Schedules shows schedule management UI
- [ ] Settings no longer has Schedules tab (back to 4 tabs)
- [ ] Menu bar "Manage Schedules..." opens main window to Schedules
- [ ] All existing schedule functionality works
- [ ] Build succeeds with zero errors

---

## UI Reference

### Sidebar Order:
1. Dashboard
2. Files
3. Transfer
4. Tasks
5. **Schedules** ← NEW
6. History

### SchedulesView Content:
- Header: "Schedules" with "Add Schedule" button
- List of schedules (reuse ScheduleRowView)
- Empty state when none
- Edit/Delete sheets (reuse ScheduleEditorSheet)

---

## Out of Scope

- New schedule functionality
- Changes to ScheduleManager
- Changes to schedule execution logic

---

## Notes for Lead

- This is primarily a Dev-1 (UI) task
- Reuse existing components: ScheduleRowView, ScheduleEditorSheet
- Main change is moving UI from Settings to MainWindow
- Dev-2, Dev-3, QA have minimal/no work

---

## Definition of Done

1. Schedules accessible from main window sidebar
2. Settings has 4 tabs (no Schedules)
3. Menu bar navigation works
4. Build succeeds
5. Lead Report submitted
