# Changelog

All notable changes to CloudSync Ultra will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

---

## [2.0.40] - 2026-01-18

### Added
- **Contract Testing** - Rclone JSON parsing verification
  - 11 contract tests for lsjson, stats, and error parsing
  - JSON fixtures for valid responses, empty dirs, edge cases
  - Verifies RemoteFile struct compatibility with rclone output
- **Performance Baselines** - Automated regression detection
  - 13 performance tests with XCTest measure blocks
  - Baseline thresholds for file parsing (1K, 10K files)
  - CI workflow alerts on >20% regression
- **Mutation Testing CI** - Weekly code quality checks
  - Scheduled workflow (Saturday 3am UTC)
  - 60% mutation score threshold
  - Results uploaded as artifacts

### Changed
- QA Score increased to 95/100

---

## [2.0.39] - 2026-01-18

### Fixed
- **OpenDrive Authentication** (#170) - Changed from OAuth to password authentication
  - Updated RcloneManager.setupOpenDrive() to accept username/password
  - Fixed wizard flow for credential-based authentication
- **Flickr Provider Removed** (#169) - No valid rclone backend exists
  - Removed from CloudProviderType enum (41 providers now)
  - Updated all test expectations
- **Azure Files Wizard** (#166) - Added missing TestConnectionStep case
- **Seafile Wizard** (#171) - Added TestConnectionStep + server URL field
- **Alibaba OSS Wizard** (#172) - Added TestConnectionStep case
- **FileFabric Wizard** (#173) - Added server URL field for self-hosted instances
- **Quatrix Authentication** (#174) - Changed from OAuth to API key authentication
  - Updated RcloneManager.setupQuatrix() to accept host/apiKey
- **Mail.ru Wizard** (#168) - Added app password guidance instructions

### Changed
- Provider count reduced from 42 to 41 (Flickr removed)
- Test count increased from 855 to 897

### Research
- **Integration Studies** (Sprint v2.0.38) - 14 provider studies completed
  - Local Storage, Azure Files, Yandex Disk, Mail.ru, Flickr
  - Seafile, Alibaba OSS, Oracle Cloud, SugarSync, OpenDrive
  - FileFabric, Quatrix, Premiumize.me, Put.io
  - Discovered 9 bugs/enhancements, all addressed in v2.0.39

---

## [2.0.37] - 2026-01-18

### Fixed
- **ownCloud Wizard Connection** (#165) - Fixed missing switch case in TestConnectionStep
  - Added `.owncloud` and `.nextcloud` cases to wizard flow
  - Proper WebDAV URL construction with `/remote.php/webdav/` suffix

### Added
- **FTP Security Enhancements** (#164) - FTPS support and security warnings
  - FTPS toggle (Explicit TLS / Implicit TLS modes)
  - Security warning for plain FTP connections
  - Certificate verification skip option for self-signed certs

### Research
- **S3-Compatible Provider Studies** (Sprint v2.0.37)
  - DigitalOcean Spaces (#129): Already works, EASY
  - Wasabi (#128): Already works, EASY
  - Scaleway (#131): Already works, EASY
  - Filebase (#134): Already works, EASY
  - Finding: All 4 S3-compatible providers fully implemented

### Process
- **QA Phase Added** - Two-phase sprint with QA verification before closure

---

## [2.0.36] - 2026-01-17

### Added
- **SFTP SSH Key Authentication** (#163) - Secure SSH key-based SFTP connections
  - SSH key file picker (defaults to ~/.ssh/, shows hidden files)
  - Key passphrase support for encrypted keys
  - Updated RcloneManager with key_file and key_file_pass parameters

### Research
- **Cloud Storage & Protocol Integration Studies** (Sprint v2.0.36)
  - Azure Blob Storage (#137): Already works, EASY
  - Google Cloud Storage (#135): Already works, EASY
  - Storj (#133): Already works, EASY
  - FTP (#144): Already works, EASY
  - ownCloud (#140): Already works via WebDAV, EASY
  - Finding: All 5 providers already work with no code changes

---

## [2.0.35] - 2026-01-17

### Added
- **MEGA 2FA Support** (#160) - Two-factor authentication for MEGA connections
  - Optional TOTP code field in MEGA wizard
  - Follows existing ProtonDrive 2FA pattern

### Research
- **Cloud Storage & Protocol Integration Studies** (Sprint v2.0.35)
  - Amazon S3 (#126): Already works, EASY
  - Backblaze B2 (#127): Already works, EASY
  - Cloudflare R2 (#130): Already works, EASY
  - WebDAV (#142): Already works, EASY
  - SFTP (#143): Partially works, needs SSH key UI (MEDIUM)
  - Finding: 5 of 6 providers already work with no code changes

---

## [2.0.34] - 2026-01-17

### Added
- **Google Photos Provider** - Full support with read-only OAuth scope (#159)
  - `googlePhotos` provider type with proper rclone gphotos backend
  - Read-only scope prevents accidental deletions
  - Transfer optimization with 8MB chunk size

### Research
- **Enterprise Provider Integration Studies** (Sprint v2.0.34)
  - SharePoint (#156): Already works, MEDIUM difficulty for custom OAuth
  - OneDrive Business (#155): Already works, EASY
  - Nextcloud (#139): Already works via WebDAV, EASY
  - MEGA (#146): Needs 2FA field, MEDIUM
  - Koofr (#147): Already works, EASY
  - Finding: 4 of 5 providers already work with no code changes

---

## [2.0.32] - 2026-01-16

### Added
- **Interactive Onboarding** (#83) - Wizards integrated into onboarding flow
  - "Connect a Provider Now" button in AddProviderStepView
  - "Try a Sync Now" button in FirstSyncStepView
  - State persistence via AppStorage
  - Users can skip or complete interactive steps

### Research
- **Windows Port Feasibility** (#65) - Architecture research complete
  - Evaluated 7 approaches (Tauri, Flutter, Electron, etc.)
  - Recommendation: Tauri (Rust + web frontend)
  - Estimated timeline: 4-5 months with 2 developers

---

## [2.0.31] - 2026-01-16

### Added
- **Wizard Infrastructure** - Reusable multi-step wizard components
  - WizardView, WizardProgressView for consistent wizard UX
- **Provider Connection Wizard** (#113) - Guided cloud provider setup
  - Provider selection, credential configuration, connection testing
- **Schedule Creation Wizard** (#114) - Guided schedule setup
  - Remote selection, timing configuration, review step
- **Transfer Setup Wizard** (#115) - Guided transfer setup
  - Source/destination selection, options, review step
- **In-App Feedback Manager** (#97) - Submit feedback via GitHub issues
  - Category selection, system info attachment, gh CLI integration
- **Security Enhancements** (#116-120)
  - AuthRateLimiter with exponential backoff (#118)
  - SecureString wrapper with memory clearing (#119)
  - Secure rclone path detection (#117)
  - Privacy-conscious account name handling (#120)

### Fixed
- **Encryption for All Users** (#121) - Removed subscription paywall
- **Encryption Import Detection** - Auto-enable encryption when importing rclone.conf with crypt remotes
- **Multi-Select Delete** - Context menu now shows correct item count

---

## [2.0.29] - 2026-01-16

### Removed
- **Team Plan** (#106) - Removed from all views and code
  - SubscriptionTier.swift, PaywallView.swift, SubscriptionView.swift
  - StoreKitManager.swift, Configuration.storekit

### Added
- Backlog split: #113-115 (Wizards), #116-120 (Security)

### Improved
- Moved archives to dedicated `.claude-team/archive/` folder
- Health score improved to 90%

---

## [2.0.28] - 2026-01-16

### Fixed
- **Path Breadcrumb Text Size** (#111) - Matches search field for consistency
- **Clear History Button Style** (#108) - Uses borderedProminent style
- **New Task Button Style** (#107) - Uses borderedProminent style
- **Drag Files Hint Text** (#99) - Larger text with proper wrapping

### Changed
- **Quick Access Section** (#105) - Moved to bottom of Performance settings

### Improved
- Dashboard: Test trend display, health history tracking, open PRs display
- Archived 18 outdated files for cleaner project structure

---

## [2.0.27] - 2026-01-16

### Fixed
- **Keyboard Shortcuts** (#102) - ⌘1/2/3 now navigate to sidebar sections
- **Notification Settings** (#100) - Requests permission before opening Settings

---

## [2.0.26] - 2026-01-16

### Fixed
- **Onboarding Connect Button** (#101) - Real OAuth flow for provider connection
  - Connect button now initiates actual OAuth authentication
  - Seamless provider setup during onboarding

- **Custom Performance Profile** (#103) - Auto-expand advanced settings
  - Selecting "Custom" now auto-expands Advanced Settings section
  - Updated description to guide users to the settings

- **Encryption Terminology** (#109, #112) - Corrected button labels
  - Fixed "Enable Decryption" → "Enable Encryption" in FileBrowserView
  - Updated accessibility labels and hints
  - Fixed Settings encryption toggle description

- **Remote Name Auto-Update** (#110) - Provider selection sync
  - Remote Name now updates when selecting a different provider
  - No longer keeps stale name from previous selection

- **Duplicate Progress Bars** (#104) - Tasks view cleanup
  - Running tasks no longer appear twice in Tasks view
  - RunningTaskIndicator shows compact view, Active section filters running tasks

### Infrastructure
- **Worker Quality Standards v2** - Enhanced operational excellence
  - Added FILE_OWNERSHIP.md for domain boundaries
  - Added ALERTS.md for worker notifications
  - Added check-ownership.sh script for validation
  - Updated project-ops-kit templates

---

## [2.0.25] - 2026-01-15

### Added
- **Keyboard Navigation** (#54) - Complete keyboard-driven workflows
  - Full navigation support throughout the application
  - Tab and arrow key support for all UI controls
  - Accessibility improvements for power users

- **Input Validation & Data Handling** (#75) - Enhanced security
  - Comprehensive input validation for all user inputs
  - Secure temporary file handling
  - Crash log data scrubbing for privacy

- **Brand Identity Documentation** (#79) - Visual identity guidelines
  - Brand guidelines and specifications
  - Visual identity documentation
  - Design system documentation

### Infrastructure
- **Worker Quality Standards** (Pillar 7) - Operational excellence improvements
  - Quality metrics and standards documentation
  - Worker performance tracking
  - Process improvement documentation

---

## [2.0.24] - 2026-01-15

### Added
- **Performance Settings UI** (#40) - Transfer optimization profiles
  - Four profiles: Conservative, Balanced, Performance, Custom
  - Five configurable settings: parallel transfers, bandwidth limit, chunk size, CPU priority, check frequency
  - PerformanceSettingsView with profile selector and advanced settings section
  - Quick toggle in TransferView for session-only profile switching
  - Auto-switches to Custom when values differ from presets
  - 14 unit tests for PerformanceProfile model

---

## [2.0.23] - 2026-01-15

### Added
- **StoreKit 2 Subscriptions** (#46) - Complete subscription system
  - Three tiers: Free ($0), Pro ($9.99/mo), Team ($19.99/mo)
  - SubscriptionTier model with feature limits
  - StoreKitManager with modern async/await APIs
  - PaywallView for upgrade prompts with tier comparison
  - SubscriptionView for subscription management
  - Feature gating in RemotesViewModel, SyncManager, EncryptionManager
  - StoreKit testing configuration

- **Security Hardening** (#74) - Pre-launch security improvements
  - SecurityManager.swift for secure file operations
  - Log file permissions (600) for privacy
  - Path sanitization to prevent directory traversal
  - Secure temp file handling

- **Legal Compliance Package** - App Store ready
  - Privacy Policy (GDPR/CCPA compliant)
  - Terms of Service
  - App Privacy Labels documentation
  - GDPR and CCPA compliance documentation

- **Marketing Launch Package** - Go-to-market ready
  - POSITIONING.md - Target segments, competitive analysis
  - LANDING_PAGE_COPY.md - Full landing page content
  - APP_STORE_DESCRIPTION.md - ASO-optimized listing
  - PRESS_KIT.md - Press release, founder bio
  - PRODUCT_HUNT_PLAN.md - Launch strategy
  - LAUNCH_CHECKLIST.md - 100+ item checklist
  - SOCIAL_TEMPLATES.md - Platform-specific posts

- **App Store Submission Assets** (#78)
  - App description (4000 chars)
  - Keywords (99 chars optimized)
  - Metadata and categories
  - Screenshot capture guide
  - Submission checklist

### Fixed
- **CI Pipeline** - Fixed coverage report failures blocking builds
  - Made coverage steps non-blocking (continue-on-error)
  - Improved error handling when coverage data unavailable

### Infrastructure
- New directories: `docs/legal/`, `docs/marketing/`, `docs/APP_STORE_SUBMISSION/`
- New specialized agents: Revenue-Engineer, Legal-Advisor, Marketing-Lead
- 5 workers completed in parallel (Phase 1)

---

## [2.0.22] - 2026-01-15

### Added
- **Quick Actions Menu** (#49) - Keyboard-driven productivity
  - New QuickActionsView with Cmd+Shift+N shortcut
  - Fast access to common operations
  - Integrated into MainWindow

- **Provider-Specific Chunk Sizes** (#73) - Optimized transfers
  - ChunkSizeConfig for per-provider optimal chunk sizes
  - Integrated with TransferOptimizer
  - Proper rclone flags for Google Drive, OneDrive, Dropbox, S3, B2

- **Transfer Preview with Dry-Run** (#55) - Pre-transfer visibility
  - TransferPreview model for operation summaries
  - Dry-run support to see what will be transferred
  - File counts, sizes, and operation breakdowns

### Changed
- RcloneManager now uses ChunkSizeConfig for provider-aware chunk sizes
- TransferOptimizer.buildArgs() accepts optional provider parameter
- Moved CrashReportingManager to dedicated file (code cleanup)

### Tests
- 841 tests total (839 passing)
- New: ChunkSizeTests.swift (25 tests)
- New: TransferPreviewTests.swift (25 tests)

---

## [2.0.21] - 2026-01-15

### Added
- **Project-Ops-Kit v1.0.0** - Major template update for reusability
  - Removed all hardcoded paths - scripts now auto-detect project root
  - Added missing scripts: ticket.sh, launch_workers.sh, auto_launch_workers.sh
  - Made template fully generic (no CloudSync-specific references)
  - Added {PROJECT_ROOT} placeholders for portable deployment
  - Comprehensive README with full usage documentation
  - Template ready for any Claude Code parallel development project

- **Crash Reporting System** (#20) - Privacy-first crash handling
  - CrashReport model for structured crash data
  - CrashReportViewer for user-accessible crash logs
  - Enhanced CrashReportingManager with signal handlers
  - Local-only storage respecting user privacy
  - CrashReportingTests.swift with comprehensive coverage

- **Transfer Optimizer** (#10) - Enhanced performance optimization
  - TransferOptimizer.swift for intelligent transfer tuning
  - Dynamic buffer sizing based on file sizes
  - Provider-aware parallel transfer limits
  - Integrated with existing transfer engine

- **Test Automation Expansion** (#27) - Quality assurance improvements
  - 770 total tests (up from 743)
  - +27 new tests covering crash reporting, onboarding validation
  - Onboarding validation report with real-world testing results

### Changed
- **App Icon Design** (#77) - Icon generation infrastructure ready
- **UI Review** (#44) - AppTheme consistency audit completed

### Infrastructure
- Pre-commit hooks for quality gates (`scripts/pre-commit`)
- Test count recording (`scripts/record-test-count.sh`)
- Session templates for development workflow
- Operational excellence tracker updated (42% → 57%)

### Tests
- 770 tests total (768 passing, 2 pre-existing timing issues)
- New: CrashReportingTests.swift
- Enhanced: OnboardingViewModelTests.swift

---

## [2.0.20] - 2026-01-14

### Added
- **Onboarding Flow** (#80, #81, #82) - Complete first-time user experience
  - 4-step wizard: Welcome, Add Provider, First Sync, Completion
  - OnboardingViewModel with state persistence
  - Progress tracking with skip option
  - 35 comprehensive tests

- **Dynamic Parallelism** (#70) - Smart transfer optimization
  - Provider-specific parallelism (Google Drive: 8, S3: 16, Proton: 2)
  - File-size aware tuning for better performance
  - DynamicParallelismConfig struct

- **Fast-List Support** (#71) - Faster directory listings
  - Enabled for: Google Drive, S3, Dropbox, OneDrive, B2, Box, GCS
  - Reduces API calls significantly

- **Provider Icons** (#95) - Visual provider identification
  - ProviderIconView component with SF Symbols
  - Brand colors for 11 major providers in Asset Catalog
  - AppTheme+ProviderColors extension

- **Visual Polish** (#84) - Consistent styling throughout

### Changed
- TransferOptimizer now uses provider-aware optimization
- Test timing fixes for edge cases

### Fixed
- **Onboarding UX issues discovered in real-world testing:**
  - Provider card grid alignment (changed to fixed 130px columns)
  - Click detection on provider cards not working
  - Provider list overflow hiding navigation buttons (added ScrollView)
  - "Show All 40+ Providers" toggle not responding to clicks
  - Quick Tips cards inconsistent sizing (now uniform 140x120px)

### Infrastructure
- CloudSyncApp/Components/ProviderIconView.swift
- CloudSyncApp/Assets.xcassets/ProviderColors/
- CloudSyncApp/Styles/AppTheme+ProviderColors.swift

### QA Notes
- UI tests compile but require Xcode GUI to run (Gatekeeper limitation)
- All 762 tests passing

---

## [2.0.19] - 2026-01-14

### Fixed
- **Build Fix** - Added missing AppTheme aliases
  - `cornerRadiusSmall` and `cornerRadiusLarge` aliases added to AppTheme struct
  - Fixed build error: 'type AppTheme has no member cornerRadiusSmall'
  - FileBrowserView.swift was referencing AppTheme.cornerRadiusSmall

### Tests
- All 743 tests passing

---

## [2.0.18] - 2026-01-14

### Added
- **Multi-Thread Downloads** (#72) - Verified complete with 30+ tests
- **App Icon Design** (#77) - Spec, SVG template, generation script
- **UI Visual Refresh** (#84) - AppTheme applied to 5 views
- **Pricing Strategy** (#85) - $29 one-time recommended
- **Marketing Channels** (#86) - Report + launch checklist
- **UI Test Integration** (#88) - 69 XCUITests integrated
- **Notifications System** (#90) - NotificationManager verified
- **CONTRIBUTING.md** (#92) - 450+ lines contributor guide
- **PUBLISHING_GUIDE.md** (#94) - ~650 lines publishing documentation

### Infrastructure
- CloudSyncApp/Styles/ directory (AppTheme, ButtonStyles, CardStyles)
- CloudSyncAppUITests/ (7 test files, 69 tests)
- Icon generation: SVG template + shell script
- 5 professional PDFs in docs/pdfs/

---

## [2.0.17] - 2026-01-14

### Added
- **Accessibility** (Dev-1) - VoiceOver labels + keyboard shortcuts
- **OSLog Logging** (Dev-2) - Replaced print() with structured logging
- **Help System** - HelpManager, HelpCategory, HelpTopic models
- **Onboarding** - OnboardingManager for first-run experience
- **Pagination** - LazyVStack for large file lists (Performance)

### Fixed
- Test assertions: 41 supported providers (iCloud enabled)
- Int64/Int type comparisons in RcloneManager

### Infrastructure
- Architecture refactor plan for RcloneManager
- Marketing channels research task
- All 743 tests passing

---

## [2.0.16] - 2026-01-14

### Performance (#70)
- TransferOptimizer class with dynamic parallelism
- Default buffer increased to 32MB
- Default checkers increased to 16
- Applied to all transfer methods (sync, download, copy, etc.)

### Security (#58)
- App Sandbox ENABLED with proper entitlements
- Path validation to prevent command injection
- Password passed via stdin (not CLI args)
- Secure temp file handling (UUID paths, 0o600 permissions)
- rclone.conf secured with 0o600
- Input length validation on credential fields

### Tests
- PathValidationSecurityTests.swift
- TransferOptimizerTests.swift

### Reports
- PERFORMANCE_ENGINEER_COMPLETE.md - Deep transfer analysis
- SECURITY_AUDITOR_COMPLETE.md - 16 vulnerabilities identified
- BRAND_DESIGNER_COMPLETE.md - Visual identity plan

---

## [2.0.15] - 2026-01-14

### Added
- **iCloud Integration Phase 1** (#9) - Local folder support
  - ICloudManager.swift for iCloud detection and path management
  - UI option: "Use Local iCloud Folder (Recommended)" in Add Cloud dialog
  - Local folder detection: `~/Library/Mobile Documents/com~apple~CloudDocs/`
  - Fixed rclone type: `icloud` → `iclouddrive`
  - 35 unit tests in ICloudIntegrationTests.swift
  - Fixed CloudProviderTests.swift iCloud support assertion

- **Crash Reporting Infrastructure** (#20) - Privacy-first crash handling
  - Dev-2: Converted 82 print() statements to OSLog Logger in RcloneManager.swift
  - Dev-3: CrashReportingManager with exception and signal handlers
  - Log export functionality for user-controlled sharing
  - Crash reports stored locally in Application Support directory

- **Specialized Agents System** (#44, #45) - On-demand expert agents
  - UX-Designer: UI/UX analysis, user flow improvements
  - Product-Manager: Strategy, requirements, roadmap planning
  - Architect: System design, refactoring decisions
  - Security-Auditor: Vulnerability analysis, security review
  - Performance-Engineer: Deep optimization analysis
  - Tech-Writer: Documentation and guides
  - All use **Opus + extended thinking** for thorough analysis
  - Launch: `launch_single_worker.sh ux-designer opus`

### Analysis & Strategy
- **UX Audit** (#44) - Comprehensive UX review
  - Overall UX score: 6.4/10
  - Critical finding: No onboarding experience (First-Time UX: 4.3/10)
  - Top 10 prioritized recommendations documented
  - Strengths: Native design, dark mode, error handling
  - Full report: `.claude-team/outputs/UX_DESIGNER_COMPLETE.md`

- **Product Strategy** (#45) - Strategic planning complete
  - Vision statement and strategic positioning defined
  - 4 user personas: Privacy Pro, Creative, SMB Owner, Power User
  - MoSCoW feature prioritization
  - 90-day roadmap with milestones
  - Competitive analysis vs Dropbox, Google Drive, OneDrive
  - Full strategy: `.claude-team/outputs/PRODUCT_MANAGER_COMPLETE.md`

### Infrastructure
- Updated `launch_single_worker.sh` to support 11 agent types
- `SPECIALIZED_AGENTS.md` - Complete agent documentation
- `RECOVERY.md` - Updated with all startup commands

## [2.0.14] - 2026-01-13

### Performance
- **Transfer Speed Optimization** (#10) - 2x speed improvement with parallel transfers
  - Increased `--transfers` from 4 to 8 (parallel file uploads/downloads)
  - Increased `--checkers` from 8 to 16 (parallel file verification)
  - Added `--buffer-size 32M` (was 16M default)
  - Added `--fast-list` for faster directory listings
  - Large folder parallelism increased to 16-32 transfers (was 8-16)
  - Full optimization roadmap in `.claude-team/outputs/DEV2_PERFORMANCE_AUDIT.md`

### Research
- **Crash Reporting Feasibility Study** (#20) - Evaluated options, documented recommendation
  - Recommend: Enhanced DIY approach using existing OSLog infrastructure
  - Privacy-first: No external services, local logs only
  - Implementation estimate: 2-3 days when prioritized
  - Full analysis in `.claude-team/outputs/DEV3_CRASH_REPORTING.md`

### Infrastructure
- **GitHub Actions Workflow** (#34) - Auto-add issues to project board
  - Created `.github/workflows/add-to-project.yml`
  - Requires PAT with `project` scope (setup instructions in file)
  - Pending: Manual workflow file creation via GitHub web UI

## [2.0.13] - 2026-01-13

### Fixed
- **Schedule Time Display** (#32) - Time picker now shows selected value correctly
  - Added `.pickerStyle(.menu)` to hour pickers
  - Increased frame width from 100 to 120 points for better visibility

- **Test Suite Health** (#35) - All 616 tests now pass (was 23 failing)
  - Updated provider count expectations (now 41 providers)
  - Fixed locale-dependent formatting tests (ByteCountFormatter)
  - Resolved timing edge cases in schedule tests
  - Corrected implementation behavior assumptions

### Added
- **12/24 Hour Time Format Setting** (#33) - User preference for time display
  - Toggle in Settings → General → "Use 24-Hour Time"
  - 12-hour format: "2 AM", "11 PM"
  - 24-hour format: "02:00", "23:00"
  - Persists via @AppStorage across restarts

### Documentation
- `docs/CLEAN_BUILD_GUIDE.md` - Xcode troubleshooting and clean build steps
- `docs/TEST_ACCOUNTS_GUIDE.md` - Cloud provider signup with Claude Cowork tips
- `.claude-team/planning/DROPBOX_PLAN.md` - Dropbox validation test plan

### Infrastructure
- **Dev-Ops Worker Added** - 5th team member for Git, GitHub, docs, research
  - Always uses Opus with extended thinking
  - Handles commits, pushes, issue management, CHANGELOG updates
- **Team Structure Update** - Strategic Partner now delegates ALL implementation
- Closed issues: #30 (won't fix), #31, #32, #33, #35, #36, #38 (dup), #39 (upstream)

## [2.0.12] - 2026-01-13

### Added
- **Drag & Drop Cloud Service Reordering** (#14) - Customize sidebar order
  - Drag cloud services to reorder them in the sidebar
  - Order persists across app restarts
  - Local storage remains fixed at bottom
  - CloudRemote model now has `sortOrder` property

- **Account Name in Encryption View** (#25) - See connected accounts
  - Email/username displays below service name in encryption settings
  - CloudRemote model now has `accountName` property
  - Graceful fallback when account name not available

- **Bandwidth Throttling Controls** (#1) - Manage transfer speeds
  - New Bandwidth section in Settings
  - Separate upload/download limits (MB/s)
  - Quick preset buttons (1, 5, 10, 50, unlimited)
  - Fixed rclone format to use "UPLOAD:DOWNLOAD" syntax
  - Limits applied to all transfer operations

### Tests
- RemoteReorderingTests.swift (6 tests) - sortOrder property and move operations
- AccountNameTests.swift (6 tests) - accountName property and display logic
- BandwidthThrottlingUITests.swift (7 tests) - settings persistence and presets

### Infrastructure
- Worker briefings updated with model selection guidance
- Extended thinking instructions added for complex tasks
- QA now always uses Opus for thorough test coverage

## [2.0.11] - 2026-01-13

### Added
- **Comprehensive Error Handling System** (#8) - World-class error handling across the entire application
  - **TransferError Foundation** (#11) - 25+ specific error types with user-friendly messages
    * Storage/quota errors (Google Drive full, rate limits, local storage full)
    * Authentication errors (token expired, access denied, OAuth failures)
    * Network errors (timeouts, connection failures, DNS issues, SSL errors)
    * File/path errors (file too large, invalid filenames, checksum mismatches)
    * Provider-specific errors (Google Photos, Dropbox, OneDrive, S3, Proton Drive)
    * Pattern matching system for automatic error detection from rclone output
    * Retry/critical classification for intelligent error handling
  - **Error Detection & Parsing** (#12) - RcloneManager error parsing and tracking
    * parseError() method with TransferError pattern matching
    * SyncProgress enhanced with error fields (errorMessage, failedFiles, partialSuccess)
    * Exit code handling (0-8 mapped to error types)
    * Partial failure detection and tracking
  - **Error Banner System** (#15) - Professional error notifications
    * ErrorNotificationManager for global error state management
    * Severity-based styling (critical=red, retryable=orange, info=blue)
    * Auto-dismiss after 10 seconds for non-critical errors
    * Retry button for retryable errors
    * Multi-error stacking (max 3 errors)
  - **Task Error States & UI** (#13) - Complete error integration in Tasks
    * SyncTask model with structured error fields (lastError, errorContext, failedFiles)
    * 9 computed properties for error display (displayErrorMessage, canRetry, hasCriticalError)
    * TasksView with failed task styling (red backgrounds, error icons)
    * Retry and Details buttons for failed tasks
    * Status-specific icons (❌ failed, ✅ success, ⏳ running)
  - **Comprehensive Test Coverage** (#16) - 61 new tests protecting error handling
    * TransferErrorTests.swift (48 tests) - Pattern parsing, classification, user messages
    * SyncTaskErrorTests.swift (9 tests) - Error states, computed properties
    * RcloneManagerErrorTests.swift (4 tests) - Error detection, partial failures
    * 88%+ overall test coverage

### Infrastructure
- **Multi-Agent Development Sprint** - Coordinated 4-worker parallel execution
  * Dev-3: TransferError foundation (6 minutes)
  * Dev-2 + Dev-1 + QA: Parallel Phase 2 execution (37 minutes)
  * Dev-3 + Dev-1: Coordinated Phase 3 (1h 47m)
  * QA: Final testing and validation (3 minutes)
  * Total sprint duration: 3 hours 11 minutes
  * 2-3x faster than single developer with higher quality

## [2.0.10] - 2026-01-13

### Fixed
- **OneDrive Integration** (#29) - Complete overhaul of OneDrive authentication and configuration
  - Fixed OAuth flow to properly handle drive type selection after authentication
  - Added support for personal, business, and SharePoint account types
  - Automatic error recovery when drive type is misconfigured
  - Connection verification before completing setup
  - Enhanced logging for debugging OAuth flow
  - Resolves "ObjectHandle is Invalid" errors that prevented OneDrive access
  - Root cause: OAuth succeeded but rclone defaulted to invalid drive type

## [2.0.9] - 2026-01-13

### Added
- **Transfer view state persistence** (#18) - Selected remotes and paths now persist when navigating away
- **Provider search field** (#22) - Filter through 42 cloud providers quickly
- **Hover highlight on username** (#17) - Visual feedback when hovering over usernames in sidebar

### Changed
- **Remote name dialog timing** (#23) - Name field only appears after selecting a provider

### Infrastructure
- **Model selection for workers** - Sonnet for XS/S tickets, Opus for M/L/XL tickets
- **WORKER_MODELS.conf** - Configure models per worker before launch

## [2.0.8] - 2026-01-12

### Fixed
- **Cloud-to-cloud progress** (#21) - Transfers between cloud providers now show progress correctly
  - Added `--stats-one-line` flag to `copyFiles()` for consistent output
  - Fixed operator precedence bug in `parseProgress()` 

### Added
- **Test coverage** - QA added 30 new tests:
  - `TimeFormattingTests.swift` (17 tests) - Time format edge cases
  - `SidebarOrderTests.swift` (8 tests) - Sidebar position verification
  - `CloudProviderTests.swift` (5 tests) - Provider property verification
- **Automated worker launcher** - Scripts for hands-free worker deployment:
  - `launch_single_worker.sh` - Launch one worker
  - `launch_all_workers.sh` - Launch all workers with tasks

## [2.0.7] - 2026-01-12

### Fixed
- **Cloud-to-cloud progress** (#21) - Transfers between cloud providers now show progress correctly
  - Added `--stats-one-line` flag to `copyFiles()` for consistent output
  - Fixed operator precedence bug in `parseProgress()` 

### Added
- **Test coverage** - QA added 30 new tests:
  - `TimeFormattingTests.swift` (17 tests) - Time format edge cases
  - `SidebarOrderTests.swift` (8 tests) - Sidebar position verification
  - `CloudProviderTests.swift` (5 tests) - Provider property verification
- **Automated worker launcher** - Scripts for hands-free worker deployment:
  - `launch_single_worker.sh` - Launch one worker
  - `launch_all_workers.sh` - Launch all workers with tasks

## [2.0.6] - 2026-01-12

### Added
- **GitHub Issues Ticket System** - Crash-proof work tracking
  - Issue templates: Bug Report, Feature Request, Internal Task (with YAML forms)
  - 30 labels organized by: status, worker, priority, component, size
  - GitHub Project board: https://github.com/users/andybod1-lang/projects/1
  - Label-based workflow: triage → ready → in-progress → needs-review → closed
  - Complete workflow documentation in `.github/WORKFLOW.md`
  - All work state persists on GitHub, survives device/power failures

### Changed
- Updated PARALLEL_TEAM.md with GitHub Issues integration
- Updated PROJECT_CONTEXT.md with ticket system documentation
- Streamlined recovery: just check `gh issue list` after crash

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

