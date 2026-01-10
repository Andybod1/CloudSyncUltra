# CloudSync 2.0 - Setup Guide

Complete setup guide for CloudSync, the professional cloud sync app for macOS.

## Prerequisites

### System Requirements
- **macOS 14.0+** (Sonoma or later)
- **Xcode 15.0+**
- **8 GB RAM** recommended
- **500 MB disk space**

### 1. Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Install rclone

```bash
brew install rclone
```

Verify installation:
```bash
rclone version
# Expected: rclone v1.65.0 or later
```

### 3. Cloud Account

Sign up for at least one cloud service:
- **Proton Drive**: https://proton.me/drive (recommended, E2E encrypted)
- **Google Drive**: https://drive.google.com
- **Dropbox**: https://dropbox.com
- **OneDrive**: https://onedrive.com

## Building the App

### Method 1: Xcode (Recommended)

1. **Open the project:**
```bash
cd ~/Claude
open CloudSyncApp.xcodeproj
```

2. **Configure signing:**
   - Select project in navigator
   - Select "CloudSyncApp" target
   - Go to "Signing & Capabilities"
   - Select your Team or "Sign to Run Locally"

3. **Build & Run:**
   - Press `⌘R` or click Play button
   - Main window opens automatically
   - Menu bar icon also appears

### Method 2: Command Line

```bash
cd ~/Claude

# Debug build
xcodebuild -project CloudSyncApp.xcodeproj \
           -scheme CloudSyncApp \
           -configuration Debug \
           build

# Run
open build/Debug/CloudSyncApp.app
```

### Method 3: Release Build

```bash
# Build release
xcodebuild -project CloudSyncApp.xcodeproj \
           -scheme CloudSyncApp \
           -configuration Release \
           build

# Copy to Applications
cp -r build/Release/CloudSyncApp.app /Applications/

# Launch
open /Applications/CloudSyncApp.app
```

## First-Time Configuration

### Step 1: Launch CloudSync

After building, the main window opens automatically. You'll see:
- **Sidebar** on the left with navigation
- **Dashboard** showing empty state
- **Menu bar icon** (cloud) in top-right

### Step 2: Add Cloud Storage

1. In sidebar, click **"Add Cloud..."** under Cloud Storage
2. Select your provider from the grid:
   - Proton Drive (purple shield)
   - Google Drive (blue G)
   - Dropbox (blue box)
   - etc.
3. Enter a name for this connection
4. Click **"Add"**

### Step 3: Configure Credentials

For **Proton Drive**:
1. Go to **Settings** (sidebar) → **Accounts** tab
2. Select your Proton Drive connection
3. Enter:
   - **Username**: your.email@proton.me
   - **Password**: Your Proton password
4. Click **"Connect"**
5. Wait for "Connected" status

For **Google Drive** (OAuth):
1. Click "Connect"
2. Browser opens for Google login
3. Authorize CloudSync
4. Return to app (automatic)

### Step 4: Browse Files

1. Click your cloud service in sidebar
2. **File Browser** opens showing remote files
3. Navigate using:
   - Double-click folders to enter
   - Breadcrumb bar to go back
   - ⬆️ button for parent folder

### Step 5: Transfer Files

1. Go to **Transfer** in sidebar
2. **Left pane**: Select source (e.g., Local Storage)
3. **Right pane**: Select destination (e.g., Proton Drive)
4. Navigate to desired folders
5. Select files (click, Shift+click, Cmd+click)
6. Click **→** button to transfer
7. Monitor progress in **Tasks** view

### Step 6: Setup Automatic Sync

1. Go to **Tasks** in sidebar
2. Click **"New Task"**
3. Configure:
   - **Name**: "Daily Backup"
   - **Type**: Sync
   - **Source**: Local Storage, /Documents
   - **Destination**: Proton Drive, /Backup
4. Enable **"Enable Schedule"**
5. Set interval (e.g., "Every hour")
6. Click **"Create Task"**

## Settings Overview

### General Tab
- **Launch at Login** — Start automatically
- **Show in Dock** — Toggle dock icon
- **Notifications** — Enable/disable alerts
- **Sound Effects** — Audio feedback

### Accounts Tab
- List of connected cloud services
- Add/remove connections
- Test connection status
- Credential management

### Security Tab
- **E2E Encryption** — Enable client-side encryption
- **Password** — Set encryption password
- **Encrypt Filenames** — Hide file names
- **⚠️ Warning**: Password cannot be recovered!

