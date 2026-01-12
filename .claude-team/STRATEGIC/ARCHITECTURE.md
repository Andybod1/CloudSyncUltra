# CloudSync Ultra - Architecture

> Maintained by: Strategic Partner
> Last Updated: 2026-01-12

---

## System Overview

CloudSync Ultra is a macOS cloud synchronization application built with SwiftUI, using rclone as the backend for cloud operations.

```
┌─────────────────────────────────────────────────────────────────┐
│                         CloudSync Ultra                          │
├─────────────────────────────────────────────────────────────────┤
│  UI Layer (SwiftUI)                                              │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐   │
│  │Dashboard│ │FileBrows│ │Transfer │ │Settings │ │ MenuBar │   │
│  └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘   │
├───────┴───────────┴───────────┴───────────┴───────────┴─────────┤
│  ViewModels                                                      │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐             │
│  │TasksViewModel│ │RemotesViewMdl│ │FileBrowserVM │             │
│  └──────┬───────┘ └──────┬───────┘ └──────┬───────┘             │
├─────────┴────────────────┴────────────────┴─────────────────────┤
│  Services Layer                                                  │
│  ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────────┐   │
│  │SyncManager │ │ScheduleMgr │ │EncryptMgr  │ │KeychainMgr │   │
│  └─────┬──────┘ └─────┬──────┘ └─────┬──────┘ └─────┬──────┘   │
├────────┴──────────────┴──────────────┴──────────────┴───────────┤
│  Core Engine                                                     │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                     RcloneManager                         │   │
│  │  • Process execution    • Config management               │   │
│  │  • Progress parsing     • Remote operations               │   │
│  └──────────────────────────┬───────────────────────────────┘   │
├─────────────────────────────┴───────────────────────────────────┤
│  External                                                        │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐                        │
│  │  rclone  │ │ Keychain │ │FS Events │                        │
│  └──────────┘ └──────────┘ └──────────┘                        │
└─────────────────────────────────────────────────────────────────┘
```

---

## Layer Responsibilities

### UI Layer (Dev-1)
- SwiftUI views and components
- User interaction handling
- Visual feedback and animations
- Accessibility

### ViewModels (Dev-1)
- State management
- Business logic for views
- Data transformation for display

### Services Layer (Dev-3)
- Domain-specific logic
- Data models
- Persistence
- Encryption/security

### Core Engine (Dev-2)
- rclone process management
- Command construction
- Output parsing
- Error handling

---

## Key Components

### RcloneManager (Singleton)
**Location:** `CloudSyncApp/RcloneManager.swift`
**Lines:** ~2,060
**Owner:** Dev-2

Responsibilities:
- Execute rclone commands
- Parse progress output
- Manage cloud provider configs
- Handle OAuth flows
- Cloud-to-cloud transfers

### ScheduleManager (Singleton)
**Location:** `CloudSyncApp/ScheduleManager.swift`
**Owner:** Dev-3

Responsibilities:
- Manage scheduled sync jobs
- Timer-based execution
- Persistence to UserDefaults
- Notifications on completion

### EncryptionManager (Singleton)
**Location:** `CloudSyncApp/EncryptionManager.swift`
**Owner:** Dev-3

Responsibilities:
- Per-remote encryption configuration
- Password management via Keychain
- Encryption toggle state

### TasksViewModel (Singleton)
**Location:** `CloudSyncApp/ViewModels/TasksViewModel.swift`
**Owner:** Dev-1

Responsibilities:
- Manage sync tasks queue
- Track task history
- Execute tasks via RcloneManager

---

## Data Models

### SyncTask
```swift
struct SyncTask: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: TaskType  // .sync, .transfer, .backup
    var sourceRemote: String
    var sourcePath: String
    var destinationRemote: String
    var destinationPath: String
    var state: TaskState
    var progress: Double
    // ...
}
```

### SyncSchedule
```swift
struct SyncSchedule: Identifiable, Codable {
    let id: UUID
    var name: String
    var isEnabled: Bool
    var frequency: ScheduleFrequency
    var sourceRemote: String
    var destinationRemote: String
    // ...
}
```

### CloudRemote
```swift
struct CloudRemote: Identifiable {
    let id: UUID
    var name: String
    var type: CloudProvider
    var isConnected: Bool
    // ...
}
```

---

## Data Flow

### Sync Execution
```
User clicks "Sync"
       │
       ▼
TasksViewModel.startTask()
       │
       ▼
RcloneManager.syncBetweenRemotes()
       │
       ├──▶ Build rclone command
       │
       ├──▶ Execute Process
       │
       ├──▶ Parse stdout for progress
       │
       └──▶ Update task.progress
              │
              ▼
       UI observes @Published
              │
              ▼
       Progress bar updates
```

### Scheduled Sync
```
ScheduleManager.startScheduler()
       │
       ▼
Timer fires at nextRunAt
       │
       ▼
ScheduleManager.executeSchedule()
       │
       ▼
Creates SyncTask
       │
       ▼
TasksViewModel.startTask()
       │
       ▼
[Same as manual sync]
```

---

## Persistence

| Data | Storage | Location |
|------|---------|----------|
| Tasks | UserDefaults | `syncTasks` key |
| Schedules | UserDefaults | `syncSchedules` key |
| Remotes | rclone config | `~/.config/rclone/rclone.conf` |
| Credentials | Keychain | CloudSync Ultra keychain |
| Encryption keys | Keychain | Per-remote passwords |

---

## Security

1. **Keychain Storage** - All credentials stored in macOS Keychain
2. **Per-Remote Encryption** - Optional client-side encryption
3. **No Plain Text** - Passwords never stored in UserDefaults
4. **Sandboxed** - App runs in macOS sandbox

---

## Future Architecture Considerations

### Planned
- [ ] Delta sync for large files
- [ ] Conflict resolution UI
- [ ] Real-time file watching (FSEvents)

### Technical Debt
- [ ] RcloneManager refactor (split into smaller managers)
- [ ] CI/CD pipeline
- [ ] Integration test suite

---

## Development Architecture

### Two-Tier Parallel System
```
Strategic Partner (Desktop Opus)
       │
       │ DIRECTIVE.md
       ▼
Lead Agent (CLI Opus)
       │
       ├──▶ Dev-1 (UI)
       ├──▶ Dev-2 (Engine)
       ├──▶ Dev-3 (Services)
       └──▶ QA (Tests)
```

### File Ownership
- **Dev-1:** Views/, ViewModels/, Components/
- **Dev-2:** RcloneManager.swift
- **Dev-3:** Models/, *Manager.swift (except Rclone)
- **QA:** CloudSyncAppTests/

---

*This document is updated by Strategic Partner when architecture decisions are made.*
