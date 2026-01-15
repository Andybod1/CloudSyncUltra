# CloudSync Ultra - App Store Submission Checklist

Comprehensive pre-submission checklist for Mac App Store release.

**Version:** 1.0
**Last Updated:** January 2026
**App Version:** 2.0.x

---

## Overview

This checklist ensures all requirements are met before submitting CloudSync Ultra to the Mac App Store. Work through each section systematically, checking off items as completed.

**Legend:**
- [ ] Not started
- [x] Completed
- N/A - Not applicable

---

## 1. Apple Developer Account

### Account Status

- [ ] Apple Developer Program membership active ($99/year)
- [ ] Developer account in good standing
- [ ] Team ID confirmed and documented
- [ ] Required agreements accepted in App Store Connect

### Team Members (If Applicable)

- [ ] All team members have appropriate access levels
- [ ] Finance role assigned for payment setup
- [ ] Admin role confirmed for app management

---

## 2. App Icon Assets

### Required Icon Sizes

All icons must be PNG, no alpha channel, no rounded corners.

| Size | Resolution | Purpose | Status |
|------|------------|---------|--------|
| 16x16 | @1x | Finder, Dock (small) | [ ] |
| 32x32 | @1x | Finder, Dock | [ ] |
| 64x64 | @1x | Finder | [ ] |
| 128x128 | @1x | Finder, Dock | [ ] |
| 256x256 | @1x | Finder | [ ] |
| 512x512 | @1x | Finder | [ ] |
| 1024x1024 | @1x | App Store | [ ] |

### Icon Quality Checks

- [ ] Icon clearly represents app functionality
- [ ] Icon is visually distinct and recognizable
- [ ] Icon looks good at all sizes
- [ ] No Apple trademarks or UI elements
- [ ] No transparency (alpha channel removed)
- [ ] Corners are square (Apple adds rounding)
- [ ] Follows macOS Big Sur+ design language

---

## 3. Screenshots

### Required Screenshot Sizes

Minimum 3, maximum 10 screenshots per size.

| Size | Display | Status |
|------|---------|--------|
| 1280 x 800 | MacBook 13" | [ ] |
| 1440 x 900 | MacBook Air | [ ] |
| 2560 x 1600 | MacBook Pro 13" Retina | [ ] |
| 2880 x 1800 | MacBook Pro 15" Retina | [ ] |

### Screenshot Content

Reference: `docs/APP_STORE_SCREENSHOTS.md`

- [ ] 01. Dashboard View captured
- [ ] 02. File Browser captured
- [ ] 03. Transfer in Progress captured
- [ ] 04. Provider Selection captured
- [ ] 05. Encryption Setup captured
- [ ] 06. Schedule View captured
- [ ] 07. Menu Bar captured
- [ ] 08. Onboarding captured
- [ ] 09. Settings captured
- [ ] 10. Success State captured

### Screenshot Quality

- [ ] Screenshots show actual app functionality
- [ ] No placeholder or test data visible
- [ ] All text is readable
- [ ] Consistent visual style across screenshots
- [ ] No personal/sensitive information visible
- [ ] PNG format, sRGB color space

---

## 4. App Preview Video (Optional)

- [ ] Duration: 15-30 seconds
- [ ] Resolution: 1920x1080 or higher
- [ ] Shows key app workflows
- [ ] No excessive text overlays
- [ ] Uploaded to App Store Connect

---

## 5. App Store Metadata

Reference: `docs/APP_STORE_METADATA.md`

### Required Fields

- [ ] App Name (max 30 characters)
- [ ] Subtitle (max 30 characters)
- [ ] Description (max 4,000 characters)
- [ ] Keywords (max 100 characters)
- [ ] What's New text
- [ ] Primary category selected
- [ ] Secondary category selected (optional)
- [ ] Age rating configured
- [ ] Copyright text (e.g., "2026 Your Company")

### URLs

- [ ] Privacy Policy URL - accessible and valid
- [ ] Support URL - accessible and valid
- [ ] Marketing URL (optional) - accessible and valid

### Content Validation

