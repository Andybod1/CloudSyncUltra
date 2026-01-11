# CloudSync Ultra v2.0

A powerful, native macOS cloud synchronization app built with SwiftUI. Manage all your cloud storage services from one beautiful interface.

![macOS](https://img.shields.io/badge/macOS-14.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Features

### 🌥️ Multi-Cloud Support
- **Proton Drive** - End-to-end encrypted cloud storage (with 2FA support)
- **Google Drive** - Full OAuth integration
- **Dropbox** - Seamless file sync
- **OneDrive** - Microsoft cloud integration
- **Amazon S3** - Object storage support
- **MEGA** - Encrypted cloud storage
- **Box, pCloud, WebDAV, SFTP, FTP** - And more!

### 📁 File Management
- **Dual-pane file browser** - Source and destination side-by-side
- **Drag & drop transfers** - Simply drag files between cloud services
- **Download/Upload** - Transfer files to/from local storage
- **Create folders** - Organize your cloud storage
- **Delete files/folders** - Clean up with confirmation dialogs
- **Search** - Find files quickly across any cloud

### 🔄 Sync & Transfer
- **Real-time progress bar** - Shows percentage, speed, and file count
- **Transfer modes** - Sync, Transfer, or Backup
- **Smart error handling** - Graceful handling of existing files
- **Cancel transfers** - Stop any operation mid-transfer

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

### 📋 Task Management
- **Scheduled syncs** - Set up recurring backup tasks
- **Task history** - View past operations
- **Status tracking** - Monitor active, pending, and completed tasks

## 🚀 Getting Started

### Requirements
- macOS 14.0 (Sonoma) or later
- Xcode 15.0 or later
- [rclone](https://rclone.org/) installed via Homebrew

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

| Provider | Auth Type | Status |
|----------|-----------|--------|
| Proton Drive | Username/Password + 2FA | ✅ Full Support |
| Google Drive | OAuth | ✅ Full Support |
| Dropbox | OAuth | ✅ Full Support |
| OneDrive | OAuth | ✅ Full Support |
| Amazon S3 | Access Keys | ✅ Full Support |
| MEGA | Username/Password | ✅ Full Support |
| Box | OAuth | ✅ Full Support |
| pCloud | Username/Password | ✅ Full Support |
| WebDAV | URL/Password | ✅ Full Support |
| SFTP | Host/Password | ✅ Full Support |
| FTP | Host/Password | ✅ Full Support |

## 🧪 Testing

The project includes a comprehensive unit test suite:

```bash
# Run tests via Xcode
⌘U

# Or via command line
xcodebuild test -project CloudSyncApp.xcodeproj -scheme CloudSyncApp
```

### Test Coverage
- **Models**: FileItem, CloudProvider, SyncTask
- **ViewModels**: FileBrowserViewModel, TasksViewModel, RemotesViewModel

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

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📧 Contact

Created by [@andybod1-lang](https://github.com/andybod1-lang)

---

**CloudSync Ultra** - One app. All your clouds. ☁️
