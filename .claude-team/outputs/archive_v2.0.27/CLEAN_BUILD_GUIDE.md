# CloudSync Ultra - Clean Build Guide (#36)

## Quick Commands

### Standard Build
```bash
cd /Users/antti/Claude
xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build 2>&1 | tail -10
```

### Clean Build (Recommended for Issues)
```bash
cd /Users/antti/Claude

# 1. Clean Xcode build folder
xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp clean

# 2. Remove DerivedData
rm -rf ~/Library/Developer/Xcode/DerivedData/CloudSyncApp-*

# 3. Fresh build
xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build 2>&1 | tail -10
```

### Launch App
```bash
open ~/Library/Developer/Xcode/DerivedData/CloudSyncApp-*/Build/Products/Debug/CloudSyncApp.app
```

---

## Common Build Issues & Solutions

### Issue: "No such module" Error
**Cause:** Swift module cache corrupted
**Solution:**
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData
rm -rf ~/Library/Caches/com.apple.dt.Xcode
xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build
```

### Issue: Code Signing Error
**Cause:** Certificate/provisioning issue
**Solution:**
1. Open Xcode → CloudSyncApp.xcodeproj
2. Select target → Signing & Capabilities
3. Ensure "Automatically manage signing" is checked
4. Select your development team

### Issue: "Command not found: xcodebuild"
**Cause:** Xcode Command Line Tools not installed
**Solution:**
```bash
xcode-select --install
```

### Issue: Build Succeeds but App Won't Launch
**Cause:** Old cached app in DerivedData
**Solution:**
```bash
# Kill any running instance
pkill -f CloudSyncApp

# Clean and rebuild
rm -rf ~/Library/Developer/Xcode/DerivedData/CloudSyncApp-*
xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build
open ~/Library/Developer/Xcode/DerivedData/CloudSyncApp-*/Build/Products/Debug/CloudSyncApp.app
```

### Issue: SwiftUI Preview Crashes
**Cause:** Preview cache corrupted
**Solution:**
```bash
rm -rf ~/Library/Developer/Xcode/UserData/Previews
```

---

## Full Reset (Nuclear Option)

If all else fails:

```bash
# 1. Quit Xcode completely
pkill -f Xcode

# 2. Remove ALL Xcode caches
rm -rf ~/Library/Developer/Xcode/DerivedData
rm -rf ~/Library/Caches/com.apple.dt.Xcode
rm -rf ~/Library/Developer/Xcode/UserData/Previews

# 3. Clear Swift package cache
rm -rf ~/Library/Developer/Xcode/SPM

# 4. Restart Xcode and build
open CloudSyncApp.xcodeproj
# Then: Product → Clean Build Folder (⇧⌘K)
# Then: Product → Build (⌘B)
```

---

## Claude Cowork Option

You can use Claude Cowork to manage builds:

```
Help me with Xcode build issues for CloudSyncApp:
1. Navigate to /Users/antti/Claude
2. Run a clean build
3. If errors occur, diagnose and fix
4. Launch the app when successful
```

---

## Verifying Build Success

A successful build shows:
```
** BUILD SUCCEEDED **
```

If you see warnings but build succeeds, check:
- Deprecation warnings (usually safe to ignore)
- Unused variable warnings (clean up later)

---

*Created: 2026-01-13*
*Ticket: #36*
