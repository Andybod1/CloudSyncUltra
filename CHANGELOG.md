# Changelog

All notable changes to CloudSync Ultra will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.6] - 2026-01-12

### Added
- **GitHub Issues Ticket System** - Crash-proof work tracking
  - Issue templates for Bug Reports, Feature Requests, and Internal Tasks
  - 37 labels for status, priority, component, worker assignment, and sizing
  - Label-based workflow: triage → ready → in-progress → needs-review → closed
  - Dashboard script at `.github/dashboard.sh` for quick status overview
  - Complete workflow documentation in `.github/WORKFLOW.md`
  - All work state persists on GitHub, survives device/power failures

### Changed
- Updated PARALLEL_TEAM.md with GitHub Issues integration
- Updated PROJECT_CONTEXT.md with ticket system documentation
- Updated RECOVERY.md with GitHub Issues recovery steps

## [2.0.5] - 2026-01-12

### Changed
- **Move Schedules to Main Window** - Schedules now a primary sidebar item
  - Added "Schedules" to main window sidebar with calendar.badge.clock icon
  - Created new SchedulesView.swift for main window schedule management
  - Shows "Next Sync" indicator at top when schedules exist
  - Empty state with call-to-action when no schedules configured
  - Full edit/delete/enable/disable/run-now functionality preserved
  - Removed Schedules tab from Settings (now 4 tabs: General, Accounts, Sync, About)
  - Menu bar "Manage Schedules..." now opens main window to Schedules section

### Added
- **Recently Completed in Tasks View** - See completed transfers at a glance
  - Shows last 5 completed tasks from the past hour
  - Compact card design with status, transfer size, and time ago
  - "View All History" link to full History view
  - Tasks view now shows both Active and Recently Completed sections

### Added
- **Recently Completed in Tasks View** - See completed transfers at a glance
  - Shows last 5 completed tasks from the past hour
  - Compact card design with status, transfer size, and time ago
  - "View All History" link to full History view
  - Tasks view now shows both Active and Recently Completed sections

## [2.0.4] - 2026-01-12

### Added
- **Menu Bar Schedule Indicator** - See next scheduled sync at a glance
  - Shows "Next: [schedule name]" with countdown in menu bar popup
  - Displays "No scheduled syncs" when none configured
  - "Manage Schedules..." button opens main window to Schedules section
  - 11 new unit tests for schedule indicator logic

- **Two-Tier Parallel Development Architecture**
  - Strategic Partner (Desktop Opus) for planning and review
  - Lead Agent (CLI Opus) for task coordination and integration
  - 4 Workers (CLI Sonnet) for parallel execution
  - New documentation: PROJECT_CONTEXT.md, RECOVERY.md, QUICK_START.md

## [2.0.3] - 2026-01-12

### Added
- **Scheduled Sync Feature** - Automatic sync at specified times
  - Create schedules with hourly, daily, weekly, or custom intervals
  - Enable/disable schedules without deleting
  - Per-schedule encryption settings (source decrypt, destination encrypt)
  - Visual schedule list with next run time and last run status
  - Day picker for weekly schedules (weekdays, weekends, custom)
  - "Run Now" button for manual trigger
  - Notifications on schedule completion (success/failure)
  - Persistent schedules survive app restart

- **New Files:**
  - `SyncSchedule.swift` - Schedule data model with frequency, timing, encryption
  - `ScheduleManager.swift` - Singleton managing timers and execution
  - `ScheduleSettingsView.swift` - Settings tab UI for schedule management
  - `ScheduleRowView.swift` - Individual schedule display component
  - `ScheduleEditorSheet.swift` - Create/edit schedule form

- **Test Coverage:**
  - 32 new unit tests for scheduled sync feature
  - `SyncScheduleTests.swift` - Model tests
  - `ScheduleManagerTests.swift` - Manager logic tests
  - `ScheduleFrequencyTests.swift` - Enum tests

## [2.0.2] - 2026-01-12

