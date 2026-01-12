# CloudSync Ultra - System Architecture

> **Maintained by:** Strategic Partner
> **Last Updated:** 2026-01-12
> **Version:** 2.0.3

---

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      CloudSync Ultra                            │
│                     macOS Application                           │
└─────────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
┌───────────────┐     ┌───────────────┐     ┌───────────────┐
│   SwiftUI     │     │   Managers    │     │   Services    │
│    Views      │     │   (Core)      │     │  (External)   │
└───────────────┘     └───────────────┘     └───────────────┘
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐     ┌───────────────┐     ┌───────────────┐
│ ViewModels    │     │ RcloneManager │     │   rclone      │
│ (State)       │     │ (Operations)  │     │  (Backend)    │
└───────────────┘     └───────────────┘     └───────────────┘
```

---

## Layer Breakdown

### UI Layer (Dev-1 Domain)

| Component | Purpose | Location |
|-----------|---------|----------|
| Views | SwiftUI screens | `CloudSyncApp/Views/` |
| ViewModels | State management | `CloudSyncApp/ViewModels/` |
| Components | Reusable UI pieces | `CloudSyncApp/Components/` |
| SettingsView | App configuration | `CloudSyncApp/SettingsView.swift` |

### Core Engine (Dev-2 Domain)

| Component | Purpose | Location |
|-----------|---------|----------|
| RcloneManager | rclone binary operations | `CloudSyncApp/RcloneManager.swift` |

**Note:** RcloneManager is 2,000+ lines. Handle with care.

### Services Layer (Dev-3 Domain)

| Component | Purpose | Location |
|-----------|---------|----------|
| SyncManager | Sync orchestration | `CloudSyncApp/SyncManager.swift` |
| ScheduleManager | Scheduled sync | `CloudSyncApp/ScheduleManager.swift` |
| EncryptionManager | E2E encryption | `CloudSyncApp/EncryptionManager.swift` |
| KeychainManager | Credential storage | `CloudSyncApp/KeychainManager.swift` |
| ProtonDriveManager | Proton Drive setup | `CloudSyncApp/ProtonDriveManager.swift` |
| Models | Data structures | `CloudSyncApp/Models/` |

---

## Data Flow

### File Transfer Flow

```
User Action (UI)
      │
      ▼
ViewModel.startTransfer()
      │
      ▼
RcloneManager.copyBetweenRemotes()
      │
      ├── Encryption check (EncryptionManager)
      │
      ▼
rclone process (external)
      │
      ▼
Progress callback
      │
      ▼
UI update (Published properties)
```

### Scheduled Sync Flow

```
App Launch
      │
      ▼
ScheduleManager.startScheduler()
      │
      ▼
Timer fires at scheduled time
      │
      ▼
ScheduleManager.executeSchedule()
      │
      ▼
TasksViewModel.startTask()
      │
      ▼
RcloneManager operations
      │
      ▼
Notification sent
```

---

## Key Design Decisions

### 1. Singleton Managers

All managers use singleton pattern for global access:
```swift
RcloneManager.shared
ScheduleManager.shared
EncryptionManager.shared
```

### 2. rclone as Backend

- All cloud operations go through rclone binary
- 42+ cloud providers supported
- No direct cloud API integration needed

### 3. Per-Remote Encryption

- Encryption configured per cloud remote
- Toggle at transfer time (source decrypt, dest encrypt)
- Keys stored in Keychain

### 4. UserDefaults for Preferences

- App settings in UserDefaults
- Schedules in UserDefaults (JSON encoded)
- Credentials in Keychain (secure)

---

## File Organization

```
CloudSyncApp/
├── CloudSyncAppApp.swift      # App entry point
├── ContentView.swift          # Main window
├── SettingsView.swift         # Settings tabs
│
├── Views/                     # UI screens
│   ├── DashboardView.swift
│   ├── TransferView.swift
│   ├── FileBrowserView.swift
│   ├── TasksView.swift
│   ├── HistoryView.swift
│   ├── ScheduleSettingsView.swift
│   └── ...
│
├── ViewModels/                # State management
│   ├── RemotesViewModel.swift
│   ├── TasksViewModel.swift
│   └── FileBrowserViewModel.swift
│
├── Models/                    # Data structures
│   ├── SyncTask.swift
│   ├── SyncSchedule.swift
│   ├── CloudProvider.swift
│   └── ...
│
├── RcloneManager.swift        # Core engine (2000+ lines)
├── SyncManager.swift          # Sync orchestration
├── ScheduleManager.swift      # Scheduling
├── EncryptionManager.swift    # Encryption
├── KeychainManager.swift      # Secure storage
└── ProtonDriveManager.swift   # Proton Drive
```

---

## Extension Points

When adding new features:

| Feature Type | Where to Add |
|--------------|--------------|
| New cloud provider | RcloneManager (rclone handles it) |
| New UI screen | Views/ + ViewModels/ |
| New sync mode | SyncManager + RcloneManager |
| New settings | SettingsView |
| Background task | ScheduleManager pattern |

---

## Constraints

1. **macOS only** - SwiftUI for macOS
2. **rclone dependency** - All cloud ops via rclone
3. **No server** - Fully local app
4. **Sandboxing** - May need entitlements for full disk access

---

*Architecture document maintained by Strategic Partner*
