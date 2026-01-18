# Worker Onboarding Guide

> **Time to complete:** 5 minutes
> **Purpose:** Get up to speed quickly and avoid common mistakes

---

## Quick Start (Do This First)

```bash
# 1. Restore context (2 min)
./scripts/restore-context.sh

# 2. Read common mistakes (2 min)
cat .claude-team/COMMON_MISTAKES.md

# 3. Check your task assignment
cat .claude-team/STATUS.md
```

---

## Before You Start Coding

### 1. Understand the Codebase

| Resource | Purpose |
|----------|---------|
| `.claude-team/TYPE_INVENTORY.md` | All types, protocols, managers |
| `CloudSyncApp/Models/` | Data models |
| `CloudSyncApp/Managers/` | Business logic |
| `CloudSyncApp/Views/` | SwiftUI views |

### 2. Check Existing Implementation

Before creating anything new:

```bash
# Search for existing types
grep -r "class.*Manager" CloudSyncApp/
grep -r "struct.*View" CloudSyncApp/Views/

# Check if provider already exists
grep -i "your-provider" CloudSyncApp/Models/CloudProviderType.swift
```

### 3. Know the Key Files

| File | What It Contains |
|------|------------------|
| `CloudProviderType.swift` | All 50+ cloud providers |
| `RcloneManager.swift` | Backend setup functions |
| `ConfigureSettingsStep.swift` | Provider-specific UI |
| `TestConnectionStep.swift` | Connection test logic |

---

## Quality Standards

### Must Do

- [ ] Run `./scripts/worker-qa.sh` before marking done
- [ ] Test with **Release** build (stricter checks)
- [ ] Update all `switch` statements when adding enum cases
- [ ] Follow conventional commit format

### Must Avoid

- [ ] `@Previewable` - Use `PreviewProvider` instead
- [ ] Force unwraps (`!`) - Use `guard let` or `if let`
- [ ] Capturing `self` in Timer/Task closures - Use `strongSelf` pattern
- [ ] Hardcoded secrets - Use environment variables

### Code Pattern (Timer + Task)

```swift
// WRONG - Will fail in Release build
timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
    Task { await self?.doSomething() }
}

// CORRECT
timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
    guard let strongSelf = self else { return }
    Task { await strongSelf.doSomething() }
}
```

---

## Task Workflow

### For Dev Tasks

```
1. Read task assignment in STATUS.md
2. Check TYPE_INVENTORY.md for existing types
3. Implement the feature
4. Run ./scripts/worker-qa.sh
5. Run ./scripts/preflight.sh --dev
6. Update output file: .claude-team/outputs/DEV{N}_COMPLETE.md
7. Commit with conventional format
```

### For Architecture Studies

```
1. Read task assignment in STATUS.md
2. Check CloudProviderType.swift for existing provider
3. Check RcloneManager.swift for setup function
4. Research the provider's rclone backend
5. Document findings in output file
6. Run ./scripts/validate-output.sh on your output
7. Run ./scripts/preflight.sh --arch
```

---

## Output File Templates

### Dev Task Output

```markdown
# Task Complete: [Task Name]

**Worker:** DEV-{N}
**Date:** YYYY-MM-DD
**Status:** Complete

## What Was Done
- [Bullet points of changes]

## Files Changed
- `path/to/file.swift` - [what changed]

## How to Test
1. [Step-by-step testing instructions]

## Known Limitations
- [Any caveats or future work needed]
```

### Architecture Study Output

```markdown
# Integration Study #{N}: [Provider Name]

**Architect:** ARCH-{N}
**Date:** YYYY-MM-DD
**Status:** Complete

## Executive Summary
[2-3 sentences about the provider and integration status]

## Current Implementation Status
[What's already in CloudSyncApp]

## rclone Backend Analysis
[Authentication methods, parameters, edge cases]

## Recommendations
[What to implement next]

## Implementation Checklist
- [ ] Task 1
- [ ] Task 2
```

---

## Scripts Reference

| Script | Purpose | When to Use |
|--------|---------|-------------|
| `./scripts/restore-context.sh` | Load project context | Start of session |
| `./scripts/worker-qa.sh` | Build + test validation | Before marking done |
| `./scripts/preflight.sh` | Interactive checklist | Before marking done |
| `./scripts/validate-output.sh` | Validate output file | For arch studies |
| `./scripts/check-dod.sh` | Definition of Done | Final verification |
| `./scripts/dashboard.sh` | Project health | Check progress |

---

## Getting Help

### Documentation

- `.claude-team/COMMON_MISTAKES.md` - Avoid repeat errors
- `docs/RUNBOOK.md` - Step-by-step guides
- `templates/project-ops-kit/` - All templates

### If You're Stuck

1. Check `COMMON_MISTAKES.md` for known issues
2. Search codebase for similar implementations
3. Run `./scripts/dashboard.sh` to see project state
4. Check recent commits for patterns: `git log --oneline -20`

---

## Checklist Before Marking Done

```
[ ] ./scripts/worker-qa.sh passes
[ ] ./scripts/preflight.sh passes
[ ] Output file is complete and validated
[ ] Commit message follows conventional format
[ ] No @Previewable usage
[ ] No force unwraps in new code
[ ] All switch statements updated
```

---

*Welcome to the team. Build quality software.*
