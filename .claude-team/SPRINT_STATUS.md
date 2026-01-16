# Sprint: v2.0.32 - Interactive Onboarding + Windows Research

**Started:** 2026-01-16
**Status:** 📋 PLANNED

---

## Sprint Goal

1. Make onboarding interactive by integrating existing wizards
2. Research Windows port feasibility and approaches

---

## Worker Assignments

| Worker | Issue | Task |
|--------|-------|------|
| **Dev-1** | #83 | Interactive Onboarding implementation |
| **Architect** | #65 | Windows port research & recommendations |

---

## Sprint Backlog

| # | Title | Worker | Size | Status |
|---|-------|--------|------|--------|
| 83 | Interactive Onboarding | Dev-1 | M | ⏳ Pending |
| 65 | Windows Port Research | Architect | M | ⏳ Pending |

**Total Effort:** ~4-5 hours

---

## #83: Interactive Onboarding (Dev-1)

### Tasks
1. Add "Connect Now" button to `AddProviderStepView`
   - Launch `ProviderConnectionWizardView` as sheet
   - Update step completion on wizard success
2. Add "Try Sync" button to `FirstSyncStepView`
   - Launch `TransferWizardView` as sheet
   - Show success feedback on completion
3. Update `OnboardingViewModel` for state tracking
4. Polish & test end-to-end

### Files to Modify
- `AddProviderStepView.swift`
- `FirstSyncStepView.swift`
- `OnboardingViewModel.swift`

### Definition of Done
- [ ] "Connect Now" button launches provider wizard
- [ ] "Try Sync" button launches transfer wizard
- [ ] Wizard completion updates onboarding state
- [ ] User can skip interactive parts
- [ ] Build passes

---

## #65: Windows Port Research (Architect)

### Research Questions
1. What are the viable approaches for Windows support?
   - Kotlin Multiplatform, Flutter, Electron/Tauri, .NET MAUI, separate codebase
2. How much code can be shared vs rewritten?
3. What's the effort estimate for each approach?
4. Which approach best fits CloudSync Ultra's architecture?
5. What are the dependencies? (rclone works on Windows)

### Deliverable
Research report in `.claude-team/outputs/ARCHITECT_COMPLETE.md`:
- Approach comparison matrix
- Recommended path forward
- Effort estimates
- Risks and trade-offs

### Definition of Done
- [ ] All approaches evaluated
- [ ] Pros/cons documented
- [ ] Recommendation with rationale
- [ ] Effort estimate provided

---

## Launch Commands

```bash
# Dev-1: Interactive Onboarding
.claude-team/scripts/launch_single_worker.sh dev-1 opus

# Architect: Windows Research
.claude-team/scripts/launch_single_worker.sh architect opus
```

---

## Previous Sprint

**v2.0.31** - Completed 2026-01-16
- ✅ #113, #114, #115: All three wizards
- ✅ #116-120: Security enhancements
- ✅ #121: Encryption for all
- ✅ #97: Feedback manager

---

*Last Updated: 2026-01-16*
