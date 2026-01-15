# TICKET: Onboarding Visual Consistency Fix

**Type:** Bug Fix / UI Polish
**Priority:** High
**Size:** M (Medium)
**Assigned To:** Dev-1
**Status:** Ready

---

## Problem

The onboarding flow has visual inconsistency between views:
- **CompletionStepView** looks vibrant with bright green checkmark, high contrast, and confetti
- **WelcomeStepView, AddProviderStepView, FirstSyncStepView** look darker and less vibrant

Screenshots show:
1. Completion view - bright, engaging
2. Steps 1-3 - cards barely visible, text low contrast, icons don't stand out

## Root Cause

In `AppTheme.swift`:
- `cardBackgroundDark = Color.white.opacity(0.08)` — too subtle
- `textOnDarkSecondary = Color.white.opacity(0.7)` — low contrast
- `textOnDarkTertiary = Color.white.opacity(0.6)` — low contrast
- `cardBorderDark = Color.white.opacity(0.1)` — barely visible

Individual views use these low-opacity values without additional visual enhancement.

## Solution

### 1. Update AppTheme.swift

```swift
// Card Styling - BEFORE
static let cardBackgroundDark = Color.white.opacity(0.08)
static let cardBackgroundDarkHover = Color.white.opacity(0.12)
static let cardBorderDark = Color.white.opacity(0.1)

// Card Styling - AFTER
static let cardBackgroundDark = Color.white.opacity(0.12)
static let cardBackgroundDarkHover = Color.white.opacity(0.16)
static let cardBorderDark = Color.white.opacity(0.15)

// Text Colors - BEFORE
static let textOnDarkSecondary = Color.white.opacity(0.7)
static let textOnDarkTertiary = Color.white.opacity(0.6)

// Text Colors - AFTER
static let textOnDarkSecondary = Color.white.opacity(0.8)
static let textOnDarkTertiary = Color.white.opacity(0.7)
```

### 2. Update WelcomeStepView.swift - FeatureCard

Add subtle shadow/glow to icon container:
```swift
// Icon container in FeatureCard - add shadow
Circle()
    .fill(Color.white.opacity(0.1))
    .frame(width: 56, height: 56)
    .shadow(color: Color(hex: "8B5CF6").opacity(0.3), radius: 8, y: 4) // ADD THIS
```

### 3. Update AddProviderStepView.swift - OnboardingProviderCard

Add subtle brand color glow when hovered or selected:
```swift
// Add shadow to icon ZStack
.shadow(color: isSelected ? provider.brandColor.opacity(0.4) : AppTheme.primaryPurple.opacity(0.2), radius: 8, y: 4)
```

### 4. Update FirstSyncStepView.swift - SyncConceptCard

Add icon glow similar to CompletionStepView:
```swift
// Icon container - add shadow
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

- [ ] All onboarding views have consistent visual vibrancy
- [ ] Cards are clearly visible against the dark gradient background
- [ ] Text has sufficient contrast for readability
- [ ] Icons have subtle glows that match the CompletionStepView style
- [ ] Hover states are clearly visible
- [ ] Build succeeds without warnings
- [ ] App launches and onboarding flow works correctly
- [ ] Visual comparison with CompletionStepView shows consistency

## Testing

1. Build and launch app
2. Reset onboarding (if needed) via Settings
3. Go through all 4 steps of onboarding
4. Verify each screen has similar visual vibrancy to CompletionStepView
5. Test hover states on cards
6. Test selection states

## Notes

- Keep changes minimal and focused on opacity/shadow values
- Don't change layout or structure
- Match the "glow" aesthetic of CompletionStepView
- Use /think for implementation planning
