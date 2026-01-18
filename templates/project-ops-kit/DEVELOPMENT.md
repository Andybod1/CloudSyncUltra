# {{PROJECT_NAME}} - Development Guide

Technical documentation for developers working on {{PROJECT_NAME}} {{VERSION}}.

## Architecture Overview

### Component Hierarchy

```
{{APP_ENTRY_POINT}} (App Entry)
    │
    ├── WindowGroup (Main Window)
    │   └── MainWindow
    │       ├── NavigationSplitView
    │       │   ├── SidebarView
    │       │   │   ├── Navigation Items
    │       │   │   └── Content Lists
    │       │   │
    │       │   └── Detail Views
    │       │       ├── DashboardView
    │       │       ├── ContentView
    │       │       └── Other Views
    │       │
    │       ├── QuickActionsView (Cmd+Shift+N overlay)
    │       │
    │       └── Environment Objects
    │           ├── MainViewModel
    │           ├── ContentViewModel
    │           └── Other ViewModels
    │
    ├── OnboardingView (First launch)
    │   └── Multi-Step Wizard
    │
    ├── Settings Scene
    │   └── SettingsView (Tabs)
    │       ├── GeneralSettingsView
    │       ├── AccountSettingsView
    │       └── AboutView
    │
    └── AppDelegate
        └── StatusBarController
            └── Menu Bar UI
```

### Data Flow

```
User Action → SwiftUI View → ViewModel → Manager → Service/API
                                         ↓
                                  Business Logic
                                         │
User Notification ← UI Update ← Published State ← Result ←──┘
```

### MVVM Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         VIEWS                               │
│  MainWindow │ DashboardView │ ContentView │ OtherViews     │
│  QuickActionsView │ OnboardingView │ SettingsView          │
└──────────────────────────┬──────────────────────────────────┘
                           │ @EnvironmentObject
┌──────────────────────────▼──────────────────────────────────┐
│                      VIEW MODELS                            │
│  MainViewModel │ ContentViewModel │ OtherViewModels        │
│  @Published properties for reactive UI updates             │
└──────────────────────────┬──────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────┐
│                       MANAGERS                              │
│  ServiceManager │ DataManager │ NotificationManager        │
│  Other business logic managers                             │
└──────────────────────────┬──────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────┐
│                        MODELS                               │
│  DataModel │ ConfigModel │ ErrorModel │ OtherModels        │
└─────────────────────────────────────────────────────────────┘
```

## Key Components

### 1. Models

#### DataModel.swift
Core data structures:

```swift
struct DataItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: ItemType
    var isConfigured: Bool
    var path: String
    var sortOrder: Int
}

enum ItemType: String, CaseIterable, Codable {
    case typeOne = "type_one"
    case typeTwo = "type_two"
    // ... more types

    var displayName: String { ... }
    var iconName: String { ... }      // SF Symbol
}
```

#### ErrorModel.swift
Comprehensive error handling system:

```swift
struct AppError: Error, Identifiable {
    let id = UUID()
    let type: ErrorType
    let message: String
    let recoverySuggestion: String?
    let isRetryable: Bool
    let underlyingError: String?

    enum ErrorType {
        case networkError
        case authenticationFailed
        case permissionDenied
        case validationError
        // ... more error types
    }

    static func parse(from output: String) -> AppError?
}
```

### 2. ViewModels

#### MainViewModel.swift

```swift
@MainActor
class MainViewModel: ObservableObject {
    static let shared = MainViewModel()

    @Published var items: [DataItem] = []
    @Published var selectedItem: DataItem?

    func loadItems()
    func saveItems()
    func addItem(_ item: DataItem)
    func removeItem(_ item: DataItem)
    func updateItem(_ item: DataItem)
    func moveItem(from: IndexSet, to: Int) // Drag reordering

    var configuredItems: [DataItem] {
        items.filter { $0.isConfigured }
            .sorted { $0.sortOrder < $1.sortOrder }
    }
}
```

### 3. Views

#### QuickActionsView.swift
Keyboard-driven productivity menu:

```swift
struct QuickActionsView: View {
    @State private var searchText = ""
    @State private var selectedIndex = 0
    @Binding var isShowing: Bool

