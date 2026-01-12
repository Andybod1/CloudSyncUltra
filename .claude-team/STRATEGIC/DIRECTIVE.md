# Strategic Directive

> Written by: Strategic Partner (Desktop Opus)
> For: Lead Agent
> Date: 2026-01-12

---

## Feature: Menu Bar Schedule Indicator

### Overview
Add a visual indicator in the menu bar showing when the next scheduled sync will run. This provides at-a-glance visibility without opening the app.

### User Story
As a user, I want to see my next scheduled sync time in the menu bar so I know my backups are configured without opening the app.

---

## Architecture Decisions

### Approach
Extend the existing MenuBarView to show schedule information from ScheduleManager.

### Key Design Choices
1. Show next schedule name and time in menu bar popup
2. Use existing ScheduleManager.shared singleton
3. Keep it simple - just display, no controls in menu bar

---

## Task Breakdown

### Dev-1 (UI Layer)
**Files to modify:**
- [ ] `Views/MenuBarView.swift` - Add schedule section

**Key requirements:**
- Show "Next: [schedule name]" with countdown
- Show "No scheduled syncs" if none exist
- Add "Manage Schedules..." button that opens Settings

### Dev-2 (Core Engine)
**No changes needed for this feature.**

Create a placeholder task acknowledging no work needed.

### Dev-3 (Services)
**No changes needed for this feature.**

Create a placeholder task acknowledging no work needed.

### QA (Testing)
**Files to create:**
- [ ] `CloudSyncAppTests/MenuBarScheduleTests.swift`

**Test coverage required:**
- Test schedule display formatting
- Test empty state handling

---

## Acceptance Criteria

- [ ] Menu bar popup shows next scheduled sync
- [ ] Shows "No scheduled syncs" when none exist
- [ ] "Manage Schedules..." opens Settings
- [ ] Build succeeds with zero errors
- [ ] Tests pass

---

## Dependencies

- Requires ScheduleManager (already exists)
- Requires SyncSchedule model (already exists)

---

## Out of Scope

- Menu bar icon changes (badge, different icons)
- Pause/resume controls in menu bar
- Schedule creation from menu bar

---

## Notes for Lead

- This is a small feature to test the two-tier workflow
- Dev-2 and Dev-3 can have minimal placeholder tasks
- Focus on getting the workflow right

---

## Definition of Done

1. Menu bar shows schedule info
2. Build succeeds
3. Tests pass
4. Lead Report submitted
