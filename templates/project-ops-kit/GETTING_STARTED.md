# Getting Started with CloudSync Ultra

## What is CloudSync Ultra?

CloudSync Ultra is **the most comprehensive cloud sync app for macOS**, supporting 42+ cloud providers with advanced features like dual-pane file management, end-to-end encryption, and intelligent transfer optimization.

### Key Features
- 🌐 **42+ Cloud Providers** - From Google Drive to Proton Drive to S3
- 📁 **Dual-Pane File Browser** - Transfer files between clouds with drag & drop
- 🔒 **End-to-End Encryption** - AES-256 encryption available to all users (Free, Pro, Team)
- ⚡ **Optimized Transfers** - Provider-aware chunk sizes and parallelism
- 🧙 **Setup Wizards** - Guided provider connection, scheduling, and transfers
- 🎯 **Quick Actions** - Keyboard-driven productivity (Cmd+Shift+N)
- 📊 **Transfer Preview** - See what will be transferred before starting
- 🕐 **Scheduled Sync** - Automatic sync on hourly/daily/weekly schedules
- ⌨️ **Full Keyboard Navigation** - Control the entire app without a mouse
- 🖥️ **Native macOS** - Beautiful SwiftUI interface with dark mode support

## Prerequisites

### System Requirements
- ✅ macOS 14.0 (Sonoma) or later
- ✅ 200 MB free disk space
- ✅ Internet connection

