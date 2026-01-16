# Task: Custom Performance Profile Shows No Options (#103)

## Worker: Dev-2
## Priority: HIGH
## Size: M (1-2 hrs)

---

## Issue

When selecting "Custom" in the Performance Profile picker, the UI shows only "Manually configured settings." with no way to configure those settings.

## Root Cause

In `PerformanceSettingsView.swift`:
1. The Advanced Settings are in a collapsed `DisclosureGroup` (line 70)
2. When "Custom" is selected, this group stays collapsed
3. User has no indication they need to expand it

## Files to Modify

- `CloudSyncApp/Views/PerformanceSettingsView.swift`

## Solution

When "Custom" profile is selected, auto-expand the Advanced Settings section.

### Implementation

1. In the `onChange` handler for `selectedProfile` (line 40-44), add logic to expand when Custom:

```swift
.onChange(of: selectedProfile) { _, newProfile in
    if newProfile != .custom {
        applyProfile(newProfile)
    }
    // Auto-expand advanced settings when Custom is selected
    if newProfile == .custom {
        withAnimation {
            showAdvanced = true
        }
    }
}
```

2. Optionally: Update the description for Custom to hint at the advanced settings:
```swift
case .custom:
    return "Configure settings below. Expand Advanced Settings to customize."
```

3. Consider: When Custom is selected, show the advanced settings **inline** (not in DisclosureGroup) for better UX.

### Better UX Option (if time permits)

Move the advanced settings outside the DisclosureGroup when Custom is selected:

```swift
// Show inline when Custom, in disclosure otherwise
if selectedProfile == .custom {
    customSettingsView  // Show settings directly
} else {
    DisclosureGroup("Advanced Settings", isExpanded: $showAdvanced) {
        customSettingsView
    }
}
```

## Verification Steps

1. Build passes
2. Open Settings → Performance
3. Select "Custom" profile
4. **Expected**: Advanced Settings expands automatically showing sliders
5. Adjust a slider
6. **Expected**: Values update, profile stays on "Custom"

## Constraints

- DO NOT create new types - use existing PerformanceProfile, PerformanceSettings
- Keep the existing AppStorage bindings
- Run `./scripts/worker-qa.sh` before marking complete

## Existing Types (from TYPE_INVENTORY.md)

```swift
enum PerformanceProfile: String, CaseIterable
enum CPUPriority: String, CaseIterable, Codable
enum CheckFrequency: String, CaseIterable, Codable
struct PerformanceSettings: Codable, Equatable
```
