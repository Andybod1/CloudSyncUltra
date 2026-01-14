# CloudSync Ultra v2.0

A powerful, native macOS cloud synchronization app built with SwiftUI. Manage all your cloud storage services from one beautiful interface.

![Build](https://github.com/andybod1-lang/CloudSyncUltra/actions/workflows/test.yml/badge.svg)
![macOS](https://img.shields.io/badge/macOS-14.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Features

### 🌥️ Multi-Cloud Support (40+ Providers)

**Core Providers (13):**  
Proton Drive, Google Drive, Dropbox, OneDrive, Amazon S3, MEGA, Box, pCloud, WebDAV, SFTP, FTP, iCloud (planned), Local Storage

**Enterprise Services (6):**  
Google Cloud Storage, Azure Blob, Azure Files, OneDrive Business, SharePoint, Alibaba Cloud OSS

**Object Storage (8):**  
Backblaze B2, Wasabi, DigitalOcean Spaces, Cloudflare R2, Scaleway, Oracle Cloud, Storj, Filebase

**Self-Hosted & International (6):**  
Nextcloud, ownCloud, Seafile, Koofr, Yandex Disk, Mail.ru Cloud

**Additional Services (9):**  
Jottacloud, Google Photos, Flickr, SugarSync, OpenDrive, Put.io, Premiumize.me, Quatrix, File Fabric

*See `CloudProvider.swift` for complete implementation details of all 42 providers*

### 📁 File Management
- **Dual-pane file browser** - Source and destination side-by-side
- **Drag & drop transfers** - Simply drag files between cloud services
- **Context menus** - Right-click for New Folder, Rename, Download, Delete
- **List and Grid views** - Choose your preferred file display
- **Download/Upload** - Transfer files to/from local storage
- **Create folders** - Organize your cloud storage with quick-access buttons
- **Delete files/folders** - Clean up with confirmation dialogs
- **Rename files** - Rename any file or folder
- **Search** - Find files quickly across any cloud

### 🔄 Sync & Transfer
- **Real-time progress tracking** - Shows percentage, speed (MB/s), and file count
- **Accurate file counters** - See exact progress (e.g., 100/100 files)
- **Transfer modes** - Sync, Transfer, or Backup
- **Cloud-to-cloud transfers** - Direct transfers between any cloud providers
- **Local-to-cloud and cloud-to-local** - Full bidirectional support
- **Professional error handling** - Clear error messages with retry options
- **Partial success tracking** - See which files succeeded when some fail
- **Cancel transfers** - Stop any operation mid-transfer
- **Transfer history** - View all past transfers with speeds and file counts
- **Bandwidth throttling** - Control upload/download speeds to avoid saturating your connection
- **Optimized performance** - Parallel transfers for faster multi-file operations

### 🚨 Error Handling (NEW in v2.0.11)
- **Clear error messages** - User-friendly explanations instead of technical jargon
- **Actionable guidance** - Know exactly what to do when errors occur
- **Smart retry logic** - Retry button appears only for retryable errors
- **Severity levels** - Visual distinction between critical and recoverable errors
- **Error details** - Full context available for troubleshooting
- **Auto-dismiss** - Non-critical notifications disappear after 10 seconds
- **Multi-error support** - Handle multiple errors gracefully
- **Provider-specific patterns** - Recognizes Google Drive, Dropbox, OneDrive, S3 error types
- **Partial failure tracking** - "15 of 20 files uploaded" with clear error indication

### 🔐 Security
- **End-to-end encryption** - Optional client-side encryption
- **Export/Import config** - Backup your rclone configuration
- **Zero-knowledge encryption** - AES-256 standard

### 🎨 Modern UI
- **Native macOS design** - Feels right at home on your Mac
- **Dark mode support** - Beautiful in any lighting
- **Menu bar icon** - Quick access from anywhere
- **Dashboard** - Quick overview with stats and activity
- **Sidebar navigation** - Easy access to all cloud services
- **Vertical view switchers** - Compact, space-efficient UI controls
- **Right-click context menus** - Full macOS-style context menus throughout

### 📋 Task Management
- **Scheduled syncs** - Set up recurring backup tasks
- **Task history** - View past operations
- **Status tracking** - Monitor active, pending, and completed tasks

## 🚀 Getting Started

> **New in v2.0.11:** Comprehensive error handling system with clear user messages, smart retry logic, and professional error presentation. See [CHANGELOG.md](CHANGELOG.md) for all updates.

> **New in v2.0:** Complete SwiftUI redesign with dual-pane interface, 40+ cloud providers, and 173+ automated tests.

### Requirements
- macOS 14.0 (Sonoma) or later
- Xcode 15.0 or later (for building from source)
- [rclone](https://rclone.org/) installed via Homebrew
- Git (for cloning the repository)

### Installation

1. **Install rclone:**
   ```bash
   brew install rclone
   ```

2. **Clone the repository:**
   ```bash
   git clone https://github.com/andybod1-lang/CloudSyncUltra.git
   cd CloudSyncUltra
   ```

3. **Open in Xcode:**
   ```bash
   open CloudSyncApp.xcodeproj
   ```

4. **Build and run** (⌘R)

### First Launch

1. Launch CloudSync Ultra
2. Click on any cloud service in the sidebar
3. Click **"Connect Now"** to authenticate
4. Start browsing and transferring files!

## 📸 Screenshots

### Dashboard
The main dashboard shows connected services, recent activity, and quick stats.

### Transfer View
Dual-pane interface for easy drag-and-drop transfers between any cloud services.

### File Browser
Full-featured file browser with list/grid views, search, and context menus.

## 🏗️ Architecture

```
CloudSyncUltra/
├── CloudSyncApp/
│   ├── CloudSyncAppApp.swift    # App entry point
│   ├── Models/
│   │   ├── CloudProvider.swift  # Cloud service definitions
│   │   ├── SyncTask.swift       # Task management
│   │   └── AppTheme.swift       # Theme settings
│   ├── ViewModels/
│   │   ├── RemotesViewModel.swift    # Cloud connections
│   │   ├── TasksViewModel.swift      # Task management
│   │   └── FileBrowserViewModel.swift # File browsing
│   ├── Views/
│   │   ├── MainWindow.swift     # Main app window
│   │   ├── DashboardView.swift  # Dashboard
│   │   ├── TransferView.swift   # Dual-pane transfer
│   │   ├── FileBrowserView.swift # Single-pane browser
│   │   ├── TasksView.swift      # Task management
│   │   └── SettingsView.swift   # App settings
│   ├── RcloneManager.swift      # rclone integration
│   ├── SyncManager.swift        # Sync orchestration
│   └── StatusBarController.swift # Menu bar
├── CloudSyncAppTests/           # Unit tests
│   ├── FileItemTests.swift
│   ├── CloudProviderTests.swift
│   ├── SyncTaskTests.swift
│   ├── FileBrowserViewModelTests.swift
│   ├── TasksViewModelTests.swift
│   └── RemotesViewModelTests.swift
└── README.md
```

## 🔧 Configuration

CloudSync Ultra stores its configuration in:
- `~/Library/Application Support/CloudSyncApp/rclone.conf`

### Backup & Restore Config

1. Go to **Settings → Security**
2. Use **Export** to save your configuration
3. Use **Import** to restore from a backup

### Supported Cloud Providers

**Top Providers:**

| Provider | Auth Type | Status |
|----------|-----------|--------|
| Proton Drive | Username/Password + 2FA | ✅ Full Support |
| Google Drive | OAuth | ✅ Full Support |
| Dropbox | OAuth | ✅ Full Support |
| OneDrive | OAuth | ✅ Full Support |
| Amazon S3 | Access Keys | ✅ Full Support |
| MEGA | Username/Password | ✅ Full Support |
| Box | OAuth | ✅ Full Support |
| pCloud | OAuth | ✅ Full Support |
| Google Cloud Storage | OAuth/Service Account | ✅ Full Support |
| Azure Blob Storage | Account Key/SAS | ✅ Full Support |
| Backblaze B2 | Account ID/Key | ✅ Full Support |
| Nextcloud | WebDAV | ✅ Full Support |
| OneDrive Business | OAuth | ✅ Full Support |
| SharePoint | OAuth | ✅ Full Support |
| Jottacloud | Personal Token | ⚠️ Experimental |

**Plus 27 more providers** including WebDAV, SFTP, FTP, Wasabi, Cloudflare R2, DigitalOcean Spaces, Oracle Cloud, Storj, Seafile, Koofr, Yandex Disk, Mail.ru Cloud, Google Photos, Flickr, and more.

See `CloudProvider.swift` for the complete list of all 42 supported providers with implementation details.

## 🧪 Testing

The project includes comprehensive automated testing:

```bash
# Run tests via Xcode
⌘U

# Or via command line
xcodebuild test -project CloudSyncApp.xcodeproj -scheme CloudSyncApp
```

### Test Coverage
- **234+ automated tests** across unit, integration, and UI layers
- **100+ unit tests** covering models, view models, and managers
- **61 error handling tests** covering TransferError, SyncTask, and RcloneManager error scenarios
- **73 UI tests** for end-to-end user workflows (ready for integration)
- **Real-world scenario coverage** including edge cases and error handling
- **88%+ coverage** for error handling system

**Test Categories:**
- Models & Core Logic (FileItem, CloudProvider, SyncTask)
- Error Handling (TransferError, error detection, error display, retry logic)
- ViewModels & State Management (FileBrowserViewModel, TasksViewModel, RemotesViewModel)
- RcloneManager & Provider Integration (OAuth, Phase 1-3 providers)
- SyncManager & Orchestration
- Encryption & Security
- Bandwidth Throttling
- End-to-End Workflows

See `TEST_COVERAGE.md` for complete test inventory and coverage details.

## 🛠️ Development

### Building from Source

```bash
# Clone
git clone https://github.com/andybod1-lang/CloudSyncUltra.git
cd CloudSyncUltra

# Build
xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -configuration Release build

# Run
open ~/Library/Developer/Xcode/DerivedData/CloudSyncApp-*/Build/Products/Release/CloudSyncApp.app
```

### Tech Stack
- **SwiftUI** - Modern declarative UI
- **Combine** - Reactive data flow
- **rclone** - Cloud storage backend
- **async/await** - Modern concurrency

## 📝 License

MIT License - see [LICENSE](LICENSE) for details.

## Contributing

We welcome contributions from the community! Please read our [Contributing Guidelines](CONTRIBUTING.md) before submitting a pull request.

### Quick Start for Contributors

1. Fork the repository
2. Clone your fork and set up the development environment
3. Create a feature branch (`feature/your-feature-name`)
4. Make your changes and add tests
5. Ensure all 743+ tests pass
6. Submit a pull request

For detailed instructions on code style, testing, and the PR process, see [CONTRIBUTING.md](CONTRIBUTING.md).

### GitHub Project Board

All new issues are automatically added to the [CloudSync Ultra project board](https://github.com/users/andybod1-lang/projects/1) via GitHub Actions. This helps track and prioritize feature requests and bug reports.

## 📧 Contact

Created by [@andybod1-lang](https://github.com/andybod1-lang)

---

**CloudSync Ultra** - One app. All your clouds. ☁️
