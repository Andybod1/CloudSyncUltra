# File Ownership Matrix

> **Purpose:** Defines which worker owns which files/directories.
> **Rule:** Only the owner may modify files in their domain.
> **Updated:** {{DATE}}

---

## Worker Domains

### Dev-1 (UI)
```
{{SOURCE_DIR}}/Views/                    ✅ Full ownership
{{SOURCE_DIR}}/ViewModels/               ✅ Full ownership
{{SOURCE_DIR}}/Components/               ✅ Full ownership
{{SOURCE_DIR}}/Styles/                   ✅ Full ownership
```

### Dev-2 (Engine)
```
{{SOURCE_DIR}}/CoreEngine/               ✅ Full ownership
{{SOURCE_DIR}}/ServiceInterface.swift    ✅ Full ownership
```

### Dev-3 (Services)
```
{{SOURCE_DIR}}/Models/                   ✅ Full ownership
{{SOURCE_DIR}}/Managers/                 ✅ Full ownership (except core engine)
```

### QA (Testing)
```
{{TEST_DIR}}/                            ✅ Full ownership
{{UI_TEST_DIR}}/                         ✅ Full ownership
```

### Dev-Ops (Infrastructure)
```
.claude-team/                            ✅ Full ownership
scripts/                                 ✅ Full ownership
.github/                                 ✅ Full ownership
docs/                                    ✅ Full ownership
```

---

## Shared Files (Require Coordination)

These files affect multiple workers. Modification requires Strategic Partner approval:

| File | Impact | Approval Required |
|------|--------|-------------------|
| `{{APP_ENTRY_POINT}}` | App entry point | Strategic Partner |
| `MainWindow.swift` | Navigation structure | Strategic Partner |
| `ContentView.swift` | Root view | Strategic Partner |
| `Info.plist` | App configuration | Strategic Partner |
| `{{PROJECT_FILE}}` | Project structure | Strategic Partner |

---

## How to Check Ownership

```bash
# Quick check: Is this file in my domain?
# Replace [FILE] and [WORKER] with actual values

FILE="{{SOURCE_DIR}}/Views/TasksView.swift"
WORKER="Dev-1"

# Check directory
echo $FILE | grep -E "Views/|ViewModels/|Components/" && echo "→ Dev-1 domain"
echo $FILE | grep -E "CoreEngine|ServiceInterface" && echo "→ Dev-2 domain"
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

*Last updated: {{DATE}}*
