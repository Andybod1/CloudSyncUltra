# CloudSync 2.0 - File Listing

Complete file structure with descriptions.

## Project Structure

```
CloudSyncApp/
├── CloudSyncApp.xcodeproj/         # Xcode project
│   └── project.pbxproj             # Project configuration
│
├── CloudSyncApp/                   # Source code
│   │
│   ├── CloudSyncAppApp.swift       # App entry point
│   │   - @main struct
│   │   - WindowGroup (main window)
│   │   - Settings scene
│   │   - AppDelegate for menu bar
│   │
│   ├── Models/                     # Data models
│   │   ├── CloudProvider.swift     # Cloud service definitions
│   │   │   - CloudProviderType enum (13 providers)
│   │   │   - CloudRemote struct
│   │   │   - FileItem struct
│   │   │
│   │   ├── SyncTask.swift          # Task/job model
│   │   │   - TaskType enum
│   │   │   - TaskState enum
│   │   │   - SyncTask struct
│   │   │   - TaskLog struct
│   │   │
│   │   └── AppTheme.swift          # Design system
│   │       - AppColors
│   │       - AppDimensions
│   │       - View modifiers
│   │       - Button styles
│   │
│   ├── ViewModels/                 # State management
│   │   ├── RemotesViewModel.swift  # Cloud connections
│   │   │   - remotes: [CloudRemote]
│   │   │   - CRUD operations
│   │   │   - Persistence
│   │   │
│   │   ├── TasksViewModel.swift    # Job queue
│   │   │   - tasks: [SyncTask]
│   │   │   - taskHistory: [SyncTask]
│   │   │   - Start/pause/cancel
│   │   │
│   │   └── FileBrowserViewModel.swift # File navigation
│   │       - files: [FileItem]
│   │       - Navigation methods
│   │       - Search & sort
│   │
│   ├── Views/                      # UI views
│   │   ├── MainWindow.swift        # Main app structure
│   │   │   - NavigationSplitView
│   │   │   - SidebarView
│   │   │   - AddRemoteSheet
│   │   │   - ProviderCard
│   │   │
│   │   ├── DashboardView.swift     # Overview dashboard
│   │   │   - Stats cards
│   │   │   - Connected services
│   │   │   - Recent activity
│   │   │   - Quick actions
│   │   │
│   │   ├── TransferView.swift      # Dual-pane transfer
│   │   │   - FileBrowserPane
│   │   │   - BreadcrumbBar
│   │   │   - FileRow
│   │   │   - Transfer controls
│   │   │
│   │   ├── TasksView.swift         # Task management
│   │   │   - TaskCard
│   │   │   - StatusBadge
│   │   │   - NewTaskSheet
│   │   │   - TaskDetailSheet
│   │   │
│   │   ├── HistoryView.swift       # Activity log
│   │   │   - Grouped by date
│   │   │   - Search & filter
│   │   │   - HistoryRow
│   │   │
│   │   └── FileBrowserView.swift   # Full file browser
│   │       - Toolbar
│   │       - List/Grid views
│   │       - FileGridItem
│   │       - NewFolderSheet
│   │
│   ├── Components/                 # Reusable components
│   │   └── (empty - future use)
│   │
│   ├── RcloneManager.swift         # rclone interface
│   │   - Process management
│   │   - Config management
│   │   - Progress parsing
│   │   - Encryption setup
│   │
│   ├── SyncManager.swift           # Sync orchestration
│   │   - File monitoring (FSEvents)
│   │   - Auto-sync timer
│   │   - State management
│   │   - Encryption config
│   │
│   ├── EncryptionManager.swift     # E2E encryption
│   │   - Keychain operations
│   │   - Password management
│   │   - Salt generation
│   │
│   ├── StatusBarController.swift   # Menu bar
│   │   - Status icon
│   │   - Menu items
│   │   - Quick actions
│   │
│   ├── SettingsView.swift          # Preferences
│   │   - GeneralSettingsView
│   │   - AccountSettingsView
│   │   - EncryptionSettingsView
│   │   - SyncSettingsView
│   │   - AboutView
│   │
│   ├── ContentView.swift           # Placeholder (legacy)
│   │
│   ├── Assets.xcassets/            # App assets
│   │   └── AppIcon.appiconset/     # App icon
│   │
│   ├── Info.plist                  # App metadata
│   │
│   └── CloudSyncApp.entitlements   # Permissions
│
├── README.md                       # Main documentation
├── DEVELOPMENT.md                  # Developer guide
├── PROJECT_OVERVIEW.md             # Project summary
├── SETUP.md                        # Setup instructions
├── QUICKSTART.md                   # Quick reference
├── FILE_LISTING.md                 # This file
│
├── build.sh                        # Build script
└── install.sh                      # Install script
```

## File Counts

| Category | Files | Lines (approx) |
|----------|-------|----------------|
| Models | 3 | ~350 |
| ViewModels | 3 | ~400 |
| Views | 6 | ~1500 |
| Managers | 4 | ~700 |
| Settings | 1 | ~450 |
| **Total Swift** | **17** | **~3400** |
| Documentation | 6 | ~2000 |

## Key Files by Function

### Entry Points
- `CloudSyncAppApp.swift` — App launch, scenes, delegate

### Data Layer
- `CloudProvider.swift` — Provider definitions, file models
- `SyncTask.swift` — Task/job models

### State Management
- `RemotesViewModel.swift` — Cloud connections
- `TasksViewModel.swift` — Job queue
- `FileBrowserViewModel.swift` — File lists

### UI Layer
- `MainWindow.swift` — App shell, navigation
- `DashboardView.swift` — Home screen
- `TransferView.swift` — File transfer
- `TasksView.swift` — Job management
- `HistoryView.swift` — Activity log
- `FileBrowserView.swift` — File browser

### Business Logic
- `SyncManager.swift` — Sync orchestration
- `RcloneManager.swift` — rclone wrapper
- `EncryptionManager.swift` — Encryption

### System Integration
- `StatusBarController.swift` — Menu bar
- `SettingsView.swift` — Preferences

### Design
- `AppTheme.swift` — Colors, dimensions, styles

---

**Version**: 2.0.0  
**Last Updated**: January 2026
