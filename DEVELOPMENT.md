# CloudSync Ultra 2.0 - Development Guide

Technical documentation for developers working on CloudSync Ultra v2.0.22.

## Architecture Overview

### Component Hierarchy (v2.0.22)

```
CloudSyncAppApp (App Entry)
    │
    ├── WindowGroup (Main Window)
    │   └── MainWindow
    │       ├── NavigationSplitView
    │       │   ├── SidebarView
    │       │   │   ├── Navigation Items
    │       │   │   ├── Cloud Remotes List
    │       │   │   └── Local Storage List
    │       │   │
    │       │   └── Detail Views
    │       │       ├── DashboardView
    │       │       ├── TransferView (Dual-Pane)
    │       │       ├── SchedulesView
    │       │       ├── TasksView
    │       │       ├── HistoryView
    │       │       └── FileBrowserView
    │       │
    │       ├── QuickActionsView (Cmd+Shift+N overlay)
    │       │
    │       └── Environment Objects
    │           ├── SyncManager
    │           ├── RemotesViewModel
    │           ├── TasksViewModel
    │           └── ScheduleManager
    │
    ├── OnboardingView (First launch)
    │   └── 4-Step Wizard
    │       ├── WelcomeStep
    │       ├── AddProviderStep
    │       ├── FirstTransferStep
    │       └── QuickTipsStep
    │
    ├── Settings Scene
    │   └── SettingsView (Tabs)
    │       ├── GeneralSettingsView
    │       ├── AccountSettingsView
    │       ├── SyncSettingsView
    │       └── AboutView
    │
    └── AppDelegate
        └── StatusBarController
            └── Menu Bar UI
```

### Data Flow

```
User Action → SwiftUI View → ViewModel → Manager → rclone → Cloud Provider
                                         ↓
                                  TransferOptimizer
                                    (v2.0.22)
                                         ↓
                              Provider-specific tuning
                                         │
User Notification ← UI Update ← Published State ← Progress ←──┘
```

### MVVM Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         VIEWS                               │
│  MainWindow │ DashboardView │ TransferView │ TasksView     │
│  QuickActionsView │ OnboardingView │ SchedulesView         │
└──────────────────────────┬──────────────────────────────────┘
                           │ @EnvironmentObject
┌──────────────────────────▼──────────────────────────────────┐
│                      VIEW MODELS                            │
│  RemotesViewModel │ TasksViewModel │ FileBrowserViewModel  │
│  OnboardingViewModel │ ScheduleManager                     │
│  @Published properties for reactive UI updates             │
└──────────────────────────┬──────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────┐
│                       MANAGERS                              │
│  SyncManager │ RcloneManager │ EncryptionManager           │
│  TransferOptimizer │ CrashReportingManager                 │
│  NotificationManager │ ErrorNotificationManager            │
└──────────────────────────┬──────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────┐
│                        MODELS                               │
│  CloudProvider │ CloudRemote │ SyncTask │ FileItem         │
│  TransferError │ TransferPreview │ ChunkSizeConfig         │
│  SyncSchedule │ CrashReport │ OnboardingState              │
└─────────────────────────────────────────────────────────────┘
```

## Key Components

### 1. Models

#### CloudProvider.swift
Defines 42+ supported cloud services:

```swift
enum CloudProviderType: String, CaseIterable, Codable {
    // Major providers
    case protonDrive = "protondrive"
    case googleDrive = "drive"
    case dropbox = "dropbox"
    case onedrive = "onedrive"
    case amazonS3 = "s3"
    case mega = "mega"
    case box = "box"
    case pcloud = "pcloud"
    case icloudDrive = "iclouddrive"
    case backblazeB2 = "b2"
    case googleCloudStorage = "gcs"

    // ... 31 more providers

    var displayName: String { ... }
    var iconName: String { ... }      // SF Symbol
    var brandColor: Color { ... }     // Provider brand color
    var rcloneType: String { ... }    // rclone config type
    var authType: AuthType { ... }    // OAuth, password, API key
}

