# CloudSync 2.0 - Development Guide

Technical documentation for developers working on CloudSync.

## Architecture Overview

### Component Hierarchy (v2.0)

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
    │       │       ├── TasksView
    │       │       ├── HistoryView
    │       │       └── FileBrowserView
    │       │
    │       └── Environment Objects
    │           ├── SyncManager
    │           ├── RemotesViewModel
    │           └── TasksViewModel
    │
    ├── Settings Scene
    │   └── SettingsView (Tabs)
    │       ├── GeneralSettingsView
    │       ├── AccountSettingsView
    │       ├── EncryptionSettingsView
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
                                                              │
User Notification ← UI Update ← Published State ← Progress ←──┘
```

### MVVM Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         VIEWS                               │
│  MainWindow │ DashboardView │ TransferView │ TasksView     │
└──────────────────────────┬──────────────────────────────────┘
                           │ @EnvironmentObject
┌──────────────────────────▼──────────────────────────────────┐
│                      VIEW MODELS                            │
│  RemotesViewModel │ TasksViewModel │ FileBrowserViewModel  │
│  @Published properties for reactive UI updates             │
└──────────────────────────┬──────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────┐
│                       MANAGERS                              │
│  SyncManager │ RcloneManager │ EncryptionManager           │
│  Business logic, process management, data persistence      │
└──────────────────────────┬──────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────┐
│                        MODELS                               │
│  CloudProvider │ CloudRemote │ SyncTask │ FileItem         │
└─────────────────────────────────────────────────────────────┘
```

## Key Components

### 1. Models

#### CloudProvider.swift
Defines supported cloud services:

```swift
enum CloudProviderType: String, CaseIterable, Codable {
    case protonDrive = "proton"
    case googleDrive = "gdrive"
    case dropbox = "dropbox"
    // ... 13+ providers
    
    var displayName: String { ... }
    var iconName: String { ... }      // SF Symbol
    var brandColor: Color { ... }     // Provider brand color
    var rcloneType: String { ... }    // rclone config type
}

struct CloudRemote: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: CloudProviderType
    var isConfigured: Bool
    var path: String
    var isEncrypted: Bool
}

struct FileItem: Identifiable {
    let id: UUID
    let name: String
    let path: String
    let isDirectory: Bool
    let size: Int64
    let modifiedDate: Date
    // Computed: icon, formattedSize, formattedDate
}
```

#### SyncTask.swift
Task/job model for transfers:

```swift
enum TaskType: String, Codable {
    case sync, transfer, backup
}

enum TaskState: String, Codable {
    case pending, running, completed, failed, paused, cancelled
}

struct SyncTask: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: TaskType
    var sourceRemote: String
    var sourcePath: String
    var destinationRemote: String
    var destinationPath: String
    var state: TaskState
    var progress: Double
    var bytesTransferred: Int64
    var totalBytes: Int64
    // ... scheduling, timestamps, error info
}
```

#### AppTheme.swift
Design system constants:

```swift
struct AppColors {
    static let primary: Color
    static let primaryGradient: LinearGradient
    static let cardBackground: Color
    static let success, warning, error, info: Color
}

struct AppDimensions {
    static let sidebarWidth: CGFloat = 240
    static let cornerRadius: CGFloat = 10
    static let padding: CGFloat = 16
    // ...
}

// View modifiers
extension View {
    func cardStyle() -> some View
    func sidebarItemStyle(isSelected: Bool) -> some View
}
```

### 2. ViewModels

#### RemotesViewModel.swift
Manages cloud connections:

```swift
@MainActor
class RemotesViewModel: ObservableObject {
    static let shared = RemotesViewModel()
    
    @Published var remotes: [CloudRemote] = []
    @Published var selectedRemote: CloudRemote?
    
    func loadRemotes()           // Load from UserDefaults
    func saveRemotes()           // Persist to UserDefaults
    func addRemote(_ remote)     // Add new connection
    func removeRemote(_ remote)  // Remove connection
    func updateRemote(_ remote)  // Update existing
    
    var configuredRemotes: [CloudRemote]  // Filter configured
    var cloudRemotes: [CloudRemote]       // Filter non-local
}
```

#### TasksViewModel.swift
Manages sync jobs:

```swift
@MainActor
class TasksViewModel: ObservableObject {
    static let shared = TasksViewModel()
    
    @Published var tasks: [SyncTask] = []
    @Published var activeTasks: [SyncTask] = []
    @Published var taskHistory: [SyncTask] = []
    @Published var logs: [TaskLog] = []
    
    func createTask(...) -> SyncTask
    func startTask(_ task) async
    func pauseTask(_ task)
    func cancelTask(_ task)
    func deleteTask(_ task)
    
    var runningTasksCount: Int
    var pendingTasksCount: Int
}
```

