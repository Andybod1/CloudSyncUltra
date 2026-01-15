# TASK_DEV1.md - Onboarding Visual Consistency

**Worker:** Dev-1 (UI Layer)
**Status:** 🟢 COMPLETED
**Priority:** High
**Size:** M (Medium - ~1 hour)
**Issue:** Onboarding visual inconsistency

---

## Objective

Fix visual inconsistency in onboarding flow where CompletionStepView looks vibrant while WelcomeStepView, AddProviderStepView, and FirstSyncStepView appear darker and less engaging.

## Problem

Screenshots show:
- CompletionStepView: Bright green checkmark, high contrast, confetti - looks great
- Steps 1-3: Cards barely visible, text low contrast, icons don't stand out

Root cause in AppTheme.swift:
- `cardBackgroundDark = Color.white.opacity(0.08)` — too subtle
- `textOnDarkSecondary = Color.white.opacity(0.7)` — low contrast
- `textOnDarkTertiary = Color.white.opacity(0.6)` — low contrast

## Solution

### 1. Update AppTheme.swift (lines ~67-77)

**Card Styling changes:**
```swift
// CHANGE FROM:
static let cardBackgroundDark = Color.white.opacity(0.08)
static let cardBackgroundDarkHover = Color.white.opacity(0.12)
static let cardBorderDark = Color.white.opacity(0.1)

// CHANGE TO:
static let cardBackgroundDark = Color.white.opacity(0.12)
static let cardBackgroundDarkHover = Color.white.opacity(0.18)
static let cardBorderDark = Color.white.opacity(0.15)
```

**Text Color changes:**
```swift
// CHANGE FROM:
static let textOnDarkSecondary = Color.white.opacity(0.7)
static let textOnDarkTertiary = Color.white.opacity(0.6)

// CHANGE TO:
static let textOnDarkSecondary = Color.white.opacity(0.8)
static let textOnDarkTertiary = Color.white.opacity(0.7)
```

### 2. Update WelcomeStepView.swift - FeatureCard struct

In the `FeatureCard` body, add shadow to the icon Circle:
```swift
// Icon - ADD shadow
ZStack {
    Circle()
        .fill(Color.white.opacity(0.1))
        .frame(width: 56, height: 56)
        .shadow(color: Color(hex: "8B5CF6").opacity(0.3), radius: 8, y: 4) // ADD THIS LINE
```

### 3. Update AddProviderStepView.swift - OnboardingProviderCard struct

In the card background, add shadow:
```swift
// After the icon ZStack, add shadow modifier to the parent ZStack:
ZStack {
    Circle()
        .fill(isSelected ? provider.brandColor.opacity(0.3) : Color.white.opacity(0.1))
        .frame(width: AppTheme.iconContainerMedium, height: AppTheme.iconContainerMedium)
        .shadow(color: isSelected ? provider.brandColor.opacity(0.4) : AppTheme.primaryPurple.opacity(0.2), radius: 8, y: 4) // ADD THIS
```

### 4. Update FirstSyncStepView.swift - SyncConceptCard struct

In the icon Circle:
```swift
Circle()
    .fill(isSelected ? concept.color.opacity(0.3) : Color.white.opacity(0.1))
    .frame(width: AppTheme.iconContainerMedium, height: AppTheme.iconContainerMedium)
    .shadow(color: isSelected ? concept.color.opacity(0.4) : AppTheme.primaryPurple.opacity(0.2), radius: 8, y: 4) // ADD THIS
```

## Files to Modify

1. `/Users/antti/Claude/CloudSyncApp/Styles/AppTheme.swift`
2. `/Users/antti/Claude/CloudSyncApp/Views/Onboarding/WelcomeStepView.swift`
3. `/Users/antti/Claude/CloudSyncApp/Views/Onboarding/AddProviderStepView.swift`
4. `/Users/antti/Claude/CloudSyncApp/Views/Onboarding/FirstSyncStepView.swift`

## Acceptance Criteria

- [x] All 4 onboarding views have consistent visual vibrancy
- [x] Cards clearly visible against dark gradient background
- [x] Text has sufficient contrast for readability
- [x] Icons have subtle glows matching CompletionStepView style
- [x] Build succeeds without warnings
- [x] App launches successfully
- [x] All onboarding tests pass (2 pre-existing unrelated failures)

## Testing

```bash
# Build
cd /Users/antti/Claude
xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -configuration Debug build 2>&1 | head -50

# Run onboarding tests
xcodebuild test -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -only-testing:CloudSyncAppTests/OnboardingViewModelTests 2>&1 | tail -20

# Launch app for visual verification
open /Users/antti/Library/Developer/Xcode/DerivedData/CloudSyncApp-*/Build/Products/Debug/CloudSyncApp.app
```

## Completion Protocol

1. Make edits to all 4 files
2. Build and verify no errors
3. Run tests
4. Launch app and verify visually
5. Commit with message: `fix(ui): Improve onboarding visual consistency`
6. Report completion in TASK_DEV1.md

---

## Completion Report

**Completed:** 2026-01-15
**Worker:** Dev-1

### Changes Made

1. **AppTheme.swift** - Updated card and text opacity values:
   - `cardBackgroundDark`: 0.08 → 0.12
   - `cardBackgroundDarkHover`: 0.12 → 0.18
   - `cardBorderDark`: 0.10 → 0.15
   - `textOnDarkSecondary`: 0.70 → 0.80
   - `textOnDarkTertiary`: 0.60 → 0.70

2. **WelcomeStepView.swift** - Added purple glow shadow to FeatureCard icon circles

3. **AddProviderStepView.swift** - Added dynamic glow shadow to OnboardingProviderCard icons (uses provider brand color when selected)

4. **FirstSyncStepView.swift** - Added dynamic glow shadow to SyncConceptCard icons (uses concept color when selected)

### Test Results
- Build: ✅ SUCCESS
- Onboarding tests: 41 passed, 2 pre-existing failures (unrelated to visual changes)

### Visual Impact
- Cards now more visible against dark gradient background
- Text contrast improved for better readability
- Icons have subtle glows matching CompletionStepView style
- All 4 onboarding steps now have consistent visual vibrancy