struct CloudRemote: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: CloudProviderType
    var isConfigured: Bool
    var path: String
    var isEncrypted: Bool
    var sortOrder: Int               // User-customizable order
    var accountName: String?         // Email/username display
}
```

#### TransferError.swift (NEW in v2.0.11)
Comprehensive error handling system:

```swift
struct TransferError: Error, Identifiable {
    let id = UUID()
    let type: ErrorType
    let message: String
    let recoverySuggestion: String?
    let isRetryable: Bool
    let underlyingError: String?

    enum ErrorType {
        case quotaExceeded
        case authenticationFailed
        case networkTimeout
        case fileNotFound
        case permissionDenied
        case checksumMismatch
        case rateLimited
        // ... 20+ error types
    }

    static func parse(from output: String) -> TransferError?
}
```

#### TransferPreview.swift (NEW in v2.0.22)
Dry-run preview model:

```swift
struct TransferPreview: Codable {
    let totalFiles: Int
    let totalSize: Int64
    let newFiles: Int
    let modifiedFiles: Int
    let deletedFiles: Int
    let operations: [Operation]

    struct Operation: Identifiable {
        let id = UUID()
        let type: OperationType // new, update, delete
        let path: String
        let size: Int64?
    }
}
```

#### ChunkSizeConfig.swift (NEW in v2.0.22)
Provider-specific optimization:

```swift
struct ChunkSizeConfig {
    let provider: CloudProviderType
    let chunkSize: String
    let transfers: Int
    let checkers: Int

    static let configurations: [CloudProviderType: ChunkSizeConfig] = [
        .googleDrive: ChunkSizeConfig(
            provider: .googleDrive,
            chunkSize: "128M",
            transfers: 8,
            checkers: 16
        ),
        .dropbox: ChunkSizeConfig(
            provider: .dropbox,
            chunkSize: "150M",
            transfers: 4,
            checkers: 8
        ),
        // ... configurations for all providers
    ]
}
```

#### SyncSchedule.swift
Schedule model for automated syncing:

```swift
struct SyncSchedule: Identifiable, Codable {
    let id: UUID
    var name: String
    var sourceRemote: CloudRemote
    var sourcePath: String
    var destinationRemote: CloudRemote
    var destinationPath: String
    var frequency: ScheduleFrequency
    var isEnabled: Bool
    var lastRun: Date?
    var nextRun: Date?

    enum ScheduleFrequency: String, Codable, CaseIterable {
        case hourly, daily, weekly, custom
    }
}
```

### 2. ViewModels

#### RemotesViewModel.swift
Enhanced with sorting and account names:

```swift
@MainActor
class RemotesViewModel: ObservableObject {
    static let shared = RemotesViewModel()

    @Published var remotes: [CloudRemote] = []
    @Published var selectedRemote: CloudRemote?

    func loadRemotes()
    func saveRemotes()
    func addRemote(_ remote)
    func removeRemote(_ remote)
    func updateRemote(_ remote)
    func moveRemote(from: IndexSet, to: Int) // Drag reordering

    var configuredRemotes: [CloudRemote] {
        remotes.filter { $0.isConfigured }
            .sorted { $0.sortOrder < $1.sortOrder }
    }
}
```

#### OnboardingViewModel.swift (NEW in v2.0.20)
First-run experience state:

```swift
@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var currentStep = 0
    @Published var isComplete = false
    @Published var selectedProvider: CloudProviderType?
    @Published var hasAddedFirstCloud = false
    @Published var hasCompletedFirstTransfer = false

    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false

    func nextStep()
    func previousStep()
    func skipOnboarding()
    func completeOnboarding()
}
```

#### ScheduleManager.swift
Manages scheduled sync execution:

```swift
@MainActor
class ScheduleManager: ObservableObject {
    static let shared = ScheduleManager()

    @Published var schedules: [SyncSchedule] = []
    @Published var activeTimers: [UUID: Timer] = [:]
    @Published var nextScheduledSync: Date?