#### FileBrowserViewModel.swift
File navigation state:

```swift
@MainActor
class FileBrowserViewModel: ObservableObject {
    @Published var currentPath: String = ""
    @Published var files: [FileItem] = []
    @Published var selectedFiles: Set<UUID> = []
    @Published var isLoading = false
    @Published var sortOrder: SortOrder = .nameAsc
    @Published var viewMode: ViewMode = .list
    @Published var searchQuery: String = ""
    
    func setRemote(_ remote: CloudRemote)
    func loadFiles() async
    func navigateTo(_ path: String)
    func navigateUp()
    func sortFiles()
    
    var filteredFiles: [FileItem]
    var pathComponents: [(name: String, path: String)]
}
```

### 3. Views

#### MainWindow.swift
Main application structure:

```swift
struct MainWindow: View {
    @StateObject private var syncManager = SyncManager.shared
    @StateObject private var remotesVM = RemotesViewModel.shared
    @StateObject private var tasksVM = TasksViewModel.shared
    
    @State private var selectedSection: SidebarSection = .dashboard
    
    var body: some View {
        NavigationSplitView {
            SidebarView(...)
        } detail: {
            switch selectedSection {
            case .dashboard: DashboardView()
            case .transfer: TransferView()
            case .tasks: TasksView()
            case .history: HistoryView()
            case .settings: SettingsView()
            case .remote(let r): FileBrowserView(remote: r)
            }
        }
        .environmentObject(syncManager)
        .environmentObject(remotesVM)
        .environmentObject(tasksVM)
    }
}
```

#### DashboardView.swift
Overview with stats cards:

```swift
struct DashboardView: View {
    var body: some View {
        ScrollView {
            VStack {
                headerSection          // Welcome + status badge
                statsSection           // 4 stat cards
                connectedServicesSection  // Cloud provider grid
                recentActivitySection  // Last 5 tasks
                quickActionsSection    // Action buttons
            }
        }
    }
}
```

#### TransferView.swift
Dual-pane file browser:

```swift
struct TransferView: View {
    @StateObject private var sourceBrowser = FileBrowserViewModel()
    @StateObject private var destBrowser = FileBrowserViewModel()
    
    var body: some View {
        VStack {
            transferToolbar  // Mode picker, refresh
            
            HStack {
                FileBrowserPane(browser: sourceBrowser, ...)
                transferControls  // → ← swap buttons
                FileBrowserPane(browser: destBrowser, ...)
            }
        }
    }
}
```

#### TasksView.swift
Job queue management:

```swift
struct TasksView: View {
    var body: some View {
        VStack {
            taskHeader  // Title + "New Task" button
            
            if tasks.isEmpty {
                emptyState
            } else {
                ScrollView {
                    ForEach(tasks) { task in
                        TaskCard(task: task, ...)
                    }
                }
            }
        }
    }
}
```

### 4. Core Managers

#### SyncManager.swift
Sync orchestration (unchanged from v1):

```swift
@MainActor
class SyncManager: ObservableObject {
    @Published var syncStatus: SyncStatus = .idle
    @Published var lastSyncTime: Date?
    @Published var currentProgress: SyncProgress?
    @Published var isMonitoring = false
    
    func startMonitoring() async
    func stopMonitoring()
    func performSync(mode: SyncMode) async
    func configureProtonDrive(username:password:) async throws
    func configureEncryption(password:salt:encryptFilenames:) async throws
}
```

#### RcloneManager.swift
rclone process interface (unchanged from v1):

```swift
class RcloneManager {
    func setupProtonDrive(username:password:) async throws
    func sync(localPath:remotePath:mode:encrypted:) async throws -> AsyncStream<SyncProgress>
    func listRemoteFiles(remotePath:encrypted:) async throws -> [RemoteFile]
    func setupEncryptedRemote(password:salt:encryptFilenames:) async throws
    func stopCurrentSync()
}
```

## State Management

### Global State (Singletons)
```swift
SyncManager.shared      // Sync operations
RemotesViewModel.shared // Cloud connections
TasksViewModel.shared   // Job queue
```

### Local State (Views)
```swift
@State private var selectedSection: SidebarSection
@State private var searchQuery: String
@StateObject private var browser = FileBrowserViewModel()
```

### Environment Objects
```swift
.environmentObject(syncManager)
.environmentObject(remotesVM)
.environmentObject(tasksVM)
```

### Data Persistence
```swift
// UserDefaults keys
"cloudRemotes"    // [CloudRemote] JSON
"syncTasks"       // [SyncTask] JSON
"taskHistory"     // [SyncTask] JSON
"localPath"       // String
"remotePath"      // String
"syncInterval"    // Double
"autoSync"        // Bool
```

