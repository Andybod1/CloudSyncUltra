# CloudSync Ultra 2.0 - Project Overview

## What is CloudSync Ultra?

CloudSync Ultra is a professional macOS application for cloud storage synchronization, inspired by industry-leading sync applications. It provides a modern, full-featured interface for managing 42+ cloud providers, transferring files between services, and keeping folders in sync with enterprise-grade features like end-to-end encryption and intelligent transfer optimization.

## Version 2.0.32 Highlights

### Evolution from MVP to Enterprise-Ready

| v1.0 (MVP) | v2.0.32 (Current) |
|------------|-------------------|
| Menu bar only | Full window + menu bar |
| Single view | Multi-view navigation |
| Proton Drive only | **42+ cloud providers** |
| Basic sync | Transfer, Sync, Backup modes |
| Simple status | Dashboard with real-time stats |
| No file browser | Dual-pane browser with drag & drop |
| Basic transfers | **Smart optimization per provider** |
| No preview | **Transfer Preview with dry-run** |
| Manual only | **Scheduled sync support** |
| No shortcuts | **Quick Actions (Cmd+Shift+N)** |

### New User Interface

```
┌─────────────────────────────────────────────────────────────┐
│  CloudSync Ultra                                    ─ □ ×     │
├─────────────┬───────────────────────────────────────────────┤
│             │                                               │
│  Dashboard  │   Welcome to CloudSync Ultra                  │
│  Transfer   │   ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐            │
│  Schedules  │   │ 42  │ │  3  │ │  0  │ │ 156 │            │
│  Tasks      │   │cloud│ │ run │ │ que │ │done │            │
│  History    │   └─────┘ └─────┘ └─────┘ └─────┘            │
│             │                                               │
│ ─────────── │   Connected Services                          │
│ CLOUD       │   ┌──────────┐ ┌──────────┐ ┌──────────┐     │
│  Proton ✓   │   │ Proton   │ │ Google   │ │ Dropbox  │     │
│  Google ✓   │   │ Drive    │ │ Drive    │ │  150GB   │     │
│  Dropbox ✓  │   │  25GB    │ │  12GB    │ └──────────┘     │
│  S3 ✓       │   └──────────┘ └──────────┘                  │
│  + Add...   │                                               │
│             │   Recent Activity                             │
│ LOCAL       │   • Transfer completed - 2 min ago (1.2GB)    │
│  Storage    │   • Scheduled sync ran - 15 min ago           │
│             │   • 150 files uploaded to S3 - 1 hour ago    │
│ ─────────── │                                               │
│  Settings   │  Press Cmd+Shift+N for Quick Actions          │
│             │                                               │
└─────────────┴───────────────────────────────────────────────┘
```

## Key Features

### 🎯 Dashboard
- **Real-time Stats** — Connected services, active tasks, queue depth, completion count
- **Service Cards** — Visual grid showing storage usage per provider
- **Recent Activity** — Last 5 operations with file counts and sizes
- **Quick Actions Hint** — Discover keyboard productivity features

### 🚀 Quick Actions Menu (NEW in v2.0.22)
- **Keyboard Shortcut** — Cmd+Shift+N opens from anywhere
- **Fast Operations** — Add cloud, quick transfer, new folder, schedule sync
- **Search-driven** — Type to filter available actions
- **Context-aware** — Shows relevant actions based on current view

### 📁 Dual-Pane Transfer
- **Side-by-Side Browsers** — Source and destination with independent navigation
- **Drag & Drop** — Natural file transfers between clouds
- **Transfer Preview** — See what will be transferred before starting (NEW!)
- **Multiple Modes** — Transfer, Sync, or Backup
- **Provider Optimization** — Automatic chunk size and parallelism tuning

### 🔄 Transfer Preview (NEW in v2.0.22)
- **Dry-Run Support** — Preview operations without transferring
- **Operation Summary** — Shows new files, updates, deletes
- **Size Calculations** — Total transfer size before starting
- **Conflict Detection** — Identifies potential overwrites

### ⚡ Provider-Specific Optimization (NEW in v2.0.22)
- **Google Drive** — 128MB chunks, 8 parallel transfers, fast-list enabled
- **Dropbox** — 150MB chunks, 4 parallel transfers, batch operations
- **OneDrive** — 10MB chunks, 4 parallel transfers, drive type aware
- **S3** — 5MB chunks, 16 parallel transfers, multi-part uploads
- **B2** — 96MB chunks, 10 parallel transfers, large file support
- **Dynamic Tuning** — Adapts based on file sizes and network conditions

### 📋 Task Management
- **Live Progress** — Real-time percentage, speed, ETA, file counts
- **Task Queue** — Create multiple jobs, execute in order
- **Recently Completed** — Quick view of finished transfers
- **Error Details** — Clear messages with retry options
- **Background Execution** — Transfers continue when minimized

### 🕐 Scheduled Sync
- **Flexible Scheduling** — Hourly, daily, weekly, or custom
- **Multiple Schedules** — Different sync pairs on different schedules
- **Encryption Support** — Per-schedule encryption settings
- **Run Now** — Manual trigger for any schedule
- **Next Sync Display** — Shows countdown in menu bar

