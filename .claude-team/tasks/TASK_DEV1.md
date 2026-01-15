# TASK: Transfer Progress Counter (#96)

## Ticket
**GitHub:** #96
**Type:** UI Enhancement
**Size:** S (30-45 min)
**Priority:** High (Andy: "Critical")

---

## Objective

Display concurrent transfer count in progress UI showing "X/Y transfers" (active transfers / max parallel).

---

## Problem

Users cannot see how many transfers are running concurrently out of the maximum possible. This makes it hard to understand transfer progress and system utilization.

---

## Solution

Add a transfer counter indicator to the transfer progress UI that shows:
- Current active transfers
- Maximum parallel transfers allowed
- Format: "3/8 transfers" or similar

---

## Implementation

### Data Source
The data is already available in `TransferEngine`:
- `parallelismConfig.maxParallel` - maximum concurrent transfers
- Active transfer count from running tasks

### Files to Modify

1. **TransferViewModel.swift** (if needed)
   - Expose `activeTransferCount` and `maxParallelTransfers`
   - May already be available via TransferEngine

2. **TransferProgressView.swift** or **TransferView.swift**
   - Add UI element showing "X/Y transfers"
   - Position near existing progress indicators

### UI Considerations
- Keep it subtle but visible
- Match existing styling
- Consider: "3/8 transfers" or "Transfers: 3/8" or icon + "3/8"

---

## Acceptance Criteria

- [ ] Transfer count visible during active transfers
- [ ] Shows format like "X/Y transfers" (active/max)
- [ ] Updates in real-time as transfers start/complete
- [ ] Hidden or shows "0/Y" when no transfers active
- [ ] Matches existing UI styling
- [ ] Tests added for new functionality

---

## Reference Files

```
CloudSyncApp/Views/TransferView.swift
CloudSyncApp/Views/TransferProgressView.swift
CloudSyncApp/ViewModels/TransferViewModel.swift
CloudSyncApp/TransferEngine/TransferEngine.swift
```

---

## Notes

- This is a quick win - keep implementation simple
- Data should already be available, just needs UI exposure
- Check how TransferOptimizer.parallelismConfig is accessed

---

*Task created: 2026-01-15*
*Sprint: v2.0.23 "Launch Ready"*
