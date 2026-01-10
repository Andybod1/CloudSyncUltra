# CloudSync 2.0 - Project Overview

## What is CloudSync?

CloudSync is a professional macOS application for cloud storage synchronization, inspired by OurClone.app. It provides a modern, full-featured interface for managing multiple cloud providers, transferring files between services, and keeping folders in sync with end-to-end encryption support.

## Version 2.0 Highlights

### From Menu Bar App to Full Application

| v1.0 (MVP) | v2.0 (Current) |
|------------|----------------|
| Menu bar only | Full window + menu bar |
| Single view | Multi-view navigation |
| Proton Drive only | 13+ cloud providers |
| Basic sync | Transfer, Sync, Backup modes |
| Simple status | Dashboard with stats |
| No file browser | Dual-pane file browser |

### New User Interface

```
┌─────────────────────────────────────────────────────────────┐
│  CloudSync 2.0                                    ─ □ ×     │
├─────────────┬───────────────────────────────────────────────┤
│             │                                               │
│  Dashboard  │   Welcome to CloudSync                        │
│  Transfer   │   ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐            │
│  Tasks      │   │  3  │ │  1  │ │  0  │ │ 24  │            │
│  History    │   │cloud│ │ run │ │ que │ │done │            │
│             │   └─────┘ └─────┘ └─────┘ └─────┘            │
│ ─────────── │                                               │
│ CLOUD       │   Connected Services                          │
│  Proton     │   ┌──────────┐ ┌──────────┐                  │
│  Google     │   │ Proton   │ │ Google   │                  │
│  Dropbox    │   │ Drive ✓  │ │ Drive ✓  │                  │
│             │   └──────────┘ └──────────┘                  │
│ LOCAL       │                                               │
│  Storage    │   Recent Activity                             │
│             │   • Transfer completed - 2 min ago            │
│ ─────────── │   • Sync finished - 15 min ago               │
│  Settings   │                                               │
│             │                                               │
└─────────────┴───────────────────────────────────────────────┘
```

## Key Features

### 🎯 Dashboard
- **Quick Stats** — Connected services, active tasks, queue, history
- **Connected Services** — Visual grid of configured cloud providers
- **Recent Activity** — Last 5 completed transfers
- **Quick Actions** — One-click transfer, sync, backup, settings

### 📁 Dual-Pane Transfer
- **Side-by-Side Browsers** — Source and destination file lists
- **Multiple Modes** — Transfer, Sync, or Backup
- **File Selection** — Multi-select with Shift/Cmd click
- **Breadcrumb Navigation** — Click path segments to navigate
- **Search & Sort** — Filter by name, sort by size/date

### 📋 Task Management
- **Job Queue** — Create and queue multiple sync jobs
- **Live Progress** — Percentage, speed, ETA, files transferred
- **Controls** — Start, pause, resume, cancel tasks
- **Logs** — Per-task activity logging

### 📜 History
- **Complete Log** — All past transfers and syncs
- **Grouped by Date** — Today, Yesterday, older dates
- **Searchable** — Find by name, source, destination
- **Filterable** — Show only completed, failed, cancelled

### 🔒 Security
- **E2E Encryption** — AES-256 client-side encryption
- **Keychain Storage** — Credentials stored securely
- **Zero-Knowledge** — Files encrypted before upload

## Technology Stack

### Languages & Frameworks
- **Swift 5.9+** — Modern, safe, performant
- **SwiftUI** — Declarative UI (NavigationSplitView, Table, etc.)
- **Combine** — Reactive state management
- **AppKit** — Menu bar, system integration

### Architecture
- **MVVM** — Model-View-ViewModel pattern
- **Singletons** — Shared managers for global state
- **Environment Objects** — SwiftUI dependency injection
- **Async/Await** — Modern concurrency

### External Dependencies
- **rclone** — Multi-cloud sync engine (70+ providers)

## File Structure

```
CloudSyncApp/
├── CloudSyncAppApp.swift          # App entry, WindowGroup + Settings
├── Models/
│   ├── CloudProvider.swift        # Provider enum, CloudRemote, FileItem
│   ├── SyncTask.swift             # Task model, TaskState, TaskLog
│   └── AppTheme.swift             # Colors, dimensions, modifiers
├── ViewModels/
│   ├── RemotesViewModel.swift     # Cloud connections state
│   ├── TasksViewModel.swift       # Job queue state
│   └── FileBrowserViewModel.swift # File navigation state
├── Views/
│   ├── MainWindow.swift           # NavigationSplitView + Sidebar
│   ├── DashboardView.swift        # Stats, services, activity
│   ├── TransferView.swift         # Dual-pane browser
│   ├── TasksView.swift            # Task cards, new task sheet
│   ├── HistoryView.swift          # Grouped history list
│   └── FileBrowserView.swift      # Full-page file browser
├── RcloneManager.swift            # rclone process interface
├── SyncManager.swift              # Sync orchestration, FSEvents
├── EncryptionManager.swift        # E2E encryption, Keychain
├── StatusBarController.swift      # Menu bar icon & menu
└── SettingsView.swift             # 5-tab preferences
```

