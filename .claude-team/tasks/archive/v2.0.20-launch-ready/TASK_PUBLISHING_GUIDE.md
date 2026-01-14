# Documentation Task: App Publishing Guide

**Issue:** #94
**Sprint:** Next Sprint
**Priority:** High
**Worker:** Tech Writer
**Model:** Opus + Extended Thinking

---

## Objective

Create a comprehensive guide explaining how to publish CloudSync Ultra as a distributable macOS application, covering both direct download and App Store paths.

## Output File

`/Users/antti/Claude/docs/PUBLISHING_GUIDE.md`

## Content Structure

### 1. Overview

```markdown
# CloudSync Ultra Publishing Guide

This guide covers how to build, sign, notarize, and distribute CloudSync Ultra.

## Distribution Options

| Method | Pros | Cons |
|--------|------|------|
| Direct Download | Full control, no review | Manual updates, trust issues |
| Mac App Store | Trust, discovery, updates | Review process, 30% cut |
| TestFlight | Beta testing | Limited to testers |
```

### 2. Prerequisites

Document required accounts and tools:
- Apple Developer Account ($99/year)
- Xcode with command line tools
- App-specific password for notarization
- Developer ID certificates

### 3. Code Signing

```markdown
## Code Signing Setup

### Create Certificates

1. Go to developer.apple.com > Certificates
2. Create:
   - "Developer ID Application" (for direct download)
   - "Mac App Distribution" (for App Store)
   - "Mac Installer Distribution" (for pkg installers)

### Configure in Xcode

1. Open CloudSyncApp.xcodeproj
2. Select target > Signing & Capabilities
3. Team: Select your Apple Developer team
4. Signing Certificate: Developer ID Application

### Verify Signing

```bash
codesign -dv --verbose=4 /path/to/CloudSyncApp.app
```
```

### 4. Building for Release

```markdown
## Build Release Version

### Archive Build

```bash
xcodebuild archive \
  -project CloudSyncApp.xcodeproj \
  -scheme CloudSyncApp \
  -archivePath build/CloudSyncApp.xcarchive
```

### Export App

```bash
xcodebuild -exportArchive \
  -archivePath build/CloudSyncApp.xcarchive \
  -exportPath build/export \
  -exportOptionsPlist ExportOptions.plist
```

### ExportOptions.plist (Direct Download)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "...">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>developer-id</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
</dict>
</plist>
```
```

### 5. Notarization (Required for Direct Download)

```markdown
## Notarization

Apple requires notarization for apps distributed outside the App Store.

### Store Credentials

```bash
xcrun notarytool store-credentials "CloudSyncUltra" \
  --apple-id "your@email.com" \
  --team-id "YOUR_TEAM_ID" \
  --password "app-specific-password"
```

### Submit for Notarization

```bash
xcrun notarytool submit build/export/CloudSyncApp.app \
  --keychain-profile "CloudSyncUltra" \
  --wait
```

### Staple Ticket

```bash
xcrun stapler staple build/export/CloudSyncApp.app
```

### Verify

```bash
spctl -a -v build/export/CloudSyncApp.app
```
```

### 6. Creating DMG

```markdown
## Create DMG Installer

### Using create-dmg

```bash
npm install -g create-dmg

create-dmg build/export/CloudSyncApp.app build/
```

### Using hdiutil (Manual)

```bash
# Create DMG
hdiutil create -volname "CloudSync Ultra" \
  -srcfolder build/export/CloudSyncApp.app \
  -ov -format UDZO \
  build/CloudSyncUltra-2.0.17.dmg

# Notarize the DMG
xcrun notarytool submit build/CloudSyncUltra-2.0.17.dmg \
  --keychain-profile "CloudSyncUltra" \
  --wait

# Staple
xcrun stapler staple build/CloudSyncUltra-2.0.17.dmg
```
```

### 7. App Store Submission

```markdown
## App Store Submission

### Prepare App Store Connect

1. Create app record at appstoreconnect.apple.com
2. Fill in metadata:
   - Name: CloudSync Ultra
   - Subtitle: Multi-Cloud File Manager
   - Category: Utilities
   - Privacy Policy URL
   - Support URL

### Required Assets

- App Icon (1024x1024)
- Screenshots (min 3):
  - 1280x800 or 1440x900
  - 2560x1600 or 2880x1800 (Retina)
- Description (up to 4000 chars)
- Keywords (up to 100 chars)
- What's New text

### Upload Build

```bash
# Export for App Store
xcodebuild -exportArchive \
  -archivePath build/CloudSyncApp.xcarchive \
  -exportPath build/appstore \
  -exportOptionsPlist ExportOptions-AppStore.plist

# Upload via Transporter or xcrun
xcrun altool --upload-app \
  -f build/appstore/CloudSyncApp.pkg \
  -u "your@email.com" \
  -p "@keychain:AC_PASSWORD"
```

### Submit for Review

1. Select build in App Store Connect
2. Answer export compliance questions
3. Submit for review
4. Wait 24-48 hours (typically)
```

### 8. Quick Reference

```markdown
## Quick Reference

### Full Release Process (Direct Download)

```bash
# 1. Increment version
# Edit CloudSyncApp.xcodeproj version

# 2. Archive
xcodebuild archive -project CloudSyncApp.xcodeproj \
  -scheme CloudSyncApp -archivePath build/CloudSyncApp.xcarchive

# 3. Export
xcodebuild -exportArchive -archivePath build/CloudSyncApp.xcarchive \
  -exportPath build/export -exportOptionsPlist ExportOptions.plist

# 4. Notarize
xcrun notarytool submit build/export/CloudSyncApp.app \
  --keychain-profile "CloudSyncUltra" --wait

# 5. Staple
xcrun stapler staple build/export/CloudSyncApp.app

# 6. Create DMG
hdiutil create -volname "CloudSync Ultra" \
  -srcfolder build/export/CloudSyncApp.app \
  -ov -format UDZO build/CloudSyncUltra-VERSION.dmg

# 7. Notarize DMG
xcrun notarytool submit build/CloudSyncUltra-VERSION.dmg \
  --keychain-profile "CloudSyncUltra" --wait
xcrun stapler staple build/CloudSyncUltra-VERSION.dmg

# 8. Upload to website/GitHub releases
```
```

## Verification

1. Guide covers both distribution methods
2. All commands are accurate and tested
3. Troubleshooting section included
4. Screenshots where helpful

## Output

Write to: `/Users/antti/Claude/docs/PUBLISHING_GUIDE.md`

Also create completion report: `/Users/antti/Claude/.claude-team/outputs/PUBLISHING_GUIDE_COMPLETE.md`

## Success Criteria

- [ ] Comprehensive guide created
- [ ] Direct download process documented
- [ ] App Store process documented
- [ ] Code signing explained
- [ ] Notarization steps included
- [ ] DMG creation covered
- [ ] Quick reference commands provided
