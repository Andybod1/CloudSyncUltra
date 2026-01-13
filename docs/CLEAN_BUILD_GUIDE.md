# Clean Build Guide for CloudSync Ultra

## Quick Reference

```bash
# Full clean build (recommended when things break)
cd /Users/antti/Claude
rm -rf ~/Library/Developer/Xcode/DerivedData/CloudSyncApp-*
xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp clean
xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build

# Launch app after build
open ~/Library/Developer/Xcode/DerivedData/CloudSyncApp-*/Build/Products/Debug/CloudSyncApp.app
```

---

## Common Build Issues & Solutions

### Issue: "No such module" errors
**Cause:** SPM packages not resolved
**Solution:**
```bash
cd /Users/antti/Claude
xcodebuild -resolvePackageDependencies -project CloudSyncApp.xcodeproj
xcodebuild build -project CloudSyncApp.xcodeproj -scheme CloudSyncApp
```

### Issue: Stale build artifacts
**Cause:** DerivedData corrupted
**Solution:**
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/CloudSyncApp-*
xcodebuild clean build -project CloudSyncApp.xcodeproj -scheme CloudSyncApp
```

### Issue: Code signing errors
**Cause:** Team/signing identity issues
**Solution:**
1. Open project in Xcode
2. Go to Signing & Capabilities
3. Select your team
4. Let Xcode manage signing

### Issue: SwiftUI preview crashes
**Cause:** Preview cache corrupted
**Solution:**
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/*/Build/Intermediates.noindex/Previews
```

---

## Build Commands Reference

| Command | Purpose |
|---------|---------|
| `xcodebuild build` | Standard build |
| `xcodebuild clean` | Clean build folder |
| `xcodebuild test` | Run unit tests |
| `xcodebuild -showBuildSettings` | Show all build settings |
| `xcodebuild -list` | List schemes and targets |

---

## Verification Steps

After a clean build, verify:

1. **Build succeeds:**
```bash
xcodebuild build 2>&1 | grep -E "BUILD SUCCEEDED|BUILD FAILED"
```

2. **App launches:**
```bash
open ~/Library/Developer/Xcode/DerivedData/CloudSyncApp-*/Build/Products/Debug/CloudSyncApp.app
```

3. **Tests pass:**
```bash
xcodebuild test -destination 'platform=macOS' 2>&1 | grep "Test Suite"
```

---

## Using Claude Cowork for Build Issues

If you have Claude Cowork (Max plan, macOS Desktop):

1. Grant Cowork access to `/Users/antti/Claude/` folder
2. Ask: "Clean build the CloudSyncApp Xcode project and launch it"
3. Cowork can execute terminal commands and verify build status

---

*Last updated: 2026-01-13*
