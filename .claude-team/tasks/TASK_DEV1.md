# Dev-1 Task: Onboarding Flow Implementation

**Created:** 2026-01-14 22:20
**Worker:** Dev-1 (UI)
**Model:** Opus with /think for complex decisions
**Issues:** #80, #81, #82

---

## Context

CloudSync Ultra needs a first-time user onboarding experience for App Store launch. Users should understand the app's value and successfully connect their first cloud provider.

---

## Your Files (Exclusive Ownership)

```
CloudSyncApp/Views/         # All view files
CloudSyncApp/ViewModels/    # All view model files
CloudSyncApp/Views/Onboarding/  # CREATE THIS
```

---

## Objectives

### Issue #80: Onboarding Infrastructure + Welcome Screen

1. **Create Onboarding Infrastructure**
   ```swift
   // CloudSyncApp/Views/Onboarding/OnboardingView.swift
   // CloudSyncApp/ViewModels/OnboardingViewModel.swift
   ```
   
2. **OnboardingViewModel** should track:
   - `currentStep: Int` (0, 1, 2, 3)
   - `hasCompletedOnboarding: Bool` (persisted in UserDefaults)
   - `canSkip: Bool`

3. **Welcome Screen (Step 0)**
   - App logo/icon
   - "Welcome to CloudSync Ultra"
   - 3-4 key benefits with icons:
     - 🔄 "Sync across 42+ cloud providers"
     - 🔒 "Your files, encrypted your way"
     - ⚡ "Fast, parallel transfers"
   - "Get Started" button
   - "Skip" link (small, subtle)

### Issue #81: Guide to Add First Provider (Step 1)

1. **Provider Selection Screen**
   - "Connect Your First Cloud" heading
   - Grid of popular providers (Google Drive, Dropbox, OneDrive, iCloud, Proton Drive)
   - "Show All Providers" expansion
   - Visual indication of OAuth vs manual config

2. **Connection Flow**
   - Guide user through OAuth or config
   - Show success animation on completion
   - "Continue" to next step

### Issue #82: Guide to First Sync (Step 2)

1. **First Sync Walkthrough**
   - "Let's sync some files!" heading
   - Simple explanation of sync vs copy
   - Show the dual-pane interface briefly
   - Suggest a small test sync

2. **Completion Screen (Step 3)**
   - 🎉 Celebration animation
   - "You're all set!"
   - Quick tips for power users
   - "Open Dashboard" button

---

## Design Guidelines

- Use `AppTheme` for all styling (colors, spacing, fonts)
- Follow existing app visual language
- Smooth transitions between steps (slide or fade)
- Progress indicator showing current step
- Allow going back to previous steps
- Responsive to window size

---

## Integration Points

```swift
// In CloudSyncApp.swift or MainView.swift
// Check if onboarding needed on launch:
if !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
    // Show OnboardingView
}
```

---

## Deliverables

1. **New Files:**
   - `CloudSyncApp/Views/Onboarding/OnboardingView.swift`
   - `CloudSyncApp/Views/Onboarding/WelcomeStepView.swift`
   - `CloudSyncApp/Views/Onboarding/AddProviderStepView.swift`
   - `CloudSyncApp/Views/Onboarding/FirstSyncStepView.swift`
   - `CloudSyncApp/Views/Onboarding/CompletionStepView.swift`
   - `CloudSyncApp/ViewModels/OnboardingViewModel.swift`

2. **Modified Files:**
   - `CloudSyncApp/CloudSyncApp.swift` - Add onboarding check

3. **Tests:**
   - `CloudSyncAppTests/OnboardingViewModelTests.swift`

4. **Git Commit:**
   ```
   feat(ui): Add first-time user onboarding flow
   
   - Welcome screen with app benefits (#80)
   - Guided provider connection (#81)
   - First sync walkthrough (#82)
   - Progress tracking with skip option
   
   Implements #80, #81, #82
   ```

---

## Notes

- Use /think for complex state management decisions
- Keep each step focused and not overwhelming
- Test with fresh UserDefaults to simulate new user
- Consider accessibility (VoiceOver support)
