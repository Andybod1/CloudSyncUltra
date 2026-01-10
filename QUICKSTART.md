# CloudSync 2.0 - Quick Start

Get up and running in 5 minutes.

## 1. Install rclone

```bash
brew install rclone
```

## 2. Build & Run

```bash
cd ~/Claude
open CloudSyncApp.xcodeproj
# Press ⌘R to build and run
```

## 3. Add Cloud Storage

1. Click **"Add Cloud..."** in sidebar
2. Select provider (Proton, Google, Dropbox, etc.)
3. Name it and click **Add**
4. Go to **Settings → Accounts**
5. Enter credentials → **Connect**

## 4. Transfer Files

1. Go to **Transfer** view
2. **Left pane**: Choose source
3. **Right pane**: Choose destination
4. Select files → Click **→**

## 5. Setup Auto Sync

1. Go to **Settings → Sync**
2. Choose local folder
3. Set remote path
4. Enable **Auto Sync**
5. **Save**

---

## Quick Reference

### Keyboard Shortcuts
| Action | Shortcut |
|--------|----------|
| New Task | ⌘N |
| Refresh | ⌘R |
| Preferences | ⌘, |
| Quit | ⌘Q |

### Menu Bar Icons
| Icon | Status |
|------|--------|
| ☁️ | Idle |
| ↻ | Syncing |
| ✓ | Complete |
| ⚠️ | Error |

### Views
- **Dashboard** — Stats & overview
- **Transfer** — Dual-pane browser
- **Tasks** — Job queue
- **History** — Past transfers

### Supported Providers
Proton Drive, Google Drive, Dropbox, OneDrive, S3, MEGA, Box, pCloud, WebDAV, SFTP, FTP

---

**Version**: 2.0.0 | **Platform**: macOS 14.0+