### Added
- **Parallel Development Team System** - Multi-agent development infrastructure
  - 4-worker parallel execution (Dev-1 UI, Dev-2 Core, Dev-3 Services, QA)
  - Lead Claude (Opus 4.5) for architecture and coordination
  - Worker Claudes (Sonnet 4) via Claude Code CLI
  - Task coordination via `.claude-team/` folder structure
  - Real-time status tracking via STATUS.md
  - ~4x speedup on parallelizable development work

- **App Version Display** - Version info shown in SettingsView footer
- **Rclone Version Logging** - New `logRcloneVersion()` method for debugging
- **Keychain Accessibility Check** - New `isKeychainAccessible()` method
- **KeychainManager Tests** - 5 new unit tests for Keychain operations

### Documentation
- Added PARALLEL_TEAM.md - Complete guide to the parallel development system
- Added .claude-team/ infrastructure with briefings, templates, and scripts

## [2.0.1] - 2026-01-12

### Fixed
- **Local Storage encryption UI** - Removed encryption lock icons and toggles from Local Storage items since encryption only applies to cloud remotes
  - Sidebar no longer shows lock icons for Local Storage
  - FileBrowserView hides encryption toggle, banner, and status indicators for local storage
  - TransferView panes hide encryption toggle when Local Storage is selected
  - EncryptionManager now rejects encryption operations for local storage (defense-in-depth)

## [2.0.0] - 2026-01-11

### Major Release - CloudSync Ultra v2.0

Complete redesign and rebuild of CloudSync with SwiftUI and modern macOS architecture.

### Added

#### Core Features
- **Dual-pane file browser** with source and destination side-by-side
- **Drag & drop transfers** between any cloud services
- **Dashboard view** with statistics, connected services, and recent activity
- **Cloud-to-cloud transfers** - direct transfers between any providers without downloading
- **Local-to-cloud and cloud-to-local** transfers with full bidirectional support
- **Task management system** with history and status tracking
- **Menu bar integration** for quick access

#### File Operations
- **Context menus** throughout with New Folder, Rename, Download, Delete
- **List and Grid view modes** - toggle between different file displays
- **Search functionality** - find files quickly across any cloud
- **Breadcrumb navigation** for easy path traversal
- **Create folders** with quick-access buttons
- **Rename files/folders** with inline editing
- **Delete files/folders** with confirmation dialogs
- **Download to local** with save panel selection

#### Transfer Features
- **Real-time progress tracking** showing percentage, speed (MB/s), and file count
- **Accurate file counters** displaying exact progress (e.g., 100/100 files)
- **Average transfer speed calculation** for completed transfers
- **Folder size pre-calculation** for accurate progress on folder uploads
- **Transfer modes** - Sync, Transfer, or Backup
- **Smart error handling** - gracefully handles existing files with --ignore-existing
- **Cancel transfers** - stop any operation mid-transfer
- **Transfer history** - view all past transfers with speeds and file counts
- **Helpful tips** for large transfers (e.g., "Zip folders with many small files")

#### Performance
- **Bandwidth throttling** - control upload/download speeds
- **Optimized performance** - parallel transfers (4 concurrent) and checkers (8 concurrent)
- **Async/await** throughout for responsive UI
- **Streaming progress** - real-time updates during transfers
- **@MainActor** annotations for proper UI thread safety

#### Security
- **End-to-end encryption** - optional client-side AES-256 encryption
- **Keychain integration** - secure password storage
- **OAuth 2.0 support** - modern authentication for 20+ providers
- **2FA support** - Proton Drive supports two-factor authentication
- **Export/Import config** - backup and restore rclone configuration
- **Zero-knowledge encryption** standard

#### Cloud Providers (42 Total)

**Core Providers (13):**
- Proton Drive (with 2FA)
- Google Drive (OAuth)
- Dropbox (OAuth)
- OneDrive (OAuth)
- Amazon S3
- MEGA
- Box (OAuth)
- pCloud
- WebDAV
- SFTP
- FTP
- iCloud Drive (planned)
- Local Storage

**Enterprise Services (6):**
- Google Cloud Storage
- Azure Blob Storage
- Azure Files
- OneDrive for Business
- SharePoint
- Alibaba Cloud OSS

