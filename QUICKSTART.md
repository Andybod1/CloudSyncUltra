# Quick Start Guide

Get CloudSync Ultra running in 5 minutes! This guide covers the essentials.

## 1. Install rclone

```bash
brew install rclone
```

## 2. Clone & Build

```bash
git clone https://github.com/andybod1-lang/CloudSyncUltra.git
cd CloudSyncUltra
open CloudSyncApp.xcodeproj
```

## 3. Build & Run

Press **⌘R** in Xcode or click the Play button.

## 4. Connect Your First Cloud

### Quick Method (NEW!)
1. Press **Cmd+Shift+N** to open Quick Actions
2. Select "Add Cloud Service"
3. Choose your provider and authenticate

### Traditional Method
1. Click a cloud service in the sidebar (e.g., Google Drive)
2. Click **"Connect Now"**
3. Follow the authentication flow
4. Done! Browse your files

## 5. Transfer Files

### Method 1: Drag & Drop
1. Go to **Transfer** in the sidebar
2. Select source cloud on the left
3. Select destination cloud on the right
4. Drag files between panes

### Method 2: Transfer Preview (NEW!)
1. Select files to transfer
2. Click **"Preview"** button
3. Review what will be transferred
4. Confirm to start transfer

### Method 3: Quick Transfer
1. Press **Cmd+Shift+N**
2. Type "transfer" and press Enter
3. Select source, destination, and files

## Essential Keyboard Shortcuts

| Shortcut | Action | Available In |
|----------|--------|--------------|
| **Cmd+Shift+N** | Quick Actions menu | Everywhere |
| **Cmd+,** | Preferences | Everywhere |
| **Cmd+N** | New folder | File browser |
| **Cmd+R** | Refresh current view | File browser |
| **Delete** | Delete selected | File browser |
| **Space** | Quick Look preview | File browser |
| **Cmd+A** | Select all | File browser |
| **Cmd+Click** | Multi-select | File browser |
| **Esc** | Cancel/Close | Dialogs |

## Common Tasks

| Task | How to Do It | Pro Tip |
|------|--------------|---------|
| **Browse files** | Click cloud name in sidebar | Press Cmd+R to refresh |
| **Quick Actions** | Press **Cmd+Shift+N** anywhere | Type to filter actions |
| **Download files** | Right-click → Download | Select multiple with Cmd+Click |
| **Upload files** | Drag from Finder or click Upload | Preview first for large uploads |
| **Delete files** | Select + Delete key or right-click | Confirms before deletion |
| **New folder** | Cmd+N or click 📁+ button | Works in any cloud |
| **Rename** | Right-click → Rename | Press Enter to confirm |
| **Transfer** | Drag between panes in Transfer view | Use Preview for confidence |
| **Schedule sync** | Schedules → New Schedule | Set daily backups |
| **View modes** | Click List/Grid buttons | Grid better for images |
| **Search files** | Type in search box | Filters as you type |
| **Check progress** | Look at Tasks view | Shows speed and ETA |

## Quick Features Overview

### 🚀 Quick Actions (Cmd+Shift+N)
Access everything instantly:
- Add Cloud Service
- Quick Transfer
- New Folder
- Schedule Sync
- View Recent Transfers

### 📊 Transfer Preview
Before any transfer:
- See exactly what will be copied
- Check file counts and sizes
- Identify conflicts
- Dry-run without risk

### ⚡ Smart Optimization
Automatic per-provider tuning:
- **Google Drive**: 8 parallel, 128MB chunks
- **Dropbox**: 4 parallel, 150MB chunks
- **S3**: 16 parallel, 5MB chunks
- **OneDrive**: 4 parallel, 10MB chunks

### 🔒 Encryption Options
- Enable per cloud service
- Password in Keychain
- Transparent encrypt/decrypt
- Zero-knowledge privacy

### 📅 Scheduled Sync
- Hourly, daily, weekly options
- Multiple schedules supported
- Encryption per schedule
- Menu bar countdown

## Tips for Power Users

### Speed Tips
- **Cmd+Shift+N** for everything - Skip clicking through menus
- **Preview large transfers** - Avoid surprises with dry-run
- **Drag & drop** - Fastest way to transfer
- **Keyboard navigation** - Tab through controls

### Organization
- **Name remotes clearly** - "Backup-S3" vs just "S3"
- **Use folders** - Organize within each cloud
- **Schedule overnight** - Large backups while you sleep
- **Color code** - Different clouds for different purposes

### Performance
- **Zip many small files** - Transfers faster as one file
- **Enable fast-list** - Supported providers load faster
- **Set bandwidth limits** - Don't saturate connection
- **Monitor first transfer** - Ensure settings are right

## Troubleshooting Quick Fixes

| Problem | Quick Fix |
|---------|-----------|
| "rclone not found" | Run: `brew install rclone` |
| "Connection failed" | Re-authenticate in sidebar |
| "Transfer slow" | Check bandwidth settings |
| "Can't see files" | Press Cmd+R to refresh |
| "Auth expired" | Click provider → Reconnect |

## What's New in v2.0.32

- **Interactive Onboarding** - 4-step wizard with "Connect a Provider Now" and "Try a Sync Now" buttons
- **Setup Wizards** - Provider Connection, Schedule, and Transfer wizards for guided setup
- **Subscription Tiers** - Free, Pro ($9.99/mo), Team ($19.99/user) with StoreKit 2
- **Full Keyboard Navigation** - Complete app control without mouse
- **Security Hardening** - Path sanitization, secure file handling, log permissions
- **855 Automated Tests** - Comprehensive test coverage

### Core Features
- **Quick Actions** - Cmd+Shift+N productivity boost
- **Transfer Preview** - See before you sync with dry-run
- **Smart Chunks** - Provider-optimized transfers

## Next Steps

1. **Connect all your clouds** - Centralize management
2. **Set up scheduled backups** - Automate protection
3. **Try Quick Actions** - Boost productivity
4. **Enable encryption** - For sensitive data
5. **Read full docs** - [README.md](README.md) has everything

## Need More Help?

- **Full Guide**: [GETTING_STARTED.md](GETTING_STARTED.md)
- **All Features**: [README.md](README.md)
- **Architecture**: [DEVELOPMENT.md](DEVELOPMENT.md)
- **What's New**: [CHANGELOG.md](CHANGELOG.md)
- **Report Issues**: [GitHub Issues](https://github.com/andybod1-lang/CloudSyncUltra/issues)

---

**Quick Start Version**: 2.0.32
**Last Updated**: January 2026

Enjoy CloudSync Ultra - The fastest way to manage all your clouds! ☁️⚡