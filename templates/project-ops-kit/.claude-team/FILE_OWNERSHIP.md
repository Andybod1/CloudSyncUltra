# File Ownership Matrix

> **Purpose:** Defines which worker owns which files/directories.
> **Rule:** Only the owner may modify files in their domain.
> **Updated:** 2026-01-16

---

## Worker Domains

### Dev-1 (UI)
```
CloudSyncApp/Views/                    ✅ Full ownership
CloudSyncApp/ViewModels/               ✅ Full ownership
CloudSyncApp/Components/               ✅ Full ownership
CloudSyncApp/Styles/                   ✅ Full ownership
```

### Dev-2 (Engine)
```
CloudSyncApp/RcloneManager.swift       ✅ Full ownership
CloudSyncApp/TransferOptimizer.swift   ✅ Full ownership
```

### Dev-3 (Services)
```
CloudSyncApp/Models/                   ✅ Full ownership
CloudSyncApp/Managers/                 ✅ Full ownership (except RcloneManager)
```

### QA (Testing)
```
CloudSyncAppTests/                     ✅ Full ownership
CloudSyncAppUITests/                   ✅ Full ownership
```

### Dev-Ops (Infrastructure)
```
.claude-team/                          ✅ Full ownership
scripts/                               ✅ Full ownership
.github/                               ✅ Full ownership
docs/                                  ✅ Full ownership
```

---

## Shared Files (Require Coordination)

These files affect multiple workers. Modification requires Strategic Partner approval:

| File | Impact | Approval Required |
|------|--------|-------------------|
| `CloudSyncAppApp.swift` | App entry point | Strategic Partner |
| `MainWindow.swift` | Navigation structure | Strategic Partner |
| `ContentView.swift` | Root view | Strategic Partner |
| `Info.plist` | App configuration | Strategic Partner |
| `CloudSyncApp.xcodeproj` | Project structure | Strategic Partner |

---

## How to Check Ownership

```bash
# Quick check: Is this file in my domain?
# Replace [FILE] and [WORKER] with actual values

FILE="CloudSyncApp/Views/TasksView.swift"
WORKER="Dev-1"

# Check directory
echo $FILE | grep -E "Views/|ViewModels/|Components/" && echo "→ Dev-1 domain"
echo $FILE | grep -E "RcloneManager|TransferOptimizer" && echo "→ Dev-2 domain"
echo $FILE | grep -E "Models/|Managers/" && echo "→ Dev-3 domain"
```

---

## Conflict Resolution

If your task requires modifying files outside your domain:

1. **STOP** - Do not modify the file
2. **Document** - Write a blocking report
3. **Alert** - Add to ALERTS.md
4. **Wait** - Strategic Partner will reassign or grant permission

---

## Permission Grants (Temporary)

Strategic Partner may grant temporary cross-domain access:

| Date | Worker | File | Reason | Expires |
|------|--------|------|--------|---------|
| (none currently) | | | | |

---

*Last updated: 2026-01-16*