### 📜 History
- **Complete Archive** — All transfers with metadata
- **Search & Filter** — Find by name, date, status
- **Transfer Metrics** — Speed, duration, file counts
- **Export Support** — CSV export for reporting

### 🔒 Security & Encryption
- **Per-Remote Encryption** — Each cloud can have its own encryption
- **AES-256 Standard** — Industry-standard encryption
- **Password Protection** — Keychain-secured passwords
- **Zero-Knowledge** — Files encrypted before cloud upload
- **Secure Credentials** — OAuth tokens in Keychain

### 🌐 42+ Cloud Providers

#### Major Providers (11)
Proton Drive, Google Drive, Dropbox, OneDrive, Amazon S3, MEGA, Box, pCloud, iCloud Drive, Backblaze B2, Google Cloud Storage

#### Enterprise Services (6)
Azure Blob, Azure Files, OneDrive Business, SharePoint, Alibaba Cloud OSS, Oracle Cloud

#### Object Storage (7)
Wasabi, DigitalOcean Spaces, Cloudflare R2, Scaleway, Storj, Filebase, IDrive e2

#### Privacy-Focused (3)
Tresorit, pCloud Crypto, Icedrive

#### Self-Hosted (6)
Nextcloud, ownCloud, Seafile, WebDAV, SFTP, FTP

#### Regional/Specialized (9)
Yandex Disk, Mail.ru Cloud, Jottacloud, Koofr, HiDrive, 1fichier, Uptobox, Google Photos, Flickr

## Technology Stack

### Languages & Frameworks
- **Swift 5.9+** — Modern, safe, performant
- **SwiftUI** — Declarative UI with latest features
- **Combine** — Reactive state management
- **AppKit** — Menu bar and system integration
- **async/await** — Modern concurrency throughout

### Architecture
- **MVVM** — Clean separation of concerns
- **Dependency Injection** — Via environment objects
- **Singleton Managers** — For global state
- **Protocol-Oriented** — Extensible design

### External Dependencies
- **rclone** — Battle-tested sync engine
- **Keychain Services** — Secure credential storage

### Quality Assurance
- **841 Automated Tests** — Comprehensive coverage
- **CI/CD Pipeline** — GitHub Actions integration
- **Pre-commit Hooks** — Quality gates
- **Test Categories** — Unit, Integration, UI

## File Structure

```
CloudSyncApp/
├── CloudSyncAppApp.swift          # App entry, scenes
├── Models/
│   ├── CloudProvider.swift        # 42 provider definitions
│   ├── SyncTask.swift             # Task model with error handling
│   ├── FileItem.swift             # File/folder representation
│   ├── TransferError.swift        # Comprehensive error types
│   ├── TransferPreview.swift      # Dry-run preview model
│   ├── ChunkSizeConfig.swift      # Provider optimization
│   └── SyncSchedule.swift         # Schedule definitions
├── ViewModels/
│   ├── RemotesViewModel.swift     # Cloud connections
│   ├── TasksViewModel.swift       # Task queue management
│   ├── FileBrowserViewModel.swift # File navigation
│   ├── OnboardingViewModel.swift  # First-run experience
│   └── ScheduleManager.swift      # Schedule execution
├── Views/
│   ├── MainWindow.swift           # App structure
│   ├── DashboardView.swift        # Home/overview
│   ├── TransferView.swift         # Dual-pane transfer
│   ├── TasksView.swift            # Active & completed
│   ├── SchedulesView.swift        # Schedule management
│   ├── HistoryView.swift          # Transfer archive
│   ├── FileBrowserView.swift      # Single-pane browser
│   ├── QuickActionsView.swift     # Cmd+Shift+N menu
│   └── OnboardingView/            # 4-step wizard
├── Managers/
│   ├── RcloneManager.swift        # rclone interface
│   ├── SyncManager.swift          # Sync orchestration
│   ├── EncryptionManager.swift    # E2E encryption
│   ├── TransferOptimizer.swift    # Performance tuning
│   ├── CrashReportingManager.swift # Privacy-first crashes
│   └── NotificationManager.swift  # User notifications
├── Components/
│   ├── ProviderIconView.swift     # Provider branding
│   ├── ErrorBanner.swift          # Error notifications
│   └── TaskCard.swift             # Task display
├── Styles/
│   ├── AppTheme.swift             # Design system
│   ├── ButtonStyles.swift         # Consistent buttons
│   └── CardStyles.swift           # Card appearances
└── StatusBarController.swift      # Menu bar integration
```

**Total Lines**: ~12,000+ Swift code
**Test Coverage**: ~75% across critical paths
**Components**: 50+ SwiftUI views

## User Workflows

### First-Time Setup
1. Launch → Onboarding wizard appears
2. Welcome → Add first cloud → First transfer → Tips
3. Skip available for experienced users
4. Dashboard shows with connected cloud

### Quick Transfer (Cmd+Shift+N)
1. Press Cmd+Shift+N from anywhere
2. Type "transfer" or select from list
3. Pick source and destination
4. Select files → Start transfer
5. Monitor in Tasks view

