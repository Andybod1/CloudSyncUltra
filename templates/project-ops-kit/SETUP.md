# CloudSync Ultra - Setup Guide

Complete setup guide for CloudSync Ultra, the professional cloud sync app for macOS with **42+ cloud providers**.

## Prerequisites

### System Requirements
- **macOS 14.0+** (Sonoma or later)
- **Xcode 15.0+** (for building from source)
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

Sign up for at least one cloud service. CloudSync Ultra supports **42+ providers** including:
- **Proton Drive**: https://proton.me/drive (recommended, E2E encrypted)
- **Google Drive**: https://drive.google.com
- **Dropbox**: https://dropbox.com
- **OneDrive**: https://onedrive.com
- **iCloud**: Built into macOS
- **Amazon S3**: https://aws.amazon.com/s3
- **Backblaze B2**: https://www.backblaze.com/b2
- And 35+ more providers

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
open ~/Library/Developer/Xcode/DerivedData/CloudSyncApp-*/Build/Products/Debug/CloudSyncApp.app
```

### Method 3: Release Build

```bash
# Build release
xcodebuild -project CloudSyncApp.xcodeproj \
           -scheme CloudSyncApp \
           -configuration Release \
           build

# Copy to Applications
cp -r ~/Library/Developer/Xcode/DerivedData/CloudSyncApp-*/Build/Products/Release/CloudSyncApp.app /Applications/

# Launch
open /Applications/CloudSyncApp.app
```

## First-Time Setup (Interactive Onboarding)

CloudSync Ultra includes an **interactive onboarding wizard** that guides you through setup.

### Step 1: Welcome Screen

On first launch, you'll see the onboarding wizard:
1. **Welcome** - Overview of CloudSync Ultra features
2. **Add Provider** - Connect your first cloud service
3. **First Sync** - Try your first transfer
4. **Complete** - Start using the app

### Step 2: Add Your First Provider (Wizard)

The **Provider Connection Wizard** guides you through adding cloud storage:

1. Click **"Connect a Provider Now"** button
2. **Select Provider** - Choose from 42+ providers in the grid
3. **Name Your Remote** - Give it a memorable name (e.g., "Work Google Drive")
4. **Authenticate**:
   - **OAuth providers** (Google, Dropbox, OneDrive): Browser opens for login
   - **Credential providers** (Proton Drive, S3): Enter username/password or keys
5. **Test Connection** - Wizard verifies the connection works
6. Click **"Finish"** to complete

### Step 3: Try Your First Sync

The onboarding offers a **"Try a Sync Now"** button:

1. Click the button to open the **Transfer Wizard**
2. **Select Source** - Choose local folder or cloud remote
3. **Select Destination** - Choose where to sync files
4. **Choose Files** - Select specific files or entire folders
5. **Review & Transfer** - Confirm and start the transfer
6. Monitor progress in the **Tasks** view

### Step 4: Explore the App

After onboarding, you'll see the main window:
- **Sidebar** - Navigation to all features
- **Dashboard** - Overview of connected remotes and recent activity
- **Menu bar icon** - Quick access even when window is closed

## Using Wizards

CloudSync Ultra includes three wizards for common tasks:

### Provider Connection Wizard

Add new cloud storage connections:
1. Click **"Add Cloud..."** in sidebar, or
2. Use **Cmd+N** keyboard shortcut
3. Follow the guided steps

### Schedule Wizard

Set up automatic sync schedules:
1. Go to **Tasks** in sidebar
2. Click **"New Scheduled Task"**
3. Configure:
   - Source and destination
   - Frequency (hourly, daily, weekly)
   - Time preferences (12/24 hour format supported)
4. Enable and save

### Transfer Wizard

Perform one-time transfers:
1. Go to **Transfer** in sidebar
2. Click **"New Transfer"** or use the wizard button
3. Select source, destination, and files
4. Review transfer preview (dry-run option available)
5. Execute transfer

## Keyboard Navigation

CloudSync Ultra supports comprehensive keyboard navigation:

### Global Shortcuts
| Shortcut | Action |
|----------|--------|
| `⌘N` | Add new provider |
| `⌘,` | Open Settings |
| `⌘⇧N` | Quick Actions menu |
| `⌘1-9` | Switch sidebar sections |

### File Browser
| Shortcut | Action |
|----------|--------|
| `↑/↓` | Navigate files |
| `⏎` | Open folder / Select file |
| `⌘↑` | Go to parent folder |
| `Space` | Quick Look preview |
| `⌘A` | Select all |
| `⌘⇧A` | Deselect all |
| `Delete` | Delete selected (with confirmation) |

### Transfer View
| Shortcut | Action |
|----------|--------|
| `Tab` | Switch between panes |
| `→` | Transfer selected to right |
| `←` | Transfer selected to left |

## Settings Overview

### General Tab
- **Launch at Login** — Start automatically
- **Show in Dock** — Toggle dock icon
- **Notifications** — Enable/disable alerts
- **Sound Effects** — Audio feedback
- **Time Format** — 12 or 24 hour display

### Accounts Tab
- List of connected cloud services (42+ supported)
- Add/remove connections via wizard
- Test connection status
- Credential management
- Import/export rclone.conf

### Security Tab
- **E2E Encryption** — Client-side encryption (available to all users)
- **Password** — Set encryption password
- **Salt** — Additional security layer
- **Encrypt Filenames** — Hide file names from cloud provider
- **Encrypt Folder Names** — Hide directory structure
- **⚠️ Warning**: Password cannot be recovered!

### Performance Tab
- **Transfer Threads** — Parallel transfers (1-32)
- **Chunk Size** — Provider-optimized sizes
- **Bandwidth Limit** — Throttle upload/download
- **Performance Profiles** — Balanced, Speed, Conservative, Custom

### Sync Tab
- **Local Folder** — Default sync source
- **Remote Path** — Default cloud destination
- **Auto Sync** — Enable file watching
- **Interval** — How often to sync
- **Conflict Resolution** — Newest wins, keep both, ask

### About Tab
- Version information (currently v2.0.32)
- Links to documentation
- Subscription status
- Credits

## Subscription Tiers

CloudSync Ultra offers three tiers:

| Feature | Free | Pro ($9.99/mo) | Team ($19.99/user) |
|---------|------|----------------|-------------------|
| Cloud providers | 42+ | 42+ | 42+ |
| E2E Encryption | ✅ | ✅ | ✅ |
| Scheduled sync | 1 task | Unlimited | Unlimited |
| Connected remotes | 3 | Unlimited | Unlimited |
| Bandwidth throttling | ✅ | ✅ | ✅ |
| Priority support | - | ✅ | ✅ |
| Team management | - | - | ✅ |

Upgrade anytime via **Settings → Subscription**.

## Menu Bar Usage

Even with the main window closed, you can:

**Click menu bar icon** to see:
- Current status (Idle/Syncing/Error)
- Last sync time
- Active transfers count
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
8. Check **Tasks** view for progress (shows X/Y transfers)
9. Verify file appears in cloud web interface

### Test Cloud → Local Transfer

1. Same as above, but reversed
2. Select file in cloud (right pane)
3. Click **←** to download
4. Verify file appears locally

### Test Automatic Sync

1. Configure sync via **Schedule Wizard** or **Settings → Sync**
2. Set short interval (1 minute for testing)
3. Enable "Auto Sync"
4. Create a file in your sync folder:
```bash
echo "test" > ~/Documents/CloudSync/test.txt
```
5. Wait for sync to trigger
6. Check cloud for the file

### Test Transfer Preview (Dry Run)

1. Go to **Transfer** view
2. Select files to transfer
3. Click **Preview** button (or enable in settings)
4. Review what would be transferred without actually transferring
5. Confirm or cancel

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
4. Re-run the Provider Connection Wizard
5. Check Console.app for detailed errors

### "Build failed" in Xcode

1. **Clean**: Product → Clean Build Folder (⌘⇧K)
2. **Check target**: macOS 14.0+
3. **Check signing**: Select valid team
4. Delete DerivedData and rebuild

### "Files not syncing"

1. Check sync folder path is correct
2. Verify cloud has available storage
3. Check Tasks view for errors
4. Try manual "Sync Now" in menu bar
5. Check if schedule is paused

### "Permission denied"

```bash
# Fix rclone permissions
chmod +x /opt/homebrew/bin/rclone

