# Getting Started with CloudSync Ultra

## What is CloudSync Ultra?

CloudSync Ultra is **the most comprehensive cloud sync app for macOS**, supporting 42+ cloud providers with advanced features like dual-pane file management, end-to-end encryption, and intelligent transfer optimization.

### Key Features
- 🌐 **42+ Cloud Providers** - From Google Drive to Proton Drive to S3
- 📁 **Dual-Pane File Browser** - Transfer files between clouds with drag & drop
- 🔒 **End-to-End Encryption** - Optional AES-256 encryption per remote
- ⚡ **Optimized Transfers** - Provider-aware chunk sizes and parallelism
- 🎯 **Quick Actions** - Keyboard-driven productivity (Cmd+Shift+N)
- 📊 **Transfer Preview** - See what will be transferred before starting
- 🕐 **Scheduled Sync** - Automatic sync on hourly/daily/weekly schedules
- 🖥️ **Native macOS** - Beautiful SwiftUI interface with dark mode support

## Prerequisites

### System Requirements
- ✅ macOS 13.0 (Ventura) or later
- ✅ 200 MB free disk space
- ✅ Internet connection

### Required Software
- **Xcode** (for building from source) - [Download from Mac App Store](https://apps.apple.com/app/xcode/id497799835)
- **rclone** (installed automatically or manually)

### Installing rclone
```bash
# Option 1: Using Homebrew (recommended)
brew install rclone

# Option 2: The app will prompt to install automatically on first launch

# Verify installation
rclone version
```

## Quick Install

### Option 1: Download Release (Coming Soon)
Pre-built releases will be available on the [releases page](https://github.com/andybod1-lang/CloudSyncUltra/releases).

### Option 2: Build from Source
```bash
# Clone the repository
git clone https://github.com/andybod1-lang/CloudSyncUltra.git
cd CloudSyncUltra

# Build using Xcode
open CloudSyncApp.xcodeproj
# Press ⌘R to build and run

# Or build from command line
xcodebuild -scheme CloudSyncApp -configuration Release build
```

## First Launch

### 1. Launch the App
- Look for **CloudSync Ultra** in your Applications folder or build output
- The app opens with a full window interface
- You'll also see a ☁️ icon in your menu bar

### 2. Onboarding Flow (First-Time Users)
New users are guided through a 4-step onboarding process:

1. **Welcome** - Introduction to CloudSync Ultra's capabilities
2. **Add Your First Cloud** - Connect a cloud provider
3. **First Transfer** - Learn the basics with a guided transfer
4. **Quick Tips** - Discover powerful features

You can skip onboarding if you're already familiar with the app.

### 3. Main Interface Overview

```
┌─────────────────────────────────────────────────────────────┐
│  CloudSync Ultra                                  ─ □ ×     │
├─────────────┬───────────────────────────────────────────────┤
│             │                                               │
│  Dashboard  │   Welcome to CloudSync Ultra                  │
│  Transfer   │                                               │
│  Schedules  │   Connected: 0 clouds                         │
│  Tasks      │   Ready to connect your first cloud service    │
│  History    │                                               │
│             │   [Add Your First Cloud]                      │
│ ─────────── │                                               │
│ CLOUD       │                                               │
│  + Add...   │                                               │
│             │                                               │
│ LOCAL       │                                               │
│  Storage    │                                               │
│             │                                               │
│ ─────────── │                                               │
│  Settings   │                                               │
│             │                                               │
└─────────────┴───────────────────────────────────────────────┘
```

## Connect Your First Cloud

### 1. Click "Add Cloud Service"
- In the sidebar under CLOUD, click **"+ Add Cloud Service..."**
- Or use Quick Actions: Press **Cmd+Shift+N** → "Add Cloud Service"

### 2. Choose a Provider
Select from 42+ supported providers:

#### Popular Providers
- **Google Drive** - Your Google storage with 15GB free
- **Dropbox** - Simple file sync with 2GB free
- **OneDrive** - Microsoft's cloud with 5GB free
- **Proton Drive** - Privacy-focused with end-to-end encryption
- **MEGA** - 20GB free with built-in encryption
- **Box** - Business-focused with 10GB free

#### Show All Providers
Click "Show All 42+ Providers" to see the complete list including:
- Enterprise: S3, Azure Blob, Google Cloud Storage
- Privacy-focused: Tresorit, pCloud Crypto
- Self-hosted: Nextcloud, ownCloud, WebDAV
- Regional: Yandex, Mail.ru, Jottacloud

### 3. Authenticate
Each provider has its own authentication method:

#### OAuth Providers (Google, Dropbox, OneDrive, Box)
1. Click on the provider
2. Your browser opens for authentication
3. Log in and authorize CloudSync Ultra
4. Return to the app - connection complete!

#### Username/Password (Proton Drive, MEGA)
1. Enter your email/username
2. Enter your password
3. For Proton Drive, enter 2FA code if enabled
4. Click "Connect"

#### API Keys (S3, B2, Azure)
1. Get credentials from your provider's dashboard
2. Enter Access Key ID and Secret Access Key
3. Configure region/endpoint if needed
4. Click "Connect"

### 4. Verify Connection
- The provider appears in your sidebar with a checkmark ✓
- Click on it to browse your files
- The Dashboard shows it as a connected service

## Your First Transfer

### Method 1: Drag & Drop (Easiest)
1. Go to **Transfer** view in the sidebar
2. Select source cloud on the left pane
3. Select destination on the right pane
4. Simply drag files from left to right!

### Method 2: Transfer View Buttons
1. In Transfer view, navigate to your files
2. Select files/folders with click or Cmd+click
3. Click the **→** button between panes
4. Monitor progress in the Tasks view

### Method 3: Quick Actions Menu
1. Press **Cmd+Shift+N** anywhere in the app
2. Type "transfer" and select "Quick Transfer"
3. Choose source and destination
4. Select files and start transfer

### Transfer Preview (NEW!)
Before starting any transfer:
1. Click "Preview" to see what will be transferred
2. Review file counts, sizes, and operations
3. Confirm or cancel based on the preview

## Key Features to Try

### 🎯 Quick Actions (Cmd+Shift+N)
Access common operations instantly:
- Add Cloud Service
- Quick Transfer
- New Folder
- Schedule Sync
- View Recent Transfers

### 📊 Dashboard
Your command center showing:
- Connected cloud services
- Storage usage per service
- Recent activity
- Quick stats

### ⚡ Optimized Transfers
CloudSync Ultra automatically optimizes based on your provider:
- Google Drive: 8 parallel transfers, 128MB chunks
- Dropbox: 4 parallel transfers, 150MB chunks
- S3: 16 parallel transfers, 5MB chunks
- OneDrive: 4 parallel transfers, 10MB chunks

### 🔒 Encryption
Enable per-remote encryption:
1. Click a cloud in the sidebar
2. Toggle "Enable Encryption"
3. Set a strong password
4. All files uploaded to this remote are encrypted

### 🕐 Scheduled Sync
Set up automatic syncing:
1. Go to **Schedules** in the sidebar
2. Click "New Schedule"
3. Choose frequency (hourly/daily/weekly)
4. Select source and destination
5. Enable the schedule

### 📋 Task Management
Monitor all operations:
- **Tasks** view shows active transfers
- See progress, speed, and time remaining
- Pause, resume, or cancel anytime
- View recently completed tasks

## Tips for Success

### Start Small
- Test with a few files first
- Verify transfers completed successfully
- Then move to larger operations

### Use Transfer Preview
- Always preview large transfers
- Check the operation summary
- Avoid surprises with dry-run

### Optimize Large Transfers
- Zip folders with many small files
- Use scheduled sync for regular backups
- Enable bandwidth throttling if needed

### Keyboard Shortcuts
- **Cmd+Shift+N** - Quick Actions menu
- **Cmd+N** - New folder (in file browser)
- **Cmd+R** - Refresh current view
- **Delete** - Delete selected files
- **Space** - Quick look preview

## Common Tasks

### Upload Files from Mac
1. Browse to destination cloud
2. Click "Upload" button or drag files from Finder
3. Select files in the dialog
4. Monitor progress in Tasks

### Download to Mac
1. Browse to files in any cloud
2. Right-click → "Download" or select and click download button
3. Choose save location
4. Files download with progress tracking

### Cloud-to-Cloud Backup
1. Use Transfer view
2. Source: Your primary cloud
3. Destination: Your backup cloud
4. Select all files and transfer

### Sync Two Folders
1. Create a new schedule
2. Set to sync mode (not copy)
3. Choose frequency
4. Enable the schedule

## Menu Bar Features

Click the ☁️ icon to:
- See sync status
- View next scheduled sync
- Quick sync now
- Open main window
- Access preferences

Status Icons:
- ☁️ - Idle, no active transfers
- 🔄 - Syncing/transferring
- ✓ - Last operation successful
- ⚠️ - Error occurred (click for details)

## Troubleshooting

### "rclone not found"
```bash
# Install via Homebrew
brew install rclone

# Verify installation
which rclone
# Should show: /opt/homebrew/bin/rclone or /usr/local/bin/rclone
```

### "Connection failed"
1. Check your internet connection
2. Verify credentials are correct
3. For OAuth, try re-authenticating
4. Check provider-specific guides in docs/providers/

### "Transfer failed"
1. Check available storage space
2. Verify file names are compatible
3. Try Transfer Preview first
4. Check error details in Tasks view

### Provider-Specific Issues
- **Google Drive**: Check API quotas
- **Dropbox**: Verify app permissions
- **OneDrive**: Ensure correct drive type
- **Proton Drive**: 2FA might be required

## Getting Help

### Documentation
- **README.md** - Complete feature list
- **QUICKSTART.md** - Quick reference guide
- **docs/providers/** - Provider-specific guides
- **CHANGELOG.md** - Latest updates

### Support
- GitHub Issues: [Report bugs or request features](https://github.com/andybod1-lang/CloudSyncUltra/issues)
- Documentation: Check docs/ folder
- Logs: Console.app → Filter by "CloudSyncApp"

## Next Steps

Now that you're up and running:

1. **Connect More Clouds** - Add all your cloud services
2. **Set Up Schedules** - Automate your backups
3. **Explore Encryption** - Secure sensitive files
4. **Try Quick Actions** - Boost your productivity
5. **Read Provider Guides** - Optimize each service

## Quick Reference

### Essential Shortcuts
- **Cmd+Shift+N** - Quick Actions menu
- **Cmd+,** - Preferences
- **Cmd+N** - New folder
- **Cmd+R** - Refresh
- **Space** - Preview file

### File Operations
- **Drag & Drop** - Between panes or from Finder
- **Right-Click** - Context menu with all options
- **Multi-Select** - Cmd+Click or Shift+Click
- **Select All** - Cmd+A

### Performance Tips
- Preview before large transfers
- Use scheduled sync for regular backups
- Enable fast-list for supported providers
- Zip many small files before transfer

---

**Getting Started Guide Version**: 2.0.23
**Estimated Time**: 10 minutes
**Last Updated**: January 2026

Welcome to CloudSync Ultra - The most powerful cloud sync app for macOS! ☁️