## Concurrency

### Main Actor
All ViewModels use `@MainActor`:
```swift
@MainActor
class TasksViewModel: ObservableObject {
    // All @Published properties update on main thread
}
```

### Async/Await
File operations use async/await:
```swift
func loadFiles() async {
    isLoading = true
    do {
        files = try await loadRemoteFiles(...)
    } catch {
        self.error = error.localizedDescription
    }
    isLoading = false
}
```

### Task Management
```swift
Task {
    await tasksVM.startTask(task)
}

// Cancellation
task.cancel()
```

## Adding Features

### Adding a New Cloud Provider

1. **Add to CloudProviderType enum:**
```swift
case nextcloud = "nextcloud"

var displayName: String {
    case .nextcloud: return "Nextcloud"
}

var iconName: String {
    case .nextcloud: return "server.rack"
}

var brandColor: Color {
    case .nextcloud: return Color(hex: "0082C9")
}

var rcloneType: String {
    case .nextcloud: return "webdav"  // or specific type
}
```

2. **Add configuration method to RcloneManager:**
```swift
func setupNextcloud(url: String, username: String, password: String) async throws {
    // rclone config create ...
}
```

3. **Add UI in AccountSettingsView:**
- Add fields for Nextcloud-specific config
- Handle OAuth if needed

### Adding a New View

1. **Create the view file:**
```swift
// Views/NewFeatureView.swift
struct NewFeatureView: View {
    @EnvironmentObject var tasksVM: TasksViewModel
    
    var body: some View {
        // ...
    }
}
```

2. **Add to SidebarSection:**
```swift
enum SidebarSection: Hashable {
    case newFeature  // Add case
}
```

3. **Add to detail switch:**
```swift
case .newFeature: NewFeatureView()
```

4. **Add sidebar item:**
```swift
sidebarItem(icon: "star", title: "New Feature", section: .newFeature)
```

### Adding Drag & Drop

```swift
struct FileBrowserPane: View {
    var body: some View {
        List { ... }
            .onDrop(of: [.fileURL], delegate: FileDropDelegate(browser: browser))
    }
}

class FileDropDelegate: DropDelegate {
    func performDrop(info: DropInfo) -> Bool {
        // Handle dropped files
    }
}
```

## Testing

### Unit Tests
```swift
class TasksViewModelTests: XCTestCase {
    func testCreateTask() {
        let vm = TasksViewModel.shared
        let task = vm.createTask(
            name: "Test",
            type: .transfer,
            sourceRemote: "local",
            sourcePath: "/test",
            destinationRemote: "proton",
            destinationPath: "/backup"
        )
        XCTAssertEqual(task.state, .pending)
    }
}
```

### UI Tests
```swift
func testDashboardLoads() {
    let app = XCUIApplication()
    app.launch()
    XCTAssertTrue(app.staticTexts["Welcome to CloudSync"].exists)
}
```

## Build Configuration

### Info.plist
```xml
<key>LSUIElement</key>
<false/>  <!-- Show in Dock (v2.0) -->

<key>CFBundleShortVersionString</key>
<string>2.0.0</string>
```

### Build Settings
```
MACOSX_DEPLOYMENT_TARGET = 14.0
SWIFT_VERSION = 5.0
MARKETING_VERSION = 2.0.0
CURRENT_PROJECT_VERSION = 2
```

## Debugging

### Console Logging
```swift
print("[SyncManager] Starting sync: \(task.name)")
print("[RcloneManager] Progress: \(progress.percentage)%")
print("[FileBrowser] Loading: \(currentPath)")
```

### View Debugging
```swift
#Preview {
    DashboardView()
        .environmentObject(SyncManager.shared)
        .environmentObject(RemotesViewModel.shared)
        .environmentObject(TasksViewModel.shared)
        .frame(width: 900, height: 700)
}
```

### State Inspection
Use Xcode's Debug Navigator to inspect:
- `@Published` property changes
- Task execution
- Memory usage

## Performance

### Lazy Loading
```swift
LazyVStack {  // Only renders visible items
    ForEach(files) { file in
        FileRow(file: file)
    }
}
```

### Debouncing
```swift
// Search debouncing
.onChange(of: searchQuery) { _, newValue in
    searchTask?.cancel()
    searchTask = Task {
        try? await Task.sleep(nanoseconds: 300_000_000)
        await performSearch(newValue)
    }
}
```

### Caching
```swift
// File list caching
private var fileCache: [String: [FileItem]] = [:]

func loadFiles() async {
    if let cached = fileCache[currentPath] {
        files = cached
        return
    }
    // Load from remote...
}
```

---

**Development Guide Version**: 2.0  
**Last Updated**: January 2026  
**Architecture**: MVVM + SwiftUI