- [ ] No competitor names in description/keywords
- [ ] No pricing claims or promises
- [ ] No references to non-App Store platforms
- [ ] No placeholder text remaining
- [ ] Grammar and spelling checked
- [ ] Character limits respected

---

## 6. Technical Requirements

### Code Signing

- [ ] Mac App Distribution certificate created
- [ ] Certificate installed in Keychain
- [ ] Provisioning profile configured
- [ ] App correctly signed (verify with `codesign -dv`)

### Hardened Runtime

- [ ] Hardened Runtime enabled in Xcode
- [ ] `ENABLE_HARDENED_RUNTIME = YES` in build settings
- [ ] All entitlements justified and documented

### App Sandbox

- [ ] App Sandbox enabled
- [ ] Minimum required entitlements only
- [ ] All entitlements documented with justification:

| Entitlement | Required | Justification |
|-------------|----------|---------------|
| `com.apple.security.network.client` | Yes | Connect to cloud services |
| `com.apple.security.files.user-selected.read-write` | Yes | Access user files |
| `com.apple.security.files.downloads.read-write` | Maybe | Access Downloads folder |

### Binary Verification

- [ ] Universal binary (Intel + Apple Silicon)
- [ ] No private API usage
- [ ] No deprecated API warnings
- [ ] No third-party framework issues
- [ ] All embedded binaries signed (including rclone)

```bash
# Verify binary architectures
lipo -info CloudSyncApp.app/Contents/MacOS/CloudSyncApp

# Verify signing
codesign --verify --deep --strict CloudSyncApp.app

# Check entitlements
codesign -d --entitlements :- CloudSyncApp.app
```

---

## 7. Build Preparation

### Version Numbers

- [ ] CFBundleShortVersionString updated (e.g., "2.0.23")
- [ ] CFBundleVersion updated (unique build number)
- [ ] Version matches CHANGELOG.md
- [ ] Build number higher than any previous submission

### Build Quality

- [ ] Release configuration used (not Debug)
- [ ] All debug logging disabled
- [ ] No test/development endpoints
- [ ] Performance optimized
- [ ] Memory usage acceptable

### Archive & Export

- [ ] Clean build completed
- [ ] Archive created successfully
- [ ] Exported with App Store method
- [ ] No export errors or warnings

---

## 8. Testing Pre-Submission

### Functional Testing

- [ ] All core features work correctly
- [ ] Cloud provider connections successful
- [ ] File transfers complete successfully
- [ ] Encryption/decryption works
- [ ] Scheduling functions properly
- [ ] Menu bar integration works

### Edge Case Testing

- [ ] App handles no internet gracefully
- [ ] Large file transfers complete
- [ ] Many files/folders handled
- [ ] App recovers from background
- [ ] Clean shutdown behavior

### Platform Testing

- [ ] Tested on Intel Mac
- [ ] Tested on Apple Silicon Mac
- [ ] Tested on minimum supported macOS version
- [ ] Tested on latest macOS version

### Crash & Stability

- [ ] No crashes in testing
- [ ] No memory leaks detected
- [ ] No excessive CPU usage
- [ ] No excessive disk usage

---

## 9. Legal & Compliance

### Privacy

- [ ] Privacy Policy published and accessible
- [ ] Privacy Policy URL added to App Store Connect
- [ ] App Privacy details completed:
  - [ ] Data types collected identified
  - [ ] Data usage purposes described
  - [ ] Third-party data sharing documented

### Third-Party Attribution

- [ ] rclone license included (MIT)
- [ ] All third-party licenses documented
- [ ] Attribution in app (Settings/About)
- [ ] No GPL-incompatible code issues

### Terms of Service

- [ ] Terms of Service drafted (if applicable)
- [ ] EULA configured in App Store Connect (optional)

### Export Compliance

- [ ] Export compliance information ready
- [ ] Encryption usage documented:
  - [ ] Uses standard encryption (HTTPS, etc.)
  - [ ] Uses non-exempt encryption: [ ] Yes [ ] No
  - [ ] If yes, export compliance documentation ready

---

## 10. App Store Connect Setup

### App Record

- [ ] App record created in App Store Connect
- [ ] Bundle ID matches Xcode project
- [ ] SKU set (unique identifier)
- [ ] Primary language set

