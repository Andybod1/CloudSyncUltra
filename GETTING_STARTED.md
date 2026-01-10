# 🚀 Getting Started with CloudSync

Welcome! This guide will get you up and running with CloudSync in under 10 minutes.

## What You're Building

A macOS menu bar app that automatically syncs a local folder with Proton Drive cloud storage.

```
┌─────────────────────────────────────┐
│  Your Mac                           │
│  ┌──────────────┐                   │
│  │ Local Folder │ ←→ CloudSync      │
│  └──────────────┘     (Menu Bar)    │
└────────────┬────────────────────────┘
             │
             ↓ Internet
             │
┌────────────▼────────────────────────┐
│  Proton Drive (Cloud Storage)       │
│  ┌──────────────┐                   │
│  │ Your Files   │ (Encrypted)       │
│  └──────────────┘                   │
└─────────────────────────────────────┘
```

## Prerequisites (5 minutes)

### 1. Check Your Mac
- macOS 13.0 or later ✓
- Xcode installed (from Mac App Store) ✓

### 2. Install rclone
```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install rclone
brew install rclone

# Verify
rclone version
```

### 3. Get Proton Drive Account
- Sign up (free): https://proton.me/drive
- Remember your email and password

## Build the App (2 minutes)

### Option 1: Automatic (Recommended)
```bash
cd CloudSyncApp
./build.sh
```

### Option 2: Using Xcode
```bash
cd CloudSyncApp
open CloudSyncApp.xcodeproj
# Press ⌘R to build and run
```

## Configure & Run (3 minutes)

### 1. Launch the App
- Look for ☁️ icon in menu bar (top-right)
- Click it to open menu

### 2. Open Preferences
- Click ☁️ icon → "Preferences..." (or press ⌘,)

### 3. Connect Proton Drive
- Go to "Account" tab
- Enter:
  - Username: `your.email@proton.me`
  - Password: `your-password`
- Click "Connect"
- Wait for "✓ Proton Drive is connected"

### 4. Setup Sync
- Go to "General" tab
- Local Folder: Click "Choose..." → Select folder
- Remote Path: Enter `/Backup` (or any path)
- Check "Enable automatic sync" ✓
- Click "Save"

### 5. Watch It Sync!
- Menu bar icon changes to ↻ (syncing)
- First sync may take a few minutes
- Icon changes to ✓ when done

## Verify It's Working

### Test 1: Create a File
```bash
# Create test file in your sync folder
echo "Hello CloudSync!" > ~/YourSyncFolder/test.txt

# Wait 5 seconds
# Check menu bar icon (should sync automatically)
```

### Test 2: Check Proton Drive
- Visit: https://drive.proton.me
- Navigate to your remote path
- See `test.txt` appear!

## Common Commands

### Manual Sync
```
Click ☁️ → "Sync Now" (or press ⌘S when menu is open)
```

### Pause Syncing
```
Click ☁️ → "Pause Sync"
```

### Check Status
```
Click ☁️ → See status in menu
```

## Understanding the Icons

| Icon | Meaning | What It Means |
|------|---------|---------------|
| ☁️ | Idle | No sync in progress, waiting |
| ↻ | Syncing | Files are being transferred |
| ✓ | Complete | Last sync was successful |
| ⚠️ | Error | Something went wrong, check menu |

## Troubleshooting

### "rclone not found"
```bash
brew install rclone
which rclone  # Should show path
```

### "Connection failed"
- Double-check your Proton Drive email/password
- Try logging in at https://drive.proton.me
- Check your internet connection

### "Sync not working"
- Ensure local folder exists and is readable
- Check Proton Drive has available storage
- Click menu icon to see error message

### "Can't find the app"
```bash
# The app should be at:
# ./build/Build/Products/Debug/CloudSyncApp.app (if Debug)
# ./build/Build/Products/Release/CloudSyncApp.app (if Release)

# Or install to Applications:
cp -r build/Build/Products/Release/CloudSyncApp.app /Applications/
```

## Next Steps

### Basic Use
✅ You're done! The app will now:
- Monitor your folder for changes
- Sync automatically every 5 minutes
- Sync when files change (after 3-second delay)
- Show progress in menu bar

### Advanced Configuration
📖 Read `README.md` for:
- Changing sync interval
- Adding exclude patterns
- Using bidirectional sync
- Multiple cloud providers (future)

### Development
💻 Read `DEVELOPMENT.md` for:
- Understanding the code
- Adding features
- Contributing back
- Architecture details

## Quick Reference Card

```
╔═══════════════════════════════════════════╗
║         CloudSync Quick Reference         ║
╠═══════════════════════════════════════════╣
║ MENU BAR                                  ║
║  ☁️ → Idle                                ║
║  ↻ → Syncing                              ║
║  ✓ → Complete                             ║
║  ⚠️ → Error                               ║
╠═══════════════════════════════════════════╣
║ SHORTCUTS                                 ║
║  ⌘S → Sync Now (when menu open)           ║
║  ⌘, → Preferences                         ║
║  ⌘Q → Quit                                ║
╠═══════════════════════════════════════════╣
║ LOCATIONS                                 ║
║  Config: ~/Library/Application Support/  ║
║          CloudSyncApp/rclone.conf         ║
║  Logs: Console.app → CloudSyncApp         ║
╠═══════════════════════════════════════════╣
║ SUPPORT                                   ║
║  Docs: README.md                          ║
║  Setup: SETUP.md                          ║
║  Quick: QUICKSTART.md                     ║
║  rclone: https://rclone.org/protondrive/  ║
╚═══════════════════════════════════════════╝
```

## Success Checklist

- [ ] rclone installed and working
- [ ] Proton Drive account created
- [ ] CloudSync app built successfully
- [ ] App appears in menu bar
- [ ] Proton Drive connected
- [ ] Local folder selected
- [ ] First sync completed
- [ ] Test file synced to cloud

**All checked?** Congratulations! 🎉 You're all set!

## What's Next?

1. **Use It Daily**
   - Just add/edit files in your sync folder
   - CloudSync handles the rest automatically

2. **Customize It**
   - Adjust sync interval in Preferences
   - Try different remote paths for organization
   - Pause when on metered connection

3. **Explore Features**
   - Read `README.md` for all features
   - Check `DEVELOPMENT.md` to understand internals
   - Consider contributing improvements

## Need Help?

1. **Check Documentation**
   - `QUICKSTART.md` - Quick reference
   - `README.md` - Complete guide
   - `SETUP.md` - Detailed setup

2. **Debug**
   - Click menu icon for status
   - Open Console.app → filter "CloudSyncApp"
   - Test rclone manually: `rclone lsd proton:`

3. **Resources**
   - rclone docs: https://rclone.org/
   - Proton Drive: https://proton.me/support/
   - File an issue (if open source)

## Tips for Success

💡 **Start Small** - Test with a small folder first  
💡 **Monitor First Sync** - Watch the progress  
💡 **Check Storage** - Ensure enough space on Proton Drive  
💡 **Read Status** - Click menu icon to see what's happening  
💡 **Be Patient** - Large initial syncs take time  

---

**Getting Started Guide Version**: 1.0  
**Estimated Time**: 10 minutes  
**Difficulty**: Beginner-friendly  
**Last Updated**: January 2026  

Happy Syncing! ☁️✨
