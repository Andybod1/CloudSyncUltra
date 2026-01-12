# Dev-3 Task: Remove Jottacloud Experimental Badge

## Issue
- #24 (Low): Remove experimental badge from Jottacloud

---

## Problem
Jottacloud integration is stable and tested. The "experimental" badge creates unnecessary user hesitation.

## Fix
Find Jottacloud in `CloudProvider.swift` and set `isExperimental` to `false`.

### Implementation
```swift
// In CloudProvider.swift - find Jottacloud case
case .jottacloud:
    return CloudProviderInfo(
        displayName: "Jottacloud",
        ...
        isExperimental: false,  // ← Change from true to false
        ...
    )
```

## Files to Modify
- `CloudSyncApp/Models/CloudProvider.swift`

---

## Completion Checklist
- [ ] Find Jottacloud provider definition
- [ ] Change `isExperimental: true` to `isExperimental: false`
- [ ] Build and verify no "Experimental" badge shows
- [ ] Update STATUS.md when done

## Commit
```
git commit -m "chore(providers): Remove experimental badge from Jottacloud - Fixes #24"
```

---

## Time Estimate
5 minutes
