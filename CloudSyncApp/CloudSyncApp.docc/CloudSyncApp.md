# ``CloudSyncApp``

A powerful, native macOS cloud synchronization app built with SwiftUI.

## Overview

CloudSync Ultra is a comprehensive cloud storage management solution that supports 42+ cloud providers. It features a modern SwiftUI interface with dual-pane file transfers, scheduled syncs, end-to-end encryption, and professional error handling.

### Key Features

- **Multi-Cloud Support**: Connect to 42+ cloud storage providers including Google Drive, Dropbox, OneDrive, Amazon S3, and more
- **Dual-Pane Transfers**: Side-by-side file browser for easy drag-and-drop between clouds
- **End-to-End Encryption**: AES-256 client-side encryption with optional filename encryption
- **Scheduled Syncs**: Automated backup tasks with flexible scheduling
- **Real-Time Progress**: Live transfer progress with speed, file counts, and ETA

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:Architecture>

### Cloud Providers

- ``CloudProvider``
- ``CloudRemote``
- ``ProviderType``

### File Management

- ``FileItem``
- ``RemoteFile``
- ``FileBrowserViewModel``

### Sync & Transfer

- ``SyncTask``
- ``SyncManager``
- ``RcloneManager``
- ``TransferProgress``

### Scheduling

- ``SyncSchedule``
- ``ScheduleManager``

### Security

- ``EncryptionManager``
- ``KeychainManager``
- ``SecureString``

### Subscriptions

- ``SubscriptionTier``
- ``StoreKitManager``

### Error Handling

- ``TransferError``
- ``ErrorSeverity``

### UI Components

- ``AppTheme``
- ``MainWindow``
- ``DashboardView``
- ``TransferView``
