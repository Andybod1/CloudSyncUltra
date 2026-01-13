# CloudSync Ultra - Clean Build Guide

## Quick Commands

### Standard Build
```bash
cd /Users/antti/Claude
xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build 2>&1 | tail -10
```

### Clean Build (fixes most issues)
```bash
cd /Users/antti/Claude
xcodebuild clean -project CloudSyncApp.xcodeproj -scheme CloudSyncApp
xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build 2>&1 | tail -10
```

### Nuclear Clean (when all else fails)
```bash
# 1. Close Xcode completely
pkill -9 Xcode

# 2. Clean DerivedData
rm -rf ~/Library/Developer/Xcode/DerivedData/CloudSyncApp-*

# 3. Clean build folder
cd /Users/antti/Claude
rm -rf build/

# 4. Clean SPM cache (if using Swift packages)
rm -rf ~/Library/Caches/org.swift.swiftpm/

# 5. Rebuild
xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp build 2>&1 | tail -10
```

### Launch App After Build
```bash
open ~/Library/Developer/Xcode/DerivedData/CloudSyncApp-*/Build/Products/Debug/CloudSyncApp.app
```

---

## Common Build Issues

### Issue: "Module not found"
**Solution:** Clean DerivedData and rebuild

### Issue: "Command PhaseScriptExecution failed"
**Solution:** Check script permissions and paths in Build Phases

### Issue: "Signing certificate" errors
**Solution:** Open Xcode → Signing & Capabilities → Re-select team

### Issue: "Stale file" or "file not found" errors  
**Solution:** Nuclear clean (see above)

### Issue: Build hangs
**Solution:** 
1. Kill Xcode: pkill -9 Xcode
2. Kill build: pkill -9 xcodebuild
3. Nuclear clean and retry

---

## Run Tests
```bash
cd /Users/antti/Claude
xcodebuild test -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -destination 'platform=macOS' 2>&1 | grep -E "Executed|passed|failed" | tail -5
```

---

*Last updated: 2026-01-13*