### Required Software
- **Xcode 15.0+** (for building from source) - [Download from Mac App Store](https://apps.apple.com/app/xcode/id497799835)
- **rclone** (installed automatically or manually)

### Installing rclone
```bash
# Option 1: Using Homebrew (recommended)
brew install rclone

# Option 2: The app will prompt to install automatically on first launch

# Verify installation
rclone version
# Expected: v1.65.0 or later
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

# Launch the app
open ~/Library/Developer/Xcode/DerivedData/CloudSyncApp-*/Build/Products/Release/CloudSyncApp.app
```

## First Launch (Interactive Onboarding)

### 1. Launch the App
- Look for **CloudSync Ultra** in your Applications folder or build output
- The app opens with a full window interface
- You'll also see a ☁️ icon in your menu bar

### 2. Interactive Onboarding Wizard
New users are guided through a **4-step interactive onboarding**:

#### Step 1: Welcome
Introduction to CloudSync Ultra's capabilities and what you can do with it.

#### Step 2: Add Your First Cloud
- Click **"Connect a Provider Now"** button
- This launches the **Provider Connection Wizard**
- Follow the guided steps to connect your first cloud
- Once connected, you'll see a ✓ checkmark confirming success

#### Step 3: First Sync
- Click **"Try a Sync Now"** button
- This launches the **Transfer Wizard**
- Select source and destination
- Complete your first transfer with guidance
- A ✓ checkmark confirms your first sync is complete

#### Step 4: Complete
- Review quick tips for power users
- Click "Get Started" to enter the main app

You can skip onboarding anytime, but the interactive steps help you learn faster.

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

### Using the Provider Connection Wizard (Recommended)

The **Provider Connection Wizard** guides you through setup step-by-step:

1. **Click "Add Cloud Service"** in the sidebar, or press **Cmd+N**
2. **Select Provider** - Choose from 42+ providers in the grid
3. **Name Your Remote** - Give it a memorable name (e.g., "Work Google Drive")
4. **Authenticate** - OAuth or credentials depending on provider
5. **Test Connection** - Wizard verifies everything works
6. **Complete** - Your cloud appears in the sidebar!

### Supported Providers

#### Popular Providers
- **Google Drive** - Your Google storage with 15GB free
- **Dropbox** - Simple file sync with 2GB free
- **OneDrive** - Microsoft's cloud with 5GB free
- **Proton Drive** - Privacy-focused with end-to-end encryption
- **MEGA** - 20GB free with built-in encryption
- **Box** - Business-focused with 10GB free

#### All 42+ Providers
Click "Show All Providers" to see the complete list including:
- **Enterprise**: S3, Azure Blob, Google Cloud Storage, SharePoint
- **Privacy-focused**: Proton Drive, pCloud Crypto
- **Self-hosted**: Nextcloud, ownCloud, WebDAV, Seafile
- **Regional**: Yandex, Mail.ru, Jottacloud, Koofr

### Authentication Types

#### OAuth Providers (Google, Dropbox, OneDrive, Box)
1. Click on the provider in the wizard
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

## Your First Transfer

### Using the Transfer Wizard (Easiest)

The **Transfer Wizard** guides you through file transfers:

1. **Launch Wizard** - Click "New Transfer" or use during onboarding
2. **Select Source** - Choose the source cloud and navigate to files
3. **Select Destination** - Choose where files should go
4. **Choose Files** - Select specific files or entire folders
5. **Preview** - Review what will be transferred (dry-run)
6. **Transfer** - Execute and monitor progress

### Method 2: Drag & Drop
1. Go to **Transfer** view in the sidebar
2. Select source cloud on the left pane
3. Select destination on the right pane
4. Simply drag files from left to right!

### Method 3: Transfer View Buttons
1. In Transfer view, navigate to your files
2. Select files/folders with click or Cmd+click
3. Click the **→** button between panes
4. Monitor progress in the Tasks view

### Method 4: Quick Actions Menu
1. Press **Cmd+Shift+N** anywhere in the app
2. Type "transfer" and select "Quick Transfer"
3. Choose source and destination
4. Select files and start transfer

### Transfer Preview
Before starting any transfer:
1. Click "Preview" to see what will be transferred
2. Review file counts, sizes, and operations
3. Confirm or cancel based on the preview

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

## Key Features to Try

### 🧙 Setup Wizards
Three wizards make complex tasks simple:
- **Provider Connection Wizard** - Add clouds with guided steps
- **Schedule Wizard** - Set up automatic sync easily
- **Transfer Wizard** - Transfer files with preview option

### 🎯 Quick Actions (Cmd+Shift+N)
Access common operations instantly:
- Add Cloud Service
- Quick Transfer
- New Folder
- Schedule Sync
- View Recent Transfers

### ⌨️ Keyboard Navigation
Full keyboard support throughout the app:

| Shortcut | Action |
|----------|--------|
| `⌘N` | Add new provider |
| `⌘,` | Open Settings |
| `⌘⇧N` | Quick Actions menu |
| `↑/↓` | Navigate files |
| `⏎` | Open folder / Select |
| `Space` | Quick Look preview |
| `⌘A` | Select all |
| `Delete` | Delete selected |
| `Tab` | Switch panes (Transfer view) |

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

### 🔒 Encryption (Available to All Users)
End-to-end encryption is available on **all tiers** (Free, Pro, Team):

1. Go to **Settings → Security**
2. Select a remote to encrypt
3. Set a strong password (save it securely!)
4. Optionally enable filename encryption
5. All files uploaded are encrypted before leaving your Mac

**⚠️ Warning**: Your password cannot be recovered. Store it safely!

### 🕐 Scheduled Sync

#### Using the Schedule Wizard
1. Go to **Schedules** in the sidebar
2. Click "New Schedule" to launch the wizard
3. Choose source and destination
4. Select frequency (hourly/daily/weekly)
5. Set preferred time
6. Enable and save

Your syncs run automatically in the background!

### 📋 Task Management
Monitor all operations:
- **Tasks** view shows active transfers with X/Y counter
- See progress, speed, and time remaining
- Pause, resume, or cancel anytime
- View recently completed tasks

## Tips for Success

### Start Small
- Test with a few files first
- Verify transfers completed successfully
- Then move to larger operations

### Use Wizards
- Wizards prevent mistakes
- They validate each step
- Great for learning the app

### Use Transfer Preview
- Always preview large transfers
- Check the operation summary
- Avoid surprises with dry-run

### Optimize Large Transfers
- Zip folders with many small files
- Use scheduled sync for regular backups
- Enable bandwidth throttling if needed

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
1. Use Transfer view or Transfer Wizard
2. Source: Your primary cloud
3. Destination: Your backup cloud
4. Select all files and transfer

### Sync Two Folders
1. Use the Schedule Wizard
2. Set to sync mode (not copy)
3. Choose frequency
4. Enable the schedule

### Multi-Select Delete
1. Select multiple files (Cmd+Click or Shift+Click)
2. Press Delete or right-click → Delete
3. Confirm in the dialog
4. Files are removed

## Menu Bar Features

Click the ☁️ icon to:
- See sync status
- View next scheduled sync
- Active transfer count (X/Y)
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
4. Re-run the Provider Connection Wizard
5. Check provider-specific guides in docs/providers/

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

### Feature Limits (Free Tier)
If you hit limits on the Free tier:
- Max 3 connected remotes → Upgrade to Pro for unlimited
- Max 1 scheduled task → Upgrade to Pro for unlimited
- Go to Settings → Subscription to upgrade

## Getting Help

### Documentation
- **README.md** - Complete feature list
- **QUICKSTART.md** - Quick reference guide
- **SETUP.md** - Detailed installation guide
- **docs/providers/** - Provider-specific guides
- **CHANGELOG.md** - Latest updates

### Support
- GitHub Issues: [Report bugs or request features](https://github.com/andybod1-lang/CloudSyncUltra/issues)
- In-App Feedback: Help → Send Feedback
- Documentation: Check docs/ folder
- Logs: Console.app → Filter by "CloudSyncApp"

## Next Steps

Now that you're up and running:

1. **Connect More Clouds** - Use the Provider Connection Wizard
2. **Set Up Schedules** - Use the Schedule Wizard for automation
3. **Explore Encryption** - Available to all users, secure your files
4. **Learn Keyboard Shortcuts** - Boost your productivity
5. **Try Quick Actions** - Press Cmd+Shift+N
6. **Consider Upgrading** - Pro tier unlocks unlimited features

## Quick Reference

### Essential Shortcuts
| Shortcut | Action |
|----------|--------|
| **Cmd+Shift+N** | Quick Actions menu |
| **Cmd+N** | Add new provider |
| **Cmd+,** | Preferences |
| **Cmd+R** | Refresh |
| **Space** | Preview file |
| **Delete** | Delete selected |

### File Operations
- **Drag & Drop** - Between panes or from Finder
- **Right-Click** - Context menu with all options
- **Multi-Select** - Cmd+Click or Shift+Click
- **Select All** - Cmd+A

### Performance Tips
- Use wizards for guided setup
- Preview before large transfers
- Use scheduled sync for regular backups
- Enable fast-list for supported providers
- Zip many small files before transfer

---

**Getting Started Guide Version**: 2.0.32
**Estimated Time**: 10 minutes
**Last Updated**: January 2026

Welcome to CloudSync Ultra - The most powerful cloud sync app for macOS! ☁️