    func createSchedule(...) -> SyncSchedule
    func updateSchedule(_ schedule: SyncSchedule)
    func deleteSchedule(_ schedule: SyncSchedule)
    func runScheduleNow(_ schedule: SyncSchedule) async
    func startScheduleTimers()
    func stopScheduleTimers()
}
```

### 3. Views

#### QuickActionsView.swift (NEW in v2.0.22)
Keyboard-driven productivity menu:

```swift
struct QuickActionsView: View {
    @State private var searchText = ""
    @State private var selectedIndex = 0
    @Binding var isShowing: Bool

    let actions = [
        QuickAction(title: "Add Cloud Service", icon: "plus.circle"),
        QuickAction(title: "Quick Transfer", icon: "arrow.right.circle"),
        QuickAction(title: "New Folder", icon: "folder.badge.plus"),
        QuickAction(title: "Schedule Sync", icon: "calendar.badge.clock"),
        QuickAction(title: "View Recent Transfers", icon: "clock.arrow.circlepath")
    ]

    var body: some View {
        VStack(spacing: 0) {
            SearchField(text: $searchText)

            ScrollView {
                ForEach(filteredActions) { action in
                    QuickActionRow(action: action, ...)
                }
            }
        }
        .onKeyPress(.downArrow) { ... }
        .onKeyPress(.upArrow) { ... }
        .onKeyPress(.return) { ... }
    }
}
```

#### OnboardingView.swift (NEW in v2.0.20)
4-step wizard for new users:

```swift
struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            ProgressIndicator(currentStep: viewModel.currentStep)

            TabView(selection: $viewModel.currentStep) {
                WelcomeStep()
                    .tag(0)
                AddProviderStep()
                    .tag(1)
                FirstTransferStep()
                    .tag(2)
                QuickTipsStep()
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            NavigationButtons(viewModel: viewModel)
        }
    }
}
```

#### SchedulesView.swift
Main window schedule management:

```swift
struct SchedulesView: View {
    @EnvironmentObject var scheduleManager: ScheduleManager
    @State private var showingNewSchedule = false

    var body: some View {
        VStack {
            if let nextSync = scheduleManager.nextScheduledSync {
                NextSyncBanner(date: nextSync)
            }

            if scheduleManager.schedules.isEmpty {
                EmptySchedulesView()
            } else {
                List {
                    ForEach(scheduleManager.schedules) { schedule in
                        ScheduleRowView(schedule: schedule)
                    }
                }
            }
        }
        .toolbar {
            Button("New Schedule") { showingNewSchedule = true }
        }
    }
}
```

### 4. Core Managers

#### RcloneManager.swift
Enhanced with optimization and preview:

```swift
class RcloneManager {
    private let optimizer = TransferOptimizer()

    func sync(localPath:remotePath:mode:encrypted:) async throws -> AsyncStream<SyncProgress>
    func listRemoteFiles(remotePath:encrypted:) async throws -> [RemoteFile]
    func copyFiles(source:destination:files:preview:) async throws -> TransferResult
    func previewTransfer(source:destination:) async throws -> TransferPreview

    // NEW: Provider-aware optimization
    private func buildTransferArgs(for provider: CloudProviderType?) -> [String] {
        var args = optimizer.buildArgs(parallelism: nil, provider: provider)

        if let config = ChunkSizeConfig.configurations[provider] {
            args.append("--drive-chunk-size=\(config.chunkSize)")
        }

        return args
    }

    // NEW: Enhanced error parsing
    func parseError(from output: String, exitCode: Int32) -> TransferError? {
        TransferError.parse(from: output) ??
        TransferError.fromExitCode(exitCode)
    }
}
```

#### TransferOptimizer.swift (NEW in v2.0.16)
Performance tuning engine:

```swift
class TransferOptimizer {
    struct OptimizationParams {
        let transfers: Int
        let checkers: Int
        let bufferSize: String

        static let `default` = OptimizationParams(
            transfers: 8,    // Increased from 4
            checkers: 16,    // Increased from 8
            bufferSize: "32M" // Increased from 16M
        )
    }