### Scheduled Backup
1. Go to Schedules → New Schedule
2. Name it (e.g., "Daily Backup")
3. Select source cloud and folder
4. Select destination and folder
5. Choose frequency and time
6. Enable schedule → Auto-executes

### Encrypted Archive
1. Add cloud service (e.g., B2)
2. Enable encryption for that remote
3. Set strong password (saved in Keychain)
4. All uploads to that remote are encrypted
5. Downloads auto-decrypt with password

## Performance Characteristics

### Transfer Speeds
| Provider | Chunk Size | Parallel | Typical Speed |
|----------|------------|----------|---------------|
| Google Drive | 128MB | 8 | 50-100 MB/s |
| Dropbox | 150MB | 4 | 30-60 MB/s |
| S3 | 5MB | 16 | 100-200 MB/s |
| OneDrive | 10MB | 4 | 20-40 MB/s |
| Proton | 16MB | 2 | 10-20 MB/s |

### Resource Usage
| State | Memory | CPU | Network |
|-------|--------|-----|---------|
| Idle | ~50MB | <1% | None |
| Browsing | ~80MB | 2-5% | Minimal |
| Transferring | ~150-300MB | 10-30% | Max available |
| Multiple tasks | ~400MB | 20-40% | Throttled if set |

### UI Responsiveness
- **60 FPS** — Smooth SwiftUI animations
- **<100ms** — Button response time
- **<1s** — File list loading (1000 files)
- **Real-time** — Progress updates

## Security Model

### Defense in Depth
1. **Authentication** — OAuth 2.0, API keys, passwords
2. **Transport** — HTTPS/TLS for all connections
3. **Storage** — Keychain for sensitive data
4. **Encryption** — Optional E2E with AES-256
5. **Validation** — Path sanitization, input limits

### Privacy First
- **No Analytics** — Zero tracking or telemetry
- **Local Only** — All data stays on device
- **Crash Reports** — Local storage, user controls
- **Open Source** — Full transparency

## Testing Strategy

### 841 Automated Tests
- **Models** — CloudProvider, FileItem, TransferError (150+ tests)
- **ViewModels** — State management, business logic (200+ tests)
- **Managers** — RcloneManager, TransferOptimizer (250+ tests)
- **Integration** — End-to-end workflows (100+ tests)
- **UI Tests** — User interaction flows (69 tests)
- **New Features** — ChunkSize, TransferPreview (50+ tests)

### Continuous Integration
- **GitHub Actions** — Build and test on push
- **Pre-commit Hooks** — Local quality gates
- **Test Recording** — Track test count over time
- **Coverage Goals** — 80%+ for critical paths

## Roadmap

### v2.1 (Next Minor)
- [ ] Advanced filtering and search
- [ ] Bandwidth scheduling (different limits by time)
- [ ] Folder watching for auto-upload
- [ ] Custom rclone flags UI
- [ ] Transfer templates

### v2.2
- [ ] Team folders with permissions
- [ ] Sync conflict resolution UI
- [ ] File versioning interface
- [ ] Advanced logging options
- [ ] Plugin system for custom providers

### v3.0 (Next Major)
- [ ] iOS companion app
- [ ] CloudKit sync between devices
- [ ] Native provider APIs (bypass rclone)
- [ ] ML-powered smart sync
- [ ] Collaboration features

## Competitive Analysis

| Feature | CloudSync Ultra | Competitors | Our Advantage |
|---------|-----------------|-------------|---------------|
| Providers | 42+ | 10-40 | Most comprehensive |
| Price | Free/$29 | $50-200/yr | One-time purchase |
| Platform | Native macOS | Electron/Web | Better performance |
| Encryption | Per-remote | Global only | More flexible |
| Quick Actions | Cmd+Shift+N | None | Productivity boost |
| Transfer Preview | Yes | Rare | Confidence in operations |
| Open Source | Yes | Mixed | Full transparency |

## Success Metrics

### App Quality
- **841 tests** passing (99.8% pass rate)
- **<0.1% crash rate** in production
- **4.8/5 stars** target App Store rating
- **<2s launch time** on M1 Macs

### User Satisfaction
- **10-minute onboarding** from install to first transfer
- **Zero support tickets** for basic operations
- **Power user features** for advanced needs
- **Keyboard-first** productivity

## Contributing

### Getting Started
1. Fork the repository
2. Clone and build locally
3. Run the 841 test suite
4. Make changes with tests
5. Submit PR with description

### Areas of Focus
- **Provider Testing** — Verify all 42 providers
- **Performance** — Optimize for large files/folders
- **Accessibility** — VoiceOver improvements
- **Documentation** — Guides and tutorials
- **Localization** — Multi-language support

### Code Standards
- SwiftUI for all UI
- Async/await for async operations
- MVVM architecture
- 80% test coverage for new code
- Clear commit messages

---

**Project**: CloudSync Ultra
**Version**: 2.0.25
**Released**: January 15, 2026
**Architecture**: MVVM + SwiftUI
**Platform**: macOS 14.0+
**License**: MIT
**Tests**: 841 (99.8% passing)

*One app. All your clouds. Perfectly optimized.* ☁️