**Object Storage (8):**
- Backblaze B2
- Wasabi
- DigitalOcean Spaces
- Cloudflare R2
- Scaleway Object Storage
- Oracle Cloud Storage
- Storj DCS
- Filebase

**Self-Hosted & International (6):**
- Nextcloud
- ownCloud
- Seafile
- Koofr
- Yandex Disk
- Mail.ru Cloud

**Additional Services (9):**
- Jottacloud (experimental)
- Google Photos (OAuth)
- Flickr (OAuth)
- SugarSync (OAuth)
- OpenDrive (OAuth)
- Put.io (OAuth)
- Premiumize.me (OAuth)
- Quatrix (OAuth)
- File Fabric (OAuth)

#### Testing
- **173+ automated tests** total
- **100+ unit tests** covering models, view models, and managers
- **73 UI tests** for end-to-end workflows (ready for integration)
- **Integration tests** for complex workflows
- **Test coverage ~75%** across all layers

#### UI/UX
- **Native macOS design** using SwiftUI
- **Dark mode support** - beautiful in any lighting
- **Vertical view switchers** - compact, space-efficient controls
- **Right-click context menus** - full macOS-style interactions
- **Sidebar navigation** - easy access to all features
- **Status badges** - visual indicators for connection status
- **Error messages** - user-friendly, cleaned-up error text
- **Loading states** - proper feedback during operations
- **Empty states** - helpful guidance when no content

#### Developer Features
- **Modern Swift 5.9** with async/await
- **SwiftUI** declarative UI framework
- **Combine** for reactive data flow
- **MVVM architecture** with clean separation of concerns
- **Comprehensive documentation** - README, QUICKSTART, guides
- **Xcode 15+ support**
- **macOS 14.0+ deployment target**

### Changed
- Complete rewrite from UIKit to SwiftUI
- Moved from MVP single-pane to production dual-pane interface
- Improved error handling with user-friendly messages
- Enhanced progress tracking with accurate file counts
- Better folder handling with size pre-calculation

### Technical Details
- **Language:** Swift 5.9
- **Framework:** SwiftUI
- **Platform:** macOS 14.0+
- **Backend:** rclone for cloud operations
- **Architecture:** MVVM with reactive patterns
- **Testing:** XCTest framework
- **Storage:** rclone config in ~/Library/Application Support/CloudSyncApp/

### Known Issues
- UI test suite not yet integrated into Xcode project (73 tests ready)
- Jottacloud provider marked as experimental
- Large file lists (1000+) may benefit from pagination

### Documentation
- README.md - Complete project overview
- QUICKSTART.md - 5-minute getting started guide
- TEST_COVERAGE.md - Comprehensive test inventory
- QUALITY_ANALYSIS_REPORT.md - Quality manager assessment
- QUALITY_DASHBOARD.md - Visual quality metrics
- DOCUMENTATION_ACCURACY_REPORT.md - Documentation accuracy check
- Multiple implementation guides (OAuth, Jottacloud, Phase 1, etc.)

---

## [1.0.0] - MVP Release

### Added
- Basic menu bar application
- Proton Drive integration
- Simple file sync
- Configuration storage

---

## Upcoming Features

### Planned for v2.1.0
- [ ] UI test suite integration into Xcode project
- [ ] CI/CD pipeline (GitHub Actions)
- [ ] SwiftLint integration
- [ ] Pagination for large file lists (1000+ files)
- [ ] Keyboard shortcuts documentation
- [ ] Accessibility improvements

### Planned for v2.2.0
- [ ] RcloneManager refactoring (split into modules)
- [ ] Dependency injection pattern
- [ ] Performance benchmarks
- [ ] Screenshot/video demos
- [ ] App Store submission preparation

### Future Considerations
- [ ] DocC API documentation
- [ ] Plugin system for custom providers
- [ ] Advanced filtering and sorting
- [ ] File preview functionality
- [ ] Telemetry and analytics (opt-in)
- [ ] Multi-language support

---

[2.0.0]: https://github.com/andybod1-lang/CloudSyncUltra/releases/tag/v2.0.0
[1.0.0]: https://github.com/andybod1-lang/CloudSyncUltra/releases/tag/v1.0.0