    func buildArgs(parallelism: OptimizationParams? = nil,
                   provider: CloudProviderType? = nil) -> [String] {
        let params = parallelism ?? .default
        var args = [
            "--transfers=\(params.transfers)",
            "--checkers=\(params.checkers)",
            "--buffer-size=\(params.bufferSize)"
        ]

        // Provider-specific optimizations
        if let provider = provider {
            switch provider {
            case .googleDrive:
                args.append("--drive-chunk-size=128M")
                args.append("--fast-list")
            case .dropbox:
                args.append("--dropbox-chunk-size=150M")
            case .s3:
                args.append("--s3-chunk-size=5M")
                args.append("--s3-upload-concurrency=16")
            // ... more providers
            }
        }

        return args
    }
}
```

#### CrashReportingManager.swift (NEW in v2.0.21)
Privacy-first crash handling:

```swift
class CrashReportingManager {
    static let shared = CrashReportingManager()

    private let crashReportsURL: URL
    private var signalSources: [DispatchSourceSignal] = []

    func setup() {
        setupExceptionHandling()
        setupSignalHandlers()
    }

    private func setupExceptionHandling() {
        NSSetUncaughtExceptionHandler { exception in
            self.handleException(exception)
        }
    }

    private func setupSignalHandlers() {
        let signals = [SIGABRT, SIGILL, SIGSEGV, SIGFPE, SIGBUS, SIGPIPE]

        for sig in signals {
            let source = DispatchSource.makeSignalSource(signal: sig)
            source.setEventHandler {
                self.handleSignal(sig)
            }
            source.resume()
            signalSources.append(source)
        }
    }

    func getCrashReports() -> [CrashReport] {
        // Load from local storage only
    }
}
```

#### ErrorNotificationManager.swift (NEW in v2.0.11)
Global error state management:

```swift
@MainActor
class ErrorNotificationManager: ObservableObject {
    static let shared = ErrorNotificationManager()

    @Published var currentErrors: [TransferError] = []
    @Published var isShowingError = false

    private var dismissTimers: [UUID: Timer] = [:]

    func show(_ error: TransferError) {
        currentErrors.append(error)
        isShowingError = true

        // Auto-dismiss non-critical errors
        if !error.type.isCritical {
            startDismissTimer(for: error, duration: 10)
        }
    }

    func dismiss(_ error: TransferError) {
        currentErrors.removeAll { $0.id == error.id }
        if currentErrors.isEmpty {
            isShowingError = false
        }
    }

    func retry(_ error: TransferError) async {
        // Implement retry logic
    }
}
```

## State Management

### Global State (Singletons)
```swift
SyncManager.shared          // Sync operations
RemotesViewModel.shared     // Cloud connections
TasksViewModel.shared       // Job queue
ScheduleManager.shared      // Scheduled syncs
ErrorNotificationManager.shared // Error banners
CrashReportingManager.shared    // Crash reports
```

### Local State (Views)
```swift
@State private var showingQuickActions = false
@State private var selectedFiles: Set<UUID> = []
@State private var transferPreview: TransferPreview?
@StateObject private var onboardingVM = OnboardingViewModel()
```

### Environment Objects
```swift
.environmentObject(syncManager)
.environmentObject(remotesVM)
.environmentObject(tasksVM)
.environmentObject(scheduleManager)
.environmentObject(errorManager)
```

### Data Persistence
```swift
// UserDefaults keys
"cloudRemotes"       // [CloudRemote] JSON
"syncTasks"          // [SyncTask] JSON
"syncSchedules"      // [SyncSchedule] JSON
"hasCompletedOnboarding" // Bool
"use24HourTime"      // Bool
"uploadBandwidthLimit" // Double (MB/s)
"downloadBandwidthLimit" // Double (MB/s)
```

## Testing Infrastructure

### 841 Automated Tests (v2.0.22)

#### Test Categories
- **Models** (150+ tests)
  - CloudProviderTests.swift - 42 provider configurations
  - TransferErrorTests.swift - 48 error parsing tests
  - ChunkSizeTests.swift - 25 optimization tests
  - TransferPreviewTests.swift - 25 preview tests

- **ViewModels** (200+ tests)
  - RemotesViewModelTests.swift - Remote management
  - TasksViewModelTests.swift - Task queue logic
  - OnboardingViewModelTests.swift - 35 onboarding tests
  - ScheduleManagerTests.swift - 32 schedule tests

- **Managers** (250+ tests)
  - RcloneManagerTests.swift - Core sync engine
  - TransferOptimizerTests.swift - Performance tuning
  - CrashReportingTests.swift - 27 crash handling tests
  - ErrorNotificationTests.swift - Error display logic

- **Integration** (100+ tests)
  - End-to-end transfer workflows
  - Provider authentication flows
  - Schedule execution tests
  - Error recovery scenarios

- **UI Tests** (69 tests)
  - OnboardingUITests.swift
  - TransferUITests.swift
  - QuickActionsUITests.swift
  - ErrorHandlingUITests.swift

### CI/CD Pipeline

#### GitHub Actions (.github/workflows/ci.yml)
```yaml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v3
    - name: Select Xcode
      run: sudo xcode-select -s /Applications/Xcode_14.3.app
    - name: Build
      run: xcodebuild build -scheme CloudSyncApp
    - name: Test
      run: xcodebuild test -scheme CloudSyncApp
    - name: Upload coverage
      uses: codecov/codecov-action@v3
