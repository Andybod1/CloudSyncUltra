# Task: Interactive Onboarding (#83)

**Worker:** Dev-1 (UI)
**Sprint:** v2.0.32
**Issue:** #83

---

## Objective

Make onboarding interactive by integrating existing wizards into the onboarding flow.

---

## Tasks

### 1. Add "Connect Now" to AddProviderStepView
- Add a prominent "Connect a Provider Now" button
- Launch `ProviderConnectionWizardView` as a sheet when tapped
- Update onboarding state when wizard completes successfully
- Keep existing guide content visible (user can read OR connect)

### 2. Add "Try Sync" to FirstSyncStepView
- Add "Try a Sync Now" button
- Launch `TransferWizardView` as a sheet when tapped
- Show success feedback when transfer completes
- Keep existing tutorial content as context

### 3. Update OnboardingViewModel
- Add state tracking for interactive completions:
  - `hasConnectedProvider: Bool`
  - `hasCompletedFirstSync: Bool`
- Persist these states
- Allow proceeding without completing interactive steps

### 4. Polish & Test
- Ensure smooth sheet presentation/dismissal
- Handle wizard cancellation gracefully
- Test full onboarding flow end-to-end

---

## Files to Modify

| File | Changes |
|------|---------|
| `CloudSyncApp/Views/Onboarding/AddProviderStepView.swift` | Add Connect Now button + sheet |
| `CloudSyncApp/Views/Onboarding/FirstSyncStepView.swift` | Add Try Sync button + sheet |
| `CloudSyncApp/ViewModels/OnboardingViewModel.swift` | Add state tracking |

---

## Reference: Existing Wizards

```swift
// Provider wizard - already built
ProviderConnectionWizardView()
    .environmentObject(remotesVM)

// Transfer wizard - already built
TransferWizardView()
```

---

## Definition of Done

- [ ] "Connect Now" button in AddProviderStepView launches wizard
- [ ] "Try Sync" button in FirstSyncStepView launches transfer wizard
- [ ] Wizard completion updates onboarding state
- [ ] User can skip interactive parts and proceed
- [ ] Build passes
- [ ] Write completion report to `.claude-team/outputs/DEV1_COMPLETE.md`

---

## QA Checklist

```bash
# Run before marking complete
xcodebuild -scheme CloudSyncApp build 2>&1 | tail -5
```

- [ ] No build errors
- [ ] No new warnings
- [ ] Tested onboarding flow manually
