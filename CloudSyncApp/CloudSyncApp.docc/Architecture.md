# Architecture

Understand the structure and design of CloudSync Ultra.

## Overview

CloudSync Ultra follows the MVVM (Model-View-ViewModel) architecture pattern with a service layer for backend operations.

### Project Structure

```
CloudSyncApp/
├── Models/              # Data structures and business logic
├── ViewModels/          # State management and UI logic
├── Views/               # SwiftUI views and components
├── Managers/            # Service layer (singleton managers)
├── Components/          # Reusable UI components
└── Styles/              # Theme and styling
```

### Core Components

#### Models

The Models layer contains data structures that represent the app's domain:

- ``CloudProvider`` - Defines supported cloud services and their capabilities
- ``SyncTask`` - Represents a sync operation with source, destination, and options
- ``FileItem`` - Represents a file or folder in the file browser
- ``TransferError`` - Structured error handling with severity levels

#### ViewModels

ViewModels manage state and business logic for views:

- ``FileBrowserViewModel`` - File listing, navigation, and operations
- ``TasksViewModel`` - Task execution and progress tracking
- ``RemotesViewModel`` - Connected cloud services management
- ``OnboardingViewModel`` - First-launch wizard state

#### Managers (Service Layer)

Singleton managers provide app-wide services:

- ``RcloneManager`` - Wraps rclone CLI for all cloud operations
- ``SyncManager`` - Orchestrates sync tasks and manages queues
- ``EncryptionManager`` - Client-side encryption with rclone crypt
- ``ScheduleManager`` - Scheduled task execution
- ``StoreKitManager`` - In-app purchases and subscriptions

### Data Flow

```
User Action → View → ViewModel → Manager → rclone → Cloud Provider
                ↑                    ↓
                └──── State Update ──┘
```

1. User interacts with a SwiftUI View
2. View calls ViewModel methods
3. ViewModel delegates to appropriate Manager
4. Manager executes rclone commands
5. Results flow back through Combine publishers
6. ViewModel updates @Published properties
7. SwiftUI automatically re-renders

### Key Design Decisions

#### rclone as Backend

CloudSync Ultra uses rclone as its cloud storage backend rather than implementing provider APIs directly. This provides:

- Support for 40+ providers out of the box
- Proven, battle-tested file transfer logic
- Encryption, chunking, and retry handling
- Regular updates from the rclone community

#### Client-Side Encryption

Encryption is implemented using rclone's crypt backend:

- AES-256 encryption
- Optional filename obfuscation
- Zero-knowledge design (keys never leave device)
- Per-remote encryption configuration

## See Also

- <doc:GettingStarted>
- ``RcloneManager``
- ``SyncManager``