**Total Swift Code**: ~3000+ lines  
**Views**: 6 main views + supporting components  
**Models**: 3 model files with 10+ types  

## Supported Cloud Providers

| Provider | Icon | Brand Color | rclone Type |
|----------|------|-------------|-------------|
| Proton Drive | shield.checkered | Purple | protondrive |
| Google Drive | g.circle.fill | Blue | drive |
| Dropbox | shippingbox.fill | Blue | dropbox |
| OneDrive | cloud.fill | Blue | onedrive |
| Amazon S3 | externaldrive | Orange | s3 |
| MEGA | m.circle.fill | Red | mega |
| Box | cube.fill | Blue | box |
| pCloud | cloud.circle | Teal | pcloud |
| WebDAV | globe | Gray | webdav |
| SFTP | terminal.fill | Green | sftp |
| FTP | network | Orange | ftp |
| Local | folder.fill | Gray | local |

## User Workflows

### Setup Flow
1. Launch CloudSync (main window opens)
2. Click "Add Cloud..." in sidebar
3. Select provider from grid
4. Enter credentials or OAuth
5. Connection appears in sidebar

### Transfer Flow
1. Go to Transfer view
2. Select source remote (left pane)
3. Select destination remote (right pane)
4. Navigate to folders
5. Select files to transfer
6. Click → to start transfer
7. Monitor progress in Tasks view

### Sync Flow
1. Go to Tasks view
2. Click "New Task"
3. Choose Sync mode
4. Select source and destination
5. Enable scheduling (optional)
6. Create task
7. Task runs automatically

## Design System

### Colors
```swift
Primary Gradient: #6366F1 → #8B5CF6 (Indigo to Purple)
Success: Green
Warning: Orange
Error: Red
Info: Blue
```

### Typography
- **Headlines**: System font, semibold
- **Body**: System font, regular
- **Captions**: System font, smaller size

### Components
- **Stat Cards** — Icon + large number + label
- **Service Cards** — Icon + name + status
- **Task Cards** — Full task info + progress bar
- **File Rows** — Icon + name + size + date

### Spacing
```swift
Padding: 16pt (standard), 8pt (small), 24pt (large)
Corner Radius: 10pt (cards), 6pt (buttons), 16pt (large)
Sidebar Width: 240pt (200-300pt range)
```

## Performance Characteristics

### Resource Usage
| State | Memory | CPU |
|-------|--------|-----|
| Idle | ~30 MB | <1% |
| Browsing | ~50 MB | 2-5% |
| Syncing | ~80-150 MB | 5-15% |
| Multiple tasks | ~200 MB | 10-20% |

### Responsiveness
- **UI Updates**: 60 FPS (SwiftUI)
- **File Detection**: <500ms (FSEvents)
- **List Loading**: <1s for 1000 files
- **Search**: Instant (local filter)

## Security Model

### Credential Storage
- **Keychain** — Encryption passwords, OAuth tokens
- **rclone Config** — Cloud provider credentials (encrypted)
- **UserDefaults** — Non-sensitive preferences

### Encryption Options
- **Transport** — HTTPS/TLS for all transfers
- **At Rest** — Provider-side encryption (varies)
- **E2E** — Optional rclone crypt layer

### Permissions
- **File System** — Full access (no sandbox)
- **Network** — Client connections
- **Keychain** — App-specific items only

## Roadmap

### v2.1 (Next Release)
- [ ] Drag & drop transfers
- [ ] System notifications
- [ ] Bandwidth throttling
- [ ] Exclude patterns UI
- [ ] Keyboard shortcuts

### v2.2
- [ ] Scheduled tasks (cron-style)
- [ ] Conflict resolution UI
- [ ] File versioning view
- [ ] Dark mode refinements

### v3.0
- [ ] Native cloud APIs (optional)
- [ ] iOS companion app
- [ ] Team collaboration
- [ ] Share links

## Comparison with Competitors

| Feature | CloudSync | OurClone | Mountain Duck |
|---------|-----------|----------|---------------|
| Price | Free | Paid | Paid |
| Open Source | Yes | No | No |
| Multi-Cloud | Yes (13+) | Yes (40+) | Yes |
| E2E Encryption | Yes | Yes | No |
| File Browser | Yes | Yes | Mount-based |
| Menu Bar | Yes | No | Yes |
| macOS Native | Yes | Electron? | Yes |

## Contributing

### Areas Needing Help
- [ ] Additional cloud provider testing
- [ ] UI/UX improvements
- [ ] Performance optimization
- [ ] Documentation
- [ ] Localization

### Code Style
- SwiftUI for all new UI
- MVVM architecture
- Async/await concurrency
- Comprehensive comments

---

**Project**: CloudSync  
**Version**: 2.0.0  
**Architecture**: MVVM + SwiftUI  
**Platform**: macOS 14.0+  
**License**: MIT  
**Last Updated**: January 2026
