# Sprint v2.0.22 Plan - "Polish & Performance"

> **Date:** 2026-01-15
> **Focus:** UI Polish, Performance Optimization, Launch Preparation
> **Status:** IN PROGRESS

---

## Completed ✅

### Dev-1: Onboarding Visual Consistency
- ✅ Updated AppTheme.swift opacity values
- ✅ Added icon glow shadows to WelcomeStepView
- ✅ Added dynamic shadows to AddProviderStepView
- ✅ Added dynamic shadows to FirstSyncStepView
- ✅ Committed: `f5cf239 fix(ui): Improve onboarding visual consistency`

---

## Remaining Tasks

### 🔵 Dev-1 (Available) - #49 Quick Actions Menu (M)
**Task:** Add Cmd+Shift+N quick actions popup
- Quick access to common operations (new sync, new task, settings)
- Keyboard shortcut support
- Modern popup design matching app style

### 🔵 Dev-2 (Ready) - #73 Provider-Specific Chunk Sizes (M)
**Task:** Optimize chunk sizes per provider type
- Google Drive: 8MB chunks
- S3/B2: 16MB chunks  
- Local: 64MB chunks
- Proton: 4MB chunks

### 🔵 Dev-3 (Ready) - #55 Transfer Preview (M)
**Task:** Add transfer preview before sync
- Dry-run capability using rclone --dry-run
- TransferPreview model
- Show what will be transferred/deleted/modified

### 🔵 QA (Ready) - Test Plans
**Task:** Create tests for new features
- Chunk size tests
- Transfer preview tests
- Coverage gap analysis

### 🔵 Dev-Ops (Ready) - #78 App Store Prep (M)
**Task:** Prepare App Store documentation
- Screenshot scenarios
- Metadata documentation
- Asset checklist

---

## Recommended Launch Order

| Order | Worker | Task | Dependencies |
|-------|--------|------|--------------|
| 1 | Dev-2 | Chunk Sizes | None |
| 2 | Dev-3 | Transfer Preview | None |
| 3 | QA | Test Plans | Can start now, finalize after Dev-2/Dev-3 |
| 4 | Dev-1 | Quick Actions | None |
| 5 | Dev-Ops | App Store Prep | None |

**Parallel execution possible:** Dev-2, Dev-3, Dev-Ops can run simultaneously (no file conflicts)

---

## Sprint Progress

```
[██████░░░░░░░░░░░░░░] 25% Complete

✅ Onboarding Visual Fix (Dev-1)
⬜ Chunk Sizes (Dev-2)
⬜ Transfer Preview (Dev-3)
⬜ Test Plans (QA)
⬜ App Store Prep (Dev-Ops)
```

---

## Post-Sprint Checklist

- [ ] Update VERSION.txt to 2.0.22
- [ ] Update CHANGELOG.md with all changes
- [ ] Update CLAUDE_PROJECT_KNOWLEDGE.md
- [ ] Commit all changes
- [ ] Push to GitHub
- [ ] Archive completed task files
- [ ] Run full test suite

---

*Updated: 2026-01-15 12:15 UTC*
