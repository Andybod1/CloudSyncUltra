# Dev-1 Task: App Icon & UI Review

**Sprint:** Launch Ready (v2.0.21)
**Created:** 2026-01-15
**Worker:** Dev-1 (UI)
**Model:** Opus (use /think for design decisions)
**Issues:** #77, #44

---

## Context

CloudSync Ultra is preparing for App Store submission. The app icon is a **hard blocker** - without it we cannot submit. Additionally, UI needs polish pass for professional appearance.

---

## Your Files (Exclusive Ownership)

```
CloudSyncApp/Assets.xcassets/AppIcon.appiconset/
CloudSyncApp/Views/
CloudSyncApp/ViewModels/
CloudSyncApp/Components/
```

---

## Objectives

### Issue #77: App Icon Set (P0 BLOCKER)

**Required Sizes:**
- 16x16, 32x32 (16@2x)
- 32x32, 64x64 (32@2x)
- 128x128, 256x256 (128@2x)
- 256x256, 512x512 (256@2x)
- 512x512, 1024x1024 (512@2x)

**Design Direction (from Brand Report):**
- Central cloud shape for cloud storage
- Connecting nodes/lines for multi-provider sync
- Gradient: Ultra Indigo (#6366F1) → Ultra Violet (#8B5CF6)
- Subtle glow effect for premium feel
- No text (scale-independent)

**Approach:**
1. Create 1024x1024 master icon (PNG or SVG)
2. Export all required sizes
3. Update Contents.json in AppIcon.appiconset
4. Verify in Xcode preview

**Reference:** `.claude-team/outputs/BRAND_DESIGNER_COMPLETE.md`

### Issue #44: UI Review

**Focus Areas:**
1. Consistency check across all views
2. AppTheme compliance
3. Spacing/alignment issues
4. Dark mode appearance
5. Accessibility (contrast ratios)

**Key Views to Review:**
- MainWindow / ContentView
- FileBrowserView
- SettingsView
- Onboarding flow (recently fixed)
- Transfer progress views

---

## Deliverables

1. [ ] App icon set (all sizes) in Assets.xcassets
2. [ ] UI issues identified and fixed
3. [ ] Tests pass
4. [ ] Commit with descriptive message

---

## Commands

```bash
# Build & test
cd ~/Claude && xcodebuild build 2>&1 | tail -5

# Launch app
open ~/Library/Developer/Xcode/DerivedData/CloudSyncApp-*/Build/Products/Debug/CloudSyncApp.app

# Run tests
xcodebuild test -destination 'platform=macOS' 2>&1 | grep "Executed"
```

---

*Report completion to Strategic Partner when done*