### Sync Tab
- **Local Folder** — Default sync source
- **Remote Path** — Default cloud destination
- **Auto Sync** — Enable file watching
- **Interval** — How often to sync
- **Conflict Resolution** — What to do with conflicts

### About Tab
- Version information
- Links to documentation
- Credits

## Menu Bar Usage

Even with the main window closed, you can:

**Click menu bar icon** to see:
- Current status (Idle/Syncing/Error)
- Last sync time
- **Sync Now** — Trigger immediate sync
- **Pause/Resume** — Control auto-sync
- **Open Sync Folder** — Launch Finder
- **Preferences** — Open settings
- **Quit** — Exit app

**Icon states**:
- ☁️ Cloud — Idle, all synced
- ↻ Arrows — Syncing in progress
- ✓ Checkmark — Just completed
- ⚠️ Warning — Error occurred

## Verification

### Test Local → Cloud Transfer

1. Go to **Transfer** view
2. Left: Select "Local Storage"
3. Navigate to a folder with test files
4. Right: Select your cloud service
5. Navigate to destination folder
6. Select a small test file
7. Click **→** to transfer
8. Check **Tasks** view for progress
9. Verify file appears in cloud web interface

### Test Cloud → Local Transfer

1. Same as above, but reversed
2. Select file in cloud (right pane)
3. Click **←** to download
4. Verify file appears locally

### Test Automatic Sync

1. Configure sync in **Settings** → **Sync**
2. Set short interval (1 minute for testing)
3. Enable "Auto Sync"
4. Create a file in your sync folder:
```bash
echo "test" > ~/Documents/ProtonSync/test.txt
```
5. Wait for sync to trigger
6. Check cloud for the file

## Permissions

### Full Disk Access (if needed)

Some folders require special permissions:

1. **System Settings** → **Privacy & Security**
2. **Full Disk Access**
3. Click **+** button
4. Navigate to CloudSyncApp.app
5. Add to list
6. Restart CloudSync

### Network Access

First launch may prompt:
> "CloudSyncApp would like to access the network"

Click **Allow** — required for cloud sync.

## Troubleshooting

### "rclone not found"

```bash
# Install
brew install rclone

# Verify
which rclone
# Should show: /opt/homebrew/bin/rclone
```

### "Connection failed"

1. Verify credentials work in web browser
2. Check internet connection
3. For 2FA accounts, may need app password
4. Check Console.app for detailed errors

### "Build failed" in Xcode

1. **Clean**: Product → Clean Build Folder (⌘⇧K)
2. **Check target**: macOS 14.0+
3. **Check signing**: Select valid team

### "Files not syncing"

1. Check sync folder path is correct
2. Verify cloud has available storage
3. Check Tasks view for errors
4. Try manual "Sync Now" in menu bar

### "Permission denied"

```bash
# Fix rclone permissions
chmod +x /opt/homebrew/bin/rclone

# Or for bundled rclone
chmod +x CloudSyncApp.app/Contents/Resources/rclone
```

## Advanced Setup

### Multiple Cloud Accounts

1. Add each cloud service separately
2. Give unique names (e.g., "Work Google Drive", "Personal Dropbox")
3. Each appears in sidebar
4. Transfer between any combination

### E2E Encryption

1. **Settings** → **Security**
2. Set strong password (save it securely!)
3. Optionally add salt
4. Enable "Encrypt file names" for full privacy
5. Click "Enable Encryption"
6. **⚠️ Files encrypted with this password only**

### Bundling rclone (for distribution)

1. Download rclone binary:
```bash
curl -O https://downloads.rclone.org/rclone-current-osx-arm64.zip
unzip rclone-current-osx-arm64.zip
```

2. Add to Xcode project:
   - Drag `rclone` to project
   - Check "Copy items if needed"
   - Add to CloudSyncApp target

3. App automatically uses bundled version

## Test Checklist

- [ ] rclone installed and working
- [ ] App builds without errors
- [ ] Main window opens
- [ ] Can add cloud storage
- [ ] Can browse cloud files
- [ ] Can transfer local → cloud
- [ ] Can transfer cloud → local
- [ ] Auto sync triggers on file changes
- [ ] Menu bar shows correct status
- [ ] Settings save correctly

## Next Steps

After setup:
1. **Configure all your cloud accounts**
2. **Set up automatic sync** for important folders
3. **Enable encryption** for sensitive data
4. **Test backup/restore** workflow
5. **Review history** to verify transfers

---

**Setup Guide Version**: 2.0  
**Last Updated**: January 2026  
**Platform**: macOS 14.0+