    let actions = [
        QuickAction(title: "Action 1", icon: "plus.circle"),
        QuickAction(title: "Action 2", icon: "arrow.right.circle"),
        // ... more actions
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

### 4. Core Managers

#### ServiceManager.swift

```swift
class ServiceManager {
    static let shared = ServiceManager()

    func performAction() async throws -> Result
    func fetchData() async throws -> [DataItem]

    // Error parsing
    func parseError(from output: String, exitCode: Int32) -> AppError? {
        AppError.parse(from: output) ??
        AppError.fromExitCode(exitCode)
    }
}
```

## State Management

### Global State (Singletons)
```swift
MainViewModel.shared              // Main data management
ServiceManager.shared             // Core operations
NotificationManager.shared        // User notifications
ErrorNotificationManager.shared   // Error banners
```

### Local State (Views)
```swift
@State private var showingQuickActions = false
@State private var selectedItems: Set<UUID> = []
@StateObject private var viewModel = SpecificViewModel()
```

### Environment Objects
```swift
.environmentObject(mainViewModel)
.environmentObject(serviceManager)
.environmentObject(errorManager)
```

### Data Persistence
```swift
// UserDefaults keys
"storedItems"            // [DataItem] JSON
"hasCompletedOnboarding" // Bool
"userPreferences"        // [String: Any] JSON

// Keychain (secure storage)
"secureCredentials"      // Sensitive data
```

## Testing Infrastructure

### {{TEST_COUNT}} Automated Tests

#### Test Categories
- **Models** - Data structure tests
- **ViewModels** - State management tests
- **Managers** - Business logic tests
- **Integration** - End-to-end workflows
- **UI Tests** - User interaction flows

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
    - uses: actions/checkout@v4
    - name: Select Xcode
      run: sudo xcode-select -s /Applications/Xcode_{{XCODE_VERSION}}.app
    - name: Build
      run: {{BUILD_COMMAND}}
    - name: Test
      run: {{TEST_COMMAND}}
```

### Pre-commit Hooks

#### scripts/pre-commit
```bash
#!/bin/bash
# Pre-commit hook for {{PROJECT_NAME}}

echo "Running pre-commit checks..."

# 1. Swift syntax check
echo "Checking Swift syntax..."
find . -name "*.swift" -exec swiftc -parse {} \; || exit 1

# 2. Build check
echo "Building project..."
{{BUILD_COMMAND}} || exit 1

# 3. Version consistency
echo "Checking version consistency..."
./scripts/version-check.sh || exit 1

echo "Pre-commit checks passed!"
```

## Adding Features

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

## Keyboard Navigation

### Global Shortcuts
| Shortcut | Action | Handler |
|----------|--------|---------|
| `⌘N` | Add new item | MainWindow.swift |
| `⌘,` | Open Settings | AppDelegate.swift |
| `⌘⇧N` | Quick Actions menu | MainWindow.swift |
| `⌘1-9` | Switch sidebar sections | SidebarView.swift |

### Implementation Pattern
```swift
struct ContentView: View {
    @FocusState private var isFocused: Bool
    @State private var selectedIndex: Int = 0

    var body: some View {
        List(selection: $selection) { ... }
            .focused($isFocused)
            .onKeyPress(.upArrow) {
                moveSelection(by: -1)
                return .handled
            }
            .onKeyPress(.downArrow) {
                moveSelection(by: 1)
                return .handled
            }
            .onKeyPress(.return) {
                openSelected()
                return .handled
            }
    }
}
```

## Build & Deployment

### Debug Build
```bash
{{BUILD_COMMAND}}
```

### Release Build
```bash
xcodebuild -scheme {{PROJECT_NAME}} -configuration Release \
    -archivePath {{PROJECT_NAME}}.xcarchive archive

xcodebuild -exportArchive \
    -archivePath {{PROJECT_NAME}}.xcarchive \
    -exportPath Release \
    -exportOptionsPlist ExportOptions.plist
```

### Version Management
```bash
# Update version
./scripts/update-version.sh {{VERSION}}

# Create release
./scripts/release.sh {{VERSION}}
```

---

**Development Guide Version**: {{VERSION}}
**Last Updated**: {{DATE}}
**Architecture**: MVVM + SwiftUI
**Tests**: {{TEST_COUNT}} automated tests
