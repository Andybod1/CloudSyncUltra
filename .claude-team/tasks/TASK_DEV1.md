# Task: UI Polish Sprint - 5 XS Issues

## Worker: Dev-1 (UI)
## Priority: LOW
## Size: 5×XS (~1-2 hrs total)

---

## Pre-Flight Checklist

```bash
# Verify ownership - all UI files should be Dev-1 domain
./scripts/check-ownership.sh CloudSyncApp/Views dev-1
```

---

## Issue 1: Path Breadcrumb Text Size (#111)

### Problem
Path breadcrumb (e.g., "/Users/Antti") has smaller text than "Search files..." placeholder.

### Expected
Both should have the same text size for visual consistency.

### Location
File browser view - top bar area

### Fix
Find the breadcrumb Text view and match its font size to the search field.

### Files to Check
- `CloudSyncApp/Views/FileBrowser*.swift`
- Look for breadcrumb/path display component

---

## Issue 2: Style Clear History Button (#108)

### Problem
"Clear History" button has different style than "Add Schedule" button.

### Expected
Match the button style to "Add Schedule" for consistency.

### Location
History view → top right "Clear History" button

### Files to Check
- `CloudSyncApp/Views/HistoryView.swift`
- Reference: `CloudSyncApp/Views/ScheduleView.swift` for Add Schedule style

---

## Issue 3: Style New Task Button (#107)

### Problem
"+ New Task" button is large purple gradient, too prominent.

### Expected
Match the style to "Add Schedule" button (subtle, consistent).

### Location
Tasks view → top right "+ New Task" button

### Files to Check
- `CloudSyncApp/Views/TaskView.swift` or similar
- Reference: `CloudSyncApp/Views/ScheduleView.swift` for Add Schedule style

---

## Issue 4: Move Quick Access Section (#105)

### Problem
"Quick Access" toggle in Performance settings is too prominent.

### Expected
Move Quick Access section to BOTTOM of Performance settings view.

### Location
Settings → Performance → Quick Access section

### Files to Check
- `CloudSyncApp/Views/PerformanceSettingsView.swift`
- `CloudSyncApp/SettingsView.swift`

---

## Issue 5: Drag Files Hint Text (#99)

### Problem
"Drag files between panes to transfer" hint is:
- Too small
- Wrapping word-by-word awkwardly

### Expected
- Larger, readable font size
- Proper text wrapping or single line

### Location
File browser view - hint text area

### Files to Check
- `CloudSyncApp/Views/FileBrowser*.swift`
- Look for hint/placeholder text

---

## Quality Requirements

Before marking EACH issue complete:
1. Run `./scripts/worker-qa.sh`
2. Build must SUCCEED
3. Visually verify the fix

## Batch Strategy

Since all are XS UI fixes:
1. Fix all 5 issues
2. Run single build verification
3. Write completion report with all fixes

## Progress Updates

Update this section every 30 minutes:

```markdown
## Progress - 08:45
**Status:** ✅ COMPLETE
**Working on:** Task completed successfully
**Completed:** All 5 issues addressed - fixed #111 and #99, confirmed #105/#107/#108 already fixed
**Blockers:** None
```

---

*Sprint v2.0.28 - UI Polish Sprint*