```

### Pre-commit Hooks

#### scripts/pre-commit
```bash
#!/bin/bash
# Pre-commit hook for CloudSync Ultra

echo "Running pre-commit checks..."

# 1. Swift format check
if command -v swiftformat >/dev/null 2>&1; then
    echo "Checking Swift formatting..."
    swiftformat --lint . || exit 1
fi

# 2. Run tests
echo "Running tests..."
xcodebuild test -scheme CloudSyncApp -quiet || exit 1

# 3. Check for TODO/FIXME
echo "Checking for unresolved TODOs..."
if grep -r "TODO\|FIXME" --include="*.swift" .; then
    echo "Warning: Found TODO/FIXME comments"
fi

# 4. Update test count
./scripts/record-test-count.sh

echo "Pre-commit checks passed!"
```

## Adding Features

### Adding a New Cloud Provider

1. **Add to CloudProviderType enum:**
```swift
case myprovider = "myprovider"

var displayName: String {
    case .myprovider: return "My Provider"
}

var iconName: String {
    case .myprovider: return "cloud.fill"
}

var brandColor: Color {
    case .myprovider: return Color(hex: "0082C9")
}
```

2. **Add chunk size configuration:**
```swift
// In ChunkSizeConfig.swift
.myprovider: ChunkSizeConfig(
    provider: .myprovider,
    chunkSize: "64M",
    transfers: 4,
    checkers: 8
)
```

3. **Add authentication UI:**
```swift
// In AccountSettingsView.swift
case .myprovider:
    MyProviderConfigView(remote: remote)
```

4. **Add tests:**
```swift
// In CloudProviderTests.swift
func testMyProviderConfiguration() {
    let provider = CloudProviderType.myprovider
    XCTAssertEqual(provider.displayName, "My Provider")
    XCTAssertEqual(provider.rcloneType, "myprovider")
}
```

### Adding a New Feature

1. **Create feature branch:**
```bash
git checkout -b feature/my-feature
```

2. **Add model if needed:**
```swift
// Models/MyFeature.swift
struct MyFeature: Identifiable, Codable {
    let id: UUID
    // ... properties
}
```

3. **Add ViewModel:**
```swift
// ViewModels/MyFeatureViewModel.swift
@MainActor
class MyFeatureViewModel: ObservableObject {
    @Published var items: [MyFeature] = []
    // ... logic
}
```

4. **Add View:**
```swift
// Views/MyFeatureView.swift
struct MyFeatureView: View {
    @StateObject private var viewModel = MyFeatureViewModel()

