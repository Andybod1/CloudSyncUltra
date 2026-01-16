# Task: Sprint v2.0.31 - Polish & Accessibility

## Worker: Dev-1 (UI)
## Issues: #121, #114, #115
## Total Size: S + M + M

---

## Pre-Flight Checklist

```bash
# Verify ownership - all files in Views/
ls CloudSyncApp/Views/
```

---

## Task 1: Encryption for All Users (#121)

### Priority: HIGH
### Size: S (~30 min)

### Problem
Encryption is currently paywalled behind Pro. Make it available to all users.

### Files to Modify
- `CloudSyncApp/Views/FileBrowserView.swift` - Remove paywall trigger
- `CloudSyncApp/Views/SettingsView.swift` - Remove Pro badge if present

### Implementation
1. Search for `showEncryptionPaywall` or `PaywallView` references
2. Remove conditional checks that gate encryption behind Pro
3. Encryption toggle should work for all users

### Verification
```bash
# Build check
xcodebuild build -scheme CloudSyncApp 2>&1 | tail -5

# Search for remaining paywall references
grep -r "Paywall\|paywall" CloudSyncApp/Views/
```

### Definition of Done
- [ ] Encryption toggle works without Pro
- [ ] No paywall shown for encryption
- [ ] Build passes

---

## Task 2: Schedule Creation Wizard (#114)

### Priority: MEDIUM
### Size: M (~2 hrs)

### Problem
Users need a guided flow to create sync schedules.

### Files to Create (in `CloudSyncApp/Views/Wizards/`)
1. `ScheduleWizard/ScheduleWizardView.swift` - Main wizard
2. `ScheduleWizard/Steps/SelectRemotesStep.swift` - Choose source/dest
3. `ScheduleWizard/Steps/ConfigureScheduleStep.swift` - Frequency, time
4. `ScheduleWizard/Steps/ReviewStep.swift` - Confirm and create

### Files to Modify
- `CloudSyncApp/Views/SchedulesView.swift` - Add "Create Schedule (Wizard)" button

### Implementation Strategy
1. Reuse existing `WizardView` and `WizardProgressView` components
2. Steps:
   - Step 1: Select source and destination remotes
   - Step 2: Configure schedule (frequency, time, options)
   - Step 3: Review and confirm
3. On completion, create schedule using existing schedule manager

### Reference Code
```bash
# Existing wizard infrastructure
cat CloudSyncApp/Views/Wizards/WizardView.swift
cat CloudSyncApp/Views/Wizards/ProviderConnectionWizard/ProviderConnectionWizardView.swift

# Existing schedule UI
cat CloudSyncApp/Views/SchedulesView.swift
```

### Definition of Done
- [ ] 3-step wizard implemented
- [ ] Reuses WizardView infrastructure
- [ ] Creates schedule on completion
- [ ] Accessible from SchedulesView
- [ ] Build passes

---

## Task 3: Transfer Setup Wizard (#115)

### Priority: LOW
### Size: M (~2 hrs)

### Problem
Users need a guided flow to set up one-time transfers.

### Files to Create (in `CloudSyncApp/Views/Wizards/`)
1. `TransferWizard/TransferWizardView.swift` - Main wizard
2. `TransferWizard/Steps/SelectSourceStep.swift` - Choose source
3. `TransferWizard/Steps/SelectDestinationStep.swift` - Choose destination
4. `TransferWizard/Steps/ConfigureOptionsStep.swift` - Transfer options
5. `TransferWizard/Steps/ConfirmStep.swift` - Review and start

### Files to Modify
- `CloudSyncApp/Views/TransferView.swift` - Add "Setup Wizard" button

### Implementation Strategy
1. Reuse existing `WizardView` and `WizardProgressView` components
2. Steps:
   - Step 1: Select source remote and folder
   - Step 2: Select destination remote and folder
   - Step 3: Configure options (sync mode, filters)
   - Step 4: Review and start transfer
3. On completion, initiate transfer using existing transfer logic

### Reference Code
```bash
# Existing transfer UI
cat CloudSyncApp/Views/TransferView.swift

# Existing wizard patterns
ls CloudSyncApp/Views/Wizards/ProviderConnectionWizard/
```

### Definition of Done
- [ ] 4-step wizard implemented
- [ ] Reuses WizardView infrastructure
- [ ] Initiates transfer on completion
- [ ] Accessible from TransferView
- [ ] Build passes

---

## Execution Order

1. **#121** first - quick win, high priority
2. **#114** second - schedule wizard
3. **#115** third - transfer wizard

---

## Verification Commands

```bash
# Build check
xcodebuild build -scheme CloudSyncApp 2>&1 | tail -10

# Full QA check
./scripts/worker-qa.sh

# List wizard files
ls -la CloudSyncApp/Views/Wizards/
```

---

## Progress Updates

```markdown
## Progress - [TIME]
**Status:** ⏳ Not started
**Working on:** -
**Completed:** -
**Blockers:** None
```

---

*Sprint v2.0.31 - Polish & Accessibility*