### Pricing & Availability

- [ ] Price tier selected
- [ ] Availability by country/region configured
- [ ] Pre-order configured (if applicable)
- [ ] Release date set (manual or automatic)

### App Information

- [ ] Category selected
- [ ] Age rating configured
- [ ] Copyright text set
- [ ] Version number set

### In-App Purchases (If Applicable)

- [ ] IAPs created and configured
- [ ] IAP metadata complete
- [ ] IAP screenshots provided
- [ ] IAPs linked to app version

---

## 11. Build Upload

### Upload Preparation

- [ ] Xcode updated to latest stable version
- [ ] Connected to internet with stable connection
- [ ] App Store Connect credentials ready

### Upload Process

```bash
# Via Xcode Organizer
1. Window > Organizer
2. Select archive
3. Distribute App > App Store Connect > Upload

# Or via command line
xcodebuild -exportArchive \
  -archivePath CloudSyncApp.xcarchive \
  -exportPath ./export \
  -exportOptionsPlist ExportOptions-AppStore.plist
```

### Post-Upload Verification

- [ ] Build appears in App Store Connect
- [ ] Build processing completed
- [ ] No processing errors
- [ ] Build passed automated checks

---

## 12. Submission

### Pre-Submit Review

- [ ] All metadata fields complete
- [ ] All screenshots uploaded
- [ ] Build selected for submission
- [ ] App Preview uploaded (if applicable)
- [ ] Pricing configured
- [ ] Availability configured

### Review Notes

- [ ] App Review notes written
- [ ] Demo account provided (if needed)
- [ ] Special instructions documented
- [ ] Contact information accurate

### Submit

- [ ] "Submit for Review" clicked
- [ ] Submission confirmed in App Store Connect
- [ ] Status changed to "Waiting for Review"

---

## 13. Post-Submission

### While Waiting

- [ ] Monitor App Store Connect for status changes
- [ ] Check email for reviewer questions
- [ ] Prepare responses for common rejection reasons

### If Rejected

- [ ] Read rejection reason carefully
- [ ] Address all issues mentioned
- [ ] Update app/metadata as needed
- [ ] Resubmit with fixes
- [ ] Appeal if rejection seems incorrect

### If Approved

- [ ] Verify app live in App Store
- [ ] Test download and installation
- [ ] Announce release
- [ ] Monitor reviews and ratings
- [ ] Prepare for support requests

---

## Quick Reference Commands

```bash
# Verify code signing
codesign --verify --deep --strict CloudSyncApp.app

# Check architectures
lipo -info CloudSyncApp.app/Contents/MacOS/CloudSyncApp

# List signing identities
security find-identity -v -p codesigning

# Archive build
xcodebuild archive \
  -project CloudSyncApp.xcodeproj \
  -scheme CloudSyncApp \
  -configuration Release \
  -archivePath build/CloudSyncApp.xcarchive

# Export for App Store
xcodebuild -exportArchive \
  -archivePath build/CloudSyncApp.xcarchive \
  -exportPath build/appstore \
  -exportOptionsPlist ExportOptions-AppStore.plist
```

---

## Common Rejection Reasons & Fixes

| Rejection | Fix |
|-----------|-----|
| Guideline 2.1 - App Completeness | Ensure all features work, no placeholder content |
| Guideline 2.3 - Metadata | Fix inaccurate descriptions, misleading screenshots |
| Guideline 4.2 - Minimum Functionality | Add more substantial features |
| Guideline 5.1.1 - Data Collection | Update privacy policy, add proper disclosures |
| Sandbox Violation | Review and justify all entitlements |
| Binary Unsigned | Sign all embedded binaries (including rclone) |

---

## Timeline Summary

| Phase | Duration |
|-------|----------|
| Asset Preparation | Variable |
| Technical Setup | Variable |
| Build & Test | Variable |
| Upload & Submission | 1-2 hours |
| App Review | 24-72 hours (typically) |
| Post-Approval | Same day |

---

*CloudSync Ultra App Store Submission Checklist*
*Use this document for every App Store submission*
*January 2026*