    var body: some View {
        // ... UI
    }
}
```

5. **Add tests:**
```swift
// Tests/MyFeatureTests.swift
class MyFeatureTests: XCTestCase {
    func testMyFeature() {
        // ... tests
    }
}
```

6. **Update test count:**
```bash
./scripts/record-test-count.sh
```

## Performance Optimization

### Transfer Performance

#### Provider-Specific Tuning
```swift
// Automatic optimization based on provider
let optimizer = TransferOptimizer()
let args = optimizer.buildArgs(provider: .googleDrive)
// Results in: --transfers=8 --checkers=16 --buffer-size=32M --drive-chunk-size=128M
```

#### Dynamic Parallelism
```swift
// Adapts based on file count and size
if fileCount > 1000 {
    params.transfers = 16
} else if totalSize > 1_000_000_000 { // 1GB
    params.transfers = 8
} else {
    params.transfers = 4
}
```

### UI Performance

#### List Virtualization
```swift
// Use LazyVStack for large lists
LazyVStack {
    ForEach(files) { file in
        FileRow(file: file)
    }
}
```

#### Image Loading
```swift
// Async image loading for provider icons
AsyncImage(url: provider.iconURL) { image in
    image.resizable()
} placeholder: {
    ProgressView()
}
```

#### Search Debouncing
```swift
.onChange(of: searchQuery) { _, newValue in
    searchTask?.cancel()
    searchTask = Task {
        try? await Task.sleep(nanoseconds: 300_000_000)
        await performSearch(newValue)
    }
}
```

## Debugging

### Console Logging

```swift
// Use Logger instead of print
import os.log

private let logger = Logger(subsystem: "com.cloudsync.app",
                          category: "RcloneManager")

logger.debug("Starting transfer: \(task.name)")
logger.error("Transfer failed: \(error.localizedDescription)")
```

### Debug Previews

```swift
#Preview("Error State") {
    TasksView()
        .environmentObject(mockTasksVM(withError: true))
}

#Preview("Multiple Clouds") {
    DashboardView()
        .environmentObject(mockRemotesVM(count: 5))
}
```

### Performance Profiling

1. **Instruments**: Use Time Profiler for CPU usage
2. **Memory Graph**: Debug memory leaks
3. **View Hierarchy**: Debug layout issues
4. **Network Link Conditioner**: Test slow connections

## Code Style Guide

### SwiftUI Best Practices

```swift
// ✅ Good - Extract complex views
struct FileRow: View {
    let file: FileItem

    var body: some View {
        HStack {
            Image(systemName: file.icon)
            VStack(alignment: .leading) {
                Text(file.name)
                Text(file.formattedSize)
                    .font(.caption)
            }
        }
    }
}

// ❌ Bad - Inline complex views
List {
    ForEach(files) { file in
        HStack {
            Image(systemName: file.isDirectory ? "folder" : "doc")
            VStack(alignment: .leading) {
                Text(file.name)
                Text(ByteCountFormatter.string(fromByteCount: file.size))
                    .font(.caption)
            }
        }
    }
}
```

### Error Handling

```swift
// ✅ Good - User-friendly errors
do {
    try await rclone.sync(...)
} catch {
    let transferError = TransferError.parse(from: error) ??
                       TransferError.generic(error)
    await errorManager.show(transferError)
}

// ❌ Bad - Raw error display
do {
    try await rclone.sync(...)
} catch {
    print(error)
}
```

### Testing

```swift
// ✅ Good - Descriptive test names
func testTransferPreviewShowsCorrectFileCounts() async {
    // Given
    let source = mockRemote(withFiles: 10)
    let destination = mockRemote(withFiles: 5)

    // When
    let preview = try await rclone.previewTransfer(
        from: source,
        to: destination
    )

    // Then
    XCTAssertEqual(preview.newFiles, 5)
    XCTAssertEqual(preview.totalFiles, 10)
}
```

## Build & Deployment

### Debug Build
```bash
xcodebuild -scheme CloudSyncApp -configuration Debug build
```

### Release Build
```bash
xcodebuild -scheme CloudSyncApp -configuration Release \
    -archivePath CloudSyncApp.xcarchive archive

xcodebuild -exportArchive \
    -archivePath CloudSyncApp.xcarchive \
    -exportPath Release \
    -exportOptionsPlist ExportOptions.plist
```

### Version Management
```bash
# Update version
./scripts/update-version.sh 2.0.23

# Create release
./scripts/release.sh 2.0.23
```

---

**Development Guide Version**: 2.0.22
**Last Updated**: January 2026
**Architecture**: MVVM + SwiftUI
**Tests**: 841 automated tests