# Or for bundled rclone
chmod +x CloudSyncApp.app/Contents/Resources/rclone
```

### "Encryption not working after import"

If you imported an rclone.conf with encrypted remotes:
1. Go to **Settings → Accounts**
2. Select the encrypted remote
3. Verify encryption toggle is enabled
4. Re-enter password if prompted

## Advanced Setup

### Multiple Cloud Accounts

1. Use the **Provider Connection Wizard** for each account
2. Give unique names (e.g., "Work Google Drive", "Personal Dropbox")
3. Each appears in sidebar
4. Transfer between any combination

### E2E Encryption

Encryption is available to **all users** (Free, Pro, and Team):

1. **Settings** → **Security**
2. Set strong password (save it securely!)
3. Optionally add salt for extra security
4. Enable "Encrypt file names" for full privacy
5. Enable "Encrypt folder names" to hide structure
6. Click "Enable Encryption"
7. **⚠️ Files can only be decrypted with this password**

### Import Existing rclone Configuration

If you have an existing rclone setup:

1. Go to **Settings** → **Accounts**
2. Click **"Import rclone.conf"**
3. Select your `~/.config/rclone/rclone.conf` file
4. All remotes are imported automatically
5. Encrypted remotes are detected and configured

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
- [ ] Onboarding wizard appears on first launch
- [ ] Can add cloud storage via wizard
- [ ] Can browse cloud files
- [ ] Can transfer local → cloud
- [ ] Can transfer cloud → local
- [ ] Transfer preview (dry-run) works
- [ ] Auto sync triggers on schedule
- [ ] Menu bar shows correct status
- [ ] Keyboard shortcuts work
- [ ] Settings save correctly
- [ ] Encryption can be enabled

## Next Steps

After setup:
1. **Connect all your cloud accounts** using the Provider Wizard
2. **Set up automatic sync** via the Schedule Wizard
3. **Enable encryption** for sensitive data (available to all users)
4. **Learn keyboard shortcuts** for power-user efficiency
5. **Configure performance** settings for your connection speed
6. **Test backup/restore** workflow
7. **Review history** to verify transfers

---

**Setup Guide Version**: 2.0.32
**Last Updated**: January 2026
**Platform**: macOS 14.0+
**Providers**: 42+
